/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
ENT.Type 			= "anim";
ENT.Base			= "base_anim";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

CreateConVar( "laser_maxbounces", "15", {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE} );

/* ----------------------
	Width
---------------------- */
function ENT:SetBeamWidth( num, forceValue )
	self.oldWidth = self:GetBeamWidth() or 0;
	local width;
	if not forceValue then
		width = math.Clamp( num, 1, 100 );
	else
		width = num;
	end;
	self.Entity:SetNetworkedInt( "Width", width );
	if WireAddon then Wire_TriggerOutput( self.Entity, "Width", width ); end
	self.IsModified = true;
end

function ENT:GetBeamWidth()
	return self.Entity:GetNetworkedInt( "Width" );
end


/* ----------------------
	 Length
---------------------- */
function ENT:SetBeamLength( num )
	self.oldLength = self:GetBeamLength() or 0;
	local length = math.abs( num );
	self.Entity:SetNetworkedInt( "Length", length );
	if WireAddon then Wire_TriggerOutput( self.Entity, "Length", length ); end
	self.IsModified = true;
end

function ENT:GetBeamLength()
	return self.Entity:GetNetworkedInt( "Length" );
end


/* ----------------------
	Damage
---------------------- */
function ENT:SetDamageAmmount( num )
	self.oldDamage = self:GetDamageAmmount() or 0;
	local damage = math.Round( num );
	self.damage = damage;
	if WireAddon then Wire_TriggerOutput( self.Entity, "Damage", damage ); end
	self.IsModified = true;
end

function ENT:GetDamageAmmount()
	return self.damage;
end


/* ----------------------
	Material
---------------------- */
function ENT:SetBeamMaterial ( material )
	self.Entity:SetNetworkedString( "Material", material );
	self.IsModified = true;
end

function ENT:GetBeamMaterial()
	return self.Entity:GetNetworkedString( "Material" );
end


/* ----------------------
      Dissolve type
---------------------- */
function ENT:SetDissolveType( dissolvetype )
	self.dissolveType = dissolvetype;
	self.IsModified = true;
end

function ENT:GetDissolveType()
	local dissolvetype = self.dissolveType;
	
	if ( dissolvetype == "energy" ) then return 0;
	elseif ( dissolvetype == "lightelec" ) then return 2;
	elseif ( dissolvetype == "heavyelec" ) then return 1;
	else return 3; end
end


/* ----------------------
          Sounds
---------------------- */
function ENT:SetStartSound( sound )
	self.startSound = sound;
end

function ENT:GetStartSound()
	return self.startSound;
end

function ENT:SetStopSound( sound )
	self.stopSound = sound;
end

function ENT:GetStopSound()
	return self.stopSound;
end

function ENT:SetKillSound( sound )
	self.killSound = sound;
end

function ENT:GetKillSound()
	return self.killSound;
end


/* ----------------------
	Toggle
---------------------- */
function ENT:SetToggle( bool )
	self.toggle = bool;
end

function ENT:GetToggle()
	return self.toggle;
end


/* ----------------------
	On/Off
---------------------- */
function ENT:SetOn( bool )
	if ( bool ~= self.Entity:GetOn() ) then
		if ( bool == true and self.Entity:GetStartSound() ) then
			self.Entity:EmitSound( Sound( self.Entity:GetStartSound() ) );
		elseif( self.Entity:GetStopSound() ) then
			self.Entity:EmitSound( Sound( self.Entity:GetStopSound() ) );
		end
		self.Targets = {};
	end
	
	self.Entity:SetNetworkedBool( "On", bool );
	
	if WireAddon then
		local wireBool = 0;
		if ( bool == true ) then wireBool = 1; end
		Wire_TriggerOutput( self.Entity, "On", wireBool );
	end
end

function ENT:GetOn()
	return self.Entity:GetNetworkedBool( "On" );
end


/* ----------------------
      Prop pushing
---------------------- */
function ENT:SetPushProps( bool )
	self.pushProps = bool;
	self.IsModified = true;
end

function ENT:GetPushProps()
	return self.pushProps;
end


/* ----------------------
     Ending Effect
---------------------- */
function ENT:SetEndingEffect ( bool )
	self.Entity:SetNetworkedBool( "EndingEffect", bool );
	self.IsModified = true;
end

function ENT:GetEndingEffect()
	return self.Entity:GetNetworkedBool( "EndingEffect" );
end