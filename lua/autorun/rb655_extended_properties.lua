
AddCSLuaFile()

local function rb655_property_filter( filtor, ent )
	if ( type( filtor ) == "string" && filtor != ent:GetClass() ) then return false end
	if ( type( filtor ) == "table" && !table.HasValue( filtor, ent:GetClass() ) ) then return false end
	if ( type( filtor ) == "function" && !filtor( ent ) ) then return false end

	return true
end

function AddEntFunctionProperty( name, label, pos, filtor, func, icon )
	properties.Add( name, {
		MenuLabel = label,
		MenuIcon = icon,
		Order =	pos,
		Filter = function( self, ent, ply )
			if ( !IsValid( ent ) or !gamemode.Call( "CanProperty", ply, name, ent ) ) then return false end
			if ( !rb655_property_filter( filtor, ent ) ) then return false end
			return true 
		end,
		Action = function( self, ent )
			self:MsgStart()
				net.WriteEntity( ent )
			self:MsgEnd()
		end,
		Receive = function( self, length, ply )
			local ent = net.ReadEntity()

			if ( !IsValid( ply ) or !IsValid( ent ) or !self:Filter( ent, ply ) ) then return false end

			if ( !rb655_property_filter( filtor, ent ) ) then return end
			func( ent, ply )
		end
	} )
end

function AddEntFireProperty( name, label, pos, class, input, icon )
	AddEntFunctionProperty( name, label, pos, class, function( e ) e:Fire( unpack( string.Explode( " ", input ) ) ) end, icon )
end

local ExplodeIcon = "icon16/bomb.png"
local EnableIcon = "icon16/tick.png"
local DisableIcon = "icon16/cross.png"
local ToggleIcon = "icon16/arrow_switch.png"

-- Half - Life 2 Specific
AddEntFireProperty("rb655_door_open", "Open", 655, {"prop_door_rotating", "func_door_rotating", "func_door"}, "Open", "icon16/door_open.png")
AddEntFireProperty("rb655_door_close", "Close", 656, {"prop_door_rotating", "func_door_rotating", "func_door"}, "Close", "icon16/door.png")
AddEntFireProperty("rb655_door_lock", "Lock", 657, {"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat"}, "Lock", "icon16/lock.png")
AddEntFireProperty("rb655_door_unlock", "Unlock", 658, {"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat"}, "Unlock", "icon16/lock_open.png")

AddEntFireProperty("rb655_func_movelinear_open", "Start", 655, "func_movelinear", "Open", "icon16/arrow_right.png")
AddEntFireProperty("rb655_func_movelinear_close", "Return", 656, "func_movelinear", "Close", "icon16/arrow_left.png")

AddEntFireProperty("rb655_func_tracktrain_StartForward", "Start Forward", 655, "func_tracktrain", "StartForward", "icon16/arrow_right.png")
AddEntFireProperty("rb655_func_tracktrain_StartBackward", "Start Backward", 656, "func_tracktrain", "StartBackward", "icon16/arrow_left.png")
AddEntFireProperty("rb655_func_tracktrain_Reverse", "Reverse", 657, "func_tracktrain", "Reverse", "icon16/arrow_undo.png")
AddEntFireProperty("rb655_func_tracktrain_Stop", "Stop", 658, "func_tracktrain", "Stop", "icon16/shape_square.png")
AddEntFireProperty("rb655_func_tracktrain_Resume", "Resume", 659, "func_tracktrain", "Resume", "icon16/resultset_next.png")
AddEntFireProperty("rb655_func_tracktrain_Toggle", "Toggle", 660, "func_tracktrain", "Toggle", ToggleIcon)

AddEntFireProperty("rb655_breakable_break", "Break", 655, {"func_breakable", "func_physbox", "prop_physics"}, "Break", ExplodeIcon) -- Do not iclude item_item_crate, it's insta server crash, dunno why.

