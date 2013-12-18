--################# HEADER #################
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
--################# SENT CODE ###############
--################# Init @JDM12989
function ENT:Initialize()
	self.Entity:SetModel("models/sandeno/naquadah_bottle.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
    
	self.MaxEnergy = 100000    --@meeces2911 WHAT is this energy ment to be, it was set to 500!? that it not very much energy ... ? Did you want 500 NE ?
	self.enabled = false;
    self.DisablePickup = false
	self.depleted = false
    
    self.health = 100
    self.boomed = false
    
	self:AddResource("Naquadah",self.MaxEnergy); --Naquadah energy @Anorr
	self:SupplyResource("Naquadah",self.MaxEnergy);
	self:AddResource("energy",self.MaxEnergy * 2); -- Maximum energy to store in a Naquadah Bottle is 800 units
    self:SupplyResource("energy", self.MaxEnergy * 2);
	self:CreateWireOutputs("Depleted","Energy","Energy %","Naquadah", "Naquadah %");
	self:CreateWireInputs("DisablePickup", "Explode");

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
        phys:Sleep();
		phys:SetMass(5);
	end
end
--concommand.Add("naq_bottle_explode", self:Explode())
--################# Spawn the SENT @JDM12989
function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("naquadah_vial");
	e:SetPos(t.HitPos+Vector(0,0,10));
	e:Spawn();
	return e;
end

function ENT:Use(activator, caller)
    if (self.DisablePickup == false) then
        if (self.depleted == true) then
        else
                if (activator:IsPlayer()) then
                    if(self:GetUnitCapacity("energy") ~= self:GetNetworkCapacity("energy")) then
                    else
                        local ATG = math.Clamp(self.naquadah_percent,0,100);
                        activator:GiveAmmo(ATG, "combinecannon")       -- Working :D
                        self:Remove()
                    end
                end
        end
    else
    end
end
--function ENT:ShowOutput
--end
--################# Think @JDM12989
function ENT:Think()
	if(self.depleted or not self.HasResourceDistribution) then return end;
	self.energy = self:GetResource("energy");
	self.naquadah = self:GetResource("Naquadah");
	local my_capacity = self:GetUnitCapacity("energy");
	local nw_capacity = self:GetNetworkCapacity("energy");
	self.energy_percent = (self.energy/(self.MaxEnergy*2))*100;
	self.naquadah_percent = (self.naquadah/self.MaxEnergy)*100
        
	-- No Naquadah Energy available anymore - We are depleted!
	if(self.naquadah_percent == 0) then
		self.depleted = true;
        self:SetWire("Depleted", 1)
    else
        self:SetWire("Depleted", 0)
        self.depleted = false;
	end
	-- Energy conversion when availeble storage @Anorr,aVoN
	if(self.energy < nw_capacity) then
        if (self.naquadah < 1) then
        else
            local rate = 500; -- Two passes until it filled the full network
            self:SupplyResource("energy",rate*2);
            self:ConsumeResource("Naquadah",rate);
        end
	end
	self:SetWire("Energy %",math.floor(self.energy_percent));
	self:SetWire("Naquadah %",math.floor(self.naquadah_percent));
	self:SetWire("Energy",math.floor(self.energy));
	self:SetWire("Naquadah",math.floor(self.naquadah));
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

function ENT:OnTakeDamage(dmg,attacker)
end

function ENT:OnTakeDamage(d)
    self.health = self.health - d:GetDamage()
    if (self.health <= 0 and not self.boomed) then
        self.boomed = true
        self:Explode()
    end
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
	if (name == "DisablePickup") then
		if (value > 0) then
            self.DisablePickup = true
        else
            self.DisablePickup = false
        end
	elseif (name == "Explode") then
		if (value > 0) then
			self:Explode();
		end
	end
end