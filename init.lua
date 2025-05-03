-- AddCSLuaFile("shared.lua")
-- include("shared.lua")


AddCSLuaFile("shared.lua")
include("vj_base/ai/core.lua")
include("vj_base/ai/schedules.lua")
include("vj_base/ai/base_aa.lua")
include("shared.lua")

-- Whitelist de modèles
local WhiteListModels = {
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_01.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_02.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_03.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_04.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_05.mdl",
	"models/hts/comradebear/pm0v3/player/heer/infantry/en/m40_s1_06.mdl"
  }

-----------------------------------------------
-- CONFIGURATION & COMPATIBILITÉ VJ Base 3.0.0
-----------------------------------------------


ENT.HasBreathSound           = false   -- supprime le bug GetSoundPitch(bool)
ENT.CanJump                  = false
ENT.JumpParams               = { Enabled=false, MaxRise=0, MaxDrop=0, MaxDistance=0 }

ENT.GrenadesThrown           = 0
ENT.NextGrenadeTime          = 0
ENT.HasGrenadeAttack         = true
ENT.MaxGrenades              = 1

ENT.AlertTimeout             = VJ.SET(5,7)
ENT.IdleAlwaysWander         = true
ENT.DisableChasingEnemy      = false

ENT.AlertSoundChance         = 25
ENT.CombatIdleSoundChance    = 10
ENT.CallForHelpSoundChance   = 30

ENT.CanOpenDoors             = true
ENT.NextDoorCheck            = 0
ENT.DoorCheckInterval        = 0.5

ENT.CanInvestigate           = true
ENT.NextLostSearch           = 0
-- ENT.InvestigateSoundChance  = 50

-- Cover system (optionnel, déjà géré par SCHEDULE_COVER_ENEMY)
ENT.CoveringEnabled          = true
ENT.CanHideOnThreat          = true
ENT.CoveringFindRange        = 600
ENT.CoveringTakeCoverDistance= 200
ENT.CoveringMoveType         = VJ_MOVETYPE_GROUND


-- arme secondaire & changement
ENT.CanUseSecondaryweapon     = true
ENT.Secondaryweapon_class     = "weapon_doi_german_luger"
ENT.Secondaryweapon_switchchance = 3

-- flanquement
ENT.FlankEnemy_chance   = 50
ENT.FlankEnemy_Nexttime = 5



-- bloquer tout T‑pose/événement d’animation parasite
function ENT:OnAnimEvent(...) return true end

-- Role assignment (60% hunters, 40% coverers)
function ENT:PreInit()
  self.GrenadesThrown = 0
  self.NextGrenadeTime = 0
  self.IsHunter      = (math.random() < 0.6)
  self.InCover       = false

  -- whitelist models (unchanged)
  local seq = {}
  for _,mdl in ipairs(WhiteListModels) do
    if file.Exists(mdl,"GAME") then seq[#seq+1]=mdl end
  end
  for i=#seq,2,-1 do local j=math.random(i); seq[i],seq[j]=seq[j],seq[i] end
  self.Model = {}
  for i=1,math.min(5,#seq) do self.Model[i]=seq[i] end
end

function ENT:Init()
  VJ.EmitSound(self,"")
  for i=1,self:GetNumBodyGroups()-1 do
    self:SetBodygroup(i,math.random(0,self:GetBodygroupCount(i-1)))
  end
  self:SetSkin(math.random(0,self:SkinCount()-1))
  self:SetPlayerColor(ColorRand():ToVector())
end

function ENT:OnResetEnemy()
	-- dès qu’on perd l’ennemi, on relance immédiatement la recherche
	self.NextLostSearch = CurTime()
	-- si navmesh dispo → cherche la dernière position connue
	if navmesh.IsLoaded() and #navmesh.GetAllNavAreas()>0 then
	  self:VJ_TASK_FIND_LOS(600)
	else
	  -- simple patrouille de secours
	  self:SCHEDULE_WANDER()
	end
  end




-- grenade ultra‑rare
function ENT:OnGrenadeAttack(status,_,_)
  if status=="Init" then
    local e = self:GetEnemy()
    if not IsValid(e) or not self:Visible(e) then return true end
    local d = self:GetPos():Distance(e:GetPos())
    if d>200 and d<600 and self.GrenadesThrown<self.MaxGrenades and math.random(10)==1 then
      self.GrenadesThrown = self.GrenadesThrown+1
      return false
    end
    return true
  end
  return false
end  
  ----------------------------------------------------------------------------------------------------------------
  -- 2) boucle CustomOnThink_Alive optimisée
  ----------------------------------------------------------------------------------------------------------------
  local function findNearestCoverProp(self, enemy)
	local best, bd = nil, 300
	for _, e in ipairs(ents.FindInSphere(self:GetPos(), bd)) do
	  local c = e:GetClass()
	  if c:find("prop_physics") or c:find("func_breakable") then
		local d = self:GetPos():Distance(e:GetPos())
		if d < bd then bd, best = d, e end
	  end
	end
	return best
  end
  
  function ENT:CustomOnThink_Alive()
	local enemy = self:GetEnemy()
	if not IsValid(enemy) then return end
  
	local ct, pos, epos = CurTime(), self:GetPos(), enemy:GetPos()
	local vis = self:Visible(enemy)
  
	-- A) sortie de cover si plus de vue
	if self.InCover and not vis then
	  self.InCover = false
	  return self:OnResetEnemy()
	end
  
	-- B) perte de vue → recherche/patrouille
	if not vis and ct >= self.NextLostSearch then
	  self.NextLostSearch = ct + 5
	  if navmesh.IsLoaded() and #navmesh.GetAllNavAreas()>0 then
		self:VJ_TASK_FIND_LOS(600)
	  else
		self:SCHEDULE_WANDER()
	  end
	  return
	end
  
	-- C) ennemi visible → hunter ou coverer
	if vis then
	  self:SetLastPosition(epos)
	  if self.IsHunter then
		self:SCHEDULE_CHASE_ENEMY()
	  else
		if not self.InCover then
		  local coverEnt = findNearestCoverProp(self, enemy)
		  if IsValid(coverEnt) then
			self.InCover = true
			local offset = (coverEnt:GetPos() - epos):GetNormalized() * 30
			self:SetLastPosition(coverEnt:GetPos() + offset)
			self:SCHEDULE_GOTO_POSITION()
			timer.Simple(1, function()
			  if IsValid(self) then self:VJ_ACT_PLAYACTIVITY(ACT_CROUCH_PASSIVE, true) end
			end)
			return
		  end
		else
		  if pos:Distance(epos) < 500 then
			self:SCHEDULE_COVER_ENEMY()
		  else
			self:SCHEDULE_CHASE_ENEMY()
		  end
		  return
		end
	  end
	end
  
	-- D) portes func_/prop_door_rotating
	if ct >= self.NextDoorCheck then
	  self.NextDoorCheck = ct + (self.DoorCheckInterval or 0.5)
	  for _, door in ipairs(ents.FindInSphere(pos, 150)) do
		local c = door:GetClass()
		if c:find("door_rotating") then
		  local st = door:GetInternalVariable("m_toggle_state")
		  if st == 1 then
			door:Fire("Unlock","",0)
			door:AcceptInput("Use", self, self)
			door:Fire("Open","",0)
		  elseif st == 0 then
			self:SetLastPosition(epos)
			self:SCHEDULE_CHASE_ENEMY()
			return
		  end
		end
	  end
	end
  
	-- E) fallback cover pour éviter le blocage
	self:SCHEDULE_COVER_ENEMY()
  end

