local version = "V1.1.0"
local warningShown = false
local warningPopupFrame = nil

-- Create frame for edit box to sit in
local craftableItemsFrame = CreateFrame("Frame", "CraftableItemsFrame", UIParent, "BasicFrameTemplateWithInset")
-- Frame settings
local headerText = craftableItemsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerText:SetText("Craft Master " .. version)
headerText:SetPoint("TOP", craftableItemsFrame, "TOP", 0, -8)
craftableItemsFrame:SetSize(400, 600)  -- Adjusted size
craftableItemsFrame:SetPoint("CENTER")
craftableItemsFrame:EnableMouse(true)
craftableItemsFrame:SetMovable(true)
craftableItemsFrame:SetResizable(true)
craftableItemsFrame:SetFrameStrata("HIGH")
craftableItemsFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
craftableItemsFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end)

-- Close button for craftableItemsFrame
local closeButton = CreateFrame("Button", "CraftableItemsCloseButton", craftableItemsFrame, "UIPanelButtonTemplate")
closeButton:SetText("Close Window")
closeButton:SetSize(100, 25)
closeButton:SetPoint("BOTTOM", craftableItemsFrame, "BOTTOM", 0, 10)
closeButton:SetScript("OnClick", function()
    craftableItemsFrame:Hide()
end)

-- Create a scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "CraftableItemsScrollFrame", craftableItemsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)  -- Adjusted bottom margin

-- Create an edit box for data display
local editBox = CreateFrame("EditBox", "CraftableItemsEditBox", scrollFrame)
-- Edit box settings
editBox:SetMultiLine(true)
editBox:SetFontObject(GameFontNormal)
editBox:SetWidth(480)  -- Adjusted width
editBox:SetAutoFocus(true)
editBox:SetScript("OnEscapePressed", function()
    craftableItemsFrame:Hide()
end)
scrollFrame:SetScrollChild(editBox)

-- Scroll Bar to craftableItemsFrame
local scrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("TOPLEFT", craftableItemsFrame, "TOPRIGHT", -16, -30)
scrollBar:SetPoint("BOTTOMRIGHT", craftableItemsFrame, "BOTTOMRIGHT", -8, 40)  -- Adjusted bottom margin
scrollBar:SetMinMaxValues(1, 1)
scrollBar:SetValueStep(1)
scrollBar.scrollStep = 1
scrollBar:SetValue(0)
scrollBar:SetWidth(16)
scrollBar:SetScript("OnValueChanged", function(self, value)
    self:GetParent():SetVerticalScroll(value)
end)

-- Function to update the scroll bar when the edit box changes
local function UpdateScrollBar()
    local maxValue = editBox:GetHeight() - scrollFrame:GetHeight()
    if maxValue > 0 then
        scrollBar:SetMinMaxValues(1, maxValue)
        scrollBar:Show()
    else
        scrollBar:Hide()
    end
end

