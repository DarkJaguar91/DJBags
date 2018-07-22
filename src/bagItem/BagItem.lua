local NAME, ADDON = ...

local item = {}

function DJBagsBagItemLoad(button, slot, id)
    for k, v in pairs(item) do
        button[k] = v
    end

    button:Init(id, slot)
end

function item:Init(id, slot)
    self:SetID(id)
    self.slot = slot

    self:SetScript('OnDragStart', self.DragItem)
    self:SetScript('OnReceiveDrag', self.PlaceOrPickup)
    self:SetScript('OnClick', function (self, ...)
        if self.buy then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
            StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
        else
            self:PlaceOrPickup(...)
        end
    end)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
end

function item:Update()
    local numBankSlots, full = GetNumBankSlots()
    if self.slot - NUM_BAG_SLOTS > numBankSlots  then
        local cost = GetBankSlotCost(self.slot-1)
        self:SetCost(cost)
        return
    end
    PaperDollItemSlotButton_Update(self)
    local slotcount = GetContainerNumSlots(self.slot)
    if slotcount > 0 then
        self.Count:SetText(tostring(slotcount))
        self.Count:Show()
    else
        self.Count:Hide()
    end
    self.buy = nil
end

function item:UpdateLock()
    PaperDollItemSlotButton_UpdateLock(self)
end

function item:PlaceOrPickup()
    local placed = PutItemInBag(self:GetID())
    if not placed then
        PickupBagFromSlot(self:GetID())
    end
end

function item:OnEnter()
    if self:GetRight() >= (GetScreenWidth() / 2) then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    else
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    end

    local hasItem, hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetInventoryItem("player", self:GetID())
    if(speciesID and speciesID > 0) then
        BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
        CursorUpdate(self)
        return;
    end

    if (not IsInventoryItemProfessionBag("player", self:GetID())) then
        for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
            if ( GetBankBagSlotFlag(self:GetID(), i) ) then
                GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]))
                break;
            end
        end
    end

    GameTooltip:Show()
    CursorUpdate(self)

    ADDON.eventManager:Fire('DJBAGS_BAG_HOVER', self.slot, true)
end

function item:SetCost(cost)
    if cost > -1 then
        self.IconBorder:Show()
        self.IconBorder:SetVertexColor(1, 0, 0, 1)
        self.Count:Show()
        self.Count:SetText(cost/10000 .. "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
        BankFrame.nextSlotCost = cost
        self.buy = true
    end
end

function item:OnLeave()
    GameTooltip_Hide()
    ResetCursor()
    
    ADDON.eventManager:Fire('DJBAGS_BAG_HOVER', self.slot, false)
end