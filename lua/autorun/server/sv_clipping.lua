AddCSLuaFile("autorun/client/cl_clipping.lua")

local function linePlaneIntersect(planePos,planeNorm,linePos1,linePos2,surfaceTbl)

	local t = planeNorm:Dot(planePos-linePos1)/planeNorm:Dot(linePos2-linePos1)
	
	if t < 0 or t > 1 then
	
		return linePos2
	end
	
	local ret = linePos1+(linePos2-linePos1)*t
	
	if !table.HasValue(surfaceTbl,ret) then
	
		table.insert(surfaceTbl,ret)
	end
		
	return ret
end

//AddMirror

local function Mirror(m,planePos,norm)

	local m2 = {}
	
	for k,v in pairs(m) do
	
		local pos1 = v[1]-planePos
		local pos2 = v[2]-planePos
		local pos3 = v[3]-planePos
				
		local d1 = pos1:Dot(norm)
		local d2 = pos2:Dot(norm)
		local d3 = pos3:Dot(norm)
			
		pos1 = pos1+planePos-norm*d1*2
		pos2 = pos2+planePos-norm*d2*2
		pos3 = pos3+planePos-norm*d3*2
		
		table.insert(m2,{pos3,pos2,pos1}) //Reverse order since it's inverted
	end
	
	return m2
end

local function Split(m,planePos,norm,mirror)
					
	local m2 = {}
		
	local surfaceTbl = {}

	for k,v in pairs(m) do
			
		local pos1 = v[0]-planePos
		local pos2 = v[1]-planePos
		local pos3 = v[2]-planePos
				
		local d1 = pos1:Dot(norm)
		local d2 = pos2:Dot(norm)
		local d3 = pos3:Dot(norm)
			
		pos1 = pos1+planePos
		pos2 = pos2+planePos
		pos3 = pos3+planePos
				
		local pos4,pos5
			
		if d1 < 0 and d2 > 0 and d3 > 0 then
				
			pos4 = linePlaneIntersect(planePos,norm,pos2,pos1,surfaceTbl)
			pos5 = linePlaneIntersect(planePos,norm,pos3,pos1,surfaceTbl)
				
			table.insert(m2,{pos4,pos2,pos3})
			table.insert(m2,{pos4,pos3,pos5})
				
		elseif d2 < 0 and d1 > 0 and d3 > 0 then
				
			pos4 = linePlaneIntersect(planePos,norm,pos1,pos2,surfaceTbl)
			pos5 = linePlaneIntersect(planePos,norm,pos3,pos2,surfaceTbl)
					
			table.insert(m2,{pos1,pos4,pos5})
			table.insert(m2,{pos1,pos5,pos3})
					
		elseif d3 < 0 and d1 > 0 and d2 > 0 then
				
			pos4 = linePlaneIntersect(planePos,norm,pos2,pos3,surfaceTbl)
			pos5 = linePlaneIntersect(planePos,norm,pos1,pos3,surfaceTbl)
					
			table.insert(m2,{pos1,pos2,pos4})
			table.insert(m2,{pos1,pos4,pos5})
					
		elseif d1 > 0 and d2 < 0 and d3 < 0 then
				
			pos2 = linePlaneIntersect(planePos,norm,pos1,pos2,surfaceTbl)
			pos3 = linePlaneIntersect(planePos,norm,pos1,pos3,surfaceTbl)
					
			table.insert(m2,{pos1,pos2,pos3})
			
		elseif d2 > 0 and d1 < 0 and d3 < 0 then
				
			pos1 = linePlaneIntersect(planePos,norm,pos2,pos1,surfaceTbl)
			pos3 = linePlaneIntersect(planePos,norm,pos2,pos3,surfaceTbl)
					
			table.insert(m2,{pos1,pos2,pos3})
					
		elseif d3 > 0 and d1 < 0 and d2 < 0 then
				
			pos1 = linePlaneIntersect(planePos,norm,pos3,pos1,surfaceTbl)
			pos2 = linePlaneIntersect(planePos,norm,pos3,pos2,surfaceTbl)
					
			table.insert(m2,{pos1,pos2,pos3})
					
		elseif d1 > 0 and d2 > 0 and d3 > 0 then
				
			table.insert(m2,{pos1,pos2,pos3})
		end
	end
				
	//TODO: nothing FUCK YEAH!
		
	if mirror == 1 then
		
		m2 = Mirror(m2,planePos,norm)
				
	elseif !mirror and #surfaceTbl > 0 then
		
		local UVs = {}
			
		local u = norm:Angle():Up()
		local r = norm:Angle():Right()
		
		table.foreach(surfaceTbl,function(k,v)
			
			local pos = v-planePos
				
			table.insert(UVs,Vector(pos:Dot(u),pos:Dot(r)))
		end)
			
		local p1 = UVs[1]*1
		
		table.sort(UVs,function(a,b)
			
			if a == p1 or b == p1 then
				
				return
			end
			
			local pos1 = a-p1
			local pos2 = b-p1
				
			local a1 = math.atan2(pos1.y,pos1.x)
			local a2 = math.atan2(pos2.y,pos2.x)
				
			return a1 < a2
		end)
						
		for i=1,#UVs-2 do
			
			local p2 = planePos+r*UVs[i].y+u*UVs[i].x
			local p3 = planePos+r*UVs[i+1].y+u*UVs[i+1].x
								
			table.insert(m2,{surfaceTbl[1],p2,p3})
		end
	end
			
	return m2
