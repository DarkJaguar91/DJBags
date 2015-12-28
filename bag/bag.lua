function DJUIBag_OnLoad(self)
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\INV_Misc_EngGizmos_30")

	self.items = {}
	for idx = 1, 24 do
		local item = CreateFrame("Button", "DJUIBagItem" .. idx, self, "DJUIBagItemTemplate")
		self.items[idx] = item
		if idx == 1 then
			item:SetPoint("TOPLEFT", 40, -73)
		elseif idx == 7 or idx == 13 or idx == 19 then
			item:SetPoint("TopLeft", self.items[idx -6], "BOTTOMLEFT", 0, -7)
		else 
			item:SetPoint("TOPLEFT", self.items[idx - 1], "TOPRIGHT", 12, 0)
		end
	end
end