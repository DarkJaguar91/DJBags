local NAME, ADDON = ...

ADDON.bank = {}
ADDON.bank.__index = ADDON.bank

local bank = ADDON.bank

function bank:Init()
    self.frame = ADDON.container('DJBagsBankMainBar')
    self:InitMainBar()

    self.bankContainer = ADDON.categoryContainer('DJBagsBankCategoryContainer', self.frame)
    self.bankContainer:SetPoint('TOPLEFT', self.frame, 'BOTTOMLEFT', 0, -5)
    self.bankContainer:SetScript("OnDragStart", function(_, ...)
        self.frame:StartMoving(...)
    end)
    self.bankContainer:SetScript("OnDragStop", function(_, ...)
        self.frame:StopMovingOrSizing(...)
    end)

    self.reagentContainer = ADDON.categoryContainer('DJBagsReagentBankCategoryContainer', self.frame)
    self.reagentContainer:SetSize(10, 10)
    self.reagentContainer:SetPoint('TOPLEFT', self.frame, 'BOTTOMLEFT', 0, -34)
    self.reagentContainer:SetScript("OnDragStart", function(_, ...)
        self.frame:StartMoving(...)
    end)
    self.reagentContainer:SetScript("OnDragStop", function(_, ...)
        self.frame:StopMovingOrSizing(...)
    end)
    self.reagentButton = CreateFrame('BUTTON', 'DJBagsBankBarReagentDepositButton', self.reagentContainer, 'UIPanelButtonTemplate')
    self.reagentButton:SetScript('OnClick', bank.ReagentButtonClick)
    self.reagentButton:SetHeight(24)
    self.reagentButton:SetPoint('BOTTOMLEFT', self.reagentContainer, 'TOPLEFT', 0, 5)

    self.frame:HookScript('OnShow', self.OnShow)
    self.frame:HookScript('OnHide', self.OnHide)

    ADDON.eventManager:AddEvent(self, "BANKFRAME_OPENED")
    ADDON.eventManager:AddEvent(self, "BANKFRAME_CLOSED")
    BankFrame:UnregisterAllEvents()
end

function bank:UpdateSettings(arrange)
    self.frame:Setup()
    self.bankContainer:Setup()
    self.reagentContainer:Setup()
    if self.frame:IsVisible() and arrange then
        self:UpdateAllItems()
    end
end

function bank:BANKFRAME_OPENED()
    self.frame:Show()
end

function bank:BANKFRAME_CLOSED()
    self.frame:Hide()
end

function bank:ReagentButtonClick()
    if IsReagentBankUnlocked() then
        PlaySound("igMainMenuOption");
        DepositReagentBank();
    else
        PlaySound("igMainMenuOption");
        StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB");
    end
end

function bank:OnShow()
    PlaySound("igMainMenuOpen")
    ADDON.bag:Open()
    bank:Register()
    bank:UpdateAllItems()
    bank:UpdateBags()
    PanelTemplates_SetTab(self, 1)
    bank.bankContainer:Show()
    bank.reagentContainer:Hide()

    if ADDON.settings.auto.depositReagents and IsReagentBankUnlocked() then
        DepositReagentBank();
    end
end

function bank:OnHide()
    PlaySound("igMainMenuClose")
    CloseAllBags(self);
    CloseBankBagFrames();
    CloseBankFrame();
    StaticPopup_Hide("CONFIRM_BUY_BANK_SLOT")
    bank:UnRegister()
end

function bank:UpdateAllItems()
    local arrangeList = {}
    ADDON.utils:UpdateItemsForBag(self.bankContainer, BANK_CONTAINER, arrangeList, ADDON.cache.GetBankItemContainer)
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
        ADDON.utils:UpdateItemsForBag(self.bankContainer, bag, arrangeList, ADDON.cache.GetBankItemContainer)
    end
    for container, _ in pairs(arrangeList) do
        container:Arrange()
    end
    self.bankContainer:Arrange()

    self:UpdateReagentBank()
end

function bank:UpdateReagentBank()
    if IsReagentBankUnlocked() then
        local arrangeList = {}
        ADDON.utils:UpdateItemsForBag(self.reagentContainer, REAGENTBANK_CONTAINER, arrangeList, ADDON.cache.GetReagentItemContainer)
        for container, _ in pairs(arrangeList) do
            container:Arrange()
        end
        self.reagentContainer:Arrange()
        self.reagentButton:SetText(REAGENTBANK_DEPOSIT)
        self.reagentButton:SetWidth(self.reagentButton:GetFontString():GetStringWidth() + 31)
    else
        self.reagentButton:SetText(BANKSLOTPURCHASE)
        self.reagentButton:SetWidth(self.reagentButton:GetFontString():GetStringWidth() + 31)
    end
