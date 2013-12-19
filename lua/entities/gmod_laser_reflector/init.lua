/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

resource.AddFile( "models/madjawa/laser_reflector.dx80.vtx" );
resource.AddFile( "models/madjawa/laser_reflector.dx90.vtx" );
resource.AddFile( "models/madjawa/laser_reflector.mdl" );
resource.AddFile( "models/madjawa/laser_reflector.phy" );
resource.AddFile( "models/madjawa/laser_reflector.sw.vtx" );
resource.AddFile( "models/madjawa/laser_reflector.vvd" );

resource.AddFile( "materials/VGUI/entities/gmod_laser_reflector.vtf" );
resource.AddFile( "materials/VGUI/entities/gmod_laser_reflector.vmt" );

include( "shared.lua" );


function ENT:SpawnFunction( ply, tr )
   
 	if not tr.Hit then return; end
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 35;
 	 
 	local ent = ents.Create( "gmod_laser_reflector" );
	ent:SetModel( "models/madjawa/laser_reflector.mdl" );
	ent:SetPos( SpawnPos );
 	ent:Spawn();
 	ent:Activate();
	ent:SetAngles( Angle( 0, ( ply:GetAimVector():Angle().y + 180 ) % 360, 0 ) ); -- Sets the right angle at spawn. Thanks to aVoN!
 	 
	return ent;
 	 
end


function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	
	local phys = self.Entity:GetPhysicsObject();
	if ( phys:IsValid() ) then
		phys:Wake();
	end
	
	self.Hits = {};
	
	if WireAddon then
		self.Outputs = Wire_CreateOutputs( self.Entity, { "Reflecting" } );
	end
	
end


function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo);
end


function ENT:Think()

	for k,v in pairs(self.Hits) do
		if (not v or not ( v and table.HasValue(v.Targets, self))) then
			table.remove(self.Hits, k);
		end
	end

	if WireAddon then Wire_TriggerOutput( self.Entity, "Reflecting", #self.Hits ); end
	
	self.Entity:NextThink( CurTime() );

	return true;

end


function ENT:OnRemove()
	if WireAddon then Wire_Remove( self.Entity ); end
end

function ENT:OnRestore()
	if WireAddon then Wire_Restored( self.Entity ); end
end

function ENT:PreEntityCopy()
    local DupeInfo = WireLib.BuildDupeInfo(self.Entity);
	
    if( DupeInfo ) then
        duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", DupeInfo );
    end
end

function ENT:PostEntityPaste( ply, ent, entities )
    if( ent.EntityMods and ent.EntityMods.WireDupeInfo ) then
        WireLib.ApplyDupeInfo( ply, ent, ent.EntityMods.WireDupeInfo, function( id ) return entities[id] end )
    end
end

function ENT:UpdateBounceCount(ent)
	if not table.HasValue(self.Hits, ent) then
		table.insert(self.Hits, ent);
	end
end