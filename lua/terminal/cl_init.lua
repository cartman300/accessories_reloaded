if (CLIENT) then 
	include("sh_init.lua");

	if surface!=nil then
		surface.CreateFont("T_ConsoleFont", {
			size = 56,
			weight = 800,
			antialias = true,
			font = "Lucida Console"
		} );
	end

	local table = table;
	local Terminal = Terminal;
	local net = net;

	net.Receive("T_AddChar", function(length)
		local index = net.ReadUInt(16);
		local text = net.ReadString();
		local colorType = net.ReadUInt(8);
		local position = net.ReadInt(16);
		local typ = net.ReadInt(16);

		if (typ==0 or !Terminal[index]) then Terminal[index] = {}; return; end;
		if (typ==1) then 
			local n = #Terminal[index] while (n>=0) do n = n - 37; end n = n + 37;
			for n2=1, 36 - n do
				table.insert(Terminal[index], {text = " ", color = 1})
			end
		end

		if (position == -1) then
			table.insert( Terminal[index], {text = text, color = colorType} );
		else
			Terminal[index][position] = {text = text, color = colorType};
		end;
	end);

	net.Receive("T_ActiveConsole", function()
		local index = net.ReadUInt(16);
		local entity = Entity(index);
		local client = LocalPlayer();
		client:DrawViewModel(false)

		if ( IsValid(entity) ) then
			client.T_Entity = entity;
			client.T_TextEntry = vgui.Create("DTextEntry");
			client.T_TextEntry:SetSize(0, 0);
			client.T_TextEntry:SetPos(0, 0);
			client.T_TextEntry:MakePopup();

			client.T_TextEntry.OnTextChanged = function(textEntry)
				local offset = 0;
				local text = textEntry:GetValue();

				if (string.len(text) > 54) then
					offset = textEntry:GetCaretPos() - 55;
				end;

				entity.consoleText = string.sub(text, offset);
			end;

			client.T_TextEntry.OnEnter = function(textEntry)
				net.Start("T_EndConsole");
					net.WriteUInt(index, 16);
					net.WriteString( tostring( textEntry:GetValue() ) );
				net.SendToServer();

				textEntry:SetText("");
				textEntry:SetCaretPos(0);

				entity.consoleText = "";
			end;
		end;
	end);

	net.Receive("T_EndTyping", function(length)
		local client = LocalPlayer();
		client:DrawViewModel(true)

		if ( !IsValid(client.T_TextEntry) ) then
			return;
		end;

		client.T_TextEntry:Remove();

		if ( IsValid(client.T_Entity) ) then
			client.T_Entity.consoleText = "";
		end;
	end);

	Msg("Inizialized clientside Terminal!\n");
end