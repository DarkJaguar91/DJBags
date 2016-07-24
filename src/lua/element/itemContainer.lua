local NAME, ADDON = ...


local container = {}

function ADDON:NewItemContainer(name, parent)
    local frame = CreateFrame('Frame', 'DJBagsItemContainer_' .. name, parent or UIParent, 'DJBagsItemContainerTemplate')

    ADDON:CreateAddon(frame, container, name)

    return frame
end

function container:Init(name)
    self.__type = DJBags_TYPE_ITEM_CONTAINER

    if string.match(name, '%a*_%a*') then
        local txt = string.match(name, '%a*_(%a*)')
        self.name:SetText(txt)
    else
        self.name:SetText(name)
    end
    self.name:SetMaxLines(1)
    self.name.text = name
    self.items = {}

    self:UpdateFromSettings()
    self.container:EnableMouse(false)
end

function container:UpdateFromSettings()
    local settings = ADDON.settings:GetSettings(self.__type)

    self:SetTitleSize(settings[DJBags_SETTING_TEXT_SIZE])
    self:SetColors(
        settings[DJBags_SETTING_BACKGROUND_COLOR],
        settings[DJBags_SETTING_BORDER_COLOR]
    )
    self:SetTextColor(settings[DJBags_SETTING_TEXT_COLOR])
    self:SetPadding(settings[DJBags_SETTING_PADDING])
    self:SetSpacing(settings[DJBags_SETTING_SPACING])
end

function container:SetTitleSize(size)
    local font, _, outline = self.name:GetFont()
    self.name:SetFont(font, size, outline)
    self.name:SetHeight(size)
end

function container:SetPadding(padding)
    self.container:ClearAllPoints()
    self.padding = padding

    self.container:SetPoint('TOPLEFT', self.name, 'BOTTOMLEFT', padding, -5)
    self.container:SetPoint('BOTTOMRIGHT', -padding, padding)
end

function container:SetTextColor(color)
    self.name:SetVertexColor(unpack(color))
end

function container:SetSize(width, height)
    local index = getmetatable(self).__index

    height = height + self.name:GetHeight() + 10

    index.SetSize(self, width, height)
end

function container:AddItem(item)
    self.items[item] = true
    if item:GetParent() ~= self.container then
        item:SetParent(self.container)
    end

    self.arranged = nil
end

function container:RemoveItem(item)
    self.items[item] = nil
    item:SetParent(nil)

    self.arranged = nil
end

function container:IsEmpty()
    return next(self.items) == nil
end

function container:GetCount()
    return ADDON:Count(self.items)
end

function container:Arrange(max, vert, maxCnt, override, forceSize)
    if override then
        self.arrange = nil
    end
    ADDON:ArrangeItemContainer(self, max, vert, maxCnt, forceSize)
end