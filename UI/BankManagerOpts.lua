

local function setlanguage(val,controleKey)
    BankManager.Saved["language"] = val
    ReloadUI()
end

--Browse the language to find the key back
local function changeTranslateTable(val,key)
    profileNum = tonumber(string.match(key, "#(%d+)"))
    key       = string.gsub(key, "#.", "")

    for keyTrad,tradValue in pairs(language[BankManager.Saved["language"]]) do
        if tradValue == val then
            if profileNum ~= nil then
                BankManager.Saved[key][profileNum] = keyTrad
            else    
                BankManager.Saved[key] = keyTrad
            end
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

local function setGuild(val,key)
    local nbGuild = GetNumGuilds()

    for i=1,nbGuild do
        guildId = GetGuildId(i)
        if val == GetGuildName(guildId) then
            BankManager.Saved["guildChoice"] = guildId
            return
        end
    end
end

local function getMaxProfilesNb()
    local profileNbList = {}
    for i=1,maxProfilesNb do
        table.insert(profileNbList,i)
    end
    return profileNbList
end

local function setProfilesNb(val,key)
    BankManager.Saved["profilesNb"] = val
    ReloadUI()
end


function getProfileName(numProfile)
    if BankManager.Saved["profilesNames"][numProfile] ~= nil then
        return BankManager.Saved["profilesNames"][numProfile]
    else
        return getTranslated("profile") .. "_"..numProfile
    end
end

local function getProfilesNames()
    local profilesNames = {}
    for i=1,BankManager.Saved["profilesNb"] do
        table.insert(profilesNames,getProfileName(i))
    end
    return profilesNames
end

local function setDefaultProfile(val,key)
    for k,v in pairs(getProfilesNames()) do
        if v == val then
            BankManager.Saved["defaultProfile"] = k
            return
        end
    end
end

local function createSubMenuRules(lam,panelID,numProfile)
    --CRAFT MODE
    lam:AddHeader(panelID, "craftHeaderBM"..numProfile,  "|c3366FF" .. getTranslated("craftHeader").."|r")
    for key,craftKey in pairs(craftingElements) do
        local craftName = getTranslated(craftKey)
        --special treatment if this is Raw Material
        if craftKey == "CRAFTING_TYPE_RAW" then
            --The checkbox -- #is for the conflict    
            lam:AddDropdown(panelID, craftKey.."#"..numProfile, "|cFFA200"..craftName.."|r", "", getTranslateTable(rawSendingType),
            function() return getTranslated(BankManager.Saved[craftKey][numProfile]) end,
            changeTranslateTable,true,getTranslated("rawsWarning")) 
        else
            lam:AddDropdown(panelID, craftKey.."#"..numProfile, craftName, "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved[craftKey][numProfile]) end,
            changeTranslateTable) 
        end
    end

    --OTHERS MODE
    lam:AddHeader(panelID, "othersHeaderBM"..numProfile, "|c3366FF" .. getTranslated("othersHeader").."|r")
    for key,othersKey in pairs(othersElements) do
        local othersName = getTranslated(othersKey)


        --The checkbox -- #is for the conflict 
        lam:AddDropdown(panelID, othersKey.."#"..numProfile, othersName, "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved[othersKey][numProfile]) end,
            changeTranslateTable)    
    end
end

