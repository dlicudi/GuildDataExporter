LoadAddOn("Blizzard_GuildUI")
local GuildDataExporter = LibStub("AceAddon-3.0"):GetAddon("GuildDataExporter")

local exportButton = CreateFrame("Button", nil, GuildFrame, "UIPanelButtonTemplate")
exportButton:SetSize(80, 22)  -- width, height
exportButton:SetText("GDE")
exportButton:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 40, -25)


local frame = CreateFrame("Frame", "GuildExportFrame", GuildFrame, "BackdropTemplate")
frame:SetSize(280, 400)
frame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 5, 0)
frame:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:Hide()

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
closeButton:SetSize(24, 24)  -- Standard close button size
closeButton:SetScript("OnClick", function()
    frame:Hide()  -- Hide the main frame when the close button is clicked
end)


local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)


local frameTitleBg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
frameTitleBg:SetSize(130, 30) -- Adjust the size as needed
frameTitleBg:SetPoint("TOP", frame, "TOP", 0, -10)
frameTitleBg:SetBackdrop({
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local frameTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frameTitle:SetPoint("CENTER", frameTitleBg, "CENTER")
frameTitle:SetText("Guild Export")


scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)


local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject("ChatFontNormal")
editBox:SetWidth(frame:GetWidth() - 40)
editBox:SetHeight(frame:GetHeight() - 20)
editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
editBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then return end
    local _, max = scrollFrame.ScrollBar:GetMinMaxValues()
    local diff = max - scrollFrame.ScrollBar:GetValue()
    if diff < 10 then
        scrollFrame.ScrollBar:SetValue(max)
    end
end)

scrollFrame:SetScrollChild(editBox)

local function UpdateGuildData()
    if not IsInGuild() then
        editBox:SetText("Not in a guild.")
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
            -- info = info .. name .. "\t" .. rank .. "\n"
        end
        -- years, months, days, hours = GetGuildRosterLastOnline(i);
        -- years, months, days, hours = years and years or 0, months and months or 0, days and days or 0, hours and hours or 0;
        -- toff = (((years*12)+months)*30.5+days)*24+hours;
        -- info = info .. name .. "," .. tostring(toff) .. "\n"
    end
    
    editBox:SetText(info)
end


exportButton:SetScript("OnClick", function()
    UpdateGuildData()
    frame:Show()
end)