end

function bank:UpdateAllItemsForBag(bag)
    local arrangeList = {}
    ADDON.utils:UpdateItemsForBag(self.bankContainer, bag, arrangeList, ADDON.cache.GetBankItemContainer)
    for container, _ in pairs(arrangeList) do
        container:Arrange()
    end
    self.bankContainer:Arrange()
end

function bank:Register()
    ADDON.eventManager:AddEvent(self, 'PLAYERBANKSLOTS_CHANGED')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:AddEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:AddEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:AddEvent(self, 'ITEM_LOCK_CHANGED')
    ADDON.eventManager:AddEvent(self, 'PLAYERREAGENTBANKSLOTS_CHANGED')
    ADDON.eventManager:AddEvent(self, 'PLAYERBANKBAGSLOTS_CHANGED')
    ADDON.eventManager:AddEvent(self, 'REAGENTBANK_PURCHASED')
end

function bank:UnRegister()
    ADDON.eventManager:RemoveEvent(self, 'PLAYERBANKSLOTS_CHANGED')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'INVENTORY_SEARCH_UPDATE')
    ADDON.eventManager:RemoveEvent(self, 'BAG_UPDATE_COOLDOWN')
    ADDON.eventManager:RemoveEvent(self, 'ITEM_LOCK_CHANGED')
    ADDON.eventManager:RemoveEvent(self, 'PLAYERREAGENTBANKSLOTS_CHANGED')
    ADDON.eventManager:RemoveEvent(self, 'PLAYERBANKBAGSLOTS_CHANGED')
    ADDON.eventManager:RemoveEvent(self, 'REAGENTBANK_PURCHASED')
end

function bank:PLAYERBANKBAGSLOTS_CHANGED()
    self:UpdateBags()
end

function bank:BAG_UPDATE(bag)
    if bag > NUM_BAG_SLOTS then
        self:UpdateAllItemsForBag(bag)
    end
end

function bank:PLAYERBANKSLOTS_CHANGED(slot)
    if slot <= NUM_BANKGENERIC_SLOTS then
        self:UpdateAllItemsForBag(BANK_CONTAINER)
    else
        self.bags[slot-NUM_BANKGENERIC_SLOTS]:Update()
    end
end

function bank:PLAYERREAGENTBANKSLOTS_CHANGED()
    self:UpdateReagentBank()
end

function bank:REAGENTBANK_PURCHASED()
    self:UpdateReagentBank()
end

function bank:INVENTORY_SEARCH_UPDATE()
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateSearch()
        end
    end
    for slot = 1, GetContainerNumSlots(BANK_CONTAINER) do
        ADDON.cache:GetItem(BANK_CONTAINER, slot):UpdateSearch()
    end
    if IsReagentBankUnlocked() then
        for slot = 1, GetContainerNumSlots(REAGENTBANK_CONTAINER) do
            ADDON.cache:GetItem(REAGENTBANK_CONTAINER, slot):UpdateSearch()
        end
    end
end

function bank:BAG_UPDATE_COOLDOWN()
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateCooldown()
        end
    end
    for slot = 1, GetContainerNumSlots(BANK_CONTAINER) do
        ADDON.cache:GetItem(BANK_CONTAINER, slot):UpdateCooldown()
    end
    if IsReagentBankUnlocked() then
        for slot = 1, GetContainerNumSlots(REAGENTBANK_CONTAINER) do
            ADDON.cache:GetItem(REAGENTBANK_CONTAINER, slot):UpdateCooldown()
        end
    end
end

function bank:ITEM_LOCK_CHANGED(bag, slot)
    if bag ~= BANK_CONTAINER and bag ~= REAGENTBANK_CONTAINER and bag <= NUM_BAG_SLOTS then return end

    if bag == BANK_CONTAINER and slot > NUM_BANKGENERIC_SLOTS then
        self.bags[slot-NUM_BANKGENERIC_SLOTS]:UpdateLock()
    elseif slot then
        ADDON.cache:GetItem(bag, slot):UpdateLock()
    end
end

