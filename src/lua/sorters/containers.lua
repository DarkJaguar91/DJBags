local NAME, ADDON = ...

ADDON.sorters = ADDON.sorters or {}

ADDON.sorters.containers = {
    ['default'] = function(A, B)
        if A.name == ADDON.utils.EMPTY_BAG_NAME then
            return true
        elseif B.name == ADDON.utils.EMPTY_BAG_NAME then
            return false
        else
            return A.name > B.name
        end
    end,
}