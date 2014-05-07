if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cap Console"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Cap Console"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	self.Light = false
	self.Screen = false
	self.Editable = true
	self.LightDistance = 300

	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);

		self:CreateWireInputs("Screen", "Text [STRING]", "Disable Use");
		self:CreateWireOutputs("Screen", "Text [STRING]");
		
		--engine.LightStyle(0, "m")
	elseif (CLIENT) then
		
		self.Text = "NO SIGNAL"
		self.Font = "cap_console_font"
		self.Poly = {
			{ x = -115, y = -145 },
			{ x = -115 + 230 - 10, y = -145 },
			{ x = -115 + 230, y = -145 + 10 },
			{ x = -115 + 230, y = -145 + 140 },
			{ x = -115 + 10, y = -145 + 140 },
			{ x = -115, y = -145 + 140 - 10 }
		}
		
		self.Particles = {
			{ x = -115, y = -145 + 140 - 10, w = 100, h = 10, vx = 2, vy = 0 },
			{ x = -115, y = -145, w = 10, h = 100, vx = 0, vy = 2 },
			{ x = -115, y = -145, w = 100, h = 10, vx = -2, vy = 0 },
			{ x = -115 + 230 - 10, y = -145, w = 10, h = 100, vx = 0, vy = -2 }
		}
		
		--timer.Simple(.1, function() render.RedownloadAllLightmaps() end)
	end
end

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
	elseif (name == "Disable Use") then
		if (SERVER) then
			if (value > 0) then
				self.DisableUse = true
			else
				self.DisableUse = false
			end
		end
	end
end

function ENT:SetKeyValue(k, v)
	self:TriggerInput(k, v)
end

if (SERVER) then
	AddCSLuaFile();

	function ENT:Use(ply)
		if (self.DisableUse) then return end
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

	surface.CreateFont("cap_console_font", {
		font = "System",
		size = 10,
		weight = 100,
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
	
	function ENT:UpdateParticles()
		for _, P in ipairs(self.Particles) do				
			P.x = P.x + P.vx
			P.y = P.y + P.vy

			if (P.x < -115 - P.w) then P.x = -115 + 230 end
			if (P.y < -145 - P.h) then P.y = -145 + 140 end

			if (P.x > -115 + 230) then P.x = -115 - P.w end
			if (P.y > -145 + 140) then P.y = -145 - P.h end
		end
	end
	
	function ENT:DrawParticles()
		for _, P in ipairs(self.Particles) do
			surface.DrawRect(P.x, P.y, P.w, P.h)
		end
	end
	
	function ENT:DrawTranslucent()
		if (self.Light and self.Screen) then
			local angle = self:GetAngles()
			angle:RotateAroundAxis(angle:Right(), -90);
			angle:RotateAroundAxis(angle:Up(), 90)
			local Pos = self:GetPos()
			Pos = Pos - angle:Up() * 25 - angle:Right() * 45
			
			surface.SetDrawColor(0, 0, 0, 200);
			draw.NoTexture()
			
			cam.Start3D2D(Pos, angle, .30);

			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilReferenceValue(1)
			surface.DrawPoly(self.Poly) -- Mask
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilReferenceValue(1) --]]--
			
			surface.DrawRect(-115, -145, 230, 140)
			surface.SetDrawColor(0, 0, 0, 100);
			self:DrawParticles()
			
			if (not pcall(draw.DrawText, self.Text, self.Font, -110, -145, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)) then
				self:SetFont("cap_console_font")
				self.Font = "cap_console_font"
			end
			
			render.SetStencilEnable(false)
			cam.End3D2D();
			
			local ScreenLight = DynamicLight(self:EntIndex())
			if (ScreenLight) then
				ScreenLight.Pos = self:GetPos() + self:GetUp() * 50 + self:GetForward() * -10
				ScreenLight.r = 255
				ScreenLight.g = 225
				ScreenLight.b = 200
				ScreenLight.Brightness = 0
				ScreenLight.Size = 100
				ScreenLight.Decay = 0
				ScreenLight.DieTime = CurTime() + .1
			end   
		end
	end
	
	function ENT:Think()
		self.Screen = self:GetScreen()
		self.Text = self:GetText()
		self.Font = self:GetFont()
		self.Light = LocalPlayer():GetPos():Distance(self:GetPos()) <= self.LightDistance
		
		if (self.Screen) then self:UpdateParticles() end
		
		self:NextThink(CurTime() + 0.2)
	end
end