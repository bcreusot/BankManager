

local function changelanguage(val,controleKey)
    BankManager.Saved["language"] = val
    ReloadUI()
end

--Browse the language to find the key back
local function changeTranslateTable(val,key)
    key = string.gsub(key, "#", "")
    for keyTrad,tradValue in pairs(language[BankManager.Saved["language"]]) do
        if tradValue == val then
            BankManager.Saved[key] = keyTrad
            return
        end
    end

end


local function getTranslateTable(arraySendingType)
    local result = {}
    for i,v in ipairs(arraySendingType) do
        table.insert(result,getTranslated(v))
    end
    return result
end

local function getGuildList()
    local guildList = {}
    local nbGuild = GetNumGuilds()

    for i=1,nbGuild do
        table.insert(guildList,GetGuildName(GetGuildId(i)))
    end
    return guildList
end


local function changeGuild(val,key)
    local nbGuild = GetNumGuilds()

    for i=1,nbGuild do
        guildId = GetGuildId(i)
        if val == GetGuildName(guildId) then
            BankManager.Saved["guildChoice"] = guildId
            return
        end
    end
end

function options()
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
    
    LAM:AddCheckbox(optionsPanel, "toolBarDisplayedBM", getTranslated("toolBarDisplayed"), getTranslated("toolBarDisplayedTooltip"),
            function() return BankManager.Saved["toolBarDisplayed"] end,
            function(val) BankManager.Saved["toolBarDisplayed"] = val end)
    
    LAM:AddDropdown(optionsPanel, "bankChoice", "|cFF0000" .. getTranslated("bankChoice").."|r", getTranslated("bankChoiceTooltip"), getTranslateTable(banks),
            function() return getTranslated(BankManager.Saved["bankChoice"]) end,
            changeTranslateTable,true,"NOT WORKING")

    LAM:AddDropdown(optionsPanel, "guildChoice", getTranslated("guildChoice"), getTranslated("guildChoice"), getGuildList(),
            function() return GetGuildName(BankManager.Saved["guildChoice"]) end,
            changeGuild)

    LAM:AddCheckbox(optionsPanel, "autoTransfertBM", getTranslated("autoTransfert"), getTranslated("autoTransfertTooltip"),
            function() return BankManager.Saved["autoTransfert"] end,
            function(val) BankManager.Saved["autoTransfert"] = val end)


    LAM:AddCheckbox(optionsPanel, "spamChatBM", getTranslated("spamChatText"), getTranslated("spamChatTooltip"),
            function() return BankManager.Saved["spamChat"] end,
            function(val) BankManager.Saved["spamChat"] = val end)


    LAM:AddDropdown(optionsPanel, "AllBM", getTranslated("AllBM"), "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved["AllBM"]) end,
            changeTranslateTable)

    LAM:AddDropdown(optionsPanel, "fillStacks", getTranslated("fillStacks"), getTranslated("fillStacksTooltip"), getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved["fillStacks"]) end,
            changeTranslateTable)


    --CRAFT MODE
    LAM:AddHeader(optionsPanel, "craftHeaderBM",  "|c3366FF" .. getTranslated("craftHeader").."|r")
	for key,craftKey in pairs(craftingElements) do
        local craftName = getTranslated(craftKey)
        --special treatment if this is Raw Material
        if craftKey == "CRAFTING_TYPE_RAW" then
            --The checkbox -- #is for the conflict    
            LAM:AddDropdown(optionsPanel, craftKey.."#", craftName, "", getTranslateTable(rawSendingType),
            function() return getTranslated(BankManager.Saved[craftKey]) end,
            changeTranslateTable,true,getTranslated("rawsWarning")) 
        else
            LAM:AddDropdown(optionsPanel, craftKey.."#", craftName, "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved[craftKey]) end,
            changeTranslateTable) 
        end
    end

    --OTHERS MODE
    LAM:AddHeader(optionsPanel, "othersHeaderBM", "|c3366FF" .. getTranslated("othersHeader").."|r")
    for key,othersKey in pairs(othersElements) do
        local othersName = getTranslated(othersKey)


        --The checkbox -- #is for the conflict 
        LAM:AddDropdown(optionsPanel, othersKey.."#", othersName, "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved[othersKey]) end,
            changeTranslateTable)    
    end
end