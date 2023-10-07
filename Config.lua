local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

GuildExport = LibStub("AceAddon-3.0"):NewAddon("GuildExport", "AceConsole-3.0")



local function getGuildRanksOptions()
    local options = {}
    for i = 1, GuildControlGetNumRanks() do
        local rankName = GuildControlGetRankName(i)
        if rankName and rankName ~= "" then
            options[rankName] = {
                type = "range",
                name = rankName,
                min = 0,
                max = 1000,  -- You can adjust the maximum value based on your needs
                step = 100,
                order = i,
                set = function(info, value)
                    GuildExport.db.profile.ranks[rankName] = value
                end,
                get = function()
                    return GuildExport.db.profile.ranks[rankName] or 0
                end
            }
        end
    end
    return options
end

local options = {
    name = "GuildExport",
    type = "group",
    args = {
        ranks = {
            type = "group",
            name = "Guild Ranks",
            args = getGuildRanksOptions()
        },
    },
}


-- Your existing code...

local function getConfigData()
    return AceSerializer:Serialize(GuildExport.db.profile)
end

local function setConfigData(value)
    local success, data = AceSerializer:Deserialize(value)
    if success then
        GuildExport.db.profile = data
        print("Configuration updated successfully!")
    else
        print("Failed to update configuration: ", data)  -- data contains the error message
    end
end

-- Add to your options table:
options.args.configHeader = {
    order = 5,
    type = "header",
    name = "Configuration Data",
}

options.args.configDescription = {
    order = 6,
    type = "description",
    name = "Directly edit the raw configuration data below:",
}

options.args.configData = {
    order = 7,
    type = "input",
    name = "Config Data",
    width = "full",
    multiline = true,
    set = function(info, value)
        setConfigData(value)
    end,
    get = function()
        return getConfigData()
    end
}

options.args.refreshButton = {
    order = 8,
    type = "execute",
    name = "Refresh Data",
    desc = "Refresh the configuration data to the latest saved state.",
    func = function()
        -- This is a no-op. It will cause the getter for the edit box to be called again.
    end
}


function GuildExport:OnInitialize()
    self.db = AceDB:New("GuildDataExporterDB", { profile = { ranks = {} } })
    AceConfig:RegisterOptionsTable("GuildExport", options)
    AceConfigDialog:AddToBlizOptions("GuildExport", "GuildExport")
end
