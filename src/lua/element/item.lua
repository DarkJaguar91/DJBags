local NAME, ADDON = ...

local item = {}

function ADDON:NewItem(bag, slot)
    local frame = CreateFrame('Frame', string.format('DJBagsItem_%d_%d', bag, slot))
    frame.button = CreateFrame('Button', string.format('DJBagsItemButton_%d_%d', bag, slot), frame,
                bag == BANK_CONTAINER and 'BankItemButtonGenericTemplate' or
                bag == REAGENTBANK_CONTAINER and 'ReagentBankItemButtonGenericTemplate' or
                'ContainerFrameItemButtonTemplate'
    )

    ADDON:CreateAddon(frame, item, bag, slot)

    return frame
end

function item:Init(bag, slot)
    self:SetID(bag)
    self.button:SetID(slot)

    self.button:SetPoint('CENTER')

    self.button.quest = _G[self.button:GetName() .. "IconQuestTexture"]
    self.button.cooldown = _G[self.button:GetName() .. "Cooldown"]
    self.button.itemLevel = self.button:CreateFontString(self.button:GetName() .. 'ItemLevel', 'ARTWORK', 'NumberFontNormal')
    self.button.itemLevel:SetPoint('TOPLEFT', 2, -2)

    self.button:Show()
    self:SetSize(self.button:GetSize())

    self.button:HookScript('OnClick', self.OnClick)
end

function item:OnClick(button)
    if self:GetParent().id and IsAltKeyDown() and button == 'LeftButton' then
            DJBagsCategoryDialogLoad(self:GetParent().id, self:GetParent().name)
    end
end

function item:GetContainerName()
    if self.id then
        local isInSet, setName = GetContainerItemEquipmentSetInfo(self:GetID(), self.button:GetID())

        if self.quality == LE_ITEM_QUALITY_POOR then
            return BAG_FILTER_JUNK
        end

        if isInSet then
            return setName
        end

        if self:GetID() >= 0 and self:GetID() <= NUM_BAG_SLOTS and C_NewItems.IsNewItem(self:GetID(), self.button:GetID()) then
            return NEW
        end

        local userDefinedList = ADDON.settings:GetUserDefinedList()
        if userDefinedList[self.id] then
            return userDefinedList[self.id]
        end

        local globalDefinedList = ADDON.settings:GetGlobalUserDefinedList()
        if globalDefinedList[self.id] then
            return globalDefinedList[self.id]
        end

        local subClassSplitList = ADDON.settings:GetSettings(DJBags_TYPE_SUB_CLASS)
        if self.classId ~= LE_ITEM_CLASS_BATTLEPET then
            if subClassSplitList[DJBags_SETTING_BOE] and DJBagsTooltip:IsItemBOE(self.link) then
                return DJBags_LOCALE_BOE
            end
            if subClassSplitList[DJBags_SETTING_BOA] and DJBagsTooltip:IsItemBOA(self.link) then
                return DJBags_LOCALE_BOA
            end
        end

        if subClassSplitList[self.classId] then
            return self.class .. (self.subClass == BAG_FILTER_JUNK and '' or '_' .. self.subClass)
        end

        return self.class
    end
    return EMPTY
end

--region Update Magic

local function UpdateQuest(self, isQuestItem, questId, isActive)
    if (questId and not isActive) then
        self.button.quest:SetTexture(TEXTURE_ITEM_QUEST_BANG)
        self.button.quest:Show()
    elseif (questId or isQuestItem) then
        self.button.quest:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
        self.button.quest:Show()
    else
        self.button.quest:Hide()
    end
end

local function UpdateNewItemAnimations(self, isNewItem, isBattlePayItem, quality)
    if (isNewItem) then
        if (isBattlePayItem) then
            self.button.NewItemTexture:Hide()
            self.button.BattlepayItemTexture:Show()
        else
            if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
                self.button.NewItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality]);
            else
                self.button.NewItemTexture:SetAtlas("bags-glow-white");
            end
            self.button.BattlepayItemTexture:Hide();
            self.button.NewItemTexture:Show();
        end
        if (not self.button.flashAnim:IsPlaying() and not self.button.newitemglowAnim:IsPlaying()) then
            self.button.flashAnim:Play();
            self.button.newitemglowAnim:Play();
        end
    else
        self.button.BattlepayItemTexture:Hide();
        self.button.NewItemTexture:Hide();
        if (self.button.flashAnim:IsPlaying() or self.button.newitemglowAnim:IsPlaying()) then
            self.button.flashAnim:Stop();
            self.button.newitemglowAnim:Stop();
        end
    end
end

local function UpdateFiltered(self, filtered, shouldDoRelicChecks, itemID)
    if (filtered) then
        self.button.searchOverlay:Show();
    else
        self.button.searchOverlay:Hide();
        if shouldDoRelicChecks then
            ContainerFrame_ConsiderItemButtonForRelicTutorial(self.button, itemID);
        end
    end
end

