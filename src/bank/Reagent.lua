local ADDON_NAME, ADDON = ...

local bank = {}
bank.__index = bank

function DJBagsRegisterReagentBagContainer(self, bags)
	DJBagsRegisterBaseBagContainer(self, bags)

	for k, v in pairs(bank) do
		self[k] = v
	end

    ADDON.eventManager:Add('BANKFRAME_OPENED', self)
    ADDON.eventManager:Add('BANKFRAME_CLOSED', self)
    ADDON.eventManager:Add('PLAYERREAGENTBANKSLOTS_CHANGED', self)
end

function bank:BANKFRAME_OPENED()
	if BankFrame.selectedTab == 2 then
		self:Show()
	end
end

function bank:BANKFRAME_CLOSED()
	self:Hide()
end

function bank:PLAYERREAGENTBANKSLOTS_CHANGED()
	self:BAG_UPDATE(REAGENTBANK_CONTAINER)
end