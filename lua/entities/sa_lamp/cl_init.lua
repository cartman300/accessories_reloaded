include("shared.lua");
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Category = "Stargate"
ENT.PrintName = "SGC Lamp"

function ENT:Draw()
    self.Entity:DrawModel()
end