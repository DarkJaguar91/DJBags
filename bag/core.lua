local addonName, ns = ...

local settings = ns.bag.settings

local impl = {}
impl.__index = impl

ns.bag.impl = impl

ns.buttons = {
	
}

impl.mainFrame = CreateFrame("Frame", "DJUIBag", UIParent)

function impl:ADDON_LOADED(name)
	if name == addonName then
		-- TODO - Load real settings
		self.mainFrame:SetPoint("BOTTOMRIGHT", -300, 125)

		local buttons = {}

		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				local button = self:UpdateButton(bag, slot)

				table.insert(buttons, button)
				button:SetParent(self.mainFrame)
			end
		end

		self:ArangeItems(self.mainFrame, buttons, settings.saved.columns, settings.saved.itemPadding, settings.saved.itemSize)
		local w, h = self:GetButtonFrameSize(#buttons, settings.saved.columns, settings.saved.itemPadding, settings.saved.itemSize)
		self.mainFrame:SetSize(w, h)
		self.mainFrame:Show()
	end
end

function impl:GetButton(bag, slot)
	if not ns.buttons[bag] then
		ns.buttons[bag] = {}
	end
	if ns.buttons[bag][slot] then
		return ns.buttons[bag][slot]
	end

	local parentFrame = CreateFrame("Frame", nil, nil)
	parentFrame:SetID(bag)

	local button = CreateFrame("Button", string.format("DJUIBagButton%d_%d", bag, slot), parentFrame, "ContainerFrameItemButtonTemplate")

	parentFrame.button = button

	button:SetAllPoints()
	button.bagID = bag
	button.slotID = slot
	button:SetID(slot)
	button:Show()
	parentFrame:Show()

	ns.buttons[bag][slot] = parentFrame

	return parentFrame
end

function impl:ArangeItems(container, items, columns, itemPadding, itemSize)
	local cnt = 0
	for k, v in pairs(items) do
		v:ClearAllPoints()
		v:SetParent(container)
		v:SetSize(settings.saved.itemSize, settings.saved.itemSize)

		local col = math.ceil(cnt % columns)
		local row = math.floor(cnt / columns)
		local x = col * itemSize + col * itemPadding
		local y = row * itemSize + row * itemPadding

		v:SetPoint("TOPLEFT", x, -y)

		cnt = cnt + 1
	end
end

function impl:GetButtonFrameSize(count, columns, itemPadding, itemSize)
	local x = columns * itemSize + (columns - 1) * itemPadding
	local rows = math.ceil(count / columns)
	local y = rows * itemSize + (rows - 1) * itemPadding

	return x, y
end

function impl:UpdateButton(bag, slot)
	local parentFrame = self:GetButton(bag, slot)
	local button = parentFrame.button

	local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(bag, slot)

	if not texture then
		button.Count:Hide()
		button.icon:SetTexture(nil)
	else
		button.icon:SetTexture(texture)

		if count > 1 then
			button.Count:SetText(count)
			button.Count:Show()
		else
			button.Count:Hide()
		end
	end

	return parentFrame
end