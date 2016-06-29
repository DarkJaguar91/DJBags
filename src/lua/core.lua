local NAME, ADDON = ...

ADDON.core = {}
ADDON.core.__index = ADDON.core
local core = ADDON.core

--region Events

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    ADDON.settingsController:Init()

    ADDON.bag:Init()

    ADDON.eventManager:RemoveEvent(self, 'ADDON_LOADED')
end

ADDON.eventManager:AddEvent(core, 'ADDON_LOADED')

--region Slash Commands

SLASH_DJBAGS1, SLASH_DJBAGS2 = '/db', '/djbags'; -- 3.
function SlashCmdList.DJBAGS(msg, editbox) -- 4.
--    ADDON.bag:Open()
ADDON.categoryDialog(12)
ADDON.eventManager:AddEvent('MyRandonEvent')
end

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox) -- 4.
ReloadUI()
end

--endregion