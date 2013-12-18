AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/missile/missile3.mdl" )
	self.Entity:SetName("Missile")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetOn( 3 )
	
	util.PrecacheSound("ambient/explosions/explode_1.wav")

	local phys = self.Entity:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(false)
	end

    self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.STime = CurTime()
	self.LTime = self.STime + self.ParL.LTime
	self.CurAngles = self.Entity:GetAngles()
	self.Entity:EmitSound("weapons/rpg/rocketfire1.wav", 70, 90)
	self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)
end

function ENT:Explosion()
			self.Entity:StopSound( "Missile.Accelerate" )
			local expl=ents.Create("env_explosion") -- The "Boom" Part
			expl:SetPos(self.Entity:GetPos())
			expl:SetName("Missile")
			expl:SetParent(self.Entity)
			expl:SetOwner(self.Entity:GetOwner())
			expl:SetKeyValue("iMagnitude", 300)
			expl:SetKeyValue("iRadiusOverride", 1000)
			expl:SetKeyValue("spawnflags", 64)
			expl:Spawn()
			expl:Activate()
			expl:Fire("explode", "", 0)
			expl:Fire("kill","",0)
			self.Exploded = true
			
			local effectdata = EffectData()
				effectdata:SetOrigin( self.Entity:GetPos() )
				effectdata:SetMagnitude(20)
				effectdata:SetScale(1)
			util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame
			util.Effect( "blastwave_missile", effectdata )	 -- self made effect 
			
			-- util.PrecacheSound("ambient/explosions/explode_9.wav")
			-- self.Entity:EmitSound("ambient/explosions/explode_9.wav", 100, 100)
			
			local Ambient = ents.Create("ambient_generic")
			Ambient:SetPos(self.Entity:GetPos())
			Ambient:SetKeyValue("message", "ambient/explosions/explode_8.wav")
			Ambient:SetKeyValue("health", 10)
			Ambient:SetKeyValue("preset", 0)
			Ambient:SetKeyValue("radius", 10000)
			Ambient:Spawn()
			Ambient:Activate()
			Ambient:Fire("PlaySound", "", 0)
			Ambient:Fire("kill", "", 4)
			
	        self.shakeeffect = ents.Create("env_shake") -- Shake from the explosion
	        self.shakeeffect:SetKeyValue("amplitude", 16)
	        self.shakeeffect:SetKeyValue("spawnflags", 4 + 8 + 16)
	        self.shakeeffect:SetKeyValue("frequency", 200.0)
	        self.shakeeffect:SetKeyValue("duration", 2)
			self.shakeeffect:SetKeyValue("radius", 2000)
	        self.shakeeffect:SetPos(self.Entity:GetPos())
	        self.shakeeffect:Fire("StartShake","",0)
	        self.shakeeffect:Fire("Kill","",4)
			
			self.splasheffect = ents.Create("env_splash")
			self.splasheffect:SetKeyValue("scale", 500)
			self.splasheffect:SetKeyValue("spawnflags", 2)
			
			self.light = ents.Create("light")
			self.light:SetKeyValue("_light", 255 + 255 + 255)
			self.light:SetKeyValue("style", 0)
			
			local physExplo = ents.Create( "env_physexplosion" )
		  	physExplo:SetOwner( self.Owner )
	       	physExplo:SetPos( self.Entity:GetPos() )
	        physExplo:SetKeyValue( "Magnitude", 300 )	-- Power of the Physicsexplosion
	        physExplo:SetKeyValue( "radius", 700 )	-- Radius of the explosion
	        physExplo:SetKeyValue( "spawnflags", 2 + 16 )
	        physExplo:Spawn()
	        physExplo:Fire( "Explode", "", 0 )
	        physExplo:Fire( "Kill", "", 0 )

			for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 350 ) ) do
				if not (v:IsPlayer()) then
					--v:Ignite( 10, 0 )
				end
			end
end


function ENT:PhysicsUpdate()

	if(self.Exploded) then
		self.Entity:Remove()
		return
	end

	if(CurTime() < self.STime + 15 && self:IsOn() == 1) then
		local vectorMoved = self.Entity:GetPos() - self.LastPosition

		if (self.Locked == true) then
			self.Target = Vector(self.XCo, self.YCo, self.ZCo)
			local AimVec = ( self.Target - self.LastPosition ):Angle()
			local Dist = math.min((self.Target - self.LastPosition):Length(), 5000)
			local Mod = math.abs(Dist - 5000)/3000
			
			self.CurAngles.p = math.ApproachAngle( self.CurAngles.p, AimVec.p, 2 + Mod )
			self.CurAngles.r = math.ApproachAngle( self.CurAngles.r, AimVec.r, 2 + Mod )
			self.CurAngles.y = math.ApproachAngle( self.CurAngles.y, AimVec.y, 2 + Mod )
			self.Entity:SetAngles( self.CurAngles )
			
			if (Dist < 200) and !self.Missed then
				timer.Simple(math.Rand(0.3, 0.5), function() 
					if self.Entity != nil then
						local phys = self.Entity:GetPhysicsObject()
						phys:EnableGravity(true)
						self.Locked = false
					end
				end)
				
				self.Missed = true
			end
		end
	
		self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)
		self.LastPosition = self.Entity:GetPos()
	else
		local phys = self.Entity:GetPhysicsObject()
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		self:SetOn( 2 )
		self.Entity:StopSound( "Missile.Accelerate" )
	end

	if (self.Missed) then
		--self.PhysObj:ApplyForceCenter(self.Entity:GetForward()*30000)
		self.PhysObj:AddAngleVelocity(Angle(math.Rand(-5,5), math.Rand(-5,5), math.Rand(-1,5))) 
	end
end

function ENT:Think()
	if CurTime() > self.STime + 0.01 then
		local phys = self.Entity:GetPhysicsObject()
		phys:EnableCollisions(true)
	end
	
	if not (self.PreLaunch) and self:IsOn() == 1 then
		
		self.LastPosition = self.Entity:GetPos()
		self.Entity:EmitSound("Missile.Accelerate", 500, 70)
		local phys = self.Entity:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:Wake()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:EnableCollisions(true)
			phys:EnableMotion(true)
		end
		self.Entity:SetOwner(self.Entity.ParL)
		timer.Simple(1, function() self.Entity:SetOwner(self.Entity.ParL) end)
		
		local Ang = self.Entity:GetAngles()
		local Pos = self.Entity:GetPos() + (Ang:Up() * 9)
		local AngVec = self.Entity:GetAngles():Forward()
		local Offset = -85
	
		self.PreLaunch = true
	end

	self.XCo = self.ParL.XCo
	self.YCo = self.ParL.YCo
	self.ZCo = self.ParL.ZCo
	
	if (self.ParL.Locked == true) then
		self.Locked = true
	end
	if (CurTime() > self.LTime && !self.Missed) then
		self.Locked = true
	end
	
	if !self.PreLaunch then
		self:SetOn( 3 )
	end
	
	if CurTime() > self.STime + 0.5 && !self.PreLaunch then
		self:SetOn( 1 )
	end
	
end

function ENT:HitEffect()
end

function ENT:PhysicsCollide( data, physobj )
	if (CurTime() > self.STime + 0.1) then
		if(!self.Exploded) then
			self:Explosion()
		end
	end
end

function ENT:OnTakeDamage(dmg)

	if(!self.Exploded && dmg:GetDamage() > 10) then
		self:Explosion()
	end
end

function ENT:Use( activator, caller )

	
end