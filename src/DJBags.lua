local ADDON_NAME, ADDON = ...
local eventManager = ADDON.eventManager

local core = {}

local function migrate_09(db, isGlobal)
    if db.VERSION < 0.9 then
        db.VERSION = 0.9
        db.useSubClass = {}
        db.formats = {}

        if isGlobal then
            db.formats = {
                bag = ADDON.formats.MASONRY,
                bank = ADDON.formats.MASONRY,
                reagents = ADDON.formats.MASONRY
            }
        end
    end
end

local function migrate()
    -- V 0.76 or less must reset settings
    if (DJBags_DB == nil or not DJBags_DB.VERSION or DJBags_DB.VERSION < 0.76) then
        DJBags_DB = {
            VERSION = 0.8,
            categories = {
            },
            newItems = {},
            useSubClass = {}
        }
    end
    if (DJBags_DB_Char == nil or not DJBags_DB_Char.VERSION or DJBags_DB_Char.VERSION < 0.76) then
        DJBags_DB_Char = {
            VERSION = 0.8,
            categories = {
            },
            newItems = {},
            useSubClass = {}
        }
    end

    -- Version 0.9 - adding extra settings
    migrate_09(DJBags_DB, true)
    migrate_09(DJBags_DB_Char)
end

function core:ADDON_LOADED(name)
	if ADDON_NAME ~= name then return end

    migrate()

    eventManager:Remove('ADDON_LOADED', core)
    eventManager:Add("AUCTION_HOUSE_SHOW", core)
    eventManager:Add("AUCTION_HOUSE_CLOSED", core)
    eventManager:Add("GUILDBANKFRAME_OPENED", core)
    eventManager:Add("GUILDBANKFRAME_CLOSED", core)
end

function core:AUCTION_HOUSE_SHOW()
    DJBagsBag:Show()
end

function core:AUCTION_HOUSE_CLOSED()
    DJBagsBag:Hide()
end

function core:GUILDBANKFRAME_OPENED()
    DJBagsBag:Show()
end

function core:GUILDBANKFRAME_CLOSED()
    DJBagsBag:Hide()
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

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

SLASH_DJBAGS1, SLASH_DJBAGS2, SLASH_DJBAGS3, SLASH_DJBAGS4 = '/djb', '/dj', '/djbags', '/db';
function SlashCmdList.DJBAGS(msg, editbox)
    for key, value in pairs(_G) do
        if type(value) ~= 'table' and
           tostring(value):find("Crafting") then
            print(dump(key) .. ' : ' .. dump(value))
        end
    end
    -- OpenAllBags()
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end
