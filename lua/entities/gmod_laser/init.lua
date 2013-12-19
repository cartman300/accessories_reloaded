/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

resource.AddFile( "materials/VGUI/entities/gmod_laser_killicon.vtf" );
resource.AddFile( "materials/VGUI/entities/gmod_laser_killicon.vmt" );


function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	
	local phys = self.Entity:GetPhysicsObject();
	if ( phys:IsValid() ) then
		phys:Wake();
	end
	
	self.Targets = {};
	
	if WireAddon then
		self.Inputs = Wire_CreateInputs( self.Entity, { "On", "Length", "Width", "Damage" } );
		self.Outputs = Wire_CreateOutputs( self.Entity, { "On", "Length", "Width", "Damage", "Hit" } );
	end
	
end

//
//self:GetDamageAmmount()
function ENT:Think()

	if ( self:GetOn() ) then

		local target = LaserLib.DoBeam( self.Entity, self:GetBeamDirection(), self:GetBeamStart(),  self:GetBeamLength(),  self:GetDamageAmmount() );
		
		if WireAddon then
			if ( target and target:IsValid() ) then
				Wire_TriggerOutput( self.Entity, "Hit", 1 );
			else
				Wire_TriggerOutput( self.Entity, "Hit", 0 );
			end
		end
	end
	
	self.Entity:NextThink( CurTime() + 0.1 );
	return true;

end


function ENT:TriggerInput( iname, value )

	if ( iname == "On" ) then
		self:SetOn( util.tobool( value ) );
	elseif ( iname == "Length" ) then
		if ( value == 0 ) then value = self.defaultLength; end
		self:SetBeamLength( value );
	elseif ( iname == "Width" ) then
		if ( value == 0 ) then value = self.defaultWidth; end
		self:SetBeamWidth( value );
	elseif ( iname == "Damage" ) then
		self:SetDamageAmmount( value );
	end

end



local function On( ply, ent )

	if ( not ent or ent == NULL ) then return; end
	ent:SetOn( !ent:GetOn() );

end

local function Off( ply, ent )

	if ( not ent or ent == NULL or ent:GetToggle() ) then return; end
	ent:SetOn( !ent:GetOn() );

end

numpad.Register( "Laser_On", On ) 
numpad.Register( "Laser_Off", Off ) 