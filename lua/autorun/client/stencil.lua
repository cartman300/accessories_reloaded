return nil

local width = ScrW()
local height = ScrH()


local tex_name = "texture_scene"
local mat_name = "material_scene"


-- Thanks to Wizzard of Ass for this portion of the code.
-- Thread: http://facepunch.com/showthread.php?t=1276039
local TEXTURE_FLAGS_CLAMP_S = 0x0004
local TEXTURE_FLAGS_CLAMP_T = 0x0008


local tex_scene = GetRenderTargetEx(tex_name,
	width,
	height,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(TEXTURE_FLAGS_CLAMP_S, TEXTURE_FLAGS_CLAMP_T),
	CREATERENDERTARGETFLAGS_UNFILTERABLE_OK,
    IMAGE_FORMAT_RGB888
)


local mat_scene = CreateMaterial(mat_name, "UnlitGeneric", {
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 0,
	["$nolod"] = 1,
	["$basetexture"] = tex_scene:GetName()
})


local mat_wall = CreateMaterial("wall_texture", "UnlitGeneric", {
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 0,
	["$nolod"] = 1,
	["$basetexture"] = "BRICK/BRICKWALL003A_CONSTRUCT"
})


local mat_white = Material("debug/debugdrawflat")


local view = {}
view.dopostprocess = true
view.drawhud       = false
view.drawmonitors  = false
view.drawviewmodel = false
view.fov           = 90+16
view.znear         = 1
view.zfar          = 10000
view.x           = 0
view.y           = 0
view.w           = width
view.h           = height
view.aspectratio = width/height


local indraw


hook.Add("RenderScene", "hole_in_the_wall", function()
	
	if indraw then return end
	
	indraw = true
	
	view.origin = LocalPlayer():GetShootPos()
	view.angles = LocalPlayer():EyeAngles()
	
	local trace = LocalPlayer():GetEyeTrace()
	local normal = trace.HitNormal
	local center = trace.HitPos
	
	local clip_normal = -normal
	local clip_center = center-normal*2
	local clip_distance = clip_normal:Dot(clip_center)
	
	local render_target = render.GetRenderTarget()
	render.SetRenderTarget(tex_scene)
		local w,h = ScrW(), ScrH()
		render.Clear(0, 0, 0, 255)
		render.ClearDepth()
		render.SetViewPort(0, 0, width, height)
			cam.Start2D()
				render.EnableClipping(true)
				render.PushCustomClipPlane(clip_normal, clip_distance)
					render.RenderView(view)
				render.PopCustomClipPlane()
				render.EnableClipping(false)
			cam.End2D()
		render.SetViewPort(0, 0, w, h)
	render.SetRenderTarget(render_target)
	
	indraw = false
end)


local function DrawQuad(pa, pb, pc, pd, normal)
	mesh.Begin(MATERIAL_QUADS, 1)
		mesh.Position(pa)
		mesh.Normal(normal)
		mesh.TexCoord(0, 0, 0)
		mesh.Color(255, 255, 255, 255)
		
		mesh.AdvanceVertex()
		
		mesh.Position(pb)
		mesh.Normal(normal)
		mesh.TexCoord(0, 1, 0)
		mesh.Color(255, 255, 255, 255)
		
		mesh.AdvanceVertex()
		
		mesh.Position(pc)
		mesh.Normal(normal)
		mesh.TexCoord(0, 1, 1)
		mesh.Color(255, 255, 255, 255)
		
		mesh.AdvanceVertex()
		
		mesh.Position(pd)
		mesh.Normal(normal)
		mesh.TexCoord(0, 0, 1)
		mesh.Color(255, 255, 255, 255)
		
		mesh.AdvanceVertex()
	mesh.End()
end


hook.Add("PreDrawOpaqueRenderables", "hole_in_the_wall", function()
	
	if indraw then return end
	
	indraw = true
	
	local trace   = LocalPlayer():GetEyeTrace()
	local center  = trace.HitPos
	local normal  = trace.HitNormal
	local texture = trace.HitTexture
	
	local forward = -normal
	local right   = forward:Angle():Right()
	local up      = forward:Angle():Up()
	
	local width   = 60
	local height  = 60
	local depth   = 40
	local color   = Color(255, 0, 0, 255)
	local angle   = 0
	
	local blf = center - right*width/2 - up*height/2
	local brf = blf + right*width
	local tlf = blf + up   *height
	local trf = brf + up   *height
	
	local blb = blf + forward * depth
	local brb = blb + right*width
	local tlb = blb + up   *height
	local trb = brb + up   *height
	
	mat_wall:SetTexture("$basetexture", texture)
	
	render.ClearStencil()
	render.SetStencilEnable(true)
		
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		
		render.SetStencilReferenceValue (1)
		render.SetStencilFailOperation  (STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation (STENCILOPERATION_KEEP)
		render.SetStencilPassOperation  (STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		
		render.SetMaterial(mat_white)
		render.DrawQuadEasy(center, normal, width, height, color, angle)
		
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		
		cam.Start2D()
			surface.SetMaterial(mat_scene)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		cam.End2D()
		
		render.SetMaterial(mat_wall)
		
		DrawQuad(blf, blb, brb, brf,  up)
		DrawQuad(tlf, trf, trb, tlb, -up)
		DrawQuad(tlf, tlb, blb, blf,  right)
		DrawQuad(trf, brf, brb, trb, -right)
		
	render.SetStencilEnable(false)
	
	indraw = false
	
end)