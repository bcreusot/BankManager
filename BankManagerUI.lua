

local TEXTURE_PUSH_BUTTON 		  	= "BankManager/img/push.dds"
local TEXTURE_PUSH_BUTTON_PRESSED 	= "BankManager/img/pushPressed.dds"

local TEXTURE_PULL_BUTTON 			= "BankManager/img/pull.dds"
local TEXTURE_PULL_BUTTON_PRESSED   = "BankManager/img/pullPressed.dds"

local FONT_TEXTURE 		  			= "BankManager/img/font.dds"

local PUSH   = {
	id      		= "_PUSH",
	tooltip 		= "CLick to Push",
	texture 		= TEXTURE_PUSH_BUTTON,
	texturePressed  = TEXTURE_PUSH_BUTTON_PRESSED,
	func    		= function ()
			            local status,err = pcall(moveItems,true,false)
			            if not status then
			                cleanAll(err)
			            end
			        end
}
local PULL   = {
	id      		= "_PULL",
	tooltip 		= "CLick to Pull",
	texture 		= TEXTURE_PULL_BUTTON,
	texturePressed  = TEXTURE_PULL_BUTTON_PRESSED,
	func    		= function ()
			            local status,err = pcall(moveItems,false,true)
			            if not status then
			                cleanAll(err)
			            end
			        end
}

local toolBarOptions ={
	PULL,
	PUSH
}

local startingOffsetXPosition = 10
local iconSize = 50

------------------------------------------------------------------------------------------------------
-- ** Function which create one button in the toolbar **
-- AddButton(parentWindow,id,func,texturePath,offsetY)
-- @parentWindow  : WINDOW_CONTROL, The main window the button has to be put on, here it's the toolbar
-- @id      	  : String,  		Id of the graphic element, has to be unique
-- @texturePath   : String,  		Texture path of the button
-- @offsetY       : Int,     		X offset of the button
------------------------------------------------------------------------------------------------------
local function AddButton(parentWindow,id,text,func,texturePath,texturePressed,offsetY)
    local button = WINDOW_MANAGER:CreateControl(id, parentWindow, CT_BUTTON)
    button:SetDimensions(iconSize,iconSize)
    button:SetAnchor(TOP, parentWindow, TOP, 0,offsetY)
    button:SetHandler("OnClicked", func)
    button:SetMouseEnabled(true)
    button:SetPressedTexture(texturePressed)
    button:SetNormalTexture(texturePath)

		--	TOOLTIP CONTROL
	local tooltipControl
	tooltipControl = WINDOW_MANAGER:CreateControl(id .. "_TOOLTIP",button,CT_TOOLTIP)
	tooltipControl:SetOwner(button,TOPLEFT,-80,5,TOPLEFT)
	tooltipControl:AddLine(text,"ZoFontBoss",255,255,255,CENTER,MODIFY_TEXT_TYPE_NONE,CENTER, true)
	tooltipControl:SetHidden(true)
    
    -- Show the action tooltip on mouseover:
	button:SetHandler("onMouseEnter", function() tooltipControl:SetHidden(false) end)
	button:SetHandler("onMouseExit", function() tooltipControl:SetHidden(true) end)
	
end

--------------------------------------------------------------------------
-- ** Function called at the initialization of the addon to prep the UI **
-- InitializeGUI()
--------------------------------------------------------------------------
function InitializeGUI()
	BankManagerUI:SetAnchor( CENTER, GuiRoot, CENTER, 185 , -10 )
	BankManagerUI:SetWidth ( 70 )
	BankManagerUI:SetHeight( 300 )
	BankManagerUI:SetHidden(true)

	BankManagerUIBG:SetAnchor(TOPLEFT, BankManagerUI, TOPLEFT, 0, 0)
	BankManagerUIBG:SetAnchorFill(BankManagerUI)
	BankManagerUIBG:SetCenterColor( 0,0,0,.4 )
	BankManagerUIBG:SetEdgeColor( 0,0,0,100 )
	BankManagerUIBG:SetEdgeTexture("",8,8,4)
	BankManagerUIBG:SetHidden(false)
	--BankManagerUIBG:SetAlpha(0.3)

	local texture = WINDOW_MANAGER:CreateControl(BankManagerUI:GetName() .. "_TEXTURE", BankManagerUIBG, CT_TEXTURE)
	--texture:SetDimensions(512,1024)
    texture:SetAnchorFill()
    texture:SetTexture(FONT_TEXTURE)

    for k,toolBarItem in pairs(toolBarOptions) do
    	local offset = k*startingOffsetXPosition + (k-1)*iconSize
    	AddButton(BankManagerUIBG,BankManagerUIBG:GetName() .. toolBarItem.id,toolBarItem.tooltip, toolBarItem.func,toolBarItem.texture,toolBarItem.texturePressed,offset)
    end
end

-------------------------------------------
-- ** Function which show the UI/toolbar **
-- showUI()
-------------------------------------------
function showUI()
	BankManagerUI:SetHidden(false)
end

-------------------------------------------
-- ** Function which hide the UI/toolbar **
-- hideUI()
-------------------------------------------
function hideUI()
	BankManagerUI:SetHidden(true)
end

