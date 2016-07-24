local NAME, ADDON = ...


local container = {}

function DJBagsContainerLoad(self)
    ADDON:CreateAddon(self, container)
end

function container:Init()
    self.__type = DJBags_TYPE_CONTAINER

    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self, ...)
        if self:GetParent() == UIParent then
            self:StartMoving()
        elseif self:GetParent():IsMovable() then
            self:GetParent():StartMoving(...)
        end
    end)
    self:SetScript("OnDragStop", function(self, ...)
        if self:GetParent() == UIParent then
            self:StopMovingOrSizing(...)
        elseif self:GetParent():IsMovable() then
            self:GetParent():StopMovingOrSizing(...)
        end
    end)
    if self:GetParent() == UIParent then
        self:SetUserPlaced(true)
    end

    self:SetColors(
        {0, 0, 0, 0.6},
        {0.3, 0.3, 0.3, 1}
    )

    self:SetPadding(5)
    self:SetSpacing(5)

    self.items = {}
end

function container:UpdateFromSettings()
    local settings = ADDON.settings:GetSettings(self.__type)

    self:SetColors(
        settings[DJBags_SETTING_BACKGROUND_COLOR],
        settings[DJBags_SETTING_BORDER_COLOR]
    )
    self:SetPadding(settings[DJBags_SETTING_PADDING])
    self:SetSpacing(settings[DJBags_SETTING_SPACING])
end

function container:SetPadding(padding)
    self.container:ClearAllPoints()
    self.padding = padding

    self.container:SetPoint('TOPLEFT', padding, -padding)
    self.container:SetPoint('BOTTOMRIGHT', -padding, padding)
end

function container:SetSpacing(spacing)
    self.spacing = spacing
end

function container:SetColors(background, border)
    self:SetBackdropColor(unpack(background))
    self:SetBackdropBorderColor(unpack(border))
end

function container:AddItem(item)
    self.items[item] = true

    if item:GetParent() ~= self.container then
        item:SetParent(self.container)
    end
end

function container:Arrange(override)
    ADDON.format[ADDON.settings:GetSettings(self.__type)[DJBags_SETTING_FORMATTER]](
        self,
        ADDON.settings:GetSettings(self.__type)[DJBags_SETTING_FORMATTER_MAX_ITEMS],
        ADDON.settings:GetSettings(self.__type)[DJBags_SETTING_FORMATTER_MAX_HEIGHT],
        ADDON.settings:GetSettings(self.__type)[DJBags_SETTING_FORMATTER_BOX_COLS],
        ADDON.settings:GetSettings(self.__type)[DJBags_SETTING_FORMATTER_VERT],
        override == 2
    )
end