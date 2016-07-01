local NAME, ADDON = ...

ADDON.settings = ADDON.settings or {}

ADDON.settings.categories = {
    subClass = {
        [LE_ITEM_CLASS_ARMOR] = false,
        [LE_ITEM_CLASS_CONSUMABLE] = true,
        [LE_ITEM_CLASS_GEM] = false,
        [LE_ITEM_CLASS_GLYPH] = false,
        [LE_ITEM_CLASS_ITEM_ENHANCEMENT] = false,
        [LE_ITEM_CLASS_MISCELLANEOUS] = true,
        [LE_ITEM_CLASS_RECIPE] = false,
        [LE_ITEM_CLASS_TRADEGOODS] = true,
        [LE_ITEM_CLASS_WEAPON] = false,
    },
    userDefined = {
    }
}

