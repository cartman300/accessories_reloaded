AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel( "models/props_phx/box_torpedo.mdl" ) 
	self.Entity:SetName("Missile Launcher (WIRED)")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Inputs = Wire_CreateInputs( self.Entity, { "Vec [VECTOR]", "Launch", "Lock", "LockTime"} )

	local phys = self.Entity:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

    	self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "agate_missle_launcher" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent:SetVar("Owner", Ply)
	
	return ent
	
end

function ENT:TriggerInput(iname, value)
	if (iname == "X") then
		self.XCo = value

	elseif (iname == "Y") then
		self.YCo = value

	elseif (iname == "Z") then
		self.ZCo = value
		
	elseif iname == "Vec" then
		self.XCo = value.x
		self.YCo = value.y
		self.ZCo = value.z

	elseif (iname == "Launch") then
		if (value > 0) then
			if (self.Launched == 0) then
				self.Launched = 1
			end
		elseif (value <= 0) then
			self.Launched = 0
		end

	elseif (iname == "Lock") then
		if (value > 0) then
			self.Locked = true
		else
			self.Locked = false
		end

	elseif (iname == "LockTime") then
		if (value > 0) then
			self.LTime = value
		else
			self.LTime = 1000000
		end
	end
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if (self.Launched == 1) then
		local NewRock = ents.Create( "agate_missle_launched" )
		if ( !IsValid(NewRock) ) then return end
		NewRock:SetPos( self.Entity:GetPos() + (self.Entity:GetForward() * 30) + (self.Entity:GetUp() * 5) )
		NewRock:SetModel( "models/missile/missile3.mdl" )
		NewRock:SetAngles( self.Entity:GetAngles() )
		NewRock.ParL = self.Entity
		NewRock:SetVar("Owner", Ply)
		NewRock:Spawn()
		NewRock:Initialize()
		NewRock:Activate()

		self.Launched = 2
	end
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:Use( activator, caller )

end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
		
	duplicator.StoreEntityModifier(self, "AGateLauncher", dupeInfo)
end
duplicator.RegisterEntityModifier( "AGateLauncher" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	
	local dupeInfo = Ent.EntityMods.AGateLauncher

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.AGateLauncher.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AGateLauncher.WireData, function(id) return CreatedEntities[id] end)
	end

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then phys:EnableGravity(false) end

	self.Owner = ply;
end