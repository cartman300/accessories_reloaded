/*
Hey you! You are reading my code!
I want to say that my code is far from perfect, and if you see that I'm doing something
in a really wrong/dumb way, please give me advices instead of saying "LOL U BAD CODER"
        Thanks
      - MadJawa
*/

LaserLib = LaserLib or {};


//////////////////////////////
////       Shared Functions       ////
//////////////////////////////

function LaserLib.GetReflectedVector( incidentVector, surfaceNormal )

	return incidentVector - 2 * ( surfaceNormal:DotProduct( incidentVector ) * surfaceNormal );

end

function LaserLib.DoBeam ( laserEnt, beamDir, beamStart, beamLength, ... )
	local trace = {};
	
	local beamStart = util.LocalToWorld(laserEnt, beamStart);
	
	laserEnt.IgnoreList = laserEnt.IgnoreList or {};
	local beamFilter = table.Copy(laserEnt.IgnoreList);
	table.insert(beamFilter, laserEnt);
	
	if ( SERVER ) then
		inflictor = laserEnt.ply;
		beamDamage = unpack({...});
		laserEnt.Targets = {}; -- we'll store here what we hit
	end
	
	if ( CLIENT ) then
		beamPoints = { beamStart };
		beamIgnore = {};
		beamWidth, beamMaterial = unpack({...});
	end

	local bounces = 0;

	repeat
		//if ( StarGate ~= nil ) then
			//trace = StarGate.Trace:New( beamStart, beamDir:Normalize() * beamLength, beamFilter );
		//else
			trace = util.QuickTrace( beamStart, beamDir * beamLength, beamFilter );
		//end
		
		if ( CLIENT ) then table.insert( beamPoints, trace.HitPos ); end
		
		-- we can bounce!
		if ( trace.Entity and trace.Entity:IsValid() and
			( ( (trace.Entity:GetClass() == "event_horizon" and ValidEntity(trace.Entity.Target)
			and trace.Entity:GetForward():DotProduct(trace.Normal) < 0 and trace.Entity ~= trace.Entity.Target)
			or trace.Entity:GetModel() == "models/madjawa/laser_reflector.mdl"
			or trace.Entity:GetMaterial() == "debug/env_cubemap_model" )
			and trace.Entity:GetClass() ~= "gmod_laser_crystal" ) ) then
			
			isMirror = true;
			
			beamFilter = table.Copy(laserEnt.IgnoreList);
			table.insert(beamFilter, trace.Entity);
			if (trace.Entity:GetClass() == "event_horizon") then
				if (not (CLIENT and not trace.Entity.DrawRipple) // HAX
				and not (SERVER and (not trace.Entity:IsOpen() or trace.Entity.ShuttingDown))) then -- STARGATE!
					beamStart, beamDir = trace.Entity:GetTeleportedVector(trace.HitPos, beamDir);
					if (CLIENT) then
						local n = table.insert( beamPoints, beamStart );
						beamIgnore[n] = true; -- prevents from rendering a beam between the two stargates
					end
					table.insert(beamFilter, trace.Entity.Target);
					if (SERVER) then
						trace.Entity:EnterEffect(trace.HitPos, laserEnt:GetBeamWidth());
						trace.Entity.Target:EnterEffect(beamStart, laserEnt:GetBeamWidth());
					end
				else isMirror = false;
				end
			else
				beamStart = trace.HitPos;
				beamDir = LaserLib.GetReflectedVector( beamDir, trace.HitNormal );
			end
			beamLength = beamLength - beamLength * trace.Fraction;
			
		elseif (SERVER and trace.Entity and trace.Entity:GetClass() == "event_horizon") then
			trace.Entity:EnterEffect(trace.HitPos, laserEnt:GetBeamWidth());
		else
			isMirror = false;
		end
		
		bounces = bounces + 1;
		
		if ( SERVER ) then		
			if ( trace.Entity  and
			( trace.Entity:GetClass() == "gmod_laser_reflector" or trace.Entity:GetClass() == "gmod_laser_crystal" )
			and not table.HasValue( trace.Entity.Hits, laserEnt ) ) then
				trace.Entity:UpdateBounceCount(laserEnt);
			end
		end
		
		if (SERVER and trace.Entity ) then table.insert(laserEnt.Targets, trace.Entity); end
		
	until ( isMirror == false or bounces > GetConVar("laser_maxbounces"):GetInt() )

	if(	SERVER and beamDamage > 0 and trace.Entity and trace.Entity:IsValid() and trace.Entity:GetClass() ~= "gmod_laser_crystal" and
			trace.Entity:GetClass() ~= "gmod_laser" and trace.Entity:GetModel() ~= "models/madjawa/laser_reflector.mdl" ) then
				
			LaserLib.DoDamage(	trace.Entity, trace.HitPos, trace.Normal, beamDir, beamDamage, inflictor,
								laserEnt:GetDissolveType(), laserEnt:GetPushProps(), laserEnt:GetKillSound() , laserEnt );
				
	end
	
	if ( CLIENT ) then
		--Fucking FIXME: weird bugs/shadows/laser disappearing seem to caused by renderbounds
		local prevPoint = beamPoints[1];
		local bbmin, bbmax = laserEnt:GetRenderBounds();
		
		if not matTab or not matTab[beamMaterial] then
			matTab[beamMaterial] = Material(beamMaterial);
		end
		render.SetMaterial( matTab[beamMaterial] );
		
		for k, v in pairs ( beamPoints ) do
			if ( prevPoint ~= v and not beamIgnore[k]==true) then
				render.DrawBeam( prevPoint, v, beamWidth, 13*CurTime(), 13*CurTime() - ( v - prevPoint ):Length()/9, Color( 255, 255, 255, 255 ) );
			end
			prevPoint = v;
			
			local pos = laserEnt:WorldToLocal(v);
			if ( pos.x < bbmin.x ) then bbmin.x = pos.x; end
			if ( pos.y < bbmin.y ) then bbmin.y = pos.y; end
			if ( pos.z < bbmin.z ) then bbmin.z = pos.z; end
			if ( pos.x > bbmax.x ) then bbmax.x = pos.x; end
			if ( pos.y > bbmax.y ) then bbmax.y = pos.y; end
			if ( pos.z > bbmax.z ) then bbmax.z = pos.z; end
		end
		
		laserEnt.NextEffect = laserEnt.NextEffect or CurTime();
		if ( not trace.HitSky and laserEnt:GetEndingEffect() and CurTime() >= laserEnt.NextEffect ) then
			if ( trace.Entity and trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_laser_crystal" ) then return; end
			
			if not (trace.Entity:IsValid() and trace.Entity:GetClass() == "event_horizon") then
				local effectdata = EffectData();
					effectdata:SetStart( trace.HitPos );
					effectdata:SetOrigin( trace.HitPos );
					effectdata:SetNormal( trace.HitNormal );
					effectdata:SetScale( 1 );
				util.Effect( "AR2Impact", effectdata );
			end
			laserEnt.NextEffect = CurTime() + 0.1;
		end
		
		laserEnt:SetRenderBounds( bbmin, bbmax, Vector()*6 );
	end
	
	return trace.Entity;
end


//////////////////////////////
////       Server Functions       ////
//////////////////////////////

if ( SERVER ) then

	AddCSLuaFile( "autorun/laserlib.lua" );

	function LaserLib.SpawnDissolver( ent, position, attacker, dissolveType )
		Dissolver = ents.Create( "env_entity_dissolver" );
		Dissolver.Target = "laserdissolve"..ent:EntIndex();
		Dissolver:SetKeyValue( "dissolvetype", dissolveType );
		Dissolver:SetKeyValue( "magnitude", 0 );
		Dissolver:SetPos( position );
		Dissolver:SetPhysicsAttacker( attacker );
		Dissolver:Spawn();
		
		return Dissolver;
	end
	
	function LaserLib.DoDamage( target, hitPos, normal, beamDir, damage, attacker, dissolveType, pushProps, killSound, laserEnt )
		
		laserEnt.NextLaserDamage = laserEnt.NextLaserDamage or CurTime();
	
		if ( pushProps and target:GetPhysicsObject():IsValid() ) then
			local phys = target:GetPhysicsObject();
			local mass = phys:GetMass();
			local mul = math.Clamp( mass * 10, 0, 2000 );
			if ( mul ~= 0 and mass <= 500 ) then
				phys:ApplyForceOffset( beamDir * mul, hitPos );
			end
		end
		
		if ( target:GetClass() == "weapon_striderbuster" ) then return end;
		
		if ( CurTime() >= laserEnt.NextLaserDamage ) then
			if ( target:IsVehicle() and target:GetDriver():IsValid() ) then -- we must kill the driver!
				target = target:GetDriver();
				target:Kill(); -- takedamage doesn't seem to work on a player inside a vehicle
			end		
			
			if ( target:GetClass() == "shield" ) then
				target:Hit( laserEnt, hitPos, math.Clamp( damage / 2500 * 3, 0, 4), -1*normal );
				laserEnt.NextLaserDamage = CurTime() + 0.3;
				return; -- we stop here because we hit a shield
			end
			
			if ( target:Health() <= damage ) then
				if ( target:IsNPC() or target:IsPlayer() ) then
					local dissolverEnt = LaserLib.SpawnDissolver( laserEnt, target:GetPos(), attacker, dissolveType );
					
					-- dissolving the NPC's weapon too
					if ( target:IsNPC() and target:GetActiveWeapon():IsValid() ) then target:GetActiveWeapon():SetName( dissolverEnt.Target ); end
					
					target:TakeDamage( damage, attacker, laserEnt ); -- we kill the player/NPC to get his ragdoll
					
					if ( target:IsPlayer() ) then
						if ( not target:GetRagdollEntity() or not target:GetRagdollEntity():IsValid() ) then return; end
						target:GetRagdollEntity():SetName( dissolverEnt.Target ); -- thanks to Nevec for the player ragdoll idea, allowing us to dissolve him the cleanest way
					else
						if ( target.DeathRagdoll and target.DeathRagdoll:IsValid() ) then -- if Keep Corpses is disabled, DeathRagdoll is nil, so we need to check this
							target.DeathRagdoll:SetName( dissolverEnt.Target );
						else
							target:SetName( dissolverEnt.Target );
						end
					end
					
					dissolverEnt:Fire( "Dissolve", dissolverEnt.Target, 0 );
					dissolverEnt:Fire( "Kill", "", 0.1 );
					dissolverEnt:Remove(); -- Makes sure it's removed. It MIGHT prevent the "no free edicts" error (I don't see what other entity could cause it right now)
				end
				
				if ( killSound ~= nil and ( target:Health() ~= 0 or target:IsPlayer() ) ) then
					//WorldSound( killSound , target:GetPos(), 160, 130);
					target:EmitSound( killSound, 500, 200 );
				end
			else
				laserEnt.NextLaserDamage = CurTime() + 0.3;
			end
			
			target:TakeDamage( damage, attacker, laserEnt );
		end
	end	
	
	function LaserLib.AssignNPCRagdoll( entity, ragdoll )
		-- it seems that's the only clean way to get the NPC's ragdoll in the DoDamage function -- Thanks to Kogitsune
		entity.DeathRagdoll = ragdoll;
	end

	hook.Add( "CreateEntityRagdoll", "LaserLib.AssignNPCRagdoll", LaserLib.AssignNPCRagdoll );

end


//////////////////////////////
////        Client Functions         ////
//////////////////////////////

if ( CLIENT ) then
	matTab = matTab or {};
	
	function LaserLib.UpdateIgnoreList(um)
		local laserEnt = ents.GetByIndex(um:ReadLong());
		local nbEnt = um:ReadLong();
		
		laserEnt.IgnoreList = {};
		for i=1, nbEnt do
			table.insert(laserEnt.IgnoreList, ents.GetByIndex(um:ReadLong()));
		end
	end
	usermessage.Hook("Laser.UpdateIgnoreList", LaserLib.UpdateIgnoreList)  
end