ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.Pack = "CAltP"
ENT.Category = ENT.Pack
ENT.PrintName		= "Missile"
ENT.Author			= "thebigalex, Cartman300"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false
ENT.follow			= nil
ENT.Owner			= nil
ENT.Exploded			= false
ENT.FuelAmount			= 1000000
ENT.LastPosition		= Vector(0,0,0)
ENT.XCo				= nil
ENT.YCo				= nil
ENT.ZCo				= nil
ENT.Launched			= false
ENT.Armed			= false
ENT.Target			= Vector(0,0,0)
ENT.PhysObj			= nil
ENT.Locked			= false
ENT.PreLaunch			= false
ENT.Warhead			= "exp_head"
ENT.WHConfig			= true

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self.Entity:SetModel( "models/missile/missile3.mdl" )
		self.Entity:SetName("Missile")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Inputs = Wire_CreateInputs( self.Entity, { "Vec [VECTOR]", "Launch", "Arm", "Lock", "Detonate", "Abort"} )

		util.PrecacheSound("ambient/explosions/explode_1.wav")
		util.PrecacheSound("weapons/rpg/rocketfire1.wav")
		
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
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
		
		local ent = ents.Create( "agate_missle" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		ent:SetVar("Owner", ply)
		
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
				if self.Sndd == nil then
					self.Entity:EmitSound("weapons/rpg/rocketfire1.wav", 70, 90)
					self.Sndd = "Done"
					self.Launched = true
				end
			end

		elseif (iname == "Arm") then
			if (value > 0) then
				self.Armed = true
			else
				self.Armed = false
			end
		
		elseif (iname == "Lock") then
			if (value > 0) then
				self.Locked = true
			else
				self.Locked = false
			end
		
		elseif (iname == "Detonate") then
			if (value > 0) then
				self:Explode()
				/*
				local WHead = ents.Create( self.Warhead )
				WHead:SetPos( self.Entity:GetPos() )
				WHead:SetOwner( self.Entity:GetOwner() )
				WHead:Spawn()
				WHead:Activate()
				*/
				self.Exploded = true
			end

		elseif (iname == "Abort") then
			if (value > 0) then
				self.Entity:StopSound("weapons/rpg/rocketfire1.wav")
				self.Sndd = nil
				self.Launched = false
				local phys = self.Entity:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:Wake()
					phys:EnableGravity(true)
					phys:EnableDrag(true)
				end
				self.FieryTrial:Remove()
			end
		end
	end

	function ENT:Explode()
		if self.Bmd == nil then
				self.Entity:EmitSound("ambient/explosions/explode_1.wav", 70, 90)
			--self.Entity:StopSound( "Missile.Accelerate" )
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

			self.Bmd = "Fuck off"
		end
	end

	function ENT:PhysicsUpdate()

		if(self.Exploded) then
			self.Entity:Remove()
			return
		end

		if (self.Launched == true) then
		
			if(self.FuelAmount > 0) then

				local vectorMoved = self.Entity:GetPos() - self.LastPosition
				local amountMoved = vectorMoved:Length()
				self.FuelAmount = self.FuelAmount - amountMoved	

				if(self.FuelAmount < 0) then
					local phys = self.Entity:GetPhysicsObject()
					phys:EnableGravity(true)
					phys:EnableDrag(true)
				end

				self.LastPosition = self.Entity:GetPos()
			end

			if (self.Locked == true) then
				self.Target = Vector(self.XCo, self.YCo, self.ZCo)
				AimVec = ( self.Target - self.LastPosition ):Angle()
				self.Entity:SetAngles( AimVec )
			end
			
			self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

		end
	end

	function ENT:Think()
		
		if(self.Exploded) then
			self.Entity:Remove()
			return
		end
		
		if (self.Launched == true) then
			if (self.PreLaunch == false) then
				self.PreLaunch = true
				local phys = self.Entity:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:Wake()
					phys:EnableGravity(false)
					phys:EnableDrag(false)
					phys:EnableCollisions(true)
					phys:EnableMotion(true)
				end

				local FieryTrailOfPainfullDoomAndDestruction = ents.Create("env_fire_trail")

				self.LastPosition = self.Entity:GetPos()

				FieryTrailOfPainfullDoomAndDestruction:SetAngles( self.Entity:GetAngles()  )
				FieryTrailOfPainfullDoomAndDestruction:SetPos( self.Entity:GetPos() - (self.Entity:GetForward() * -30) )

				FieryTrailOfPainfullDoomAndDestruction:SetParent(self.Entity)
				FieryTrailOfPainfullDoomAndDestruction:Spawn()
				FieryTrailOfPainfullDoomAndDestruction:Activate()
				self.FieryTrial = FieryTrailOfPainfullDoomAndDestruction
				self.PhysObj:SetVelocity(self.Entity:GetForward()*3100)

			local SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction = ents.Create("env_smoketrail") //Sorry, I coulden't resist.
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("startsize","8")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("endsize","18")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("minspeed","1")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("maxspeed","2")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("startcolor","40 40 40")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("endcolor","40 40 40")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("opacity",".3")
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("spawnrate","60")  //Makes smoke thick.
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetKeyValue("lifetime","0.2")  //We don't want the smoke to be there for a long time.
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetPos(self.Entity:GetPos())
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:Spawn()
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:Fire("kill","",10)
			SmokeyTrailofThickBlackSmokefromFieryTrailOfPainfullDoomAndDestruction:SetParent(self.Entity)	

			local smoke = ents.Create("env_smoketrail") //Lesser smoke, not as thick and as black.
			smoke:SetKeyValue("startsize","30")
			smoke:SetKeyValue("endsize","60")
			smoke:SetKeyValue("minspeed","10")
			smoke:SetKeyValue("startcolor","255 255 255")
			smoke:SetKeyValue("endcolor","0 0 0")
			smoke:SetKeyValue("opacity","5")
			smoke:SetKeyValue("spawnrate","60")
			smoke:SetKeyValue("lifetime","7")
			smoke:SetPos(self.Entity:GetPos())
			smoke:Spawn()
			smoke:Fire("kill","",10)
			smoke:SetParent(self.Entity)

			local light = ents.Create("env_lightglow") //Nice little glow from the rocket flame
			light:SetPos(self.Entity:GetPos())
			light:SetKeyValue("targetname", "moo")
			light:SetKeyValue("rendercolor", "255 255 255")
			light:SetKeyValue("VerticalGlowSize", "12")
			light:SetKeyValue("HorizontalGlowSize", "12")
			light:Spawn()
			light:SetParent(self.Entity)
				

				self.PreLaunch = true
			end
		end
	end

	function ENT:PhysicsCollide( data, physobj )
		
		if (self.Armed == true) then
			if(!self.Exploded) then
				self:Explode()
				/*
				local WHead = ents.Create( self.Warhead )
				WHead:SetPos( self.Entity:GetPos() )
				WHead:SetOwner( self.Entity:GetOwner() )
				WHead:Spawn()
				WHead:Activate()
				*/
				self.Exploded = true
			end
		end
	end

	function ENT:OnTakeDamage( dmginfo )

		if (self.Armed == true) then
			if(!self.Exploded) then
				local expl=ents.Create("env_explosion")
				expl:SetPos(self.Entity:GetPos())
				expl:SetName("Missile")
				expl:SetParent(self.Entity)
				expl:SetOwner(self.Entity:GetOwner())
				expl:SetKeyValue("iMagnitude","300");
				expl:SetKeyValue("iRadiusOverride", 250)
				expl:Spawn()
				expl:Activate()
				expl:Fire("explode", "", 0)
				expl:Fire("kill","",0)
				self.Exploded = true


			local effectdata = EffectData() -- Credits to Pac_187 for the Effect(s)
			effectdata:SetOrigin( self.Entity:GetPos() )
			util.Effect( "Explosion", effectdata )			 -- Explosion effect
			util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame
			util.Effect( "Rocket_Explosion", effectdata )	 -- self made effect 

					self.shakeeffect = ents.Create("env_shake") -- Shake from the explosion
					self.shakeeffect:SetKeyValue("amplitude","16")
					self.shakeeffect:SetKeyValue("spawnflags","29")
					self.shakeeffect:SetKeyValue("frequency","200.0")
					self.shakeeffect:SetKeyValue("duration","2")
					self.shakeeffect:SetPos(self.Entity:GetPos())
					self.shakeeffect:Fire("StartShake","",0)
					self.shakeeffect:Fire("Kill","",4)

					local ar2Explo = ents.Create( "env_ar2explosion" )
					ar2Explo:SetOwner( self.Owner )
					ar2Explo:SetPos( self.Entity:GetPos() )
					ar2Explo:Spawn()
					ar2Explo:Activate()
					ar2Explo:Fire( "Explode", "", 0 )

						local physExplo = ents.Create( "env_physexplosion" )
						physExplo:SetOwner( self.Owner )
							physExplo:SetPos( self.Entity:GetPos() )
							physExplo:SetKeyValue( "Magnitude", "300" ) -- Power of the Physicsexplosion
							physExplo:SetKeyValue( "radius", "500" ) -- Radius of the explosion
							physExplo:SetKeyValue( "spawnflags", "19" )
							physExplo:Spawn()
							physExplo:Fire( "Explode", "", 0 )



			end
		end
		
	end

	function ENT:Use( activator, caller )
		--Msg( self.Warhead )
	end

	function ENT:PreEntityCopy()
		local dupeInfo = {}

		if ValidEntity(self.Entity) then
			dupeInfo.EntID = self.Entity:EntIndex()
		end
		if WireAddon then
			dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
		end
			
		duplicator.StoreEntityModifier(self, "AGateMissile", dupeInfo)
	end
	duplicator.RegisterEntityModifier( "AGateMissile" , function() end)

	function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
		
		local dupeInfo = Ent.EntityMods.AGateMissile

		if dupeInfo.EntID then
			self.Entity = CreatedEntities[ dupeInfo.EntID ]
		end

		if(Ent.EntityMods and Ent.EntityMods.AGateMissile.WireData) then
			WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AGateMissile.WireData, function(id) return CreatedEntities[id] end)
		end

		local phys = self.Entity:GetPhysicsObject();
		if ValidEntity(phys) then phys:EnableGravity(false) end

		self.Owner = ply;
	end	
else
	killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))

	function ENT:Initialize()
	end

	function ENT:Draw()
		self.Entity:DrawModel()
	end
end