local ADDON_NAME, ADDON = ...

DJBags_AddCategoryFilter(function(bag, slot)
	if DJBagsTooltip:IsItemArtifactPower(bag, slot) then
        return ARTIFACT_POWER
    end
end)