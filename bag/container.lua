local _, ns = ...

local settings = ns.settings

local containers = {}
containers.__index = containers

containers.list = {}

ns.containers = containers

function containers:GetContainer(name)
	if not self.list[name] then
		self.list[name] = container(name)
	end
	return self.list[name]
end 

local container = {}
local mt = {}
mt.__call = function(tbl, name, parent)
	local obj = setmetatable(CreateFrame("Frame", "DJUIBag" .. name, parent), container)

	obj:Init(name)

	return obj
end
setmetatable(container, mt)

function container:Init(name)
	self.name = name
	self.items = {}

	self.title = self:CreateFontString(self:GetName() .. "Title", "OVERLAY")
	self.title:SetPoint("TOP", 0, -1)
	self.title:SetFont("Fonts\\FRIZQT__.TTF", settings.saved.titleSize, "OUTLINE")
	self.title:SetTextColor(0.6, 0.36, 0, 1)

	self.title:SetText(name)

	self.itemContainer = CreateFrame("Frame", self:GetName() .. "ItemContainer", self)
	self.itemContainer:SetPoint("TOPLEFT", self, "TOPLEFT", settings.saved.padding, -settings.saved.titleSize - settings.saved.padding)
	self.itemContainer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -settings.saved.padding, settings.saved.padding)
end

function container:AddItem(item)
	item:SetParent(self)
	item.container = self

	table.insert(self.items, item)
end

function container:RemoveItem(item)
	item:SetParent(nil)
	item.container = nil

	for i = 1, #self.items do
		if self.items[i] == item then
			table.remove(self.items, i)
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
	local rows = math.ceil(#self.items / settings.saved.columns)
	return settings.saved.titleSize +
	        settings.saved.padding * 2 +
	        (rows - 1) * settings.saved.itemPadding +
	        rows * settings.saved.itemSize
end

function container:Arrange()
	local w = self:GetWidth()
	local h = self:GetHeight()

	self:SetSize(w, h)

	self:ArrangeItems()
end

function container:ArrangeItems()
	for i = 1, #self.items do
		local col = math.ceil((i - 1) % settings.saved.columns)
		local row = math.floor((i - 1) / settings.saved.columns)
		local x = col * settings.saved.itemSize + col * settings.saved.itemPadding
		local y = -(row * settings.saved.itemSize + row * settings.saved.itemPadding)

		local item = self.items[i]
		item:SetSize(settings.saved.itemSize, settings.saved.itemSize)
		item:ClearAllPoints()
		item:SetPoint("TOPLEFT", x, y)
	end
end