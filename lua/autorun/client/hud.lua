local MINIMAP = false

hook.Add("PostDrawSkyBox", "Minimap_Skybox", function()
	if (MINIMAP) then render.Clear(0, 0, 0, 0, true, true) end
end)

hook.Add("HUDPaint", "Minimap", function()
	local me = LocalPlayer()
	
	if (MINIMAP) then
		SW = surface.ScreenWidth()
		SH = surface.ScreenHeight()
		Sw = SW - 32
		Sh = SH - 32
		
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
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( surface.GetTextureID( "gui/silkicons/user" ) )
		surface.DrawTexturedRect(SW / 2 - 8, SH / 2 - 8, 16, 16)

		if (me:KeyDown(IN_MOVELEFT) or me:KeyDown(IN_MOVERIGHT) or me:KeyDown(IN_FORWARD) or me:KeyDown(IN_BACK)) then me:SetEyeAngles(Angle(0, 0, 0)) end
	end
end)

concommand.Add("+minimap", function() MINIMAP = true end)
concommand.Add("-minimap", function() MINIMAP = false end)
concommand.Add("minimap", function() MINIMAP = not MINIMAP end)