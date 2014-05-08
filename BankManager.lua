

--------------------------------------------------------------------------------
--	***** Bank Manager *****
--	* Benjamin Creusot - Todo
--	* 17/04/2014 
--	* v2.6.1
--		Manage easily your bank. Automatically places items in your bank/inventory
--
--  * LICENSE MIT
--------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
-- ** Function that place one item in another bag/slot **
-- placeItems(fromBag, fromSlot, destBag, destSlot, quantity)
-- @fromBag   : Int, Bag where the item has to come from
-- @fromSlot  : Int, Slot where the item has to come from
-- @destBag   : Int, Bag where the item will go
-- @destSlot  : Int, Slot where the item will go
-- @quantity  : int, Quantity moved
---------------------------------------------------------------------------------------
function placeItems(fromBag, fromSlot, destBag, destSlot, quantity)
    --local fromName = GetItemName(fromBag, fromSlot)
    --local destName = GetItemName(destBag, destSlot)
    --if destName ~= nil then
    --    d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (" .. destName .. ") [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    --else
    --    d("(" .. fromName .. ")[" .. fromBag .. "," .. fromSlot .."] => (nil) [" .. destBag .. "," .. destSlot .."] (" .. quantity .. ")")
    --end
    ClearCursor()
    if CallSecureProtected("PickupInventoryItem", fromBag, fromSlot, quantity) then
        CallSecureProtected("PlaceInInventory", destBag, destSlot)
    end
    ClearCursor()
end

---------------------------------------------------------------------------------------
-- ** Function return the state of an item regarding of the option sets **
-- getItemState(craftingType,itemType)
-- @craftingType  : Int,  Type of craft, describe in the API of ESO
-- @itemType      : Int,  Type of item,  describe in the API of ESO
-- @return        : The state of the item, NOTHING, INVENTORY_TO_BANK,BANK_TO_INVENTORY
---------------------------------------------------------------------------------------
local function getItemState(craftingType,itemType)
    if BankManager.Saved.AllBM == INVENTORY_TO_BANK or BankManager.Saved.AllBM == BANK_TO_INVENTORY then
        return BankManager.Saved.AllBM
    end

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

----------------------------------------------------------------------------------
-- ** Function that display information in the chat about moving/stacking items **
-- displayChat(itemName, quantity, moved)
-- @itemName    : String,  Name of the item
-- @quantity    : Int,     Quantity of the item
-- @moved       : Boolean, If the item had been moved or stacked
----------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------
-- ** Function that parse one bag then register information about free space, stackable items and push/pull items **
-- getBagDescription(bag,pushItems,pullItems)
-- @bag          : Int,   The ID of the bag (BackPack,Bank,GuildBank)
-- @pushItems    : Table, The table contains all items that have to be pushed
-- @pullItems    : Table, The table contains all items that have to be pulled
-- @return       :        The items stack table and the free slot avalaible of the corresponding bag
--------------------------------------------------------------------------------------------------------------------
local function getBagDescription(bag,pushItems,pullItems)
    --get the number of slot in the destination
    local bagIcon, bagSlots = GetBagInfo(bag)
    --return tables of stackable items in the bag and free slots
    local itemsStackTable, slotAvalaibleDest = {},{}
    --iteration to get all the slots
    for slotDest = 0, bagSlots-1 do
        local item   = {}
        local idItem = GetItemInstanceId(bag, slotDest)
        --if the item exist, we create it
        if idItem ~= nil then
            item.id                    = idItem
            item.bag                   = bag
            item.slot                  = slotDest
            item.name                  = GetItemName(bag, slotDest)
            item.stack,item.maxStack   = GetSlotStackSize(bag, slotDest)
            item.itemType              = GetItemType(bag, slotDest)
            item.craftType             = GetItemCraftingInfo(bag, slotDest)
            item.state                 = getItemState(item.craftType,item.itemType)
        end
        --if the item is not from the junk, and if the items got room for more
        if (idItem ~= nil and not IsItemJunk(bag, slotDest)) then
            --if the all option is disabled
            if (item.state == INVENTORY_TO_BANK and bag ~= BANKS_TRANSLATION[BankManager.Saved.bankChoice]) then
                item.idPushPull = #pushItems+1
                table.insert(pushItems,item)
            elseif (item.state == BANK_TO_INVENTORY and bag ~= BAG_BACKPACK) then
                item.idPushPull = #pullItems+1
                table.insert(pullItems,item)
            end

            if  item.stack < item.maxStack then
                itemsStackTable[idItem] = item
            end
        elseif idItem == nil then
            table.insert(slotAvalaibleDest,slotDest)
        end
    end
    return itemsStackTable,slotAvalaibleDest
end

------------------------------------------------------------------------------------------------------------
-- ** Function that analyze the stack of the item and the stack of the destination then stack items  **
-- stackItems(idItem, fromTable,destTable,fromFreeSpaceTable)
-- @idItem              : String, the ID of the element, ID are ingame value made of an object (8-9 numbers)
-- @fromTable           : Table,  The stacking table which contains items by there ID
-- @destTable           : Table,  The destination stacking table which contains items by there ID
-- @fromFreeSpaceTable  : Table,  The table contains all free space from one bag
-- @return              :         If the item has been entirely moved to his destination stack
------------------------------------------------------------------------------------------------------------
local function stackItems(idItem, fromTable,destTable,fromFreeSpaceTable)
    local fromItem     = fromTable[idItem]
    local destItem     = destTable[idItem]
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
        return true
    --no enough place
    else
        fromItem.stack = fromItem.stack - maxDestQuantity
        placeItems(fromItem.bag, fromItem.slot, destItem.bag, destItem.slot, maxDestQuantity)
        destTable[idItem] = nil
        displayChat(fromItem.name, maxDestQuantity, false)
        return false
    end
end

---------------------------------------------------------
-- ** First Function in the moving part of the object **
-- moveItems(isPushSet,isPullSet)
-- @isPushSet : Boolean, define if we have to do the push
-- @isPullSet : Boolean, define if we have to do the pull
---------------------------------------------------------
function moveItems(isPushSet,isPullSet)
    -- check if the program is already performing
    assert(not flagAlreadyPerforming, getTranslated("alreadyPerforming"))
    --now it's performing :)
          flagAlreadyPerforming                         = true

    local nbItemsMove,nbItemsStack                      = 0,0
    local pushItems,pullItems                           = {},{}
    local bankBag                                       = BANKS_TRANSLATION[BankManager.Saved.bankChoice]
    local backpackBag                                   = BAG_BACKPACK
    local bankItemsStackTable, bankFreeSlots            = {},{}
    local inventoryItemsStackTable, inventoryFreeSlots  = {},{}
    local securityCounter                               = 0
    
    --BANK ANALYZE
    bankItemsStackTable,bankFreeSlots = getBagDescription(bankBag,pushItems,pullItems)

    --INVENTORY ANALYZE
    inventoryItemsStackTable, inventoryFreeSlots = getBagDescription(backpackBag,pushItems,pullItems)

    --If it's the GUILDBANK, we got a special treatment cause of the shitty system of waiting event:)
    --if BankManager.Saved.bankChoice == "BAG_GUILDBANK" then
    --    initGuildBankManager(backpackBag,bankBag,bankItemsStackTable,inventoryItemsStackTable, inventoryFreeSlots,pushItems,pullItems)
    --    return
    --end


    --Stacking time, we run the inventory because statistically there is more chance that the inventory contains less items that the bank
    for idItem,itemInventory in pairs(inventoryItemsStackTable) do
        --If the items is present in the dest
        if bankItemsStackTable[idItem] then
            local itemState   = itemInventory.state
            local globalState = BankManager.Saved.AllBM
            local idPush      = inventoryItemsStackTable[idItem].idPushPull
            local idPull      = bankItemsStackTable[idItem].idPushPull

            --PUSH STACKING
            if (isPushSet and (itemState == INVENTORY_TO_BANK or BankManager.Saved["fillStacks"] == INVENTORY_TO_BANK)) then
                -- The item has been completely stack ! We gotta remove it from the push table
                if stackItems(idItem,inventoryItemsStackTable,bankItemsStackTable,inventoryFreeSlots) then
                    pushItems[idPush] = nil
                end
                nbItemsStack = nbItemsStack + 1
            --Same rule but for TO_INVENTORY
            elseif (isPullSet and (itemState == BANK_TO_INVENTORY or BankManager.Saved["fillStacks"] == BANK_TO_INVENTORY)) then
                if stackItems(idItem,bankItemsStackTable,inventoryItemsStackTable,bankFreeSlots) then
                    pullItems[idPull] = nil
                end
                nbItemsStack = nbItemsStack + 1
            end
        end
    end


    -- if there is place in both bags AND there is something to move

    while ((next(bankFreeSlots) ~= nil and next(pushItems) ~= nil and isPushSet) or (next(inventoryFreeSlots) ~= nil and next(pullItems) ~= nil and isPullSet) and securityCounter < 300) do
        securityCounter = securityCounter +1
        --We begin by pushing items from inventory
        if isPushSet then
            for k,item in pairs(pushItems) do
                --if the items was already stack (secure for maxStack items that are not registered at all)
                --if not inventoryItemsStackTable[item.id] and item.stack < item.maxStack then
                --    table.remove(pushItems,k)
                -- if there is a place in the bank at least
                if next(bankFreeSlots) ~= nil then
                    placeItems(item.bag, item.slot, BANKS_TRANSLATION[BankManager.Saved.bankChoice], table.remove(bankFreeSlots), item.stack)
                    --new place in bank
                    table.insert(inventoryFreeSlots,item.slot)
                    table.remove(pushItems,k)
                    nbItemsMove  = nbItemsMove + 1
                    displayChat(item.name, item.stack, true)
                --if not there is no point to continue
                else
                    break
                end
            end
        end
        --pull time
        if isPullSet then
            for k,item in pairs(pullItems) do
                --if not bankItemsStackTable[item.id] and item.stack < item.maxStack then
                --    table.remove(pullItems,k)
                if next(inventoryFreeSlots) ~= nil then
                    placeItems(item.bag, item.slot, BAG_BACKPACK, table.remove(inventoryFreeSlots), item.stack)
                    --new place in bank
                    table.insert(bankFreeSlots,item.slot)
                    table.remove(pullItems,k)
                    nbItemsMove  = nbItemsMove + 1
                    displayChat(item.name, item.stack, true)
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


---------------------------------------------------------------------------
-- ** Function called when the events are raised **
-- bankOpening(eventCode, addOnName, isManual)
-- @eventCode : Int,     Code of the event
-- @addOnName : String,  Name of the addon
-- @isManual  : Boolean, If the function was not launch by us... I guess :)
---------------------------------------------------------------------------
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
        --We set the guild bank to work with
        --we check the permission
        if DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_DEPOSIT) and DoesPlayerHaveGuildPermission(BankManager.Saved["guildChoice"], GUILD_PERMISSION_BANK_WITHDRAW) then 
            SelectGuildBank(BankManager.Saved["guildChoice"])
            ClearCursor()
            moveItems(true,true)
        else
            d(getTranslated("noPermission"))
        end
    end

end

------------------------------------------------
-- ** Function called when the bank is closed **
-- bankClose()
------------------------------------------------
function bankClose()
    hideUI()
end

------------------------------------------
-- ** Init Function **
-- init(eventCode, addOnName)
-- @eventCode : Int,     Code of the event
-- @addOnName : String,  Name of the addon
------------------------------------------
function init(eventCode, addOnName)
    if addOnName ~= BankManagerAppName then
        return
    end

    local initVarFalse              = NOTHING
    local defaults = {
        ["language"]                = getBaseLanguage(),
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