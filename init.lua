if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
AddCSLuaFile("shared.lua")
include("vj_base/npc_general.lua")
include("vj_base/npc_schedules.lua")
include("vj_base/npc_movetype_aa.lua")
include("shared.lua")
/*--------------------------------------------------
	=============== Human SNPC Base ===============
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
	INFO: Used as a base for human SNPCs.
--------------------------------------------------*/
AccessorFunc(ENT,"m_iClass","NPCClass",FORCE_NUMBER)
AccessorFunc(ENT,"m_fMaxYawSpeed","MaxYawSpeed",FORCE_NUMBER)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Core Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.Model = {"models/sk/germans/heer/mid_enlisted/npc_ger_tunic.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = ("60")
ENT.VJ_IsHugeMonster = false -- Is this a huge monster?
	-- This is mostly used for massive or boss SNPCs, it affects certain part of the SNPC, for example the SNPC won't receive any knock back
	-- ====== Collision / Hitbox Variables ====== --
ENT.HullType = HULL_SMALL
ENT.HasHull = false -- Set to false to disable HULL
ENT.HullSizeNormal = true -- set to false to cancel out the self:SetHullSizeNormal()
ENT.HasSetSolid = true -- set to false to disable SetSolid
	-- ====== Sight & Speed Variables ====== --
ENT.SightDistance = 1000000 -- How far it can see
ENT.SightAngle = 80 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 40 -- How fast it can turn
ENT.TurningUseAllAxis = false -- If set to true, angles will not be restricted to y-axis, it will change all axes (plural axis)
	-- ====== Movement Variables ====== --
	-- Types: VJ_MOVETYPE_GROUND | VJ_MOVETYPE_AERIAL | VJ_MOVETYPE_AQUATIC | VJ_MOVETYPE_STATIONARY | VJ_MOVETYPE_PHYSICS
ENT.MovementType = VJ_MOVETYPE_GROUND -- How does the SNPC move?
ENT.CanTurnWhileStationary = true -- If set to true, the SNPC will be able to turn while it's a stationary SNPC
ENT.MaxJumpLegalDistance = VJ_Set(120, 150) -- The max distance the NPC can jump (Usually from one node to another) | ( UP, DOWN )
	-- ====== Miscellaneous Variables ====== --
ENT.HasEntitiesToNoCollide = true -- If set to false, it won't run the EntitiesToNoCollide code
ENT.EntitiesToNoCollide = {} -- Entities to not collide with when HasEntitiesToNoCollide is set to true
ENT.AllowPrintingInChat = false -- Should this SNPC be allowed to post in player's chat? Example: "Blank no longer likes you."
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ AI / Relationship Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasAllies = true -- Put to false if you want it not to have any allies
ENT.VJ_NPC_Class = {"CLASS_NAZI"} -- NPCs with the same class with be allied to each other
	-- Common Classes: Combine = CLASS_COMBINE || Zombie = CLASS_ZOMBIE || Antlions = CLASS_ANTLION || Xen = CLASS_XEN || Player Friendly = CLASS_PLAYER_ALLY
ENT.FriendsWithAllPlayerAllies = false -- Should this SNPC be friends with all other player allies that are running on VJ Base?
ENT.Behavior = VJ_BEHAVIOR_AGGRESSIVE -- Doesn't attack anything
	-- VJ_BEHAVIOR_AGGRESSIVE = Default behavior, attacks enemies || VJ_BEHAVIOR_NEUTRAL = Neutral to everything, unless provoked
	-- VJ_BEHAVIOR_PASSIVE = Doesn't attack, but can attacked by others || VJ_BEHAVIOR_PASSIVE_NATURE = Doesn't attack and is allied with everyone
ENT.MoveOutOfFriendlyPlayersWay = false -- Should the SNPC move out of the way when a friendly player comes close to it?
ENT.NextMoveOutOfFriendlyPlayersWayTime = 1 -- How much time until it can moves out of the player's way?
ENT.BecomeEnemyToPlayer = false -- Should the friendly SNPC become enemy towards the player if it's damaged by a player?
ENT.BecomeEnemyToPlayerLevel = 2 -- How many times does the player have to hit the SNPC for it to become enemy?
	-- ====== Old Variables (Can still be used, but it's recommended not to use them) ====== --
ENT.VJ_FriendlyNPCsSingle = {}
ENT.VJ_FriendlyNPCsGroup = {}
ENT.PlayerFriendly = false -- Makes the SNPC friendly to the player and HL2 Resistance
	-- ====== Passive Behavior Variables ====== --
ENT.Passive_RunOnTouch = true -- Should it run away and make a alert sound when something collides with it?
ENT.Passive_NextRunOnTouchTime1 = 3 -- How much until it can run away again when something collides with it? | First # in the math.Rand
ENT.Passive_NextRunOnTouchTime2 = 4 -- How much until it can run away again when something collides with it? | Second # in the math.Rand
ENT.Passive_RunOnDamage = true -- Should it run when it's damaged? | This doesn't impact how self.Passive_AlliesRunOnDamage works
ENT.Passive_AlliesRunOnDamage = true -- Should its allies (other passive SNPCs) also run when it's damaged?
ENT.Passive_AlliesRunOnDamageDistance = 800 -- Any allies within this distance will run when it's damaged
ENT.Passive_NextRunOnDamageTime1 = 6 -- How much until it can run the code again? | First # in the math.Rand
ENT.Passive_NextRunOnDamageTime2 = 7 -- How much until it can run the code again? | Second # in the math.Rand
	-- ====== On Player Sight Variables ====== --
ENT.HasOnPlayerSight = false -- Should do something when it sees the enemy? Example: Play a sound
ENT.OnPlayerSightDistance = 200 -- How close should the player be until it runs the code?
ENT.OnPlayerSightDispositionLevel = 1 -- 0 = Run it every time | 1 = Run it only when friendly to player | 2 = Run it only when enemy to player
ENT.OnPlayerSightOnlyOnce = true -- Should it only run the code once?
ENT.OnPlayerSightNextTime1 = 15 -- How much time should it pass until it runs the code again? | First number in math.random
ENT.OnPlayerSightNextTime2 = 20 -- How much time should it pass until it runs the code again? | Second number in math.random
	-- ====== Call For Help Variables ====== --
ENT.CallForHelp = true -- Does the SNPC call for help?
ENT.CallForHelpDistance = 2000 -- -- How far away the SNPC's call for help goes | Counted in World Units
ENT.NextCallForHelpTime = 4 -- Time until it calls for help again
ENT.HasCallForHelpAnimation = true -- if true, it will play the call for help animation
ENT.AnimTbl_CallForHelp = {ACT_SIGNAL_ADVANCE,ACT_SIGNAL_FORWARD} -- Call For Help Animations
ENT.CallForHelpAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.CallForHelpAnimationPlayBackRate = 0.5 -- How fast should the animation play? | Currently only for gestures!
ENT.CallForHelpStopAnimations = true -- Should it stop attacks for a certain amount of time?
	-- To let the base automatically detect the animation duration, set this to false:
ENT.CallForHelpStopAnimationsTime = false -- How long should it stop attacks?
ENT.CallForHelpAnimationFaceEnemy = true -- Should it face the enemy when playing the animation?
ENT.NextCallForHelpAnimationTime = 30 -- How much time until it can play the animation again?
	-- ====== Medic Variables ====== --
ENT.IsMedicSNPC = false -- Is this SNPC a medic? Does it heal other friendly friendly SNPCs, and players(If friendly)
ENT.AnimTbl_Medic_GiveHealth = {ACT_SPECIAL_ATTACK1} -- Animations is plays when giving health to an ally
ENT.Medic_CheckDistance = 600 -- How far does it check for allies that are hurt? | World units
ENT.Medic_HealDistance = 100 -- How close does it have to be until it stops moving and heals its ally?
ENT.Medic_HealthAmount = 25 -- How health does it give?
ENT.Medic_NextHealTime1 = 10 -- How much time until it can give health to an ally again | First number in the math.random
ENT.Medic_NextHealTime2 = 15 -- How much time until it can give health to an ally again | Second number in the math.random
ENT.Medic_SpawnPropOnHeal = true -- Should it spawn a prop, such as small health vial at a attachment when healing an ally?
ENT.Medic_SpawnPropOnHealModel = "models/healthvial.mdl" -- The model that it spawns
ENT.Medic_SpawnPropOnHealAttachment = "anim_attachment_LH" -- The attachment it spawns on
	-- ====== Follow Player Variables ====== --
	-- Will only follow a player that's friendly to it!
ENT.FollowPlayer = true -- Should the SNPC follow the player when the player presses a certain key?
ENT.FollowPlayerChat = true -- Should the SNPCs say things like "Blank stopped following you" | self.AllowPrintingInChat overrides this variable!
ENT.FollowPlayerKey = "Use" -- The key that the player presses to make the SNPC follow them
ENT.FollowPlayerCloseDistance = 150 -- If the SNPC is that close to the player then stand still until the player goes farther away
ENT.NextFollowPlayerTime = 0.1 -- Time until it runs to the player again
	-- ====== Movement & Idle Variables ====== --
ENT.AnimTbl_IdleStand = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_SHOTGUN_RELAXED} -- The idle animation when AI is enabled
ENT.AnimTbl_Walk = {ACT_WALK} -- Set the walking animations | Put multiple to let the base pick a random animation when it moves
ENT.AnimTbl_Run = {ACT_RUN} -- Set the running animations | Put multiple to let the base pick a random animation when it moves
ENT.DisableWandering = true -- Disables wandering when the SNPC is idle
ENT.DisableChasingEnemy = false -- Disables the SNPC chasing the enemy
	-- ====== Constantly Face Enemy Variables ====== --
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfVisible = true -- Should it only face the enemy if it's visible?
ENT.ConstantlyFaceEnemy_IfAttacking = false -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Both" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2500 -- How close does it have to be until it starts to face the enemy?
	-- ====== Pose Parameter Variables ====== --
ENT.HasPoseParameterLooking = true -- Does it look at its enemy using poseparameters?
ENT.PoseParameterLooking_InvertPitch = false -- Inverts the pitch poseparameters (X)
ENT.PoseParameterLooking_InvertYaw = false -- Inverts the yaw poseparameters (Y)
ENT.PoseParameterLooking_InvertRoll = false -- Inverts the roll poseparameters (Z)
ENT.PoseParameterLooking_TurningSpeed = 10 -- How fast does the parameter turn?
ENT.PoseParameterLooking_Names = {pitch={},yaw={},roll={}} -- Custom pose parameters to use, can put as many as needed
	-- ====== Sound Detection Variables ====== --
ENT.InvestigateSoundDistance = 9 -- How far away can the SNPC hear sounds? | This number is timed by the calculated volume of the detectable sound.
	-- ====== Control Variables ====== --
	-- Use these variables very careful! One wrong change can mess up the whole SNPC!
ENT.FindEnemy_UseSphere = false -- Should the SNPC be able to see all around him? (360) | Objects and walls can still block its sight!
ENT.FindEnemy_CanSeeThroughWalls = false -- Should it be able to see through walls and objects? | Can be useful if you want to make it know where the enemy is at all times
ENT.DisableFindEnemy = false -- Disables FindEnemy code, friendly code still works though
ENT.DisableSelectSchedule = false -- Disables Schedule code, Custom Schedule can still work
ENT.DisableTakeDamageFindEnemy = false -- Disable the SNPC finding the enemy when being damaged
ENT.DisableTouchFindEnemy = false -- Disable the SNPC finding the enemy when being touched
ENT.DisableMakingSelfEnemyToNPCs = false -- Disables the "AddEntityRelationship" that runs in think
ENT.LastSeenEnemyTimeUntilReset = 15 -- Time until it resets its enemy if its current enemy is not visible
ENT.NextProcessTime = 4.5 -- Time until it runs the essential part of the AI, which can be performance heavy!
	-- ====== Miscellaneous Variables ====== --
ENT.DisableInitializeCapabilities = false -- If enabled, all of the Capabilities will be disabled, allowing you to add your own
ENT.AttackTimersCustom = {}
ENT.DistanceToRunFromEnemy = 150 -- When the enemy is this close, the SNPC will back away | Put to 0, to never back away
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Damaged / Injured Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ====== Blood-Related Variables ====== --
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
	-- Types: "Red" || "Yellow" || "Green" || "Orange" || "Blue" || "Purple" || "White" || "Oil"
ENT.HasBloodParticle = true -- Does it spawn a particle when damaged?
ENT.HasBloodDecal = true -- Does it spawn a decal when damaged?
ENT.HasBloodPool = false -- Does it have a blood pool?
ENT.CustomBlood_Particle = {} -- Particles to spawn when it's damaged
ENT.CustomBlood_Decal = {} -- Decals to spawn when it's damaged
ENT.CustomBlood_Pool = {} -- Blood pool types after it dies
ENT.BloodPoolSize = "Normal" -- What's the size of the blood pool?
	-- Sizes: "Normal" || "Small" || "Tiny"
ENT.BloodDecalUseGMod = true -- Should use the current default decals defined by Garry's Mod? (This only applies for certain blood types only!)
ENT.BloodDecalDistance = 300 -- How far the decal can spawn in world units
	-- ====== Immunity Variables ====== --
ENT.GodMode = false -- Immune to everything
ENT.Immune_AcidPoisonRadiation = false -- Immune to Acid, Poison and Radiation
ENT.Immune_Bullet = false -- Immune to bullet type damages
ENT.Immune_Blast = false -- Immune to explosive-type damages
ENT.Immune_Dissolve = false -- Immune to dissolving | Example: Combine Ball
ENT.Immune_Electricity = false -- Immune to electrical-type damages | Example: shock or laser
ENT.Immune_Fire = false -- Immune to fire-type damages
ENT.Immune_Melee = false -- Immune to melee-type damage | Example: Crowbar, slash damages
ENT.Immune_Physics = false -- Immune to physics impacts, won't take damage from props
ENT.Immune_Sonic = false -- Immune to sonic-type damages
ENT.ImmuneDamagesTable = {} -- Makes the SNPC immune to specific type of damages | Takes DMG_ enumerations
ENT.GetDamageFromIsHugeMonster = false -- Should it get damaged no matter what by SNPCs that are tagged as VJ_IsHugeMonster?
ENT.AllowIgnition = true -- Can this SNPC be set on fire?
	-- ====== Flinching Variables ====== --
ENT.CanFlinch = 0 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchDamageTypes = {} -- If it uses damage-based flinching, which types of damages should it flinch from?
ENT.FlinchChance = 1 -- Chance of it flinching from 1 to x | 1 will make it always flinch
ENT.AnimTbl_Flinch = {"Shoved_Backward_01","Shoved_Backward_02","Shoved_Backward_03","Shoved_Backward_04","Shoved_Backward_05"} -- If it uses normal based animation, use this
ENT.NextMoveAfterFlinchTime = "1.0" -- How much time until it can move, attack, etc. | Use this for schedules or else the base will set the time 0.6 if it sees it's a schedule!
ENT.NextFlinchTime = 0.5 -- How much time until it can flinch again?
ENT.HasHitGroupFlinching = false -- It will flinch when hit in certain hitgroups | It can also have certain animations to play in certain hitgroups
ENT.HitGroupFlinching_DefaultWhenNotHit = true -- If it uses hitgroup flinching, should it do the regular flinch if it doesn't hit any of the specified hitgroups?
ENT.HitGroupFlinching_Values = {
	{HitGroup = {1}, Animation = {"KSWoundHead"}}, --Head
	{HitGroup = {2}, Animation = {"Shoved_Backward_01","Shoved_Backward_02","Shoved_Backward_03","Shoved_Backward_04","Shoved_Backward_05"}}, --Chest
	{HitGroup = {4}, Animation = {"Shoved_Leftward_01"}}, --Left Arm
	{HitGroup = {5}, Animation = {"Shoved_Rightward_01"}}, --Right Arm
	{HitGroup = {6}, Animation = {"KSWoundLeftLeg"}}, --Left Leg
	{HitGroup = {7}, Animation = {"KSWoundRightLeg"}}, --Right Leg
}
	-- ====== Damage By Player Variables ====== --
ENT.HasDamageByPlayer = false -- Should the SNPC do something when it's hit by a player? Example: Play a sound or animation
ENT.DamageByPlayerDispositionLevel = 0 -- 0 = Run it every time | 1 = Run it only when friendly to player | 2 = Run it only when enemy to player
ENT.DamageByPlayerNextTime1 = 2 -- How much time should it pass until it runs the code again? | First number in math.random
ENT.DamageByPlayerNextTime2 = 2 -- How much time should it pass until it runs the code again? | Second number in math.random
	-- ====== Run Away On Unknown Damage Variables ====== --
ENT.RunAwayOnUnknownDamage = false -- Should run away on damage
ENT.NextRunAwayOnDamageTime = 5 -- Until next run after being shot when not alerted
	-- ====== Call For Back On Damage Variables ====== --
ENT.CallForBackUpOnDamage = true -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)
ENT.CallForBackUpOnDamageDistance = 800 -- How far away the SNPC's call for help goes | Counted in World Units
ENT.CallForBackUpOnDamageUseCertainAmount = true -- Should the SNPC only call certain amount of people?
ENT.CallForBackUpOnDamageUseCertainAmountNumber = 3 -- How many people should it call if certain amount is enabled?
ENT.CallForBackUpOnDamageAnimation = {} -- Animation used if the SNPC does the CallForBackUpOnDamage function
	-- To let the base automatically detect the animation duration, set this to false:
