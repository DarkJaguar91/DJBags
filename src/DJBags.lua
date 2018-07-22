local ADDON_NAME, ADDON = ...
local eventManager = ADDON.eventManager

local core = {}

function core:ADDON_LOADED(name)
	if ADDON_NAME ~= name then return end

    -- Default Settings
    DJBags_DB = DJBags_DB or {
            VERSION = 0.76,
            categories = {
            },
            newItems = {}
        }
        DJBags_DB_Char = DJBags_DB_Char or {
            categories = {
            },
            newItems = {}
        }
    if ((not DJBags_DB.VERSION) or DJBags_DB.VERSION < 0.76) then
        DJBags_DB = {
            VERSION = 0.76,
            categories = {
            },
            newItems = {}
        }
        DJBags_DB_Char = {
            categories = {
            },
            newItems = {}
        }
    end

	eventManager:Remove('ADDON_LOADED', core)
end

eventManager:Add('ADDON_LOADED', core)

ToggleAllBags = function()
    if DJBagsBag:IsVisible() then
        DJBagsBag:Hide()
    else
        DJBagsBag:Show()
    end
end

local oldToggle = ToggleBag
ToggleBag = function(id)
    if id < 5 and id > -1 then
        if DJBagsBag:IsVisible() then
            DJBagsBag:Hide()
        else
            DJBagsBag:Show()
        end
    else
        oldToggle(id)
    end
end

ToggleBackpack = function()
    if DJBagsBag:IsVisible() then
        DJBagsBag:Hide()
    else
        DJBagsBag:Show()
    end
end

OpenAllBags = function()
    DJBagsBag:Show()
end

OpenBackpack = function()
    DJBagsBag:Show()
end

CloseAllBags = function()
    DJBagsBag:Hide()
end

CloseBackpack = function()
    DJBagsBag:Hide()
end

SLASH_DJBAGS1, SLASH_DJBAGS2, SLASH_DJBAGS3, SLASH_DJBAGS4 = '/djb', '/dj', '/djbags', '/db';
function SlashCmdList.DJBAGS(msg, editbox)
	for i, v in pairs(DJBagsBank) do
        if (string.find(string.lower(tostring(i)), "event")) then
            print(i, v)
        end
    end
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end