end


//PhysObj implementation

local meta = FindMetaTable("PhysObj")

function meta:Clip(pos,norm,mirror)

	//self:EnableCollisions(false)

	local t = {}
	
	local m1,m2
	
	local m = self:GetMesh()
	
	//pack as triangles
	//PrintTable(m)
	local count = table.Count(m)
	//print(count)
	local nm = {}
	for ver = 1, count/3 do
		//print(ver)
		nm[ver] = {}
		for i = 0,2 do
			//print(ver, i, m[(ver-1)*3+i + 1], (ver-1)*3 + i + 1)
			if m[(ver-1)*3 + i + 1] then
				nm[ver][i] = m[(ver-1)*3+i + 1].pos
			end
		end
	end
	
	
	//for i=1,count/3 do
		//local m = self:GetConvexMesh(i)
		//local mm = nm[i]
		if mirror then
		
			m1 = Split(nm,pos,norm,0)
			m2 = Split(nm,pos,norm,1)
				
			table.insert(t,m1)
			table.insert(t,m2)
		else
		
			m1 = Split(nm,pos,norm)
			
			table.insert(t,m1)
		end
	//end
	
	//unpack triangles
	//PrintTable(t)
	local nt = {}
	local cur = 1
	for k,tri in pairs(t[1]) do
		for k,v in pairs(tri) do
			nt[cur] = {}
			nt[cur].pos = v
			cur = cur + 1
		end
	end
	t = nt
	//PrintTable(t)
	//local valid = false
	
	//for i=1,#t do
		//if t[i] and t[i][1] then
		
		//	valid = true
		//	break
		//end
	//end
	
	//if !valid then
	
		//self:EnableCollisions(true)
		//return false
	//end
		
	local values = {}
	
	/*for k,v in pairs(meta) do
		if k:find("^Get") and meta["Set"..k:sub(4)] then
		
			values[k:sub(4)] = {v(self)}
		end
	end*/
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local mass = mirror and self:GetMass()*2 or self:GetMass()
	local damp = self:GetDamping()
	local rotDamp = self:GetRotDamping()
	local ent = self:GetEntity()
		
	//self:RebuildFromConvexs(pos,ang,mass,damp,rotDamp,0.5,0.5,t)
	//ent:PhysicsInitFromVerts( t, false )
	ent:PhysicsFromMesh(t)
	
	/*for k,v in pairs(values) do
	
		self["Set"..k](self,unpack(v))
	end*/
	
	//self:EnableCollisions(true)
	ent:EnableCustomCollisions(true)
	
	return true
end