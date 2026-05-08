local addonName, addonTable = ...
local DEFunnel = addonTable.DEFunnel or _G.DEFunnel

local MailFrame = {}
DEFunnel.MailFrame = MailFrame

-- Tunable: bump to 0.2 if items don't reliably attach in testing.
local ATTACH_DELAY = 0.1
local MAX_ATTACHMENTS = 12
-- NUM_BAG_SLOTS = 4 in retail (backpack at 0 plus 4 side bags 1-4). The
-- reagent bag at index 5 is intentionally excluded — armor/weapons can't go
-- there.
local TOTAL_BAGS = NUM_BAG_SLOTS or 4

-- Item class IDs (avoid LE_ITEM_CLASS_* removed in some builds).
local CLASS_WEAPON = Enum and Enum.ItemClass and Enum.ItemClass.Weapon or 2
local CLASS_ARMOR  = Enum and Enum.ItemClass and Enum.ItemClass.Armor  or 4

-- Read tooltip line text for a bag slot. We rely on tooltip text rather than
-- C_Item.IsBound* alone because BoE-vs-already-bound is only authoritative in
-- the tooltip lines for a regular BoE that has been equipped and bound.
local function GetTooltipLines(bag, slot)
    if not C_TooltipInfo or not C_TooltipInfo.GetBagItem then return nil end
    local data = C_TooltipInfo.GetBagItem(bag, slot)
    if not data then return nil end
    if TooltipUtil and TooltipUtil.SurfaceArgs then
        TooltipUtil.SurfaceArgs(data)
        if data.lines then
            for _, line in ipairs(data.lines) do
                TooltipUtil.SurfaceArgs(line)
            end
        end
    end
    return data.lines
end

local function ClassifyBind(bag, slot)
    local lines = GetTooltipLines(bag, slot)
    local isBoE, isWarbound, isSoulbound = false, false, false
    if lines then
        for _, line in ipairs(lines) do
            local text = line.leftText
            if text then
                if text == ITEM_BIND_ON_EQUIP then
                    isBoE = true
                elseif text == ITEM_ACCOUNTBOUND_UNTIL_EQUIP then
                    isWarbound = true
                elseif text == ITEM_SOULBOUND or text == ITEM_BIND_ON_PICKUP then
                    isSoulbound = true
                end
            end
        end
    end

    -- Cross-check warbound via the modern API.
    if not isWarbound and C_Item and C_Item.IsBoundToAccountUntilEquip then
        local loc = ItemLocation:CreateFromBagAndSlot(bag, slot)
        if loc and C_Item.DoesItemExist(loc) and C_Item.IsBoundToAccountUntilEquip(loc) then
            isWarbound = true
        end
    end

    return isBoE, isWarbound, isSoulbound
end

local function IsEligible(bag, slot, info, qualities, currentExpac, allowWarbound)
    if not info or not info.itemID then return false end
    if not qualities[info.quality or 0] then return false end

    local _, _, _, _, _, classID = GetItemInfoInstant(info.itemID)
    if classID ~= CLASS_WEAPON and classID ~= CLASS_ARMOR then return false end

    -- Expansion ID is the 15th return of GetItemInfo (1-indexed).
    local link = info.hyperlink
    if not link then return false end
    local expacID = select(15, GetItemInfo(link))
    if expacID == nil then return false end
    if expacID ~= currentExpac then return false end

    local isBoE, isWarbound, isSoulbound = ClassifyBind(bag, slot)
    if isSoulbound then return false end
    if isWarbound and not allowWarbound then return false end
    if not (isBoE or isWarbound) then return false end

    return true
end

