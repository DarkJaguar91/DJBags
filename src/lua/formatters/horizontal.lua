local NAME, ADDON = ...

ADDON.formatters = ADDON.formatters or {}

ADDON.formatters['horizontal'] = {}

local formatter = ADDON.formatters['horizontal']
formatter.__index = formatter

function formatter:Format(container)
    local settings = ADDON.settings.formatter.horizontal

    local list = container.containers

    local maxCols = settings.cols
    local h = container.padding

    local x = container.padding
    local mH = 0
    local mW = 0
    local cnt = 0
    local lastH = 0

    for v in ADDON.utils:PairsByKey(list, ADDON.sorters.containers[settings.sorter]) do
        if v:IsEmpty() then
            v:Hide()
        else
            v:Show()
            local numItems = v.name == EMPTY and 1 or v:Count()

            if cnt ~= 0 and (cnt + numItems) > maxCols then
                x = container.padding
                h = h + mH + container.spacing
                cnt = 0
                mH = 0
            end

            if numItems > maxCols then
                v:Arrange(maxCols)
            else
                v:Arrange(numItems)
            end

            v:SetParent(container)
            v:ClearAllPoints()
            v:SetPoint('TOPLEFT', x, -h)

            mH = math.max(mH, v:GetHeight())
            mW = math.max(mW, x + v:GetWidth())
            x = x + container.spacing + v:GetWidth()

            cnt = cnt + numItems
            lastH = v:GetHeight()
        end
    end

    container:SetSize(
        mW + container.padding,
        h + container.padding + lastH
    )
end