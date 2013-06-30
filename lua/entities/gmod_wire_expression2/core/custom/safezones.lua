__e2setcost(2)

e2function number entity:inSafeZone() 
	if not E2Lib.IsValid( this ) then return 0 end 
	return ( this:InSafeZone() and 1 ) or 0 
end 

__e2setcost(nil)