function bank:InitMainBar()
    table.insert(UISpecialFrames, self.frame:GetName())
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    self.frame:SetPoint('TOPLEFT', 200, -100)
    self.frame:SetUserPlaced(true)
    self.frame:Hide()
    self.bags = {}

    self.emptyBag = CreateFrame('BUTTON', 'DJBagsBankEmptyContainer', self.frame)
    self.emptyBag:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    })
    self.emptyBag:SetBackdropBorderColor(1, 0, 0, 1)
    self.emptyBag:SetBackdropColor(0, 0, 0, 0)
    self.emptyBag.money = CreateFrame('Frame', 'DJBagsBankBagBost', self.emptyBag, 'SmallMoneyFrameTemplate')
    self.emptyBag.money:SetPoint('CENTER', 6, 0)
    self.emptyBag:SetPoint("TOPRIGHT", -5, -5)
    self.emptyBag:SetScript('OnClick', function()
        PlaySound("igMainMenuOption");
        StaticPopup_Show("CONFIRM_BUY_BANK_SLOT");
    end)
    SmallMoneyFrame_OnLoad(self.emptyBag.money)
    MoneyFrame_SetType(self.emptyBag.money, "STATIC")

    self.searchBar = CreateFrame('EDITBOX', 'DJBagsBankSearch', self.frame, 'BagSearchBoxTemplate')
    self.searchBar:SetPoint('BOTTOMLEFT', 10, 5)
    self.searchBar:SetPoint('BOTTOMRIGHT', -5, 5)
    self.searchBar:SetHeight(25)

    self.bagBtn = CreateFrame('BUTTON', self.frame:GetName()..'Tab1', self.frame, 'TabButtonTemplate')
    self.bagBtn.tab = 1
    self.bagBtn:SetPoint('BOTTOMLEFT', self.frame, 'TOPLEFT')
    self.bagBtn:SetText(BANK)
    self.bagBtn:SetScript('OnClick', self.TabClick)
    PanelTemplates_TabResize(self.bagBtn, 0)
    _G[self.bagBtn:GetName().."HighlightTexture"]:SetWidth(self.bagBtn:GetTextWidth() + 31)

    self.reagentBtn = CreateFrame('BUTTON', self.frame:GetName()..'Tab2', self.frame, 'TabButtonTemplate')
    self.reagentBtn.tab = 2
    self.reagentBtn:SetPoint('BOTTOMLEFT', self.bagBtn, 'BOTTOMRIGHT', 0, 0)
    self.reagentBtn:SetText(REAGENT_BANK)
    self.reagentBtn:SetScript('OnClick', self.TabClick)
    PanelTemplates_TabResize(self.reagentBtn, 0)
    _G[self.reagentBtn:GetName().."HighlightTexture"]:SetWidth(self.reagentBtn:GetTextWidth() + 31)
    PanelTemplates_SetNumTabs(self.frame, 2)
end

function bank:TabClick()
    PlaySound("igMainMenuOpen")
    PanelTemplates_SetTab(self:GetParent(), self.tab)
    if self.tab == 1 then
        bank.bankContainer:Show()
        bank.reagentContainer:Hide()
    else
        bank.bankContainer:Hide()
        bank.reagentContainer:Show()
    end
end

function bank:UpdateBags()
    local numBankslots, full = GetNumBankSlots()
    for bag = #self.bags+1, numBankslots do
        local item = ADDON.bagItem('DJBagsBankBagItem' .. bag, bag, BankButtonIDToInvSlotID(bag, 1))
        item:SetParent(self.frame)
        tinsert(self.bags, item)
    end

    if not full then
        self.emptyBag:Show()
        local cost = GetBankSlotCost(numSlots);
        BankFrame.nextSlotCost = cost;
        if( GetMoney() >= cost ) then
            SetMoneyFrameColor(self.emptyBag.money, "white");
        else
            SetMoneyFrameColor(self.emptyBag.money, "red")
        end
        MoneyFrame_Update(self.emptyBag.money, cost);
    else
        self.emptyBag:Hide()
    end
    self:ArrangeBags()
end

function bank:ArrangeBags()
    local x = 5
    local y = ADDON.settings.bagItem.size

    for _, bag in pairs(self.bags) do
        bag:Update()
        bag:SetPoint('TOPLEFT', x, -5)
        x = x + 5 + bag:GetWidth()
    end

    if self.emptyBag:IsVisible() then
        self.emptyBag:SetSize(math.max(y, self.emptyBag.money:GetWidth() - 10), y)
        x = x + 5 + self.emptyBag:GetWidth()
    end

    self.frame:SetSize(math.max(x, 175), y + 12 + self.searchBar:GetHeight())
end