AddEntFireProperty("rb655_turret_toggle", "Toggle", 655, {"npc_combine_camera", "npc_turret_ceiling", "npc_turret_floor"}, "Toggle", ToggleIcon)
AddEntFireProperty("rb655_turret_ammo_remove", "Deplete Ammo", 656, "npc_turret_floor", "DepleteAmmo", "icon16/delete.png")
AddEntFireProperty("rb655_turret_ammo_restore", "Restore Ammo", 657, "npc_turret_floor", "RestoreAmmo", "icon16/add.png")
AddEntFireProperty("rb655_self_destruct", "Self Destruct", 658, {"npc_turret_floor", "npc_helicopter"}, "SelfDestruct", ExplodeIcon)
AddEntFunctionProperty("rb655_turret_make_friendly", "Make Friendly", 659, function( ent )
	if ( ent:GetNWBool("TurretIsFriendly", false) ) then return false end
	if ( ent:GetClass() == "npc_turret_floor" ) then return true end
	return false
end, function(ent)
	ent:SetKeyValue("spawnflags", SF_FLOOR_TURRET_CITIZEN)
	ent:Activate()
	
	ent:SetNWBool("TurretIsFriendly", true)
end, "icon16/user_green.png")

AddEntFireProperty("rb655_suitcharger_recharge", "Recharge", 655, "item_suitcharger", "Recharge", "icon16/arrow_refresh.png")

AddEntFireProperty("rb655_manhack_jam", "Jam", 655, "npc_manhack", "InteractivePowerDown", ExplodeIcon)

AddEntFireProperty("rb655_scanner_mineadd", "Equip Mine", 655, "npc_clawscanner", "EquipMine", "icon16/add.png")
AddEntFireProperty("rb655_scanner_minedeploy", "Deploy Mine", 656, "npc_clawscanner", "DeployMine", "icon16/arrow_down.png")
AddEntFireProperty("rb655_scanner_disable_spotlight", "Disable Spotlight", 658, {"npc_clawscanner", "npc_cscanner"}, "DisableSpotlight", DisableIcon)
--AddEntFireProperty("rb655_scanner_d1", "1", 655, "npc_combinedropship", "DropMines 1", DisableIcon)

AddEntFireProperty("rb655_rollermine_selfdestruct", "Self Destruct", 655, "npc_rollermine", "InteractivePowerDown", ExplodeIcon)
AddEntFireProperty("rb655_rollermine_turnoff", "Turn Off", 656, "npc_rollermine", "TurnOff", DisableIcon)
AddEntFireProperty("rb655_rollermine_turnon", "Turn On", 657, "npc_rollermine", "TurnOn", EnableIcon)

AddEntFireProperty("rb655_helicopter_gun_on", "Enable Turret", 655, "npc_helicopter", "GunOn", EnableIcon)
AddEntFireProperty("rb655_helicopter_gun_off", "Disable Turret", 656, "npc_helicopter", "GunOff", DisableIcon)
AddEntFireProperty("rb655_helicopter_dropbomb", "Drop Bomb", 657, "npc_helicopter", "DropBomb", "icon16/arrow_down.png")
AddEntFireProperty("rb655_helicopter_norm_shoot", "Start Normal Shooting", 658, "npc_helicopter", "StartNormalShooting", "icon16/clock.png")
AddEntFireProperty("rb655_helicopter_long_shoot", "Start Long Cycle Shooting", 659, "npc_helicopter", "StartLongCycleShooting", "icon16/clock_red.png")
AddEntFireProperty("rb655_helicopter_deadly_on", "Enable Deadly Shooting", 660, "npc_helicopter", "EnableDeadlyShooting", EnableIcon)
AddEntFireProperty("rb655_helicopter_deadly_off", "Disable Deadly Shooting", 661, "npc_helicopter", "DisableDeadlyShooting", DisableIcon)

AddEntFireProperty("rb655_gunship_OmniscientOn", "Enable Omniscient", 655, "npc_combinegunship", "OmniscientOn", EnableIcon)
AddEntFireProperty("rb655_gunship_OmniscientOff", "Disable Omniscient", 656, "npc_combinegunship", "OmniscientOff", DisableIcon)
AddEntFireProperty("rb655_gunship_BlindfireOn", "Enable Blindfire", 657, "npc_combinegunship", "BlindfireOn", EnableIcon)
AddEntFireProperty("rb655_gunship_BlindfireOff", "Disable Blindfire", 658, "npc_combinegunship", "BlindfireOff", DisableIcon)

