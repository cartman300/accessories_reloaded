--[[-------------------------------------------------------------------------------------------------------------------------
	Clientside magic box code
-------------------------------------------------------------------------------------------------------------------------]]--

include( "shared.lua" )

--[[-------------------------------------------------------------------------------------------------------------------------
	Initialization
-------------------------------------------------------------------------------------------------------------------------]]--

function ENT:Initialize()
	self:SetModelScale( 1.2, 0 )
end

--[[-------------------------------------------------------------------------------------------------------------------------
	Drawing
-------------------------------------------------------------------------------------------------------------------------]]--

local rt = render.GetScreenEffectTexture()
local matView = CreateMaterial(
	"UnlitGeneric",
	"GMODScreenspace",
	{
		["$basetexture"] = rt,
		["$basetexturetransform"] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
		["$texturealpha"] = "0",
		["$vertexalpha"] = "1",
	}
)

function ENT:Draw()
	--self:DrawModel()
	
	local oldRT = render.GetRenderTarget()
	render.SetRenderTarget( rt )
	
	render.Clear( 0, 0, 0, 0 )
	render.ClearDepth()
	render.ClearStencil()
	
	local viewCenter = self:GetPos() + Vector( -0.2, -23.2, 0 )
	local worldCenter = self:GetNWVector( "WorldPos" ) + Vector( 160, -32, 76 )
	local offset = viewCenter - LocalPlayer():EyePos() + Vector( 0, 0, 20 )
	local camPos = worldCenter - offset + Vector( 0, 0, 5 )
	
	render.RenderView({
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH(),
		origin = camPos,
		angles = LocalPlayer():EyeAngles(),
		dopostprocess = true,
		drawhud = true,
		drawviewmodel = true
	})
	
	--render.RenderHUD(0, 0, ScrW(), ScrH())
	render.UpdateScreenEffectTexture()
	
	render.SetRenderTarget( oldRT )
	
	render.ClearStencil()
	render.SetStencilEnable( true )
	
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 1 )
	
	local matDummy = Material( "debug/white" )
	render.SetMaterial( matDummy )
	render.SetColorModulation( 1, 1, 1 )
	mesh.Begin( MATERIAL_QUADS, 1 )
		render.DrawSphere(self:GetPos() + Vector( -0.2, -23.2, 0 ), 50, 20, 20, Color(0, 0, 0, 255))
	mesh.End()
	
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 1 )
	
	matView:SetTexture( "$basetexture", rt )
	render.SetMaterial( matView )
	render.DrawScreenQuad()
	
	render.SetStencilEnable( false )
end