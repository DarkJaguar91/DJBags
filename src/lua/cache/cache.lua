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
    self.items[bag][slot] = self.items[bag][slot] or ADDON:NewItem(bag, slot)
    return self.items[bag][slot]
end

function cache:GetItemContainer(bag, name)
    if bag == BANK_CONTAINER or bag > NUM_BAG_SLOTS then
        self.bankContainers[name] = self.bankContainers[name] or ADDON:NewItemContainer(name)
        DJBagsBankContainer:AddItem(self.bankContainers[name])
        return self.bankContainers[name]
    elseif bag == REAGENTBANK_CONTAINER then
        self.reagentContainers[name] = self.reagentContainers[name] or ADDON:NewItemContainer(name)
        DJBagsReagentContainer:AddItem(self.reagentContainers[name])
        return self.reagentContainers[name]
    else
        self.bagContainers[name] = self.bagContainers[name] or ADDON:NewItemContainer(name)
        DJBagsBagContainer:AddItem(self.bagContainers[name])
        return self.bagContainers[name]
    end
end