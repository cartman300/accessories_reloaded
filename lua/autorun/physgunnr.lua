local function Physgunnr(p,e)
	if(IsValid(e) and (e.AntiPickup or e.IsBrush)) then
		return false;
	end
end

hook.Add("GravGunPunt","accessory_punt", Physgunnr);
hook.Add("GravGunPickupAllowed","accessory_grav_pickup", Physgunnr);
hook.Add("PhysgunPickup","accessory_phys_pickup", Physgunnr);
hook.Add("CanPlayerUnfreeze","accessory_unfreeze", Physgunnr);