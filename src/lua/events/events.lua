local NAME, ADDON = ...

ADDON.events = CreateFrame('FRAME')

local events = ADDON.events
events.list = {}

events:SetScript('OnEvent', function(self, event, ...)
    self:Fire(event, ...)
end)

function events:Fire(event, ...)
    if not event or not self.list[event] then return end

    for obj in pairs(self.list[event]) do
        obj[event](obj, ...)
    end
end

function events:Add(event, obj)
    if not event or not obj or not obj[event] then return end

    if not self.list[event] then
        self.list[event] = {}

        self:RegisterEvent(event)
    end

    self.list[event][obj] = true
end

function events:Remove(event, obj)
    if not event or not obj or not self.list[event] or not self.list[event][obj] then return end

    self.list[event][obj] = nil

    if next(self.list[event]) == nil and ADDON:Count(self.list[event]) == 0 then
        self.list[event] = nil
        self:UnregisterEvent(event)
    end
end