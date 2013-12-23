StarGate.LifeSupportAndWire(ENT); -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Base Prop"
ENT.Author = "Cartman300"
ENT.Contact = "Cartman300@net.hr"
ENT.Category = "CAltP"
ENT.WireDebugName = "Base Prop"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (CLIENT) then
	ENT.RenderGroup = RENDERGROUP_BOTH;
	ENT.Category = "CAltP"
	ENT.PrintName = "Base Entity"

	function ENT:Draw()
		self.Entity:DrawModel()
	end
elseif (SERVER) then
	AddCSLuaFile();

	function ENT:Initialize()
		self.Entity:SetModel("models/jaanus/wiretool/wiretool_siren.mdl");
		self.Entity:PhysicsInit(SOLID_VPHYSICS);
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
		self.Entity:SetSolid(SOLID_VPHYSICS);
		
		--self:AddResource("Naquadah",self.MaxEnergy); --Naquadah energy @Anorr
		--self:SupplyResource("Naquadah",self.MaxEnergy)
		--self:CreateWireOutputs("Depleted","Energy","Energy %","Naquadah", "Naquadah %");
		--self:CreateWireInputs("DisablePickup", "Explode");

		local phys = self.Entity:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:Sleep();
			phys:SetMass(5);
		end
	end


	function ENT:SpawnFunction(p,t)
		if(not t.Hit) then return end;
		local e = ents.Create("sa_base");
		e:SetPos(t.HitPos+Vector(0,0,10));
		e:Spawn();
		return e;
	end

	function ENT:Use(activator, caller)
		if (activator:IsPlayer()) then
		
		end
	end

	function ENT:Think()
		
		
		self.Entity:NextThink(CurTime()+1);
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

	function ENT:TriggerInput(name,value)
		
	end
end