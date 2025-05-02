AddCSLuaFile("shared.lua")
include("shared.lua")




/*-----------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
local WhiteListModels = {
    "models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_01.mdl",
    "models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_02.mdl",
    "models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_03.mdl",
    "models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_04.mdl",
    "models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_05.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_06.mdl"
}


-- Override total du lancer de grenades
function ENT:OnGrenadeAttack(status, overrideEnt, landDir)
	if status == "Init" then
	  local e = self:GetEnemy()
	  -- annule toujours par défaut
	  if not IsValid(e) or not self:Visible(e) then return true end
	  local d = self:GetPos():Distance(e:GetPos())
	  -- only if visible & 200–600 units & <1 grenade used
	  if d>200 and d<600 and (self.GrenadesThrown or 0)<1 then
		self.GrenadesThrown = (self.GrenadesThrown or 0) + 1
		return false  -- autorise CE lancer unique
	  end
	  return true     -- sinon annule
	end
	return false
  end
  





-- À l’apparition de chaque PNJ, on choisit son rôle
function ENT:CustomOnInitialize()
	-- reset grenades
	self.GrenadesThrown = 0
	self.NextGrenadeTime = 0
	-- 50 % chasseur, 50 % guetteur
	if math.random() < 0.5 then
	  self.IsHunter = true
	else
	  self.IsHunter = false
	end
  end
  







----------------------------------------------------------------
-- 1) Hook pour contrôler TOTALEMENT le lancer de grenades
----------------------------------------------------------------
function ENT:OnGrenadeAttack(status, overrideEnt, landDir)
	if status == "Init" then
	  local e = self:GetEnemy()
	  -- chasseur : très rare, seulement s’il voit et est à distance moyenne
	  if self.IsHunter then
		if not IsValid(e) or not self:Visible(e) then return true end
		local d = self:GetPos():Distance(e:GetPos())
		if d < 200 or d > 600 then return true end
		if (self.GrenadesThrown or 0) >= 1 then return true end
		self.GrenadesThrown = (self.GrenadesThrown or 0) + 1
		return false
	  end
	  -- guetteur : encore plus rare, 1 chance sur 10
	  if not self.IsHunter then
		if math.random(1,10) ~= 1 then return true end
		if not IsValid(e) or not self:Visible(e) then return true end
		self.GrenadesThrown = (self.GrenadesThrown or 0) + 1
		return false
	  end
	end
  end
	
  ----------------------------------------------------------------
  -- 2) Refonte de CustomOnThink_Alive()
  ----------------------------------------------------------------
  function ENT:CustomOnThink_Alive()
	local enemy = self:GetEnemy()
	if not IsValid(enemy) then return end
  
	local ct   = CurTime()
	local me   = self:GetPos()
	local you  = enemy:GetPos()
	local vis  = self:Visible(enemy)
	local dist = me:Distance(you)
  
	-- A) Patrouille / recherche si plus visible
	if not vis and ct >= (self.NextLostSearch or 0) then
	  self.NextLostSearch = ct + 5
	  self:VJ_TASK_FIND_LOS(600)           -- fouille la dernière position connue 
	  return
	end
  
	-- B) Si visible → poursuite agressive
	if vis then
	  self:SetLastPosition(you)
	  self:SCHEDULE_CHASE_ENEMY()
	  -- autorise UN lancer de grenade immédiat si conditions
	  -- (OnGrenadeAttack gère l’unique lancer)
	  self:CustomOnGrenadeCheck()
	  return
	end
  
	-- C) Gestion des portes (throttle 0.5s)
	if ct >= (self.NextDoorCheck or 0) then
	  self.NextDoorCheck = ct + 0.5
	  for _, door in ipairs(ents.FindInSphere(me,150)) do
		if door:GetClass():find("door_rotating") then
		  local st = door:GetInternalVariable("m_toggle_state")
		  if st == 0 then
			self:SetLastPosition(you)
			self:SCHEDULE_CHASE_ENEMY()
			return
		  elseif st == 1 then
			self.CoveringEnabled = false
			door:Fire("Unlock","",0)
			door:AcceptInput("Use", self, self)
			door:Fire("Open","",0)
			self.CoveringEnabled = true
			self:SetLastPosition(you)
			self:SCHEDULE_CHASE_ENEMY()
			return
		  end
		end
	  end
	end
  
	-- D) couverture par défaut pour éviter le statique
	if self.CoveringEnabled then
	  self:SCHEDULE_COVER_ENEMY()           -- ne reste plus figé devant une porte 
	end
  end
	
  function ENT:CustomOnGrenadeCheck()
	-- appelle le hook OnGrenadeAttack
	self:OnGrenadeAttack("Init", nil, nil)
  end


  function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	-- ignore tout event de “gesture_signal_group” qui pouvait T‑poser
	if evOptions and evOptions:find("signal_group") then return true end
  end


  
function ENT:PreInit()
	local seq = {}
	for _,m in ipairs(WhiteListModels) do
	  if file.Exists(m,"GAME") then seq[#seq+1]=m end
	end
	for i=#seq,2,-1 do local j=math.random(i); seq[i],seq[j]=seq[j],seq[i] end
	self.Model = {}
	for i=1,math.min(5,#seq) do self.Model[i]=seq[i] end
  end

-- map arme → (bodygroup “Kit”) (FONCTIONNEL)
-- local WeaponBodygroupMap = {
-- 	["weapon_doi_german_kar98k"] = {group = 12, value = 0},  -- Kar98k
-- 	["weapon_doi_german_mp40"]   = {group = 12, value = 2},  -- MP40
--   }

-- map arme → bodygroup “Kit”, et config des autres BG
local BGConfig = {
	-- Kit selon l'arme équipée
	[12] = { mode = "byWeapon", map = {
		["weapon_doi_german_kar98k"] = 0,
		["weapon_doi_german_kar98k"] = 0,
		["weapon_doi_german_mp40"]   = 1,
		["weapon_doi_german_mp34"] = 1,
		["weapon_doi_german_stg44"]  = 2,
		["weapon_doi_german_g43"] = 3,
		["weapon_doi_german_g43sniper"] = 3,
		["weapon_doi_german_mg34"] = 4,
	  }
	},
	-- Headgear (groupe 1) : option 0 à 90%, 1 à 5%, 3 à 5%
	[1]  = { mode = "weighted", weights = { [0] = 90, [2] = 5, [3] = 5 } }, -- Helmet - pourcentages
	[2]  = { mode = "weighted", weights = { [0] = 90, [1] = 1, [3] = 2, [4] = 2, [5] = 2, [6] = 3 } }, -- Helmet accessory - pourcentages
	[3]  = { mode = "weighted", weights = { [0] = 90, [1] = 2, [3] = 2, [4] = 2, [5] = 4 } }, -- Facial features - pourcentages
	[4]  = { mode = "probBool", prob = 20 }, -- Tunic (groupe 4) activation 20% (exemple)
	[6]  = { mode = "weighted", weights = { [0] = 90, [1] = 5 } }, -- watch
	[7]  = { mode = "weighted", weights = { [0] = 87, [1] = 5, [2] = 5, [3] = 3 } }, -- gloves
	[8]  = { mode = "weighted", weights = { [0] = 70, [1] = 5, [2] = 5, [3] = 6, [4] = 7, [5] = 10 } }, -- rank
	[9]  = { mode = "weighted", weights = { [0] = 90, [1] = 10, [2] = 0, } }, -- facewear (- gasmask 0%)
	[11] = { mode = "probBool", prob = 5 }, -- Entrenching gear (groupe 11) activation 5%

	-- EXEMPLE: [9]  = { mode = "fixed", value = 4 }, -- équipement toujours valeur 4
	-- EXEMPLE: [3]  = { mode = "randomRange", min = 0, max = 5 }, (reference pour random)

  }
  
  -- Fonction utilitaire pour tirage pondéré
  local function WeightedPick(weights)
	local total = 0
	for v,w in pairs(weights) do total = total + w end
	local r = math.random() * total
	for v,w in pairs(weights) do
	  r = r - w
	  if r <= 0 then return v end
	end
	-- fallback
	for v,_ in pairs(weights) do return v end
  end
  
  function ENT:CustomOnInitialize()
	timer.Simple(0, function()
	  if not IsValid(self) then return end
  
	  -- obtenir classe d'arme
	  local weaponClass
	  local wep = self:GetActiveWeapon()
	  if IsValid(wep) then weaponClass = wep:GetClass() end
  
	  -- appliquer chaque config
	  for group, cfg in pairs(BGConfig) do
		if cfg.mode == "fixed" then
		  self:SetBodygroup(group, cfg.value)
  
		elseif cfg.mode == "probBool" then
		  local v = (math.random() < cfg.prob/100) and 1 or 0
		  self:SetBodygroup(group, v)
  
		elseif cfg.mode == "prob" then
		  if math.random() < cfg.prob/100 then
			self:SetBodygroup(group, cfg.value)
		  end
  
		elseif cfg.mode == "randomRange" then
		  self:SetBodygroup(group, math.random(cfg.min, cfg.max))
  
		elseif cfg.mode == "byWeapon" and weaponClass then
		  local v = cfg.map[weaponClass]
		  if v then self:SetBodygroup(group, v) end
  
		elseif cfg.mode == "weighted" then
		  local pick = WeightedPick(cfg.weights)
		  self:SetBodygroup(group, pick)
		end
	  end
	end)
end



--   [Bodygroup DEBUG]	0	Soldat
--   [Bodygroup DEBUG]	1	headgear
--   [Bodygroup DEBUG]	2	helmet accessory
--   [Bodygroup DEBUG]	3	facial features
--   [Bodygroup DEBUG]	4	tunic
--   [Bodygroup DEBUG]	5	trousers
--   [Bodygroup DEBUG]	6	watch
--   [Bodygroup DEBUG]	7	hands
--   [Bodygroup DEBUG]	8	rank
--   [Bodygroup DEBUG]	9	facewear
--   [Bodygroup DEBUG]	10	backpack
--   [Bodygroup DEBUG]	11	entrenchingtools
--   [Bodygroup DEBUG]	12	kit
  






















--   function ENT:CustomOnInitialize() -- NPCs WW2 Eastern Front reference
-- 	if math.random(1,0) == 1 then
-- 		self:SetBodygroup(0,math.random(0,8)) -- Heads
-- 		self:SetBodygroup(1,math.random(0,10)) -- Headwear
-- 		self:SetBodygroup(2,math.random(0,0)) -- Eyewear
-- 		self:SetBodygroup(3,math.random(0,0)) -- Maskwear
-- 		self:SetBodygroup(4,math.random(0,6)) -- Ranks
-- 		self:SetBodygroup(5,math.random(0,1)) -- Handwear
-- 		self:SetBodygroup(6,math.random(0,3)) -- Tunics
-- 		self:SetBodygroup(7,math.random(0,2)) -- Legwear
-- 		self:SetBodygroup(8,math.random(2,3)) -- Y-Straps
-- 		self:SetBodygroup(9,math.random(4,4)) -- Equipment
-- 		self:SetBodygroup(10,math.random(0,0)) -- Feldgendarmerie
-- 	end
-- end
  





ENT.StartHealth = 10
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.UsePoseParameterMovement = true
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true

ENT.HasMeleeAttack = false
ENT.AnimTbl_MeleeAttack = "vjseq_seq_meleeattack01"

ENT.WeaponInventory_AntiArmorList = {"weapon_vj_rpg"}
ENT.WeaponInventory_MeleeList = {}

ENT.HasGrenadeAttack = true
ENT.MaxGrenades            = 2
ENT.GrenadeAttackChance     = 5
ENT.GrenadeAttackThrowTime = 0.85
ENT.GrenadeAttackModel = "models/npc_doi/weapons/w_stielhandgranate.mdl"
ENT.AnimTbl_GrenadeAttack = "vjges_gesture_item_throw"
ENT.GrenadesThrown         = 0
ENT.NextGrenadeTime        = 0

-- throttle portes
ENT.NextDoorCheck          = 0
ENT.DoorCheckInterval      = 0.5

-- Réduire drastiquement les dialogues de combat
ENT.AlertSoundChance        = 10     -- au lieu de 30 ou 50
ENT.CombatIdleSoundChance   = 10
ENT.CallForHelpSoundChance  = 10

-- Patrouille active dès qu'il perd le joueur de vue
ENT.CanInvestigate          = true
ENT.InvestigateSoundChance  = 5

-- Conserver la peur des grenades
ENT.CombatDamageResponse    = true
ENT.DangerDetectionDistance = 800
ENT.CanDetectDangers        = true
ENT.CanRedirectGrenades     = true

-- Désactiver les sauts ridicules
ENT.CanJump                 = false
ENT.JumpParams.Enabled      = false


ENT.AnimTbl_Medic_GiveHealth = "vjges_gesture_item_drop"
ENT.AnimTbl_CallForHelp = {"vjges_gesture_signal_group", "vjges_gesture_signal_forward"}
ENT.AnimTbl_DamageAllyResponse = "vjges_gesture_signal_halt"
ENT.Weapon_OcclusionDelay = false

ENT.FootstepSoundTimerRun = 0.3
ENT.FootstepSoundTimerWalk = 0.5

ENT.CanFlinch = true
ENT.FlinchCooldown = 1
ENT.AnimTbl_Flinch = {"vjges_flinch_01", "vjges_flinch_02"}
ENT.FlinchHitGroupMap = {
	{HitGroup = HITGROUP_HEAD, Animation = {"vjges_flinch_head_01", "vjges_flinch_head_02"}},
	{HitGroup = HITGROUP_CHEST, Animation = {"vjges_flinch_phys_01", "vjges_flinch_phys_02", "vjges_flinch_back_01"}},
	{HitGroup = HITGROUP_STOMACH, Animation = {"vjges_flinch_stomach_01", "vjges_flinch_stomach_02"}},
	{HitGroup = HITGROUP_LEFTARM, Animation = "vjges_flinch_shoulder_l"},
	{HitGroup = HITGROUP_RIGHTARM, Animation = "vjges_flinch_shoulder_r"}
}

ENT.HasDeathAnimation = false
ENT.AnimTbl_Death = {"vjseq_death_02", "vjseq_death_03", "vjseq_death_04"}
ENT.DeathAnimationChance = 1

ENT.SoundTbl_FootStep = {"vjks_ww2/footstep/bootstep_01.ogg",
						"vjks_ww2/footstep/bootstep_02.ogg",
						"vjks_ww2/footstep/bootstep_03.ogg",
						"vjks_ww2/footstep/bootstep_04.ogg",
						"vjks_ww2/footstep/bootstep_05.ogg",
						"vjks_ww2/footstep/bootstep_06.ogg",
						"vjks_ww2/footstep/bootstep_07.ogg",
						"vjks_ww2/footstep/bootstep_08.ogg",
						"vjks_ww2/footstep/bootstep_09.ogg",
						"vjks_ww2/footstep/bootstep_10.ogg"}
ENT.SoundTbl_Breath = {}
ENT.SoundTbl_Idle = {"vjks_ww2/humans/shared/humming/1.ogg",
					"vjks_ww2/humans/shared/humming/2.ogg",
					"vjks_ww2/humans/shared/humming/3.ogg",
					"vjks_ww2/humans/shared/humming/4.ogg",
					"vjks_ww2/humans/shared/sneeze/1.ogg",
					"vjks_ww2/humans/shared/sneeze/2.ogg",
					"vjks_ww2/humans/shared/sneeze/3.ogg",
					"vjks_ww2/humans/shared/sneeze/4.ogg",
					"vjks_ww2/humans/shared/sneeze/5.ogg",
					"vjks_ww2/humans/shared/sneeze/6.ogg",
					"vjks_ww2/humans/shared/sneeze/7.ogg",
					"vjks_ww2/humans/shared/sneeze/8.ogg",
					"vjks_ww2/humans/shared/sneeze/9.ogg",
					"vjks_ww2/humans/shared/whistle/1.ogg",
					"vjks_ww2/humans/shared/whistle/2.ogg",
					"vjks_ww2/humans/shared/whistle/3.ogg",
					"vjks_ww2/humans/shared/whistle/4.ogg",
					"vjks_ww2/humans/shared/whistle/5.ogg",
					"vjks_ww2/humans/shared/whistle/6.ogg",
					"vjks_ww2/humans/shared/whistle/7.ogg",
					"vjks_ww2/humans/shared/whistle/8.ogg",
					"vjks_ww2/humans/shared/whistle/9.ogg",
					"vjks_ww2/humans/shared/whistle/10.ogg",
					"vjks_ww2/humans/shared/whistle/11.ogg",
					"vjks_ww2/humans/shared/whistle/12.ogg",
					"vjks_ww2/humans/shared/whistle/13.ogg",
					"vjks_ww2/humans/shared/whistle/14.ogg"}
ENT.SoundTbl_CombatIdle = {"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_inform_suppressed_generic_01.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_inform_suppressed_generic_02.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_inform_suppressed_generic_03.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_inform_suppressed_generic_04.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v7/ge_3_order_attack_infantry_01.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v7/ge_3_order_attack_infantry_02.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v7/ge_3_order_attack_infantry_03.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v7/ge_3_order_attack_infantry_04.ogg",
							"vjks_ww2/humans/ger/cries_in_battle/v7/ge_3_order_attack_infantry_05.ogg"}
ENT.SoundTbl_OnReceiveOrder = {"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_06.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_07.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03b.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_06.ogg"}
ENT.SoundTbl_FollowPlayer = {}
ENT.SoundTbl_UnFollowPlayer = {}
ENT.SoundTbl_MoveOutOfPlayersWay = {}
ENT.SoundTbl_MedicBeforeHeal = {}
ENT.SoundTbl_MedicAfterHeal = {}
ENT.SoundTbl_MedicReceiveHeal = {}
ENT.SoundTbl_OnPlayerSight = {"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_06.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_07.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03b.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_06.ogg"}
ENT.SoundTbl_Investigate = {}
ENT.SoundTbl_Alert = {"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_06.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v4/ge_0_order_move_generic_07.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_follow_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_03b.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_forward_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_01.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_02.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_03.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_04.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_05.ogg",
								"vjks_ww2/humans/ger/executing_an_order/v7/ge_3_order_move_generic_06.ogg"}
ENT.SoundTbl_CallForHelp = {"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_01.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_02.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_03.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_04.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_01.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_02.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_03.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_04.ogg"}
ENT.SoundTbl_BecomeEnemyToPlayer = {"kstrudel/imps/storm2/onplayersight/onplayersight_1.ogg"}
ENT.SoundTbl_Suppressing = {"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_01.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_02.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_03.ogg",
								"vjks_ww2/humans/ger/suppressed/v4/ge_0_inform_suppressed_generic_04.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_01.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_02.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_03.ogg",
								"vjks_ww2/humans/ger/suppressed/v7/ge_3_inform_suppressed_generic_04.ogg"}
ENT.SoundTbl_WeaponReload = {}
ENT.SoundTbl_BeforeMeleeAttack = {}
ENT.SoundTbl_MeleeAttack = {}
ENT.SoundTbl_MeleeAttackExtra = {}
ENT.SoundTbl_MeleeAttackMiss = {}
ENT.SoundTbl_GrenadeAttack = {"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_01.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_01b.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_01c.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_02.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_03.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_04.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_05.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v4/ge_0_inform_attacking_grenade_06.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_01.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_01b.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_01c.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_02.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_03.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_04.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_05.ogg",
								"vjks_ww2/humans/ger/throwing_a_grenade/v7/ge_3_inform_attacking_grenade_06.ogg"}
ENT.SoundTbl_OnGrenadeSight = {"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_01.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_02.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_03.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_04.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_05.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_06.ogg",
								"vjks_ww2/humans/ger/cries_in_battle/v4/ge_0_order_action_grenade_07.ogg"}
ENT.SoundTbl_OnKilledEnemy = {}
ENT.SoundTbl_Pain = {"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain2.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain3.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain4.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain5.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain6.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain7.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain8.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain2.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain3.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain4.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain5.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain6.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain7.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain8.ogg"}
ENT.SoundTbl_Impact = {}
ENT.SoundTbl_DamageByPlayer = {"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain2.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain3.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain4.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain5.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain6.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain7.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v4/gen_m_pain8.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain1.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain2.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain3.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain4.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain5.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain6.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain7.ogg",
								"vjks_ww2/humans/ger/scream_of_pain/v7/gen_m_pain8.ogg"}
ENT.SoundTbl_Death = {"vjks_ww2/humans/ger/death_cry/v4/deathcry_01.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/deathcry_02.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/deathcry_03.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/deathcry_04.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/deathcry_05.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death1.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death2.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death3.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death4.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death5.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death6.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death7.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death8.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death9.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death10.ogg",
								"vjks_ww2/humans/ger/death_cry/v4/gen_m_death11.ogg"}
---------------------------------------------------------------------------------------------------------------------------------------------


-- couverture
ENT.CoveringEnabled           = true    -- active le cover system
ENT.CanHideOnThreat           = true    -- cherche du cover face aux menaces
ENT.CoveringFindRange         = 600     -- distance max pour chercher un abri
ENT.CoveringTakeCoverDistance = 200     -- se jette à couvert dès qu’il est à moins de 200 units
ENT.CoveringMoveType          = VJ_MOVETYPE_GROUND


-- arme secondaire & changement
ENT.CanUseSecondaryweapon     = true
ENT.Secondaryweapon_class     = "weapon_doi_german_luger"
ENT.Secondaryweapon_switchchance = 3

-- flanquement
ENT.FlankEnemy_chance   = 50
ENT.FlankEnemy_Nexttime = 5


ENT.CanOpenDoors = true 

function ENT:PreInit()
    -- Copie de la whitelist dans une table séquentielle
    local seq = {}
    for _, mdl in ipairs(WhiteListModels) do
        if file.Exists(mdl, "GAME") then
            seq[#seq+1] = mdl
        end
    end

    -- Mélange Fisher–Yates
    for i = #seq, 2, -1 do
        local j = math.random(i)
        seq[i], seq[j] = seq[j], seq[i]
    end

    -- On ne garde que 5
    self.Model = {}
    for i = 1, math.min(5, #seq) do
        self.Model[i] = seq[i]
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	VJ.EmitSound(self, "") -- Player connect sound
	
	-- Random bodygroups and skins
	for i = 1, self:GetNumBodyGroups() -1 do
		self:SetBodygroup(i, math.random(0, self:GetBodygroupCount(i - 1)))
	end
	self:SetSkin(math.random(0, self:SkinCount() - 1))
	
	-- Random playermodel color
	self:SetPlayerColor(Color(math.Rand(0, 255), math.Rand(0, 255), math.Rand(0, 255)):ToVector())
end
---------------------------------------------------------------------------------------------------------------------------------------------
/*function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, corpse)
	-- Has to be client side, not worth networking, therefore this has been abandoned
	corpse.SetupDataTables = function()
		//corpse:NetworkVar("Vector", 0, "PlayerColor")
		corpse:DTVar("Vector", 0, "PlayerColor")
	end
	
	corpse:InstallDataTable()
	corpse:SetupDataTables()
	
	corpse:DTVar("Vector", 0, "PlayerColor")
	//corpse:SetDTVector(0, self:GetPlayerColor())
    //corpse:SetPlayerColor(self:GetPlayerColor())
end*/
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
-- function ENT:OnDeath(dmginfo, hitgroup, status)
-- 	if status == "Init" then
-- 		local pos = self:GetPos()
-- 		local pitch = math.random(95, 105)
-- 		local function deathSound(time, snd)
-- 			timer.Simple(time, function()
-- 				sound.Play(snd, pos, 65, pitch)
-- 			end)
-- 		end
-- 		-- deathSound(0, "hl1/fvox/beep.wav")
-- 		-- deathSound(0.25, "hl1/fvox/beep.wav")
-- 		-- deathSound(0.75, "hl1/fvox/beep.wav")
-- 		-- deathSound(1.25, "hl1/fvox/beep.wav")
-- 		-- deathSound(1.7, "hl1/fvox/flatline.wav")
-- 	end
-- end


