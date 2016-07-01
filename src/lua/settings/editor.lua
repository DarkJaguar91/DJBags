local NAME, ADDON = ...

local STEP = 1
local SCROLL = 20
local MAX = 1

ADDON.settingsEditor = {}
ADDON.settingsEditor.__index = ADDON.settingsEditor

local settings = ADDON.settingsEditor
setmetatable(settings, {
    __call = function(self)
        return self.frame or self:CreateFrame()
    end
})

function settings:UpdateSettings()
    if self.frame then
        self.frame:Setup()
        if self.containers then
            for _, v in pairs(self.containers) do
                v:Setup()
            end
        end
    end
end

function settings:CreateFrame()
    self.frame = ADDON.container('DJBagsSettingsScreen')
    self.frame:SetSize(520, 450)
    self.frame:SetPoint("TOPLEFT", 200, -200)
    self.frame:Hide()
    table.insert(UISpecialFrames, self.frame:GetName())

    self.title = self.frame:CreateFontString('DJBagsSettingsScreenTitle', nil, 'GameFontNormal')
    self.title:SetText('DJBags Settings')
    self.title:SetPoint('TOPLEFT', 5, -5)

    self.exitBtn = CreateFrame('BUTTON', 'DJBagsSettingsScreenExitButton', self.frame, 'UIPanelCloseButton')
    self.exitBtn:SetPoint('TOPRIGHT')

    self.scrollBar = CreateFrame("Slider", 'DJBagsSettingsScreenScrollBar', self.frame, "UIPanelScrollBarTemplate")
    self.scrollBar:SetPoint('TOPRIGHT', -5, -50)
    self.scrollBar:SetPoint('BOTTOMRIGHT', -5, 25)
    self.scrollBar:SetMinMaxValues(1, MAX)
    self.scrollBar:SetValueStep(STEP)
    self.scrollBar.scrollStep = SCROLL
    self.scrollBar:SetScript("OnValueChanged",
        function(self, value)
            settings.scrollFrame:SetVerticalScroll(value)
        end)

    self.scrollFrame = CreateFrame("ScrollFrame", 'DJBagsSettingsScreenScrollFrame', self.frame)
    self.scrollFrame:SetPoint('TOPLEFT', 5, -30)
    self.scrollFrame:SetPoint('BOTTOMRIGHT', self.scrollBar, 'BOTTOMLEFT', -5, -15)
    self.scrollBar:SetValue(1)

    self.scrollFrame:EnableMouseWheel(true)
    self.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = settings.scrollBar:GetValue()

        if IsShiftKeyDown() and (delta > 0) then
            settings.scrollBar:SetValue(0)
        elseif IsShiftKeyDown() and (delta < 0) then
            settings.scrollBar:SetValue(MAX)
        elseif (delta < 0) and (current < MAX) then
            settings.scrollBar:SetValue(math.min(current + 20, MAX))
        elseif (delta > 0) and (current > 1) then
            settings.scrollBar:SetValue(math.max(current - 20, 1))
        end
    end)

    self.content = CreateFrame("Frame", 'DJBagsSettingsScreenContent', self.scrollFrame)
    self.content:SetSize(self.scrollFrame:GetWidth(), 0)

    self.scrollFrame:SetScrollChild(self.content)

    self:CreateCategorySettings()
    self:CreateItemSettings()
    self:CreateContainerSettings()
    self:CreateItemContainerSettings()
    self:CreateCategoryContainerSettings()
    self:CreateMainBarSettings()

    self.settingsFrame = CreateFrame('FRAME', 'DJBagsSettingsOpenFrame', UIParent)
    self.settingsFrame.name = 'DJBags'
    self.settingsTextInfo = self.settingsFrame:CreateFontString('DJBagsSettingsInfo', 'OVERLAY', 'GameFontNormal')
    self.settingsTextInfo:SetPoint('CENTER')
    self.settingsTextInfo:SetText('In order to access DJBag\'s settings, please type:\n\n/db\n\nor\n\n/djbags\n\nin the game chat window.')
    InterfaceOptions_AddCategory(self.settingsFrame);

    return self.frame
