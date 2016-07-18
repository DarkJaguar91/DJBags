local NAME, ADDON = ...

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function DJBagsInitSettingsSlider(slider, name, min, max, step, type, setting)
    local value = ADDON.settings:GetSettings(type)[setting]

    _G[slider:GetName() .. 'Text']:SetText(tostring(name) .. ' - ' .. value)
    _G[slider:GetName() .. 'Low']:SetText(tostring(min))
    _G[slider:GetName() .. 'High']:SetText(tostring(max))
    slider:SetMinMaxValues(min, max)
    slider.type = type
    slider.setting = setting
    slider.name = name

    slider:SetValue(value)
    slider:SetValueStep(step)
end

function DJBagsSettingsSlider_OnChange(self, value)
    _G[self:GetName() .. 'Text']:SetText(tostring(self.name) .. ' - ' .. round(value, 1))
    ADDON.settings:SetSettings(self.type, self.setting, value, true)
end

function DJBagsInitSettingsColorPicker(picker, type, setting)
    picker.type = type
    picker.setting = setting

    picker:SetBackdropColor(unpack(ADDON.settings:GetSettings(type)[setting]))
end

function DJBagsSettingsColorPicker_OnClick(self)
    local r, g, b, a = self:GetBackdropColor()

    local function callback(restore)
        local newR, newG, newB, newA = r, g, b, a;
        if not restore then
            newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
        end

        local out = { newR, newG, newB, newA }
        self:SetBackdropColor(unpack(out))

        ADDON.settings:SetSettings(self.type, self.setting, out)
    end

    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback;
    ColorPickerFrame:SetColorRGB(r, g, b, a);
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = { r, g, b, a };
    ShowUIPanel(ColorPickerFrame)
end