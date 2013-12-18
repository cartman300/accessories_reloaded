StarGate.LifeSupportAndWire(ENT);

AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.PrintName = "Terminal";
ENT.Author = "Cartman300";
ENT.Purpose = "Computing stuff.";
ENT.WireDebugName = "Terminal";
ENT.Spawnable = true;
ENT.Category = "Stargate";

function ENT:OnRemove()
	if (CLIENT) then
		if (Terminal != nil) then Terminal[ self:EntIndex() ] = nil; end
	end;
end;

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active");
	self:NetworkVar("Bool", 1, "WarmingUp");
	self:NetworkVar("Entity", 0, "User");
	self:NetworkVar("Bool", 2, "CanWork")
end;

if (SERVER) then

	function ENT:SpawnFunction(client, trace)
		if (!trace.Hit) then
			return false;
		end;

		local entity = ents.Create(self.ClassName);
		entity:Initialize();
		entity:SetPos( trace.HitPos + Vector(0, 0, 32) );
		entity:Spawn();
		entity:Activate();
		return entity;
	end;

	function ENT:OnTakeDamage(D)
		if (self:GetCanWork()) then
			self.HEALTH = self.HEALTH - D:GetDamage()
		end
	end

	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube075x1x025.mdl");
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		self:DrawShadow(false);
		self:SetActive(false);
		self.HEALTH = 200

		if (Terminal != nil) then for k,v in pairs(Terminal.os["default"]) do
			self[k] = v;
		end end
		
		self:SetCanWork(true)

		local physicsObject = self:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;

	function ENT:OnRemove()
		if (self.Shutdown != nil) then self:Shutdown(); end;
	end;
	
	function ENT:WarmUp()
		if (self.Startup != nil) then self:Startup(); self:SetActive(true); end;
	end;

	function ENT:Use(activator, caller)
		if (self:GetCanWork()==false) then self:SetActive(!self:GetActive()); return; end;
		if (self.locked) then
			return;
		end;

		if ( self:GetActive() ) then
			if (!IsValid(self:GetUser())) then
				self:SetUser(activator);

				net.Start("T_ActiveConsole");
					net.WriteUInt(self:EntIndex(), 16);
				net.Send(activator);
			end;
		else
			self:WarmUp();
		end;

		if (self:GetActive()) then
			if self.OnUse != nil then self:OnUse(activator, caller); end;
		end
	end;
	
	function ENT:Think()
		if (self:GetCanWork()==false) then return; end;
		if (self.HEALTH<=0) then self:SetCanWork(false); for k,v in pairs(Terminal.os["bios"]) do self[k] = v; end return; end;
		if (self:GetActive() and self.Tick != nil) then self:Tick(); end;
		local user = self:GetUser();

		if ( IsValid(user) ) then
			local distance = user:GetPos():Distance( self:GetPos() );

			if ( ( !self:GetActive() and !self:GetWarmingUp() ) or distance > 96 ) then
				net.Start("T_EndTyping");
				net.Send(user);

				self:SetUser(nil);
			end;
		end;
	end;

	function ENT:TriggerInput(iname, value)
		if (self:GetCanWork()==false) then return; end;
		if (self:GetActive()) then
			if self.WireInput != nil then
				self:WireInput(iname, value)
			end
		end
	end
else       // CLIENT CRAP ###########################################################
	local math = math;
	local cam = cam;
	local render = render;
	local draw = draw;
	local surface = surface;
	local Color = Color;

	local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255);

	function ENT:Initialize()
		self.scrW = 2048;
		self.scrH = 1550;
		self.maxLines = 26;  // 26
		self.lineHeight = 57.4;  // 28.7
		self.lineLength = 37;  // 57
	end;

	function ENT:Draw()
		self:DrawModel();

		if (self:GetActive()) then
			local angle = self:GetAngles();
			angle:RotateAroundAxis(angle:Up(), 270);

			local offset = angle:Up() * 6 + angle:Forward() * -22 + angle:Right() * -16.7

			cam.Start3D2D(self:GetPos() + offset, angle, 0.0215);
				render.PushFilterMin(TEXFILTER.ANISOTROPIC);
				render.PushFilterMag(TEXFILTER.ANISOTROPIC);
					surface.SetDrawColor(5, 5, 8, 255);
					surface.DrawRect(0, 0, self.scrW, self.scrH);
					if (self:GetCanWork()==false) then
						local drw2 = math.random(0,100)
						local drw = false;
						if (drw2<90) then
							render.PopFilterMin();
							render.PopFilterMag();
							cam.End3D2D();
							return;
						end
					end

					local STDOUT = Terminal[self:EntIndex()] or {};
					local lines = {};

					local y = 1;
					local x = -1;
					for _,v in pairs(STDOUT) do
						x = x + 1;
						if (x >= self.lineLength) then
							x = 0; y = y + 1;
						end
						if (lines[y]==nil) then lines[y]={}; end;
						lines[y][x]=v;
					end

					while (lines[self.maxLines+1]!=nil) do
						table.remove(lines, 1);
					end

					for y = 1, self.maxLines do
						for x = 0, self.lineLength do 
							if (lines[y] != nil and lines[y][x] != nil) then 
								local color = Terminal:ColorFromIndex(lines[y][x].color) or Color(255,255,255);
								local txt = lines[y][x].text or "";
								draw.SimpleText(txt, "T_ConsoleFont", 1 + 56 * x, self.lineHeight * (y - 1), color, 0, 0);
							end
						end
					end;

					local y = (self.maxLines) * self.lineHeight;

					surface.SetDrawColor(255, 255, 255, 15);
					surface.DrawRect(0, y, self.scrW - 1, self.lineHeight);

					if ( IsValid( self:GetUser() ) ) then
						if ( self:GetUser() != LocalPlayer() ) then
							self.consoleText = self:GetUser():Name().." is typing...";
						end;
					else
						self.consoleText = "";
					end;

					draw.SimpleText("> ".. (self.consoleText or ""), "T_ConsoleFont", 1, y, color_white, 0, 0);

					if ( self:GetWarmingUp() ) then
						if (!self.flashTime) then
							
						end;
						

						

					elseif (self.flashTime) then
						self.flashTime = nil;
					end;
				render.PopFilterMin();
				render.PopFilterMag();
			cam.End3D2D();
		else
			local angle = self:GetAngles();
			angle:RotateAroundAxis(angle:Up(), 270);
			local offset = angle:Up() * 6 + angle:Forward() * -22 + angle:Right() * -16.7
			cam.Start3D2D(self:GetPos() + offset, angle, 0.0215);
				surface.SetDrawColor(0, 0, 0, 255);
				surface.DrawRect(0, 0, self.scrW, self.scrH);
			cam.End3D2D();
		end;
	end;
end;
