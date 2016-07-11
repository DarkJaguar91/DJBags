local NAME, ADDON = ...

ADDON.formatters = ADDON.formatters or {}

ADDON.formatters['vertical'] = {}

local formatter = ADDON.formatters['vertical']
formatter.__index = formatter

function formatter:Format(container)
    local settings = ADDON.settings.formatter.vertical

    local list = container.containers

    local x = -container.padding
    local y = container.padding
    local width = 0
    local height = 0

    for item in ADDON.utils:PairsByKey(list, ADDON.sorters.containers[settings.sorter]) do
        item:Arrange(settings.cols)
        item:ClearAllPoints()
        item:SetParent(container)

        if item:IsEmpty() then
            item:Hide()
        else
            item:Show()
            if (y + item:GetHeight() + container.spacing) > (settings.maxHeight / 100 * GetScreenHeight()) then
                y = container.padding
                x = x - item:GetWidth() - container.spacing
            end

            item:SetPoint('BOTTOMRIGHT', x, y)

            height = math.max(height, y + item:GetHeight() + container.padding)
            width = math.max(width, -x + container.padding + item:GetWidth())
            y = y + container.spacing + item:GetHeight()
        end
    end

    container:SetSize(width, height)
end