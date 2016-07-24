local NAME, ADDON = ...

local container = {}

function DJBagsMainBarLoad(self)
    ADDON:CreateAddon(self, container)
end

function container:Init()
    self.__type = DJBags_TYPE_MAIN_BAR

    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    self:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)

    self:SetColors(
        {0, 0, 0, 0.6},
        {0.3, 0.3, 0.3, 1}
    )

    self:Show()
end

function container:UpdateFromSettings()
    local settings = ADDON.settings:GetSettings(self.__type)

    self:SetColors(
        settings[DJBags_SETTING_BACKGROUND_COLOR],
        settings[DJBags_SETTING_BORDER_COLOR]
    )
end

function container:SetColors(background, border)
    self:SetBackdropColor(unpack(background))
    self:SetBackdropBorderColor(unpack(border))
end