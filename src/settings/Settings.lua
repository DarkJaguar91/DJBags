local ADDON_NAME, ADDON = ...

function DJBagsSettingsColumnsLoad(self)
	function self:Update()
		self.name:SetText(ADDON.locale.COLUMNS:format(self:GetParent().bag.settings.maxColumns))
	end
	self.up.process = function() 
		local currentCount = self:GetParent().bag.settings.maxColumns
		if (currentCount < 20) then
			self:GetParent().bag.settings.maxColumns = currentCount + 1

			self:Update()
			self:GetParent().bag:Refresh()
		end
	end
	self.down.process = function()
		local currentCount = self:GetParent().bag.settings.maxColumns
		if (currentCount > 1) then
			self:GetParent().bag.settings.maxColumns = currentCount - 1

			self:Update()
			self:GetParent().bag:Refresh()
		end
	end
end

function DJBagsSettingsScaleLoad(self)
	function self:Update()
		self.name:SetText(ADDON.locale.SCALE:format(self:GetParent().bag.settings.scale))
	end
	self.up.process = function() 
		local currentCount = self:GetParent().bag.settings.scale or 1
		if (currentCount < 1.7) then
			self:GetParent().bag.settings.scale = currentCount + 0.02

			self:Update()
			self:GetParent().bag:SetScale(self:GetParent().bag.settings.scale)
		end
	end
	self.down.process = function()
		local currentCount = self:GetParent().bag.settings.scale or 1
		if (currentCount > 0.2) then
			self:GetParent().bag.settings.scale = currentCount - 0.02

			self:Update()
			self:GetParent().bag:SetScale(self:GetParent().bag.settings.scale)
		end
	end
end
