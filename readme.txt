SafeZones
	
	Desc: Scripts to give a map safezones, so builders can build,
	and killers can kill in their respective areas. You can 
	have different zones for different maps, this is made to make 
	all that easier. Also comes with Custom Spawn Points

	Commands: 
		sz_new <id> <boxMax (vector)> <boxMin (vector)>;
		sz_remove <id>;
		sz_list; -- Prints the map's safezones by ID
		new_spawnpoint; 
		clear_spawnpoints; 

	Examples: 
		sz_new MainSpawn 0,0,0 1000,1000,1000 
		sz_remove MainSpawn
		sz_list 

	Data: 
		Saved to: data/SafeZones/<map name> 

	Author: Adult

	Thanks to: Awcmon for helping out and pretty much telling me 
	how to do this.