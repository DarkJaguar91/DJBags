local NAME, ADDON = ...

function DJBagsTooltip:GetItemLevel(link)
    self:SetOwner(UIParent, "ANCHOR_NONE")
    self:SetHyperlink(link)

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft"..i]:GetText()
        local UPGRADE_LEVEL = gsub(ITEM_LEVEL," %d","")

        if text and text:find(UPGRADE_LEVEL) then
            local itemLevel = string.match(text,"%d+")

            if itemLevel then
                return tonumber(itemLevel)
            end
        end
    end
end