AddEntFireProperty("rb655_alyx_HolsterWeapon", "Holster Weapon", 655, "npc_alyx", "HolsterWeapon", "icon16/gun.png")
AddEntFireProperty("rb655_alyx_UnholsterWeapon", "Unholster Weapon", 656, "npc_alyx", "UnholsterWeapon", "icon16/gun.png")
AddEntFireProperty("rb655_alyx_HolsterAndDestroyWeapon", "Holster And Destroy Weapon", 657, "npc_alyx", "HolsterAndDestroyWeapon", "icon16/gun.png")

AddEntFireProperty("rb655_antlion_burrow", "Burrow", 655, {"npc_antlion" , "npc_antlion_worker"}, "BurrowAway", "icon16/arrow_down.png")
AddEntFireProperty("rb655_barnacle_free", "Free Target", 655, "npc_barnacle", "LetGo", "icon16/heart.png")

AddEntFireProperty("rb655_zombine_suicide", "Suicide", 655, "npc_zombine", "PullGrenade", ExplodeIcon)
AddEntFireProperty("rb655_zombine_sprint", "Sprint", 656, "npc_zombine", "StartSprint", "icon16/flag_blue.png")

AddEntFireProperty("rb655_thumper_enable", "Enable", 655, "prop_thumper", "Enable", EnableIcon)
AddEntFireProperty("rb655_thumper_disable", "Disable", 656, "prop_thumper", "Disable", DisableIcon)

AddEntFireProperty("rb655_dog_fetch_on", "Start Playing Fetch", 655, "npc_dog", "StartCatchThrowBehavior", "icon16/accept.png")
AddEntFireProperty("rb655_dog_fetch_off", "Stop Playing Fetch", 656, "npc_dog", "StopCatchThrowBehavior", "icon16/cancel.png")

AddEntFireProperty("rb655_soldier_look_off", "Enable Blindness", 655, "npc_combine_s", "LookOff", "icon16/user_green.png")
AddEntFireProperty("rb655_soldier_look_on", "Disable Blindness", 656, "npc_combine_s", "LookOn", "icon16/user_gray.png")

