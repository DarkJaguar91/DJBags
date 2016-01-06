local _, ns = ...

local settings = ns.settings

local container = {}
container.__index = container
local containers = {}
containers.__index = containers

containers.list = {}

ns.containers = containers

function containers:GetCurrencyBar()
	if not self.currencyBar then
		self.currencyBar = CreateFrame("Frame", "DJUICurrencyBar", UIParent)
		self.currencyBar:SetSize(container:GetWidth(), settings.saved.titleSize)
		self.currencyBar:SetPoint("BOTTOMRIGHT", -300, 125)

		self.currencyBar:SetBackdrop({
	        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	        edgeFile = "Interface\\Buttons\\WHITE8x8",
	        tile = false, tileSize = 16, edgeSize = 1,
    	})
    	self.currencyBar:SetBackdropColor(unpack(settings.saved.containerColor))	

		self.currencyBar:SetMovable(true)
		self.currencyBar:EnableMouse(true)
		self.currencyBar:RegisterForDrag("LeftButton")
		self.currencyBar:SetScript("OnDragStart", self.currencyBar.StartMoving)
		self.currencyBar:SetScript("OnDragStop", self.currencyBar.StopMovingOrSizing)
		tinsert(UISpecialFrames, self.currencyBar:GetName());
	end

	return self.currencyBar
end

function containers:GetContainer(name)
	if not self.list[name] then
		self.list[name] = container(name, UIParent)
	end

	return self.list[name]
end 

function containers:Toggle()
	if containers.currencyBar:IsShown() then
		containers:Hide()
	else
		containers:Show()
	end
end

function containers:Show()
	containers.currencyBar:Show()
	for k, v in pairs(containers.list) do
		v:Show()
	end
end

function containers:Hide()
	containers.currencyBar:Hide()
	for k, v in pairs(containers.list) do
		v:Hide()
	end
end

local mt = {}
mt.__call = function(tbl, name, parent)
	local obj = CreateFrame("Frame", "DJUIBag" .. name, parent)

	for k, v in pairs(container) do
		obj[k] = v
	end

	obj:Init(name)

	return obj
end
setmetatable(container, mt)

function container:Init(name)
	self.name = name
	self.items = {}

	self:SetFrameLevel(5)

	self.title = self:CreateFontString(self:GetName() .. "Title", "OVERLAY")
	self.title:SetFont("Fonts\\FRIZQT__.TTF", settings.saved.titleSize, "OUTLINE")
	self.title:SetText(name)
	self.title:SetPoint("TOPLEFT", settings.saved.titlePadding, -settings.saved.titlePadding)
	self.title:SetTextColor(unpack(settings.saved.titleColor))

	self.itemContainer = CreateFrame("Frame", self:GetName() .. "ItemContainer", self)
	self.itemContainer:SetPoint("TOPLEFT", self, "TOPLEFT", settings.saved.padding, -settings.saved.titleSize - settings.saved.padding)
	self.itemContainer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -settings.saved.padding, settings.saved.padding)

	self:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 16, edgeSize = 1,
    })
    self:SetBackdropColor(unpack(settings.saved.containerColor))
    tinsert(UISpecialFrames, self:GetName());

	self:Position()
end

function container:Position()
	local col, index = self:GetBagPosition()

	self:ClearAllPoints()

	local parentContainer = self:GetParentContainer(col, index)

	if not parentContainer then
		local parentPoint = col == 1 and "TOPRIGHT" or "BOTTOMLEFT"
		local offsetX = col == 1 and 0 or (settings.saved.bagPadding * (col - 1) + (col - 2) * self:GetWidth()) 
		local offsetY = col == 1 and settings.saved.bagPadding or 0
		self:SetPoint("BOTTOMRIGHT", containers:GetCurrencyBar(), parentPoint, -offsetX, offsetY)
	else
		local parentPoint = "TOPRIGHT"
		local offsetX = 0
		local offsetY = settings.saved.bagPadding
		self:SetPoint("BOTTOMRIGHT", parentContainer, parentPoint, offsetX, offsetY)
	end
end

function container:RepositionChildren()
	local col, index = self:GetBagPosition()

	local child = nil

	repeat
		index = index + 1
		child = settings.saved.bagColumns[col][index]

		if child then
			containers:GetContainer(child):Position()
		end
	until child == nil
end

function container:GetParentContainer(col, index)
	while index > 0 do
		if index == 1 then
			return nil
		else
			local container = containers:GetContainer(settings.saved.bagColumns[col][index - 1])
			if container:GetHeight() > 0 then
				return container
			end
		end

		index = index - 1
	end
end

function container:GetBagPosition()
	for c, list in pairs(settings.saved.bagColumns) do
		for i, name in pairs(list) do
			if name == self.name then
				return c, i
			end
		end
	end

	table.insert(settings.saved.bagColumns[#settings.saved.bagColumns], self.name)
	local col = #settings.saved.bagColumns
	local index = #settings.saved.bagColumns[#settings.saved.bagColumns]
	return col, index
end

function container:AddItem(item)
	item:SetParent(self)
	item.container = self

	table.insert(self.items, item)

	self:Arrange()
	if #self.items % settings.saved.columns == 1 then
		self:RepositionChildren()
	end
end

function container:RemoveItem(item)
	item:SetParent(nil)
	item.container = nil

	for i = 1, #self.items do
		if self.items[i] == item then
			table.remove(self.items, i)
			self:Arrange()
			if #self.items == 0 then
				self:RepositionChildren()
			end
			break
		end 
	end
end

function container:GetWidth()
	local numItems = settings.saved.columns
	return settings.saved.padding * 2 + 
			(numItems - 1) * settings.saved.itemPadding +
			numItems * settings.saved.itemSize
end

function container:GetHeight()
	if #self.items == 0 then return 0 end

	local rows = math.ceil(#self.items / settings.saved.columns)
	return settings.saved.titleSize +
	        settings.saved.padding * 2 +
	        (rows - 1) * settings.saved.itemPadding +
	        rows * settings.saved.itemSize
end

function container:Arrange()
	local w = self:GetWidth()
	local h = self:GetHeight()

	if h == 0 then
		self:Hide()
		return
	end

	if containers.currencyBar:IsShown() then
		self:Show()
	end

	self:SetSize(w, h)

	self:ArrangeItems()
	self:Position()
end

function container:ArrangeItems()
	if #self.items == 0 then return end

	table.sort(self.items, settings.sortingFunction["default"]) -- TODO add bag settings

	for i = 1, #self.items do
		local col = math.ceil((i - 1) % settings.saved.columns)
		local row = math.floor((i - 1) / settings.saved.columns)
		local x = col * settings.saved.itemSize + col * settings.saved.itemPadding
		local y = -(row * settings.saved.itemSize + row * settings.saved.itemPadding)

		local item = self.items[i]
		item:SetSize(settings.saved.itemSize, settings.saved.itemSize)
		item:ClearAllPoints()
		item:SetPoint("TOPLEFT", self.itemContainer, "TOPLEFT", x, y)
		item:Show()
	end
end