end

function settings:AddSettingsPanel(panel)
    self.containers = self.containers or {}
    tinsert(self.containers, panel)
    panel:SetParent(self.content)
    panel:SetPoint('TOPLEFT', 0, -5 - self.content:GetHeight())
    panel:SetPoint('TOPRIGHT', 0, -5 - self.content:GetHeight())
    self.content:SetHeight(self.content:GetHeight() + panel:GetHeight() + 5)

    MAX = math.max(MAX, self.content:GetHeight() - self.scrollFrame:GetHeight())
    self.scrollBar:SetMinMaxValues(1, MAX)
end

local function CreateColorSelector(name, parent, getColor, callBack)
    local colourSelector = CreateFrame('BUTTON', 'DJBagsSettingsColourSelector' .. name .. ADDON.uuid(), parent)
    colourSelector:SetNormalFontObject("GameFontHighlight")
    colourSelector:SetText(name)
    colourSelector:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 2,
    })
    colourSelector:SetBackdropBorderColor(unpack(getColor()))
    colourSelector:SetBackdropColor(0, 0, 0, 1)
    colourSelector.call = callBack

    colourSelector:SetScript('OnClick', function(self)
        local r, g, b, a = unpack(getColor())

        local function callback(restore)
            local newR, newG, newB, newA = r, g, b, a;
            if not restore then
                newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
            end

            self:SetBackdropBorderColor(newR, newG, newB, newA)
            self.call(newR, newG, newB, newA)
        end

        ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback;
        ColorPickerFrame:SetColorRGB(r, g, b, a);
        ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
        ColorPickerFrame.previousValues = { r, g, b, a };
        ShowUIPanel(ColorPickerFrame)
    end)

    colourSelector:SetSize(150, 20)
    return colourSelector
end

local function round(num)
    if num >= 0 then return math.floor(num + .5)
    else return math.ceil(num - .5)
    end
end

local function CreateSlider(name, parent, min, max, value, callBack)
    local slider = CreateFrame('Slider', 'DJBagsSettingsColourSelector' .. name .. ADDON.uuid(), parent, 'OptionsSliderTemplate')
    getglobal(slider:GetName() .. "Text"):SetText(name .. ' - ' .. tostring(value()));
    getglobal(slider:GetName() .. "High"):SetText(max);
    getglobal(slider:GetName() .. "Low"):SetText(min);
    slider:SetMinMaxValues(min, max)
    slider:SetValue(value())
    slider:Show()

    slider:SetScript('OnValueChanged', function(self, value)
        value = round(value)
        callBack(value)
        getglobal(self:GetName() .. "Text"):SetText(name .. ' - ' .. tostring(value));
    end)

    return slider
end

local function CreateTitle(title, parent)
    parent.title = parent:CreateFontString('DJBagsSettingsScreenTitle' .. title .. ADDON.uuid(), nil, 'GameFontNormal')
    parent.title:SetText(title)
    parent.title:SetPoint('TOPLEFT', 5, -5)
end

local function CreateCheckBox(name, container, checked, callBack)
    local check = CreateFrame('CHECKBUTTON', 'DJBagsSettingsCheckButton' .. name .. ADDON.uuid(), container, 'UICheckButtonTemplate')
    _G[check:GetName() .. "Text"]:SetText(name)
    check.textW = _G[check:GetName() .. "Text"]:GetStringWidth()
    check.call = callBack
    check:SetChecked(checked)
    check:SetScript('OnClick', function(self)
        self.call(self:GetChecked())
    end)
    return check
end