AddEntFireProperty("rb655_citizen_wep_pick_on", "Permit Weapon Pickup", 655, "npc_citizen", "EnableWeaponPickup", EnableIcon)
AddEntFireProperty("rb655_citizen_wep_pick_off", "Restrict Weapon Pickup", 656, "npc_citizen", "DisableWeaponPickup", DisableIcon)
AddEntFireProperty("rb655_citizen_panic", "Start Panicking", 658, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessPanic", "icon16/flag_red.png")
AddEntFireProperty("rb655_citizen_panic_off", "Stop Panicking", 659, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessHigh", "icon16/flag_green.png")

AddEntFireProperty("rb655_camera_angry", "Make Angry", 656, "npc_combine_camera", "SetAngry", "icon16/flag_red.png")
AddEntFireProperty("rb655_combine_mine_disarm", "Disarm", 655, "combine_mine", "Disarm", "icon16/wrench.png")

AddEntFireProperty("rb655_hunter_enable", "Enable Shooting", 655, "npc_hunter", "EnableShooting", EnableIcon)
AddEntFireProperty("rb655_hunter_disable", "Disable Shooting", 656, "npc_hunter", "DisableShooting", DisableIcon)

AddEntFireProperty("rb655_vortigaunt_enable", "Enable Armor Recharge", 655, "npc_vortigaunt", "EnableArmorRecharge", EnableIcon)
AddEntFireProperty("rb655_vortigaunt_disable", "Disable Armor Recharge", 656, "npc_vortigaunt", "DisableArmorRecharge", DisableIcon)

AddEntFireProperty("rb655_antlion_enable", "Enable Jump", 655, {"npc_antlion", "npc_antlion_worker"}, "EnableJump", EnableIcon)
AddEntFireProperty("rb655_antlion_disable", "Disable Jump", 656, {"npc_antlion", "npc_antlion_worker"}, "DisableJump", DisableIcon)
AddEntFireProperty("rb655_antlion_hear", "Hear Bugbait", 657, {"npc_antlion", "npc_antlion_worker"}, "HearBugbait", EnableIcon)
AddEntFireProperty("rb655_antlion_ignore", "Ignore Bugbait", 658, {"npc_antlion", "npc_antlion_worker"}, "IgnoreBugbait", DisableIcon)

AddEntFireProperty("rb655_antlion_grub_squash", "Squash", 655, "npc_antlion_grub", "Squash", "icon16/bug.png")

AddEntFireProperty("rb655_antlionguard_bark_on", "Enable Antlion Summon", 655, "npc_antlionguard", "EnableBark", EnableIcon)
AddEntFireProperty("rb655_antlionguard_bark_off", "Disable Antlion Summon", 656, "npc_antlionguard", "DisableBark", DisableIcon)

AddEntFireProperty("rb655_headcrab_burrow", "Burrow", 655, "npc_headcrab", "BurrowImmediate", "icon16/arrow_down.png")

AddEntFireProperty( "rb655_strider_stand", "Force Stand", 655, "npc_strider", "Stand", "icon16/arrow_up.png" )
AddEntFireProperty( "rb655_strider_crouch", "Force Crouch", 656, "npc_strider", "Crouch", "icon16/arrow_down.png" )
AddEntFireProperty( "rb655_strider_break", "Destroy", 657, { "npc_strider", "npc_clawscanner", "npc_cscanner" }, "Break", ExplodeIcon )

-- This just doesn't do anything
AddEntFireProperty( "rb655_patrol_on", "Start Patrolling", 660, { "npc_citizen", "npc_combine_s" }, "StartPatrolling", "icon16/flag_green.png" )
AddEntFireProperty( "rb655_patrol_off", "Stop Patrolling", 661, { "npc_citizen", "npc_combine_s" }, "StopPatrolling", "icon16/flag_red.png" )

-- Strider forgets how to shoot if we use these.
--AddEntFireProperty( "rb655_strider_aggressive_e", "Make More Aggressive", 658, "npc_strider", "EnableAggressiveBehavior", EnableIcon )
--AddEntFireProperty( "rb655_strider_aggressive_d", "Make Less Aggressive", 659, "npc_strider", "DisableAggressiveBehavior", DisableIcon )

AddEntFunctionProperty( "rb655_healthcharger_recharge", "Recharge", 655, "item_healthcharger", function( ent )
	local n = ents.Create( "item_healthcharger" )
	n:SetPos( ent:GetPos() )
	n:SetAngles( ent:GetAngles() )
	n:Spawn()
	n:Activate()
	n:EmitSound( "items/suitchargeok1.wav" )

	undo.ReplaceEntity( ent, n )
	cleanup.ReplaceEntity( ent, n )

	ent:Remove()
end, "icon16/arrow_refresh.png" )

local passive = {
	"npc_seagull", "npc_crow", "npc_piegon",
	"npc_cscanner", "npc_clawscanner", "npc_turret_floor",
	"npc_dog", "npc_gman", "npc_antlion_grub",
	"npc_stalker" -- Don't want to attack me :(
	// "npc_kleiner", "npc_eli", "npc_magnusson", "npc_fisherman", "npc_mossman", "npc_breen" -- They can use anabelle :O
}

local friendly = {
	"npc_monk", "npc_alyx", "npc_barney", "npc_citizen",
	"npc_cscanner", "npc_clawscanner", "npc_turret_floor",
	"npc_dog", "npc_vortigaunt", "npc_kleiner", "npc_eli",
	"npc_magnusson", "npc_fisherman", "npc_mossman",
	"monster_barney", "monster_scientist", "player"
}

local hostile = {
	"npc_combine_scanner", "npc_turret_ceiling", "npc_combine_s", "npc_combine_gunship", "npc_combine_dropship",
	"npc_cscanner", "npc_clawscanner", "npc_turret_floor", "npc_helicopter", "npc_hunter", "npc_manhack",
	"npc_stalker", "npc_rollermine", "npc_strider", "npc_metropolice",
	
	"monster_human_assassin", "monster_human_grunt"
}

local monsters = {
	"npc_antlion", "npc_antlionguard", "npc_barnacle", "npc_fastzombie", "npc_fastzombie_torso",
	"npc_headcrab", "npc_headcrab_fast", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine",
	"monster_alien_grunt", "monster_alienslave", "monster_babycrab", "monster_headcrab", "monster_bigmomma", "npc_bullchicken",
	"monster_alien_controller","monster_gargantua", "monster_nihilanth", "monster_snark", "monster_zombie", "monster_tentacle"
}

AddEntFunctionProperty( "rb655_make_friendly", "Make Friendly", 652, function( ent )
	if (ent:IsNPC() && !table.HasValue( passive, ent:GetClass() ) ) then return true end
	return false
end, function( ent )
	for id, class in pairs( friendly ) do ent:AddRelationship( class .. " D_LI 999" ) end
	for id, class in pairs( monsters ) do ent:AddRelationship( class .. " D_HT 999" ) end
	for id, class in pairs( hostile ) do ent:AddRelationship( class .. " D_HT 999" ) end
end, "icon16/user_green.png" )

AddEntFunctionProperty( "rb655_make_hostile", "Make Hostile", 653, function( ent )
	if ( ent:IsNPC() && !table.HasValue( passive, ent:GetClass() ) ) then return true end
	return false
end, function( ent )
	for id, class in pairs( hostile ) do ent:AddRelationship( class .. " D_LI 999" ) end
	for id, class in pairs( monsters ) do ent:AddRelationship( class .. " D_HT 999" ) end
	for id, class in pairs( friendly ) do ent:AddRelationship( class .. " D_HT 999" ) end
end, "icon16/user_red.png" )

-- Vehicles
AddEntFunctionProperty( "rb655_vehicle_exit", "Kick Driver", 655, function( ent )
	if ( ent:IsVehicle() ) then return true end
	return false
end, function( ent )
	if ( !IsValid( ent:GetDriver() ) ) then return end
	ent:GetDriver():ExitVehicle()
end, "icon16/car.png" )

AddEntFunctionProperty( "rb655_vehicle_enter", "Enter Vehicle", 656, function( ent )
	if ( ent:IsVehicle() ) then return true end
	return false
end, function( ent, ply )
	ply:EnterVehicle( ent )
end, "icon16/car.png" )

AddEntFunctionProperty( "rb655_vehicle_add_gun", "Mount Gun", 657, function( ent )
	if ( !ent:IsVehicle() ) then return false end
	if ( ent:GetNWBool( "EnableGun", false ) ) then return false end
	if ( ent:GetBodygroup( 1 ) == 1 ) then return false end
	if ( ent:LookupSequence( "aim_all" ) > 0 ) then return true end
	if ( ent:LookupSequence( "weapon_yaw" ) > 0 && ent:LookupSequence( "weapon_pitch" ) > 0 ) then return true end
	return false
end, function( ent )
	ent:SetKeyValue( "EnableGun", "1" )
	ent:Activate()
	
	ent:SetBodygroup( 1, 1 )
	
	ent:SetNWBool( "EnableGun", true )
end, "icon16/gun.png" )

-- Garry's Mod Specific
AddEntFunctionProperty( "rb655_baloon_break", "Pop", 655, "gmod_balloon", function( ent, ply )
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker( ply )

	ent:OnTakeDamage( dmginfo )
end, ExplodeIcon )

AddEntFunctionProperty( "rb655_dynamite_activate", "Explode", 655, "gmod_dynamite", function( ent, ply )
	ent:Explode( 0, ply )
end, ExplodeIcon )

-- Emitter
AddEntFunctionProperty( "rb655_emitter_on", "Start Emitting", 655, function( ent )
	if ( ent:GetClass() == "gmod_emitter" && !ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:SetOn( true )
end, EnableIcon )

AddEntFunctionProperty( "rb655_emitter_off", "Stop Emitting", 656, function( ent )
	if ( ent:GetClass() == "gmod_emitter" && ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:SetOn( false )
end, DisableIcon )

-- Lamps
AddEntFunctionProperty( "rb655_lamp_on", "Enable", 655, function( ent )
	if ( ent:GetClass() == "gmod_lamp" && !ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:Switch( true )
end, EnableIcon )

AddEntFunctionProperty( "rb655_lamp_off", "Disable", 656, function( ent )
	if ( ent:GetClass() == "gmod_lamp" && ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:Switch( false )
end, DisableIcon )

-- Light
AddEntFunctionProperty( "rb655_light_on", "Enable", 655, function( ent )
	if ( ent:GetClass() == "gmod_light" && !ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:SetOn( true )
end, EnableIcon )

AddEntFunctionProperty( "rb655_light_off", "Disable", 656, function( ent )
	if ( ent:GetClass() == "gmod_light" && ent:GetOn() ) then return true end
	return false
end, function( ent, ply )
	ent:SetOn( false )
end, DisableIcon )

-- No thruster, it is glitchy
