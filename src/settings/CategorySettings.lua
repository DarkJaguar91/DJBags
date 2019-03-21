local ADDON_NAME, ADDON = ...

local categorySettings = {}

function DJBagsSettingsOpenCategorySettingsForBag(bag)
	local settings = categorySettings[bag:GetName()] or CreateSettingsForBag(bag)
	settings:Show()
end

local height = 16
local width = 150

local function Update(self)
	for k, _ in pairs(ADDON.categoryManager.filters) do
		self[k]:SetChecked(self.bag.settings.filters[k] == nil and true or self.bag.settings.filters[k])
	end
end

function CreateSettingsForBag(bag)
	print("Creating")
	local settings = CreateFrame('Frame', string.format('DJBagsCategorySettings_%s', bag:GetName()), UIParent, 'DJBagsCategorySettings')

	local x = 5
	local y = -25
	for k, _ in pairs(ADDON.categoryManager.filters) do
		local btn = CreateFrame('CheckButton', string.format("%s_%s", settings:GetName(), k), settings, 'UICheckButtonTemplate')
		btn:SetScript('OnClick', function(self, ...) 
			self:GetParent().bag.settings.filters[self.key] = self:GetChecked()
			self:GetParent().bag:Refresh()
		end)
		_G[btn:GetName() .. 'Text']:SetText(k)

		btn:SetPoint("TOPLEFT", x, y)

		y = y - 5 - height

		if (y < (-10 - height * 10)) then
			y = -25
			x = x + 5 + width
		end

		settings[k] = btn
		btn.key = k
	end

	settings:SetSize(x + 5 + width, x > 5 and (30 + (10 * height)) or -y + height + 5)
	settings.bag = bag
	settings:SetPoint('CENTER')
	settings.name:SetText(ADDON.locale.CATEGORY_SETTINGS_FOR:format(bag:GetName()))

	categorySettings[bag:GetName()] = settings
	settings.Update = Update
	settings:Update()

	table.insert(UISpecialFrames, settings:GetName())
    settings:RegisterForDrag("LeftButton")
    settings:SetScript("OnDragStart", settings.StartMoving)
    settings:SetScript("OnDragStop", settings.StopMovingOrSizing)
    settings:SetUserPlaced(true)

	return settings 
end
