local NAME, ADDON = ...

local eventFrame = CreateFrame("FRAME", "DJBagsEventsFrame", nil)
eventFrame:Hide()

eventFrame.types = {}

function eventFrame:FireEvent(event, ...)
    if not self.types[event] then return end

    for k, _ in pairs(self.types[event]) do
        if k[event] then
            k[event](k, ...)
        end
    end
end

eventFrame:SetScript("OnEvent", eventFrame.FireEvent)

function eventFrame:AddEvent(obj, event)
    if not obj[event] then return end

    if not self.types[event] or next(self.types[event]) == nil then
        self.types[event] = {}
        self:RegisterEvent(event)
    end

    self.types[event][obj] = true
end

function eventFrame:RemoveEvent(obj, event)
    if not self.types[event] and not self.types[event][obj] then return end

    self.types[event][obj] = nil

    if next(self.types[event]) == nil then
        self:UnregisterEvent(event)
    end
end

ADDON.eventManager = eventFrame