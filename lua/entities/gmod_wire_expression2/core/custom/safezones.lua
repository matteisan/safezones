E2Lib.RegisterExtension( "safezones", true )

__e2setcost(1)
e2function number entity:inSafeZone() 
	if not E2Lib.IsValid( this ) then return 0 end 
	return ( this:InSafeZone() and 1 ) or 0 
end 

__e2setcost(5)
e2function array safezoneCorners( string name )
	if not Zones.exists( name ) then return {} end 
	return Zones.getZoneByName( name ):GetCorners() 
end 

__e2setcost(5)
e2function table safezoneData( string name ) 
	if not Zones.exists( name ) then return {} end 
	return Zones.getZoneByName( name ):ToTable() 
end 

__e2setcost(1)
e2function number safezoneExists( string name ) 
	return Zones.exists( name ) and 1 or 0 
end 

__e2setcost(nil)