ENT.CallForBackUpOnDamageAnimationTime = false -- How much time until it can use activities
ENT.NextCallForBackUpOnDamageTime1 = 9 -- Next time it use the CallForBackUpOnDamage function | The first # in math.random
ENT.NextCallForBackUpOnDamageTime2 = 11 -- Next time it use the CallForBackUpOnDamage function | The second # in math.random
ENT.DisableCallForBackUpOnDamageAnimation = false -- Disables the animation when the CallForBackUpOnDamage function is called
	-- ====== Taking Cover Variables ====== --
ENT.AnimTbl_TakingCover = {} -- The animation it plays when hiding in a covered position, leave empty to let the base decide
	-- ====== Move Or Hide On Damage Variables ====== --
ENT.MoveOrHideOnDamageByEnemy = true -- Should the SNPC move or hide when being damaged by an enemy?
ENT.MoveOrHideOnDamageByEnemy_OnlyMove = false -- Should it only move and not hide?
ENT.AnimTbl_MoveOrHideOnDamageByEnemy = {} -- The activities it plays when it finds a hiding spot | This will override self.AnimTbl_TakingCover and and the base animations
ENT.MoveOrHideOnDamageByEnemy_HideTime1 = 3 -- How long should it hide? | First number in math.random
ENT.MoveOrHideOnDamageByEnemy_HideTime2 = 4 -- How long should it hide? | Second number in math.random
ENT.MoveOrHideOnDamageByEnemy_NextHideTime1 = 7 -- How long until it can hide again? | First number in math.random
ENT.MoveOrHideOnDamageByEnemy_NextHideTime2 = 8 -- How long until it can hide again? | Second number in math.random
ENT.NextMoveOrHideOnDamageByEnemy1 = 3 -- How much time until it moves or hides on damage by enemy? | The first # in math.random
ENT.NextMoveOrHideOnDamageByEnemy2 = 3.5 -- How much time until it moves or hides on damage by enemy? | The second # in math.random
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Killed & Corpse Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ====== Corpse Variables ====== --
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.DeathCorpseEntityClass = "UseDefaultBehavior" -- The entity class it creates | "UseDefaultBehavior" = Let the base automatically detect the type
ENT.DeathCorpseModel = {} -- The corpse model that it will spawn when it dies | Leave empty to use the NPC's model | Put as many models as desired, the base will pick a random one.
ENT.DeathCorpseSkin = -1 -- Used to override the death skin | -1 = Use the skin that the SNPC had before it died
ENT.DeathCorpseSetBodyGroup = true -- Should it get the models bodygroups and set it to the corpse? When set to false, it uses the model's default bodygroups
	-- Set both of the following BodyGroup variables to a number greater than -1 to set a custom bodygroup for the corpse:
