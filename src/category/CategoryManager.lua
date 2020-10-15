local ADDON_NAME, ADDON = ...

ADDON.categoryManager = {}
local categoryManager = ADDON.categoryManager
categoryManager.__index = categoryManager
categoryManager.filters = {}

function DJBags_AddCategoryFilter(filter, name)
	assert(filter, 'Filter is required')
  assert(name, 'A name for the filter is required')

	categoryManager.filters[name] = filter
end

function categoryManager:GetTitle(item, filters)
	  local bag = item:GetParent():GetID()
    local slot = item:GetID()

    if item.id then
        local isInSet, setName = GetContainerItemEquipmentSetInfo(bag, slot)

        if item.quality == Enum.ItemQuality.Poor then
            return BAG_FILTER_JUNK
        end

        if isInSet then
            return setName
        end

        if bag >= 0 and bag <= NUM_BAG_SLOTS and (C_NewItems.IsNewItem(bag, slot) or DJBags_DB_Char.newItems[item.id]) then
          DJBags_DB_Char.newItems[item.id] = true
          return NEW
        end

       	for k, v in pairs(self.filters) do
          if (filters[k] == nil or filters[k]) then
         		local output = v(bag, slot)
         		if output then
         		 	return output
       		  end
          end
       	end

        return item.class
    end
    return EMPTY
end
