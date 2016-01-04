local addonName, ns = ...

local settings = ns.settings
local containers = ns.containers
local buttons = ns.buttons

local impl = {}
impl.__index = impl

ns.impl = impl

function impl:ADDON_LOADED(name)
	if addonName == name then
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				local button = buttons:GetButton(bag, slot)
				button:Update()
			end
		end
		containers:Show()
	end
end

function impl:BAG_UPDATE(bag, slot)
	if bag >= 0 and bag <= NUM_BAG_SLOTS then
		for slot = 1, GetContainerNumSlots(bag) do
			local button = buttons:GetButton(bag, slot)
			button:Update()
		end
	end
end