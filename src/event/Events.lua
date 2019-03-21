local ADDON_NAME, ADDON = ...

ADDON.events = {}
local events = ADDON.events
events.__index = events

-- Cleanup
events.ITEMS_CLEARED = 'EVENT_DJBAGS_ITEMS_CLEARED'
