--[[--
	Name:           Smart Welder V4
	Author(s):      Duncan Stead, Hans Leid
	Version:        4.0
--]]--
local tp = "Tool.smartwelder."
local dp = "#"..tp
 
local SelectedEntities = {}
hook.Add("PlayerDisconnected","smartwelder_disconnect",function(ply)
	for k,v in pairs(SelectedEntities) do
		if v.Player == ply then
			if ent:IsValid() then
				ent:SetColor(v.Color)
				ent:SetMaterial(v.Material)
			end
			SelectedEntities[ent] = nil
		end
	end
end)
 
TOOL.Category           = "Constraints"
TOOL.Name                       = dp.."name"
TOOL.Command            = nil
TOOL.ConfigName         = ""
TOOL.Operating          = false
TOOL.Props                      = {}
TOOL.Filter             = {}
 
TOOL.AutoKey            = IN_USE
TOOL.SecondaryKey       = IN_SPEED
 
--the default smartweld settings
TOOL.ClientConVar["selectradius"]=128
TOOL.ClientConVar["selectinsideradius"]=0
TOOL.ClientConVar["nocollide"]=1
TOOL.ClientConVar["eachother"]=1
TOOL.ClientConVar["freeze"]=0
TOOL.ClientConVar["clearwelds"]=1
TOOL.ClientConVar["strength"]=0
TOOL.ClientConVar["world"]=0
 
TOOL.ClientConVar["color_r"]=0
TOOL.ClientConVar["color_g"]=255
TOOL.ClientConVar["color_b"]=0
TOOL.ClientConVar["color_a"]=255
 
if CLIENT then
	language.Add( "Undone_smartweld", "Undone Smart Weld" )
 
	language.Add( tp.."name", "Weld - Smart" )
	language.Add( tp.."desc", "Automatically welds selected props" )
	language.Add( tp.."0", "Select/deselect props with left click (Hold Use key and left click to auto-select)." )
	language.Add( tp.."1", "Smart-weld with right click. Reload clears selection." )

	language.Add( tp.."selectinsideradius", "Auto-select inside radius" )
	language.Add( tp.."selectinsideradius.help", "The auto-selecting inside radius, anything before this value wont be selected, If you want to select everything use 0 for this value" )

	language.Add( tp.."selectoutsideradius", "Auto-select outside radius" )
	language.Add( tp.."selectoutsideradius.help", "The auto-selecting outside radius, anything beyond this value wont be selected" )

	language.Add( tp.."strength", "Weld forcelimit" )
	language.Add( tp.."strength.help", "The strength of the welds created. Use 0 for unbreakable welds" )
 
	language.Add( tp.."eachother", "Weld each other" )
	language.Add( tp.."eachother.help", "Whether props should all be welded between each other" )
	language.Add( tp.."nocollide", "No-collide" )
	language.Add( tp.."nocollide.help", "Whether pairs of props should be no-collided when welded" )
	language.Add( tp.."freeze", "Auto-freeze" )
	language.Add( tp.."freeze.help", "Whether all selected props should be frozen during the weld" )
	language.Add( tp.."clearwelds", "Remove welds" )
	language.Add( tp.."clearwelds.help", "Removes old welds inside the selection before smart welding" )
	language.Add( tp.."world", "Weld to world" )
	language.Add( tp.."world.help", "Weld each and every prop or entity selected to world" )
 
	language.Add( tp.."color", "Selection color" )
	language.Add( tp.."color.help", "Modify the selection color to make the props look less idiotic" )
end
 
