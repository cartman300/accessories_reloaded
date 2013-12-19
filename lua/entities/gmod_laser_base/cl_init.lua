/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
include( "shared.lua" );

ENT.RenderGroup = RENDERGROUP_BOTH;

function ENT:Draw()
	self.Entity:DrawModel();
end

function ENT:DrawTranslucent()
	if ( self:GetOn() ) then
		-- FIXME : find a better way to render the laser (Scripted Effect?)
		LaserLib.DoBeam( self.Entity, self:GetBeamDirection(), self:GetBeamStart(), self:GetBeamLength(), self:GetBeamWidth(), self:GetBeamMaterial() );
	end
	self.Entity:DrawShadow(false); -- temporary fix for the weird shadows bug
end