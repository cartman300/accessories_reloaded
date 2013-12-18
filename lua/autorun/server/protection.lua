function Prot(p,e)
	if(IsValid(e) and (e.AntiPhysgun)) then
		return false;
	end
end
hook.Add("GravGunPunt","a13_punt",Prot);
hook.Add("GravGunPickupAllowed","a13_grav_pickup",Prot);
hook.Add("PhysgunPickup","a13_phys_pickup",Prot);
hook.Add("CanPlayerUnfreeze","a13_unfreeze",Prot);