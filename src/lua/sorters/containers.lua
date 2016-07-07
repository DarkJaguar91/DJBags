local NAME, ADDON = ...

ADDON.sorters = ADDON.sorters or {}

ADDON.sorters.containers = {
    ['default'] = function(A, B)
        if A.name == EMPTY then
            return true
        elseif B.name == EMPTY then
            return false
        else
            return A.name > B.name
        end
    end,
}