AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");


function ENT:Initialize()
	self.Entity:SetModel("models/jaanus/wiretool/wiretool_siren.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
    
    self.I = 0
    self.Act = true
    self.Active = false
    self.xD = true
    
	--self:AddResource("Naquadah",self.MaxEnergy);
	--self:SupplyResource("Naquadah",self.MaxEnergy)
	self:CreateWireOutputs("Active");
	self:CreateWireInputs("On", "Toggle");

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
        phys:Sleep();
		phys:SetMass(5);
	end
end

function ENT:On()
	if self.Active == false then
		self.Active = true
		self:SetColor(Color(255, 0, 0, 255))
		local angForward = self:GetAngles() + Angle( 90, 0, 0 )

		self.flashlight = ents.Create( "env_projectedtexture" )

			self.flashlight:SetParent( self )

			// The local positions are the offsets from parent..
			self.flashlight:SetLocalPos( Vector( 0, 0, 5 ) )
			self.flashlight:SetLocalAngles( Angle(0,90,90) )

			// Looks like only one flashlight can have shadows enabled!
			self.flashlight:SetKeyValue( "enableshadows", 0 )
			self.flashlight:SetKeyValue( "farz", 2048 )
			self.flashlight:SetKeyValue( "nearz", 8 )

			//Todo: Make this tweakable?
			self.flashlight:SetKeyValue( "lightfov", 100 )

			// Color.. Bright pink if none defined to alert us to error
			self.flashlight:SetKeyValue( "lightcolor", self.m_strLightColor or "255 0 0" )


		self.flashlight:Spawn()

		self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	end
end

function ENT:RotateLight(A)
    self.flashlight:SetLocalAngles( Angle(0, A, 90))
end

function ENT:Off()
	if self.Active == true then
		self.Active = false
		self:SetColor(Color(50, 0, 0, 255))
		SafeRemoveEntity( self.flashlight )
	end
end

function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("sa_lamp");
	e:SetPos(t.HitPos+Vector(0,0,10));
	e:Spawn();
	return e;
end

function ENT:Use(activator, caller)
    if (activator:IsPlayer()) then
    
    end
end
--function ENT:ShowOutput
--end
--################# Think @JDM12989
function ENT:Think()
	if (self.Act == true) then
        self:On()
        if self.I > 359 then
            self.I = 0
        else
            self.I = self.I + 5
        end
        self:RotateLight(self.I)
    else
        self:Off()
    end
    
	self.Entity:NextThink(CurTime()+0.01);
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
    if (name == "On") then
        if (value > 0) then
            self.Act = true
            self:SetWire("Active", 1)
        else
            self.Act = false
            self:SetWire("Active", 0)
        end
    end
    if (name == "Toggle") then
        if (value > 0) then
            if (self.xD == true) then
                self.xD = false
                timer.Simple(0.2, function()
                    self.xD = true
                end)
                if self.Act == true then
                    self.Act = false
                    self:SetWire("Active", 0)
                else
                    self.Act = true
                    self:SetWire("Active", 1)
                end
            end
        end
    end
end