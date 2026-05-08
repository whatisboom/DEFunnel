local addonName, addonTable = ...

local DEFunnel = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
_G.DEFunnel = DEFunnel
addonTable.DEFunnel = DEFunnel

local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local defaults = {
    realm = {
        recipient = "",
    },
    profile = {
        qualities = {
            [2] = true,  -- Uncommon
            [3] = true,  -- Rare
            [4] = true,  -- Epic
        },
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
    self:RegisterEvent("MAIL_SHOW", function()
        if self.MailFrame then self.MailFrame:OnShow() end
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

function DEFunnel:RefreshMinimap()
    if self.db.profile.minimap.hide then
        LDBIcon:Hide("DEFunnel")
    else
        LDBIcon:Show("DEFunnel")
    end
end
