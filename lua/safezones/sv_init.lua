--[[
	-- Zones -- 

	Serverside framework
]]-- 

-- Master table 
Zones = {}
Zones.zones = {} 
Zones.spawns = {}
Zones.edit = {}
Zones.MAP = game.GetMap()

-- File in which data will be saved 
Zones.DATA_PATH = "safezones/" .. Zones.MAP .. ".txt"

-- ------------------------------------------------ --
-- --------- Loading all files and data ----------- -- 
-- ------------------------------------------------ --
local function init() 
	if not file.IsDir( "safezones", "DATA" ) then
		file.CreateDir( "safezones", "DATA" )
	end

	local path = Zones.DATA_PATH 

	-- File doesn't exist yet.
	if not file.Exists( path, "DATA" ) then return end 

	-- Zone and Spawn Data 
	-- Note: not using Zones = data because it will overwrite needed variables.
	local data = util.JSONToTable( file.Read( path, "DATA" ) )
	Zones.zones = data.zones or {} 
	Zones.spawns = data.spawns or {}

	if table.Count( Zones.zones ) ~= 0 then
		MsgC( Color(200,200,0), "Zone data loaded for map: " .. Zones.MAP .. "!\n" )
		
		-- This is to make it so the zones loaded from 
		-- the save data have the correct metatable.
		local oldzones = Zones.zones 
		Zones.zones = {} 
		for k,v in pairs( oldzones ) do 
			local zone = Zone( v._name, v._min, v._max, v._corners ) 
			zone._truemin = v._truemin 
			zone._truemax = v._truemax 
			zone._defclr = v._defclr 
			zone._editing = false 

			table.insert( Zones.zones, zone )
		end
	end

	if table.Count( Zones.spawns ) ~= 0 then
		MsgC( Color(200,200,0), "Spawn data loaded for map: " .. Zones.MAP .. "!\n" )
	end


end 
hook.Add( "Initialize", "Safezones_init", init )

-- ------------------------------------ -- 
-- ------- Custom Chat Messages ------- -- 
-- ------------------------------------ --
util.AddNetworkString( "zones_chat" )
function Zones.message( ply, tbl )
	net.Start( "zones_chat" )
		net.WriteTable( tbl )

	if IsValid( ply ) then
		net.Send( ply )
	else 
		net.Broadcast()
	end 
end 

function Zones.success( ply, msg )
	local tbl = { Color(100,200,100), "[Safezones] ", Color(0,255,0), msg }
	Zones.message( ply or nil, tbl ) 
end 

function Zones.error( ply, msg )
	local tbl = { Color(100,200,100), "[Safezones] ", Color(255,0,0), msg }
	Zones.message( ply or nil, tbl ) 
end 

function Zones.updateZones()
	local oldzones = Zones.zones 
	Zones.zones = {} 
	for k,v in pairs( oldzones ) do 
		local zone = Zone( v._name, v._min, v._max, v._corners ) 
		zone._truemin = v._truemin 
		zone._truemax = v._truemax 
		zone._defclr = v._defclr 
		zone._editing = false 

		table.insert( Zones.zones, zone )
	end
end 

-- ------------------------------------ -- 
-- --------- Data sending ------------- --
-- ------------------------------------ -- 
util.AddNetworkString( "zones_data" )
function Zones.sendData( ply ) 
	local tbl = { 
		zones = Zones.zones, 
		spawns = Zones.spawns 
	}
	
	net.Start( "zones_data" )
		net.WriteTable( tbl )
	if IsValid( ply ) then 
		net.Send( ply )
	else 
		net.Broadcast() 
	end 
end 


-- ------------------------------------ -- 
-- ------- Simple save function ------- -- 
-- ------------------------------------ --
function Zones.saveData( ply ) 
	if not ply:IsSuperAdmin() then return end 
	local tbl = {}
	tbl.spawns = Zones.spawns 
	tbl.zones = {} 
	
	for k,v in pairs( Zones.zones ) do
		table.insert( tbl.zones, v:ToTable() )
	end

	file.Write( Zones.DATA_PATH, util.TableToJSON( Zones ) )
end
concommand.Add( "safezones_save", Zones.saveData )	  

