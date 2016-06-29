local NAME, ADDON = ...

ADDON.container = {}
ADDON.container.__index = ADDON.container

local container = ADDON.container
setmetatable(container, {
    __call = function(tbl, name, parent)
        local frame = CreateFrame('FRAME', 'DJBagContainer_' .. (name or ADDON.uuid()), parent or UIParent)
        frame.name = name

        for key, value in pairs(tbl) do
            frame[key] = value
        end

        frame:Setup()

        return frame
    end
})

function container:Setup()
    local settings = ADDON.settings.container

    self:SetBackdrop({
        -- TODO remove all hardcoded shit
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = settings.borderWidth,
    })
    self:SetBackdropColor(unpack(settings.backgroundColor))
    self:SetBackdropBorderColor(unpack(settings.borderColor))
end