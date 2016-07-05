local NAME, ADDON = ...

ADDON.categoryDialog = {}
ADDON.categoryDialog.__index = ADDON.categoryDialog

local dialog = ADDON.categoryDialog
setmetatable(dialog, {
    __call = function(self, id)
        self:Show(id)
    end
})

function dialog:Show(id)
    if not id then return end

    local frame = self:GetFrame(id)
    self.id = id
    frame:Show()
    self.editBox:SetFocus()
end

function dialog:GetFrame(id)
    if not self.frame then
        self:CreateFrame()
    end

    self.frame:Setup()

    self:Init(id)
    return self.frame
end

function OnDropDownClick(self)
    UIDropDownMenu_SetSelectedID(dialog.dropDown, self:GetID())
    dialog:SetText(self.value)
end

function InitDropDown(self, level)
    local unique = {}
    for _, v in pairs(ADDON.settings.categories.userDefined) do
        unique[v] = true
    end

    if next(unique) ~= nil then
        local info
        for k, _ in pairs(unique) do
            info = UIDropDownMenu_CreateInfo()
            info.text = k
            info.value = k
            info.func = OnDropDownClick
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function dialog:Init(id)
        local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)

    self.title:SetText(string.format('Change %s\'s category?', name))
    -- TODO add texture

    UIDropDownMenu_Initialize(self.dropDown, InitDropDown)
    self.errorText:Hide()
    local text = ADDON.settings.categories.userDefined[id] or ''
    self:SetText(text)

    self.frame:SetHeight(75 + self.title:GetStringHeight())
end

function dialog:Setup()
    if self.frame then
        self.frame:Setup()
    end
end

function dialog:SetText(text)
    self.editBox:SetText(text)
end

function dialog:CreateFrame()
    self.frame = ADDON.container('DJBagsCategoryDialog')
    self.frame:SetPoint('CENTER')
    table.insert(UISpecialFrames, self.frame:GetName())

    self.title = self.frame:CreateFontString('DJBagsCategoryDialogTitle', 'OVERLAY')
    self.title:SetFont('Fonts\\FRIZQT__.TTF', 18, 'OUTLINE')
    self.title:SetTextColor(1, 1, 1, 1)
    self.title:SetPoint("TOPLEFT", 5, -5)
    self.title:SetPoint("TOPRIGHT", -5, -5)

    self.editBox = CreateFrame('EDITBOX', 'DJBagsCategoryDialogEdit', self.frame)
    self.editBox:SetHeight(20)
    self.editBox:SetFontObject("GameFontHighlight")
    self.editBox:SetPoint('TOPLEFT', self.title, 'BOTTOMLEFT', 0, -15)
    self.editBox:SetPoint('TOPRIGHT', self.frame, 'RIGHT', -140, 0)
    self.editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    })
    self.editBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    self.editBox:SetBackdropColor(0, 0, 0, 0)
    self.editBox:SetScript('OnEnterPressed', function()
        dialog.okBtn:Click()
    end)
    self.editBox:SetScript('OnEscapePressed', function()
        dialog.frame:Hide()
    end)

    self.errorText = self.frame:CreateFontString('DJBagsCategoryDialogTitle', 'OVERLAY')
    self.errorText:SetFont('Fonts\\FRIZQT__.TTF', 18, 'OUTLINE')
    self.errorText:SetTextColor(1, 0, 0, 1)
    self.errorText:SetPoint("TOPRIGHT", self.editBox, 'TOPLEFT', -5, 0)
    self.errorText:SetText('A Category name needs to be entered!')
    self.errorText:Hide()

    self.dropDown = CreateFrame("Button", "DJBagsCategoryDialogDropDown", self.frame, "UIDropDownMenuTemplate")
    self.dropDown:SetPoint('LEFT', self.editBox, 'RIGHT')
    UIDropDownMenu_SetWidth(self.dropDown, 100);
    UIDropDownMenu_SetButtonWidth(self.dropDown, 124)
    UIDropDownMenu_JustifyText(self.dropDown, "LEFT")

    self.resetBtn = CreateFrame('BUTTON', 'DJBagsCategoryDialogResetButton', self.frame)
    self.resetBtn:SetNormalFontObject("GameFontHighlight")
    self.resetBtn:SetSize(75, 20)
    self.resetBtn:SetText(RESET)
    self.resetBtn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    })
    self.resetBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    self.resetBtn:SetBackdropColor(0, 0, 0, 0)
    self.resetBtn:SetPoint('BOTTOMLEFT', self.frame, 'BOTTOMLEFT', 5, 5)
    self.resetBtn:SetScript('OnClick', function()
        ADDON.settings.categories.userDefined[dialog.id] = nil
        ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
        dialog.frame:Hide()
    end)

    self.okBtn = CreateFrame('BUTTON', 'DJBagsCategoryDialogOkButton', self.frame)
    self.okBtn:SetNormalFontObject("GameFontHighlight")
    self.okBtn:SetSize(75, 20)
    self.okBtn:SetText(DONE)
    self.okBtn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    })
    self.okBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    self.okBtn:SetBackdropColor(0, 0, 0, 0)
    self.okBtn:SetPoint('BOTTOMRIGHT', self.frame, 'BOTTOMRIGHT', -5, 5)
    self.okBtn:SetScript('OnClick', function()
        local text = dialog.editBox:GetText()
        dialog.errorText:Hide()
        if not text or text ~= '' then
            ADDON.settings.categories.userDefined[dialog.id] = text
            ADDON.eventManager:FireEvent('SETTINGS_UPDATE', true)
            dialog.frame:Hide()
        else
            dialog.errorText:Show()
        end
    end)

    self.cancelBtn = CreateFrame('BUTTON', 'DJBagsCategoryDialogCancelButton', self.frame)
    self.cancelBtn:SetNormalFontObject("GameFontHighlight")
    self.cancelBtn:SetSize(75, 20)
    self.cancelBtn:SetText(CANCEL)
    self.cancelBtn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    })
    self.cancelBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    self.cancelBtn:SetBackdropColor(0, 0, 0, 0)
    self.cancelBtn:SetPoint('TOPRIGHT', self.okBtn, 'TOPLEFT', -5, 0)
    self.cancelBtn:SetScript('OnClick', function()
        dialog.frame:Hide()
    end)

    self.frame:SetSize(350, 90)
end

