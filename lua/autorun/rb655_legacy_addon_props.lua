
AddCSLuaFile()

if ( SERVER ) then return end

language.Add( "rb655.legacy_addon_props.name", "Legacy Addons ( Info Inside )" )

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

local function GetSize( b )
	b = math.floor( b / 1024 )

	if ( b < 1024 ) then
		return b .. " KB"
	end
	
	b = math.floor( b / 1024 )
	
	if ( b < 1024 ) then
		return b .. " MB"
	end

	b = math.floor( b / 1024 )
	
	return b .. " GB"
end

hook.Add( "PopulateContent", "LegacyAddonProps", function( pnlContent, tree, node )
	local ViewPanel = vgui.Create( "ContentContainer", pnlContent )
	ViewPanel:SetVisible( false )

	local LegacyAddons = node:AddNode( "#rb655.legacy_addon_props.name", "icon16/folder_database.png" )
	LegacyAddons.DoClick = function()

		ViewPanel:Clear( true )

		local txt = "( Workshop Files that are wasting space and not used by GMod  - Safe to delete )\n\n"
		local sizeLeft = 0
		
		for id, fle in pairs( GetWorkshopLeftovers() ) do
			sizeLeft = sizeLeft + file.Size( "addons/" .. fle, "GAME" ) or 0
			txt = txt .. "[ " .. GetSize( file.Size( "addons/" .. fle, "GAME" ) or 0 ) .. " ] addons/" .. fle .. "\n"
		end
		
		if ( sizeLeft == 0 ) then txt = txt .. "None.\n" end

		local sizeAll = 0

		for id, fle in pairs( file.Find( "addons/*.gma", "GAME" ) ) do
			sizeAll = sizeAll + ( file.Size( "addons/" .. fle, "GAME" ) or 0 )
		end
		
		txt = txt .. "\nWorkshop Addons: " .. GetSize( sizeAll - sizeLeft )
		txt = txt .. "\nLeftovers: " .. GetSize( sizeLeft )
		txt = txt .. "\nTotal: " .. GetSize( sizeAll )
	
		/* ---------------------------------------------------------------------------------------------------- */

		txt = txt .. "\n\n\n( Legacy Addons with models )\n\n"
		
		local t = {}
		
		local files, folders = file.Find( "addons/*", "MOD" )
		for k, v in pairs( folders or {} ) do
			if ( file.IsDir(  "addons/" .. v .. "/models/", "MOD" ) ) then
				table.insert( t, v )
			end
		end
		
		if ( #t > 0 ) then
			for k, v in pairs( t ) do
				txt = txt ..  "addons/" .. v .. "/\n"
			end
		else
			txt = txt ..  "None.\n"
		end
		
		/* ---------------------------------------------------------------------------------------------------- */
		
		txt = txt .. "\n\n( Empty Legacy Addons - Safe to delete )\n\n"
	
		local t = {}
		
		local files, folders = file.Find( "addons/*", "MOD" )
		for k, v in pairs( folders or {} ) do
			local a, b = file.Find( 'addons/' .. v .. "/*", "MOD" )
			if ( table.Count( b ) < 1 ) then
				table.insert( t, v )
			end
		end

		if ( #t > 0 ) then
			for k, v in pairs( t ) do
				txt = txt ..  "addons/" .. v .. "/\n"
			end
		else
			txt = txt ..  "None.\n"
		end
		
		/* ---------------------------------------------------------------------------------------------------- */
		
		txt = txt .. "\n\n( Incorrectly installed Legacy Addons )\n\n"
		
		local t = {}
		
		local files, folders = file.Find( "addons/*", "MOD" )
		for k, v in pairs( folders or {} ) do
			if ( !file.IsDir(  "addons/" .. v .. "/models/", "MOD" ) && !file.IsDir(  "addons/" .. v .. "/materials/", "MOD" ) && !file.IsDir(  "addons/" .. v .. "/lua/", "MOD" ) && !file.IsDir(  "addons/" .. v .. "/sound/", "MOD" ) ) then
				table.insert( t, v )
			end
		end

		if ( #t > 0 ) then
			for k, v in pairs( t ) do
				txt = txt ..  "addons/" .. v .. "/\n"
			end
		else
			txt = txt ..  "None.\n"
		end

		/* ---------------------------------------------------------------------------------------------------- */
		
		txt = txt .. "\n\n( Cache Sizes - Safe to delete )\n"
		
		local size = 0
		local files, folders = file.Find( "cache/*", "MOD" )
		for k, v in pairs( files or {} ) do
			size = size + file.Size( "cache/" .. v, "GAME" ) or 0
		end
		txt = txt .. "\n[ cache/ ] Download cache: " .. GetSize( size )
	
		local size = 0
		local files, folders = file.Find( "cache/lua/*", "MOD" )
		txt = txt .. "\n[ cache/lua/ ] Lua cache: " .. #files .. " files ~" .. GetSize( #files * 1400 ) -- Too many files to count actual size! Same goes for below one.
	
		local size = 0
		local files, folders = file.Find( "cache/workshop/*", "MOD" )
		/*for k, v in pairs( files or {} ) do
			size = size + file.Size( "cache/workshop/" .. v, "GAME" ) or 0
		end
		txt = txt .. "\n[ cache/workshop/ ] Workshop cache: " .. GetSize( size )*/
		txt = txt .. "\n[ cache/workshop/ ] Workshop cache: " .. #files .. " files ~" .. GetSize( #files * 128 )
		

		local size = 0
		local files, folders = file.Find( "downloads/server/*", "MOD" )
		for k, v in pairs( files or {} ) do
			size = size + file.Size( "downloads/server/" .. v, "GAME" ) or 0
		end
		txt = txt .. "\n[ downloads/server/ ] Workshop Addons from servers: " .. GetSize( size )

		local it = vgui.Create( "DLabel" )
		it:SetText( txt )
		it:SetFont( "Default" )
		it:SizeToContents()
		it:SetBright( true )
		ViewPanel:Add( it )
		
		it.m_DragSlot = nil -- Don't allow to drag!

		pnlContent:SwitchPanel( ViewPanel )

	end

	local files, folders =  file.Find( "addons/*", "GAME" )
	for _, f in SortedPairs( folders ) do
		if ( !file.IsDir( "addons/" .. f .. "/models/", "GAME" ) ) then continue end

		local count = CountRecursive( "addons/" .. f .. "/models/", "GAME" )
		if ( count == 0 ) then continue end

		local models = LegacyAddons:AddNode( f .. " (" .. count .. ")", "icon16/bricks.png" )
		models.DoClick = function()

			ViewPanel:Clear( true )
			AddRecursive( ViewPanel, "addons/" .. f .. "/models/" )
			pnlContent:SwitchPanel( ViewPanel )

		end

	end

end )

function GetWorkshopLeftovers()
	local subscriptions = {}

	for id, t in pairs( engine.GetAddons() ) do
		subscriptions[ tonumber( t.wsid ) ] = true
	end

	local t = {}
	for id, fileh in pairs( file.Find( "addons/*.gma", "GAME" ) ) do
		local a = string.StripExtension( fileh )
		a = string.Explode( "_", a )
		a = tonumber( a[ #a ] )
		if ( !subscriptions[ a ] ) then
			table.insert( t, fileh )
		end
	end
	
	return t

end
