ENT.Base = "sa_base"
ENT.PrintName = "KINO Detector"
ENT.WireDebugName = "KINO Detector"

ENT.Spawnable = true
ENT.AdminSpawnable = false

if (CLIENT) then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
elseif (SERVER) then
	AddCSLuaFile();
	
	ENT.Range = 5000
	ENT.Kinos = nil
	ENT.OwnersKinos = nil
	
	function ENT:RecordKINO(KinoID)
		local e = Entity(KinoID)
		if IsValid(e) and e:GetClass() == "kino_ball" then
			UpdateRenderTarget(e)
		end
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/props_rooftop/antenna03a.mdl");
		self.Entity:PhysicsInit(SOLID_VPHYSICS);
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
		self.Entity:SetSolid(SOLID_VPHYSICS);

		self:CreateWireOutputs("KINOs in range", "Owners KINOs", "Range")
		self:CreateWireInputs("Range")
		

		local phys = self.Entity:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:EnableMotion(false)
			phys:SetMass(5);
		end
	end


	function ENT:SpawnFunction(p,t)
		if(not t.Hit) then return end;
		local e = ents.Create("sa_kino_detector");
		e:SetPos(t.HitPos);
		e:Spawn();
		return e;
	end

	function ENT:Use(activator, caller)
		if (activator:IsPlayer()) then
		
		end
	end
	
	function ENT:GetKinos()
		local AllKinos = ents.FindByClass("kino_ball*")
		local Kinos = {}
		for k,v in pairs(AllKinos) do
			if (v:GetPos():Distance(self:GetPos()) < self.Range) then
				table.insert(Kinos, {Kino = v, KinoID = v:EntIndex()})
			end
		end
		table.SortByMember(Kinos, "KinoID")
		return Kinos
	end

	function ENT:GetOwnersKinos(Kinos)
		local K = Kinos or self:GetKinos()
		local R = {}
		for k,v in pairs(K) do
			if (v.Kino:GetOwner() == self:GetOwner()) then table.insert(R, v) end
		end
		return R
	end
	
	function ENT:Think()
		self.Kinos = self:GetKinos()
		self.OwnersKinos = self:GetOwnersKinos(self.Kinos)
		Wire_TriggerOutput(self, "KINOs in range", self.Kinos and #self.Kinos or 0)
		Wire_TriggerOutput(self, "Owners KINOs", self.OwnersKinos and #self.OwnersKinos or 0)
		Wire_TriggerOutput(self, "Range", self.Range or 0)
	
		self.Entity:NextThink(CurTime() + 0.25);
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
		if (name == "Range") then
			if (value <= 5000 and value > 0) then 
				self.Range = value
			end
		end
	end
end