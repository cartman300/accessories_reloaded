include("shared.lua");
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Category = "Stargate"
ENT.PrintName = "Base Entity"

function ENT:Draw()
    self.Entity:DrawModel()
end