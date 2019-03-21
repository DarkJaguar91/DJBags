local ADDON_NAME, ADDON = ...

local bank = {}
bank.__index = bank

function DJBagsRegisterBankBagContainer(self, bags)
	DJBagsRegisterBaseBagContainer(self, bags)

	for k, v in pairs(bank) do
		self[k] = v
	end

    ADDON.eventManager:Add('BANKFRAME_OPENED', self)
    ADDON.eventManager:Add('BANKFRAME_CLOSED', self)
    ADDON.eventManager:Add('PLAYERBANKSLOTS_CHANGED', self)
    ADDON.eventManager:Add('PLAYERBANKBAGSLOTS_CHANGED', self)

    BankFrame:UnregisterAllEvents()
    BankFrame:SetScript('OnShow', nil)
end

function bank:BANKFRAME_OPENED()
	if (BankFrame.selectedTab or 1) == 1 then
		self:Show()
	end
end

function bank:BANKFRAME_CLOSED()
	self:Hide()
end

function bank:PLAYERBANKSLOTS_CHANGED()
	self:BAG_UPDATE(BANK_CONTAINER)
end

function bank:BAG_UPDATE_DELAYED()
    for _, bag in pairs(self.bags) do
    	if bag ~= BANK_CONTAINER then
			DJBagsBankBar['bag' .. bag - NUM_BAG_SLOTS]:Update()
		end
	end
end

function bank:PLAYERBANKBAGSLOTS_CHANGED()
	self:BAG_UPDATE_DELAYED()
end
