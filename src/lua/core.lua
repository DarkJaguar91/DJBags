local NAME, ADDON = ...

local core = {}

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    ADDON.settings:Init()
    ADDON.bagController:Init()
    ADDON.bankController:Init()

    ADDON.events:Remove('ADDON_LOADED', self)
end

ADDON.events:Add('ADDON_LOADED', core)

--region Bag commands

function DJBags_ItemsCleared()
    ADDON.bagController:OnItemsCleared()
    ADDON.bankController:OnItemsCleared()
end

ToggleAllBags = function()
    ADDON.bagController:Toggle()
end

ToggleBag = function(id)
    if id < 5 and id > -1 then
        ADDON.bagController:Toggle()
    end
end

ToggleBackpack = function()
    ADDON.bagController:Toggle()
end

OpenAllBags = function()
    ADDON.bagController:Open()
end

OpenBackpack = function()
    ADDON.bagController:Open()
end

CloseAllBags = function()
    ADDON.bagController:Close()
end

CloseBackpack = function()
    ADDON.bagController:Close()
end

--endregion

SLASH_DJBAGS1, SLASH_DJBAGS2, SLASH_DJBAGS3, SLASH_DJBAGS4 = '/djb', '/dj', '/djbags', '/db';
function SlashCmdList.DJBAGS(msg, editbox)
    DJBagsSettingsContainer:Show()
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end