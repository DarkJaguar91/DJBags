local NAME, ADDON = ...

ADDON.item = {}
ADDON.item.__index = ADDON.item

local item = ADDON.item
setmetatable(item, {
    __call = function(tbl, bag, slot)
        local parent = CreateFrame('FRAME', string.format('DJBagsItemParent%d_%d', bag, slot))
        parent.button = CreateFrame('BUTTON', string.format('DJBagsItem%d_%d', bag, slot), parent, 'ContainerFrameItemButtonTemplate')

        parent:SetID(bag)
        parent.button:SetID(slot)

        for key, value in pairs(tbl) do
            parent[key] = value
        end

        parent:Init()
        parent:Setup()

        return parent
    end
})

function item:Init()
    self.button:ClearAllPoints()
    self.button:SetAllPoints()

    self.button.IconBorder:ClearAllPoints()
    self.button.IconBorder:SetAllPoints()

    self.button:SetNormalTexture([[Interface\Common\WhiteIconFrame]])
    self.button:GetNormalTexture():ClearAllPoints()
    self.button:GetNormalTexture():SetAllPoints()

    self.button.NewItemTexture:ClearAllPoints()
    self.button.NewItemTexture:SetAllPoints()

    self.button.flash:ClearAllPoints()
    self.button.flash:SetAllPoints()

    self.button.quest = _G[self.button:GetName() .. "IconQuestTexture"]
    self.button.quest:ClearAllPoints()
    self.button.quest:SetAllPoints()

    self.button.cooldown = _G[self.button:GetName() .. "Cooldown"]

    self.button:Show()

    self.button:HookScript('OnClick', self.OnClick)
end

function item:Setup()
    local settings = ADDON.settings.item
    self:SetSize(settings.size, settings.size)
    local name, _, outline = self.button.Count:GetFont()
    self.button.Count:SetFont(name, math.min(settings.size / 4, 13), outline)
end

--region Update Events

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

local function UpdateCountcolour(self, equipable, quality)
    if equipable and quality then
        self.button.Count:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
    else
        self.button.Count:SetVertexColor(1, 1, 1)
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
    local texture, count, locked, quality, _, _, _, filtered, _, id = GetContainerItemInfo(self:GetID(), self.button:GetID())
    local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self:GetID(), self.button:GetID())
    local isNewItem = C_NewItems.IsNewItem(self:GetID(), self.button:GetID())
    local isBattlePayItem = IsBattlePayItem(self:GetID(), self.button:GetID())
    local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)
    local equipable = IsEquippableItem(id)

    if (equipable) then
        count = count > 1 and count or select(4, GetItemInfo(id))
    end

    self.id = id
    self.name = id and select(1, GetItemInfo(id)) or ''
    self.quality = quality or 0
    self.ilevel = id and select(4, GetItemInfo(id)) or 0

    SetItemButtonTexture(self.button, texture)
    SetItemButtonQuality(self.button, quality, id)
    SetItemButtonCount(self.button, count)
    SetItemButtonDesaturated(self.button, locked)
    UpdateQuest(self, isQuestItem, questId, isActive)
    UpdateNewItemAnimations(self, isNewItem, isBattlePayItem, quality)
    UpdateFiltered(self, filtered, shouldDoRelicChecks, id)
    UpdateCountcolour(self, equipable, quality)
    UpdateCooldown(self)
end

function item:UpdateCooldown()
    UpdateCooldown(self)
end

function item:UpdateSearch()
    local _, _, _, _, _, _, _, filtered, _, id = GetContainerItemInfo(self:GetID(), self.button:GetID())
    local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)
    UpdateFiltered(self, filtered, shouldDoRelicChecks, id)
end

function item:UpdateLock()
    local locked = select(3, GetContainerItemInfo(self:GetID(), self.button:GetID()))
    SetItemButtonDesaturated(self.button, locked);
end

function item:OnClick(button)
    if self:GetParent().id then
        if IsAltKeyDown() and button == 'LeftButton' then
            ADDON.categoryDialog(self:GetParent().id)
        end
    end
end

--endregion