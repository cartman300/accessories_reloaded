include("shared.lua");
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Category = "Stargate"
ENT.PrintName = "Naquadah Vial"

function ENT:Draw()
    self.Entity:DrawModel()
end