--[[
	SafeZone - Custom Spawn Point
]]--

ENT.Base      = "base_gmodentity"
ENT.Type      = "anim"
ENT.PrintName = "Custom Spawn Point"
ENT.Author    = "Adult"

ENT.Spawnable = true 

if SERVER then
	AddCSLuaFile()

	function ENT:SpawnFunction( ply, tr )
		if not tr.Hit then return end 

		local pos = tr.HitPos 
		local ent = ents.Create( "sent_spawnpoint" )

		ent:SetPos( pos + Vector(0,0,10) )
		ent:Spawn()
		ent:Activate()

		ent.owner = ply 

		-- Normally I wouldn't use networking, but this is
		-- the easiest possible way for the client to get it.
		ent:SetNetworkedEntity( "Owner", ply )
		return ent 
	end 

	function ENT:Initialize() 
		self.Entity:SetModel( "models/props_combine/combine_mine01.mdl" )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )

		local owner = self.owner
		owner.spawn = self:GetPos() + Vector(0,0,25)
	end
	
	function ENT:OnRemove()
		local owner = self.owner
		if not owner then return end 

		owner.spawn = nil
	end
	
	function ENT:Use( activator, caller )
		if not activator then return end
		if not caller then return end 
		if activator ~= self.owner then return end 

		activator.spawn = self:GetPos() + Vector(0,0,25)
		activator:PrintMessage( 4, "Spawnpoint set!" )

		local phys = self.Entity:GetPhysicsObject()
		if phys then 
			phys:EnableMotion( false )
		end
	end 

	local function playerSelectSpawn( ply )
		if not ply.spawn then return end 

		ply:SetPos( ply.spawn )
	end
	hook.Add( "PlayerSpawn", "SpawnPoint", playerSelectSpawn )
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
		local name  = self.PrintName 
		local owner = self.Entity:GetNetworkedEntity( "Owner" ):Name()
		local text  = string.format( "- %s - \nOwner: %s", name, owner )

		AddWorldTip( nil, text, nil, self:GetPos(), nil )
	end
end 