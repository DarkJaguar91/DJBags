local bagItems = {}
local itemSize, columns, padding, titleSize = 37, 5, 4, 15

local function GetItems()
	bagItems = {}

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local id = GetContainerItemID(bag, slot)
			if id then
				local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(bag, slot)
				local name, _, _, ilevel, reqLevel, class, subclass, maxStack, equipSlot, _, vendorPrice = GetItemInfo(id)

				if not bagItems[class] then
					bagItems[class] = {}
				end

				table.insert(bagItems[class], {
					id = id,
					name = name,
					texture = texture,
					link = link,
					count = count,
					quality = quality,
					ilevel = ilevel,
					maxStack = maxStack,
				})
			end
		end
	end
end

local function CreateBag(parent, name, items)
	if #items == 0 then return end

	local function sortIt(a, b)
		if a.quality == b.quality then
			if a.name == b.name then
				return a.count > b.count
			end

			return a.name < b.name
		end

		return a.quality > b.quality	
	end

	table.sort(items, sortIt)

	if not parent.frames then
		parent.frames = {}
	end
	local frame = parent.frames[name]
	if not frame then
		parent.frames[name] = CreateFrame("Frame", "BagFrame" .. name, parent)
		frame = parent.frames[name]
		frame.name = name
		frame.items = {}
		frame.buttonPool = {}
		frame.createItem = function(self, item)
			local button = table.remove(self.buttonPool)

			if not button then
				button = CreateFrame("Button", nil, self, "DJUIBagItemTemplate")
				button.count:SetFontObject("DJUI_Small")
			end

			button.link = item.link
			button.icon:SetTexture(item.texture)

			if item.count > 1 then
				button.count:SetText(item.count)
				button.count:SetVertexColor(1, 1, 1, 1)
				button.count:Show()
			elseif item.maxStack == 1 and item.ilevel > 1 then
				print(item.name)
				button.count:SetText(item.ilevel)
				button.count:SetVertexColor(GetItemQualityColor(item.quality))
				button.count:Show()
			else
				button.count:Hide()
			end

			if item.quality > 1 then
				button.glow:SetVertexColor(GetItemQualityColor(item.quality))
				button.glow:Show()
			else 
				button.glow:Hide()
			end
			table.insert(self.items, button)
			return button
		end
		frame.title = frame:CreateFontString("BagBuddy_Title", "OVERLAY", "GameFontNormal")
		frame.title:SetFontObject("DJUITitle")
		frame.title:SetPoint("TOP", 0, -1)
		frame.background = frame:CreateTexture(nil, "BACKGROUND")
		frame.background:SetAllPoints()
		frame.background:SetTexture(0, 0, 0, 0.6)
		frame:SetBackdrop({
		 edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
		 edgeSize= 0.6,
		})
	end

	local frame = parent.frames[name]
	for k, v in pairs(frame.items) do	
		v:Hide()
		v.link = nil
		v:ClearAllPoints()
		table.insert(frame.buttonPool, v)
	end

	frame.items = {}
	frame.title:SetText(name)

	local count = 0
	for k, v in pairs(items) do
		local btn = frame:createItem(v)
		
		local x = padding + itemSize * (count % columns) + padding * (count % columns)
		local y = -(frame.title:GetStringHeight() + padding + padding * math.floor(count / 5) + itemSize * math.floor(count / 5))
		btn:SetPoint("TOPLEFT", x, y)

		count = count + 1
	end
	local numRows = math.ceil(#items / 5)
	local x = padding * (columns + 1) + itemSize * columns
	local y = numRows * itemSize + frame.title:GetStringHeight() + padding + padding * numRows
	frame:SetSize(x, y)
	return x, y, frame
end

local function UpdateItems(parent)
	GetItems()
	local w, h = 0, 0
	for k, v in pairs(bagItems) do
		local w1, h1, frame = CreateBag(parent, k, v)
		w = math.max(w, w1)
		frame:SetPoint("BOTTOMRIGHT", 0, h)
		frame:Show()
		h = h + h1
	end
	parent:SetSize(w + 5, h + 5)
	parent:Show()
end

function DJUIBag_OnLoad(self)
	UpdateItems(self)
end

function DJUIBag_ItemEnter(self, motion)
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

function DJUIBag_ItemLeave(self, motion)
	GameTooltip:Hide()
end