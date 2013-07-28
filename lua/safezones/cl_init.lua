--[[
	-- Safezones -- 

	Clientside framework
]]--


-- Master table 
Zones = {}
Zones.zones = {}
Zones.spawns = {}


CreateClientConVar( "zones_drawzones", 1, true, false )

-- Chat messages, I know like every major addon has one of these
-- but I don't like having large dependencies.
net.Receive( "zones_chat", function() 
	chat.AddText( unpack( net.ReadTable() ) )
end )


-- Receiving the data for zones 
net.Receive( "zones_data", function() 
	local tbl = net.ReadTable() 
	Zones.zones = tbl.zones or {} 
	Zones.spawns = tbl.spawns or {} 
end )

local function postDrawOpaqueRenderables() 
	local zones = Zones.zones 
	if not zones then return end 
	if #zones < 1 then return end 
	
	for i=1,#zones do 
		-- zones[i]:Draw()
		DrawZone( zones[i] )
	end 
end 

hook.Add( "PostDrawOpaqueRenderables", "zones_draw", postDrawOpaqueRenderables )
