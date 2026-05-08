local addonName, addonTable = ...

local DEFunnel = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
_G.DEFunnel = DEFunnel
addonTable.DEFunnel = DEFunnel

local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local defaults = {
    global = {
        realms = {},
    },
    realm = {
        recipient = "",
        includeWarbound = true,
    },
    profile = {
        qualities = {
            [2] = true,  -- Uncommon
            [3] = true,  -- Rare
            [4] = true,  -- Epic
        },
        autoFunnel = false,
        openToSendMail = false,
        minimap = {
            hide = false,
        },
    },
}

function DEFunnel:OnInitialize()
    self.db = AceDB:New("DEFunnelDB", defaults, true)
    self.L = AceLocale:GetLocale("DEFunnel")
    local L = self.L

    self.ldb = LDB:NewDataObject("DEFunnel", {
        type = "launcher",
        text = "DEFunnel",
        icon = "Interface\\Icons\\INV_Enchant_Disenchant",
        OnClick = function(_, button)
            if button == "RightButton" then
                DEFunnel:OpenOptions()
            else
                DEFunnel:OpenOptions()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("DEFunnel")
            local recipient = DEFunnel.db.realm.recipient
            if recipient and recipient ~= "" then
                tooltip:AddLine(string.format(L["TOOLTIP_RECIPIENT"], recipient), 1, 1, 1)
            else
                tooltip:AddLine(L["TOOLTIP_NO_RECIPIENT"], 1, 0.5, 0.5)
            end
            tooltip:AddLine(L["TOOLTIP_HINT"], 0.7, 0.7, 0.7)
        end,
    })

    LDBIcon:Register("DEFunnel", self.ldb, self.db.profile.minimap)

    self:RegisterChatCommand("defunnel", "SlashHandler")
    self:RegisterChatCommand("df", "SlashHandler")

    if self.Options and self.Options.Setup then
        self.Options:Setup()
    end
end

function DEFunnel:OnEnable()
    self:StampSelf()

    self:RegisterEvent("MAIL_SHOW", function()
        if self.MailFrame then self.MailFrame:OnShow() end
        if self.db.profile.openToSendMail then
            -- Defer one frame so MailFrame finishes its own init before
            -- we click a tab on it.
            C_Timer.After(0, function()
                if _G.MailFrame and _G.MailFrame:IsShown() and MailFrameTab2 then
                    MailFrameTab2:Click()
                end
            end)
        end
    end)
    self:RegisterEvent("MAIL_CLOSED", function()
        if self.MailFrame then self.MailFrame:OnClose() end
    end)
end

function DEFunnel:SlashHandler(input)
    input = input and input:trim() or ""
    if input == "" then
        self:OpenOptions()
        return
    end

    local cmd, rest = input:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""

    if cmd == "set" then
        local name = rest and rest:trim() or ""
        if name == "" then return end
        self.db.realm.recipient = name
    else
        self:OpenOptions()
    end
end

function DEFunnel:OpenOptions()
    if self.Options and self.Options.Open then
        self.Options:Open()
    end
end

-- Stamp the current character into the global per-realm character list so
-- the recipient dropdown can offer them as a known alt later.
function DEFunnel:StampSelf()
    local realm = GetRealmName()
    local name = UnitName("player")
    if not realm or not name or realm == "" or name == "" then return end
    self.db.global.realms[realm] = self.db.global.realms[realm] or {}
    self.db.global.realms[realm][name] = true
end

-- Returns a sorted array of known character names on the current realm,
-- including the current character (which is stamped on enable).
function DEFunnel:GetKnownAlts()
    local realmTable = self.db.global.realms[GetRealmName()]
    local alts = {}
    if realmTable then
        for name in pairs(realmTable) do
            alts[#alts + 1] = name
        end
    end
    table.sort(alts)
    return alts
end

-- True if `name` is a tracked character on the current realm (i.e., in the
-- player's Warband as far as this addon knows).
function DEFunnel:IsKnownAlt(name)
    if not name or name == "" then return false end
    local realmTable = self.db.global.realms[GetRealmName()]
    return realmTable and realmTable[name] == true or false
end

function DEFunnel:RefreshMinimap()
    if self.db.profile.minimap.hide then
        LDBIcon:Hide("DEFunnel")
    else
        LDBIcon:Show("DEFunnel")
    end
end
