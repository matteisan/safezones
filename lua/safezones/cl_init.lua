--[[
	-- Safezones -- 

	Clientside framework
]]--


-- Master table 
Zones = {}
Zones.zones = {}
Zones.spawns = {}

-- Chat messages, I know like every major addon has one of these
-- but I don't like having large dependencies.
net.Receive( "zones_chat", function() 
	chat.AddText( unpack( net.ReadTable() ) )
end )


-- Receiving the data for zones 
net.Receive( "zones_data", function() 
	local tbl = net.ReadTable() 
	local zones = tbl.zones or {} 
	Zones.spawns = tbl.spawns or {} 
	Zones.zones = {} 
	-- Make zone from table data.
	for k,v in pairs( zones ) do
		local zone = MakeZoneFromTable( v )
		table.insert( Zones.zones, zone )
	end 
end )

local function postDrawOpaqueRenderables() 
	local zones = Zones.zones 
	if not zones then return end 
	if #zones < 1 then return end 
	
	for i=1,#zones do 
		zones[i]:Draw()
	end 
end 

CreateClientConVar( "zones_drawzones", 1, true, false )
hook.Add( "PostDrawOpaqueRenderables", "sz_draw", postDrawOpaqueRenderables )

cvars.AddChangeCallback( "zones_drawzones", function( cvar, old, new ) 
	if new ~= 0 then 
		hook.Add( "PostDrawOpaqueRenderables", "sz_draw", postDrawOpaqueRenderables )
	else 
		hook.Remove( "PostDrawOpaqueRenderables", "sz_draw" )
	end 
end )
