local NAME, ADDON = ...

ADDON.bankController = {}
ADDON.bankController.__index = ADDON.bankController

local controller = ADDON.bankController


function controller:Init()
    ADDON.events:Add('BANKFRAME_OPENED', self)
    ADDON.events:Add('BANKFRAME_CLOSED', self)
end

function DJBagsBankBar_OnShow(self)
    PanelTemplates_SetTab(self, 1)
    DJBagsBankContainer:Show()
    DJBagsReagentContainer:Hide()
    self:Update()
    controller:Register()
    controller:Update()
end

function DJBagsBankBar_OnHide(self)
    controller:UnRegister()
end

function DJBagsBankTab_OnClick(tab)
    PlaySound("igMainMenuOpen")
    PanelTemplates_SetTab(DJBagsBankBar, tab.tab)
    if tab.tab == 1 then
        DJBagsBankContainer:Show()
        DJBagsReagentContainer:Hide()
    else
        DJBagsBankContainer:Hide()
        DJBagsReagentContainer:Show()
    end
end

function controller:Update()
    ADDON:UpdateBags({-1, 5, 6, 7, 8, 9, 10, 11, -3})
    DJBagsBankContainer:Arrange()
    self:ArrangeReagents()
end

function controller:ArrangeReagents()
    if IsReagentBankUnlocked() then
        DJBagsReagentContainer.reagentButton:Hide()
        DJBagsReagentContainer:Arrange()
    else
        DJBagsReagentContainer:SetSize(110, 35)
        DJBagsReagentContainer.reagentButton:Show()
    end
end

function controller:BANKFRAME_OPENED()
    DJBagsBankBar:Show()
end

function controller:BANKFRAME_CLOSED()
    DJBagsBankBar:Hide()
end

function controller:Register()
    ADDON.events:Add('PLAYERBANKSLOTS_CHANGED', self)
    ADDON.events:Add('BAG_UPDATE', self)
    ADDON.events:Add('INVENTORY_SEARCH_UPDATE', self)
    ADDON.events:Add('BAG_UPDATE_COOLDOWN', self)
    ADDON.events:Add('ITEM_LOCK_CHANGED', self)
    ADDON.events:Add('PLAYERREAGENTBANKSLOTS_CHANGED', self)
    ADDON.events:Add('PLAYERBANKBAGSLOTS_CHANGED', self)
    ADDON.events:Add('REAGENTBANK_PURCHASED', self)
    ADDON.events:Add('BAG_UPDATE_DELAYED', self)
end

function controller:UnRegister()
    ADDON.events:Remove('PLAYERBANKSLOTS_CHANGED', self)
    ADDON.events:Remove('BAG_UPDATE', self)
    ADDON.events:Remove('INVENTORY_SEARCH_UPDATE', self)
    ADDON.events:Remove('BAG_UPDATE_COOLDOWN', self)
    ADDON.events:Remove('ITEM_LOCK_CHANGED', self)
    ADDON.events:Remove('PLAYERREAGENTBANKSLOTS_CHANGED', self)
    ADDON.events:Remove('PLAYERBANKBAGSLOTS_CHANGED', self)
    ADDON.events:Remove('REAGENTBANK_PURCHASED', self)
    ADDON.events:Remove('BAG_UPDATE_DELAYED', self)
end

function controller:PLAYERBANKSLOTS_CHANGED()
    ADDON:UpdateBags({BANK_CONTAINER})
    DJBagsBankContainer:Arrange()
end

function controller:BAG_UPDATE(bag)
    if bag > NUM_BAG_SLOTS then
        ADDON:UpdateBags({bag})
    end
end

function controller:INVENTORY_SEARCH_UPDATE()
    local function updateSearch(bag)
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateSearch()
        end
    end

    updateSearch(-3)
    updateSearch(-1)
    updateSearch(5)
    updateSearch(6)
    updateSearch(7)
    updateSearch(8)
    updateSearch(9)
    updateSearch(10)
    updateSearch(11)
end

function controller:BAG_UPDATE_COOLDOWN()
    local function updateCooldown(bag)
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateCooldown()
        end
    end

    updateCooldown(-3)
    updateCooldown(-1)
    updateCooldown(5)
    updateCooldown(6)
    updateCooldown(7)
    updateCooldown(8)
    updateCooldown(9)
    updateCooldown(10)
    updateCooldown(11)
end

function controller:ITEM_LOCK_CHANGED(bag, slot)
    if bag ~= BANK_CONTAINER and bag ~= REAGENTBANK_CONTAINER and bag <= NUM_BAG_SLOTS then return end

    if bag == BANK_CONTAINER and slot > NUM_BANKGENERIC_SLOTS then
        _G[DJBagsBankBar:GetName() .. 'Bag' .. (slot-NUM_BANKGENERIC_SLOTS)]:UpdateLock()
    elseif slot then
        ADDON.cache:GetItem(bag, slot):UpdateLock()
    end
end

function controller:PLAYERREAGENTBANKSLOTS_CHANGED()
    ADDON:UpdateBags({REAGENTBANK_CONTAINER})
    self:ArrangeReagents()
end

function controller:PLAYERBANKBAGSLOTS_CHANGED()
    DJBagsBankBar:Update()
end

function controller:REAGENTBANK_PURCHASED()
    self:PLAYERREAGENTBANKSLOTS_CHANGED()
end

function controller:BAG_UPDATE_DELAYED()
    DJBagsBankBar:Update()
end