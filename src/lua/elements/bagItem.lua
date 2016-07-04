local NAME, ADDON = ...

ADDON.bagItem = {}
ADDON.bagItem.__index = ADDON.bagItem

local item = ADDON.bagItem
setmetatable(item, {
    __call = function(tbl, name, slot, id)
        local frame = CreateFrame('BUTTON', name, nil, 'ItemButtonTemplate')
        frame:SetID(id)
        frame.slot = slot

        for k, v in pairs(tbl) do
            frame[k] = v
        end

        frame:Init()
        frame:Setup()

        return frame
    end
})

function item:Init()
    self:SetScript('OnDragStart', self.DragItem)
    self:SetScript('OnReceiveDrag', self.PlaceOrPickup)
    self:SetScript('OnClick', self.PlaceOrPickup)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)

    self.IconBorder:ClearAllPoints()
    self.IconBorder:SetAllPoints()

    self:SetNormalTexture([[Interface\Common\WhiteIconFrame]])
    self:GetNormalTexture():ClearAllPoints()
    self:GetNormalTexture():SetAllPoints()
end

function item:Setup()
    local settings = ADDON.settings.bagItem or {size = 26}

    self:SetSize(settings.size, settings.size)
end

function item:Update()
    PaperDollItemSlotButton_Update(self)
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

function item:DragItem()
    PickupBagFromSlot(self:GetID())
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
end

function item:OnLeave()
    GameTooltip_Hide();
    ResetCursor();
end