include("weapons/gmod_tool/stargate_base_tool.lua");
TOOL.Category="Energy";
TOOL.Name="#".."Naquadah Vial";

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["model"] = "models/sandeno/naquadah_bottle.mdl";
TOOL.Entity.Class = "naquadah_vial";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 30;
TOOL.Topic["name"] = "Naquadah Vial Spawner";
TOOL.Topic["desc"] = "Creates a Naquadah Vial";
TOOL.Topic[0] = "Left click, to spawn a Naquadah Vial";
TOOL.Language["Undone"] = "Naquadah Vial removed";
TOOL.Language["Cleanup"] = "Naquadah Vials";
TOOL.Language["Cleaned"] = "Removed all Naquadah Vials";
TOOL.Language["SBoxLimit"] = "Hit the Naquadah Vial limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(Language.GetMessage("stool_autoweld"),"agate_vial_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(Language.GetMessage("stool_autolink"),"agate_vial_autolink"):SetToolTip("Autolink this to resource using Entities?");
	end
	Panel:AddControl("Label", {Text = "\nThis is the Naquadah Vial, this tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Naquadah Vial is quite useless for you.",})
end

TOOL:Register();