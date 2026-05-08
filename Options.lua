local addonName, addonTable = ...
local DEFunnel = addonTable.DEFunnel or _G.DEFunnel

local Options = {}
DEFunnel.Options = Options

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Wrap a string in the Blizzard quality color escape so the label reads
-- in its native quality color (green/blue/purple).
local function ColorByQuality(quality, text)
    local hex = select(4, GetItemQualityColor(quality))
    if hex then
        return "|c" .. hex .. text .. "|r"
    end
    return text
end

function Options:Setup()
    local L = DEFunnel.L

    local qualityValues = {
        [2] = ColorByQuality(2, ITEM_QUALITY2_DESC),
        [3] = ColorByQuality(3, ITEM_QUALITY3_DESC),
        [4] = ColorByQuality(4, ITEM_QUALITY4_DESC),
    }

    local options = {
        type = "group",
        name = "DEFunnel",
        args = {
            recipientHeader = {
                order = 5,
                type = "header",
                name = L["OPT_SECTION_RECIPIENT"],
            },
            recipient = {
                order = 10,
                type = "input",
                width = "double",
                name = L["OPT_RECIPIENT"],
                desc = L["OPT_RECIPIENT_DESC"],
                get = function() return DEFunnel.db.realm.recipient or "" end,
                set = function(_, val) DEFunnel.db.realm.recipient = val and val:trim() or "" end,
            },
            recipientRealm = {
                order = 11,
                type = "description",
                width = "full",
                name = function()
                    return "|cff999999" .. string.format(L["OPT_RECIPIENT_REALM"], GetRealmName() or "") .. "|r"
                end,
                fontSize = "small",
            },

            filtersHeader = {
                order = 20,
                type = "header",
                name = L["OPT_SECTION_FILTERS"],
            },
            qualities = {
                order = 21,
                type = "multiselect",
                name = L["OPT_QUALITIES"],
                desc = L["OPT_QUALITIES_DESC"],
                values = qualityValues,
                get = function(_, key) return DEFunnel.db.profile.qualities[key] end,
                set = function(_, key, val) DEFunnel.db.profile.qualities[key] = val end,
            },

            behaviorHeader = {
                order = 30,
                type = "header",
                name = L["OPT_SECTION_BEHAVIOR"],
            },
            minimap = {
                order = 32,
                type = "toggle",
                width = "full",
                name = L["OPT_MINIMAP"],
                desc = L["OPT_MINIMAP_DESC"],
                get = function() return not DEFunnel.db.profile.minimap.hide end,
                set = function(_, val)
                    DEFunnel.db.profile.minimap.hide = not val
                    DEFunnel:RefreshMinimap()
                end,
            },
        },
    }

    AceConfig:RegisterOptionsTable("DEFunnel", options)
    self.dialogFrame = AceConfigDialog:AddToBlizOptions("DEFunnel", "DEFunnel")
end

function Options:Open()
    -- 12.x Settings API
    if Settings and Settings.OpenToCategory and self.dialogFrame then
        Settings.OpenToCategory(self.dialogFrame.name)
    elseif AceConfigDialog then
        AceConfigDialog:Open("DEFunnel")
    end
end
