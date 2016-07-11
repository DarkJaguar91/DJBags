local NAME, ADDON = ...

ADDON.settings = ADDON.settings or {}

ADDON.settings.formatter = {
    vertical = {
        sorter = 'defaultVertical',
        cols = 4,
        maxHeight = 50,
    },
    horizontal = {
        sorter = 'defaultHorizontal',
        cols = 12,
    },
}

