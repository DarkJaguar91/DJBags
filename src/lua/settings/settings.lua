local NAME, ADDON = ...

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

    ADDON.globalCategories = {}
    if DJBagsConfig then
        if DJBagsConfig[realm] and DJBagsConfig[realm][player] then
            local userSettings = DJBagsConfig[realm][player]
            self:MigrateSettings(userSettings, ADDON.settings)
            ADDON.settings = userSettings
        end
        ADDON.globalCategories = DJBagsConfig.globalCategories or {}
    end
end

function settings:MigrateSettings(table, default)
    for k, v in pairs(default) do
        if table[k] then
            if type(v) ~= type(table[k]) then
                table[k] = v
            elseif type(v) == 'table' then
                self:MigrateSettings(table[k], v)
            end
        else
            table[k] = v
        end
    end
    for k, v in pairs(table) do
        if not default[k] and type(v) == 'table' then
            table[k] = nil
        end
    end
end