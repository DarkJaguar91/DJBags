local NAME, ADDON = ...

local item = {}

function ADDON:NewBagItem(name, slot, id)
    local frame = CreateFrame('Button', name, UIParent, 'ItemButtonTemplate')

    ADDON:CreateAddon(frame, item, id, slot)

    return frame
end

function item:Init(id, slot)
    self:SetID(id)
    self.slot = slot

    self:SetScript('OnDragStart', self.DragItem)
    self:SetScript('OnReceiveDrag', self.PlaceOrPickup)
    self:SetScript('OnClick', self.PlaceOrPickup)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
end

function item:Update()
    PaperDollItemSlotButton_Update(self)
    local slotcount = GetContainerNumSlots(self.slot)
    if slotcount > 0 then
        self.Count:SetText(tostring(slotcount))
        self.Count:Show()
    else
        self.Count:Hide()
    end
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

    local hasItem, hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetInventoryItem("player", self:GetID());
    if(speciesID and speciesID > 0) then
        BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
        CursorUpdate(self);
        return;
    end

    if (not IsInventoryItemProfessionBag("player", self:GetID())) then
        for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
            if ( GetBankBagSlotFlag(self:GetID(), i) ) then
                GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
                break;
            end
        end
    end

    GameTooltip:Show();
    CursorUpdate(self);

    ADDON.events:Fire('DJBAGS_BAG_HOVER', self.slot, true)
end

function item:OnLeave()
    GameTooltip_Hide();
    ResetCursor();

    ADDON.events:Fire('DJBAGS_BAG_HOVER', self.slot, false)
end