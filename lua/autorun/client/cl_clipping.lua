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