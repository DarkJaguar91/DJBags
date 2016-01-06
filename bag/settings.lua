local _, ns = ...

local settings = {}
ns.settings = settings

settings.saved = {
	itemSize = 37,
	columns = 8,
	itemPadding = 3,
	padding = 5,
	bagPadding = 3,
	containerColor = {0, 0, 0, 0.6},
	titleSize = 11,
	titlePadding = 2,
	titleColor = {0.8, 0.8, 0.8, 1},
	countFontSize = 11,
	countFontBotPadding = 2,
	countFontSidePadding = 2,
	types = {},
	bagColumns = {
		{
			"Miscellaneous",
			"Consumable",
			"Trade Goods",
			"Junk",
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