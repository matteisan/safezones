--[[-------------------------------------
------------- ACF Handling --------------
--- Essentially copying the old funcs ---
--- to check if they're in safezones. ---
---------------------------------------]]

-- Check if in safezone
local vecmeta = FindMetaTable( "Vector" )
function vecmeta:InSafeZone() 
	for k,v in pairs( zData ) do
		local min = v.corners[2]
		local max = v.corners[5]

		if inrange( pos, min, max ) then
			return true 
		end
	end

	return false 
end 

if ACF then 
	local old_ACF_HE = ACF_HE 
	function ACF_HE( Hitpos, HitNormal, FillerMass, FragMass, Inflictor, NoOcc )
		if Hitpos:InSafeZone() then return end 

		old_ACF_HE( Hitpos, HitNormal, FillerMass, FragMass, Inflictor, NoOcc )
	end 

	local old_ACF_Spall = ACF_Spall 
	function ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor )
		if Hitpos:InSafeZone() then return end  

		old_ACF_Spall( HitPos , HitVec , HitMask , KE , Caliber , Armour , Inflictor )
	end 

	local old_ACF_SpallTrace = ACF_SpallTrace 
	function ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
		if HitVec:InSafeZone() then return end 

		old_ACF_SpallTrace( HitVec , SpallTr , SpallEnergy , SpallAera , Inflictor )
	end 

	local old_ACF_RoundImpact = ACF_RoundImpact 
	function ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
		if Hitpos:InSafeZone() then return end 

		old_ACF_RoundImpact( Bullet, Speed, Energy, Target, HitPos, HitNormal , Bone )
	end 

	local old_ACF_PenetrateGround = ACF_PenetrateGround 
	function ACF_PenetrateGround( Bullet, Energy, HitPos )
		if HitPos:InSafeZone() then return end 

		old_ACF_PenetrateGround( Bullet, Energy, HitPos )
	end 

	local old_ACF_KEShove = ACF_KEShove 
	function ACF_KEShove(Target, Pos, Vec, KE ) 
		if Pos:InSafeZone() then return end 

		old_ACF_KEShove(Target, Pos, Vec, KE )
	end 

	local old_ACF_HEKill = ACF_HEKill 
	function ACF_HEKill( Entity, HitVector, Energy )
		if HitVector:InSafeZone() then return end 

		old_ACF_HEKill( Entity, HitVector, Energy )
	end 

	local old_ACF_APKill = ACF_APKill 
	function ACF_APKill( Entity , HitVector , Power )
		if HitVector:InSafeZone() then return end 

		old_ACF_APKill( Entity , HitVector , Power )
	end 

	local old_ACF_AmmoExplosion = ACF_AmmoExplosion 
	function ACF_AmmoExplosion( Origin , Pos )
		if Pos:InSafeZone() then return end 

		old_ACF_AmmoExplosion( Origin , Pos )
	end 
end 