if (SERVER) then
	include("terminal/sv_init.lua");

	AddCSLuaFile("autorun/client/cl_terminal.lua");
	AddCSLuaFile("terminal/cl_init.lua");
else
	include("terminal/cl_init.lua");
end