function TOOL.BuildCPanel(cp)
	cp:AddControl( "Header", { Text = dp.."name", Description       = dp.."desc" }  )
 
 	cp:AddControl( "Slider", {
		Label = dp.."selectinsideradius",
		Help = dp.."selectinsideradius",
		Type = "float",
		Min = "0",
		Max = "1000",
		Command = "smartwelder_selectinsideradius" } )
	cp:AddControl( "Slider", {
		Label = dp.."selectoutsideradius",
		Help = dp.."selectoutsideradius",
		Type = "float",
		Min = "0",
		Max = "1000",
		Command = "smartwelder_selectradius" } )
	cp:AddControl( "Slider", {
		Label = dp.."strength",
		Help = dp.."strength",
		Type = "float",
		Min = "0",
		Max = "10000",
		Command = "smartwelder_strength" } )
 
	cp:AddControl( "Checkbox", {
		Label = dp.."eachother",
		Help = dp.."eachother",
		Command = "smartwelder_eachother" } )
	cp:AddControl( "Checkbox", {
		Label = dp.."nocollide",
		Help = dp.."nocollide",
		Command = "smartwelder_nocollide" } )
	cp:AddControl( "Checkbox", {
		Label = dp.."freeze",
		Help = dp.."freeze",
		Command = "smartwelder_freeze" } )
	cp:AddControl( "Checkbox", {
		Label = dp.."clearwelds",
		Help = dp.."clearwelds",
		Command = "smartwelder_clearwelds" } )
	cp:AddControl( "Checkbox", {
		Label = dp.."world",
		Help = dp.."world",
		Command = "smartwelder_world" } )
 
	cp:AddControl( "Color", {
		Label = dp.."color",
		Help = dp.."color",
		Red = "smartwelder_color_r",
		Green = "smartwelder_color_g",
		Blue = "smartwelder_color_b",
		Alpha = "smartwelder_color_r" } )
end
 
function TOOL:Notify(str)
	local ply = self:GetOwner()
	if not ply:IsValid() then return false end
	ply:PrintMessage(HUD_PRINTCENTER,str)
end
 
function TOOL:LeftClick( trace )
	if self:CheckOperating(true) then return false end
 
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
 
	if SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end
	if CLIENT  then return true end
 
	local ply = self:GetOwner()
	local selectradius=self:GetClientNumber("selectradius")
	local selectinsideradius=self:GetClientNumber("selectinsideradius")
 
	if ply:KeyDown(self.AutoKey) then
		local selectedcount=self:SelectRadius(trace.HitPos,selectradius,selectinsideradius)
		if selectedcount>1 then
			self:Notify(selectedcount.." props auto-selected")
		else
			self:Notify("No props auto-selected")
		end
	elseif self:IsSelectable(trace.Entity) then
		if self:IsSelected(trace.Entity) then
			self:DeSelect(trace.Entity)
		else
			self:Select(trace.Entity)
		end
	else
		return false
	end
	self:CheckStage()
	return true
end
function TOOL:RightClick()
	if self:CheckOperating(true) then return false end
 
	self:CheckStage()
 
	local amount = table.Count(self.Props)
	if amount == 0 then
		self:Notify("No props selected!")
		return false
	end
 
	self.Operating = true
 
	local ply = self:GetOwner()
	local secondary = ply:KeyDown(self.SecondaryKey)
	local eachother = self:GetClientNumber("eachother")>0
	local nocollide = self:GetClientNumber("nocollide")>0
	local freeze = self:GetClientNumber("freeze")>0
	local clearwelds = self:GetClientNumber("clearwelds")>0
	local strength = self:GetClientNumber("strength")
	local world = self:GetClientNumber("world")>0
 
	local complete,welded,failed = 0,{},0
	for ent,opts in pairs(self.Props) do
		if !ent:IsValid() then
			print('NOT VALID',ent)
			self:DeSelect(ent)
			continue
		end
 
		if freeze then
			local entphys = ent:GetPhysicsObject()
			if entphys:IsValid() then
				entphys:EnableMotion(false)
				entphys:Sleep()
			end
		end
 
		if world or amount > 1 then
 
			if clearwelds then
				local constraints = constraint.FindConstraints( ent, "Weld" )
				for _,const in pairs(constraints) do
					for cent,_ in pairs(self.Props) do
						if cent != ent and const.Ent2 == cent and cent:IsValid() then
							const.Constraint:Remove()
						end
					end
				end
			end
 
			undo.Create("smartweld")
			undo.SetPlayer(ply)
			complete = complete + 1
			timer.Simple(0.1*complete,function()
				if world then
					welded[ent] = true
					undo.AddEntity(self:WeldEnts(ent,game.GetWorld(),strength,nocollide))
				end
				if eachother then
					welded[ent] = true
					local i = 0
					for oent,_ in pairs(self.Props) do
						if welded[oent] then continue end
						i = i + 1
						timer.Simple(0.001*i,function()
							local weld = self:WeldEnts(ent,oent,strength,nocollide)
							if weld == false then
								failed = failed + 1
								print(ent,oent)
							else
								undo.AddEntity(weld)
							end
						end)
					end
				end
			end)
		end
	end
	timer.Simple(0.1*(complete+1),function()
		self:WeldingFinished(welded,failed)
	end)
