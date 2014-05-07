--[[
	-------------------
	***** Bank Manager *****
	* Benjamin Creusot - Todo
	* 17/04/2014 
	* v2.5.3
		Manage easily your bank. Automatically places items in your bank/inventory
	-------------------
]]--

function placeItems(fromBag, fromSlot, destBag, destSlot, quantity)
    --[[local fromName = GetItemName(fromBag, fromSlot)
    local destName = GetItemName(destBag, destSlot)
    if destName ~= nil then
        d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (" .. destName .. ") [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    else
        d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (nil) [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    end--]]
    ClearCursor()
    if CallSecureProtected("PickupInventoryItem", fromBag, fromSlot, quantity) then
        CallSecureProtected("PlaceInInventory", destBag, destSlot)
    end
    ClearCursor()
end


local function getItemState(craftingType,itemType)
    if (itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or 
           itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
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

function displayChat(itemName, quantity, moved)
    if(counterMessageChat <= limitMessageChat) then
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
    counterMessageChat = counterMessageChat +1
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
                if (item.state == INVENTORY_TO_BANK and bag ~= BANKS_TRANSLATION[BankManager.Saved.bankChoice]) then
                    table.insert(pushItems,item)
                elseif (item.state == BANK_TO_INVENTORY and bag ~= BAG_BACKPACK) then
                    table.insert(pullItems,item)
                end
            --if we gotta pull everything in bank and this is not the bank :)
            elseif BankManager.Saved.AllBM == INVENTORY_TO_BANK and bag ~= BANKS_TRANSLATION[BankManager.Saved.bankChoice] then
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

function moveItems(isPushSet,isPullSet)
    -- check if the program is already performing
    assert(not flagAlreadyPerforming, getTranslated("alreadyPerforming"))
    --now it's performing :)
    flagAlreadyPerforming = true

    local nbItemsMove,nbItemsStack                 = 0,0
    local pushItems,pullItems                      = {},{}
    local bankBag                                  = BANKS_TRANSLATION[BankManager.Saved.bankChoice]
    local backpackBag                              = BAG_BACKPACK
    local bankItemsTable, bankFreeSlots            = {},{}
    local inventoryItemsTable, inventoryFreeSlots  = {},{}
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

    --If it's the GUILDBANK, we got a special treatment cause of the shitty system of waiting event:)
    if BankManager.Saved.bankChoice == "BAG_GUILDBANK" and false then
        initGuildBankManager(backpackBag,bankBag,bankItemsTable,inventoryItemsTable, inventoryFreeSlots,pushItems,pullItems)
        return
    end


    --Stacking time
    for idItem,itemBank in pairs(bankItemsTable) do
        --If the items is present in the dest
        if inventoryItemsTable[idItem] then
            --3 possibilites : NOTHING, Stack in Bank, Stack in Inventory
            if ((itemBank.state == INVENTORY_TO_BANK or BankManager.Saved.AllBM == INVENTORY_TO_BANK) and isPushSet) then
                --Stacking items (by reference) - idItem-fromTable-destTable-fromFreeSpace
                stackItems(idItem,inventoryItemsTable,bankItemsTable,inventoryFreeSlots)
            elseif ((itemBank.state == BANK_TO_INVENTORY or BankManager.Saved.AllBM == BANK_TO_INVENTORY) and isPullSet) then
                stackItems(idItem,bankItemsTable,inventoryItemsTable,bankFreeSlots)
            --We consider here that the item  has no specific place to go
            elseif ((BankManager.Saved["fillStacks"] == INVENTORY_TO_BANK) and isPushSet) then
                stackItems(idItem,inventoryItemsTable,bankItemsTable,inventoryFreeSlots)
            elseif ((BankManager.Saved["fillStacks"] == BANK_TO_INVENTORY) and isPullSet) then
                stackItems(idItem,bankItemsTable,inventoryItemsTable,bankFreeSlots)
            end
            nbItemsStack = nbItemsStack + 1
        end
    end


    -- if there is place in both bags AND there is something to move

    while ((next(bankFreeSlots) ~= nil and next(pushItems) ~= nil and isPushSet) or (next(inventoryFreeSlots) ~= nil and next(pullItems) ~= nil and isPullSet) and securityCounter < 300) do
        securityCounter = securityCounter +1
        --We begin by pushing items from inventory
        if isPushSet then
            for k,item in pairs(pushItems) do
                --if the items was already stack (secure for maxStack items that are not registered at all)
                if not inventoryItemsTable[item.id] and item.stack < item.maxStack then
                    table.remove(pushItems,k)
                -- if there is a place in the bank at least
                elseif next(bankFreeSlots) ~= nil then
                    placeItems(item.bag, item.slot, BANKS_TRANSLATION[BankManager.Saved.bankChoice], table.remove(bankFreeSlots), item.stack)
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
        end
        --pull time
        if isPullSet then
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

    end
    if(securityCounter > 299) then
        d("Something went wrong : plz send me a message on the forum of esoui, pseudo : Todo")
    end

    if BankManager.Saved["spamChat"] and counterMessageChat > limitMessageChat then
        d((counterMessageChat - limitMessageChat) .. " " .. getTranslated("noDisplayed"))
    end

    d("----------------------")
    d(nbItemsMove .. " " .. getTranslated("itemsMoved"))
    d(nbItemsStack .. " " .. getTranslated("itemsStacked"))
    d("----------------------")

    --Data reset for new action
    counterMessageChat    = 0
    flagAlreadyPerforming = false
end

function bankOpening(eventCode, addOnName, isManual)
    if isManual then
        return
    end

    --Display the toolbar
    if BankManager.Saved.toolBarDisplayed then
        showUI()
    end

    -- if the automatique push/pull is disable
    if not BankManager.Saved.autoTransfert then
        return
    end

    if BankManager.Saved.bankChoice == "BAG_BANK" and eventCode == EVENT_OPEN_BANK then
        ClearCursor()
        moveItems(true,true)
    elseif BankManager.Saved.bankChoice == "BAG_GUILDBANK" and eventCode == EVENT_GUILD_BANK_ITEMS_READY  and BankManager.Saved["guildChoice"] then
        ClearCursor()
        --We set the guild bank to work with
        SelectGuildBank(BankManager.Saved["guildChoice"])
        --we check the permission
        if DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_DEPOSIT) and DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_WITHDRAW) then 
            moveItems(true,true)
        else
            d(getTranslated("noPermission"))
        end
    end

