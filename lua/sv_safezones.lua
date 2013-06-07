--[[
	SafeZone - Server
]]-- 

-- Globals
local MAP = string.lower(game.GetMap())
local FilePath = "safezones/" .. MAP .. ".txt"
local SpawnPath = "safezones/" .. MAP .. "spawns.txt"
local zData = zData or {}
local Spawns = {}

-- Load everything up
local function init() 
	MsgC( Color(0,200,0), "SafeZones loaded!\n" )

	if not file.IsDir( "safezones", "DATA" ) then
		file.CreateDir( "safezones", "DATA" )
	end

	if not file.Exists( FilePath, "DATA" ) then return end 

	local data = file.Read( FilePath, "DATA" )
	zData = util.JSONToTable( data )

	-- Load spawns
	local sp  = file.Read( SpawnPath, "DATA" ) or ""
	Spawns = util.JSONToTable( sp ) or {} 

	if table.Count( zData ) ~= 0 then 
		MsgC( Color(0,200,0), "SafeZone data for: " .. MAP .. " loaded!\n" )
	end
	
	if table.Count( Spawns ) ~= 0 then 
		MsgC( Color(0,200,0), "Spawn data for: " .. MAP .. " loaded!\n" )
	end
end 
hook.Add( "Initialize", "SafeZone_Init", init )


--[[-------------------------------------
-------------- Helpers ------------------
---------------------------------------]]

-- Forms the table with the corners of the box
local function formCorners( min, max ) 
	local size = max - min
	local x, y, z = size.x, size.y, size.z 

	return { 
		max, 
		max - Vector( 0,0,z ), 
		max - Vector( 0,y,0 ),
		max - Vector( x,0,0 ),
		min + Vector( 0,0,z ),
		min + Vector( 0,y,0 ),
		min + Vector( x,0,0 ),
		min
	}
end 

-- returns if 'v' is within the min/max vectors
local function inrange( v, min, max )
	if v.x < min.x then return false end 
	if v.y < min.y then return false end 
	if v.z < min.z then return false end 
	
	if v.x > max.x then return false end 
	if v.y > max.y then return false end 
	if v.z > max.z then return false end

	return true  
end 


-- Check if in safezone
local entmeta = FindMetaTable( "Entity" )
function entmeta:InSafeZone()
	local pos = self:GetPos() 
	for k,v in pairs(zData) do 
		local min = v.corners[2]
		local max = v.corners[5]

		if inrange( pos, min, max ) then
			return true 
		end
	end

	return false 
end

-- Same as above, but for just vectors
local vecmeta = FindMetaTable( "Vector" )
function vecmeta:InSafeZone()
	for k,v in pairs(zData) do 
		local v = zData[i]
		local min = v.corners[2]
		local max = v.corners[5]

		if inrange( self, min, max ) then
			return true 
		end
	end

	return false 
end 

-- turns 200,0,0 to Vector(200,0,0)
local function strToVec( s )
	local e = string.Explode( ",", s )

	return Vector( e[1], e[2], e[3] )
end 


-- save data
local function save()
	file.Write( FilePath, util.TableToJSON( zData ) )
end

-- Save spawns
local function saveSpawns()
	file.Write( SpawnPath, util.TableToJSON( Spawns ) )
end


-- send data to client 
util.AddNetworkString( "safezones_getzones" )
local function resend() 
	net.Start( "safezones_getzones" )
		net.WriteTable( zData )
	net.Broadcast()
end


--[[-------------------------------------
--------------- Hooks -------------------
---------------------------------------]]

-- Take damage: negate all damage if needed
local function takeDamage( ent, dmgInfo )
	local entpos = ent:GetPos()

	for k,v in pairs(zData) do 
		local min = v.corners[2]
		local max = v.corners[5]
		if inrange( entpos, min, max ) then
			dmgInfo:SetDamage(0)
			return 
		end
	end

	return dmgInfo  
end
hook.Add( "EntityTakeDamage", "SafeZone_Dmg", takeDamage )