ENT.DeathBodyGroupA = -1 -- Used for Custom Bodygroup | Group = A
ENT.DeathBodyGroupB = -1 -- Used for Custom Bodygroup | Group = B
ENT.DeathCorpseAlwaysCollide = false -- Should the corpse always collide?
ENT.FadeCorpse = false -- Fades the ragdoll on death
ENT.FadeCorpseTime = 10 -- How much time until the ragdoll fades | Unit = Seconds
ENT.SetCorpseOnFire = false -- Sets the corpse on fire when the SNPC dies
ENT.UsesBoneAngle = true -- This can be used to stop the corpse glitching or flying on death
ENT.UsesDamageForceOnDeath = true -- Disables the damage force on death | Useful for SNPCs with Death Animations
ENT.WaitBeforeDeathTime = 0 -- Time until the SNPC spawns its corpse and gets removed
	-- ====== Death Animation Variables ====== --
ENT.HasDeathAnimation = false -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"vjseq_death_01",
					"vjseq_death_02a",
					"vjseq_death_02c",
					"vjseq_death_03",
					"vjseq_death_05",
					"vjseq_death_06",
					"vjseq_death_07",
					"vjseq_death_08",
					"vjseq_death_08b",
					"vjseq_death_09",
					"vjseq_death_10ab",
					"vjseq_death_10b",
					"vjseq_death_10c",	--Commented out because they were too long-form deaths, not sudden enough for regular stormtroopers.
					"vjseq_death_11_01a",
					"vjseq_death_11_01b",
					"vjseq_death_11_02a",
					"vjseq_death_11_02b",
					"vjseq_death_11_02c",
					"vjseq_death_11_02d",
					"vjseq_death_11_03a",
					"vjseq_death_11_03b",
					"vjseq_death_11_03c",
					"deathrunning_01",
					"deathrunning_03",
					"deathrunning_04",
					"deathrunning_05",
					"deathrunning_06",
					"deathrunning_07",
					"deathrunning_08",
					"deathrunning_09",
					"deathrunning_10",
					"deathrunning_11a",
					"deathrunning_11b",
					"deathrunning_11c",
					"deathrunning_11d",
					"deathrunning_11e",
					"deathrunning_11f",
					"deathrunning_11g"} -- Death Animations
