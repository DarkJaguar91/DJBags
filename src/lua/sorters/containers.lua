local NAME, ADDON = ...

ADDON.sorters = ADDON.sorters or {}

ADDON.sorters.containers = {
    ['defaultVertical'] = function(A, B)
        if A.name == EMPTY then
            return true
        elseif B.name == EMPTY then
            return false
        elseif A.name == NEW then
            return false
        elseif B.name == NEW then
            return true
        elseif A.name == BAG_FILTER_JUNK then
            return false
        elseif B.name == BAG_FILTER_JUNK then
            return true
        else
            return A.name > B.name
        end
    end,
    ['defaultHorizontal'] = function(A, B)
        if A.name == EMPTY then
            return false
        elseif B.name == EMPTY then
            return true
        elseif A.name == NEW then
            return true
        elseif B.name == NEW then
            return false
        elseif A.name == BAG_FILTER_JUNK then
            return true
        elseif B.name == BAG_FILTER_JUNK then
            return false
        else
            return A.name < B.name
        end
    end,
}