-- PlayerNoClip: Stop people from noclipping.
local function playerNoClip( ply )
	if not ply:InSafeZone() then
		if not ply:IsAdmin() then 
			ULib.tsayError( ply, "You're in the killzone!" ) 
			return false 
		end 

		return false  
	end 

	return true
end
hook.Add( "PlayerNoClip", "SafeZone_NoClip", playerNoClip )


-- ULibCommandCalled: Stop using !god.
local function ulibCommandCalled( ply, cmd, args )
	if cmd ~= "ulx god" then return true end 

	if not ply:InSafeZone() then 
		if not ply:IsAdmin() then
			ULib.tsayError( ply, "You're in the killzone!" ) 
			return false 
		end 

		return true 
	end 
	
	return true 
end
hook.Add( "ULibCommandCalled", "SafeZone_God", ulibCommandCalled )


-- PlayerInitialSpawn: Send data bro.
local function playerInitialSpawn( ply )
	ply._oldpos = ply:GetPos()
	ply._oldclip = false 

	net.Start( "safezones_getzones" )
		net.WriteTable( zData )
	net.Send( ply )
end 
hook.Add( "PlayerInitialSpawn", "SafeZone_Connect", playerInitialSpawn )


-- PlayerSpawn: If doesn't have a custom spawn, use the maps.
local function playerSpawn( ply )
	if #Spawns < 1 then return end 
	if ply.spawn then return end 

	local i = math.random( 1, #Spawns )

	ply:SetPos( Spawns[i] )
end
hook.Add( "PlayerSpawn", "SafeZone_CustomSpawn", playerSpawn )


-- Think: check if a player is outside the zone and in god/noclip
local function tick()
	local players = player.GetAll()
	for i=1,#players do
		local v = players[i]

		if v:InSafeZone() then continue end 
		if v:IsAdmin() then continue end 

		if v:GetMoveType() == MOVETYPE_NOCLIP then
			v:SetMoveType( MOVETYPE_WALK )
		end

		if v.ULXHasGod then 
			v:GodDisable()
			v.ULXHasGod = false 
		end
	end

end
hook.Add( "Tick", "SafeZone_Think", tick )


--[[-------------------------------------
-------------- Commands -----------------
---------------------------------------]]
local function newSz_cmd( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end 
	local id = args[1]

	if zData[id] then 
		ULib.tsayError( ply, id .. " is already used as an ID!" )
		return 
	end

	local min = strToVec( args[2] )
	local max = strToVec( args[3] )

	if not min or not max then return end 

	zData[id] = {}

	zData[id].min = min 
	zData[id].max = max 
	zData[id].corners = formCorners( min, max )

	save()
	resend()

	ULib.tsayColor( ply, nil, Color(0,255,0), "SafeZone - " .. id .. " created!" )
end
concommand.Add( "sz_new", newSz_cmd )


local function removeSz_cmd( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end 

	local id = args[1]

	if not zData[id] then 
		ULib.tsayError( ply, nil, "Invalid or no ID specified!" )
		return 
	end
	
	zData[id] = nil 
	save()
	resend() 

	ULib.tsayColor( ply, nil, Color(0,255,0), "SafeZone - " .. id .. " removed!" )
end
concommand.Add( "sz_remove", removeSz_cmd )


util.AddNetworkString( "safezones_print" )
local function listSz_cmd( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end 

	net.Start( "safezones_print" )
	net.Send( ply )
end
concommand.Add( "sz_list", listSz_cmd )


local function newSpawn_cmd( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end 

	local tr = ply:GetEyeTrace() 
	if not tr.Hit then return end 

	local c = #Spawns + 1
	Spawns[c] = tr.HitPos 

	saveSpawns()

	ULib.tsayColor( ply, nil, Color(0,255,0), "New spawn point placed!" )
end 
concommand.Add( "new_spawnpoint", newSpawn_cmd )


local function clearSpawns_cmd( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end 

	Spawns = {}
	saveSpawns()

	ULib.tsayColor( ply, nil, Color(0,255,0), "Spawn points cleared!" )
end 
concommand.Add( "clear_spawnpoints", clearSpawns_cmd )
