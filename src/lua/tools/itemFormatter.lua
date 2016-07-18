local NAME, ADDON = ...

local itemSorter = function (A, B)
    if A.quality == B.quality then
        if A.ilevel == B.ilevel then
            return A.name < B.name
        end
        return A.ilevel > B.ilevel
    end
    return A.quality > B.quality
end

local function alreadySorted(frame, max, vert)
    if frame.arranged and frame.max == max and frame.vert == vert then
        return true
    end
    return false
end

function ADDON:ArrangeItemContainer(frame, max, vert, maxCnt)
    if frame:IsEmpty() or alreadySorted(frame, max, vert) then return end

    local itemCount = maxCnt or frame:GetCount()
    local cnt = 0

    for item in ADDON:PairsByKey(frame.items, itemSorter) do
        if maxCnt and cnt >= maxCnt then
            item:Hide()
        else
            item:Show()
            local row = cnt % max
            local col = math.floor(cnt / max)

            local colPos = (frame.spacing + item:GetWidth()) * col
            local rowPos = (frame.spacing + item:GetWidth()) * row

            item:SetPoint('TOPLEFT', vert and colPos or rowPos, -(vert and rowPos or colPos))

            cnt = cnt + 1
            if maxCnt and cnt == maxCnt then
                item:SetItemCount(frame:GetCount() - cnt + 1)
            end
        end
    end

    local colSize = math.ceil(itemCount / max) * (next(frame.items):GetWidth() + frame.spacing) - frame.spacing
    local rowSize = max * (frame.spacing + next(frame.items):GetWidth()) - frame.spacing

    frame:SetSize(
        (vert and colSize or rowSize) + frame.padding * 2,
        (vert and rowSize or colSize) + frame.padding * 2
    )
end