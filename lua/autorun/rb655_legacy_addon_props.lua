
AddCSLuaFile()

if ( SERVER ) then return end

language.Add( "rb655.legacy_addon_props.name", "Legacy Addons" )

local function AddRecursive( pnl, folder )
	local files, folders = file.Find( folder .. "*", "GAME" )

	for k, v in pairs( files or {} ) do
		if ( !string.EndsWith( v, ".mdl" ) ) then continue end

		local cp = spawnmenu.GetContentType( "model" )
		if ( cp ) then
			local mdl = folder .. v
			mdl = string.sub( mdl, string.find( mdl, "models/" ), string.len( mdl ) )
			mdl = string.gsub( mdl, "models/models/", "models/" )
			cp( pnl, { model = mdl } )
		end
	end

	for k, v in pairs( folders or {} ) do AddRecursive( pnl, folder .. v .. "/" ) end
end

local function CountRecursive( folder )
	local files, folders = file.Find( folder .. "*", "GAME" )
	local val = 0

	for k, v in pairs( files or {} ) do if ( string.EndsWith( v, ".mdl" ) ) then val = val + 1 end end
	for k, v in pairs( folders or {} ) do val = val + CountRecursive( folder .. v .. "/" ) end
	return val
end

hook.Add( "PopulateContent", "LegacyAddonProps", function( pnlContent, tree, node )
	local ViewPanel = vgui.Create( "ContentContainer", pnlContent )
	ViewPanel:SetVisible(false)

	local MyNode = node:AddNode( "#rb655.legacy_addon_props.name", "icon16/folder_database.png" )

	local files, folders =  file.Find( "addons/*", "GAME" )
	for _, f in SortedPairs( folders ) do
		if ( !file.IsDir( "addons/" .. f .. "/models/", "GAME" ) ) then continue end

		local count = CountRecursive( "addons/" .. f .. "/models/", "GAME" )
		if ( count == 0 ) then continue end

		local models = MyNode:AddNode( f .. " (" .. count .. ")", "icon16/bricks.png" )
		models.DoClick = function()
			ViewPanel:Clear( true )
			AddRecursive( ViewPanel, "addons/" .. f .. "/models/" )
			pnlContent:SwitchPanel( ViewPanel )
		end
	end
end)
