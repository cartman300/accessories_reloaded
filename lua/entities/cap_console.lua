if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cap Console"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Cap Console"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Light = false
ENT.Screen = false

if SERVER then

	if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

	AddCSLuaFile();

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		
		self:CreateWireInputs("Screen");
	end
	
	function ENT:TriggerInput(name, value)
		if (name == "Screen") then
			if (value <= 0) then self.Screen = false else self.Screen = true end
			self:SetNWBool("Screen", self.Screen)
		end
	end

	function ENT:Think()
		local ply = StarGate.FindPlayer(self:GetPos(), 300);

		if (ply and not self.Light) then
			self.Light = true;
			self:SetSkin(1);
			self:SetNWBool("Light", true)
			local NWScreen = self:GetNWBool("Screen")
			if (NWScreen != self.Screen) then self:SetNWBool("Screen", self.Screen) end
		elseif (not ply and self.Light) then
			self.Light = false;
			self:SetSkin(0);
			self:SetNWBool("Light", false)
		end

		self:NextThink(CurTime() + 0.5);
		return true
	end

else
	
	function ENT:Draw()
		self:DrawModel()
		
		if (self.Light and self.Screen) then
			local angle = self:GetAngles()
			angle:RotateAroundAxis(angle:Right(), -90);
			angle:RotateAroundAxis(angle:Up(), 90)
			local Pos = self:GetPos()
			Pos = Pos - angle:Up() * 25 - angle:Right() * 45
			cam.Start3D2D(Pos, angle, 0.25);
			surface.SetDrawColor(0, 0, 0, 200);
			surface.DrawRect(-115, -145, 230, 140);
			draw.SimpleText("NO SIGNAL", "CenterPrintText", 0, -75, Color(255, 255, 255), 1, 1);
			cam.End3D2D();
		end
	end
	
	function ENT:Think()
		self.Light = self:GetNWBool("Light")
		self.Screen = self:GetNWBool("Screen")
		self:NextThink(CurTime() + 0.5)
	end

end