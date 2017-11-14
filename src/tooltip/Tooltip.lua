local ADDON_NAME, ADDON = ...

function DJBagsTooltip:GetItemLevel(bag, slot)
    self:SetOwner(UIParent, "ANCHOR_NONE")
    self:SetBagItem(bag, slot)

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()
        local UPGRADE_LEVEL = gsub(ITEM_LEVEL, " %d", "")

        if text and text:find(UPGRADE_LEVEL) then
            local itemLevel = string.match(text, "%d+")

            if itemLevel then
                return tonumber(itemLevel)
            end
        end
    end
end

function DJBagsTooltip:IsItemBOE(bag, slot)
    self:SetOwner(UIParent, "ANCHOR_NONE")
    self:SetBagItem(bag, slot)

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and text:find(ITEM_BIND_ON_EQUIP) then
            return true
        end
    end

    return false
end

function DJBagsTooltip:IsItemBOA(bag, slot)
    self:SetOwner(UIParent, "ANCHOR_NONE")
    self:SetBagItem(bag, slot)

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and text:find(ITEM_BIND_TO_BNETACCOUNT) then
            return true
        end
    end

    return false
end

function DJBagsTooltip:IsItemArtifactPower(bag, slot)
    self:SetOwner(UIParent, "ANCHOR_NONE")
    self:SetBagItem(bag, slot)

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and text:find(ARTIFACT_POWER) then
            return true
        end
    end

    return false
end