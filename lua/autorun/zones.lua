--[[
	-- safezones --

	Author: Adult

	Description: A series of useful tools that are based around the use
	of safezones, where players can build in peace and not get killed.
	Designed to make compatibility with admin mods easy.

	Includes: 
		- safezones 
		- Per zone permissions 
		- Default safezone spawns
		- Custom spawns 
		- Decorative designs 
		- GUI to manage safezones 
		- Clientside interaction
		- Teleporters for interzone-transportation.
]]--

-- Send client files and load server files
if SERVER then
	AddCSLuaFile( "safezones/cl_init.lua" )
	AddCSLuaFile( "safezones/zones.lua")
	AddCSLuaFile( "vgui/sz_cl.lua" )

	include( "safezones/zones.lua" )
	include( "safezones/sv_init.lua" )
	include( "vgui/sz_sv.lua")
end


if CLIENT then
	include( "safezones/zones.lua" )
	include( "safezones/cl_init.lua" )
	include( "vgui/sz_cl.lua" )
end

-- compat files
local f = file.Find( "compatibility/*", "LUA" ) 
for k,v in pairs( f ) do
	if SERVER then 
		AddCSLuaFile( "compatibility/" .. v )
	end 
	include( "compatibility/" .. v )
end 