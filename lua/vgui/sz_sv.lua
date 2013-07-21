-- server wrapping for menus

-- why do i need this?
if not SERVER then return end 

util.AddNetworkString( "zones_zdata" )
net.Receive( "zones_zdata", function( _, sender ) 
	-- juuuuuuuuuuuust in case.
	if not sender:IsSuperAdmin() then return end 

	local name = net.ReadString()
	local data = net.ReadTable() 

	for _,v in pairs( Zones.zones ) do 
		if v._name == name then 
			v = data 
		end 
	end 

	Zones.saveData() 
	Zones.updateZones()
	-- todo, error checking.
end )

util.AddNetworkString( "zones_spawndata" )
net.Receive( "zones_spawndata", function( _, sender )
	if not ply:IsSuperAdmin() then return end 

	Zones.spawns = net.ReadTable()
	saveData()
end )