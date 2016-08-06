local NAME, ADDON = ...

ADDON.format = ADDON.format or {}

local sorter = function(A, B)
    if A.name.text == EMPTY then
        return true
    elseif B.name.text == EMPTY then
        return false
    elseif A.name.text == NEW then
        return false
    elseif B.name.text == NEW then
        return true
    elseif A.name.text == BAG_FILTER_JUNK then
        return false
    elseif B.name.text == BAG_FILTER_JUNK then
        return true
    else
        return A.name.text > B.name.text
    end
end

ADDON.format[DJBags_FORMATTER_BOX] = function(frame, _, maxHeight, cols, _, override)
    local x = 0
    local y = 0
    local width = 0
    local height = 0

    for item in ADDON:PairsByKey(frame.items, sorter) do
        if item:IsEmpty() or ADDON.settings:IsContainerHidden(item.name.text) then
            item:Hide()
        else
            item:ClearAllPoints()
            item:Arrange(cols, nil, (item.name:GetText() == EMPTY and 1), override, true)
            item:Show()
            if (y + item:GetHeight() + frame.spacing) > (maxHeight / 100 * GetScreenHeight()) then
                y = 0
                x = x - item:GetWidth() - frame.spacing
            end

            item:SetPoint('BOTTOMRIGHT', x, y)

            height = math.max(height, y + item:GetHeight() + frame.padding * 2)
            width = math.max(width, -x + item:GetWidth() + frame.padding * 2)
            y = y + frame.spacing + item:GetHeight()
        end
    end

    frame:SetSize(width, height)
end