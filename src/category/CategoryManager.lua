local ADDON_NAME, ADDON = ...

ADDON.categoryManager = {}
local categoryManager = ADDON.categoryManager
categoryManager.__index = categoryManager
categoryManager.filters = {}

function DJBags_AddCategoryFilter(filter, name)
	assert(filter, 'Filter is required')

	if not name then
		table.insert(categoryManager.filters, filter)
	else
		categoryManager.filters[name] = filter
	end
end

function categoryManager:GetTitle(item)
	local bag = item:GetParent():GetID()
    local slot = item:GetID()

    if item.id then
        local isInSet, setName = GetContainerItemEquipmentSetInfo(bag, slot)

        if item.quality == LE_ITEM_QUALITY_POOR then
            return BAG_FILTER_JUNK
        end

        if isInSet then
            return setName
        end

        if bag >= 0 and bag <= NUM_BAG_SLOTS and C_NewItems.IsNewItem(bag, slot) then
            return NEW
        end

       	for k, v in pairs(self.filters) do
       		local output = v(bag, slot)
       		if output then
       			return output
       		end
       	end

        return item.class
    end
    return EMPTY
end