local NAME, ADDON = ...

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function DJBagsInitSettingsSlider(slider, name, min, max, step, type, setting, noDeciaml)
    local value = ADDON.settings:GetSettings(type)[setting]

    _G[slider:GetName() .. 'Text']:SetText(tostring(name) .. ' - ' .. value)
    _G[slider:GetName() .. 'Low']:SetText(tostring(min))
    _G[slider:GetName() .. 'High']:SetText(tostring(max))
    slider:SetMinMaxValues(min, max)
    slider.type = type
    slider.setting = setting
    slider.name = name
    slider.noDecimal = noDeciaml

    local onChange = slider:GetScript('OnValueChanged')
    slider:SetScript('OnValueChanged', nil)
    slider:SetValue(value)
    slider:SetValueStep(step)
    slider:SetScript('OnValueChanged', onChange)
end

function DJBagsSettingsSlider_OnChange(self, value)
    _G[self:GetName() .. 'Text']:SetText(tostring(self.name) .. ' - ' .. round(value, self.noDecimal and 0 or 1))
    value = self.noDecimal and round(value, 0) or value
    ADDON.settings:SetSettings(self.type, self.setting, value, 1)
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

function DJBagsInitSettingsCheckBox(checkbox, name, type, setting, arrangeType)
    checkbox.type = type
    checkbox.setting = setting
    checkbox.arrangeType = arrangeType

    _G[checkbox:GetName() .. "Text"]:SetText(name)

    checkbox:SetChecked(ADDON.settings:GetSettings(type)[setting])
end

function DJBagsSettingsCheckBox_OnChange(checkbox, checked)
    ADDON.settings:SetSettings(checkbox.type, checkbox.setting, checked, checkbox.arrangeType)
end

function DJBagsCategoryDialogLoad(id, name)
    DJBagsCategoryDialog:Show()
    DJBagsCategoryDialog.name:SetText(string.format(DJBags_LOCALE_CATEGORY_DIALOG_TITLE, name))
    DJBagsCategoryDialog.id = id

    local userDefined = ADDON.settings:GetUserDefinedList()
    local globalDefined = ADDON.settings:GetGlobalUserDefinedList()
    local current = userDefined[id] or globalDefined[id]

    if current then
        DJBagsCategoryDialog.edit:SetText(current)
        DJBagsCategoryDialog.global:SetChecked(userDefined[id] == nil)
    else
        DJBagsCategoryDialog.edit:SetText('')
        DJBagsCategoryDialog.global:SetChecked(false)
    end
    DJBagsCategoryDialog.edit:SetFocus()

    UIDropDownMenu_Initialize(DJBagsCategoryDialog.dropdown, function(self, level)
        local unique = {}
        for _, v in pairs(ADDON.settings:GetUserDefinedList()) do
            unique[v] = true
        end
        for _, v in pairs(ADDON.settings:GetGlobalUserDefinedList()) do
            unique[v] = true
        end

        if next(unique) ~= nil then
            local info
            for k, _ in pairs(unique) do
                info = UIDropDownMenu_CreateInfo()
                info.text = k
                info.value = k
                info.func = DJBagsCategoryDialog_DropDownClick
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
end

function DJBagsCategoryDialog_DropDownClick(self)
    UIDropDownMenu_SetSelectedID(DJBagsCategoryDialog.dropdown, self:GetID())
    DJBagsCategoryDialog.edit:SetText(self.value)
end

function DJBagsCategoryDialog_Done()
    local global = DJBagsCategoryDialog.global:GetChecked()
    local text = DJBagsCategoryDialog.edit:GetText()
    if text and text ~= '' then
        if global then
            ADDON.settings:AddGlobalDefinedItem(DJBagsCategoryDialog.id, text)
        else
            ADDON.settings:AddUserDefinedItem(DJBagsCategoryDialog.id, text)
        end
        DJBagsCategoryDialog:Hide()
    end
end

function DJBagsCategoryDialog_Clear()
    ADDON.settings:ClearUserDefinedItem(DJBagsCategoryDialog.id)
    DJBagsCategoryDialog:Hide()
end

function DJBagsFormatSettings_OnLoad(self)
    local type = ADDON.settings:GetSettings(DJBags_TYPE_CONTAINER)[DJBags_SETTING_FORMATTER]
    function self:ShowContainer(type)
        if type == 1 then
            self.masonry:Show()
            self.box:Hide()
        else
            self.masonry:Hide()
            self.box:Show()
        end
    end
    self:ShowContainer(type)

    UIDropDownMenu_Initialize(self.dropdown, function(_, level)
        local unique = {
            DJBags_LOCALE_MASONRY,
            DJBags_LOCALE_BOX
        }

        local cnt = 0
        local info
        for _, k in pairs(unique) do
            cnt = cnt + 1
            info = UIDropDownMenu_CreateInfo()
            info.text = k
            info.value = cnt
            info.func = function(item)
                ADDON.settings:SetSettings(DJBags_TYPE_CONTAINER, DJBags_SETTING_FORMATTER, item.value, 2)
                self:ShowContainer(item.value)
                UIDropDownMenu_SetSelectedID(self.dropdown, item.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedID(self.dropdown, type)
end