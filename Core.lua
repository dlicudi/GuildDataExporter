LoadAddOn("Blizzard_GuildUI")
local AceGUI = LibStub("AceGUI-3.0")
local GuildDataExporter = LibStub("AceAddon-3.0"):GetAddon("GuildDataExporter")
local exportButton = CreateFrame("Button", nil, GuildFrame, "UIPanelButtonTemplate")

exportButton:SetSize(80, 22)  -- width, height
exportButton:SetText("GDE")
exportButton:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 40, -25)



local function UpdateGuildData()
    if not IsInGuild() then
        tab1:SetText("Not in a guild.")
        return
    end

    local info = ""
    local numMembers = GetNumGuildMembers()

    local ranks = GuildDataExporter.db.profile.ranks

    for i = 1, numMembers do
        local name, rank, _, level = GetGuildRosterInfo(i)
        local rankValue = ranks[rank] or nil
        if rankValue and level == 60 and rankValue > 0 then
            info = info .. name .. "\t" .. rankValue .. "\n"
        end
    end
    
    tab1:SetText(info)

end

local function GetGuildMembers()
    if not IsInGuild() then
        tab4:SetText("Not in a guild.")
        return
    end

    local function GetArmorType(class)
        local armorTypes = {
            ["Mage"] = "Cloth",
            ["Warlock"] = "Cloth",
            ["Priest"] = "Cloth",
            ["Rogue"] = "Leather",
            ["Druid"] = "Leather",
            ["Monk"] = "Leather",
            ["Demon Hunter"] = "Leather",
            ["Shaman"] = "Chain",
            ["Hunter"] = "Chain",
            ["Warrior"] = "Plate",
            ["Paladin"] = "Plate",
            ["Death Knight"] = "Plate"
        }
        return armorTypes[class] or "Unknown"
    end

    local info = ""
    local numMembers = GetNumGuildMembers()

    local ranks = GuildDataExporter.db.profile.ranks

    for i = 1, numMembers do
        local years, months, days, hours = GetGuildRosterLastOnline(i)
        local hoursOffline = (tonumber(years) or 0) * 365 * 24 + (tonumber(months) or 0) * 30 * 24 + (tonumber(days) or 0) * 24 + (tonumber(hours) or 0)

        local name, rank, rankIndex, level, class = GetGuildRosterInfo(i)
        local rankValue = ranks[rank] or nil
        local armorType = GetArmorType(class)
        
        if rankValue and level == 60 then
            info = info .. name .. "\t" .. rank .. "\t" .. class .. "\t" .. armorType .. "\t" .. hoursOffline .. "\n"
        end
    end
    
    tab4:SetText(info)
end



local function UpdateTrialRaiders()
    if not IsInGuild() then
        tab2:SetText("Not in a guild.")
        return
    end

    local info = ""
    local numMembers = GetNumGuildMembers()

    local trialRank = GuildDataExporter.db.profile.trialRaiderRank

    for i = 1, numMembers do
        local name, rank, _, level, _, _, _, officerNote = GetGuildRosterInfo(i)

        if rank == trialRank then
            info = info .. name .. "\t" .. officerNote .. "\n"
        end
    end

    tab2:SetText(info)
end



local function UpdateLongOfflineMembers()
    local yOffset = -5
    local numButtons = 0 -- Keep track to dynamically adjust the contentFrame's height
    local offlineThresholdHours = GuildDataExporter.db.profile.offlineThresholdHours
    local info = ""

    for i = 1, GetNumGuildMembers() do
        local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
        local years, months, days, hours = GetGuildRosterLastOnline(i)
        local totalHoursOffline = (tonumber(years) or 0) * 365 * 24 + (tonumber(months) or 0) * 30 * 24 + (tonumber(days) or 0) * 24 + (tonumber(hours) or 0)

        if not online and totalHoursOffline > offlineThresholdHours then
            info = info .. name .. "\t" .. totalHoursOffline .. "\n"

        end
    end

    tab3:SetText(info)

end


function CreateTabbedFrame()
    -- Create the main frame
    frame = AceGUI:Create("Frame")

    _G["MyGlobalFrameName"] = frame.frame
    tinsert(UISpecialFrames, "MyGlobalFrameName")


    frame:SetTitle("Guild Data Exporter")
    frame:SetWidth(600)
    frame:SetHeight(400)
    frame:SetLayout("Fill") -- Set layout to "Fill" so the tab group will take the whole space

    -- Create the tab group
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        {text = "Boosted Rolls", value = "tab1"},
        {text = "Trial Raiders", value = "tab2"},
        {text = "Inactive Users", value = "tab3"},
        {text = "Guild Members", value = "tab4"}
    })

    -- This function will handle tab changes
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren() -- clear the current content

        if group == "tab1" then
            tab1 = AceGUI:Create("MultiLineEditBox")
            tab1:SetLabel("The no lifers")
            tab1:SetFullWidth(true)
            tab1:SetFullHeight(true)
            container:AddChild(tab1)
            UpdateGuildData()
        elseif group == "tab2" then
            tab2 = AceGUI:Create("MultiLineEditBox")
            tab2:SetLabel("The rookies")
            tab2:SetFullWidth(true)
            tab2:SetFullHeight(true)
            container:AddChild(tab2)
            UpdateTrialRaiders()
        elseif group == "tab3" then        
            tab3 = AceGUI:Create("MultiLineEditBox")
            tab3:SetLabel("The quitters")
            tab3:SetFullWidth(true)
            tab3:SetFullHeight(true)
            container:AddChild(tab3)
            UpdateLongOfflineMembers()        
        elseif group == "tab4" then        
            tab4 = AceGUI:Create("MultiLineEditBox")
            tab4:SetLabel("The classes")
            tab4:SetFullWidth(true)
            tab4:SetFullHeight(true)
            container:AddChild(tab4)
            GetGuildMembers()
        end

    end)

    -- Set the default tab
    tabGroup:SelectTab("tab1")

    -- Add the tab group to the main frame
    frame:AddChild(tabGroup)
    frame:Hide()
end


local function OnAddonLoaded(self, event, addonName)
    if addonName == "GuildDataExporter" then
        CreateTabbedFrame()
        self:UnregisterEvent("ADDON_LOADED")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnAddonLoaded)



exportButton:SetScript("OnClick", function()
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
        UpdateGuildData()
    end
end)

SLASH_GDE1 = "/gde"

SlashCmdList["GDE"] = function(msg)
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
    end
end
