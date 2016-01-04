local _, ns = ...

local impl = ns.impl
local eventFrame = CreateFrame("Frame", "DJUIBagEventFrame", nil)
eventFrame:Hide()

SLASH_DJBAG1, SLASH_DJBAG2 = '/djb', '/djbag'
function SlashCmdList.DJBAG(msg, editbox)

end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if impl[event] then
		impl[event](impl, ...)
	end
end)