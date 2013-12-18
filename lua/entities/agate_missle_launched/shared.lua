ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "MissileW"
ENT.Author			= "thebigalex, cartman300"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.follow			= nil
ENT.Owner			= nil
ENT.Exploded			= false
ENT.LastPosition		= Vector(0,0,0)
ENT.XCo				= nil
ENT.YCo				= nil
ENT.ZCo				= nil
ENT.Target			= Vector(0,0,0)
ENT.PhysObj			= nil
ENT.Locked			= false
ENT.PreLaunch			= false
ENT.STime			= nil
ENT.LTime			= nil
ENT.ParL			= nil

function ENT:SetOn( Int )
	self.Entity:SetNetworkedInt( "On", Int )
end

function ENT:IsOn()
	return self.Entity:GetNetworkedInt( "On" )
end
