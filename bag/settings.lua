local _, ns = ...

if not ns.bag then
	ns.bag = {}
	ns.bag.__index = ns.bag
end

local settings = {}
ns.bag.settings = settings

settings.saved = {
	itemSize = 37,
	columns = 8,
	itemPadding = 3,
	padding = 5,
	bagPadding = 3,
	titleSize = 15,
	countFontSize = 10,
	types = {},
	bagColumns = {
		["Miscellaneous"] = 0,
		["Consumable"] = 0,
		["Trade Goods"] = 0,
		["Quest"] = 0,
		["Sets"] = 1,
		["Armor"] = 1,
		["Weapon"] = 1,
	},
}

settings.setNames = {}

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