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

function ENT:OnRemove()
	if WireAddon then Wire_Remove( self.Entity ); end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo);
end

function ENT:OnRestore()
	if WireAddon then Wire_Restored( self.Entity ); end
end

// Wire Adv. Dupe support, thanks to Wiremod forums
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