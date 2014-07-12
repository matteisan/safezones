local entmeta = FindMetaTable("Entity")

function entmeta:InACFZone( name )
	if not IsValid( self ) then return end 
	local pos = self:GetPos() 

	for i=1,table.Count(Zones.zones) do 
		local zone = Zones.zones[i]
		if not zone.acf or tonumber(zone.acf) == 0 then continue end 
		if name ~= nil and zone:Name() ~= name then continue end 

		if inrange( pos, zone._truemin, zone._truemax ) then
			return true 
		end 
	end 

	return false 
end 


if SERVER then 
	hook.Add("ACF_BulletDamage","SafeZone_ACF", function( _, ent, _, _, _, inflictor, _, gun )
		if ent:InACFZone() and not inflictor:InACFZone() then
			return false
		end 

		if ent:InACFZone() or inflictor:InACFZone() or ( IsValid( gun ) and gun:InACFZone() ) then return end 
		
		-- The validity check on the gun is in case the person is using a torch.
		if ent:InSafeZone() or inflictor:InSafeZone() or ( IsValid( gun ) and gun:InSafeZone() ) then 
			return false 
		end 
	end )
	
	hook.Add("ACF_FireShell", "SafeZone_FireShell", function( gun )
		if gun:InACFZone() then return end 
		if gun:InSafeZone() then 
			return false 
		end 
	end )
	
	hook.Add("ACF_AmmoExplode", "SafeZone_Ammo", function( ammo, bdata ) 
		if ammo:InACFZone() then return end 
		if ammo:InSafeZone() then
			return false 
		end 
	end )
end 
