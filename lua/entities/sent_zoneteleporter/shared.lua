--[[
	SafeZone - Teleporters
]]--

ENT.Base      = "base_gmodentity"
ENT.Type      = "anim"
ENT.PrintName = "Zone Teleporter"
ENT.Author    = "Adult"

ENT.Spawnable = false
ENT.AdminOnly = false  

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize() 
		self.Entity:SetModel( "models/props_docks/channelmarker_gib03.mdl" )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.last_press = 0
	end
	
	function ENT:Use( activator )
		if not activator then return end
		if activator == self.ignore then return end 
		if ( CurTime() - self.last_press ) < 2 then return end 

 		local dest = self.dest
		local zone = Zones.getZoneByName( dest )
		if not zone then return end 

		local tp = zone.teleporter
		tp.ignore = activator
		activator:SetAngles( tp:LocalToWorldAngles( Angle( 0, 180, 0 ) ) )
		activator:SetPos( tp:LocalToWorld( Vector( -25, 0, 0 ) ) )	
		self.last_press = CurTime()
	end 

	function ENT:Think() 
		if ( CurTime() - self.last_press ) > 2 then 
			self.ignore = nil
		end 
	end 
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()

		local ply = LocalPlayer()
		local tr  = ply:GetEyeTrace()
		if tr.Entity == self and ply:GetPos():Distance( self.Entity:GetPos() ) < 250 then 
			self.Entity:DrawTip()
		end
	end

	function ENT:DrawTip()
		local text  = string.format( "- Zone Teleporter - \nSource Zone: %s\nTarget Zone: %s", self:GetNetworkedString( "Source" ), self:GetNetworkedString( "Destination" ) )

		AddWorldTip( nil, text, nil, self:GetPos(), nil )
	end
end 
