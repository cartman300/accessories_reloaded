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
ENT.Editable = true
ENT.LightDistance = 300

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Screen", { KeyName = "Screen", Edit = { type = "Boolean", order = 1 } })
	self:NetworkVar("String", 0, "Text", { KeyName = "Text", Edit = { type = "String", order = 2 } })
	self:NetworkVar("String", 1, "Font", { KeyName = "Font", Edit = { type = "String", order = 3 } })
	
	self:SetText("NO SIGNAL")
	self:SetScreen(false)
	self:SetFont("cap_console_font")
end

function ENT:TriggerInput(name, value)
	if (name == "Screen") then
		if (value <= 0) then
			self.Screen = false
		else
			self.Screen = true
		end
		self:SetScreen(self.Screen)
		self:SetWire("Screen", value)
	elseif (name == "Text" or name == "Text [STRING]") then	
		self:SetText(tostring(value))
		self:SetWire("Text", tostring(value))
	end
end

function ENT:SetKeyValue(k, v)
	self:TriggerInput(k, v)
end

if (SERVER) then
	if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

	AddCSLuaFile();

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		
		self:CreateWireInputs("Screen", "Text [STRING]");
		self:CreateWireOutputs("Screen", "Text [STRING]");
	end
	
	function ENT:Use(ply)
		local N = 0
		if (not self.Screen) then N = 1 end
		self:TriggerInput("Screen", N)
	end

	function ENT:Think()
		local ply = StarGate.FindPlayer(self:GetPos(), self.LightDistance);

		if (ply and not self.Light) then
			self.Light = true;
			self:SetSkin(1);
		elseif (not ply and self.Light) then
			self.Light = false;
			self:SetSkin(0);
		end
		
		self:NextThink(CurTime() + 0.2);
		return true
	end

elseif (CLIENT) then
	ENT.Text = "NO SIGNAL"
	ENT.Font = "cap_console_font"
	
	surface.CreateFont("cap_console_font", {
		font = "System",
		size = 10,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})

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
			if (not pcall(draw.DrawText, self.Text, self.Font, -110, -145, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)) then
				self:SetFont("cap_console_font")
			end
			cam.End3D2D();
		end
	end
	
	function ENT:Think()
		self.Screen = self:GetScreen()
		self.Text = self:GetText()
		self.Font = self:GetFont()
		self.Light = LocalPlayer():GetPos():Distance(self:GetPos()) <= self.LightDistance
		self:NextThink(CurTime() + 0.2)
	end
end