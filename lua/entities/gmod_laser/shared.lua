/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
ENT.Type 			= "anim";
ENT.Base			= "gmod_laser_base";
ENT.PrintName		= "Laser";
ENT.WireDebugName	= "Laser";
ENT.Author			= "MadJawa";
ENT.Information		= "";
ENT.Category		= "";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;


function ENT:Setup( width, length, damage, material, dissolveType, startSound, stopSound, killSound, toggle, startOn, pushProps, endingEffect, update )
	self.Entity:SetBeamWidth( width );
	self.defaultWidth = width;
	self.Entity:SetBeamLength( length );
	self.defaultLength = length;
	self.Entity:SetDamageAmmount( damage );
	self.Entity:SetBeamMaterial( material );
	self.Entity:SetDissolveType( dissolveType );
	self.Entity:SetStartSound( startSound );
	self.Entity:SetStopSound( stopSound );
	self.Entity:SetKillSound( killSound );
	self.Entity:SetToggle( toggle );
	if ( ( not toggle and update ) or ( not update ) ) then self.Entity:SetOn( startOn ); end
	self.Entity:SetPushProps( pushProps );
	self.Entity:SetEndingEffect( endingEffect );
	
	if ( update ) then
		local ttable = {
			width = width,
			length = length,
			damage = damage,
			material = material,
			dissolveType = dissolveType,
			startSound = startSound,
			stopSound = stopSound,
			killSound = killSound,
			toggle = toggle,
			startOn = startOn,
			pushProps = pushProps,
			endingEffect = endingEffect
		}
		table.Merge(self.Entity:GetTable(), ttable );
	end
end

function ENT:GetBeamDirection()
	local angleOffset = self:GetAngleOffset();
	if ( angleOffset==90 ) then return self.Entity:GetForward();
	elseif ( angleOffset==180 ) then return -1*self.Entity:GetUp();
	elseif ( angleOffset==270 ) then return -1*self.Entity:GetForward();
	else return self.Entity:GetUp(); end
end

function ENT:GetBeamStart()
	local angleOffset = self:GetAngleOffset();
	local startOffset = self:GetStartOffset();
	if ( angleOffset==90 ) then return Vector(self:OBBMaxs().z+startOffset, 0, 0);
	elseif ( angleOffset==180 ) then return Vector(0, 0, -(self:OBBMaxs().z+startOffset));
	elseif ( angleOffset==270 ) then return Vector(-(self:OBBMaxs().z+startOffset), 0, 0);
	else return Vector(0, 0, self:OBBMaxs().z+startOffset); end
end

/* ----------------------
     Model Offset
---------------------- */
function ENT:SetAngleOffset( offset )
	self.Entity:SetNetworkedInt( "AngleOffset", offset );
end

function ENT:GetAngleOffset()
	return self.Entity:GetNetworkedInt( "AngleOffset" );
end

function ENT:SetStartOffset( offset )
	self.Entity:SetNetworkedInt( "StartOffset", offset );
end

function ENT:GetStartOffset()
	return self.Entity:GetNetworkedInt( "StartOffset" );
end