local function UpdateILevel(self, equipable, quality, level)
    if equipable then
        if quality and quality >= LE_ITEM_QUALITY_COMMON then
            self.button.itemLevel:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
        else
            self.button.itemLevel:SetVertexColor(1, 1, 1, 1)
        end
        self.button.itemLevel:SetText(level)
        self.button.itemLevel:Show()
    else
        self.button.itemLevel:Hide()
    end
end

local function UpdateCooldown(self)
    if not GetContainerItemID(self:GetID(), self.button:GetID()) then
        self.button.cooldown:Hide()
        return
    end

    local start, duration, enable = GetContainerItemCooldown(self:GetID(), self.button:GetID());
    CooldownFrame_Set(self.button.cooldown, start, duration, enable);
    if (duration > 0 and enable == 0) then
        SetItemButtonTextureVertexColor(self.button, 0.4, 0.4, 0.4);
    else
        SetItemButtonTextureVertexColor(self.button, 1, 1, 1);
    end
end

function item:Update()
    local texture, count, locked, quality, _, _, link, filtered, _, id = GetContainerItemInfo(self:GetID(), self.button:GetID())
    local equipable = IsEquippableItem(id)

    local name, level, classId, class, subClass
    if id then
        name, _, _, level, _, class, subClass, _, _, _, _, classId = GetItemInfo(id)
    end
    local isEquipment = equipable or classId == LE_ITEM_CLASS_ARMOR or classId == LE_ITEM_CLASS_WEAPON

    self.id = id
    self.name = name or ''
    self.quality = quality or 0
    self.ilevel = level or 0
    self.link = link
    self.classId = classId
    self.class = class
    self.subClass = subClass
    self.count = count or 1
    self.button.hasItem = nil

    if isEquipment then
        level = DJBagsTooltip:GetItemLevel(link) or level
    elseif classId == LE_ITEM_CLASS_CONTAINER then
        -- TODO set count to number of slots
    end

    UpdateILevel(self, equipable, quality, level)
    if ADDON:IsBankBag(self:GetID()) then
        BankFrameItemButton_Update(self.button)
    else
        local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self:GetID(), self.button:GetID())
        local isNewItem = C_NewItems.IsNewItem(self:GetID(), self.button:GetID())
        local isBattlePayItem = IsBattlePayItem(self:GetID(), self.button:GetID())
        local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)

        self.button.hasItem = true

        SetItemButtonTexture(self.button, texture)
        SetItemButtonQuality(self.button, quality, id)
        SetItemButtonCount(self.button, count)
        SetItemButtonDesaturated(self.button, locked)
        UpdateQuest(self, isQuestItem, questId, isActive)
        UpdateNewItemAnimations(self, isNewItem, isBattlePayItem, quality)
        UpdateFiltered(self, filtered, shouldDoRelicChecks, id)
        UpdateCooldown(self)
    end
end

function item:UpdateCooldown()
    UpdateCooldown(self)
end

function item:UpdateSearch()
    local _, _, _, _, _, _, _, filtered, _, id = GetContainerItemInfo(self:GetID(), self.button:GetID())
    local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)
    self:SetFiltered(filtered, shouldDoRelicChecks)
end

function item:UpdateLock()
    local locked = select(3, GetContainerItemInfo(self:GetID(), self.button:GetID()))
    SetItemButtonDesaturated(self.button, locked);
end

function item:SetFiltered(filtered, shouldDoRelicChecks)
    UpdateFiltered(self, filtered, shouldDoRelicChecks, self.id)
end

function item:SetItemCount(count)
    SetItemButtonCount(self.button, count)
end

--endregion

--region Override UI code

function ContainerFrameItemButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")

    local newItemTexture = self.NewItemTexture
    local battlepayItemTexture = self.BattlepayItemTexture
    local flash = self.flashAnim
    local newItemGlowAnim = self.newitemglowAnim

    newItemTexture:Hide()
    battlepayItemTexture:Hide()

    if (flash:IsPlaying() or newItemGlowAnim:IsPlaying()) then
        flash:Stop()
        newItemGlowAnim:Stop()
    end

    local showSell
    local _, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(self:GetParent():GetID(), self:GetID())
    if(speciesID and speciesID > 0) then
        ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)
        BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
        return;
    else
        if (BattlePetTooltip) then
            BattlePetTooltip:Hide()
        end
    end

    local requiresCompareTooltipReanchor = ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

    if ( requiresCompareTooltipReanchor and (IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems")) ) then
        GameTooltip_ShowCompareItem(GameTooltip)
    end

    if ( InRepairMode() and (repairCost and repairCost > 0) ) then
        GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true)
        SetTooltipMoney(GameTooltip, repairCost)
        GameTooltip:Show()
    elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
        showSell = 1
    end

    if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
        ShowInspectCursor()
    elseif ( showSell ) then
        ShowContainerSellCursor(self:GetParent():GetID(),self:GetID())
    elseif ( self.readable ) then
        ShowInspectCursor()
    else
        ResetCursor()
    end

    if ArtifactFrame and self.hasItem then
        ArtifactFrame:OnInventoryItemMouseEnter(self:GetParent():GetID(), self:GetID())
    end
end

--endregion