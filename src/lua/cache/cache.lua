local NAME, ADDON = ...

ADDON.cache = {}
ADDON.cache.__index = ADDON.cache

local cache = ADDON.cache
cache.items = {}
cache.bagContainers = {}
cache.bankContainers = {}
cache.reagentContainers = {}

function cache:GetItem(bag, slot)
    self.items[bag] = self.items[bag] or {}
    self.items[bag][slot] = self.items[bag][slot] or ADDON.item(bag, slot)
    return self.items[bag][slot]
end

function cache:GetBagItemContainer(name)
    self.bagContainers[name] = self.bagContainers[name] or ADDON.itemContainer(name, nil, nil, name == EMPTY)
    return self.bagContainers[name]
end

function cache:GetBankItemContainer(name)
    self.bankContainers[name] = self.bankContainers[name] or ADDON.itemContainer(name, nil, nil, name == EMPTY)
    return self.bankContainers[name]
end

function cache:GetReagentItemContainer(name)
    self.reagentContainers[name] = self.reagentContainers[name] or ADDON.itemContainer(name, nil, nil, name == EMPTY)
    return self.reagentContainers[name]
end

function cache:UpdateSettings()
    for _, slots in pairs(self.items) do
        for _, item in pairs(slots) do
            item:Setup()
        end
    end
    for _, container in pairs(cache.bagContainers) do
        container:Setup()
    end
    for _, container in pairs(cache.bankContainers) do
        container:Setup()
    end
    for _, container in pairs(cache.reagentContainers) do
        container:Setup()
    end
end