--[[
	Zone Object 
]]--

ZONE = {} 
zonemeta = {
	__index = ZONE, 
	__tostring = function( t )
		local ret = t._name .. ": [\n"
		for i=1,#t do 
			ret = ret .. "\t" .. t[i] .. "\n"
		end 
	
		return ret .. "]\n"
	end,
	__call = function( _, ... ) return Zone( ... ) end 
}


function ZONE:CalculateMinMax() 
	local corners = self._corners
	-- This is to make sure the values given are real corners to begin with.
	local min = self._min  
	local max = self._max
	
	for i=1,#corners do 
		local c = corners[i]
		min.x = c.x < min.x and c.x or min.x 
		min.y = c.y < min.y and c.y or min.y
		min.z = c.z < min.z and c.z or min.z 
		
		max.x = c.x > max.x and c.x or max.x 
		max.y = c.y > max.y and c.y or max.y
		max.z = c.z > max.z and c.z or max.z 
	end 
	
	self._truemin = min 
	self._truemax = max 
	self:CalculateCorners()
end 

function ZONE:CalculateCorners()
	local size = self._max - self._min 
	local x, y, z = size.x, size.y, size.z 
		self._corners = {
		self._max, 
		self._max - Vector(0,0,z),
		self._max - Vector(0,y,0),
		self._max - Vector(x,0,0),
		self._min + Vector(0,0,z),
		self._min + Vector(0,y,0),
		self._min + Vector(x,0,0),
		self._min
	}
end 

function ZONE:GetCorners() 
	return self._corners 
end 

function ZONE:Name() 
	return self._name 
end 

function ZONE:GetMin() 
	return self._min 
end 

function ZONE:GetMax() 
	return self._max 
end 

function ZONE:GetColor() 
	return self._clr 
end 

function ZONE:SetMin( v )
	self._min = v 
end 

function ZONE:SetMax( v ) 
	self._max = v 
end 

function ZONE:SetColor( color )
	self._clr = color 
end 

function ZONE:Editing()
	return self._editing
end 

function ZONE:SetEditing( bool ) 
	self._editing = bool 
end 
 

function ZONE:ToTable() 
	local tbl = {}
	for k,v in pairs( self ) do 
		tbl[k] = v 
	end 

	return tbl
end 

-- args: Name of zone, Min vec, max vec, Corner table
function ZONE.new( name, min, max, corners )
	local data = {
		_name = name or "", 
		_corners = corners or {},
		_min = min or corners[1] or Vector(),
		_max = max or corners[8] or Vector(),
		_truemin = min or Vector(),
		_truemax = max or Vector(),
		_editing = false,
		_clr = Color( 255, 255, 255 )
	}

	setmetatable(data,zonemeta)
	return data 
end 

function Zone( name, min, max, corners )
	return ZONE.new( name, min, max, corners )
end 

function b_tonumber( bool )
	return (bool == true) and 1 or -1
end 

function ZONE:Draw()
	local corners = self._corners 
	local min = self._min 
	local max = self._max 
	local clr = self._clr 
	local r, g, b = clr.r, clr.g, clr.b

	cam.Start3D2D( max, Angle(0,0,0), 1 ) 
		surface.SetDrawColor( Color(r, g, b, 255) )

		local x = ( b_tonumber(max.x < corners[4].x) * max:Distance(corners[4]) )
		local y = ( b_tonumber(max.y > corners[3].y) * max:Distance(corners[3]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()

	cam.Start3D2D( max, Angle(0,0,90), 1 )
		surface.SetDrawColor(  Color(r, g, b, 255) )

		local x = ( b_tonumber(max.x < corners[4].x) * max:Distance(corners[4]) )
		local y = ( b_tonumber(max.z > corners[2].z) * max:Distance(corners[2]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()

	cam.Start3D2D( max, Angle(90,0,0), 1 )
		surface.SetDrawColor( Color(r, g, b, 255) )

		local x = ( b_tonumber(max.z > corners[2].z) * max:Distance(corners[2]) )
		local y = ( b_tonumber(max.y > corners[3].y) * max:Distance(corners[3]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()

	cam.Start3D2D( min, Angle(0,0,0), 1 ) 
		surface.SetDrawColor( Color(r, g, b, 255) )

		local x = ( b_tonumber(min.x < corners[7].x) * min:Distance(corners[7]) )
		local y = ( b_tonumber(min.y > corners[6].y) * min:Distance(corners[6]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()

	cam.Start3D2D( min, Angle(0,0,90), 1 ) 
		surface.SetDrawColor( Color(r, g, b, 255) )

		local x = ( b_tonumber(min.x < corners[7].x) * min:Distance(corners[7]) )
		local y = ( b_tonumber(min.z > corners[5].z) * min:Distance(corners[5]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()

	cam.Start3D2D( min, Angle(90,0,0), 1 ) 
		surface.SetDrawColor( Color(r, g, b, 255) )

		local x = ( b_tonumber(min.z > corners[5].z) * min:Distance(corners[5]) )
		local y = ( b_tonumber(min.y > corners[6].y) * min:Distance(corners[6]) )

		surface.DrawOutlinedRect( 0, 0, x, y )
	cam.End3D2D()
end 


--[[ Other Various Helpers ]]-- 

-- returns true if 'v' is within the points 
function inrange( v, min, max )
	if v.x < min.x then return false end 
	if v.y < min.y then return false end 
	if v.z < min.z then return false end 

	if v.x > max.x then return false end 
	if v.y > max.y then return false end 
	if v.z > max.z then return false end 

	return true 
end 

function MakeZoneFromTable( tbl )
	local zone = Zone( tbl._name, tbl._min, tbl._max, tbl._corners ) 

	for k,v in pairs( tbl ) do 
		zone[k] = v 
	end 

	return zone 
end 
