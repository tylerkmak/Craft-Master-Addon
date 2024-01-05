local version = "V1.0.0"

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

-- Add a scroll bar to craftableItemsFrame
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
        name, type, _,_, _, _ = GetTradeSkillInfo(i)
        if (name and type ~= "header") then
            outputText = outputText .. name .. ","
        end
    end

    editBox:SetText(outputText)
    editBox:HighlightText()
    UpdateScrollBar() 
    craftableItemsFrame:SetHeight(600)
    craftableItemsFrame:SetWidth(500) 
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
