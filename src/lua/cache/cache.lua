local NAME, ADDON = ...

ADDON.cache = {}
ADDON.cache.__index = ADDON.cache

local cache = ADDON.cache
cache.items = {}
cache.bagContainers = {}

function cache:GetItem(bag, slot)
    self.items[bag] = self.items[bag] or {}
    self.items[bag][slot] = self.items[bag][slot] or ADDON.item(bag, slot)
    return self.items[bag][slot]
end

function cache:GetBagItemContainer(name)
    self.bagContainers[name] = self.bagContainers[name] or ADDON.itemContainer(name, name ~= ADDON.utils.EMPTY_BAG_NAME, nil, name == ADDON.utils.EMPTY_BAG_NAME)
    return self.bagContainers[name]
end

function cache:UpdateSettings()
    for _, slots in pairs(self.items) do
        for _, item in pairs(slots) do
            item:Setup()
        end
    end
    for _, container in pairs(cache.bagContainers) do
        container:Setup()
        container:Arrange()
    end
end