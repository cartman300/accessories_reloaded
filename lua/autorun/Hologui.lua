if (SERVER) then
	AddCSLuaFile()
	return
end

Hologui = {}
Hologui.__index = Hologui
Hologui.__tostring = function() return "Hologui" end

surface.CreateFont("hologui_font", {
	font = "Consolas",
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function Hologui:GetMousePos()
	local Ply = LocalPlayer()
	
	local MousePos = { x = 0, y = 0, dx = 0, dy = 0, Hit = false, UseDown = false }
	local Tr = Ply:GetEyeTrace()
	
	if (Tr.Entity == self.Owner and Ply:GetPos():Distance(Tr.HitPos) < 100) then
		local LHitPos = self.Owner:WorldToLocal(Tr.HitPos) * 10 * Vector(1, -1, 1)
		LHitPos = LHitPos + Vector(self.w / 2, self.h / 2, 0)
		MousePos.x = LHitPos.x
		MousePos.y = LHitPos.y
		MousePos.Hit = true
		MousePos.UseDown = Ply:KeyDown(IN_USE)
	end
	
	if (self.LastMousePos and self.LastMousePos.Hit) then
		MousePos.dx = self.LastMousePos.x - MousePos.x
		MousePos.dy = self.LastMousePos.y - MousePos.y
	end
	
	self.LastMousePos = MousePos
	return MousePos
end

function Hologui:Draw(Pos, Angles, Scale)
	if (LocalPlayer():GetPos():Distance(self.Owner:GetPos()) > 400) then return end
	local MPos = self:GetMousePos()
	
	cam.Start3D2D(Pos, Angles, Scale)
	render.PushFilterMag(TEXFILTER.LINEAR)
	render.PushFilterMin(TEXFILTER.LINEAR)
	
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(self.x, self.y, self.w, self.h)
	
	self.tx = self.tx or 0
	self.ty = self.ty or 0
	
	if (MPos.UseDown) then
		self.tx = self.tx - MPos.dx
		self.ty = self.ty - MPos.dy
	end
	
	draw.DrawText("Some very long and readable text", "hologui_font", self.tx, self.ty, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	

	if (MPos.Hit) then
		local AlphaAdd = MPos.UseDown and 155 or 0
		surface.SetDrawColor(255, 255, 255, 50)
		surface.DrawLine(MPos.x, 0, MPos.x, self.h)
		surface.DrawLine(0, MPos.y, self.w, MPos.y)
		
		surface.SetDrawColor(255, 255, 255, 100 + AlphaAdd)
		surface.DrawOutlinedRect(MPos.x - 4, MPos.y - 4, 8, 8)
	end
	render.PopFilterMag()
	render.PopFilterMin()
	cam.End3D2D()
end

function Hologui:SetPos(x, y)
	self.x = x
	self.y = y
end

function Hologui:SetSize(w, h)
	self.w = w
	self.h = h
end

function Hologui:Dispose()

end

function Hologui.Create(Owner, x, y, w, h)
	local NewHolo = {}
	setmetatable(NewHolo, Hologui)
	
	NewHolo:SetPos(x, y)
	NewHolo:SetSize(w, h)
	NewHolo.Owner = Owner
	NewHolo.LastMousePos = {}
	
	return NewHolo
end