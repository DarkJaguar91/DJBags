local ADDON_NAME, ADDON = ...

DJBags_AddCategoryFilter(function(bag, slot)
	if DJBagsTooltip:IsItemBOE(bag, slot) then
        return ITEM_BIND_ON_EQUIP
    end
end, ITEM_BIND_ON_EQUIP)

DJBags_AddCategoryFilter(function(bag, slot)
	-- Important to do BnetAccount bound first because the text "Blizzard Account Bound" contains "Account Bound"
    if DJBagsTooltip:IsItemBOBA(bag, slot) then
    	return ITEM_BNETACCOUNTBOUND
    end
	if DJBagsTooltip:IsItemBOA(bag, slot) then
        return ITEM_ACCOUNTBOUND
    end
end, ITEM_ACCOUNTBOUND)
