

function InitializeGUI()
	local window = WINDOW_MANAGER:CreateTopLevelWindow( "BankManagerToolbar" ) 
	BankManagerToolbar:SetDimensions(200, 380)
	BankManagerToolbar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 250, 200)
	BankManagerToolbar:SetHidden( false )
	
	local BG = WINDOW_MANAGER:CreateControl( "BankManagerToolbarItems",  DuraItemList, CT_BACKDROP)
	BankManagerToolbarItems:SetAnchor(TOPLEFT, DuraItemList, TOPLEFT, 0, 0)
	BankManagerToolbarItems:SetAnchorFill(DuraItemList)
	BankManagerToolbarItems:SetCenterColor( 0,0,0,.4 )
	BankManagerToolbarItems:SetEdgeColor( 0,0,0,100 )
	BankManagerToolbarItems:SetEdgeTexture("",8,1,2)

end