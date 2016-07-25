local NAME, ADDON = ...

function ADDON:IsBankBag(id)
    if id == BANK_CONTAINER or id == REAGENTBANK_CONTAINER then
        return true
    end
    return false
end

function ADDON:CreateAddon(obj, tbl, ...)
    for k, v in pairs(tbl) do
        obj[k] = v
    end

    if obj.Init then
        obj:Init(...)
    end
end

function ADDON:Count(table)
    local cnt = 0;

    for _ in pairs(table) do
        cnt = cnt + 1
    end

    return cnt
end

function ADDON:PairsByKey(tbl, sorter)
    local keys = {}
    for k in pairs(tbl) do
        tinsert(keys, k)
    end
    table.sort(keys, sorter)
    local index = 0
    return function()
        index = index + 1
        return keys[index], tbl[keys[index]]
    end
end

function ADDON:UpdateBags(bags)
    for _, bag in pairs(bags) do
        local bagSlots = GetContainerNumSlots(bag)

        if ADDON.cache.items[bag] and bagSlots < ADDON:Count(ADDON.cache.items[bag]) then
            for index = bagSlots + 1, ADDON:Count(ADDON.cache.items[bag]) do
                local item = ADDON.cache:GetItem(bag, index)
                local parent = item:GetParent() and item:GetParent():GetParent()
                if parent and parent.RemoveItem then
                    parent:RemoveItem(item)
                end
                item:Hide()
            end
        end

        for slot = 1, bagSlots do
            local item = ADDON.cache:GetItem(bag, slot)
            item:Update()
            local newParent = ADDON.cache:GetItemContainer(bag, item:GetContainerName())

            local currentParent = item:GetParent() and item:GetParent():GetParent()
            if currentParent and currentParent.RemoveItem then
                currentParent:RemoveItem(item)
            end

            newParent:AddItem(item)
        end
    end
end