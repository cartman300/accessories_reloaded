local meta = FindMetaTable( "Entity" )

if (SERVER) then
	AddCSLuaFile()
	
	if not meta.SetParentEngine then meta.SetParentEngine = meta.SetParent end

	function meta:SetParent( parent )
		
		local oldparent = self:GetParent()
		self:SetParentEngine( parent )
		
		-- If we're unparenting or changing parent, remove the ent from the previous parent's childtable
		if IsValid( oldparent ) and oldparent ~= parent and oldparent._children then
			oldparent._children[ self ] = nil
		end
		
		-- If we're parenting to a new/different ent, insert the ent into the parent's childtable
		if IsValid( parent ) then
			parent._children = parent._children or {}
			parent._children[ self ] = self
			self:CallOnRemove( "UnparentOnRemove", function( ent ) ent:SetParent( nil ) end )
		end
		
	end

	function meta:GetChildren()
		return self._children or {}
	end
	
elseif (CLIENT) then

	function meta:CreateHolo(x, y, w, h)
		return Hologui.Create(self, x, y, w, h)
	end

end

