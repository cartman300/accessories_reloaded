-- This code makes it so gates get random names when they spawn! :D

local IsRGAEnabledCVAR = CreateConVar( "stargate_random_spawn_addr", 1)


-- Random string generator
local function RandomAddress(max,exclude)
    local chr = "@1234567890QWERTYUIOPASDFGHJKLZXCVBNM"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomNumber(max)
    local exclude = ""
    local chr = "0123456789"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomString(max)
    local exclude = ""
    local chr = "0123456789"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomAll(max)
    local chr = "1234567890QWERTYUIOASDFGHJKLZXCVBN"
    local ret = ""
    local exclude = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

hook.Add("PlayerSpawnedSENT","RandomGateName",function(ply,ent)
    if (GetConVar("stargate_random_spawn_addr"):GetInt() == 1) then
        if (IsValid(ent) and ent.IsStargate) then
      --      ent:Ignite(1, 0)
            ent:SetGateAddress(RandomAddress(6,ent:GetGateGroup()))
            if (ent:GetClass() == "stargate_atlantis") then
                ent:SetGateName("M"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
            elseif (ent:GetClass() == "stargate_sg1" or ent:GetClass() == "stargate_movie" or ent:GetClass() == "stargate_infinity" or ent:GetClass() == "stargate_tollan")then
                ent:SetGateName("P"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
            elseif (ent:GetClass() == "stargate_orlin") then
                ent:SetGateName("Orlins Gate "..RandomNumber(4))
            elseif (ent:GetClass() == "stargate_supergate") then
                ent:SetGateName(RandomAll(7))
            elseif (ent:GetClass() == "stargate_universe") then
                ent:SetGateName("U-"..RandomNumber(5))
            else
                ent:SetGateName("Unknown! :O")
            end
        end
    end
end)
