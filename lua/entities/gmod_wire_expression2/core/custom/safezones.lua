E2Lib.RegisterExtension( "safezones", true )
__e2setcost(1)
e2function number entity:inSafeZone() 
	if not E2Lib.IsValid( this ) then return 0 end 
	return ( this:InSafeZone() and 1 ) or 0 
end 
__e2setcost(nil)