end
function TOOL:WeldingFinished(welded,failed)
	undo.Finish()
	self:ResetSelection()
	self:Notify("Welded "..table.Count(welded).." entities")
	if failed > 0 then timer.Simple(2,function() self:Notify("Failed to weld "..failed.." times") end) end
	self:CheckStage()
	self.Operating = false
end
function TOOL:WeldEnts(ent1, ent2, strength, nocollide)
	if ent1:IsValid() and (ent2:IsValid() or ent2 == game.GetWorld()) then
		return constraint.Weld( ent1, ent2, 0, 0, strength, nocollide )
	end
	return false
end
 
function TOOL:Select(ent)
	if !ent or !ent:IsValid() then return false end
	//if ent:GetClass():sub(1,4) != 'prop' then return false end
	if self:IsSelected(ent) then self:DeSelect(ent) end
	SelectedEntities[ent] = {Player = self:GetOwner(),Color = ent:GetColor(),Material = ent:GetMaterial()}
	self.Props[ent] = SelectedEntities[ent]
	ent:SetColor(Color(
		self:GetClientNumber("color_r") or 0,
		self:GetClientNumber("color_g") or 255,
		self:GetClientNumber("color_b") or 0,
		self:GetClientNumber("color_a") or 255))
	return true
end
function TOOL:DeSelect(ent)
	local Selection = SelectedEntities[ent]
	if !Selection then return false end
	if ent:IsValid() then
		ent:SetColor(Selection.Color)
		ent:SetMaterial(Selection.Material)
	end
	SelectedEntities[ent] = nil
	self.Props[ent] = SelectedEntities[ent]
	return true
end
function TOOL:IsSelectable(ent)
	return ent and ent:IsValid() and ent:GetPhysicsObject() and ent:GetClass():find("prop") and self:IsOwner(ent)
end
function TOOL:SelectRadius(pos,radius,insideradius)
	local counted=0

	local close_ents = ents.FindInSphere( pos, radius )
	for i,v in ipairs(close_ents) do
		if not self:IsSelected(v) and self:IsSelectable(v) and self:Select(v) then
			print(v)
			counted=counted+1
		end
	end

	local too_close = ents.FindInSphere(pos,insideradius)
	for i,v in ipairs(too_close) do
		if self:IsSelected(v) and self:IsSelectable(v) and self:DeSelect(v) then
			print(v)
			counted=counted-1
		end
	end

	return counted
end
function TOOL:ResetSelection(ply)
	if !ply then ply = self:GetOwner() end
	for ent,v in pairs(SelectedEntities) do
		if v.Player == ply then
			self:DeSelect(ent)
		end
	end
end
function TOOL:IsSelected(ent)
	return tobool(SelectedEntities[ent])
end
function TOOL:IsOwner(ent,ply)
	if CPPI then
		local id = self:GetOwner():UniqueID()
		local owner,ownerid = ent:CPPIGetOwner()
		return ownerid == id
	else
		return true
	end
end
function TOOL:CheckOperating(warn)
	local oper = tobool(self.Operating)
	if oper and warn then
		self:Notify("Please wait until the previous operation finishes")
	end
	return oper
end
function TOOL:CheckStage()
	local stage = table.Count(self.Props)>1 and 1 or 0
	self:SetStage(stage)
end
function TOOL:Reload( trace )
	if self:CheckOperating(true) then return false end
	local cleared=self:ResetSelection()
 
	self:CheckStage()
	self:Notify("Selection cleared!")
end
function TOOL:Holster()
	if self:CheckOperating() then return false end
	self:ResetSelection()
end
 
concommand.Add("smartwelder_printents",function(ply)
	local console = !IsValid(ply)
	if console then
		print('Global:')
	else
		ply:PrintMessage(HUD_PRINTCONSOLE,'Global:')
	end
	for k,v in pairs(SelectedEntities) do
		if console then
			print(table.ToString(v))
		else
			ply:PrintMessage(HUD_PRINTCONSOLE,table.ToString(v))
		end
	end
end)