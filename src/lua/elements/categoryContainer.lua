local NAME, ADDON = ...

ADDON.categoryContainer = {}
ADDON.categoryContainer.__index = ADDON.categoryContainer

local container = ADDON.categoryContainer
setmetatable(container, {
    __call = function(tbl, name, parent)
        local frame = ADDON.container(name, parent)

        for k, v in pairs(tbl) do
            frame[k] = v
        end

        frame:Init()
        frame:Setup()

        return frame
    end
})

function container:Init()
    table.insert(UISpecialFrames, self:GetName())
    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)
    self.containers = {}

    self.closeBtn = CreateFrame('Button', self:GetName() .. 'CloseButton', self)
    self.closeBtn:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Disabled]])
    self.closeBtn:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])
    self.closeBtn:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
    self.closeBtn:SetScript('OnClick', function()
        if self:GetParent() == UIParent then
            self:Hide()
        else
            self:GetParent():Hide()
        end
    end)
end

function container:Setup()
    ADDON.container.Setup(self)

    local settings = ADDON.settings.categoryContainer

    self.padding = settings.padding
    self.spacing = settings.spacing
    self.formatter = ADDON.formatters[settings.formatter]
    self.maxHeight = settings.maxHeight
    if settings.closeVisible then
        self.closeBtn:Show()
    else
        self.closeBtn:Hide()
    end
    self.closeBtn:SetPoint('Topright', self, 'TOPRIGHT', settings.closeSize / 5, settings.closeSize / 5)
    self.closeBtn:SetSize(settings.closeSize, settings.closeSize)
end

function container:AddContainer(container)
    self.containers[container] = true
end

function container:Arrange()
    self.formatter:Format(self)
end