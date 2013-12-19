TOOL.Category = "Construction"
TOOL.Name = "#Clipplane"

TOOL.ClientConVar["pitch"] = 0
TOOL.ClientConVar["yaw"] = 0
TOOL.ClientConVar["distance"] = 0
TOOL.ClientConVar["mirror"] = 0

if SERVER then

	local function SendForClipping(ent,ply)
	
		if ply then
		
			umsg.Start("SendForClipping",ply)
			umsg.Entity(ent)
			umsg.Long(1)
			umsg.Vector(ent._clipPlanes[#ent._clipPlanes][1])
			umsg.Float(ent._clipPlanes[#ent._clipPlanes][2])
			umsg.Bool(ent._clipPlanes[#ent._clipPlanes][3])
			
			umsg.End()
			return
		end
		
		umsg.Start("SendForClipping")
				
		umsg.Entity(ent)
					
		umsg.Long(#ent._clipPlanes)
		
		for k,v in pairs(ent._clipPlanes) do
		
			umsg.Vector(v[1])
			umsg.Float(v[2])
			umsg.Bool(v[3])
		end
		
		umsg.End()
	end
	
	hook.Add("PlayerInitialSpawn","ClipPhysSendToClient",function(ply)
	
		for k,v in pairs(ents.FindByClass("prop_physics")) do
		
			if v._clipPlanes then
		
				SendForClipping(v,ply)
			end
		end
	end)

	duplicator.RegisterEntityModifier("clipplane",function(p,e,data)
	
		local phys = e:GetPhysicsObject()
		
		for k,v in pairs(data) do
		
			timer.Simple(k,function(e)
			
				if !IsValid(e) then return end
			
				e:GetPhysicsObject():Clip(v[1]*-v[2],v[1],v[3])
			end,e)
		end
		
		e._clipPlanes = data
		
		SendForClipping(e)
		
		duplicator.StoreEntityModifier(e,"clipplane",data)
	end)

	function TOOL:LeftClick(tr)
		
		return self:RightClick(tr)
	end

	function TOOL:RightClick(tr)

		if !(IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_physics") or CLIENT then return end
			
		local n = Angle(self:GetClientNumber("pitch",0),self:GetClientNumber("yaw",0),0):Forward()
		local d = self:GetClientNumber("distance",0)
		local m = self:GetClientNumber("mirror",0) == 1
			
		if !tr.Entity:GetPhysicsObject():Clip(n*d,n,m) then
		
			self:GetOwner():SendLua[[GAMEMODE:AddNotify("You are trying to clip the whole model, please don't crash us :)",NOTIFY_ERROR,5)]]
			return false
		end
				
		tr.Entity._clipPlanes = tr.Entity._clipPlanes or {}
		
		table.insert(tr.Entity._clipPlanes,{n,d,m})
		
		SendForClipping(tr.Entity)
		
		duplicator.StoreEntityModifier(tr.Entity,"clipplane",tr.Entity._clipPlanes)
		
		return true
	end
end

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header",{Text = "#tool.clipplane.name",Description = "#tool.clipplane.desc"})
	
	panel:AddControl("Slider",{Label = "#tool.clipplane.pitch",Command = "clipplane_pitch",Min = -180,Max = 180})
	panel:AddControl("Slider",{Label = "#tool.clipplane.yaw",Command = "clipplane_yaw",Min = -180,Max = 180})

	panel:AddControl("Slider",{Label = "#tool.clipplane.dist",Command = "clipplane_distance",Min = -500,Max = 500})
	panel:AddControl("CheckBox",{Label = "#tool.clipplane.mirror",Command = "clipplane_mirror"})
	panel:AddControl("Button",{Label = "#tool.clipplane.reset",Command = "clipplane_reset"})	
end

if CLIENT then

	language.Add("tool.clipplane.name","Physical Clipplane")
	language.Add("tool.clipplane.desc","Clips the object you shoot physically and visually")
	language.Add("tool.clipplane.pitch","Pitch")
	language.Add("tool.clipplane.yaw","Yaw")
	language.Add("tool.clipplane.dist","Distance")
	language.Add("tool.clipplane.mirror","Mirror?")
	language.Add("tool.clipplane.0","")
	
	
	concommand.Add("clipplane_reset",function()

		RunConsoleCommand("clipplane_pitch",0)
		RunConsoleCommand("clipplane_yaw",0)
		RunConsoleCommand("clipplane_distance",0)
	end)
end
