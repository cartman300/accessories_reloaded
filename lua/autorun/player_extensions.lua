local Ply = FindMetaTable("Player")

function Ply:Radiation()
	return self:GetNWInt("Rad.Gamma")
end

if SERVER then
	AddCSLuaFile()

	hook.Add("PlayerSpawn", "RadDeathhandler", function(Ply)
		Ply:SetRadiation(0)
	end)
	
	function Ply:Irradiate(IncRate)
		for i=1, IncRate do
			timer.Simple(1 / IncRate * i, function()
				self:IncRadiation(1)
			end)
		end
	end

	function Ply:SetRadiation(Val)
		if (Val == nil or type(Val) != "number") then return nil end
		if (not self:Alive()) then return end
		if (Val > 3000) then
			self:SetNWInt("Rad.Gamma", 0)
			self:Kill()
		else
			self:SetNWInt("Rad.Gamma", Val)
		end
	end
	
	function Ply:IncRadiation(Val)
		self:SendLua("LocalPlayer():Geiger()")
		self:SetRadiation(self:Radiation() + Val or 0)
	end
else
	local LastGeiger = CurTime()

	function Ply:Geiger(PlaySound)
		if (PlaySound == nil or PlaySound) then surface.PlaySound("radioactive/geiger" .. math.random(1, 5) .. ".mp3") end
		LastGeiger = CurTime()
	end	
	
	function Ply:ShouldShowGeiger()
		if LastGeiger + 3 < CurTime() then return false end
		return true
	end
end