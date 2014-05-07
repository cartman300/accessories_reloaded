local ReadBit = net.ReadBit

function net.ReadBit(ReturnBool)
	local Bit = ReadBit()
	if (ReturnBool) then
		return Bit > 0
	end
	return Bit
end