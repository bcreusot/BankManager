--[[
	-------------------
	***** Bank Manager *****
	* Benjamin Creusot - Todo
	* 17/04/2014 
	* v2.5
		Manage easily your bank. Automatically places items in your bank/inventory
	-------------------
]]--


 -- Global Vars
BankManagerVars = "BMVars"
currentVersion  = "2.5"

othersElements = {
    "ITEMTYPE_WEAPON",
    "ITEMTYPE_WEAPON_BOOSTER",
    "ITEMTYPE_ARMOR",
    "ITEMTYPE_ARMOR_BOOSTER",
    "ITEMTYPE_COSTUME",
    "ITEMTYPE_DISGUISE",
    "ITEMTYPE_DRINK",
    "ITEMTYPE_FOOD",
    "ITEMTYPE_AVA_REPAIR",
    "ITEMTYPE_LOCKPICK",
    "ITEMTYPE_POTION",
    "ITEMTYPE_POISON",
    "ITEMTYPE_RECIPE",
    "ITEMTYPE_SCROLL",
    "ITEMTYPE_SIEGE",
    "ITEMTYPE_SOUL_GEM",
    "ITEMTYPE_TABARD",
    "ITEMTYPE_TROPHY"
}
craftingElements = {
    "CRAFTING_TYPE_RAW",
    "CRAFTING_TYPE_BLACKSMITHING",
    "CRAFTING_TYPE_CLOTHIER",     
    "CRAFTING_TYPE_ENCHANTING",   
    "CRAFTING_TYPE_ALCHEMY",      
    "CRAFTING_TYPE_PROVISIONING", 
    "CRAFTING_TYPE_WOODWORKING",  
    "ITEMTYPE_STYLE_MATERIAL",
    "ITEMTYPE_WEAPON_TRAIT",
    "ITEMTYPE_ARMOR_TRAIT"
}
NOTHING             = "NOTHING"
BANK_TO_INVENTORY   = "BANK_TO_INVENTORY"
INVENTORY_TO_BANK   = "INVENTORY_TO_BANK"
MATCH_CRAFT         = "MATCH_CRAFT"

sendingType = {
    NOTHING,
    BANK_TO_INVENTORY,
    INVENTORY_TO_BANK
}
rawSendingType = {
    NOTHING,
    MATCH_CRAFT,
    BANK_TO_INVENTORY,
    INVENTORY_TO_BANK
}


languages = {
    "English",
    "Francais",
    "Deutsch"
}




-- Main Vars
BankManager = {}


