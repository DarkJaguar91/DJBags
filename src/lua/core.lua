local NAME, ADDON = ...

local core = {}

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    ADDON.settings:Init()
    ADDON.bagController:Init()

    ADDON.events:Remove('ADDON_LOADED', self)
end

ADDON.events:Add('ADDON_LOADED', core)

SLASH_DJBAGS1 = '/djb';
function SlashCmdList.DJBAGS(msg, editbox)
    ADDON.bagController:Open()
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end