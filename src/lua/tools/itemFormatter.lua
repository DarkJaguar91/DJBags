local NAME, ADDON = ...

local itemSorter = function (A, B)
    if A.quality == B.quality then
        if A.ilevel == B.ilevel then
            if A.name == B.name then
                return A.count > B.count
            end
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

function ADDON:ArrangeItemContainer(frame, max, vert, maxCnt, force)
    if frame:IsEmpty() or alreadySorted(frame, max, vert) then return end

    local itemCount = 0
    local cnt = 0

    local items = {}
    for item in ADDON:PairsByKey(frame.items, itemSorter) do
        tinsert(items, item)
    end

    local index = 1
    while (index <= #items) do
        local item = items[index]
        local nItem = items[index + 1]
        local totalCnt = 0
        local mustStackAll = ADDON.settings:GetSettings(DJBags_TYPE_MAIN)[DJBags_SETTING_STACK_ALL]
        while mustStackAll and nItem and nItem.id == item.id do
            totalCnt = totalCnt + nItem.count
            index = index + 1
            nItem:Hide()
            nItem = items[index+1]
        end
        if totalCnt > 0 then
            item:SetItemCount(item.count + totalCnt)
        end

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
            itemCount = itemCount + 1
        end
        index = index + 1
    end

    local colSize = math.ceil(itemCount / max) * (next(frame.items):GetWidth() + frame.spacing) - frame.spacing
    local numCols = force and max or (maxCnt and maxCnt or (itemCount < max and itemCount or max))
    local rowSize = numCols * (frame.spacing + next(frame.items):GetWidth()) - frame.spacing

    frame:SetSize(
        (vert and colSize or rowSize) + frame.padding * 2,
        (vert and rowSize or colSize) + frame.padding * 2
    )
end