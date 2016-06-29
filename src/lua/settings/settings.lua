local NAME, ADDON = ...

ADDON.settingsController = {}
local settings = ADDON.settingsController
settings.__index = settings

--region Events

function settings:Init()
    self:GetCharacterSettings()
end

function settings:GetCharacterSettings()
    local realm = GetRealmName()
    local player = UnitName("player")

    if DJBagsConfig and DJBagsConfig[realm] and DJBagsConfig[realm][player] then
        --        ADDON.settings = DJBagsConfig[realm][player]
    end
end