ENT.DeathAnimationChance = 1.5 -- Put 1 if you want it to play the animation all the time
	-- To let the base automatically detect the animation duration, set this to false:
	-- ====== Dismemberment/Gib Variables ====== --
ENT.AllowedToGib = false -- Is it allowed to gib in general? This can be on death or when shot in a certain place
ENT.HasGibOnDeath = false -- Is it allowed to gib on death?
ENT.GibOnDeathDamagesTable = {DMG_CRUSH} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
ENT.HasGibOnDeathSounds = true -- Does it have gib sounds? | Mostly used for the settings menu
ENT.HasGibDeathParticles = true -- Does it spawn particles on death or when it gibs? | Mostly used for the settings menu
	-- ====== Item Drops On Death Variables ====== --
ENT.DropWeaponOnDeath = false -- Should it drop its weapon on death?
ENT.DropWeaponOnDeathAttachment = "anim_attachment_RH" -- Which attachment should it use for the weapon's position
ENT.HasItemDropsOnDeath = false -- Should it drop items on death?
ENT.ItemDropsOnDeathChance = 14 -- If set to 1, it will always drop it
ENT.ItemDropsOnDeath_EntityList = {"weapon_frag","item_healthvial"} -- List of items it will randomly pick from | Leave it empty to drop nothing or to make your own dropping code (Using CustomOn...)
	-- ====== Ally Reaction On Death Variables ====== --
	-- Default: Creature base uses BringFriends and Human base uses AlertFriends
	-- BringFriendsOnDeath takes priority over AlertFriendsOnDeath!
ENT.BringFriendsOnDeath = false -- Should the SNPC's friends come to its position before it dies?
ENT.BringFriendsOnDeathDistance = 800 -- How far away does the signal go? | Counted in World Units
ENT.BringFriendsOnDeathUseCertainAmount = true -- Should the SNPC only call certain amount of people?
ENT.BringFriendsOnDeathUseCertainAmountNumber = 3 -- How many people should it call if certain amount is enabled?
ENT.AlertFriendsOnDeath = true -- Should the SNPCs allies get alerted when it dies? | Its allies will also need to have this variable set to true!
ENT.AlertFriendsOnDeathDistance = 800 -- How far away does the signal go? | Counted in World Units
ENT.AlertFriendsOnDeathUseCertainAmountNumber = 50 -- How many people should it alert?
ENT.AnimTbl_AlertFriendsOnDeath = {ACT_RANGE_ATTACK1} -- Animations it plays when an ally dies that also has AlertFriendsOnDeath set to true
	-- ====== Miscellaneous Variables ====== --
ENT.HasDeathNotice = false -- Set to true if you want it show a message after it dies
ENT.DeathNoticePosition = HUD_PRINTCENTER -- Were you want the message to show. Examples: HUD_PRINTCENTER, HUD_PRINTCONSOLE, HUD_PRINTTALK
ENT.DeathNoticeWriting = "Example: Spider Queen Has Been Defeated!" -- Message that will appear
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Melee Attack Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = GetConVarNumber("vj_snpcdamage")
	-- ====== Animation Variables ====== --
ENT.AnimTbl_MeleeAttack = {"vjseq_swing"} -- Melee Attack Animations
ENT.MeleeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.MeleeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the melee attack animation?
ENT.MeleeAttackAnimationDecreaseLengthAmount = 0 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the enemy.
	-- ====== Distance Variables ====== --
ENT.MeleeAttackDistance = 30 -- How close does it have to be until it attacks?
ENT.MeleeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.MeleeAttackDamageAngleRadius = 100 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
	-- ====== Timer Variables ====== --
	-- To use event-based attacks, set this to false:
ENT.TimeUntilMeleeAttackDamage = 0.5 -- This counted in seconds | This calculates the time until it hits something
ENT.NextMeleeAttackTime = 0 -- How much time until it can use a melee attack?
ENT.NextMeleeAttackTime_DoRand = false -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
	-- To let the base automatically detect the attack duration, set this to false:
