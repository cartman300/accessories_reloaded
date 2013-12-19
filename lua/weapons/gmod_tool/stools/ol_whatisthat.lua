
TOOL.Category		= "Information"
TOOL.Name			= "#What Is That?"
TOOL.Command		= nil
TOOL.ConfigName		= ""

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "Tool.ol_whatisthat.name", "What Is That?" )
	language.Add( "Tool.ol_whatisthat.desc", "Seriously, what is it?" )
	language.Add( "Tool.ol_whatisthat.0", "Click to find out!" )
	
end

function TOOL:LeftClick( trace )
	if !trace.Entity then return false end
	if CLIENT then return true end
	
	local ent = trace.Entity
	local ply = self:GetOwner()
	local class = ent:GetClass()
	local message = "That is"
	if class == "worldspawn" then
		message = message.." part of the level!"
	elseif class == "prop_physics" then
		local model = ent:GetModel()
		message = message.." a prop. Its model is: "..model
	else
		message = message.." a "..class
	end
	ply:PrintMessage(HUD_PRINTTALK, message)
	-- ply:PrintMessage(2, message)
	return true
end

function TOOL:RightClick( trace )
	return self:LeftClick( trace, true )
end

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool.ol_whatisthat.name", Description	= "#Tool.ol_whatisthat.desc" }  )
end

local function OverrideCanTool(pl, rt, toolmode)
	-- We don't want any addons denying use of this tool. Even when using
	-- PropDefender, people should be able to use this tool on other people's
	-- stuff.
	if toolmode == "ol_whatisthat" then
		return true
	end
end
hook.Add( "CanTool", "ol_whatisthat_CanTool", OverrideCanTool );