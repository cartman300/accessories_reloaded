if (SERVER) then AddCSLuaFile() end

if (CLIENT) then
	local UP = Material("skybox/trainup")
	local LEFT = Material("skybox/trainlf")
	local RIGHT = Material("skybox/trainrt")
	local FRONT = Material("skybox/trainft")
	local BACK = Material("skybox/trainbk")

	hook.Add("PostDraw2DSkyBox", "Multiskybox", function()

		
		for k,v in pairs(ents.FindByClass("prop_physics")) do
			if (v:GetPos():Distance(LocalPlayer():GetPos()) < 500 and game.GetMap() == "gm_enterprise_solution") then
			
				render.Clear(100, 100, 100, 255, false, false)
				
				render.OverrideDepthEnable( true, false )
				render.SetLightingMode(2)
				
				cam.Start3D(Vector(0, 0, 0), EyeAngles())
					render.SetMaterial(RIGHT)
					render.DrawQuadEasy(Vector(32,0,0), Vector(-1,0,0), 64, 64, Color(255,255,255), 180)
					render.SetMaterial(LEFT)
					render.DrawQuadEasy(Vector(-32,0,0), Vector(1,0,0), 64, 64, Color(255,255,255), 180)
					render.SetMaterial(BACK)
					render.DrawQuadEasy(Vector(0,32,0), Vector(0,-1,0), 64, 64, Color(255,255,255), 180)
					render.SetMaterial(FRONT)
					render.DrawQuadEasy(Vector(0,-32,0), Vector(0,1,0), 64, 64, Color(255,255,255), 180)
					render.SetMaterial(UP)
					render.DrawQuadEasy(Vector(0,0,32), Vector(0,0,-1), 64, 64, Color(255,255,255), 0)
				cam.End3D()

				render.OverrideDepthEnable( false, false )
				render.SetLightingMode(0)
				
			end
		end

	end)
end