function options()
    local textCheckBox = ""
    local craftName, textCheckBox, othersKey
    local LAM = LibStub("BankManager_LibAddonMenu-1.0")
    local optionsPanel = LAM:CreateControlPanel("Bank Manager", "|c3366FFBank|r Manager")
    LAM:AddHeader(optionsPanel, "versionBM", "|c3366FF" .. getTranslated("version").."|r:" .. currentVersion)
    LAM:AddHeader(optionsPanel, "headerBM", "|c3366FF" .. getTranslated("title").."|r" )

    LAM:AddDropdown(optionsPanel, "languageBM", getTranslated("dropDownLanguageText"), getTranslated("dropDownLanguageTooltip"), languages,
            function() return BankManager.Saved["language"] end,
            setlanguage,
            true , getTranslated("reloadWarning"))
    
    LAM:AddCheckbox(optionsPanel, "toolBarDisplayedBM", getTranslated("toolBarDisplayed"), getTranslated("toolBarDisplayedTooltip"),
            function() return BankManager.Saved["toolBarDisplayed"] end,
            function(val) BankManager.Saved["toolBarDisplayed"] = val end)
    
    LAM:AddDropdown(optionsPanel, "bankChoice", "|cFF0000" .. getTranslated("bankChoice").."|r", getTranslated("bankChoiceTooltip"), getTranslateTable(banks),
            function() return getTranslated(BankManager.Saved["bankChoice"]) end,
            changeTranslateTable,true,"NOT WORKING")

    LAM:AddDropdown(optionsPanel, "guildChoice", getTranslated("guildChoice"), getTranslated("guildChoice"), getGuildList(),
            function() return GetGuildName(BankManager.Saved["guildChoice"]) end,
            setGuild)

    LAM:AddCheckbox(optionsPanel, "autoTransfertBM", getTranslated("autoTransfert"), getTranslated("autoTransfertTooltip"),
            function() return BankManager.Saved["autoTransfert"] end,
            function(val) BankManager.Saved["autoTransfert"] = val end)


    LAM:AddCheckbox(optionsPanel, "spamChatBM", getTranslated("spamChatText"), getTranslated("spamChatTooltip"),
            function() return BankManager.Saved["spamChat"] end,
            function(val) BankManager.Saved["spamChat"] = val end)
    
    LAM:AddCheckbox(optionsPanel, "spamChatAllBM", getTranslated("spamChatAllText"), getTranslated("spamChatAllTooltip"),
            function() return BankManager.Saved["spamChatAll"] end,
            function(val) BankManager.Saved["spamChatAll"] = val end)


    LAM:AddDropdown(optionsPanel, "profilesNbBM", getTranslated("profilesNb"), getTranslated("profilesNbTooltip"), getMaxProfilesNb(),
            function() return BankManager.Saved["profilesNb"] end,
            setProfilesNb,
            true , getTranslated("reloadWarning"))

    --Small note : if we decrease the number of avalaible profils we must check that the default profil name is not one of the unaccessible profils
    LAM:AddDropdown(optionsPanel, "defaultProfileBM", getTranslated("defaultProfile"), getTranslated("defaultProfileTooltip"), getProfilesNames(),
            function() return getProfileName(tonumber(BankManager.Saved["defaultProfile"]) <= tonumber(BankManager.Saved["profilesNb"]) and BankManager.Saved["defaultProfile"] or 1) end,
            setDefaultProfile)

    --Profile Mode !
    for i=1,BankManager.Saved["profilesNb"] do
        LAM:AddHeader(optionsPanel, "headerProfiles"..i.."BM", "|c3366FF"..getProfileName(i).."|r")
        LAM:AddEditBox(optionsPanel, "editBoxProfiles"..i.."BM", getTranslated("profileName"), getTranslated("profileNameTooltip"), false,
            function() return getProfileName(i) end,
            function(val) 
                BankManager.Saved["profilesNames"][i] = val
                ReloadUI()
            end,
            true , getTranslated("reloadWarning"))

        LAM:AddDropdown(optionsPanel, "AllBM#"..i, getTranslated("AllBM"), "", getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved["AllBM"][i]) end,
            changeTranslateTable)

        LAM:AddDropdown(optionsPanel, "fillStacks#"..i, getTranslated("fillStacks"), getTranslated("fillStacksTooltip"), getTranslateTable(sendingType),
            function() return getTranslated(BankManager.Saved["fillStacks"][i]) end,
            changeTranslateTable)

        local subMenuRules = LAM:AddSubMenu(optionsPanel, "subMenuRulesBM"..i, getTranslated("subMenuRulesButton"), getTranslated("subMenuRulesButtonTooltip"))
        createSubMenuRules(LAM, subMenuRules,i)
    end
end