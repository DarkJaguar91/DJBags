local ADDON_NAME, ADDON = ...

-- Formatter types
ADDON.formats = {
	MASONRY = 0,
}

-- Locale
local locale = {
	enUS = {
		allCharacters = 'All Characters?'
	}
}

ADDON.locale = locale[GetLocale()] or locale['enUS']
