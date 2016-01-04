local _, ns = ...

local settings = ns.settings
local containers = ns.containers

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
	return button(bag, slot)
end 

local button = {} 
local mt = {}
mt.__call = function(tbl, bag, slot)
	local parentFrame = CreateFrame("Frame", 
		string.format("FJUIBagButtonParent%d_%d", bag, slot), nil)
	local obj = CreateFrame("Button",
		string.format("DJUIBagButton%d_%d", bag, slot), parentFrame, 
		"ContainerFrameItemButtonTemplate")
	obj.parent = parentFrame
	parentFrame.button = obj

	button.Init(parentFrame, bag, slot)
	return parentFrame
end
setmetatable(button, mt)

function button.Init(obj, bag, slot)
	setmetatable(obj, button)

	obj.bag = bag
	obj.slot = slot

	obj.SetID(bag)
	obj.button:SetID(slot)

	obj:Show()
	obj.button:Show()
end

function button:GetInformation()
	local id = GetContainerItemID(self.bag, self.slot)
	local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(self.bag, self.slot)
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)

	return id, name, texture, count, quality, ilevel
end

function button:GetContainerName()
	local id = GetContainerItemID(self.bag, self.slot)
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id)
	local isInSet, setName = GetContainerItemEquipmentSetInfo(self.bag, self.slot)

	if isInSet then
		settings.setNames[setName] = true
	end

	local type = settings.saved.types[id] or (isInSet and setName) or class

	if not settings.saved.bagColumns[settings.setNames[type] and "Sets" or type] then
		settings.saved.bagColumns[type] = 1
	end

	return type
end

function button:Update()
	local id, name, texture, count, quality, ilevel = self:GetInformation()

	if id then
		self:UpdateItem(id, texture, count, quality, ilevel)
	else
		self:Clear()
	end
end

function button:UpdateItem(id, texture, count, quality, ilevel)
	local button = self.button

	button.icon:SetTexture(texture)

	if count > 1 then
		button.Count:SetText(count)
		button.Count:SetVertexColor(1, 1, 1, 1)
		button.Count:Show()
	elseif IsEquipableItem(id) then
		button.Count:SetText(ilevel)
		button.Count:SetVertexColor(GetItemQualityColor(quality))
		button.Count:Show()
	else
		button.Count:Hide()
	end
end

function button:Clear()
	local button = self.button

	button.icon:SetTexture(nil)
	button.Count:Hide()
end