ENT.NextAnyAttackTime_Melee = false -- How much time until it can use any attack again? | Counted in Seconds
ENT.NextAnyAttackTime_Melee_DoRand = false -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
ENT.MeleeAttackReps = 1 -- How many times does it run the melee attack code?
ENT.MeleeAttackExtraTimers = {/* Ex: 1,1.4 */} -- Extra melee attack timers | it will run the damage code after the given amount of seconds
ENT.StopMeleeAttackAfterFirstHit = false -- Should it stop the melee attack from running rest of timers when it hits an enemy?
	-- ====== Control Variables ====== --
ENT.DisableMeleeAttackAnimation = false -- if true, it will disable the animation code
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Weapon Attack Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.WeaponSpread = 3.5 -- What's the spread of the weapon? | Closer to 0 = better accuracy, Farther than 1 = worse accuracy
ENT.DisableWeapons = false -- If set to true, it won't be able to use weapons
ENT.Weapon_NoSpawnMenu = false -- If set to true, the NPC weapon setting in the spawnmenu will not be applied for this SNPC
	-- ====== Distance Variables ====== --
ENT.Weapon_FiringDistanceFar = 100000 -- How far away it can shoot
ENT.Weapon_FiringDistanceClose = 0.5 -- How close until it stops shooting
	-- ====== Standing-Firing Variables ====== --
ENT.AnimTbl_WeaponAttack = {ACT_RANGE_ATTACK_SHOTGUN} -- Animation played when the SNPC does weapon attack | For VJ Weapons
ENT.WeaponAttackSchedule = {SCHED_RANGE_ATTACK1} -- Schedule played when the SNPC does weapon attack | For None-VJ Weapons
ENT.CanCrouchOnWeaponAttack = true -- Can it crouch while shooting?
ENT.AnimTbl_WeaponAttackCrouch = {} -- Animation played when the SNPC does weapon attack while crouching | For VJ Weapons
ENT.CanCrouchOnWeaponAttackChance = 4.5 -- How much chance of crouching? | 1 = Crouch every time
ENT.AnimTbl_WeaponAttackFiringGesture = {} -- Firing Gesture animations used when the SNPC is firing the weapon | Leave empty for the base to decide
ENT.DisableWeaponFiringGesture = false -- If set to true, it will disable the weapon firing gestures
	-- ====== Moving-Firing Variables ====== --
ENT.HasShootWhileMoving = true -- Can it shoot while moving?
ENT.AnimTbl_ShootWhileMovingRun = {} -- Animations it will play when shooting while running | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_ShootWhileMovingWalk = {} -- Animations it will play when shooting while walking | NOTE: Weapon may translate the animation that they see fit!
	-- ====== Reloading Variables ====== --
ENT.AllowWeaponReloading = true -- If false, the SNPC will no longer reload
ENT.DisableWeaponReloadAnimation = false -- if true, it will disable the animation code when reloading
ENT.AnimTbl_WeaponReload = {ACT_RELOAD_SHOTGUN} -- Animations that play when the SNPC reloads
ENT.AnimTbl_WeaponReloadBehindCover = {ACT_RELOAD_LOW, ACT_RELOAD_PISTOL_LOW} -- Animations that it plays when the SNPC reloads, but behind cover
ENT.WeaponReloadAnimationFaceEnemy = true -- Should it face the enemy while playing the weapon reload animation?
ENT.WeaponReloadAnimationDecreaseLengthAmount = 0 -- This will decrease the time until it starts moving or attack again. Use it to fix animation pauses until it chases the enemy.
ENT.WeaponReloadAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
	-- ====== Weapon Inventory Variables ====== --
	-- Weapons are given on spawn and the NPC will only switch to those if the requirements are met
	-- The items that are stored in self.WeaponInventory:
		-- Primary - Default weapon
		-- AntiArmor - Current enemy is an armored enemy (Usually vehicle) or a boss
		-- Melee - Current enemy is (very close and the NPC is out of ammo) OR (in regular melee attack distance) + NPC must have more than 25% health
ENT.WeaponInventory_AntiArmor = false -- If true, the NPC will spawn with one of the given weapons (Will only be given the weapon if it already has another!)
ENT.WeaponInventory_AntiArmorList = {} -- It will randomly be given one of these weapons
ENT.WeaponInventory_Melee = false -- If true, the NPC will spawn with one of the given weapons (Will only be given the weapon if it already has another!)
ENT.WeaponInventory_MeleeList = {"vjks_ww2_wep_ger_spade"} -- It will randomly be given one of these weapons
	-- ====== Move Randomly While Firing Variables ====== --
ENT.MoveRandomlyWhenShooting = true -- Should it move randomly when shooting?
ENT.NextMoveRandomlyWhenShootingTime1 = 0.5 -- How much time until it can move randomly when shooting? | First number in math.random
ENT.NextMoveRandomlyWhenShootingTime2 = 1 -- How much time until it can move randomly when shooting? | Second number in math.random
	-- ====== Wait For Enemy To Come Out Variables ====== --
ENT.WaitForEnemyToComeOut = false -- Should it wait for the enemy to come out from hiding?
ENT.AnimTbl_CustomWaitForEnemyToComeOut = {} -- Leave empty to use the default animations from the base | The base will play the firing animations
ENT.WaitForEnemyToComeOutTime1 = 3 -- How much time should it wait until it starts chasing the enemy? | First number in math.random
ENT.WaitForEnemyToComeOutTime2 = 4 -- How much time should it wait until it starts chasing the enemy? | Second number in math.random
ENT.WaitForEnemyToComeOutDistance = 100 -- If it's this close to the enemy, it won't do it
	-- ====== Scared Behavior Variables ====== --
ENT.NoWeapon_UseScaredBehavior = true -- Should it use the scared behavior when it sees an enemy and doesn't have a weapon?
ENT.AnimTbl_ScaredBehaviorStand = {ACT_COWER} -- The animation it will when it's just standing still | Replaces the idle stand animation
ENT.AnimTbl_ScaredBehaviorMovement = {} -- The movement animation it will play | Leave empty for the base to decide the animation
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Grenade Attack Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasGrenadeAttack = false -- Should the SNPC have a grenade attack?
ENT.GrenadeAttackEntity = "obj_vjks_ww2_ger_stickgrenade" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.GrenadeAttackModel = "models/weapons/w_stick.mdl" -- The model for the grenade entity
	-- ====== Animation Variables ====== --
