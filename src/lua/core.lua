local NAME, ADDON = ...

ADDON.core = {}
ADDON.core.__index = ADDON.core
local core = ADDON.core

--region Events

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    ADDON.settingsController:Init()

    ADDON.bag:Init()

    ADDON.eventManager:AddEvent(self, "SETTINGS_UPDATE")
    ADDON.eventManager:RemoveEvent(self, 'ADDON_LOADED')
end

function core:SETTINGS_UPDATE()
    ADDON.cache:UpdateSettings()
    ADDON.bag:UpdateSettings()
    ADDON.categoryDialog:Setup()
end

ADDON.eventManager:AddEvent(core, 'ADDON_LOADED')

--region Slash Commands

SLASH_DJBAGS1, SLASH_DJBAGS2 = '/db', '/djbags';
function SlashCmdList.DJBAGS(msg, editbox)
    ADDON.bag:Open()
end

SLASH_TDJBAGS1, SLASH_TDJBAGS2 = '/tt', '/ttt';
function SlashCmdList.TDJBAGS(msg, editbox)
    ADDON.settingsController:ShowSettings()
end

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox)
    ReloadUI()
end

--endregion