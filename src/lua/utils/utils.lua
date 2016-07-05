local NAME, ADDON = ...

local random = math.random
ADDON.uuid = function()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

ADDON.utils = {}
ADDON.utils.__index = ADDON.utils
ADDON.utils.EMPTY_BAG_NAME = 'SUPER_RANDOM_EMPTY_BAG_NAME_123123'

local utils = ADDON.utils

function utils:PairsByKey(tbl, sortFunction)
    local keys = {}
    for k in pairs(tbl) do
        tinsert(keys, k)
    end
    table.sort(keys, sortFunction)
    local index = 0
    return function()
        index = index + 1
        return keys[index], tbl[keys[index]]
    end
end

function utils:GetItemContainerName(bag, slot)
    local id = GetContainerItemID(bag, slot)

    if id then
        local name, link, quality, iLevel, reqLevel, className, subClassName, maxStack, equipSlot, texture, vendorPrice, cId, sCId = GetItemInfo(id)
        local isInSet, setName = GetContainerItemEquipmentSetInfo(bag, slot)

        if quality == LE_ITEM_QUALITY_POOR then
            return BAG_FILTER_JUNK
        end

        if isInSet then
            return setName
        end

        if bag >= 0 and bag <= NUM_BAG_SLOTS and C_NewItems.IsNewItem(bag, slot) then
            return NEW
        end

        local userDefinedList = ADDON.settings.categories.userDefined
        if userDefinedList[id] then
            return userDefinedList[id] .. '*'
        end

        local globalDefinedList = ADDON.globalCategories
        if globalDefinedList[id] then
            return globalDefinedList[id] .. '**'
        end

        local subClassSplitList = ADDON.settings.categories.subClass
        if subClassSplitList[cId] then
            return className .. ' ' .. subClassName
        end

        return className
    end
    return self.EMPTY_BAG_NAME
end

function utils:UpdateItemsForBag(frame, bag, arrangeList, containerFunc)
    local count = GetContainerNumSlots(bag)
    if count == 0 and ADDON.cache.items[bag] then
        for _, item in pairs(ADDON.cache.items[bag]) do
            if item:GetParent() then
                local previousContainer = item:GetParent()
                previousContainer:RemoveItem(item)
                arrangeList[previousContainer] = true
                item:Hide()
            end
        end
    else
        for slot = 1, count do
            local item = ADDON.cache:GetItem(bag, slot)
            local previousContainer
            if item:GetParent() and item:GetParent().__class == ADDON.itemContainer.__class then
                previousContainer = item:GetParent()
            end

            item:Update()

            local newContainer = containerFunc(ADDON.cache, ADDON.utils:GetItemContainerName(bag, slot))
            frame:AddContainer(newContainer)
            arrangeList[newContainer] = true

            if previousContainer ~= newContainer then
                if previousContainer then
                    previousContainer:RemoveItem(item)
                    arrangeList[previousContainer] = true
                end
                newContainer:AddItem(item)
            end
        end
    end
end