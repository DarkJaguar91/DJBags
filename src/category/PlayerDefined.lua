local ADDON_NAME, ADDON = ...

DJBags_AddCategoryFilter(function(bag, slot)
    local _, _, _, _, _, _, _, _, _, id = GetContainerItemInfo(bag, slot)

    return DJBags_DB_Char.categories[id] or DJBags_DB.categories[id]
end)

function ADDON:GetAllPlayerDefinedCategories()
	local flags = {}
	local output = {}

	for k, v in pairs(DJBags_DB.categories) do
		if not flags[v] then
			flags[v] = true
			tinsert(output, v)
		end
	end

	for k, v in pairs(DJBags_DB_Char.categories) do
		if not flags[v] then
			flags[v] = true
			tinsert(output, v)
		end
	end

	table.sort(output)
	return output
end