TOOL.Category = "Cartman300"
TOOL.Name = "Mapify"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Model = "none"

if CLIENT then
	language.Add("tool.mapify.name", "Mapify tool")
	language.Add("tool.mapify.desc", "Makes props permanent! (Until map restart)")
	language.Add("tool.mapify.0", "Left Click - Mapify, Right Click - Demapify, Reload - Make brush")
end

function TOOL:LeftClick(trace)
	if CLIENT then return end
	if IsValid(trace.Entity) and not trace.Entity.Mapified then
		trace.Entity.Mapified = true
		trace.Entity.AntiPickup = true
		undo.ReplaceEntity(trace.Entity, NULL)
		return true
	end
	return false
end

function TOOL:RightClick(trace)
	if CLIENT then return end
	if IsValid(trace.Entity) and trace.Entity.Mapified then
		trace.Entity.Mapified = false
		trace.Entity.AntiPickup = false
		return true
	end
	return false
end

function TOOL:Reload(trace)
	if CLIENT then return end
	return false
end
