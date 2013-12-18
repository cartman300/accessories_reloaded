--[[-------------------------------------------------------------------------------------------------------------------------
	Magic Box entity information
-------------------------------------------------------------------------------------------------------------------------]]--

ENT.Type					= "anim"
ENT.Base					= "base_gmodentity"

ENT.PrintName				= "Magic Box"
ENT.Author					= "Overv"
ENT.Contact				= "overv161@gmail.com"
ENT.Purpose				= "Remake of Mahalis' magic box."
ENT.Instructions			= "Use with care. Contains volatile amounts of awesome and win."

ENT.Spawnable			= true
ENT.AdminSpawnable	= true

--[[-------------------------------------------------------------------------------------------------------------------------
	Collision trick
-------------------------------------------------------------------------------------------------------------------------]]--

hook.Add( "ShouldCollide", "MagicBoxEntranceCollision", function( ent1, ent2 )
	if ( ent1:IsPlayer() and ent2:GetClass() == "magicbox" ) then
		return ent1:GetVelocity():Angle().y > 70 and ent1:GetVelocity():Angle().y < 100
	elseif ( ent2:IsPlayer() and ent1:GetClass() == "magicbox" ) then
		return ent2:GetVelocity():Angle().y > 70 and ent2:GetVelocity():Angle().y < 100
	end
end )

--[[-------------------------------------------------------------------------------------------------------------------------
	Physgunning
-------------------------------------------------------------------------------------------------------------------------]]--

hook.Add( "PhysgunPickup", "MagicNoPickup", function( ply, ent )
	if ( ent:GetClass():Left( 8 ) == "magicbox" or ( ent:GetOwner():IsValid() and ent:GetOwner():GetClass():Left( 8 ) == "magicbox" ) ) then return false end
end )