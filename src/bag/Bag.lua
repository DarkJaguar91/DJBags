local ADDON_NAME, ADDON = ...

local bag = {}
bag.__index = bag

function DJBagsRegisterBagBagContainer(self, bags)
    DJBagsRegisterBaseBagContainer(self, bags)

    for k, v in pairs(bag) do
        self[k] = v
    end
end

function bag:SortBags()    
    ADDON.eventManager:Remove('BAG_UPDATE', self)
    SortBags()
    ADDON.eventManager:Add('BAG_UPDATE', self)
end

function bag:ClearNewItems()
    DJBags_DB_Char.newItems = {}
    C_NewItems:ClearAll()
    self:Refresh()
end

function bag:BAG_UPDATE_DELAYED()
    if self.mainBar.bagBar then
        for _, bag in pairs(self.bags) do
            if bag > 0 then
                self.mainBar.bagBar['bag'..bag]:Update()
            end
        end
    end
end