-- These are the points that dictate where the points are
local function newPoint()
	local e = ents.Create("prop_physics")
		e:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		e:SetMaterial("models/debug/debugwhite")
		e:Spawn()
		e:SetMoveType( MOVETYPE_NONE )
		e._iszone = true 
		
	return e 
end 

local floor = math.floor 
local function round( vec )
	return Vector( floor(vec.x), floor(vec.y), floor(vec.z) )
end 

function Zones.newZone( name, caller )
	local top = newPoint()
	top:SetColor( Color(255,0,0) )

	-- This is the mid point, not handled 
	-- clientside at all. It's used to just 
	-- move the the zone as a whole.
	local mid = newPoint() 
	mid:SetColor( Color(0,0,255) )
	mid._mid = true 

	local bot = newPoint()
	bot:SetColor( Color(0,255,0) )


	local offset = Vector(0,0,25)

	top:SetPos( caller:GetPos() + ( caller:GetForward() * 150 ) + ( offset * 3 ) )
	top._oldpos = top:GetPos()

	mid:SetPos( caller:GetPos() + ( caller:GetForward() * 150 ) + ( offset * 2 ) )
	mid._oldpos = mid:GetPos() 

	bot:SetPos( caller:GetPos() + ( caller:GetForward() * 150 ) + offset )
	bot._oldpos = bot:GetPos() 

	local zone = Zone( name, round(bot:GetPos()), round(top:GetPos()), {} )
	zone:SetEditing( true )
	table.insert( Zones.zones, zone )
	
	-- todo; non-lazy cleanup strategy.
	-- For Cleanup:
	zone._points = { top, mid, bot }

	hook.Add( "Tick", "Safezones_editing", function() 
		-- More efficient than calling :GetPos each time
		local bpos = bot:GetPos()
		local mpos = mid:GetPos()
		local tpos = top:GetPos() 

		-- If the position hasn't changed, don't 
		-- bother doing anything.
		if tpos == top._oldpos and 
			mpos == mid._oldpos and 
			bpos == bot._oldpos then return end 

		-- You moved the midpoint
		if mpos ~= mid._oldpos then 
			top:SetPos( mid:LocalToWorld( top._oldpos - mid._oldpos ) )
			top._oldpos = top:GetPos()
			tpos = top:GetPos()

			bot:SetPos( mid:LocalToWorld( bot._oldpos - mid._oldpos ) ) 
			bot._oldpos = bot:GetPos()
			bpos = bot:GetPos()
	 	elseif tpos ~= top._oldpos or bpos ~= bot._oldpos then  -- You moved one of the other points
	 		mid:SetPos( ( tpos + bpos ) / 2 )
	 		mid._oldpos = mid:GetPos()
	 		mpos = mid:GetPos()
	 	end 

	 	-- Recalculate, send, and cache positions
	 	zone:SetMin( round(bpos) )
	 	zone:SetMax( round(tpos) )
	 	zone:CalculateCorners()
	 	Zones.sendData() 
	 	bot._oldpos = bpos 
	 	mid._oldpos = mpos 
	 	top._oldpos = tpos 

	end )
end 



concommand.Add( "safezone_new", function( ply, _, args ) 
	if not ply:IsSuperAdmin() then return end 
	Zones.newZone( args[1], ply )
end )


concommand.Add( "safezone_finish", function( ply, _, args )
	if not ply:IsSuperAdmin() then return end 

	for k,v in pairs( Zones.zones ) do
		if v:Name() == args[1] then 
			v:SetEditing( false )
			v:CalculateMinMax()
			Zones.success( ply, args[1] .. " finished editing." )
			hook.Remove( "Tick", "Safezones_editing" )
			Zones.sendData()

			for i=1,#v._points do 
				v._points[i]:Remove()
			end 

			v._points = nil 
			
			break
		end 
	end
end )

concommand.Add( "safezone_remove", function( ply, cmd, args ) 
	if not ply:IsSuperAdmin() then return end 

	for k,v in pairs( Zones.zones ) do 
		if v:Name() == args[1] then 
			Zones.success( ply, args[1] .. " removed!" )
			Zones.zones[k] = nil 
			Zones.saveData( ply )
			Zones.sendData()

			break
		end 
	end 
end )