local function placeItems(fromBag, fromSlot, destBag, destSlot, quantity)
    --[[local fromName = GetItemName(fromBag, fromSlot)
    local destName = GetItemName(destBag, destSlot)
    if destName ~= nil then
        d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (" .. destName .. ") [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    else
        d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (nil) [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    end]]--
    ClearCursor()
    if CallSecureProtected("PickupInventoryItem", fromBag, fromSlot, quantity) then
        CallSecureProtected("PlaceInInventory", destBag, destSlot)
    end
    ClearCursor()
end

local function getTranslated(text)
    return language[BankManager.Saved["language"]][text]
end

local function getItemState(craftingType,itemType)
    if (itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or 
           itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
           itemType == ITEMTYPE_ALCHEMY_BASE or
           itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then
        itemType = ITEMTYPE_RAW_MATERIAL
    end

    --If the craft of itemtype is known and we got a entry for it (we treat it)
    if craftingType ~= CRAFTING_TYPE_INVALID and CRAFTING_TYPE_TRANSLATION[craftingType] then
        if itemType == ITEMTYPE_RAW_MATERIAL and BankManager.Saved[ITEMTYPE_TRANSLATION[itemType]] ~= MATCH_CRAFT then
            return BankManager.Saved[ITEMTYPE_TRANSLATION[itemType]]
        else
            return BankManager.Saved[CRAFTING_TYPE_TRANSLATION[craftingType]]
        end
    end
    if itemType ~= ITEMTYPE_NONE and ITEMTYPE_TRANSLATION[itemType] then
        return BankManager.Saved[ITEMTYPE_TRANSLATION[itemType]]
    end
    return NOTHING
end

local function displayChat(itemName, quantity, moved)
    local startString,endString = string.find(itemName,"%^")
    if startString ~= nil then
        itemName = string.sub(itemName,0,startString-1)
    end
    if BankManager.Saved["spamChat"] then
        if moved then
            d(quantity .. " " .. itemName .. " " .. getTranslated("itemsMoved"))
        else
            d(quantity .. " " .. itemName .. " " .. getTranslated("itemsStacked"))
        end
    end
end

--Return the tables of stackable items in the bag and a table of all free spots
local function getBagDescription(bag,pushItems,pullItems)
    --get the number of slot in the destination
    local bagIcon, bagSlots = GetBagInfo(bag)
    --return tables of items in the bag
    local itemsTables = {}
    --return tables of free slots
    local slotAvalaibleDest = {}
    --iteration to get all the slots
    for slotDest = 0, bagSlots-1 do
        local itemStack, itemMaxStack, itemName, idItem, isJunk, itemType,craftInfo
        local item = {}
        itemStack, itemMaxStack = GetSlotStackSize(bag, slotDest)
        itemName  = GetItemName(bag, slotDest)
        idItem    = GetItemInstanceId(bag, slotDest)
        isJunk    = IsItemJunk(bag, slotDest)
        craftInfo = GetItemCraftingInfo(bag, slotDest)
        itemType  = GetItemType(bag, slotDest)
        --if the item exist, we create it
        if idItem ~= nil then
            item.id           = idItem
            item.name         = itemName
            item.stack        = itemStack
            item.maxStack     = itemMaxStack
            item.slot         = slotDest
            item.bag          = bag
            item.itemType     = itemType
            item.craftType    = craftInfo
            item.state        = getItemState(craftInfo,itemType)
        end
        --if the item is not from the junk, and if the items got room for more
        if (not isJunk) and idItem ~= nil  then
            if itemStack < itemMaxStack then
                itemsTables[idItem] = item
            end
            --if the all option is disabled
            if BankManager.Saved.AllBM == NOTHING then
                if (item.state == INVENTORY_TO_BANK and bag ~= BAG_BANK) then
                    table.insert(pushItems,item)
                elseif (item.state == BANK_TO_INVENTORY and bag ~= BAG_BACKPACK) then
                    table.insert(pullItems,item)
                end
            --if we gotta pull everything in bank and this is not the bank :)
            elseif BankManager.Saved.AllBM == INVENTORY_TO_BANK and bag ~= BAG_BANK then
                table.insert(pushItems,item)
            elseif BankManager.Saved.AllBM == BANK_TO_INVENTORY and bag ~= BAG_BACKPACK then
                table.insert(pullItems,item)
            end
        elseif idItem == nil then
            table.insert(slotAvalaibleDest,slotDest)
        end
    end
    return itemsTables,slotAvalaibleDest
end

local function stackItems(idItem, fromTable,destTable,fromFreeSpaceTable)
    local fromItem = fromTable[idItem]
    local destItem = destTable[idItem]
    --If we gotta do something
    --2 case : enough place, not enough place :)
    local maxDestQuantity = destItem.maxStack - destItem.stack
    --enough place
    if(maxDestQuantity >= fromItem.stack) then
        placeItems(fromItem.bag, fromItem.slot, destItem.bag, destItem.slot, fromItem.stack)
        destItem.stack = destItem.stack + fromItem.stack
        --from item is no more so we have a new free place and we can remove that element
        table.insert(fromFreeSpaceTable,fromItem.slot)
        fromTable[idItem] = nil
        if destItem.stack == destItem.maxStack then
            destTable[idItem] = nil
        end
        displayChat(fromItem.name, fromItem.stack, false)
    --no enough place
    else
        fromItem.stack = fromItem.stack - maxDestQuantity
        placeItems(fromItem.bag, fromItem.slot, destItem.bag, destItem.slot, maxDestQuantity)
        destTable[idItem] = nil
        displayChat(fromItem.name, maxDestQuantity, false)
    end
end

local function moveItems()
    local nbItemsMove,nbItemsStack                 = 0,0
    local pushItems,pullItems                      = {},{}
    local bankBag                                  = BAG_BANK
    local backpackBag                              = BAG_BACKPACK
    local bankItemsTable, bankFreeSlots            = {},{}
    local inventoryItemsTable, inventoryFreeSlots  = {},{}
    local craftType                                = {}
    local securityCounter                          = 0
    --BANK ANALYZE
    bankItemsTable,bankFreeSlots = getBagDescription(bankBag,pushItems,pullItems)

    --INVENTORY ANALYZE
    inventoryItemsTable, inventoryFreeSlots = getBagDescription(backpackBag,pushItems,pullItems)
    --[[

    * MAIN ALGORITHM
    * We will process throught each bag, one at a time and try to push or pull each items from each bag
    * If a bag become full we skip it until it pushes an item
    
    ]]--

    --Stacking time
    for idItem,itemBank in pairs(bankItemsTable) do
        --If the items is present in the dest
        if inventoryItemsTable[idItem] then
            --3 possibilites : NOTHING, Stack in Bank, Stack in Inventory
            if (itemBank.state == INVENTORY_TO_BANK or BankManager.Saved.AllBM == INVENTORY_TO_BANK) then
                --Stacking items (by reference) - idItem-fromTable-destTable-fromFreeSpace
                stackItems(idItem,inventoryItemsTable,bankItemsTable,inventoryFreeSlots)
                nbItemsStack = nbItemsStack + 1
            elseif (itemBank.state == BANK_TO_INVENTORY or BankManager.Saved.AllBM == BANK_TO_INVENTORY) then
                stackItems(idItem,bankItemsTable,inventoryItemsTable,bankFreeSlots)
                nbItemsStack = nbItemsStack + 1
            end
        end
    end

    -- if there is place in both bags AND there is something to move

    while ((next(bankFreeSlots) ~= nil and next(pushItems) ~= nil) or (next(inventoryFreeSlots) ~= nil and next(pullItems) ~= nil) and securityCounter < 300) do
        securityCounter = securityCounter +1
        --We begin by pushing items from inventory
        for k,item in pairs(pushItems) do
            --if the items was already stack (secure for maxStack items that are not registered at all)
            if not inventoryItemsTable[item.id] and item.stack < item.maxStack then
                table.remove(pushItems,k)
            -- if there is a place in the bank at least
            elseif next(bankFreeSlots) ~= nil then
                placeItems(item.bag, item.slot, BAG_BANK, table.remove(bankFreeSlots), item.stack)
                --new place in bank
                table.insert(inventoryFreeSlots,item.slot)
                displayChat(item.name, item.stack, true)
                nbItemsMove  = nbItemsMove + 1
                table.remove(pushItems,k)
            --if not there is no point to continue
            else
                break
            end
        end
        --pull time
        for k,item in pairs(pullItems) do
            if not bankItemsTable[item.id] and item.stack < item.maxStack then
                table.remove(pullItems,k)
            elseif next(inventoryFreeSlots) ~= nil then
                placeItems(item.bag, item.slot, BAG_BACKPACK, table.remove(inventoryFreeSlots), item.stack)
                --new place in bank
                table.insert(bankFreeSlots,item.slot)
                displayChat(item.name, item.stack, true)
                nbItemsMove  = nbItemsMove + 1
                table.remove(pullItems,k)
            else
                break
            end
        end

    end
    if(securityCounter > 299) then
        d("Something went wrong : plz send me a message on the forum of esoui, pseudo : Todo")
    end
    d("----------------------")
    d(nbItemsMove .. " " .. getTranslated("itemsMoved"))
    d(nbItemsStack .. " " .. getTranslated("itemsStacked"))
    d("----------------------")
end

function bankOpening(eventCode, addOnName, isManual)
    if isManual then
        return
    end

    ClearCursor()
    moveItems()

end

local function changelanguage(val,controleKey)
    BankManager.Saved["language"] = val
    ReloadUI()
end

--Browse the language to find the key back
local function changeItemsSendingType(val,key)
    key = string.gsub(key, "#", "")
    for keyTrad,tradValue in pairs(language[BankManager.Saved["language"]]) do
        if tradValue == val then
            BankManager.Saved[key] = keyTrad
            return
        end
    end

end


local function getSendingTypeList(arraySendingType)
    local result = {}
    for i,v in ipairs(arraySendingType) do
        table.insert(result,getTranslated(v))
    end
    return result
end


local function options()
    local textCheckBox = ""
    local craftName, textCheckBox, othersKey
    local LAM = LibStub("BankManager_LibAddonMenu-1.0")
    local optionsPanel = LAM:CreateControlPanel("Bank Manager", "Bank Manager")
    LAM:AddHeader(optionsPanel, "versionBM", "|c3366FF" .. getTranslated("version").."|r:" .. currentVersion)
    LAM:AddHeader(optionsPanel, "headerBM", "|c3366FF" .. getTranslated("title").."|r" )

    LAM:AddDropdown(optionsPanel, "languageBM", getTranslated("dropDownLanguageText"), getTranslated("dropDownLanguageTooltip"), languages,
            function() return BankManager.Saved["language"] end,
            changelanguage,
            true , getTranslated("reloadWarning"))

    LAM:AddCheckbox(optionsPanel, "spamChatBM", getTranslated("spamChatText"), getTranslated("spamChatTooltip"),
                function() return BankManager.Saved["spamChat"] end,
                function(val) BankManager.Saved["spamChat"] = val end)


    LAM:AddDropdown(optionsPanel, "AllBM", getTranslated("AllBM"), "", getSendingTypeList(sendingType),
            function() return getTranslated(BankManager.Saved["AllBM"]) end,
            changeItemsSendingType)


    --CRAFT MODE
    LAM:AddHeader(optionsPanel, "craftHeaderBM",  "|c3366FF" .. getTranslated("craftHeader").."|r")
	for key,craftKey in pairs(craftingElements) do
        local craftName = getTranslated(craftKey)
        sendingTypeTab = sendingType
        --special treatment if this is Raw Material
        if othersKey == CRAFTING_TYPE_RAW then
            sendingTypeTab = rawSendingType
        end
        --The checkbox -- #is for the conflict 
        LAM:AddDropdown(optionsPanel, craftKey.."#", craftName, "", getSendingTypeList(sendingTypeTab),
            function() return getTranslated(BankManager.Saved[craftKey]) end,
            changeItemsSendingType)    
    end

    --OTHERS MODE
    LAM:AddHeader(optionsPanel, "othersHeaderBM", "|c3366FF" .. getTranslated("othersHeader").."|r")
    for key,othersKey in pairs(othersElements) do
        local othersName = getTranslated(othersKey)


        --The checkbox -- #is for the conflict 
        LAM:AddDropdown(optionsPanel, othersKey.."#", othersName, "", getSendingTypeList(sendingType),
            function() return getTranslated(BankManager.Saved[othersKey]) end,
            changeItemsSendingType)    
    end
end

function init(eventCode, addOnName)
    if addOnName ~= "BankManager" then
        return
    end
    local initVarFalse              = NOTHING
    local defaults = {
        ["language"]                = "English",
        ["spamChat"]                = false,
        ["AllBM"]                   = NOTHING
    }
    
    for k,v in ipairs(craftingElements) do
        defaults[v] = initVarFalse
    end
    for k,v in ipairs(othersElements) do
        defaults[v] = initVarFalse
    end
    BankManager.Saved = ZO_SavedVars:New(BankManagerVars, 1, nil, defaults, nil)

    options()
    
    EVENT_MANAGER:RegisterForEvent("BankManager", EVENT_OPEN_BANK, bankOpening)
end


EVENT_MANAGER:RegisterForEvent("BankManager", EVENT_ADD_ON_LOADED, init)