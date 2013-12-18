/*
	Shield Spawner for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# Header
include("weapons/gmod_tool/stargate_base_tool.lua");
TOOL.Category="Tech";
TOOL.Name=Language.GetMessage("stool_shield");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["immunity"] = 0;
TOOL.ClientConVar["size"] = 300;
TOOL.ClientConVar["toggle"] = 3;
TOOL.ClientConVar["strength"] = 0;
TOOL.ClientConVar["bubble"] = 1;
TOOL.ClientConVar["containment"] = 0;
TOOL.ClientConVar["passing_draw"] = 1;

TOOL.ClientConVar["atlantis_mode"] = 0;
TOOL.ClientConVar["anti_noclip"] = 0;

TOOL.ClientConVar["r"] = 255;
TOOL.ClientConVar["g"] = 255;
TOOL.ClientConVar["b"] = 255;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/micropro/shield_gen.mdl";
TOOL.MaximumShieldSize = StarGate.CFG:Get("shield","max_size",1024); -- A person generally can spawn 1 shield
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateShieldModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/micropro/shield_gen.mdl",{}); -- Thanks micropro for this model!
list.Set(TOOL.List,"models/props_combine/weaponstripper.mdl",{Angle=Angle(-90,0,0),Position=Vector(15,0,-60)});
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
if (file.Exists("models/props_c17/pottery08a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery08a.mdl",{});
end
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});
list.Set(TOOL.List,"models/props_phx/construct/metal_plate1.mdl",{});
list.Set(TOOL.List,"models/props_phx/construct/glass/glass_plate1x1.mdl",{});
list.Set(TOOL.List,"models/props_phx/construct/wood/wood_panel1x1.mdl",{});
list.Set(TOOL.List,"models/hunter/plates/plate1x1.mdl",{});
list.Set(TOOL.List,"models/props_phx/misc/iron_beam1.mdl",{});
list.Set(TOOL.List,"models/props_junk/TrafficCone001a.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "shield_generator";
TOOL.Entity.Keys = {"toggle_shield","model","size","immunity","strength_multiplier","r","g","b","bubble","containment","passing_draw","Strength", "anti_noclip", "atlantis_mode"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("shield","limit",1); -- A person generally can spawn 1 shield

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = "Shield Spawner";
TOOL.Topic["desc"] = "Creates a Shield";
TOOL.Topic[0] = "Left click, to spawn a Shield";
-- Adds additional "language" - To the end of these files, the string "_*classname*" will be added, using TOOL.Entity["class"].
-- E.g. TOOL.Language["Undone"] will add the language "Undone_prop_physics" when TOOL.Entity["class"] is "prop_physics"
TOOL.Language["Undone"] = "Shield removed";
TOOL.Language["Cleanup"] = "Shields";
TOOL.Language["Cleaned"] = "Removed all Shields";
TOOL.Language["SBoxLimit"] = "Hit the Shield limit";
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	local size = self:GetClientNumber("size");
	local immunity = self:GetClientNumber("immunity");
	local strength = self:GetClientNumber("strength");
	local bubble = self:GetClientNumber("bubble");
	-- Due to compatibility issues with Gmod2007, we need to divide by 255
	local r = self:GetClientNumber("r")/255;
	local g = self:GetClientNumber("g")/255;
	local b = self:GetClientNumber("b")/255;
	local containment = self:GetClientNumber("containment");
	local passing_draw = self:GetClientNumber("passing_draw");
	local atlantis_mode = self:GetClientNumber("atlantis_mode");
	local anti_noclip = self:GetClientNumber("anti_noclip");
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:SetSize(size);
		t.Entity.ImmuneOwner = false;
		if(util.tobool(immunity)) then
			t.Entity.ImmuneOwner = true;
		end
		t.Entity.DrawBubble = false;
		if(util.tobool(bubble)) then
			t.Entity.DrawBubble = true;
		end
		t.Entity:SetMultiplier(strength);
		t.Entity:SetShieldColor(r,g,b);
		t.Entity.PassingDraw = util.tobool(passing_draw);
		t.Entity.AntiNoclip = util.tobool(anti_noclip);
		t.Entity.Containment = util.tobool(containment);
		t.Entity.AtlantisMode = util.tobool(atlantis_mode);

		-- Make changes take effect immediately, when shield is turned on
		if(t.Entity:Enabled()) then
			t.Entity:Status(false,true);
			local e = t.Entity;
			timer.Simple(0.1,
				function()
					if(e and e:IsValid()) then
						e:Status(true,true);
					end
				end
			);
		end
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,size,immunity,strength,r,g,b,bubble,containment,passing_draw,atlantis_mode,anti_noclip);
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model,size,immunity,strength,r,g,b,bubble,containment,passing_draw,atlantis_mode,anti_noclip);
	e.AtlantisMode = atlantis_mode
	e.AntiNoclip = anti_noclip
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,toggle,model,size,immunity,strength_multiplier,r,g,b,bubble,containment,passing_draw,Strength,atlantis_mode,anti_noclip)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model,size,immunity,strength_multiplier,r,g,b,bubble,containment,passing_draw,Strength,atlantis_mode,anti_noclip)
	e.ImmuneOwner = util.tobool(immunity);
	e.DrawBubble = util.tobool(bubble);
	e.PassingDraw = util.tobool(passing_draw);
	e.Containment = util.tobool(containment);
	e:SetSize(size or 80);
	e:SetMultiplier(strength_multiplier);
	e.AtlantisMode = util.tobool(atlantis_mode)
	e.AntiNoclip = util.tobool(anti_noclip);
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleShield",e);
	end
	local num = tonumber(Strength);
	if(Strength and num and type(num) == "number") then
		e.Strength = num;
	end
	e:SetShieldColor(r,g,b);
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("ComboBox",{
		Label="Presets",
		MenuButton=1,
		Folder="stargate_shield",
		Options={
			Default=self:GetDefaultSettings(),
			["Goa'uld"] = {
				stargate_shield_r = 255,
				stargate_shield_g = 128,
				stargate_shield_b = 59,
			},
			["Asgard"] = {
				stargate_shield_r = 170,
				stargate_shield_g = 189,
				stargate_shield_b = 255,
			},
			["Alteran"] = {
				stargate_shield_r = 124,
				stargate_shield_g = 255,
				stargate_shield_b = 189,
			},
			["Tau'ri"] = {
				stargate_shield_r = 35,
				stargate_shield_g = 90,
				stargate_shield_b = 130,
			},
		},
		CVars=self:GetSettingsNames(),
	});
	Panel:NumSlider("Size:","stargate_shield_size",100,self.MaximumShieldSize,0);
	Panel:NumSlider("Faster - Stronger","stargate_shield_strength",-5,5,2):SetToolTip("Note: Increasing the Strength will result into slower Regeneration and more Energy Usage");
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label="Toggle:",
		Command="stargate_shield_toggle",
	});
	Panel:AddControl("Color",{
		Label = "Color",
		Red = "stargate_shield_r",
		Green = "stargate_shield_g",
		Blue = "stargate_shield_b",
		ShowAlpha = 0,
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255,
	});
	Panel:AddControl("PropSelect",{Label="Model",ConVar="stargate_shield_model",Category="",Models=self.Models});
	Panel:CheckBox("Immunity","stargate_shield_immunity"):SetToolTip("When this is enabled, the owner of the shield can always go or shoot through\nno matter if he was inside the shield when it was turned on or not");
	Panel:CheckBox("Draw Bubble","stargate_shield_bubble"):SetToolTip("Draw a bubble when hit?");
	Panel:CheckBox("Show Effect when Passing Shield","stargate_shield_passing_draw"):SetToolTip("Draws the shield effect, when something passes it");
	if(StarGate.CFG:Get("shield","allow_containment",true)) then
		Panel:CheckBox("Containment","stargate_shield_containment"):SetToolTip("Enable this to keep things inside a shield instead of keeping it away");
	end
	Panel:CheckBox(Language.GetMessage("stool_autoweld"),"stargate_shield_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(Language.GetMessage("stool_autolink"),"stargate_shield_autolink"):SetToolTip("Autolink this to resouce using Entity?");
	end
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox("Atlantis Mode", "stargate_shield_atlantis_mode"):SetToolTip("Shield will stay on as long as there is power.");
	end
	Panel:CheckBox("Anti Noclip", "stargate_shield_anti_noclip"):SetToolTip("People can't noclip in the shield?");
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleShield",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e:Enabled()) then
				e:Status(false);
			else
				e:Status(true);
			end
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();