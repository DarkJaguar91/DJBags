local _, ns = ...

if not ns.bag then
	ns.bag = {}
	ns.bag.__index = ns.bag
end

local settings = {}
ns.bag.settings = settings

settings.iLevelTypes = {
	"Weapon",
	"Armor"
}

settings.saved = {
	itemSize = 37,
	columns = 8,
	itemPadding = 3,
	padding = 5,
	bagPadding = 3,
	titleSize = 15,
	countFontSize = 10,
	savedTypes = {},
	bagSettings = {},
	bagColumns = {
		left = {
			"Sets",
			"Armor",
			"Weapon",
		},
		right = {
			"Miscellaneous",
			"Consumable",
			"Trade Goods",
			"Quest",
		},
	},
}

settings.setNames = {}

settings.isSet = function(key)
	for k, v in pairs(settings.setNames) do
		if v == key then
			return true
		end
	end
end

settings.bagColumnSorter = function (itemTable)
	local function getKey(itm)
		itm = settings.isSet(itm) and "Sets" or itm
		for k, v in pairs(itemTable) do
			if v == itm then
				return k
			end
		end
		return nil
	end

	return function(a, b)
		local valA =  getKey(a)
		local valB =  getKey(b)

		if valA and valB then
			if valA ~= valB then
				return valA < valB
			end
		elseif valA then
			return true
		elseif valB then
			return false
		end
		return a < b
	end
end

settings.sortingFunction = {
	["default"] = function (a, b)
		if a.quality == b.quality then
			if a.name == b.name then
				return a.count > b.count
			end
			return a.name < b.name
		end
		return a.quality > b.quality
	end,
	["name"] = function (a, b)
		return a.name < b.name
	end,
}

_G["DJUIBagSettings"] = settings