ENT.AnimTbl_GrenadeAttack = {ACT_RANGE_ATTACK_THROW} -- Grenade Attack Animations
ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.GrenadeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the grenade attack animation?
	-- ====== Distance & Chance Variables ====== --
ENT.NextThrowGrenadeTime1 = 10 -- Time until it runs the throw grenade code again | The first # in math.random
ENT.NextThrowGrenadeTime2 = 15 -- Time until it runs the throw grenade code again | The second # in math.random
ENT.ThrowGrenadeChance = 6.5 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 2400 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 100 -- How close until it stops throwing grenades
	-- ====== Timer Variables ====== --
ENT.TimeUntilGrenadeIsReleased = 0.62 -- Time until the grenade is released
	-- To let the base automatically detect the attack duration, set this to false:
ENT.GrenadeAttackAnimationStopAttacks = false -- Should it stop attacks for a certain amount of time?
ENT.GrenadeAttackAnimationStopAttacksTime = false -- How long should it stop attacks?
ENT.GrenadeAttackFussTime = 3 -- Time until the grenade explodes
	-- ====== Projectile Spawn & Velocity Variables ====== --
ENT.GrenadeAttackAttachment = "anim_attachment_LH" -- The attachment that the grenade will spawn at
ENT.GrenadeAttackVelUp1 = 200 -- Grenade attack velocity up | The first # in math.random
ENT.GrenadeAttackVelUp2 = 200 -- Grenade attack velocity up | The second # in math.random
ENT.GrenadeAttackVelForward1 = 500 -- Grenade attack velocity up | The first # in math.random
ENT.GrenadeAttackVelForward2 = 500 -- Grenade attack velocity up | The second # in math.random
ENT.GrenadeAttackVelRight1 = -20 -- Grenade attack velocity right | The first # in math.random
ENT.GrenadeAttackVelRight2 = 20 -- Grenade attack velocity right | The second # in math.random
	-- ====== Grenade Detection & Throwing Back Variables ====== --
ENT.CanDetectGrenades = true -- Set to false to disable the SNPC from running away from grenades
ENT.RunFromGrenadeDistance = 400 -- If the entity is this close to the it, then run!
	-- NOTE: The ability to throw grenades back only work if the SNPC can detect grenades AND has a grenade attack!
ENT.CanThrowBackDetectedGrenades = true -- Should it try to pick up the detected grenade and throw it back to the enemy?
	-- ====== Control Variables ====== --
ENT.DisableGrenadeAttackAnimation = false -- if true, it will disable the animation code when doing grenade attack
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Sound Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasSounds = true -- Put to false to disable ALL sounds
	-- ====== Footstep Sound Variables ====== --
ENT.DisableFootStepSoundTimer = false -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = .5 -- Next foot step sound when it is walking
ENT.DisableFootStepOnRun = false -- It will not play the footstep sound when running
ENT.DisableFootStepOnWalk = false -- It will not play the footstep sound when walking
ENT.HasWorldShakeOnMove = false -- Should the world shake when it's moving?
ENT.NextWorldShakeOnRun = 0.5 -- How much time until the world shakes while it's running
ENT.NextWorldShakeOnWalk = 1 -- How much time until the world shakes while it's walking
ENT.WorldShakeOnMoveAmplitude = 10 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.WorldShakeOnMoveRadius = 1000 -- How far the screen shake goes, in world units
ENT.WorldShakeOnMoveDuration = 0.4 -- How long the screen shake will last, in seconds
ENT.WorldShakeOnMoveFrequency = 100 -- Just leave it to 100
ENT.DisableWorldShakeOnMoveWhileRunning = false -- It will not shake the world when it's running
ENT.DisableWorldShakeOnMoveWhileWalking = false -- It will not shake the world when it's walking
	-- The following custom variables are used for timer-based footstep & world shake
	-- Add any animations that should be used to trigger a sound or shake the world, only add animations if the base doesn't recognize an animation as a movement!
ENT.CustomWalkActivites = {} -- Custom walk activities
ENT.CustomRunActivites = {} -- Custom run activities
	-- ====== Idle Sound Variables ====== --
ENT.IdleSounds_NoRegularIdleOnAlerted = false -- if set to true, it will not play the regular idle sound table if the combat idle sound table is empty
	-- ====== Miscellaneous Variables ====== --
ENT.AlertSounds_OnlyOnce = false -- After it plays it once, it will never play it again
ENT.BeforeMeleeAttackSounds_WaitTime = 0 -- Time until it starts playing the Before Melee Attack sounds
ENT.OnlyDoKillEnemyWhenClear = true -- When there is no enemy in sight
	-- ====== Main Control Variables ====== --
ENT.HasFootStepSound = true -- Should the SNPC make a footstep sound when it's moving?
ENT.HasBreathSound = false -- Should it make a breathing sound?
ENT.HasIdleSounds = true -- If set to false, it won't play the idle sounds
ENT.HasOnReceiveOrderSounds = true -- If set to false, it won't play any sound when it receives an order from an ally
ENT.HasFollowPlayerSounds_Follow = true -- If set to false, it won't play the follow player sounds
ENT.HasFollowPlayerSounds_UnFollow = true -- If set to false, it won't play the unfollow player sounds
ENT.HasMoveOutOfPlayersWaySounds = true -- If set to false, it won't play any sounds when it moves out of the player's way
ENT.HasMedicSounds_BeforeHeal = true -- If set to false, it won't play any sounds before it gives a med kit to an ally
ENT.HasMedicSounds_AfterHeal = true -- If set to false, it won't play any sounds after it gives a med kit to an ally
ENT.HasMedicSounds_ReceiveHeal = true -- If set to false, it won't play any sounds when it receives a medkit
ENT.HasOnPlayerSightSounds = true -- If set to false, it won't play the saw player sounds
ENT.HasInvestigateSounds = true -- If set to false, it won't play any sounds when it's investigating something
ENT.HasAlertSounds = true -- If set to false, it won't play the alert sounds
ENT.HasCallForHelpSounds = true -- If set to false, it won't play any sounds when it calls for help
ENT.HasBecomeEnemyToPlayerSounds = true -- If set to false, it won't play the become enemy to player sounds
ENT.HasSuppressingSounds = true -- If set to false, it won't play any sounds when firing a weapon
ENT.HasWeaponReloadSounds = true -- If set to false, it won't play any sound when reloading
ENT.HasMeleeAttackSounds = true -- If set to false, it won't play the melee attack sound
ENT.HasExtraMeleeAttackSounds = false -- Set to true to use the extra melee attack sounds
ENT.HasMeleeAttackMissSounds = true -- If set to false, it won't play the melee attack miss sound
ENT.HasGrenadeAttackSounds = true -- If set to false, it won't play any sound when doing grenade attack
ENT.HasOnGrenadeSightSounds = true -- If set to false, it won't play any sounds when it sees a grenade
ENT.HasOnKilledEnemySound = true -- Should it play a sound when it kills an enemy?
ENT.HasPainSounds = true -- If set to false, it won't play the pain sounds
ENT.HasImpactSounds = true -- If set to false, it won't play the impact sounds
ENT.HasDamageByPlayerSounds = true -- If set to false, it won't play the damage by player sounds
ENT.HasDeathSounds = true -- If set to false, it won't play the death sounds
ENT.HasSoundTrack = false -- Does the SNPC have a sound track?
	-- ====== File Path Variables ====== --
	-- Leave blank if you don't want any sounds to play
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
					
					
function ENT:CustomOnInitialize()
	if math.random(1,0) == 1 then
		self:SetBodygroup(0,math.random(0,8)) -- Heads
		self:SetBodygroup(1,math.random(0,6)) -- Headwear
		self:SetBodygroup(2,math.random(0,0)) -- Eyewear
		self:SetBodygroup(3,math.random(0,0)) -- Maskwear
		self:SetBodygroup(4,math.random(0,2)) -- Ranks
		self:SetBodygroup(5,math.random(0,1)) -- Handwear
		self:SetBodygroup(6,math.random(0,1)) -- Tunics
		self:SetBodygroup(7,math.random(0,1)) -- Legwear
		self:SetBodygroup(8,math.random(2,3)) -- Y-Straps
		self:SetBodygroup(9,math.random(1,2)) -- Equipment
		self:SetBodygroup(10,math.random(0,0)) -- Feldgendarmerie
	end
