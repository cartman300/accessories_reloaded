AddCSLuaFile()


ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true


function ENT:Initialize()


	self:SetModel( "models/alyx.mdl" );
	self:SetSkin(0)
	self:SetHealth(100)
	
	self.loco:SetDeathDropHeight(200)	//default 200
	self.loco:SetAcceleration(400)		//default 400
	self.loco:SetDeceleration(400)		//default 400
	self.loco:SetStepHeight(18)			//default 18
	self.loco:SetJumpHeight(58)		//default 58
	
	self.Isjumping = false
	
end


function ENT:Splode()
	local Boom = ents.Create("env_explosion")
	Boom:SetPos(self:GetPos())
	Boom:SetKeyValue( "iMagnitude", "90" )
//	Boom:SetOwner(self.Entity:GetOwner())
	Boom:SetOwner(self)	
	Boom:Spawn()
	Boom:Fire("Explode",0,0)
	Boom:Fire("Kill",0,0)
	self:Remove()
end

function ENT:BehaveUpdate( fInterval )
	if ( !self.BehaveThread ) then return end
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then
		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );
	end
end

function ENT:RunBehaviour()
	while ( true ) do

		pos = Entity(1):GetPos()
		local NearestStargate = nil;
		local NearestStargateDistance = 10000;

		for k,v in pairs(ents.GetAll()) do
			if v.IsStargate and v:GetPos():Distance(self:GetPos()) < NearestStargateDistance then
				NearestStargate = v;
				NearestStargateDistance = v:GetPos():Distance(self:GetPos())
			end
		end

		self.loco:FaceTowards( NearestStargate:GetPos() )
		self:StartActivity( ACT_WALK )				-- run anim
		self.loco:SetDesiredSpeed( 60 )			-- run speed	
		local opts = {	lookahead = 300,
				tolerance = 20,
				draw = true,
				maxage = 1,
				repath = 0.1	}
		self:MoveToPos( NearestStargate:GetPos() + NearestStargate:GetForward() * 300, opts )

		local ent = ents.FindInSphere( self:GetPos(), 600 )
		local DHD = nil;
		for k,v in pairs( ent ) do
			if v.IsDHD then
				DHD = v;
			end
		end	

		if (DHD != nil) then
			self.loco:FaceTowards( DHD:GetPos() )
			self:StartActivity( ACT_WALK )				-- run anim
			self.loco:SetDesiredSpeed( 60 )			-- run speed	
			self:MoveToPos( DHD:GetPos() + DHD:GetForward() * 100 + DHD:GetUp() * 30, opts )
			self:MoveToPos( DHD:GetPos() + DHD:GetForward() * 30 + DHD:GetUp() * 30, opts )
			NearestStargate:DialGate("123456", 1)
			local wat = true;
			self:StartActivity( ACT_IDLE )
			while (wat) do
				self.loco:FaceTowards(NearestStargate:GetPos())
				timer.Simple(10,function() wat = false; end)
				coroutine.yield()
			end
			self:StartActivity( ACT_WALK )
			self:MoveToPos( NearestStargate:GetPos() + NearestStargate:GetForward() * 300, opts )
			self:MoveToPos( NearestStargate:GetPos() + NearestStargate:GetForward() * -10, opts )
			NSG = NearestStargate;
			timer.Simple(1, function() NSG:AbortDialling(); NSG = nil; end)
			self:Remove()
		end
		coroutine.yield()
	end
end

function ENT:OnLandOnGround()
	self:StartActivity(ACT_LAND)
	timer.Simple(0.6,function()
		self:StartActivity(ACT_WALK)
	end)
end

function ENT:OnKilled( damageinfo )
	self:BecomeRagdoll( damageinfo )
end

list.Set( "NPC", "npc_wraith", 	{	Name = "Wraith", 
									Class = "npc_wraith",
									Category = "Stargate"	
})