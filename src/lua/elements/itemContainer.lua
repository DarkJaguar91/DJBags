local NAME, ADDON = ...

ADDON.itemContainer = {}
ADDON.itemContainer.__index = ADDON.itemContainer
ADDON.itemContainer.__class = 'ItemContainer'

local container = ADDON.itemContainer
setmetatable(container, {
    __call = function(tbl, name, hasTitle, parent, max)
        local frame = ADDON.container(name, parent)
        frame.max = max

        for k, v in pairs(tbl) do
            frame[k] = v
        end

        frame:Init(hasTitle)
        frame:Setup()

        return frame
    end
})

function container:Init(hasTitle)
    self.items = {}
    if hasTitle == nil or hasTitle then
        self.title = self:CreateFontString(self:GetName() .. 'Title', 'OVERLAY')
    end
end

function container:Setup()
    ADDON.container.Setup(self)

    local settings = ADDON.settings.itemContainer

    self.padding = settings.padding
    self.spacing = settings.spacing
    self.cols = settings.cols
    self.sortFunction = ADDON.sorters.items[settings.sortFunction]

    if self.title then
        self.title:SetFont(settings.font, settings.fontSize, '')
        self.title:SetText(self.name)
        self.title:SetTextColor(unpack(settings.fontColor))
        self.title:ClearAllPoints()
        self.title:SetPoint('TOPLEFT', self.padding, -self.padding)
        self.title:SetPoint('TOPRIGHT', -self.padding, -self.padding)
        self.title.margin = settings.titleMargin
    end
end

function container:AddItem(item)
    if item:GetParent() ~= self then
        self.items[item] = true
    end
end

function container:RemoveItem(item)
    self.items[item] = nil
end

function container:Arrange()
    local list = self.items

    local x = self.padding
    local y = -self.padding - (self.title and (self.title:GetStringHeight() + self.title.margin) or 0)
    local width
    local height = 0

    local cnt = 0

    for item, _ in ADDON.utils:PairsByKey(list, self.sortFunction) do
        item:ClearAllPoints()
        item:SetParent(self)

        if self.max and cnt >= self.cols then
            item:Hide()
        else
            item:SetPoint('TOPLEFT', x, y)
            item:Show()

            width = width or self.cols * (self.spacing + item:GetWidth()) - self.spacing + self.padding * 2
            height = math.max(height, -y + item:GetHeight() + self.padding)

            cnt = cnt + 1

            if cnt % self.cols == 0 then
                y = y - self.spacing - item:GetHeight()
                x = self.padding
            else
                x = x + self.spacing + item:GetWidth()
            end
        end
    end
    if width then
        self:SetSize(width, height)
    end
end

function container:IsEmpty()
    return next(self.items) == nil
end