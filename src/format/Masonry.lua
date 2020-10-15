local ADDON_NAME, ADDON = ...

ADDON.formatter = ADDON.formatter or {}

local typeSorter = function(A, B)
    if A == EMPTY then
        return false
    elseif B == EMPTY then
        return true
    elseif A == NEW then
        return true
    elseif B == NEW then
        return false
    elseif A == BAG_FILTER_JUNK then
        return true
    elseif B == BAG_FILTER_JUNK then
        return false
    else
        return A < B
    end
end

local itemSorter = function(A, B)
    if A.type == B.type then
        if A.quality == B.quality then
            if A.ilevel == B.ilevel then
                if A.name == B.name then
                    return (A.count or 1) > (B.count or 1)
                end
                return (A.name or '') < (B.name or '')
            end
            return (A.ilevel or 1) > (B.ilevel or 1)
        end
        return (A.quality or 0) > (B.quality or 0)
    end
    return typeSorter(A.type, B.type)
end

ADDON.formatter[ADDON.formats.MASONRY] = function(bag)
    table.sort(bag.items, itemSorter)
    for _, container in pairs(bag.titleContainers) do
        container:Hide()
    end
    local padding = bag.settings.padding
    local containerSpacing = bag.settings.containerSpacing
    local itemSpacing = bag.settings.itemSpacing
    local maxCols = bag.settings.maxColumns > 0 and bag.settings.maxColumns or 1

    -- Format the containers
    local containers = {}
    local cnt, x, y, currentType, container, prevItem
    for _, item in pairs(bag.items) do
        item:Hide()
        if item.type ~= currentType then
            currentType = item.type
            container = bag.titleContainers[currentType]
            cnt = 0
            x = 4 + padding
            y = 4 + padding + padding + container.name:GetHeight()
            tinsert(containers, container)
        end

        if not (item.type == EMPTY) or cnt == 0 then
            item:ClearAllPoints()
            item:SetPoint('TOPLEFT', container, 'TOPLEFT', x, -y)
            item:Show()
            if item.type == EMPTY then
                item.count = 1
            end
            prevItem = item

            x = x + itemSpacing + item:GetWidth()
            cnt = cnt + 1
            if cnt % maxCols == 0 then
                x = 4 + padding
                y = y + itemSpacing + item:GetHeight()
            end
        else
            prevItem:IncrementCount()
        end

        local cols = item.type == EMPTY and 1 or math.min(cnt, maxCols)
        local rows = item.type == EMPTY and 1 or math.ceil(cnt / maxCols)
        local width = padding * 2 + cols * item:GetWidth() + (cols - 1) * itemSpacing
        local height = padding * 3 + container.name:GetHeight() + rows * item:GetHeight() + (rows - 1) * itemSpacing
        container:SetSize(width+8, height+8)
        container.cols = cols
    end

    x = padding
    y = padding
    cnt = 0
    local prevHeight = 0
    local mW = 0
    local mH = 0
    for _, container in pairs(containers) do
        if cnt + container.cols > maxCols then
            y = y + prevHeight + containerSpacing
            x = padding
            mH = math.max(mH, y + padding - containerSpacing)
            cnt = 0
        end

        container:ClearAllPoints()
        container:SetPoint('TOPLEFT', x, -y)
        container:Show()

        x = x + container:GetWidth() + containerSpacing
        mW = math.max(mW, x + padding - containerSpacing)
        prevHeight = container:GetHeight()
        cnt = cnt + container.cols
    end
    bag:SetSize(mW, mH + prevHeight + padding + 4)
end
