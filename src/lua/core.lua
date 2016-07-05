local NAME, ADDON = ...

ADDON.core = {}
ADDON.core.__index = ADDON.core
local core = ADDON.core

--region Events

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    ADDON.settingsController:Init()

    ADDON.bag:Init()
    ADDON.bank:Init()

    ADDON.eventManager:AddEvent(self, "SETTINGS_UPDATE")
    ADDON.eventManager:RemoveEvent(self, 'ADDON_LOADED')
end

function core:SETTINGS_UPDATE(arrange)
    ADDON.cache:UpdateSettings(arrange)
    ADDON.bag:UpdateSettings(arrange)
    ADDON.bank:UpdateSettings(arrange)
    ADDON.categoryDialog:Setup()
end

ADDON.eventManager:AddEvent(core, 'ADDON_LOADED')

--region Bag commands

ToggleAllBags = function()
    ADDON.bag:Toggle()
end

ToggleBag = function(id)
    if id < 5 and id > -1 then
        ADDON.bag:Toggle()
    end
end

ToggleBackpack = function()
    ADDON.bag:Toggle()
end

OpenAllBags = function()
    ADDON.bag:Open()
end

OpenBackpack = function()
    ADDON.bag:Open()
end

CloseAllBags = function()
    ADDON.bag:Close()
end

CloseBackpack = function()
    ADDON.bag:Close()
end

--endregion

--region Slash Commands

SLASH_DJBAGS1, SLASH_DJBAGS2 = '/db', '/djbags';
function SlashCmdList.DJBAGS(msg, editbox)
    ADDON.settingsController:ShowSettings()
end

SLASH_TDJBAGS1, SLASH_TDJBAGS2 = '/tt', '/ttt';
function SlashCmdList.TDJBAGS(msg, editbox)
    for k, v in pairs(C_NewItems) do
            print(k, v)
    end
end

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox)
    ReloadUI()
end

--endregion