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

function ENT:PreInit()
	local seq = {}
	for _,m in ipairs(WhiteListModels) do
	  if file.Exists(m,"GAME") then seq[#seq+1]=m end
	end
	for i=#seq,2,-1 do local j=math.random(i); seq[i],seq[j]=seq[j],seq[i] end
	self.Model = {}
	for i=1,math.min(5,#seq) do self.Model[i]=seq[i] end
  end

-- 2) hook d’équipement d’arme
local WeaponBodygroupMap = {
	["weapon_doi_german_kar98k"] = {group = 12, value = 1},
	["weapon_doi_german_mp40"]  = {group = 12, value = 2},
  }
  function ENT:CustomOnWeaponEquip(wep)
	print("[npc_vj_player_heer_en] Equip hook, class=",wep:GetClass())
	local m = WeaponBodygroupMap[wep:GetClass()]
	if m then self:SetBodygroup(m.group,m.value) end
  end
  
  local e=ents.FindByClass("npc_vj_player_heer_en")[1]
  for i=0,e:GetNumBodyGroups()-1 do
	print(i,":",e:GetBodygroupName(i),"(",e:GetBodygroupCount(i),"options)")
  end





ENT.StartHealth = 10
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.UsePoseParameterMovement = true
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = "vjseq_seq_meleeattack01"

ENT.WeaponInventory_AntiArmorList = {"weapon_vj_rpg"}
ENT.WeaponInventory_MeleeList = {"weapon_fists"}

ENT.HasGrenadeAttack = true
ENT.GrenadeAttackThrowTime = 0.85
ENT.GrenadeAttackModel = "models/npc_doi/weapons/w_stielhandgranate.mdl"
ENT.AnimTbl_GrenadeAttack = "vjges_gesture_item_throw"

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
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Init" then
		local pos = self:GetPos()
		local pitch = math.random(95, 105)
		local function deathSound(time, snd)
			timer.Simple(time, function()
				sound.Play(snd, pos, 65, pitch)
			end)
		end
		-- deathSound(0, "hl1/fvox/beep.wav")
		-- deathSound(0.25, "hl1/fvox/beep.wav")
		-- deathSound(0.75, "hl1/fvox/beep.wav")
		-- deathSound(1.25, "hl1/fvox/beep.wav")
		-- deathSound(1.7, "hl1/fvox/flatline.wav")
	end
end
