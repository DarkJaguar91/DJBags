local ADDON_NAME, ADDON = ...

local dialog = {}

function DJBagsCategoryDialogLoad(self)
	for k, v in pairs(dialog) do
        self[k] = v
    end

    self:Init()
end

function dialog:Init()
    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)
    self:SetUserPlaced(true)

    _G[self.allCharacters:GetName() .. 'Text']:SetText(ADDON.locale.ALL_CHARACTERS)
end

local function DropDownClick(self)
    UIDropDownMenu_SetSelectedID(DJBagsCategoryDialog.dropdown, self:GetID())
    DJBagsCategoryDialog.edit:SetText(self.value)
end

function dialog:DisplayForItem(id, name)
	self.name:SetText(name)
	self.id = id
	self:Show()

    local current = DJBags_DB_Char.categories[id] or DJBags_DB.categories[id]
    local categories = ADDON:GetAllPlayerDefinedCategories()

    UIDropDownMenu_Initialize(self.dropdown, function(self, level)
        if next(categories) ~= nil then
            local info
            for _, k in pairs(categories) do
                info = UIDropDownMenu_CreateInfo()
                info.text = k
                info.value = k
                info.func = DropDownClick
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    if current then
        self.edit:SetText(current)
        self.allCharacters:SetChecked(DJBags_DB.categories[id])
        for i=1,#categories do
            if categories[i] == current then
                UIDropDownMenu_SetSelectedID(self.dropdown, i)
            end
        end
    else
        self.edit:SetText('')
        self.allCharacters:SetChecked(false)
        UIDropDownMenu_SetSelectedID(self.dropdown, 0)
    end

    self.edit:SetFocus()
end

function dialog:Reset()
    local global = self.allCharacters:GetChecked()

    if global then
        DJBags_DB.categories[self.id] = nil
    else
        DJBags_DB_Char.categories[self.id] = nil
    end
    self:Hide()
    self:RefreshBags()
end

function dialog:Done()
    local global = self.allCharacters:GetChecked()
    local text = self.edit:GetText()

    if global then
        DJBags_DB.categories[self.id] = text
    else
        DJBags_DB_Char.categories[self.id] = text
    end

    self:Hide()
    self:RefreshBags()
end

function dialog:RefreshBags()
    if (DJBagsBag:IsVisible()) then
        DJBagsBag:Refresh()
    end
    if (DJBagsBank:IsVisible()) then
        DJBagsBank:Refresh()
    end
    if (DJBagsReagents:IsVisible()) then
        DJBagsReagents:Refresh()
    end
end
