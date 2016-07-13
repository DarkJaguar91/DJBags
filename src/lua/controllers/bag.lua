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
    self.frame.bagBar = ADDON.bagBar(self.frame)
    self.frame.bagBar:SetPoint('TOPRIGHT', self.frame.mainBar, 'BOTTOMRIGHT', 0, -3)
    self.frame.mainBar:SetBagFrame(self.frame.bagBar)

    self.frame:HookScript('OnShow', function()
        self:Register()
    end)
    self.frame:HookScript('OnHide', function()
        self:UnRegister()
        if ADDON.settings.auto.clearNewItems then
            C_NewItems.ClearAll()
        end
    end)

    ADDON.eventManager:AddEvent(self, 'MERCHANT_SHOW')
end

function bag:MERCHANT_SHOW()
    if ADDON.settings.auto.sellJunk then
        local price = 0
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1 , GetContainerNumSlots(bag) do
                if select(4, GetContainerItemInfo(bag, slot)) == LE_ITEM_QUALITY_POOR then
                    ShowMerchantSellCursor(1)
                    UseContainerItem(bag, slot)
                    price = price + select(11, GetItemInfo(GetContainerItemID(bag, slot)))
                end
            end
        end
        ResetCursor()
        DEFAULT_CHAT_FRAME:AddMessage("Sold junk for: " .. GetCoinTextureString(price))
    end
end

function bag:Open()
    self:UpdateAllItems()
    self.frame.mainBar:Update()
    self.frame.bagBar:Update()
    self.frame:Show()
end

function bag:Close()
    self.frame:Hide()
end

function bag:Toggle()
    if self.frame:IsVisible() then
        self:Close()
    else
        self:Open()
    end
end

function bag:NewItemsUpdated()
    if self.frame:IsVisible() then
        self:UpdateAllItems()
    end
end

function bag:UpdateAllItems()
    for bag = 0, NUM_BAG_SLOTS do
        ADDON.utils:UpdateItemsForBag(self.frame, bag, ADDON.cache.GetBagItemContainer)
    end
    self:CheckForRemovedItems()
    self.frame:Arrange()
end

function bag:UpdateAllItemsForBag(bag)
    ADDON.utils:UpdateItemsForBag(self.frame, bag, ADDON.cache.GetBagItemContainer)
    self:CheckForRemovedItems()
    self.frame:Arrange()
end

function bag:Register()
    ADDON.eventManager:AddEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:AddEvent(self, 'ITEM_LOCK_CHANGED')
    ADDON.eventManager:AddEvent(self, 'PLAYER_MONEY')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE_DELAYED')
end

function bag:UnRegister()
    ADDON.eventManager:RemoveEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:RemoveEvent(self, 'ITEM_LOCK_CHANGED')
    ADDON.eventManager:RemoveEvent(self, 'PLAYER_MONEY')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE_DELAYED')
end

function bag:UpdateSettings(arrange)
    self.frame:Setup()
    self.frame.mainBar:Setup()
    self.frame.mainBar:Update()
    self.frame.bagBar:Setup()
    if self.frame:IsVisible() and arrange then
        self:Open()
    end
end

function bag:PLAYER_MONEY()
    self.frame.mainBar:Update()
end

function bag:BAG_UPDATE(bag)
    if bag >= 0 and bag <= NUM_BAG_SLOTS then
        self:UpdateAllItemsForBag(bag)
    end
end

function bag:INVENTORY_SEARCH_UPDATE()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = ADDON.cache:GetItem(bag, slot)
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
    if bag then
        if bag >= 0 and bag <= NUM_BAG_SLOTS and slot then
            ADDON.cache:GetItem(bag, slot):UpdateLock()
        end
        self.frame.bagBar:UpdateLock(bag)
    end
end

function bag:BAG_UPDATE_DELAYED()
    self.frame.bagBar:Update()
end

function bag:CheckForRemovedItems()
    for bag = 1, NUM_BAG_SLOTS do
        if GetContainerNumSlots(bag) == 0 and ADDON.cache.items[bag] then
            ADDON.utils:UpdateItemsForBag(self.frame, bag, ADDON.cache.GetBagItemContainer)
        end
    end
end