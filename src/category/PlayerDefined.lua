local ADDON_NAME, ADDON = ...

DJBags_AddCategoryFilter(function(bag, slot)
    local _, _, _, _, _, _, _, _, _, id = GetContainerItemInfo(self:GetParent():GetID(), self:GetID())

    return DJBags_DB.category.all[id] or DJBags_DB.category.player[id]
end)
