local NAME, ADDON = ...

ADDON.bagBar = {}
ADDON.bagBar.__index = ADDON.bagBar

local bar = ADDON.bagBar
setmetatable(bar, {
    __call = function(self, parent)
        local frame = ADDON.container('DJBagsBagBar', parent)

        for k, v in pairs(self) do
            frame[k] = v
        end

        frame:Init()
        frame:Setup()

        return frame
    end
})

function bar:Init()
    self.bag1 = ADDON.bagItem('DJBagsBag0', 1, GetInventorySlotInfo("Bag0Slot"))
    self.bag1:SetParent(self)
    self.bag2 = ADDON.bagItem('DJBagsBag1', 2, GetInventorySlotInfo("Bag1Slot"))
    self.bag2:SetParent(self)
    self.bag3 = ADDON.bagItem('DJBagsBag2', 3, GetInventorySlotInfo("Bag2Slot"))
    self.bag3:SetParent(self)
    self.bag4 = ADDON.bagItem('DJBagsBag3', 4, GetInventorySlotInfo("Bag3Slot"))
    self.bag4:SetParent(self)
end

function bar:Setup()
    ADDON.container.Setup(self)

    self.bag1:SetPoint("TOPRIGHT", -5, -5)
    self.bag2:SetPoint("TOPRIGHT", self.bag1, 'TOPLEFT', -5, 0)
    self.bag3:SetPoint("TOPRIGHT", self.bag2, 'TOPLEFT', -5, 0)
    self.bag4:SetPoint("TOPRIGHT", self.bag3, 'TOPLEFT', -5, 0)

    self:SetSize(self.bag1:GetWidth() * 4 + 25, 10 + self.bag1:GetHeight())
end

function bar:Update()
    self.bag1:Update()
    self.bag2:Update()
    self.bag3:Update()
    self.bag4:Update()
end

function bar:UpdateLock(bag)
    if bag == self.bag1:GetID() then
        self.bag1:UpdateLock()
    elseif bag == self.bag2:GetID() then
        self.bag2:UpdateLock()
    elseif bag == self.bag3:GetID() then
        self.bag3:UpdateLock()
    elseif bag == self.bag4:GetID() then
        self.bag4:UpdateLock()
    end
end