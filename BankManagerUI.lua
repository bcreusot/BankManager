

local TEXTURE_PUSH_BUTTON = "BankManager/img/push.dds"
local TEXTURE_PULL_BUTTON = "BankManager/img/pull.dds"
local FONT_TEXTURE 		  = "BankManager/img/font.dds"



local PUSH   = {
	texture = TEXTURE_PUSH_BUTTON,
	func    = pushButton,
	id      = "_PUSH"
}
local PULL   = {
	texture = TEXTURE_PULL_BUTTON,
	func    = pullButton,
	id      = "_PULL"
}

local toolBarOptions ={
	PULL,
	PUSH
}

local startingOffsetXPosition = 10
local iconSize = 50

local function AddButton(parentWindow,id,func,texturePath,offsetY)
    local button = WINDOW_MANAGER:CreateControl(id, parentWindow, CT_BUTTON)
    button:SetDimensions(iconSize,iconSize)
    button:SetAnchor(TOP, parentWindow, TOP, 0,offsetY)
    button:SetHandler("OnClicked", func)
    button:SetMouseEnabled(false)

    local texture = WINDOW_MANAGER:CreateControl(id .. "_TEXTURE", button, CT_TEXTURE)
    texture:SetAnchorFill()
    texture:SetTexture(texturePath)
    -- texture:SetColor(1, 1, 1, 1)
end


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
    	AddButton(BankManagerUIBG,BankManagerUIBG:GetName() .. toolBarItem.id, toolBarItem.func,toolBarItem.texture,offset)
    end
end

function showUI()
	BankManagerUI:SetHidden(false)
end
function hideUI()
	BankManagerUI:SetHidden(true)
end

function pushButton()
	d("push")
	moveItems(true,false)
end
function pullButton()
	d("pull")
	moveItems(false,true)
end