local _, ns = ...

local impl = ns.bag.impl

SLASH_DJBAG1, SLASH_DJBAG2 = '/djb', '/djbag'
function SlashCmdList.DJBAG(msg, editbox)

end

impl.mainFrame:RegisterEvent("ADDON_LOADED")

impl.mainFrame:SetScript("OnEvent", function(self, event, ...)
	if impl[event] then
		impl[event](impl, ...)
	end
end)