local function ShowWarningPopup(warningMessage, notFoundItems)
    if not warningShown then
        if not warningPopupFrame then
            warningPopupFrame = CreateFrame("Frame", "CraftMasterWarningPopup", UIParent)
            warningPopupFrame:SetSize(380, 350)  -- Increased height to accommodate the additional text
            warningPopupFrame:SetPoint("CENTER")
            warningPopupFrame:EnableMouse(true)
            warningPopupFrame:SetMovable(true)
            warningPopupFrame:SetResizable(true)
        
            -- Create a background texture to set the background color
            local backgroundTexture = warningPopupFrame:CreateTexture(nil, "BACKGROUND")
            backgroundTexture:SetAllPoints(true)
            backgroundTexture:SetColorTexture(0, 0, 0, 0.9)  -- Almost black background color
        
            -- Add an edit box for displaying the warning message
            local editBox = CreateFrame("EditBox", nil, warningPopupFrame)
            editBox:SetMultiLine(true)
            editBox:SetFontObject(GameFontNormalLarge)  -- Bigger font for title
            editBox:SetWidth(350)
            editBox:SetHeight(250)
            editBox:SetPoint("TOPLEFT", 10, -40)  -- Adjusted position for title
            editBox:SetPoint("BOTTOMRIGHT", -10, 10)
            editBox:SetAutoFocus(false)
            editBox:SetScript("OnEscapePressed", function()
                warningPopupFrame:Hide()
            end)
            editBox:SetScript("OnMouseDown", function() editBox:HighlightText() end)
            editBox:EnableMouse(true)  -- Enable mouse interaction for editable box
            editBox:SetTextColor(1, 0, 0)  -- Stark red text color for items not found
            editBox:SetText("Please report these items to the CraftMaster discord or via the /bugreport command on your server\n\n")
        
            warningPopupFrame.editBox = editBox
        
            -- Close button for the warning popup
            local closeButton = CreateFrame("Button", nil, warningPopupFrame, "UIPanelButtonTemplate")
            closeButton:SetText("Close Window")
            closeButton:SetSize(100, 25)
            closeButton:SetPoint("BOTTOM", warningPopupFrame, "BOTTOM", 0, 10)
            closeButton:SetFrameStrata("DIALOG")
            closeButton:SetScript("OnClick", function()
                warningPopupFrame:Hide()
            end)
        
        end

        -- Set title and color for items not found
        local title = "Warning: Items Not Found"
        local formattedNotFoundItems = "|cFFFF0000" .. table.concat(notFoundItems, "\n") .. "|r"

        warningPopupFrame.editBox:SetText(title .. "\n\n" .. "Please report these items to the CraftMaster discord or via the /bugreport command on your server\n\n" .. formattedNotFoundItems)

        warningPopupFrame:Show()

        -- Set the flag to indicate the warning has been shown
        warningShown = true
    end
end

-- Function to replace item names with IDs in the output text
local function ReplaceItemNamesWithIDs(outputText)
    local resultString = ""
    local notFoundItems = {}  -- Track items not found in itemIDMapping

    for item in outputText:gmatch("[^,]+") do
        local exactMatch = false

        -- Check for an exact match in the itemIDMapping
        for itemName, itemID in pairs(itemIDMapping) do
            if item == itemName then
                exactMatch = true
                -- Append the itemID to the resultString
                resultString = resultString .. itemID .. ","
                break
            end
        end

        -- If no exact match is found
        if not exactMatch then
            table.insert(notFoundItems, item)
        end
    end

    -- Remove the trailing comma, if any
    resultString = resultString:gsub(",$", "")

    -- Display warning for not found items
    if #notFoundItems > 0 then
        local warningMessage = "Warning: The following item(s) were not found and will be added in the near future."
        ShowWarningPopup(warningMessage, notFoundItems)
    end

    return resultString
end



-- Function to list craftable items for current skill window open
function ListCraftableItems()
    local numTradeSkills = GetNumTradeSkills()

    -- This shouldn't ever happen after some changes, but leaving just in case
    if numTradeSkills == 0 then
        editBox:SetText("Please open a crafting window first and run this command.")
        craftableItemsFrame:Show()
        return
    end

    local outputText = ""
    local name, type;
    for i = 1, numTradeSkills do
        name, type, _, _, _, _ = GetTradeSkillInfo(i)
        if (name and type ~= "header") then
            outputText = outputText .. name .. ","
        end
    end

    -- Replace item names with their corresponding IDs
    outputText = ReplaceItemNamesWithIDs(outputText)

    editBox:SetText(outputText)
    editBox:HighlightText()
    UpdateScrollBar()

    -- Dynamically set the frame size based on the content
    local contentHeight = editBox:GetHeight()
    local contentWidth = editBox:GetWidth()  -- Get the width of the content
    local frameHeight = math.max(contentHeight + 120, 300)  -- Set the minimum height to 300 pixels
    local adjustedFrameHeight = math.min(frameHeight, 600)  -- Adjusted maximum height
    craftableItemsFrame:SetHeight(adjustedFrameHeight)
    craftableItemsFrame:SetWidth(contentWidth + 50)  -- Adjust the width to accommodate the content
    craftableItemsFrame:Show()
end

-- Event Handlers
local function OnCraftingWindowShow()
    ListCraftableItems()
end

-- Register craft window opening event
craftableItemsFrame:RegisterEvent("TRADE_SKILL_SHOW")
craftableItemsFrame:SetScript("OnEvent", OnCraftingWindowShow)

-- Hide is here to prevent an extra window from appearing because fuck you blizzard
craftableItemsFrame:Hide()

