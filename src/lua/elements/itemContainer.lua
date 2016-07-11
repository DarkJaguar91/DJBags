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
        self.title = self:CreateFontString(self:GetName() .. 'Title', 'OVERLAY', 'GameFontNormal')
        self.title.scriptHandler = CreateFrame('FRAME', 'DJBagsScriptHandler' .. self.name, self)
        self.title.scriptHandler:SetPoint('TOPLEFT')
        self.title.scriptHandler:SetPoint('TOPRight')
        self.title.scriptHandler:SetScript('OnEnter', self.TitleEnter)
        self.title.scriptHandler:SetScript('OnLeave', self.TitleLeave)
    end
end

function container:Setup()
    ADDON.container.Setup(self)

    local settings = ADDON.settings.itemContainer

    self.padding = settings.padding
    self.spacing = settings.spacing
    self.sortFunction = ADDON.sorters.items[settings.sortFunction]
    self.fontSize = settings.fontSize

    if self.title then
        local font, _, outline = self.title:GetFont()
        self.title:SetFont(font, settings.fontSize, outline)
        if not settings.showClassWithSub and string.match(self.name, '%a*_%a*') then
            local name = string.match(self.name, '%a*_(%a*)')
            self.title:SetText(name)
        else
            self.title:SetText(self.name)
        end
        self.title:SetMaxLines(1)
        self.title:SetTextColor(unpack(settings.fontColor))
        self.title:ClearAllPoints()
        self.title:SetPoint('TOPLEFT', 0, -self.padding)
        self.title.margin = settings.titleMargin
        self.title.scriptHandler:SetHeight(self.fontSize)
    end
end

function container:AddItem(item)
    self.items[item] = true
end

function container:RemoveItem(item)
    self.items[item] = nil
end

function container:Arrange(cols)
    local list = self.items

    local x = self.padding
    local y = -self.padding - (self.title and (self.fontSize + self.title.margin) or 0)
    local width
    local height = 0

    local cnt = 0

    for item, _ in ADDON.utils:PairsByKey(list, self.sortFunction) do
        item:ClearAllPoints()
        item:SetParent(self)

        if self.max and cnt >= cols then
            item:Hide()
        else
            item:SetPoint('TOPLEFT', x, y)
            item:Show()

            width = width or cols * (self.spacing + item:GetWidth()) - self.spacing + self.padding * 2
            height = math.max(height, -y + item:GetHeight() + self.padding)

            cnt = cnt + 1

            if cnt % cols == 0 then
                y = y - self.spacing - item:GetHeight()
                x = self.padding
            else
                x = x + self.spacing + item:GetWidth()
            end
            if self.max and cnt == cols then
                item:ShowCountText(self:Count() - cnt + 1)
            end
        end
    end
    if width then
        self:SetSize(width, height)
        if self.title then
            self.title:SetWidth(width)
        end
    end
end

function container:Count()
    local count = 0
    for _, v in pairs(self.items) do
        if v and v ~= nil then
            count = count + 1
        end
    end
    return count
end

function container:IsEmpty()
    return next(self.items) == nil
end

function container:TitleEnter()
    if (self:GetParent().title:IsTruncated()) then
        GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
        GameTooltip:SetText(self:GetParent().name)
        GameTooltip:Show()
    end
end

function container:TitleLeave()
    GameTooltip:Hide()
end