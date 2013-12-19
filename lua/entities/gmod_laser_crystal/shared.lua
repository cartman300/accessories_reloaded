/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
ENT.Type			= "anim";
ENT.Base			= "gmod_laser_base";
ENT.PrintName		= "Laser Crystal";
ENT.WireDebugName	= "Laser Crystal";
ENT.Author			= "MadJawa";
ENT.Information		= "Laser Crystal";
ENT.Category		= "Other";

ENT.Spawnable		= true;
ENT.AdminSpawnable	= true;


function ENT:GetBeamDirection()

	return self.Entity:GetUp(); // crystal always cast the beam in the same direction

end

function ENT:GetBeamStart()

	return Vector(0, 0, 0); // FIXME: make it not start in the middle of the prop

end