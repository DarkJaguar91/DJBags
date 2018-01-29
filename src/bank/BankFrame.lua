local ADDON_NAME, ADDON = ...

local bankFrame = {}
bankFrame.__index = bankFrame

function DJBagsRegisterBankFrame(self, bags)
	for k, v in pairs(bankFrame) do
		self[k] = v
	end

    ADDON.eventManager:Add('BANKFRAME_OPENED', self)
    ADDON.eventManager:Add('BANKFRAME_CLOSED', self)
    ADDON.eventManager:Add('BAG_UPDATE_DELAYED', self)

    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self, ...)
        self:StartMoving()
    end)
    self:SetScript("OnDragStop", function(self, ...)
        self:StopMovingOrSizing(...)
    end)
    self:SetUserPlaced(true)
end

function DJBagsBankTab_OnClick(tab)
	PanelTemplates_SetTab(DJBagsBankBar, tab.tab)
    if tab.tab == 1 then
        DJBagsBank:Show()
        DJBagsReagents:Hide()
        BankFrame.selectedTab = 1
        BankFrame.activeTabIndex = 1
    else
        DJBagsBank:Hide()
        DJBagsReagents:Show()
        BankFrame.selectedTab = 2
        BankFrame.activeTabIndex = 2
    end
end

function bankFrame:BANKFRAME_OPENED()
	self:Show()
    DJBagsBag:Show()
end

function bankFrame:BANKFRAME_CLOSED()
	self:Hide()
end