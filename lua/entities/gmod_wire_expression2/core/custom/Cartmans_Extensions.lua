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

local function RandomAllTwo(max)
    local chr = "1234567890QWERTYUIOASDFGHJKLZXCVBNMqwertzuioplkjhgfdsayxcvbnm"
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

e2function string stargateRandAddr()
	return RandomAddress(6,"#")
end

e2function string stargateNameMilkyWay()
	return "P"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2)
end

e2function string stargateNameAtlantis()
	return "M"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2)
end

e2function string stargateNameUniverse()
	return "U-"..RandomNumber(5)
end

e2function string stargateNameSupergate()
	return RandomAll(7)
end

e2function string randomChars(number lenght)
	return RandomAllTwo(lenght)
end







e2function array entity:stargateDHDLastAddr()
    if (!this or !this.IsDHD) and (!this.IsCrystal) then return {} end
    return this.Addresses
end

e2function array wirelink:stargateDHDLastAddr()
    if (!this or !this.IsDHD) and (!this.IsCrystal) then return {} end
    return this.Addresses
end

function DHDial(chev, dcristal)
	local v = nil
	if chev == nil then return end
	if chev >= 1 then
		v = chev
	else
		v = 1
	end
	local symbols = "A-Z1-9@#!*";
	if (GetConVar("stargate_group_system"):GetBool()) then
		symbols = "A-Z0-9@#*";
	end
	local char = string.char(v):upper();
	if (v>=128 and v<=137) then char = string.char(v-80):upper(); -- numpad 0-9
	elseif (v==139) then char = string.char(42):upper(); end -- numpad *
	if(v == 13) then -- Enter Key
		dcristal:PressButton("DIAL",_,true);
		dcristal:Rst()
	elseif(v == 127) then -- Backspace key
		local e = dcristal:FindGate();
		if not ValidEntity(e) then return end
		if (GetConVar("stargate_dhd_close_incoming"):GetInt()==0 and e.IsOpen and not e.Outbound) then return end
		if (e.IsOpen) then
			e:AbortDialling();
		elseif (e.NewActive and #dcristal.DialledAddress>0) then
			dcristal:PressButton(dcristal.DialledAddress[table.getn(dcristal.DialledAddress)],_,true);
		end
		dcristal:Rst()
	elseif(char:find("["..symbols.."]")) then -- Only alphanumerical and the @, #
		dcristal:PressButton(char,_,true);
	end
	return chev
end

e2function number entity:stargateDialChev(number chev)
	return DHDial(chev, this)
end

e2function number entity:stargateDialChev(string chev)
	return DHDial(string.byte(chev), this)
end

e2function void entity:stargateDialChevReset()
	this:Rst()
end

e2function void entity:stargateDialChevHReset()
	this:HRst()
end

e2function string entity:ga()
	return this.A or ""
end
e2function number entity:gb()
	return this.B or 0
end
e2function number entity:gc()
	return this.C or 0
end
e2function void entity:gtrg(number a, number b)
	this:Triger(a,b)
end

e2function number wirelink:stargateDialChev(number chev)
	return DHDial(chev, this)
end

e2function number wirelink:stargateDialChev(string chev)
	return DHDial(string.byte(chev), this)
end

e2function void wirelink:stargateDialChevReset()
	this:Rst()
end

e2function void wirelink:stargateDialChevHReset()
	this:HRst()
end

--[[
	e2function void entity:stargateSetPointOfOrigin(string s)
		this:SetPointOfOrigin(s)
	end
]]--