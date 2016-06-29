local NAME, ADDON = ...

ADDON.settingsController = {}
local settings = ADDON.settingsController
settings.__index = settings

--region Events

function settings:Init()
    self:GetCharacterSettings()

    ADDON.eventManager:AddEvent("SETTING_UPDATE")
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
    --    DJBagsConfig[player] = ADDON.settings
end

function settings:GetCharacterSettings()
    local realm = GetRealmName()
    local player = UnitName("player")

    if DJBagsConfig and DJBagsConfig[realm] and DJBagsConfig[realm][player] then
        --        ADDON.settings = DJBagsConfig[realm][player]
    end
end