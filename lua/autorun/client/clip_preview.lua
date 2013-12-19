local p = 0
local y = 0
	
local d = 0

local mat = Material("models/debug/debugwhite")

local curEnt

cvars.AddChangeCallback("clipplane_pitch",function(_,_,new)

	p = tonumber(new) or 0		
end)

cvars.AddChangeCallback("clipplane_yaw",function(_,_,new)
	
	y = tonumber(new) or 0		
end)
	
cvars.AddChangeCallback("clipplane_distance",function(_,_,new)
	
	d = tonumber(new) or 0		
end)

hook.Add("PostDrawOpaqueRenderables","ClipPhysPreview",function()

	local e = LocalPlayer():GetEyeTraceNoCursor().Entity
	
	if !e or !e:IsValid() then return end
	if e:GetClass() != "prop_physics" or e:IsWorld() then return end
	if !LocalPlayer() or !LocalPlayer():IsValid() then return end
	if !LocalPlayer():GetActiveWeapon() or !LocalPlayer():IsValid() or LocalPlayer():GetActiveWeapon():GetClass() != "gmod_tool" or GetConVarString("gmod_toolmode") != "clipplane" then return end
	
	local m = GetConVarNumber("clipplane_mirror",0) == 1
	
	local n = Angle(p,y,0):Forward()*-1
	
	n:Rotate(e:GetAngles())
	
	render.EnableClipping(true)
	
	if !m then
	
		e:SetModelScale(1.01, 0.0001)
		
		render.SetColorModulation(1000,0,0)
		
		render.PushCustomClipPlane(n,n:Dot(e:GetPos()-n*d))
			
			e:DrawModel()
		render.PopCustomClipPlane()
		
		render.SetColorModulation(1,1,1)
	else
		
		local a = e:GetAngles()
		a:RotateAroundAxis(n,180)
		
		e:SetModelScale(-1, 0.0001)
		e:SetRenderOrigin(e:GetPos()-n*d*2)
		e:SetRenderAngles(a)
		e:SetupBones()
		
		render.SetBlend(0.5)
	
		render.PushCustomClipPlane(n,n:Dot(e:GetPos()+n*d))
		
			render.CullMode(MATERIAL_CULLMODE_CW)
			
				e:DrawModel()
			render.CullMode(MATERIAL_CULLMODE_CCW)
		render.PopCustomClipPlane()
			
		render.SetBlend(1)
	end
	
	render.EnableClipping(false)
	
	e:SetModelScale(1, 0.0001)
	e:SetRenderOrigin()
	e:SetRenderAngles()
	e:SetupBones()
end)

