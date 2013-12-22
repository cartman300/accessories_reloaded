if (SERVER) then return end

local GPDA = {}
GPDA.Visible = false

function GPDA.Draw()
	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(1)

	-- draw your mask here, diamond, circle or whatever.

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
	render.SetStencilReferenceValue(1)

	--self.Avatar:SetPaintedManually(false)
	--self.Avatar:PaintManual()
	--self.Avatar:SetPaintedManually(true)

	render.SetStencilEnable(false)
	render.ClearStencil()
end

function GPDA.Update()

end


--[[hook.Add("Think", "GPDA_Think", function()
	if (LocalPlayer():KeyPressed(IN_WALK)) then
		GPDA.Visible = not GPDA.Visible
	end
	
	if (GPDA.Visible) then
		GPDA.Update()
		GPDA.Draw()
	end
end)]]--