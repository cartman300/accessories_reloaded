ENT.Base = "sa_base"
ENT.PrintName = "Screen"
ENT.WireDebugName = "Screen"

ENT.Spawnable = true
ENT.AdminSpawnable = false

if (CLIENT) then
	function ENT:Draw()	
		self:DrawModel()
		--if (LocalPlayer():GetPos():Distance(self:GetPos()) < 1000) then
			if (self:GetNWBool("SIGNAL_LOST")) then
				local angle = self:GetAngles()
				angle:RotateAroundAxis(angle:Right(), -90);
				angle:RotateAroundAxis(angle:Up(), 90)
				local Pos = self:GetPos()
				Pos = Pos + angle:Up() * 6.1
				cam.Start3D2D(Pos, angle, 0.25);
				surface.SetDrawColor(0, 0, 0, 255);
				surface.DrawRect(-115, -145, 230, 140);
				draw.SimpleText("NO SIGNAL", "CenterPrintText", 0, -75, Color(255, 255, 255), 1, 1);
				cam.End3D2D();
			end
		--end
	end
elseif (SERVER) then
	AddCSLuaFile();
	
	ENT.Detector = nil
	ENT.KINO = nil
	
	function ENT:RecordKINO(KinoID)
		local e = Entity(KinoID)
		if IsValid(e) and e:GetClass() == "kino_ball" then
			UpdateRenderTarget(e)
		end
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/rt_screen.mdl");
		self.Entity:PhysicsInit(SOLID_VPHYSICS);
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
		self.Entity:SetSolid(SOLID_VPHYSICS);
		
		--self:AddResource("Naquadah",self.MaxEnergy); --Naquadah energy @Anorr
		--self:SupplyResource("Naquadah",self.MaxEnergy)
		--self:CreateWireOutputs("Depleted","Energy","Energy %","Naquadah", "Naquadah %");
		--self:CreateWireInputs("DisablePickup", "Explode");
		self:CreateWireInputs("KINO", "KINO Detector [WIRELINK]");
		self:CreateWireOutputs("No Signal")
		

		local phys = self.Entity:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:EnableMotion(false);
			phys:SetMass(5);
		end
	end


	function ENT:SpawnFunction(p,t)
		if(not t.Hit) then return end;
		local e = ents.Create("sa_screen");
		e:SetPos(t.HitPos);
		e:Spawn();
		return e;
	end

	function ENT:Use(activator, caller)
		if (activator:IsPlayer()) then
		
		end
	end
	
	function ENT:Think()
		if (not IsValid(self.KINO) or not IsValid(self.Detector) or self.Detector:GetPos():Distance(self.KINO:GetPos()) > self.Detector.Range) then
			self:SetNWBool("SIGNAL_LOST", true)
			Wire_TriggerOutput(self, "No Signal", 1)
		end
		self.Entity:NextThink(CurTime() + 1);
		return true;
	end

	function ENT:OnTakeDamage(d)
	
	end

	function ENT:Explode()
		local lexplode = ents.Create("env_explosion")
		lexplode:SetPos(self:GetPos()) //Puts the explosion where you are aiming
		self:Remove()
		lexplode:SetOwner( self.Owner ) //Sets the owner of the explosion
		lexplode:Spawn()
		lexplode:SetKeyValue("iMagnitude","125") //Sets the magnitude of the explosion
		lexplode:Fire("Explode", 0, 0 ) //Tells the explode entity to explode
		if (self.HasRD) then StarGate.WireRD.OnRemove(self) end;
	end

	function ENT:TriggerInput(name, value)
		if (name == "KINO Detector") then
			self.Detector = value
		elseif (name == "KINO" and IsValid(self.Detector)) then
			local K = self.Detector.Kinos[value] and self.Detector.Kinos[value].Kino or nil
			if (IsValid(K)) then
				self.KINO = K
				self:RecordKINO(K:EntIndex())
				self:SetNWBool("SIGNAL_LOST", false)
				Wire_TriggerOutput(self, "No Signal", 0)
			end
		end
	end
end