local version = "V1.1.1"
local warningShown = false
local warningPopupFrame = nil


local craftableItemsFrame = CreateFrame("Frame", "CraftableItemsFrame", UIParent, "BasicFrameTemplateWithInset")
local headerText = craftableItemsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

headerText:SetText("Craft Master " .. version)
headerText:SetPoint("TOP", craftableItemsFrame, "TOP", 0, -8)
craftableItemsFrame:SetSize(400, 600)  
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


local scrollFrame = CreateFrame("ScrollFrame", "CraftableItemsScrollFrame", craftableItemsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)  


local editBox = CreateFrame("EditBox", "CraftableItemsEditBox", scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject(GameFontNormal)
editBox:SetWidth(480)  
editBox:SetAutoFocus(true)
editBox:SetScript("OnEscapePressed", function()
    craftableItemsFrame:Hide()
end)
scrollFrame:SetScrollChild(editBox)

-- Scroll Bar to craftableItemsFrame
local scrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("TOPLEFT", craftableItemsFrame, "TOPRIGHT", -16, -30)
scrollBar:SetPoint("BOTTOMRIGHT", craftableItemsFrame, "BOTTOMRIGHT", -8, 40) 
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
            warningPopupFrame:SetSize(380, 350)  
            warningPopupFrame:SetPoint("CENTER")
            warningPopupFrame:EnableMouse(true)
            warningPopupFrame:SetMovable(true)
            warningPopupFrame:SetResizable(true)
        
            
            local backgroundTexture = warningPopupFrame:CreateTexture(nil, "BACKGROUND")
            backgroundTexture:SetAllPoints(true)
            backgroundTexture:SetColorTexture(0, 0, 0, 0.9)  
        
           
            local editBox = CreateFrame("EditBox", nil, warningPopupFrame)
            editBox:SetMultiLine(true)
            editBox:SetFontObject(GameFontNormalLarge)  
            editBox:SetHeight(250)
            editBox:SetPoint("TOPLEFT", 10, -40)  
            editBox:SetPoint("BOTTOMRIGHT", -10, 10)
            editBox:SetAutoFocus(false)
            editBox:SetScript("OnEscapePressed", function()
                warningPopupFrame:Hide()
            end)
            editBox:SetScript("OnMouseDown", function() editBox:HighlightText() end)
            editBox:EnableMouse(true) 
            editBox:SetTextColor(1, 0, 0)  
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
        warningShown = true
    end
end

-- Function to replace item names with IDs in the output text
local function ReplaceItemNamesWithIDs(outputText)
    local resultString = ""
    local notFoundItems = {}

    for item in outputText:gmatch("[^,]+") do
        local exactMatch = false

        -- Check for an exact match in the itemIDMapping
        for itemName, itemID in pairs(itemIDMapping) do
            if item == itemName then
                exactMatch = true
                resultString = resultString .. itemID .. ","
                break
            end
        end

        if not exactMatch then
            table.insert(notFoundItems, item)
        end
    end

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

    local contentHeight = editBox:GetHeight()
    local contentWidth = editBox:GetWidth()  
    local frameHeight = math.max(contentHeight + 120, 300)  
    local adjustedFrameHeight = math.min(frameHeight, 600)  

    craftableItemsFrame:SetHeight(adjustedFrameHeight)
    craftableItemsFrame:SetWidth(contentWidth + 50)
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