end

function bankClose()
    hideUI()
end


function init(eventCode, addOnName)
    if addOnName ~= BankManagerAppName then
        return
    end

    local initVarFalse              = NOTHING
    local defaults = {
        ["language"]                = "English",
        ["toolBarDisplayed"]        = true,
        ["bankChoice"]              = "BAG_BANK",
        ["guildChoice"]             = GetGuildId(1),
        ["autoTransfert"]           = true,
        ["spamChat"]                = false,
        ["AllBM"]                   = NOTHING,
        ["fillStacks"]              = NOTHING
    }
    
    for k,v in ipairs(craftingElements) do
        defaults[v] = initVarFalse
    end
    for k,v in ipairs(othersElements) do
        defaults[v] = initVarFalse
    end
    BankManager.Saved = ZO_SavedVars:New(BankManagerVars, 1, nil, defaults, nil)
    
    --New vars until changing version saved number
    if not BankManager.Saved.fillStacks then
        BankManager.Saved.fillStacks = NOTHING
    end
    if not BankManager.Saved.ITEMTYPE_LURE then
        BankManager.Saved.ITEMTYPE_LURE = NOTHING
    end
    if not BankManager.Saved.bankChoice then
        BankManager.Saved.bankChoice = "BAG_BANK"
    end
    if not BankManager.Saved.guildChoice then
        BankManager.Saved.guildChoice = GetGuildId(1)
    end
    if BankManager.Saved.autoTransfert == nil then
        BankManager.Saved.autoTransfert = true
    end
    if BankManager.Saved.toolBarDisplayed == nil then
        BankManager.Saved.toolBarDisplayed = true
    end



    options()
    InitializeGUI()


    EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_OPEN_BANK              , bankOpening)
    EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_CLOSE_BANK             , bankClose)
    --EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_GUILD_BANK_ITEMS_READY, bankOpening)

end


EVENT_MANAGER:RegisterForEvent(BankManagerAppName, EVENT_ADD_ON_LOADED, init)