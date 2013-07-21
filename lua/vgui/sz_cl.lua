-- vgui shit fucks

local FILE -- File from file browser
local function parentsToDir( panel, text )
    local parent = panel:GetParent()
    local text = text or ""

    if IsValid( parent ) then
        local t = parent:GetText() 
        if t ~= "" then 
            text = parent:GetText() .. "/" .. text
        end

        text = parentsToDir( parent, text )
    end

    return string.TrimRight( text, "/" )
end

local function newLabel( text, parent ) 
	local ret = vgui.Create( "DLabel", parent ) 
		ret:SetText( text ) 
		ret:SizeToContents()
		ret:SetTextColor( Color(0,0,0) ) 
	return ret 
end 

local function updateInfo( panel, adminonly, zonetype, noclip, dmg ) 
	panel._adminonly:SetText( adminonly or "N/A" ) 
	panel._adminonly:SizeToContents()
	
	panel._zonetype:SetText( zonetype or "N/A" ) 
	panel._zonetype:SizeToContents()

	panel._noclip:SetText( noclip or "N/A" ) 
	panel._noclip:SizeToContents()

	panel._damage:SetText( dmg or "N/A" ) 
	panel._damage:SizeToContents()
end 

local function openFileBrowser() 
	local Frame = vgui.Create( "DFrame" ) 
		Frame:SetSize( 310, 340 ) 
		Frame:Center()
		Frame:MakePopup()
		Frame:SetTitle( "File Browser" ) 
		
	local Tree = vgui.Create( "DTree", Frame ) 
		Tree:SetSize( 300, 275 )
		Tree:SetPos( 5, 25 )
		Tree:SetPadding( 5 ) 
		
	local Select = vgui.Create( "DButton", Frame ) 
		Select:SetSize( 100, 20 )
		Select:SetPos( 100, 310 ) 
		Select:SetText( "Select File" ) 
		
		Select.DoClick = function() 
			local item = Tree:GetSelectedItem()
			local val  = item:GetText()
			FILE = parentsToDir( item ) .. "/" .. val 
		end 
		
	local _, d = file.Find( "*", "GAME" ) 
	for _,v in pairs( d ) do 
		local node = Tree:AddNode( v ) 
		node:MakeFolder( v, "GAME", true ) 
	end 
end 

-- openFileBrowser()

local function openMenu()
	local Frame = vgui.Create( "DFrame" ) 
		Frame:SetSize( 300, 300 )
		Frame:Center() 
		Frame:MakePopup()
		Frame:SetTitle( "SafeZone Menu" ) 
		
	local PropSheet = vgui.Create( "DPropertySheet", Frame ) 
		PropSheet:SetSize( 280, 270 ) 
		PropSheet:SetPos( 10, 25 ) 
	
	-- Clientside tab
	local ClientForm = vgui.Create( "DPanel", PropSheet ) 
		ClientForm:SetSize( 280, 270 ) 
		ClientForm:SetPos( 0, 0 )
		
	local HelpText = newLabel( "Right-click a zone to view options.", ClientForm ) 
		HelpText:SetPos( 50, 10 )  
		
	local ZoneList = vgui.Create( "DListView", ClientForm ) 
		ZoneList:SetSize( 140, 100 ) 
		ZoneList:SetPos( 10, 30 )
		ZoneList:SetMultiSelect( false )
		ZoneList:AddColumn( "Zones" ) 
		
		for i=1,10 do ZoneList:AddLine(i) end 
	
		ZoneList.OnRowRightClick = function() 
			local m = DermaMenu() 
				m:AddOption( "Edit", function() end )  
				m:AddOption( "Goto", function() end ) 
			m:Open()
		end 
	
	local Info = newLabel( "Information:", ClientForm ) 
		Info:SetPos( 175, 30 ) 
		
	-- save these panels so we can edit them
	AdminOnlyText = newLabel( "Admin Only:", ClientForm ) 
		AdminOnlyText:SetPos( 155, 50 ) 
		
	ZoneTypeText = newLabel( "Zone Type:", ClientForm ) 
		ZoneTypeText:SetPos( 155, 70 )
	
	NoclipText = newLabel( "No clip:", ClientForm ) 
		NoclipText:SetPos( 155, 90 ) 
		
	DamageText = newLabel( "Damage:", ClientForm ) 
		DamageText:SetPos( 155, 110 ) 
	
	local Mixer = vgui.Create( "DColorMixer", ClientForm ) 
		Mixer:SetSize( 180, 80 ) 
		Mixer:SetPos( 5, 140 ) 
		Mixer:SetPalette( false ) 
		Mixer:SetWangs( false )
		
	local SetColorBtn = vgui.Create( "DButton", ClientForm ) 
		SetColorBtn:SetText( "Set Color" ) 
		SetColorBtn:SetSize( 50, 20 ) 
		SetColorBtn:SetPos( 200, 140 ) 
		
	local RandomColorBtn = vgui.Create( "DButton", ClientForm ) 
		RandomColorBtn:SetText( "Random" ) 
		RandomColorBtn:SetSize( 50, 20 )
		RandomColorBtn:SetPos( 200, 170 )
		
	local DefaultColorBtn = vgui.Create( "DButton", ClientForm ) 
		DefaultColorBtn:SetText( "Default" ) 
		DefaultColorBtn:SetSize( 50, 20 )
		DefaultColorBtn:SetPos( 200, 200 )
			
	-- Set default values: 
	ClientForm._adminonly = newLabel( "N/A", ClientForm ) 
		ClientForm._adminonly:SetPos( 220, 50 ) 
	
	ClientForm._zonetype = newLabel( "N/A", ClientForm ) 
		ClientForm._zonetype:SetPos( 220, 70 ) 
		
	ClientForm._noclip = newLabel( "N/A", ClientForm ) 
		ClientForm._noclip:SetPos( 220, 90 ) 
		
	ClientForm._damage = newLabel( "N/A", ClientForm ) 
		ClientForm._damage:SetPos( 220, 110 ) 
		
	PropSheet:AddSheet( "Client", ClientForm, "gui/silkicons/user", false, false, "Clientside settings for Zones." )

	-- Superadmin only. todo: add serverside checks as well.
	if not LocalPlayer():IsSuperAdmin() then return end 
	-- serverside tab
	local ServerForm = vgui.Create( "DPanel", PropSheet ) 
		ServerForm:SetSize( 280, 270 ) 
		ServerForm:SetPos( 0, 0 ) 
		
		
	PropSheet:AddSheet( "Server", ServerForm, "gui/silkicons/group", false, false, "Serverside Settings for Zones." )
end

concommand.Add( "zones_menu", openMenu )

	