end
					
					
					
					
ENT.SoundTbl_SoundTrack = {}
	-- ====== Fade Out Time Variables ====== --
	-- Put to 0 if you want it to stop instantly
ENT.SoundTrackFadeOutTime = 2
	-- ====== Sound Chance Variables ====== --
	-- Higher number = less chance of playing | 1 = Always play
ENT.IdleSoundChance = 8
ENT.CombatIdleSoundChance = 1
ENT.OnReceiveOrderSoundChance = 1
ENT.FollowPlayerSoundChance = 1
ENT.UnFollowPlayerSoundChance = 1
ENT.MoveOutOfPlayersWaySoundChance = 2
ENT.MedicBeforeHealSoundChance = 1
ENT.MedicAfterHealSoundChance = 1
ENT.MedicReceiveHealSoundChance = 1
ENT.OnPlayerSightSoundChance = 1
ENT.InvestigateSoundChance = 1
ENT.AlertSoundChance = 1
ENT.CallForHelpSoundChance = 1
ENT.BecomeEnemyToPlayerChance = 1
ENT.BeforeMeleeAttackSoundChance = 1
ENT.MeleeAttackSoundChance = 1
ENT.ExtraMeleeSoundChance = 1
ENT.MeleeAttackMissSoundChance = 1
ENT.GrenadeAttackSoundChance = 1
ENT.OnGrenadeSightSoundChance = 1
ENT.SuppressingSoundChance = 2
ENT.WeaponReloadSoundChance = 1
ENT.OnKilledEnemySoundChance = 1
ENT.PainSoundChance = 1
ENT.ImpactSoundChance = 1
ENT.DamageByPlayerSoundChance = 1
ENT.DeathSoundChance = 1
ENT.SoundTrackChance = 1
	-- ====== Timer Variables ====== --
	-- Randomized time between the two variables, x amount of time has to pass for the sound to play again | Counted in seconds
ENT.NextSoundTime_Breath_BaseDecide = true -- Let the base decide the next sound time, if it can't it will use the numbers below
ENT.NextSoundTime_Breath1 = 1
ENT.NextSoundTime_Breath2 = 1
ENT.NextSoundTime_Idle1 = 8
ENT.NextSoundTime_Idle2 = 25
ENT.NextSoundTime_Investigate1 = 5
ENT.NextSoundTime_Investigate2 = 5
ENT.NextSoundTime_Alert1 = 2
ENT.NextSoundTime_Alert2 = 3
ENT.NextSoundTime_OnGrenadeSight1 = 3
ENT.NextSoundTime_OnGrenadeSight2 = 3
ENT.NextSoundTime_Suppressing1 = 7
ENT.NextSoundTime_Suppressing2 = 15
ENT.NextSoundTime_WeaponReload1 = 3
ENT.NextSoundTime_WeaponReload2 = 5
ENT.NextSoundTime_OnKilledEnemy1 = 3
ENT.NextSoundTime_OnKilledEnemy2 = 5
ENT.NextSoundTime_Pain1 = 2
ENT.NextSoundTime_Pain2 = 2
ENT.NextSoundTime_DamageByPlayer1 = 2
ENT.NextSoundTime_DamageByPlayer2 = 2.3
	-- ====== Volume Variables ====== --
	-- Number must be between 0 and 1
	-- 0 = No sound, 1 = normal/loudest
ENT.SoundTrackVolume = 1
	-- ====== Sound Level Variables ====== --
	-- The proper number are usually range from 0 to 180, though it can go as high as 511
	-- More Information: https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel_Flags
ENT.FootStepSoundLevel = 70
ENT.BreathSoundLevel = 60
ENT.IdleSoundLevel = 75
ENT.CombatIdleSoundLevel = 80
ENT.OnReceiveOrderSoundLevel = 80
ENT.FollowPlayerSoundLevel = 75
ENT.UnFollowPlayerSoundLevel = 75
ENT.MoveOutOfPlayersWaySoundLevel = 75
ENT.BeforeHealSoundLevel = 75
ENT.AfterHealSoundLevel = 75
ENT.MedicReceiveHealSoundLevel = 75
ENT.OnPlayerSightSoundLevel = 75
ENT.InvestigateSoundLevel = 80
ENT.AlertSoundLevel = 80
ENT.CallForHelpSoundLevel = 80
ENT.BecomeEnemyToPlayerSoundLevel = 75
ENT.BeforeMeleeAttackSoundLevel = 75
ENT.MeleeAttackSoundLevel = 75
ENT.ExtraMeleeAttackSoundLevel = 75
ENT.MeleeAttackMissSoundLevel = 75
ENT.SuppressingSoundLevel = 80
ENT.WeaponReloadSoundLevel = 80
ENT.GrenadeAttackSoundLevel = 80
ENT.OnGrenadeSightSoundLevel = 80
ENT.OnKilledEnemySoundLevel = 80
ENT.PainSoundLevel = 80
ENT.ImpactSoundLevel = 60
ENT.DamageByPlayerSoundLevel = 75
ENT.DeathSoundLevel = 80
//ENT.SoundTrackLevel = 0.9
	-- ====== Sound Pitch Variables ====== --
	-- Higher number = Higher pitch | Lower number = Lower pitch
	-- Highest acceptable number is 254
