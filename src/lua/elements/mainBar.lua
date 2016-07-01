local NAME, ADDON = ...

ADDON.mainBar = {}
ADDON.mainBar.__index = ADDON.mainBar

local bar = ADDON.mainBar
setmetatable(bar, {
    __call = function(tbl, parent)
        local container = ADDON.container('DJBagsMoneyBar', parent)

        for k, v in pairs(tbl) do
            container[k] = v
        end

        container:Init()
        container:Setup()

        return container
    end
})

function bar:Init()
    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self, ...)
        if self:GetParent() then
            self:GetParent():StartMoving(...)
        end
    end)
    self:SetScript("OnDragStop", function(self, ...)
        if self:GetParent() then
            self:GetParent():StopMovingOrSizing(...)
        end
    end)

    self.currencyBox = CreateFrame('FRAME', 'DJBagsMainBarCurrencyBox', self)
    self.currency = self.currencyBox:CreateFontString('DJBagMainBarCurrencyText', 'OVERLAY')
    self.currency:SetAllPoints()
    self.currencyBox:SetPoint('TOPLEFT', 5, -5)
    self.currencyBox:SetPoint('BOTTOMLEFT', 5, 5)
    self.searchBox = CreateFrame('EDITBOX', 'DJBagsMainBarSearch', self, 'BagSearchBoxTemplate')
    self.searchBox:SetPoint('TOPLEFT', self.currencyBox, 'TOPRIGHT', 10, 0)
    self.searchBox:SetPoint('BOTTOMLEFT', self.currencyBox, 'BOTTOMRIGHT', 10, 0)
    self.searchBox:SetWidth(125)
    self.slots = self:CreateFontString('DJBagMainBarSlotsText', 'OVERLAY')
    self.slots:SetPoint('TOPLEFT', self.searchBox, 'TOPRIGHT', 5, 0)
    self.slots:SetPoint('BOTTOMLEFT', self.searchBox, 'BOTTOMRIGHT', 5, 0)

    self.currencyBox:SetScript('OnEnter', function()
        local cnt = GetCurrencyListSize()
        GameTooltip:SetOwner(self.currencyBox, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOMLEFT", self.currencyBox, "TOPLEFT")
        GameTooltip:SetText("Currency")
        for index = 1, cnt do
            local name, _, _, _, _, count, texture, _, _, _, _ = GetCurrencyListInfo(index)
            if count ~= 0 and texture ~= nil then
                GameTooltip:AddDoubleLine(name, count .. " |T" .. texture .. ":16|t", 1, 1, 1, 1, 1, 1)
            end
        end
        GameTooltip:Show()
    end)

    self.currencyBox:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
end

function bar:Setup()
    ADDON.container.Setup(self)

    local settings = ADDON.settings.mainBar
    self.currency:SetFont(settings.currencyFont, settings.currencyFontSize, '')
    self.currency:SetTextColor(unpack(settings.currencyFontColor))
    self.slots:SetFont(settings.slotsFont, settings.slotsFontSize, '')
    self.slots:SetTextColor(unpack(settings.slotsFontColor))
end

function bar:Update()
    self.currency:SetText(GetCoinTextureString(GetMoney()))

    local total, free = 0, 0
    for bag = 0, NUM_BAG_SLOTS do
        total = total + GetContainerNumSlots(bag)
        free = free + GetContainerNumFreeSlots(bag)
    end
    self.slots:SetText(string.format("%d/%d", total - free, total))

    self.currencyBox:SetWidth(self.currency:GetStringWidth())
    self:SetSize(self.currency:GetStringWidth() + self.slots:GetStringWidth() + 165, math.max(self.currency:GetStringHeight(), self.slots:GetStringHeight()) + 12)
end
