if (SERVER) then
	include("terminal/sv_init.lua");
	
	AddCSLuaFile("terminal/cl_init.lua");
	AddCSLuaFile("autorun/terminal.lua");
else
	include("terminal/cl_init.lua");
end