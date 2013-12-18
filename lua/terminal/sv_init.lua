if (SERVER) then
	include("sh_init.lua");
	include("sv_filesystem.lua");

	AddCSLuaFile("sh_init.lua");

	util.AddNetworkString("T_ActiveConsole");
	util.AddNetworkString("T_EndConsole");
	util.AddNetworkString("T_AddChar");
	util.AddNetworkString("T_EndTyping");

	Terminal = Terminal or {};
	Terminal.os = Terminal.os or {};

	local Terminal = Terminal;
	local net = net;

	function Terminal:Broadcast(entity, str, colorType, position)
		for c in str:gmatch"." do
			Terminal:PrintChar(entity, tostring(c), colorType, position)
		end
	end

	function Terminal:Clear(entity)
		Terminal:PrintChar(entity, nil, nil, nil, 0)
	end

	function Terminal:FillLine(entity)
		Terminal:PrintChar(entity, nil, nil, nil, 1)
	end

	function Terminal:PrintChar(entity, char, colorType, position, tyype)
		if ( !IsValid(entity) ) then
			return;
		end;

		net.Start("T_AddChar");
			net.WriteUInt(entity:EntIndex(), 16);
			net.WriteString(char or " ");
			net.WriteUInt(colorType or T_COL_MSG, 8);
			net.WriteInt(position or -1, 16);
			net.WriteInt(tyype or -1, 16);
		net.Broadcast();
	end;

	function Terminal:GetInput(entity, Callback)
		entity.acceptingInput = true;
		entity.inputCallback = Callback;
	end;

	net.Receive("T_EndConsole", function(length, client)
		local index = net.ReadUInt(16);
		local entity = Entity(index);
		local text = net.ReadString();

		if (IsValid(entity) and entity.GetUser and IsValid( entity:GetUser() ) and entity:GetUser() == client) then
			if (text == "" or text == " ") then
				entity:SetUser(nil);

				net.Start("T_EndTyping");
				net.Send(client);

				return;
			end;

			local command = text;
			local quote = (string.sub(command, 1, 1) != "\"");
			local arguments = {};

			for chunk in string.gmatch(command, "[^\"]+") do
				quote = !quote;

				if (quote) then
					table.insert(arguments, chunk);
				else
					for chunk in string.gmatch(chunk, "[^ ]+") do
						table.insert(arguments, chunk);
					end;
				end;
			end;
			if (entity.Command != nil) then
				local a = entity:Command(arguments);
				if (a != nil and a == true) then return; end;
			end;

			Terminal:Broadcast(entity, text, T_COL_NIL);
		end;
	end);

	local files, folders = file.Find("Terminal/os/*", "LUA");

	Terminal.os = {}
	for k, v in pairs(folders) do
		OS = {};
		include("os/"..v.."/init.lua");
		Terminal.os[v] = OS;
		OS = nil;
	end;

	Msg("Initialized serverside Terminal!\n");
end