function settings:CreateItemSettings()
    local container = ADDON.container('DJBagsSettingsItemScreen', nil)

    CreateTitle('Item settings', container)

    container.size = CreateSlider('Size', container, 18, 50, function()
        return ADDON.settings.item.size
    end, function(value)
        ADDON.settings.item.size = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.size:SetPoint('TOPLEFT', 10, -35)

    container:SetHeight(65)
    self:AddSettingsPanel(container)
end

function settings:CreateContainerSettings()
    local container = ADDON.container('DJBagsSettingsContainerScreen', nil)

    CreateTitle('Border and Background', container)

    container.borderPicker = CreateColorSelector('Border Colour', container, function()
        return ADDON.settings.container.borderColor
    end, function(r, g, b, a)
        ADDON.settings.container.borderColor = { r, g, b, a }
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.borderPicker:SetPoint('TOPLEFT', 5, -25)

    container.backgroundPicker = CreateColorSelector('Background Colour', container, function()
        return ADDON.settings.container.backgroundColor
    end, function(r, g, b, a)
        ADDON.settings.container.backgroundColor = { r, g, b, a }
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.backgroundPicker:SetPoint('TOPLEFT', container.borderPicker, 'TOPRIGHT', 15, 0)

    container.borderWidth = CreateSlider('Border Width', container, 1, 4, function()
        return ADDON.settings.container.borderWidth
    end, function(value)
        ADDON.settings.container.borderWidth = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.borderWidth:SetPoint('TOPLEFT', container.backgroundPicker, 'TOPRIGHT', 15, 0)

    container:SetHeight(55)
    self:AddSettingsPanel(container)
end

function settings:CreateItemContainerSettings()
    local container = ADDON.container('DJBagsSettingsItemContainerScreen', nil)

    CreateTitle('Category container settings', container)

    container.fontColor = CreateColorSelector('Font Colour', container, function()
        return ADDON.settings.itemContainer.fontColor
    end, function(r, g, b, a)
        ADDON.settings.itemContainer.fontColor = { r, g, b, a }
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.fontColor:SetPoint('TOPLEFT', 5, -25)

    container.fontSize = CreateSlider('Font size', container, 8, 18, function()
        return ADDON.settings.itemContainer.fontSize
    end, function(value)
        ADDON.settings.itemContainer.fontSize = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.fontSize:SetPoint('TOPLEFT', container.fontColor, 'TOPRIGHT', 15, 0)

    container.colsSlider = CreateSlider('Columns', container, 4, 10, function()
        return ADDON.settings.itemContainer.cols
    end, function(value)
        ADDON.settings.itemContainer.cols = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.colsSlider:SetPoint('TOPLEFT', container.fontSize, 'TOPRIGHT', 15, 0)

    container.padding = CreateSlider('Padding', container, 1, 10, function()
        return ADDON.settings.itemContainer.padding
    end, function(value)
        ADDON.settings.itemContainer.padding = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.padding:SetPoint('TOPLEFT', container.fontColor, 'BOTTOMLEFT', 2, -20)

    container.spacing = CreateSlider('Item Spacing', container, 1, 10, function()
        return ADDON.settings.itemContainer.spacing
    end, function(value)
        ADDON.settings.itemContainer.spacing = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.spacing:SetPoint('TOPLEFT', container.padding, 'TOPRIGHT', 15, 0)

    container:SetHeight(95)
    self:AddSettingsPanel(container)
end

function settings:CreateCategoryContainerSettings()
    local container = ADDON.container('DJBagsSettingsCategoryContainerScreen', nil)

    CreateTitle('Bag container settings', container)

    container.padding = CreateSlider('Padding', container, 1, 10, function()
        return ADDON.settings.categoryContainer.padding
    end, function(value)
        ADDON.settings.categoryContainer.padding = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.padding:SetPoint('TOPLEFT', 15, -35)

    container.spacing = CreateSlider('Container spacing', container, 1, 10, function()
        return ADDON.settings.categoryContainer.spacing
    end, function(value)
        ADDON.settings.categoryContainer.spacing = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.spacing:SetPoint('TOPLEFT', container.padding, 'TOPRIGHT', 15, 0)

    container.maxHeight = CreateSlider('Max height', container, 250, 1000, function()
        return ADDON.settings.categoryContainer.maxHeight
    end, function(value)
        ADDON.settings.categoryContainer.maxHeight = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end)
    container.maxHeight:SetPoint('TOPLEFT', container.spacing, 'TOPRIGHT', 15, 0)

    container:SetHeight(70)
    self:AddSettingsPanel(container)
end

function settings:CreateMainBarSettings()
    local container = ADDON.container('DJBagsSettingsMainBarScreen', nil)

    CreateTitle('Main Bar', container)

    container.currencyFontColor = CreateColorSelector('Currency Font Colour', container, function()
        return ADDON.settings.mainBar.currencyFontColor
    end, function(r, g, b, a)
        ADDON.settings.mainBar.currencyFontColor = { r, g, b, a }
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.currencyFontColor:SetPoint('TOPLEFT', 5, -25)

    container.slotFontColor = CreateColorSelector('Slot Font Colour', container, function()
        return ADDON.settings.mainBar.slotsFontColor
    end, function(r, g, b, a)
        ADDON.settings.mainBar.slotsFontColor = { r, g, b, a }
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.slotFontColor:SetPoint('TOPLEFT', container.currencyFontColor, 'TOPRIGHT', 15, 0)

    container.currencyFontSize = CreateSlider('Currency font size', container, 8, 18, function()
        return ADDON.settings.mainBar.currencyFontSize
    end, function(value)
        ADDON.settings.mainBar.currencyFontSize = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.currencyFontSize:SetPoint('TOPLEFT', container.slotFontColor, 'TOPRIGHT', 15, 0)

    container.slotFontSize = CreateSlider('Currency font size', container, 8, 18, function()
        return ADDON.settings.mainBar.slotsFontSize
    end, function(value)
        ADDON.settings.mainBar.slotsFontSize = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.slotFontSize:SetPoint('TOPLEFT', container.currencyFontColor, 'BOTTOMLEFT', 2, -20)

    container:SetHeight(95)
    self:AddSettingsPanel(container)
end

function settings:CreateCategorySettings()
    local container = ADDON.container('DJBagsSettingsMainBarScreen', nil)

    CreateTitle('Category Subclassing', container)

    function container:Add(item)
        self.items = self.items or {}
        tinsert(self.items, item)
    end

    container:Add(CreateCheckBox(AUCTION_CATEGORY_ARMOR, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_ARMOR], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_ARMOR] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_CONSUMABLES, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_CONSUMABLE], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_CONSUMABLE] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_GEMS, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_GEM], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_GEM] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_GLYPHS, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_GLYPH], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_GLYPH] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_ITEM_ENHANCEMENT, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_ITEM_ENHANCEMENT], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_ITEM_ENHANCEMENT] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_MISCELLANEOUS, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_MISCELLANEOUS], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_MISCELLANEOUS] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_RECIPES, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_RECIPE], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_RECIPE] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_TRADE_GOODS, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_TRADEGOODS], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_TRADEGOODS] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))
    container:Add(CreateCheckBox(AUCTION_CATEGORY_WEAPONS, container, ADDON.settings.categories.subClass[LE_ITEM_CLASS_WEAPON], function(value)
        ADDON.settings.categories.subClass[LE_ITEM_CLASS_WEAPON] = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
    end))

    local y = -20
    local x = 5
    if container.items then
        for _, item in pairs(container.items) do
            if x + item.textW > self.scrollFrame:GetWidth() - 10 then
                x = 5
                y = y - 30
            end
            item:SetPoint('TOPLEFT', x, y)
            x = x + item.textW + 35
        end
    end

    container:SetHeight(35 - y)
    self:AddSettingsPanel(container)
end