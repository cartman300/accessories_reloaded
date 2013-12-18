--[[-------------------------------------------------------------------------------------------------------------------------
	Serverside magic box code
-------------------------------------------------------------------------------------------------------------------------]]--

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

--[[-------------------------------------------------------------------------------------------------------------------------
	Spawn function
-------------------------------------------------------------------------------------------------------------------------]]--

function ENT:SpawnFunction( ply, tr )
	if ( !tr.HitWorld ) then return false end
	
	local ent = ents.Create( "magicbox" )
	ent:SetPos( tr.HitPos + Vector( 0, 0, 41 ) )
	ent:Spawn()
	ent:SetAngles( Angle( 0, 180, -90 ) )
	
	return ent
end

--[[-------------------------------------------------------------------------------------------------------------------------
	Initialization
-------------------------------------------------------------------------------------------------------------------------]]--

function ENT:Initialize()
	self:SetModel( "models/props_junk/wood_crate002a.mdl" )
	
	self:PhysicsInitBox( Vector( -20.3231, -34.4971, -20.2868 ) * 1.2, Vector( 20.3128, 34.2730, 20.1908 ) * 1.2 )
	self:SetCollisionBounds( Vector( -20.3231, -20.2868, -34.4971 ) * 1.2, Vector( 20.3128, 20.1908, 34.2730 ) * 1.2 )
	
	self:GetPhysicsObject():EnableMotion( false )
end

--[[-------------------------------------------------------------------------------------------------------------------------
	Teleporting
-------------------------------------------------------------------------------------------------------------------------]]--

function ENT:Touch( ent )
	local off = ( ent:GetPos() - self:GetPos() )
	local y = off:Angle().y
	
	if ( ent:IsPlayer() and y >= 265 and y <= 275 ) then
		ent:SetPos( self:GetNWVector( "WorldPos" ) + Vector( 160 + off.x, -38, 20 )  )
	end
end

--[[-------------------------------------------------------------------------------------------------------------------------
	Clean up
-------------------------------------------------------------------------------------------------------------------------]]--

function ENT:OnRemove()
	for _, ent in pairs( self.WorldEnts ) do
		if ( ent:IsValid() ) then ent:Remove() end
	end
	self.Exit:Remove()
end