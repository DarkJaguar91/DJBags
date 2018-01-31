local ADDON_NAME, ADDON = ...

local bag = {}
bag.__index = bag

local settings = {
    padding = 5,
    containerSpacing = 5,
    itemSpacing = 5,
    maxColumns = 10,
}

local function MakeMoveable(self)
    if self:GetParent() == UIParent then
        table.insert(UISpecialFrames, self:GetName())
    end
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self, ...)
        if self:GetParent() == UIParent then
            self:StartMoving()
        elseif self:GetParent():IsMovable() then
            self:GetParent():StartMoving(...)
        end
    end)
    self:SetScript("OnDragStop", function(self, ...)
        if self:GetParent() == UIParent then
            self:StopMovingOrSizing(...)
        elseif self:GetParent():IsMovable() then
            self:GetParent():StopMovingOrSizing(...)
        end
    end)
    if self:GetParent() == UIParent then
        self:SetUserPlaced(true)
    end
end

local function GetKeyBasedBagList(bags)
    local out = {}
    for _, v in pairs(bags) do
        out[v] = true
    end
    return out
end

local function CreateBagContainers(self)
    local out = {}
    for _, bag in pairs(self.bags) do
        out[bag] = CreateFrame("Frame", "DJBagsBagContainer_" .. bag, self)
        out[bag]:SetAllPoints()
        out[bag]:SetID(bag)
        out[bag].items = {}
    end
    return out
end

local function CreateTitleContainer(self, item)
    if not self.titleContainers[item.type] then
        self.titleContainers[item.type] = CreateFrame('Frame', string.format('DJBagsTitleContainer_%s_%s', self:GetName(), item.type), self, 'DJBagsTitleContainerTemplate')
        self.titleContainers[item.type].name:SetText(item.type)
        self.titleContainers[item.type].name.text = item.type
        MakeMoveable(self.titleContainers[item.type])
    end
end

local function GetAllItems(self, bags)
    local updateOccured = false
    for _, bag in pairs(bags) do
        local bagSlots = GetContainerNumSlots(bag)
        local container = self.containers[bag]
        for slot = 1, bagSlots do
            if not container.items[slot] then
                container.items[slot] = ADDON:NewItem(container, slot)
                tinsert(self.items, container.items[slot])
            end
            local item = container.items[slot]
            local idBefore = item.id
            item:Update()
            item.type = ADDON.categoryManager:GetTitle(item)
            CreateTitleContainer(self, item)
            if idBefore ~= item.id and item.id ~= nil then
                updateOccured = true
            end
        end
    end
    if updateOccured then
        self:Format()
    end
    return updateOccured
end

function DJBagsRegisterBaseBagContainer(frame, bags)
    for k, v in pairs(bag) do
        frame[k] = v
    end

    frame:OnLoad(bags)
end

function bag:OnLoad(bags)
    self.bags = bags
    self.bagsByKey = GetKeyBasedBagList(bags)
    self.items = {}
    self.containers = CreateBagContainers(self)
    self.titleContainers = {}
    self.settings = settings -- TODO get this from user defined settings...
    self.Format = ADDON.formatter[ADDON.formats.MASONRY]

    ADDON.eventManager:Add('PLAYER_ENTERING_WORLD', self)

    MakeMoveable(self) 
end

function bag:OnShow()
    self:Refresh()
    self:BAG_UPDATE_DELAYED()

    ADDON.eventManager:Add('INVENTORY_SEARCH_UPDATE', self)
    ADDON.eventManager:Add('BAG_UPDATE_COOLDOWN', self)
    ADDON.eventManager:Add('ITEM_LOCK_CHANGED', self)
    ADDON.eventManager:Add('BAG_UPDATE_DELAYED', self)    
    ADDON.eventManager:Add('DJBAGS_BAG_HOVER', self) -- some hover stuff...
end

function bag:OnHide()
    ADDON.eventManager:Remove('INVENTORY_SEARCH_UPDATE', self)
    ADDON.eventManager:Remove('BAG_UPDATE_COOLDOWN', self)
    ADDON.eventManager:Remove('ITEM_LOCK_CHANGED', self)
    ADDON.eventManager:Remove('BAG_UPDATE_DELAYED', self)
    ADDON.eventManager:Remove('DJBAGS_BAG_HOVER', self)
end

function bag:Refresh()
    if not GetAllItems(self, self.bags) then
        self:Format()
    end
end

function bag:PLAYER_ENTERING_WORLD()
    ADDON.eventManager:Add('BAG_UPDATE', self)
end

function bag:BAG_UPDATE(bag)
    if self.bagsByKey[bag] then
        GetAllItems(self, { bag })
    end
end

function bag:INVENTORY_SEARCH_UPDATE()
    for _, item in pairs(self.items) do
        item:UpdateSearch()
    end
end

function bag:BAG_UPDATE_COOLDOWN()
    for _, item in pairs(self.items) do
        item:UpdateCooldown()
    end
end

function bag:ITEM_LOCK_CHANGED(bag, slot)
    if bag then
        if self.bagsByKey[bag] and slot then
            if (self.containers[bag].items[slot]) then
                self.containers[bag].items[slot]:UpdateLock()
            end
        end
    end
end

function bag:BAG_UPDATE_DELAYED()
end

function bag:DJBAGS_BAG_HOVER(bagId, locked)
    for _, item in pairs(self.items) do
        local lock = (item:GetParent():GetID() ~= bagId) and locked
        item:UpdateLock(lock)
    end
end 