local ADDON_NAME, ADDON = ...

function DJBagsSettingsColumnsLoad(self)
	function self:Update()
		self.name:SetText(ADDON.locale.COLUMNS .. ": " .. self:GetParent():GetParent().settings.maxColumns)
	end
	self.up.process = function() 
		local currentCount = self:GetParent():GetParent().settings.maxColumns
		if (currentCount < 20) then
			self:GetParent():GetParent().settings.maxColumns = currentCount + 1

			self:Update()
			self:GetParent():GetParent():Refresh()
		end
	end
	self.down.process = function()
		local currentCount = self:GetParent():GetParent().settings.maxColumns
		if (currentCount > 1) then
			self:GetParent():GetParent().settings.maxColumns = currentCount - 1

			self:Update()
			self:GetParent():GetParent():Refresh()
		end
	end
end

function DJBagsSettingsColumnsShow(self)
	self:Update()
end