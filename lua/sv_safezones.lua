--[[
	SafeZone - Server
]]-- 

-- Globals
local MAP = game.GetMap()
local FilePath = "SafeZones/" .. MAP .. ".txt"
local zData = zData or {}

-- Load everything up
local function init() 
	MsgC( Color(0,200,0), "SafeZones loaded!\n" )

	if not file.IsDir( "SafeZones", "DATA" ) then
		file.CreateDir( "SafeZones", "DATA" )
	end

	if not file.Exists( FilePath, "DATA" ) then return end 

	local data = file.Read( FilePath, "DATA" )

	zData = util.JSONToTable( data )

	MsgC( Color(0,200,0), "SafeZone data for: " .. MAP .. " loaded!\n" )
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
local plymeta = FindMetaTable( "Entity" )
function plymeta:InSafeZone()
	local pos = self:GetPos() 
	for k,v in pairs( zData ) do
		local min = v.corners[2]
		local max = v.corners[5]

		if inrange( pos, min, max ) then
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
	local attacker = dmgInfo:GetAttacker()
	if not attacker then return end 

	local attpos = attacker:GetPos()
	local entpos = ent:GetPos()

	for k,v in pairs( zData ) do 
		local min = v.corners[2]
		local max = v.corners[5]
		if inrange( entpos, min, max ) then
			dmgInfo:SetDamage(0)
			return 
		end

		if not attacker then 
			dmgInfo:SetDamage(0)
			return 
		end
		
		if not inrange( attpos, min, max ) then 
			dmgInfo:SetDamage(0)
			return 
		end
	end
end
hook.Add( "EntityTakeDamage", "SafeZone_Dmg", takeDamage )


-- PlayerNoClip: Stop people from noclipping.
local function playerNoClip( ply )
	if not ply:InSafeZone() then
		if not ply:IsAdmin() then 
			ULib.tsayError( ply, "You're in the safezone!" ) 
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
			ULib.tsayError( ply, "You're in the safezone!" ) 
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


-- Think: check if a player is outside the zone and in god/noclip
local function think()
	for k,v in pairs( player.GetAll() ) do
		if v:InSafeZone() then continue end 
		if v:IsAdmin() then continue end 

		local oldpos  = v._oldpos
		local newpos  = v:GetPos()

		if oldpos ~= newpos then 
			local oldclip = v._oldclip
			local oldgod  = v._oldgod 
			local newclip = v:GetMoveType() == MOVETYPE_NOCLIP
			local newgod  = v.ULXHasGod 

			if oldclip ~= newclip then 
				v:SetMoveType( MOVETYPE_WALK )
				v._oldclip = false 
			end 

			if oldgod ~= newgod then
				v:GodDisable()
				v.ULXHasGod = false 
				v._oldgod = false 
			end 
		end
	end

end
hook.Add( "Think", "SafeZone_Think", think )



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

