Multiskybox = Multiskybox or {}
local function MS_Init(Key, Val)
	Multiskybox[Key] = Multiskybox[Key] or Val
end

local function DevMsg(...)
	if (Multiskybox.Developer) then
		print(...)
	end
end

local TYPE_STRING = type("Hello")
local TYPE_BOOL = type(true)
local TYPE_NUMBER = type(1)

local function typeof(a, b)
	if (type(a) == b) then return end
	error("Expected " .. tostring(b) .. ", got " .. type(a))
end

Multiskybox._Started = false
Multiskybox.Enabled = false
Multiskybox.Developer = true

Multiskybox.MSG_NONE = 0
Multiskybox.MSG_LIGHTMAP_CHANGE = 1
Multiskybox.MSG_SKYBOX_ENABLE = 2

net.Receive("Multiskybox", function()
	local MsgType = net.ReadInt(8)
	
	if (CLIENT) then
	
		if (MsgType == Multiskybox.MSG_LIGHTMAP_CHANGE) then
			Multiskybox.LightmapFx = net.ReadString()
			timer.Simple(.1, function()
					DevMsg("Multiskybox: Redownloading lightmaps for \"" .. Multiskybox.LightmapFx .. "\"")
					render.RedownloadAllLightmaps()
				end)
		elseif (MsgType == Multiskybox.MSG_SKYBOX_ENABLE) then
			Multiskybox.Enabled = net.ReadBit(true)
			DevMsg("Multiskybox enabled:", Multiskybox.Enabled)
		else
			print("Received unknown MSG_:", MsgType)
		end

	end
end)

function Multiskybox.Start(MsgType)
	if (Multiskybox._Started) then
		error("Call Multiskybox.End() first before calling Start() again!")
		return
	end
	Multiskybox._Started = true
	
	typeof(MsgType, TYPE_NUMBER)

	net.Start("Multiskybox")
	net.WriteInt(MsgType, 8)
end

function Multiskybox.End()
	if (Multiskybox._Started == false) then
		error("Call Multiskybox.Start() first before calling End() again!")
		return
	end

	if (CLIENT) then
		net.SendToServer()
	elseif (SERVER) then
		net.Broadcast()
	end
	
	Multiskybox._Started = false
end

if (SERVER) then
	AddCSLuaFile()
	util.AddNetworkString("Multiskybox")
	
	function Multiskybox.Lightmap(Fx)
		Multiskybox.Start(Multiskybox.MSG_LIGHTMAP_CHANGE)
		net.WriteString(Fx or "m")
		engine.LightStyle(0, Fx or "m")
		Multiskybox.End()
	end
	
	function Multiskybox.Enable(DoEnable)
		Multiskybox.Start(Multiskybox.MSG_SKYBOX_ENABLE)
		net.WriteBit(DoEnable and true or false)
		Multiskybox.Enabled = DoEnable and true or false
		Multiskybox.End()
	end
	
elseif (CLIENT) then
	MS_Init("UP", Material("skybox/trainup"))
	MS_Init("LEFT", Material("skybox/trainlf"))
	MS_Init("RIGHT", Material("skybox/trainrt"))
	MS_Init("FRONT", Material("skybox/trainft"))
	MS_Init("BACK", Material("skybox/trainbk"))

	hook.Add("PostDraw2DSkyBox", "Multiskybox", function()
		if (Multiskybox.Enabled) then
			render.Clear(100, 100, 100, 255, false, false)
			
			render.OverrideDepthEnable( true, false )
			render.SetLightingMode(2)
			
			cam.Start3D(Vector(0, 0, 0), EyeAngles())
				render.SetMaterial(Multiskybox.RIGHT)
				render.DrawQuadEasy(Vector(32,0,0), Vector(-1,0,0), 64, 64, Color(255,255,255), 180)
				render.SetMaterial(Multiskybox.LEFT)
				render.DrawQuadEasy(Vector(-32,0,0), Vector(1,0,0), 64, 64, Color(255,255,255), 180)
				render.SetMaterial(Multiskybox.BACK)
				render.DrawQuadEasy(Vector(0,32,0), Vector(0,-1,0), 64, 64, Color(255,255,255), 180)
				render.SetMaterial(Multiskybox.FRONT)
				render.DrawQuadEasy(Vector(0,-32,0), Vector(0,1,0), 64, 64, Color(255,255,255), 180)
				render.SetMaterial(Multiskybox.UP)
				render.DrawQuadEasy(Vector(0,0,32), Vector(0,0,-1), 64, 64, Color(255,255,255), 0)
			cam.End3D()

			render.OverrideDepthEnable( false, false )
			render.SetLightingMode(0)
			
		end
	end)

end