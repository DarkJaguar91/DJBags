local NAME, ADDON = ...

ADDON.sorters = ADDON.sorters or {}

ADDON.sorters.items = {
    ['default'] = function(A, B)
        if A.quality == B.quality then
            if A.ilevel == B.ilevel then
                return A.name < B.name
            end
            return A.ilevel > B.ilevel
        end
        return A.quality > B.quality
    end,
}