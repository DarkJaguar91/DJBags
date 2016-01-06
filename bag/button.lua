local _, ns = ...

local settings = ns.settings
local containers = ns.containers

local button = {} 
button.__index = button

local buttons = {}
buttons.__index = buttons

buttons.list = {}

ns.buttons = buttons

function buttons:GetButton(bag, slot)
	if not self.list[bag] then
		self.list[bag] = {}
	end
	if not self.list[bag][slot] then
		self.list[bag][slot] = button(bag, slot)
	end
	return self.list[bag][slot]
end 

local mt = {}
mt.__call = function(tbl, bag, slot)
	local parentFrame = CreateFrame("Frame", 
		string.format("FJUIBagButtonParent%d_%d", bag, slot), nil)
	local btn = CreateFrame("Button",
		string.format("DJUIBagButton%d_%d", bag, slot), parentFrame, 
		"ContainerFrameItemButtonTemplate")

	btn.parent = parentFrame
	parentFrame.button = btn

	for k, v in pairs(button) do
		parentFrame[k] = v
	end

	parentFrame:Init(bag, slot)
	return parentFrame
end
setmetatable(button, mt)

function button:Init(bag, slot)
	self.bag = bag	
	self.slot = slot

	self:SetID(bag)
	self.button:SetID(slot)
	self.button:SetAllPoints()

	self.button.BattlepayItemTexture:Hide()

	self.button.Count:SetFont("Fonts\\FRIZQT__.TTF", settings.saved.countFontSize, "OUTLINE")
	self.button.Count:ClearAllPoints()
	self.button.Count:SetPoint("BOTTOMRIGHT",  -settings.saved.countFontSidePadding, 
		settings.saved.countFontBotPadding)

	self.button.IconBorder:SetTexture([[Interface\AddOns\DJUI-WOW\art\Border]])
	self.button.icon:ClearAllPoints()
	self.button.icon:SetPoint("TOPLEFT", -1, 1)
	self.button.icon:SetPoint("BOTTOMRIGHT", 1, -1)

	local NT = _G[self.button:GetName() .. "NormalTexture"]
	NT:SetTexture([[Interface\AddOns\DJUI-WOW\art\Border]])
	NT:ClearAllPoints()
	NT:SetAllPoints()

	self:Show()
	self.button:Show()
end

function button:GetInformation()
	local id = GetContainerItemID(self.bag, self.slot)
	if id then
		local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(self.bag, self.slot)
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)

		return id, name, texture, count, quality, iLevel
	end
end

function button:GetContainerName()
	local id = GetContainerItemID(self.bag, self.slot)

	if id then
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)
		local isInSet, setName = GetContainerItemEquipmentSetInfo(self.bag, self.slot)

		if isInSet then
			settings.setNames[setName] = true
			setName = string.gsub(setName, ",", " &")
		end
		return settings.saved.types[id] or (isInSet and setName) or (quality == 0 and "Junk") or class
	end
end

function button:Update()
	local id, name, texture, count, quality, ilevel = self:GetInformation()

	if id then
		self:UpdateItem(id, name, texture, count, quality, ilevel)
	else
		self:Clear()
	end

	self:UpdateContainer()
end

function button:UpdateContainer()
	local name = self:GetContainerName()

	if self.container then
		if self.container.name == name then
			return
		end
		self.container:RemoveItem(self)
	end

	if name then
		local container = containers:GetContainer(name)

		container:AddItem(self)
	else
		self:Hide() -- TODO fix this!!
	end
end

function button:UpdateItem(id, name, texture, count, quality, ilevel)
	local button = self.button

	self.name = name
	self.quality = quality
	self.count = count

	button.icon:SetTexture(texture)

	if count > 1 then
		button.Count:SetText(count)
		button.Count:SetVertexColor(1, 1, 1, 1)
		button.Count:Show()
	elseif IsEquippableItem(id) then
		button.Count:SetText(ilevel)
		button.Count:SetVertexColor(GetItemQualityColor(quality))
		button.Count:Show()
	else
		button.Count:Hide()
	end

	if quality <= 0 then
		button.JunkIcon:Show()
	else
		button.JunkIcon:Hide()
	end
	button.IconBorder:SetVertexColor(GetItemQualityColor(quality))
	button.IconBorder:Show()

	if C_NewItems.IsNewItem(self.bag, self.slot) then
		button.newitemglowAnim:Play()
	end
end

function button:Clear()
	local button = self.button

	self.name = nil
	self.quality = nil
	self.count = nil

	button.icon:SetTexture(nil)
	button.Count:Hide()
end

