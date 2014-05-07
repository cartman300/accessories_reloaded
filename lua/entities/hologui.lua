if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Hologui"
ENT.Author = "Cartman300"
ENT.Category = "Cartmanium"
ENT.WireDebugName = ENT.PrintName
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:Initialize()
	self:SetModel("models/sprops/rectangles/size_4_5/rect_42x66x3.mdl")
	
	if (SERVER) then
	
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
	
	elseif (CLIENT) then
		
		self.Screen = self:CreateHolo(0, 0, 660, 420)

	end
end

function ENT:SetupDataTables()
	--[[self:NetworkVar("Bool", 0, "Screen", { KeyName = "Screen", Edit = { type = "Boolean", order = 1 } })
	self:NetworkVar("String", 0, "Text", { KeyName = "Text", Edit = { type = "String", order = 2 } })
	self:NetworkVar("String", 1, "Font", { KeyName = "Font", Edit = { type = "String", order = 3 } })
	
	self:SetText("NO SIGNAL")
	self:SetScreen(false)
	self:SetFont("cap_console_font")]]--
end

if (SERVER) then
	AddCSLuaFile();
	
	function ENT:SpawnFunction(ply, tr)
		if (not tr.Hit) then return end

		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), 270)
		ang:RotateAroundAxis(ang:Up(), 90)

		local ent = ents.Create("hologui")
		ent:SetAngles(ang)
		ent:SetPos(tr.HitPos + Vector(0, 0, 0))
		ent:Spawn()
		ent:Activate()
		ent.Owner = ply

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
		
		return ent
	end

	function ENT:Use(ply)
	end
	
	function ENT:Think()
		self:NextThink(CurTime() + 0.2);
	end

elseif (CLIENT) then
	function ENT:DrawTranslucent()
		if (self.Screen) then
			local Ang = self:GetAngles()
			local Pos = self:GetPos() + self:GetUp() * 2 + self:GetRight() * -21 + self:GetForward() * -33
						
			self.Screen:Draw(Pos, Ang, .1)
		end
	end
	
	function ENT:Think()
		self:NextThink(CurTime() + 0.2)
	end
end