local CHUD_LOADED = false
local function CHUD_LOAD()
	local MINIMAP = MINIMAP or false
	local CHUD = CHUD or true
	
	surface.CreateFont("HUDFont", {
		font = "dolce vita",
		size = 32,
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
	
	local me = LocalPlayer()
	local SW = surface.ScreenWidth()
	local SH = surface.ScreenHeight()
	
	local Materials = {}
	Materials.Health = Material("hud/health.png", "")
	Materials.Energy = Material("hud/electric.png", "")
	
			local Draw = {}
		Draw.Texture = function(Tex, X, Y, W, H, Col)
			if (Col == nil) then
				surface.SetDrawColor(255, 255, 255, 255)
			else
				surface.SetDrawColor(Col)
			end
			surface.SetMaterial(Tex)
			surface.DrawTexturedRect(X, SH - Y, W, H)
		end
		
		Draw.Text = function(Str, X, Y)
			--surface.SetFont("HUDFont")
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(X, SH - Y)
			surface.DrawText(Str)
		end
		
		Draw.Rect = function(C, X, Y, W, H)
			surface.SetDrawColor(C)
			surface.DrawRect(X, SH - Y, W, H)
		end
		
		Draw.HUDBox = function(Mat, T, X, Y, DoHide)
			local num_T = tonumber(T)
			if (DoHide and num_T <= 0) then return 0, 0; end -- If we hide and T <= 0 then don't show up and return 0, 0 size
			surface.SetFont("HUDFont")
			local w = surface.GetTextSize(T)
			local b_W = w + 48
			local b_H = 40
			Draw.Rect(Color(0, 0, 0, 200), X, Y, b_W, b_H) -- Rectangle
			local Clr = nil; if (num_T <= 10) then Clr = Color(255, 50, 50, 255) end -- Red color when T <= 10
			Draw.Texture(Mat, X + 4, Y - 4, 32, 32, Clr) -- Icon
			Draw.Text(T, X + 40, Y - 4) -- Text
			return b_W, b_H -- return size
		end
		
	hook.Add("PostDrawSkyBox", "Minimap_Skybox", function() if (MINIMAP) then render.Clear(0, 0, 0, 0, true, true) end end)
	hook.Add("HUDPaint", "Minimap", function()			
		if (CHUD) then
			local p_Health = tostring(me:Health())
			local p_Armor = tostring(me:Armor())
			--local p_Ammo_Primary = tostring(1124)
			--local p_Ammo_Secondary = tostring(12) -- Maybe one day
			
			local h_W = Draw.HUDBox(Materials.Health, p_Health, 10, 50)
			Draw.HUDBox(Materials.Energy, p_Armor, h_W + 15, 50, true)
		end
		
		if (MINIMAP) then
			local Sw = SW - 32
			local Sh = SH - 32
		
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( 15, 15, SW - 30, SH - 30 )
			
			local camd = {}	
			
			camd.dopostprocess = false
			camd.drawhud = false
			camd.drawviewmodel = !false
			camd.drawmonitors = false
			
			camd.ortho = true
			camd.angles = Angle(90, 0, 0)
			camd.origin = me:GetPos() + Vector(0, 0, 90)
			
			camd.x = 16
			camd.y = 16
			camd.w = Sw
			camd.h = Sh
			camd.ortholeft = -Sw
			camd.orthoright = Sw
			camd.orthotop = -Sh
			camd.orthobottom = Sh
			render.RenderView(camd)
			
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(surface.GetTextureID("gui/silkicons/user"))
			surface.DrawTexturedRect(SW / 2 - 8, SH / 2 - 8, 16, 16)

			if (me:KeyDown(IN_MOVELEFT) or me:KeyDown(IN_MOVERIGHT) or me:KeyDown(IN_FORWARD) or me:KeyDown(IN_BACK)) then me:SetEyeAngles(Angle(0, 0, 0)) end
		end
	end)
	
	hook.Add("HUDShouldDraw", "CHud_HUDShouldDraw", function(name)
		if (CHUD) then
			if (name == "CHudHealth" or name == "CHudBattery") then
				return false
			end
		end
		return true
	end)
	
	concommand.Add("+minimap", function() MINIMAP = true end)
	concommand.Add("-minimap", function() MINIMAP = false end)
	concommand.Add("minimap", function() MINIMAP = not MINIMAP end)
	
	concommand.Add("+cl_chud", function() CHUD = true end)
	concommand.Add("-cl_chud", function() CHUD = false end)
	concommand.Add("cl_chud", function() CHUD = not CHUD end)
	
	concommand.Add("cl_chud_status", function()
		print("CHUD open    = " .. tostring(CHUD))
		print("Minimap open = " .. tostring(MINIMAP))
	end)
end

concommand.Add("cl_chud_load", function()
	CHUD_LOADED = true
	CHUD_LOAD()
	if (CHUD_LOADED) then
		print("CHUD Reloaded!");
	else
		print("CHUD Loaded!")
	end
end)