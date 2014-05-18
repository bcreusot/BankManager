 
 -- Global Vars
BankManagerVars    = "BMVars"
BankManagerAppName = "BankManager"
currentVersion     = "v2.7"

-- Main Vars
BankManager           = {}
--Limit the number of message in the chat to avoid spamming detection by the game
counterMessageChat    = 0
limitMessageChat      = 20
--CUrrent selectec profile
currentProfile         = 1
--In case two quick click on the toolbar button while performing
flagAlreadyPerforming = false
--Number of Max Profiles per character
maxProfilesNb          = 3

languages = {
    "English",
    "Francais",
    "Deutsch"
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


banks = {
    "BAG_BANK",
    "BAG_GUILDBANK"
}
BANKS_TRANSLATION = {
    ["BAG_BANK"]                    = BAG_BANK,
    ["BAG_GUILDBANK"]               = BAG_GUILDBANK
}

othersElements = {
    "ITEMTYPE_WEAPON",
    "ITEMTYPE_WEAPON_BOOSTER",
    "ITEMTYPE_ARMOR",
    "ITEMTYPE_ARMOR_BOOSTER",
    "ITEMTYPE_COSTUME",
    "ITEMTYPE_DISGUISE",
    "ITEMTYPE_DRINK",
    "ITEMTYPE_FOOD",
    "ITEMTYPE_LURE",
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
ITEMTYPE_TRANSLATION = {
    [ITEMTYPE_WEAPON]               = "ITEMTYPE_WEAPON",
    [ITEMTYPE_WEAPON_BOOSTER]       = "ITEMTYPE_WEAPON_BOOSTER",
    [ITEMTYPE_ARMOR]                = "ITEMTYPE_ARMOR",
    [ITEMTYPE_ARMOR_BOOSTER]        = "ITEMTYPE_ARMOR_BOOSTER",
    [ITEMTYPE_COSTUME]              = "ITEMTYPE_COSTUME",
    [ITEMTYPE_DISGUISE]             = "ITEMTYPE_DISGUISE",
    [ITEMTYPE_DRINK]                = "ITEMTYPE_DRINK",
    [ITEMTYPE_FOOD]                 = "ITEMTYPE_FOOD",
    [ITEMTYPE_LURE]                 = "ITEMTYPE_LURE",
    [ITEMTYPE_AVA_REPAIR]           = "ITEMTYPE_AVA_REPAIR",
    [ITEMTYPE_LOCKPICK]             = "ITEMTYPE_LOCKPICK",
    [ITEMTYPE_POTION]               = "ITEMTYPE_POTION",
    [ITEMTYPE_POISON]               = "ITEMTYPE_POISON",
    [ITEMTYPE_RECIPE]               = "ITEMTYPE_RECIPE",
    [ITEMTYPE_SCROLL]               = "ITEMTYPE_SCROLL",
    [ITEMTYPE_SIEGE]                = "ITEMTYPE_SIEGE",
    [ITEMTYPE_SOUL_GEM]             = "ITEMTYPE_SOUL_GEM",
    [ITEMTYPE_STYLE_MATERIAL]       = "ITEMTYPE_STYLE_MATERIAL",
    [ITEMTYPE_TABARD]               = "ITEMTYPE_TABARD",
    [ITEMTYPE_TROPHY]               = "ITEMTYPE_TROPHY",
    [ITEMTYPE_WEAPON_TRAIT]         = "ITEMTYPE_WEAPON_TRAIT",
    [ITEMTYPE_ARMOR_TRAIT]          = "ITEMTYPE_ARMOR_TRAIT",
    [ITEMTYPE_RAW_MATERIAL]         = "CRAFTING_TYPE_RAW"
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

CRAFTING_TYPE_TRANSLATION = {
    [CRAFTING_TYPE_BLACKSMITHING]   = "CRAFTING_TYPE_BLACKSMITHING",
    [CRAFTING_TYPE_CLOTHIER]        = "CRAFTING_TYPE_CLOTHIER",     
    [CRAFTING_TYPE_ENCHANTING]      = "CRAFTING_TYPE_ENCHANTING",   
    [CRAFTING_TYPE_ALCHEMY]         = "CRAFTING_TYPE_ALCHEMY",      
    [CRAFTING_TYPE_PROVISIONING]    = "CRAFTING_TYPE_PROVISIONING", 
    [CRAFTING_TYPE_WOODWORKING]     = "CRAFTING_TYPE_WOODWORKING"  
}
