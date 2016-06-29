local NAME, ADDON = ...

ADDON.bag = {}
ADDON.bag.__index = ADDON.bag

local bag = ADDON.bag

function bag:Init()
    self.frame = ADDON.categoryContainer('DJBagsBagCategoryContainer', UIParent)
    self.frame:SetPoint('BOTTOMRIGHT', -200, 200)
    self.frame:SetUserPlaced(true)
    self.frame:Hide()
    self.frame.mainBar = ADDON.mainBar(self.frame)
    self.frame.mainBar:SetPoint('TOPRIGHT', self.frame, 'BOTTOMRIGHT', 0, -2)
    self.frame.mainBar:Show()
end

function bag:Open()
    self:Register()
    self:UpdateAllItems()
    self.frame.mainBar:Update()
    self.frame:Show()
end

function bag:Close()
    self:UnRegister()
    self.frame:Hide()
end

function bag:Toggle()
    if self.frame:IsVisible() then
        self:Close()
    else
        self:Open()
    end
end

local function UpdateItemsForBag(self, bag, arrangeList)
    for slot = 1, GetContainerNumSlots(bag) do
        local item = ADDON.cache:GetItem(bag, slot)
        local previousContainer
        if item:GetParent() and item:GetParent().__class == ADDON.itemContainer.__class then
            previousContainer = item:GetParent()
        end

        item:Update()

        local newContainer = ADDON.cache:GetBagItemContainer(ADDON.utils:GetItemContainerName(bag, slot))
        self.frame:AddContainer(newContainer)

        if previousContainer ~= newContainer then
            if previousContainer then
                previousContainer:RemoveItem(item)
                arrangeList[previousContainer] = true
            end
            newContainer:AddItem(item)
            arrangeList[newContainer] = true
        end
    end
end

function bag:UpdateAllItems()
    local arrangeList = {}
    for bag = 0, NUM_BAG_SLOTS do
        UpdateItemsForBag(self, bag, arrangeList)
    end
    for container, _ in pairs(arrangeList) do
        container:Arrange()
    end
    self.frame:Arrange()
end

function bag:UpdateAllItemsForBag(bag)
    local arrangeList = {}
    UpdateItemsForBag(self, bag, arrangeList)
    for container, _ in pairs(arrangeList) do
        container:Arrange()
    end
    self.frame:Arrange()
end

function bag:Register()
    ADDON.eventManager:AddEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:AddEvent(self, 'ITEM_LOCK_CHANGED')
end

function bag:UnRegister()
    ADDON.eventManager:RemoveEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:RemoveEvent(self, 'ITEM_LOCK_CHANGED')
end

function bag:BAG_UPDATE(bag)
    if bag >= 0 and bag <= NUM_BAG_SLOTS then
        self:UpdateAllItemsForBag(bag)
    end
end

function bag:INVENTORY_SEARCH_UPDATE()
    for bag = 0, NUM_BAG_SLOTS do
        for _, item in pairs(ADDON.cache:GetItemsForBag(bag)) do
            item:UpdateSearch()
        end
    end
end

function bag:BAG_UPDATE_COOLDOWN()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = ADDON.cache:GetItem(bag, slot)
            item:UpdateCooldown()
        end
    end
end

function bag:ITEM_LOCK_CHANGED(bag, slot)
    if bag >= 0 and bag <= NUM_BAG_SLOTS then
        ADDON.cache:GetItem(bag, slot):UpdateLock()
    end
end