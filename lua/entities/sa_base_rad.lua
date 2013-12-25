StarGate.LifeSupportAndWire(ENT); -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "sa_base"
ENT.PrintName = "Base Rad Prop"
ENT.Author = "Cartman300"
ENT.Contact = "Cartman300@net.hr"
ENT.Pack = "CAltP"
ENT.Category = ENT.Pack
ENT.WireDebugName = "Base Rad Prop"
ENT.PrintName = "Base Rad Prop"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (SERVER) then
	ENT.LastRadThink = CurTime()
	ENT.RadIntensity = 50
	ENT.RadDistance = 500
	
	function ENT:RadThink()
		if (self.LastRadThink + 1 < CurTime()) then
			self.LastRadThink = CurTime()
			for k,v in pairs(player.GetAll()) do
				local Dist = self:GetPos():Distance(v:GetPos())
				if Dist < self.RadDistance then
					v:Irradiate(self.RadIntensity * (self.RadDistance - Dist) / self.RadDistance)
				end
			end
		end
	end

	function ENT:Think()
		self:RadThink()
		self.Entity:NextThink(CurTime()+1);
		return true;
	end
end