concommand.Add( "safezones_addspawn", function( ply ) 
	if not ply:IsSuperAdmin() then return end 

	local tr = ply:GetEyeTrace() 
	if not tr.Hit then return end 

	local pos = tr.HitPos 

	table.insert( Zones.spawns, pos )
	Zones.success( ply, "Spawnpoint placed and saved!" )
	Zones.saveData( ply )
end )

concommand.Add( "safezones_clearspawns", function( ply ) 
	if not ply:IsSuperAdmin() then return end 

	Zones.spawns = {} 
	Zones.success( ply, "Spawnpoints cleared and saved." )
	Zones.saveData( ply )
end ) 

-- ----------------------------------- --
-- -------------- Hooks -------------- -- 
-- ----------------------------------- -- 

-- helper to check if there are no zones.
function Zones.noZones()
	return #Zones.zones < 1 
end 

-- easy for now
local noZones = Zones.noZones

local function takeDamage( ent, dmgInfo )
	if noZones() then return dmgInfo end 

	if ent:InSafeZone() then 
		dmgInfo:SetDamage(0)
		return dmgInfo
	end 

	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:InSafeZone() then
		dmgInfo:SetDamage(0)
		return dmgInfo 
	end

	local inflictor = dmgInfo:GetInflictor()
	if IsValid(inflictor) and inflictor:InSafeZone() then
		dmgInfo:SetDamage(0)
		return dmgInfo 
	end

	return dmgInfo
end 
hook.Add( "EntityTakeDamage", "Safezones_TakeDamge", takeDamage )


local function playerInitialSpawn( ply ) 
	Zones.sendData( ply )
end 
hook.Add( "PlayerInitialSpawn", "Safezones_FirstSpawn", playerInitialSpawn )


local function playerSpawn( ply )
	if #Zones.spawns < 1 then return end 
	-- built in spawnpoint stuff
	if ply.custom_spawn then return end 

	local i = math.random( 1, #Zones.spawns )

	ply:SetPos( Zones.spawns[i] + Vector(0,0,10) )
end 
hook.Add( "PlayerSpawn", "Safezones_Spawn", playerSpawn )


local function playerNoClip( ply )
	if noZones() then return end 

	if not ply:InSafeZone() and not ply:IsAdmin() then 
		Zones.error( ply, "You're not allowed to noclip here!" )
		return false 
	end	
end 
hook.Add( "PlayerNoClip", "Safezones_NoClip", playerNoClip )


local function tick() 
	if noZones() then return end 

	local players = player.GetAll() 

	for i=1,#players do 
		local v = players[i]

		if v:InSafeZone() then continue end 
		if v:IsAdmin() then continue end 

		if v:GetMoveType() == MOVETYPE_NOCLIP then 
			v:SetMoveType( MOVETYPE_WALK )
		end 
	end 
end 
hook.Add( "Tick", "Safezones_Tick", tick )


-- returns true if 'v' is within the points 
local function inrange( v, min, max )
	if v.x < min.x then return false end 
	if v.y < min.y then return false end 
	if v.z < min.z then return false end 
	

	if v.x > max.x then return false end 
	if v.y > max.y then return false end
	if v.z > max.z then return false end 
	
	return true 
end 


-- Check if inside safezone 
local entmeta = FindMetaTable( "Entity" )
function entmeta:InSafeZone( name ) 
	local pos = self:GetPos()

	-- not using a pairs loop to increase speed in luajit
	for i=1,table.Count(Zones.zones) do 
		local zone = Zones.zones[i]
		if name ~= nil and zone._name ~= name then continue end

		if inrange( pos, zone._truemin, zone._truemax ) then 
			return true 
		end 
	end 

	return false 
end

local vecmeta = FindMetaTable( "Vector" )
function vecmeta:InSafeZone( name ) 
	-- not using a pairs loop to increase speed in luajit
	for i=1,#Zones.zones do 
		local zone = Zones.zones[i]
		if name ~= nil and zone:Name() ~= name then continue end 

		if inrange( self, zone._truemin, zone._truemax ) then 
			return true 
		end 
	end 

	return false 
end
