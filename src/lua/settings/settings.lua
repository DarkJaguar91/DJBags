local NAME, ADDON = ...

local DBVERSION = 1

ADDON.settingsController = {}
local settings = ADDON.settingsController
settings.__index = settings

--region Events

function settings:Init()
    self:GetCharacterSettings()

    self.screen = ADDON.settingsEditor()

    ADDON.eventManager:AddEvent(self, "SETTINGS_UPDATE")
end

function settings:ShowSettings()
    self.screen:Show()
end

function settings:SETTINGS_UPDATE()
    local realm = GetRealmName()
    local player = UnitName("player")

    if not DJBagsConfig then
        DJBagsConfig = {}
    end
    if not DJBagsConfig[realm] then
        DJBagsConfig[realm] = {}
    end
    DJBagsConfig[realm][player] = ADDON.settings

    ADDON.settingsEditor:UpdateSettings()
end

function settings:GetCharacterSettings()
    local realm = GetRealmName()
    local player = UnitName("player")

    ADDON.settings.version = DBVERSION
    if DJBagsConfig and DJBagsConfig[realm] and DJBagsConfig[realm][player] then
        if not DJBagsConfig[realm][player].version or DJBagsConfig[realm][player].version < DBVERSION then
            DJBagsConfig[realm][player] = self:migrateDb(DJBagsConfig[realm][player].version or 0, DJBagsConfig[realm][player])
        end
        ADDON.settings = DJBagsConfig[realm][player]
    end
end

settings.migrateFunc = {}
settings.migrateFunc[1] = function ()
    return ADDON.settings
end

function settings:migrateDb(version, old)
    while version < DBVERSION do
        version = version + 1
        old = self.migrateFunc[version](old)
    end
    return old
end