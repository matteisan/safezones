#Safezones
##Safezones are an addon for Garry's Mod that allow for administrators to create zones where noclip and god mode are enabled and no prop damage is alloewd.

###If you have any issues or request, please create new issue about it here: http://github.com/matteisan/safezones/issues [GitHub](http://github.com/matteisan/issues)

####Instructions:
* You must be Super Admin to use this.
* Type safezone_new "Name" in console.
	* This will create three new cubes in front of your player.
	* The blue is for moving the zone, the other two are for resizing the zone.
* Position the markers wherever you want them.
* Type safezone_finish "Name" in console.
	* This does all final calculations and properly sends data to the clients.
* Type safezones_save to save all the data.


####Other commands (**Remember to run safezones_save to save after using these commands**):
* safezone_setoption "Name" "Option" "Value(s)" 
	* This is primarily used for setting options for particular zones.
	* Example: safezone_setoption "ACFZone" "acf" "1"
	* Sets ACF enabled in the zone ACFZone
* safezone_setcolor "Name" "R" "G" "B"
	* Sets the color of a safezone.
	* Example: safezone_setcolor "Zone" "255" "0" "0"
* safezone_remove "Name"
	* Removes the given zone.
	* Example: safezone_remove "Zone"
* safezones_addspawn 
	* Adds a spawn where you are looking.
	* Auto saves.
* safezones_clearspawns 
	* Clears all spawns in the map.
	* Auto saves.

#####For developers: 
* If you call safezone_setoption with a custom option, it will save with the rest of the zone data.
	* You can use this to handle zones serverside with custom options.
	* Example: safezone_setoption "Zone" "test" "string or number or anything"
	* This is will make Zone.test return "string or number or anything"

* If you wish to contribute, check out the todo.txt, those have the plans for safezones in the future.