function MailFrame:ScanBags()
    local qualities = DEFunnel.db.profile.qualities
    local currentExpac = GetExpansionLevel()
    local allowWarbound = DEFunnel.db.realm.includeWarbound and true or false
    local results = {}

    for bag = 0, TOTAL_BAGS do
        local numSlots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and IsEligible(bag, slot, info, qualities, currentExpac, allowWarbound) then
                results[#results + 1] = { bag = bag, slot = slot }
            end
        end
    end

    return results
end

function MailFrame:OnShow()
    if not SendMailFrame then return end

    if not self.button then
        -- Parent to MailFrame (not SendMailFrame) and bump the frame level
        -- above the SendMail/Inbox tabs so we don't get drawn behind them.
        -- Use _G.MailFrame because our module table shadows the global.
        local parent = _G.MailFrame or SendMailFrame
        local btn = CreateFrame("Button", "DEFunnelSendButton", parent, "UIPanelButtonTemplate")
        btn:SetSize(120, 22)
        btn:SetFrameStrata("HIGH")
        btn:SetFrameLevel((MailFrameTab1 and MailFrameTab1:GetFrameLevel() or 0) + 10)
        -- Initial fallback anchor; replaced in SendMailFrame:OnShow once
        -- frame coordinates are valid.
        btn:SetPoint("TOPRIGHT", SendMailFrame, "BOTTOMRIGHT", 0, -6)

        -- Only show on the Send Mail tab. Also drives the auto-funnel trigger.
        if SendMailFrame then
            SendMailFrame:HookScript("OnShow", function()
                if MailFrame.button then
                    MailFrame:Reposition()
                    MailFrame.button:Show()
                end
                MailFrame:AutoFunnelIfReady()
            end)
            SendMailFrame:HookScript("OnHide", function()
                if MailFrame.button then MailFrame.button:Hide() end
            end)
        end
        btn:SetText(DEFunnel.L["FUNNEL_BUTTON"])
        btn:SetScript("OnClick", function() MailFrame:OnFunnelClick() end)
        self.button = btn
    end

    self.button:SetText(DEFunnel.L["FUNNEL_BUTTON"])
    -- Match initial visibility to the active tab.
    if SendMailFrame and SendMailFrame:IsShown() then
        self.button:Show()
    else
        self.button:Hide()
    end
end

function MailFrame:Reposition()
    local btn = self.button
    local parent = _G.MailFrame
    if not btn or not parent or not MailFrameTab2 then return end
    local tabTop, tabHeight = MailFrameTab2:GetTop(), MailFrameTab2:GetHeight()
    local frameBottom = parent:GetBottom()
    if not tabTop or not tabHeight or not frameBottom then return end
    local yOffset = (tabTop - tabHeight / 2) - frameBottom
    btn:ClearAllPoints()
    btn:SetPoint("RIGHT", parent, "BOTTOMRIGHT", 0, yOffset)
end

function MailFrame:OnClose()
    if self.button then
        self.button:Hide()
    end
end

local function IsSelf(recipient)
    if not recipient or recipient == "" then return false end
    local player = UnitName("player")
    return player and player:lower() == recipient:lower()
end

function MailFrame:OnFunnelClick()
    if not SendMailFrame or not SendMailFrame:IsShown() then return end

    local recipient = DEFunnel.db.realm.recipient
    if not recipient or recipient == "" then
        self:PromptRecipient()
        return
    end

    if IsSelf(recipient) then
        DEFunnel:Print(DEFunnel.L["IS_SELF"])
        return
    end

    self:Funnel()
end

function MailFrame:Funnel()
    local recipient = DEFunnel.db.realm.recipient
    local eligible = self:ScanBags()
    local total = #eligible

    if total == 0 then
        DEFunnel:Print(DEFunnel.L["NO_ELIGIBLE"])
        return
    end

    if SendMailNameEditBox then
        SendMailNameEditBox:SetText(recipient)
    end

    local toAttach = math.min(total, MAX_ATTACHMENTS)
    local attached = 0

    -- Recursive timer chain: each attach needs a frame to settle before
    -- the next PickupContainerItem call.
    local function step(i)
        if i > toAttach then return end
        local entry = eligible[i]
        ClearCursor()
        C_Container.PickupContainerItem(entry.bag, entry.slot)
        if CursorHasItem() then
            ClickSendMailItemButton(i, false)
            attached = attached + 1
        end
        ClearCursor()
        C_Timer.After(ATTACH_DELAY, function() step(i + 1) end)
    end

    step(1)
end

-- Fires from SendMailFrame:OnShow when the user enables autoFunnel.
-- Guards: recipient set, eligible items present, and the To: editbox isn't
-- mid-compose to someone else (empty, or already our recipient).
function MailFrame:AutoFunnelIfReady()
    if not DEFunnel.db.profile.autoFunnel then return end

    local recipient = DEFunnel.db.realm.recipient
    if not recipient or recipient == "" then return end
    if IsSelf(recipient) then return end

    if SendMailNameEditBox then
        local current = SendMailNameEditBox:GetText() or ""
        if current ~= "" and current ~= recipient then return end
    end

    if #self:ScanBags() == 0 then return end

    self:Funnel()
end

function MailFrame:PromptRecipient()
    if not StaticPopupDialogs["DEFUNNEL_SET_RECIPIENT"] then
        StaticPopupDialogs["DEFUNNEL_SET_RECIPIENT"] = {
            text = DEFunnel.L["RECIPIENT_PROMPT"],
            button1 = OKAY,
            button2 = CANCEL,
            hasEditBox = true,
            maxLetters = 64,
            OnAccept = function(self)
                local editBox = self.EditBox or self.editBox
                local name = editBox and editBox:GetText() or ""
                if name ~= "" then
                    DEFunnel.db.realm.recipient = name
                    MailFrame:OnFunnelClick()
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local parent = self:GetParent()
                local name = self:GetText() or ""
                if name ~= "" then
                    DEFunnel.db.realm.recipient = name
                    parent:Hide()
                    MailFrame:OnFunnelClick()
                end
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
    StaticPopup_Show("DEFUNNEL_SET_RECIPIENT")
end
