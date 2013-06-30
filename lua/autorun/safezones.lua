--[[
	SafeZones
	
	Desc: Scripts to give a map safezones, so builders can build,
	and killers can kill in their respective areas. You can 
	have different zones for different maps, this is made to make 
	all that easier.

	Dependencies: Loosely dependent on ULib, but I'll be fixing 
	that shortly. It was just a lazy fix of mine.

	Commands: 
		sz_new <id> <boxMin (vector)> <boxMax (vector)>;
		sz_remove <id>;
		sz_list; -- Prints the map's safezones by ID

	Examples: 
		sz_new MainSpawn 0,0,0 1000,1000,1000 
		sz_remove MainSpawn
		sz_list 

	Data: 
		Saved to: data/SafeZones/<map name> 

	Author: Adult

	Thanks to: Awcmon for helping out and pretty much telling me 
	how to do this.
]]--


-- Server files
if SERVER then 
	AddCSLuaFile()
	AddCSLuaFile( "cl_safezones.lua" )

	include( "sv_safezones.lua" )
	include( "acf.lua" )
end

-- Client file
if CLIENT then
	include( "cl_safezones.lua" )
end
