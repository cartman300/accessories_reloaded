local function Inc(f)
	if (CLIENT) then
		include(f)
	elseif (SERVER) then
		AddCSLuaFile(f)
		include(f)
	end
end

if (SERVER) then AddCSLuaFile() end
Inc "hud/chat_url_parser.lua"
-- Inc "hud/holo_map.lua" -- Nope