if SERVER then 
	hook.Add("ACF_BulletDamage","SafeZone_ACF", function( _, ent, _, _, _, inflictor, _, gun )
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
		if ammo:InSafeZone() then return end 
		if ammo:InSafeZone() then
			return false 
		end 
	end )
end 
