if SERVER then 
	local function err( ply, msg )
		ULib.tsayError( ply, "You're not in a safezone!" or msg )
	end 

	hook.Add( "ULibCommandCalled", "StopAbusing", function( ply, cmd, args ) 
		if not IsValid( ply ) then return end 
		if ply:IsAdmin() then return end 
		if ply:InSafeZone() then return end 

		if cmd == "ulx god" then 
			err( ply )
		end 

		if cmd == "ulx goto" then 
			err( ply )
		end 

		if cmd == "ulx teleport" then
			err( ply )
		end 
	end )

	hook.Add( "ULibPlayerTarget", "NoGoto", function( caller, cmd, target )
		if not IsValid( caller ) then return end 
		if caller:IsAdmin() then return end 
		if cmd ~= "ulx goto" then return end

		if not caller:InSafeZone() then
			ULib.tsayError( caller, "You're not in a safezone!" )
			return false 
		end 

		if not target:InSafeZone() then 
			ULib.tsayError( caller, target:Name() .. " is not in a safezone!" )
			return false 
		end 
	end )
end 