ENT.UseTheSameGeneralSoundPitch = true
	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"
	-- It picks the number between these two variables below:
ENT.GeneralSoundPitch1 = 90
ENT.GeneralSoundPitch2 = 100
	-- These two variables control any sound pitch variable that is set to "UseGeneralPitch"
	-- To not use these variables for a certain sound pitch, just put the desired number in the specific sound pitch
ENT.FootStepPitch1 = 80
ENT.FootStepPitch2 = 100
ENT.BreathSoundPitch1 = 100
ENT.BreathSoundPitch2 = 100
ENT.IdleSoundPitch1 = "UseGeneralPitch"
ENT.IdleSoundPitch2 = "UseGeneralPitch"
ENT.CombatIdleSoundPitch1 = "UseGeneralPitch"
ENT.CombatIdleSoundPitch2 = "UseGeneralPitch"
ENT.OnReceiveOrderSoundPitch1 = "UseGeneralPitch"
ENT.OnReceiveOrderSoundPitch2 = "UseGeneralPitch"
ENT.FollowPlayerPitch1 = "UseGeneralPitch"
ENT.FollowPlayerPitch2 = "UseGeneralPitch"
ENT.UnFollowPlayerPitch1 = "UseGeneralPitch"
ENT.UnFollowPlayerPitch2 = "UseGeneralPitch"
ENT.MoveOutOfPlayersWaySoundPitch1 = "UseGeneralPitch"
ENT.MoveOutOfPlayersWaySoundPitch2 = "UseGeneralPitch"
ENT.BeforeHealSoundPitch1 = "UseGeneralPitch"
ENT.BeforeHealSoundPitch2 = "UseGeneralPitch"
ENT.AfterHealSoundPitch1 = 100
ENT.AfterHealSoundPitch2 = 100
ENT.MedicReceiveHealSoundPitch1 = "UseGeneralPitch"
ENT.MedicReceiveHealSoundPitch2 = "UseGeneralPitch"
ENT.OnPlayerSightSoundPitch1 = "UseGeneralPitch"
ENT.OnPlayerSightSoundPitch2 = "UseGeneralPitch"
ENT.InvestigateSoundPitch1 = "UseGeneralPitch"
ENT.InvestigateSoundPitch2 = "UseGeneralPitch"
ENT.AlertSoundPitch1 = "UseGeneralPitch"
ENT.AlertSoundPitch2 = "UseGeneralPitch"
ENT.CallForHelpSoundPitch1 = "UseGeneralPitch"
ENT.CallForHelpSoundPitch2 = "UseGeneralPitch"
ENT.BecomeEnemyToPlayerPitch1 = "UseGeneralPitch"
ENT.BecomeEnemyToPlayerPitch2 = "UseGeneralPitch"
ENT.BeforeMeleeAttackSoundPitch1 = "UseGeneralPitch"
ENT.BeforeMeleeAttackSoundPitch2 = "UseGeneralPitch"
ENT.MeleeAttackSoundPitch1 = 95
ENT.MeleeAttackSoundPitch2 = 100
ENT.ExtraMeleeSoundPitch1 = 80
ENT.ExtraMeleeSoundPitch2 = 100
ENT.MeleeAttackMissSoundPitch1 = 90
ENT.MeleeAttackMissSoundPitch2 = 100
ENT.SuppressingPitch1 = "UseGeneralPitch"
ENT.SuppressingPitch2 = "UseGeneralPitch"
ENT.WeaponReloadSoundPitch1 = "UseGeneralPitch"
ENT.WeaponReloadSoundPitch2 = "UseGeneralPitch"
ENT.GrenadeAttackSoundPitch1 = "UseGeneralPitch"
ENT.GrenadeAttackSoundPitch2 = "UseGeneralPitch"
ENT.OnGrenadeSightSoundPitch1 = "UseGeneralPitch"
ENT.OnGrenadeSightSoundPitch2 = "UseGeneralPitch"
ENT.OnKilledEnemySoundPitch1 = "UseGeneralPitch"
ENT.OnKilledEnemySoundPitch2 = "UseGeneralPitch"
ENT.PainSoundPitch1 = "UseGeneralPitch"
ENT.PainSoundPitch2 = "UseGeneralPitch"
ENT.ImpactSoundPitch1 = 90
ENT.ImpactSoundPitch2 = 100
ENT.DamageByPlayerPitch1 = "UseGeneralPitch"
ENT.DamageByPlayerPitch2 = "UseGeneralPitch"
ENT.DeathSoundPitch1 = "UseGeneralPitch"
ENT.DeathSoundPitch2 = "UseGeneralPitch"
	-- ====== Playback Rate Variables ====== --
	-- Decides how fast the sound should play
	-- Examples: 1 = normal, 2 = twice the normal speed, 0.5 = half the normal speed
ENT.SoundTrackPlaybackRate = 1

---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	if self.HasGibDeathParticles == true then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodeffect:SetColor(VJ_Color2Byte(Color(130,19,10)))
		bloodeffect:SetScale(120)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
		bloodspray:SetOrigin(self:GetPos())
		bloodspray:SetScale(8)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(0)
		util.Effect("bloodspray",bloodspray)
		util.Effect("bloodspray",bloodspray)
	end
	
	self:CreateGibEntity("obj_vj_gib","models/gibs/humans/eye_gib.mdl",{Pos=self:LocalToWorld(Vector(0,0,65)),Ang=self:GetAngles()+Angle(0,-90,0),Vel=self:GetRight()*math.Rand(150,250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("obj_vj_gib","models/Gibs/HGIBS.mdl",{Pos=self:LocalToWorld(Vector(0,3,65)),Ang=self:GetAngles()+Angle(0,-90,0),Vel=self:GetRight()*math.Rand(-150,-250)+self:GetForward()*math.Rand(-200,200)})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,30))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,30))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos=self:LocalToWorld(Vector(0,0,30))})
	self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos=self:LocalToWorld(Vector(0,0,40))})
	self:CreateGibEntity("obj_vj_gib","models/props_junk/Shoe001a.mdl",{Pos=self:LocalToWorld(Vector(0,0,35))})
	self:CreateGibEntity("obj_vj_gib","models/props_junk/Shoe001a.mdl",{Pos=self:LocalToWorld(Vector(0,0,35))})
	return true
end



/*--------------------------------------------------
	=============== Human SNPC Base ===============
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
INFO: Used to make human SNPCs
--------------------------------------------------*/
