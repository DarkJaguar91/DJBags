local ADDON_NAME, ADDON = ...

function try(f, catch_f)
    local status, exception = pcall(f)
    if not status then
        catch_f(exception)
    end
end

local eventManager = CreateFrame('FRAME')
ADDON.eventManager = eventManager
eventManager.events = {}

eventManager:SetScript('OnEvent', function(self, event, ...)
    self:Fire(event, ...)
end)

function eventManager:Add(event, object)
    assert(event, 'Event required')
    assert(object, 'Object required')
    assert(object[event], 'Object requires event method ' .. event)

    if not self.events[event] then
        self.events[event] = {}
        try(
            function() 
                self:RegisterEvent(event)
            end,
            function(_)
                -- do nothing for now
            end
        ) -- use pcall so that blizzard doesnt stop my personal events
    end

    self.events[event][object] = true
end

function eventManager:Fire(event, ...)
    assert(event, 'No event to look for')
    -- assert(self.events[event], 'No object registered for event ' .. event) Rather change this to a warning

    if self.events[event] then
        for object in pairs(self.events[event]) do
            object[event](object, ...)
        end
    end
end

local function Count(table)
    local cnt = 0;

    for _ in pairs(table) do
        cnt = cnt + 1
    end

    return cnt
end

function eventManager:Remove(event, object)
    assert(event, 'Event required')
    assert(object, 'Object required')

    self.events[event][object] = nil

    if next(self.events[event]) == nil and Count(self.events[event]) == 0 then
        self.events[event] = nil

        try(
            function() 
                self:UnregisterEvent(event)
            end,
            function(_)
                -- do nothing for now
            end
        ) -- use pcall so that blizzard doesnt stop my personal events
        
    end
end
