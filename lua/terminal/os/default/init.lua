OS.Classname = "default";
OS.Name = "TER-DOS";
OS.Description = "TER-DOS Standard OS"

function OS:Print(str, clr, skip_newline)
	Terminal:Broadcast(self,str or " ",clr)
	if (str != nil and string.len(str) < 37 and skip_newline != true) then
		Terminal:FillLine(self)
	end
end

function OS:OnInstall()
	self:Print("Instalation complete!")
	self:Print("Restarting in 3sec...");
	timer.Simple(3, function()
		self.ECHO = true;
		self.IGNORE = false;
		self:Shutdown();
		timer.Simple(1,function()
			if (self != nil) then self:Startup(); end;
		end)
	end)
end

function OS:Startup()
	self:SetActive(true)
	Terminal:Broadcast(self,"Initializing...");
	Terminal:Clear(self);
	if (self.ECHO == nil) then self.ECHO = false; end;
	if (self.IGNORE == nil) then self.IGNORE = false; end;
end

function OS:Tick()

end

function OS:Shutdown()
	Terminal:Clear(self);	
	self:SetActive(false);
end

function OS:Command(com)
	if (self.IGNORE) then return true; end;
	if (self.ECHO) then
		local c = "";
		for k,v in pairs(com) do
			c = c .. " " .. v;
		end
		self:Print(string.Trim(c), T_COL_CMD)
	end
	if (com[1]=="printl") then
		self:Print(com[2], com[3] or 1)
	elseif (com[1]=="print") then
		self:Print(com[2], com[3] or 1, true)
	elseif (com[1]=="shutdown") then
		self:Shutdown()
	elseif (com[1]=="clear") then
		Terminal:Clear(self);
	elseif (com[1]=="echo") then
		if (com[2]!=nil) then
			self.ECHO = tobool(com[2])
		else
			self:Print("ECHO is " .. tostring(self.ECHO))
		end
	elseif (com[1]=="restart") then
		self:Shutdown();
		timer.Simple(1,function()
			if (self != nil) then self:Startup(); end;
		end)
	elseif (com[1]=="help") then
		self:Print("== Help Utility =====================", T_COL_MSG);
		self:Print(" printl <arg> <color>", T_COL_CMD)
		self:Print(" print <arg> <color>", T_COL_CMD)
		self:Print(" clear", T_COL_CMD)
		self:Print(" shutdown", T_COL_CMD)
		self:Print(" restart", T_COL_CMD)
		self:Print(" os", T_COL_CMD)
		self:Print(" echo <1 or 0>", T_COL_CMD)
		self:Print(" wire", T_COL_CMD)
	elseif (com[1]=="os") then
		if (com[2]=="list") then
			self:Print("== OS Instalation Utility ===========", T_COL_MSG)
			self:Print(" Type 'os install <name>' to install ", T_COL_INFO)
			self:Print(" OS List: ")
			for k,v in pairs(Terminal.os) do
				if v != nil then
					self:Print(v.Classname .. " - " .. v.Description, T_COL_CMD)
				end
			end
		elseif (com[2]=="install") then
			if (com[3]!=nil) then
				local found = false;
				for k,v in pairs(Terminal.os) do
					if v.Classname == com[3] then
						found = true;
						Terminal:Clear(self);
						self.IGNORE = true;
						self:Print("Loading packages, please wait...", T_COL_MSG)
						timer.Simple(4, function()
							self:Print("Installing...", T_COL_MSG)
							local msgs = { "Wiping disk.","Creating partitions.","Resizing partitions.", "Formatting partitions.", "Extracting packages.","Finalizing."}
							local last = 0;
							for k,v in pairs(msgs) do
								local t = math.random(last,last + 3);
								last = t;
								timer.Simple(last,function()
									if (IsValid(self)) then self:Print(v); else return; end;
								end)
							end
							timer.Simple(math.random(last,last + 5), function()
								for k,v in pairs(Terminal.os[com[3]]) do
									if (!IsValid(self)) then return; end;
									self[k] = v;
								end
								self:OnInstall();
							end)
						end)
					end
				end
				if (found==false) then
					self:Print("OS Not Found '" .. com[3] .. "'", T_COL_ERR)
				end
			end
		else
			self:Print("== OS Instalation Utility ===========", T_COL_MSG)
			self:Print(" os list - list all available OS", T_COL_CMD)
			self:Print(" os install <arg> - install <arg>", T_COL_CMD)
		end
	elseif (com[1]=="wire") then
		if (com[2]=="out_add") then
			self.WireOutputs = self.WireOutputs or {}
			self.WireOutputs[com[3] or "NIL"] = 1;
		elseif (com[2]=="out_remove") then
			self.WireOutputs = self.WireOutputs or {}
			self.WireOutputs[com[3] or "NIL"] = 0
		elseif (com[2]=="out_set") then
			Wire_TriggerOutput(self, com[3] or "NIL", com[4] or 0)
		elseif (com[2]=="in_add") then
			self.WireInputs = self.WireInputs or {}
			self.WireInputs[com[3] or "NIL"] = 1;
		elseif (com[2]=="in_remove") then
			self.WireInputs = self.WireInputs or {}
			self.WireInputs[com[3] or "NIL"] = 0
		elseif (com[2]=="list") then
			self:Print("Wire Inputs: ")
			for k,v in pairs(self.WireInputs or {}) do
				if v>0 then self:Print(" " .. k, T_COL_CMD) end
			end
			self:Print("Wire Outputs: ")
			for k,v in pairs(self.WireOutputs or {}) do
				if v>0 then self:Print(" " .. k, T_COL_CMD) end
			end
		elseif (com[2]=="init") then
			local prts = {}
			for k,v in pairs(self.WireInputs or {}) do
				if v>0 then table.insert(prts,k) end
			end
			/*self.Inputs = */WireLib.CreateInputs(self, prts)
			prts = {}
			for k,v in pairs(self.WireOutputs or {}) do
				if v>0 then table.insert(prts,k) end
			end
			/*self.Outputs = */WireLib.CreateOutputs(self, prts)
		else
			self:Print("== Wiremod Utility ==================", T_COL_MSG)
			self:Print(" wire out_add <port>", T_COL_CMD)
			self:Print(" wire out_remove <port>", T_COL_CMD)
			self:Print(" wire out_set <port> <value>", T_COL_CMD)
			self:Print(" wire in_add <port>", T_COL_CMD)
			self:Print(" wire in_remove <port>", T_COL_CMD)
			self:Print(" wire init", T_COL_CMD)
			self:Print(" wire list", T_COL_CMD)
		end
	else
		self:Print("Unknown command '" .. com[1] .. "'", T_COL_ERR)
	end
	return true;
end

function OS:WireInput(iname, value)
	self:Print(iname .. "=" .. value)
end

function OS:OnUse(activator, caller)

end