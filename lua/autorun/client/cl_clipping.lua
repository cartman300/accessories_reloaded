local p,d,y = 0,0,0

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
	
	if not IsValid(e) then return end
	if e:GetClass() ~= "prop_physics" then return end
	if not IsValid(LocalPlayer()) then return end
	if not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" or GetConVarString("gmod_toolmode") ~= "clipplane" then return end
	
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

local meta = FindMetaTable("Entity")

function meta:AddClipPlane(norm,dist,mirror)

	self._clipPlanes = self._clipPlanes or {}
	
	table.insert(self._clipPlanes,{norm,dist,mirror})
end

usermessage.Hook("SendForClipping",function(msg)

	local e = msg:ReadEntity()
	
	local num = msg:ReadLong()
	
	for i=1,num do
	
		e:AddClipPlane(msg:ReadVector(),msg:ReadFloat(),msg:ReadBool())
	end
end)

hook.Add("PreDrawOpaqueRenderables","ClipPhysRender",function()
	
	render.EnableClipping(true)
				
		for k,v in pairs(ents.FindByClass("prop_physics")) do
		
			if v._clipPlanes then
			
				local mat = v:GetMaterial()
				local color = v:GetColor()
				
				//render.SetColorModulation(color.r/255,color.g/255,color.b/255)
				render.SetBlend(color.a/255)
				
				//SetMaterialOverride(mat)
						
				local start = v._clipPlanes[0] and 0 or 1
				
				for i=start,#v._clipPlanes do
				
					local p = v._clipPlanes[i]
					
					local a = v:GetAngles()
				
					local n = p[1]*1
									
					n = v:LocalToWorldAngles(n:Angle()):Forward()
					
					local pos = v:GetPos()+n*p[2]
					
					if p[3] then
					
						local n2 = n*-1
						
						v:SetModelScale(-1, 0)
														
						a:RotateAroundAxis(n,180)
						
						v:SetRenderOrigin(pos-n2*p[2])
						v:SetRenderAngles(a)
						v:SetupBones()
						
						render.PushCustomClipPlane(n2,n2:Dot(pos))
						
							v:DrawModel()
							
							render.CullMode(MATERIAL_CULLMODE_CW)
				
								v:DrawModel()
							render.CullMode(MATERIAL_CULLMODE_CCW)
						render.PopCustomClipPlane()
					end
										
					render.PushCustomClipPlane(n,pos:Dot(n))
				end
				
				v:SetModelScale(1, 0)
				v:SetRenderOrigin()
				v:SetRenderAngles()
				v:SetupBones()
				
				v:DrawModel()
				
				render.CullMode(MATERIAL_CULLMODE_CW)
				
					v:DrawModel()
				render.CullMode(MATERIAL_CULLMODE_CCW)
				
				for i=start,#v._clipPlanes do
				
					render.PopCustomClipPlane()
				end
																	
				v:SetModelScale(0, 0)
				
				render.SetBlend(1)
				//render.SetColorModulation(1,1,1)
				//SetMaterialOverride()
			end
		end
	
	render.EnableClipping(false)
	
	render.SetBlend(1)
end)