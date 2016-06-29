-- local NAME, ADDON = ...

function class(...)
    local arg1 = ...
    local base
    if type(arg1) == 'table' and arg1.__djclass then
        base = arg1
    end

    local c = {}
    c.__index = c
    c.__djclass = true
    c.type = select(base and 2 or 1, ...) or base and base.type
    c.inherits = select(base and 3 or 2, ...) or base and base.inherits

    if base then
        for k, v in pairs(base) do
            c[k] = v
        end
    end

    setmetatable(c, {
        __call = function(table, ...)
            local name
            if table.type then
                name = ...
                assert(name and type(name) == 'string', 'DJClass needs a name (first argument) when creating an object for WoWs frame content')
            end
            local obj
            if name then
                obj = {} -- CreateFrame(name, table.type, UIParent, table.inherits)
            else
                obj = {}
            end

            for k, v in pairs(table) do
                obj[k] = v
            end

            if obj.init and type(obj.init) == 'function' then
                obj:init(select(name and 2 or 1, ...))
            end

            return obj
        end
    })

    return c
end

local A = class('FRAME')
function A:init(string)
    self.name = string
end

local B = class(A)
function B:init(name, text)
    A.init(self, name)
    self.text = text
end

function B:print()
    print(self.name, self.text)
end

print("\nstart\n\n")

local b = B('Namerize', 'Text', 'Face')
b:print()