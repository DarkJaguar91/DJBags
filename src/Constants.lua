local ADDON_NAME, ADDON = ...

-- Formatter types
local formats = {
	MASONRY = 0,
	MASONRY_STACKED = 1,
}
ADDON.formats = formats

-- Locale
local locale = {
	enUS = {
		ALL_CHARACTERS = 'All Characters?',
		COLUMNS = 'Columns: %d',
		CATEGORY_SETTINGS = "Category Settings",
		CATEGORY_SETTINGS_FOR = "%s Category Settings",
		FORMATS = {
			[formats.MASONRY] = "Masonry",
			[formats.MASONRY_STACKED]  = "Massonry Extra Stacking",
		}
	}
}

ADDON.locale = locale[GetLocale()] or locale['enUS']

for k, v in pairs(ADDON.locale) do
	_G["DJBAGS_" .. k] = v
end
