local _, ns = ...

local settings = {}
ns.settings = settings

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
		{
			"Miscellaneous",
			"Consumable",
			"Trade Goods",
			"Quest",
		},
		{
			"Armor",
			"Weapon"
		}
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