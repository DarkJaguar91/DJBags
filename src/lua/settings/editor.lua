local NAME, ADDON = ...

local STEP = 1
local SCROLL = 1
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
    print('asd')
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
    self.scrollFrame:SetPoint('BOTTOMRIGHT', self.scrollBar, 'BOTTOMLEFT', -5, 0)
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

    self:CreateContainerSettings()
    self:CreateItemContainerSettings()

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
    local colourSelector = CreateFrame('BUTTON', 'DJBagsSettingsColourSelector' .. name, parent)
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

local function CreateSlider(parent, name, min, max, value, callBack)
    local slider = CreateFrame('Slider', name .. 'slider', parent, 'OptionsSliderTemplate')
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
    parent.title = parent:CreateFontString('DJBagsSettingsScreenTitle' .. title, nil, 'GameFontNormal')
    parent.title:SetText(title)
    parent.title:SetPoint('TOPLEFT', 5, -5)
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

    container.borderWidth = CreateSlider(container, 'Border Width', 1, 4, function()
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

    container.fontSize = CreateSlider(container, 'Font size', 8, 18, function()
        return ADDON.settings.itemContainer.fontSize
    end, function(value)
        ADDON.settings.itemContainer.fontSize = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.fontSize:SetPoint('TOPLEFT', container.fontColor, 'TOPRIGHT', 15, 0)

    container.colsSlider = CreateSlider(container, 'Columns', 4, 10, function()
        return ADDON.settings.itemContainer.cols
    end, function(value)
        ADDON.settings.itemContainer.cols = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.colsSlider:SetPoint('TOPLEFT', container.fontSize, 'TOPRIGHT', 15, 0)

    container.padding = CreateSlider(container, 'Padding', 1, 10, function()
        return ADDON.settings.itemContainer.padding
    end, function(value)
        ADDON.settings.itemContainer.padding = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.padding:SetPoint('TOPLEFT', container.fontColor, 'BOTTOMLEFT', 2, -20)

    container.spacing = CreateSlider(container, 'Item Spacing', 1, 10, function()
        return ADDON.settings.itemContainer.spacing
    end, function(value)
        ADDON.settings.itemContainer.spacing = value
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE')
    end)
    container.spacing:SetPoint('TOPLEFT', container.padding, 'TOPRIGHT', 15, 0)

    container:SetHeight(95)
    self:AddSettingsPanel(container)
end