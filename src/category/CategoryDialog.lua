local ADDON_NAME, ADDON = ...

local dialog = {}

function DJBagsCategoryDialogLoad(self)
	for k, v in pairs(item) do
        self[k] = v
    end

    self:Init()
end

function dialog:Init()
    table.insert(UISpecialFrames, self:GetName())
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)
    self:SetUserPlaced(true)
end

function dialog:DisplayForItem(id, name)
	DJBagsCategoryDialog.name:SetText(name)
	DJBagsCategoryDialog.id = id
	DJBagsCategoryDialog;Show()

	
end

function dialog:Done()

end