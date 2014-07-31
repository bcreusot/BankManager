
NOTHING             = "NOTHING"
BANK_TO_INVENTORY   = "BANK_TO_INVENTORY"
INVENTORY_TO_BANK   = "INVENTORY_TO_BANK"

sendingType = {
    NOTHING,
    BANK_TO_INVENTORY,
    INVENTORY_TO_BANK
}

ITEMTYPE_TRANSLATION = {
    [ITEMTYPE_ALCHEMY_BASE]                 = "ITEMTYPE_ALCHEMY_BASE",
    [ITEMTYPE_REAGENT]                      = "ITEMTYPE_REAGENT",
    [ITEMTYPE_GLYPH_ARMOR]                  = "ITEMTYPE_GLYPH_ARMOR",
    [ITEMTYPE_GLYPH_JEWELRY]                = "ITEMTYPE_GLYPH_JEWELRY",    
    [ITEMTYPE_GLYPH_WEAPON]                 = "ITEMTYPE_GLYPH_WEAPON",    
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT]       = "ITEMTYPE_ENCHANTING_RUNE_ASPECT",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE]      = "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY]      = "ITEMTYPE_ENCHANTING_RUNE_POTENCY",
    [ITEMTYPE_ENCHANTMENT_BOOSTER]          = "ITEMTYPE_ENCHANTMENT_BOOSTER",            
    [ITEMTYPE_INGREDIENT]                   = "ITEMTYPE_INGREDIENT",
    [ITEMTYPE_WOODWORKING_BOOSTER]          = "ITEMTYPE_WOODWORKING_BOOSTER",
    [ITEMTYPE_WOODWORKING_MATERIAL]         = "ITEMTYPE_WOODWORKING_MATERIAL",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL]     = "ITEMTYPE_WOODWORKING_RAW_MATERIAL",                
    [ITEMTYPE_CLOTHIER_BOOSTER]             = "ITEMTYPE_CLOTHIER_BOOSTER",
    [ITEMTYPE_CLOTHIER_MATERIAL]            = "ITEMTYPE_CLOTHIER_MATERIAL",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL]        = "ITEMTYPE_CLOTHIER_RAW_MATERIAL",                
    [ITEMTYPE_BLACKSMITHING_BOOSTER]        = "ITEMTYPE_BLACKSMITHING_BOOSTER",
    [ITEMTYPE_BLACKSMITHING_MATERIAL]       = "ITEMTYPE_BLACKSMITHING_MATERIAL",
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]   = "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL",
    [ITEMTYPE_WEAPON]                       = "ITEMTYPE_WEAPON",
    [ITEMTYPE_WEAPON_BOOSTER]               = "ITEMTYPE_WEAPON_BOOSTER",
    [ITEMTYPE_ARMOR]                        = "ITEMTYPE_ARMOR",
    [ITEMTYPE_ARMOR_BOOSTER]                = "ITEMTYPE_ARMOR_BOOSTER",
    [ITEMTYPE_COSTUME]                      = "ITEMTYPE_COSTUME",
    [ITEMTYPE_DISGUISE]                     = "ITEMTYPE_DISGUISE",
    [ITEMTYPE_DRINK]                        = "ITEMTYPE_DRINK",
    [ITEMTYPE_FOOD]                         = "ITEMTYPE_FOOD",
    [ITEMTYPE_LURE]                         = "ITEMTYPE_LURE",
    [ITEMTYPE_AVA_REPAIR]                   = "ITEMTYPE_AVA_REPAIR",
    [ITEMTYPE_TOOL]                         = "ITEMTYPE_TOOL",
    [ITEMTYPE_POTION]                       = "ITEMTYPE_POTION",
    [ITEMTYPE_POISON]                       = "ITEMTYPE_POISON",
    [ITEMTYPE_RECIPE]                       = "ITEMTYPE_RECIPE",
    [ITEMTYPE_RACIAL_STYLE_MOTIF]           = "ITEMTYPE_RACIAL_STYLE_MOTIF",
    [ITEMTYPE_SIEGE]                        = "ITEMTYPE_SIEGE",
    [ITEMTYPE_SOUL_GEM]                     = "ITEMTYPE_SOUL_GEM",
    [ITEMTYPE_STYLE_MATERIAL]               = "ITEMTYPE_STYLE_MATERIAL",
    [ITEMTYPE_TABARD]                       = "ITEMTYPE_TABARD",
    [ITEMTYPE_TROPHY]                       = "ITEMTYPE_TROPHY",
    [ITEMTYPE_WEAPON_TRAIT]                 = "ITEMTYPE_WEAPON_TRAIT",
    [ITEMTYPE_ARMOR_TRAIT]                  = "ITEMTYPE_ARMOR_TRAIT"
}       


blackSmithingRules = {
    "ITEMTYPE_BLACKSMITHING_BOOSTER",
    "ITEMTYPE_BLACKSMITHING_MATERIAL",
    "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL"
}

clothierRules = {
    "ITEMTYPE_CLOTHIER_BOOSTER",
    "ITEMTYPE_CLOTHIER_MATERIAL",
    "ITEMTYPE_CLOTHIER_RAW_MATERIAL"
}
woodWorkingRules = {
    "ITEMTYPE_WOODWORKING_BOOSTER",
    "ITEMTYPE_WOODWORKING_MATERIAL",
    "ITEMTYPE_WOODWORKING_RAW_MATERIAL"
}
provisioningRules = {
    "ITEMTYPE_INGREDIENT",
    "ITEMTYPE_DRINK",
    "ITEMTYPE_FOOD",
    "ITEMTYPE_RECIPE"
}
enchantingRules = {
    "ITEMTYPE_ENCHANTING_RUNE_ASPECT",
    "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
    "ITEMTYPE_ENCHANTING_RUNE_POTENCY",
    "ITEMTYPE_ENCHANTMENT_BOOSTER",
    "ITEMTYPE_GLYPH_ARMOR",
    "ITEMTYPE_GLYPH_JEWELRY",
    "ITEMTYPE_GLYPH_WEAPON"
}
alchemyRules = {
    "ITEMTYPE_ALCHEMY_BASE",
    "ITEMTYPE_REAGENT"
}

othersElementsRules = {
    "ITEMTYPE_STYLE_MATERIAL",
    "ITEMTYPE_WEAPON_TRAIT",
    "ITEMTYPE_ARMOR_TRAIT",
    "ITEMTYPE_WEAPON",
    "ITEMTYPE_WEAPON_BOOSTER",
    "ITEMTYPE_ARMOR",
    "ITEMTYPE_ARMOR_BOOSTER",
    "ITEMTYPE_COSTUME",
    "ITEMTYPE_DISGUISE",
    "ITEMTYPE_LURE",
    "ITEMTYPE_AVA_REPAIR",
    "ITEMTYPE_TOOL",
    "ITEMTYPE_POTION",
    "ITEMTYPE_POISON",
    "ITEMTYPE_RACIAL_STYLE_MOTIF",
    "ITEMTYPE_SIEGE",
    "ITEMTYPE_SOUL_GEM",
    "ITEMTYPE_TABARD",
    "ITEMTYPE_TROPHY"
}


allRules = {
    blackSmithingRules,
    clothierRules,
    woodWorkingRules,
    provisioningRules,
    enchantingRules,
    alchemyRules,
    othersElementsRules
}