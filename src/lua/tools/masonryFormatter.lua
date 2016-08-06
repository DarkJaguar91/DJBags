local NAME, ADDON = ...

ADDON.format = ADDON.format or {}

local sorter = function(A, B)
    if A.name.text == EMPTY then
        return false
    elseif B.name.text == EMPTY then
        return true
    elseif A.name.text == NEW then
        return true
    elseif B.name.text == NEW then
        return false
    elseif A.name.text == BAG_FILTER_JUNK then
        return true
    elseif B.name.text == BAG_FILTER_JUNK then
        return false
    else
        return A.name.text < B.name.text
    end
end

ADDON.format[DJBags_FORMATTER_MASONRY] = function(frame, maxItems, _, _, vert, override)
    local h = 0
    local x = 0
    local mH = 0
    local mW = 0
    local cnt = 0
    local lastH = 0

    for v in ADDON:PairsByKey(frame.items, function(A, B)
        local ans = sorter(A, B)
        if vert then
            return not ans
        end
        return ans
    end) do
        if v:IsEmpty() or ADDON.settings:IsContainerHidden(v.name.text) then
            v:Hide()
        else
            v:Show()
            local numItems = v.name:GetText() == EMPTY and 1 or v:GetCount()

            if cnt ~= 0 and (cnt + numItems) > maxItems then
                x = 0
                h = h + mH + frame.spacing
                cnt = 0
                mH = 0
            end

            if numItems > maxItems then
                v:Arrange(maxItems, vert, nil, override)
            else
                v:Arrange(numItems, vert, (v.name:GetText() == EMPTY and 1), override)
            end

            v:ClearAllPoints()
            v:SetPoint(vert and 'BOTTOMRIGHT' or 'TOPLEFT', vert and -h or x, vert and x or -h)

            mH = math.max(mH, vert and v:GetWidth() or v:GetHeight())
            mW = math.max(mW, x + (vert and v:GetHeight() or v:GetWidth()))
            x = x + frame.spacing + (vert and v:GetHeight() or v:GetWidth())

            cnt = cnt + numItems
            lastH = vert and v:GetWidth() or v:GetHeight()
        end
    end

    frame:SetSize((vert and (h + lastH) or mW) + frame.padding * 2,
        (vert and mW or (h + lastH)) + frame.padding * 2)
end