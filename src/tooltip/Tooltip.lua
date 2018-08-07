local ADDON_NAME, ADDON = ...

function DJBagsTooltip:GetItemLevel(bag, slot)
    self:ClearLines()
    self:SetOwner(UIParent, "ANCHOR_NONE")
    if bag < 0 then
        self:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
    else
        self:SetBagItem(bag, slot)
    end

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
    self:ClearLines()
    self:SetOwner(UIParent, "ANCHOR_NONE")
    if bag < 0 then
        self:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
    else
        self:SetBagItem(bag, slot)
    end


    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and text:find(ITEM_BIND_ON_EQUIP) then
            return true
        end
    end

    return false
end

function DJBagsTooltip:IsItemBOA(bag, slot)
    self:ClearLines()
    self:SetOwner(UIParent, "ANCHOR_NONE")
    if bag < 0 then
        self:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
    else
        self:SetBagItem(bag, slot)
    end

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and (text:find(ITEM_ACCOUNTBOUND) or text:find(ITEM_BIND_TO_ACCOUNT)) then
            return true
        end
    end

    return false
end

-- Extra for Bind on Battlenet account
function DJBagsTooltip:IsItemBOBA(bag, slot)
    self:ClearLines()
    self:SetOwner(UIParent, "ANCHOR_NONE")
    if bag < 0 then
        self:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
    else
        self:SetBagItem(bag, slot)
    end

    for i = 2, self:NumLines() do
        local text = _G[self:GetName() .. "TextLeft" .. i]:GetText()

        if text and (text:find(ITEM_BNETACCOUNTBOUND) or text:find(ITEM_BIND_TO_BNETACCOUNT)) then
            return true
        end
    end
    return false
end