--------------------------- CI-DESSUS : CODE PERSONNALIÉ ------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------


-- Whitelist model preinit
function ENT:PreInit()
  local seq = {}
  for _, m in ipairs(WhiteListModels) do
    if file.Exists(m, "GAME") then table.insert(seq, m) end
  end
  for i = #seq, 2, -1 do local j = math.random(i); seq[i], seq[j] = seq[j], seq[i] end
  self.Model = {}
  for i = 1, math.min(5, #seq) do self.Model[i] = seq[i] end
end

-- Default init: bodygroups, skin, color
function ENT:Init()
  VJ.EmitSound(self, "")
  for i = 1, self:GetNumBodyGroups() - 1 do
    self:SetBodygroup(i, math.random(0, self:GetBodygroupCount(i - 1)))
  end
  self:SetSkin(math.random(0, self:SkinCount() - 1))
  self:SetPlayerColor(Color(math.Rand(0,255),math.Rand(0,255),math.Rand(0,255)):ToVector())
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
	-- ─── A) Initialisation IA ───────────────────────────────────
	-- reset grenades, timers portes, recherche perdue
	self.GrenadesThrown    = 0
	self.NextGrenadeTime   = 0
	self.MaxGrenades       = self.MaxGrenades or 1
	-- 60% hunter, 40% coverer
	self.IsHunter          = (math.random() < 0.6)
	self.InCover           = false
	self.NextDoorCheck     = 0
	self.NextLostSearch    = 0
  
	-- ─── B) Configuration bodygroups (votre BGConfig) ───────────
	timer.Simple(0, function()
	  if not IsValid(self) then return end
  
	  -- récupérer la classe d’arme équipée
	  local weaponClass
	  local wep = self:GetActiveWeapon()
	  if IsValid(wep) then weaponClass = wep:GetClass() end
  
	  -- appliquer chaque règle de BGConfig
	  for group, cfg in pairs(BGConfig) do
		if     cfg.mode == "fixed"       then
		  self:SetBodygroup(group, cfg.value)
  
		elseif cfg.mode == "probBool"    then
		  local v = (math.random() < cfg.prob/100) and 1 or 0
		  self:SetBodygroup(group, v)
  
		elseif cfg.mode == "prob"        then
		  if math.random() < cfg.prob/100 then
			self:SetBodygroup(group, cfg.value)
		  end
  
		elseif cfg.mode == "randomRange" then
		  self:SetBodygroup(group, math.random(cfg.min, cfg.max))
  
		elseif cfg.mode == "byWeapon" and weaponClass then
		  local v = cfg.map[weaponClass]
		  if v then self:SetBodygroup(group, v) end
  
		elseif cfg.mode == "weighted"    then
		  local pick = WeightedPick(cfg.weights)
		  self:SetBodygroup(group, pick)
		end
	  end
	end)
  end

  ENT.StartHealth = 10
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.UsePoseParameterMovement = true
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true

ENT.HasMeleeAttack = false
ENT.AnimTbl_MeleeAttack = "vjseq_seq_meleeattack01"

ENT.WeaponInventory_AntiArmorList = {"weapon_vj_rpg"}
ENT.WeaponInventory_MeleeList = {}

ENT.GrenadeAttackModel = "models/npc_doi/weapons/w_stielhandgranate.mdl"
ENT.AnimTbl_GrenadeAttack = "vjges_gesture_item_throw"

-- Conserver la peur des grenades
-- ENT.CombatDamageResponse    = true
-- ENT.DangerDetectionDistance = 800
-- ENT.CanDetectDangers        = true
-- ENT.CanRedirectGrenades     = true

-- Désactiver les sauts ridicules
-- ENT.CanJump                 = false
-- ENT.JumpParams.Enabled      = false

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
-- ENT.DeathAnimationChance = 1

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


