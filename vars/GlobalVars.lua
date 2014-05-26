 
 -- Global Vars
BankManagerVars    = "BMVars"
BankManagerAppName = "BankManager"
currentVersion     = "v2.8"

-- Main Vars
BankManager           = {}
--Limit the number of message in the chat to avoid spamming detection by the game
counterMessageChat    = 0
limitMessageChat      = 20
--CUrrent selectec profile
currentProfile        = 1
--In case two quick click on the toolbar button while performing
flagAlreadyPerforming = false
--Number of Max Profiles per character
maxProfilesNb         = 3
--var representing the ID of the options panel
optionsPanel          = nil
--If the addon have to reload
dirty                 = false
--The controle panel textbox to display if the UI has to reload
reloadUITextbox       = nil
--type of gold transfer
typeOfGoldTransfer = {
	"goldAmount","goldPercentage"
}

--test var
test = {}

languages = {
    "English",
    "Francais",
    "Deutsch"
}



banks = {
    "BAG_BANK",
    "BAG_GUILDBANK"
}
BANKS_TRANSLATION = {
    ["BAG_BANK"]                    = BAG_BANK,
    ["BAG_GUILDBANK"]               = BAG_GUILDBANK
}
