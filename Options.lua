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

local CUSTOM_RECIPIENT = "__custom__"

-- Returns the dropdown values map (alt names + a sentinel for custom entry)
-- and a list of order-preserving keys.
local function BuildRecipientChoices()
    local alts = DEFunnel:GetKnownAlts()
    local values = {}
    local order = {}
    for _, name in ipairs(alts) do
        values[name] = name
        order[#order + 1] = name
    end
    values[CUSTOM_RECIPIENT] = DEFunnel.L["OPT_RECIPIENT_CUSTOM"]
    order[#order + 1] = CUSTOM_RECIPIENT
    return values, order
end

-- The dropdown's effective value: either the recipient (if it matches a known
-- alt) or the custom sentinel. The custom input below it shows the raw text.
local function GetRecipientChoice()
    local recipient = DEFunnel.db.realm.recipient or ""
    if recipient ~= "" and DEFunnel:IsKnownAlt(recipient) then
        return recipient
    end
    return CUSTOM_RECIPIENT
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
            recipientPick = {
                order = 9,
                type = "select",
                width = "double",
                name = L["OPT_RECIPIENT_PICK"],
                desc = L["OPT_RECIPIENT_PICK_DESC"],
                values = function() return (BuildRecipientChoices()) end,
                sorting = function() return (select(2, BuildRecipientChoices())) end,
                get = GetRecipientChoice,
                set = function(_, val)
                    if val == CUSTOM_RECIPIENT then
                        -- Clear the recipient so the dropdown sticks on the
                        -- custom sentinel and the input below shows empty.
                        DEFunnel.db.realm.recipient = ""
                        return
                    end
                    DEFunnel.db.realm.recipient = val
                    DEFunnel.db.realm.includeWarbound = true
                end,
            },
            recipient = {
                order = 10,
                type = "input",
                width = "double",
                name = L["OPT_RECIPIENT"],
                desc = L["OPT_RECIPIENT_DESC"],
                hidden = function() return GetRecipientChoice() ~= CUSTOM_RECIPIENT end,
                get = function() return DEFunnel.db.realm.recipient or "" end,
                set = function(_, val)
                    DEFunnel.db.realm.recipient = val and val:trim() or ""
                end,
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
            includeWarbound = {
                order = 12,
                type = "toggle",
                width = "full",
                name = L["OPT_INCLUDE_WARBOUND"],
                desc = L["OPT_INCLUDE_WARBOUND_DESC"],
                get = function() return DEFunnel.db.realm.includeWarbound end,
                set = function(_, val) DEFunnel.db.realm.includeWarbound = val end,
            },
            assignSelf = {
                order = 13,
                type = "execute",
                width = "double",
                name = function()
                    local name = UnitName("player") or ""
                    if name ~= "" then
                        return string.format("%s (%s)", L["OPT_ASSIGN_SELF"], name)
                    end
                    return L["OPT_ASSIGN_SELF"]
                end,
                desc = function()
                    return string.format(L["OPT_ASSIGN_SELF_DESC"], UnitName("player") or "")
                end,
                func = function()
                    local name = UnitName("player")
                    if not name or name == "" then return end
                    DEFunnel.db.realm.recipient = name
                    DEFunnel.db.realm.includeWarbound = true
                end,
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
            autoFunnel = {
                order = 31,
                type = "toggle",
                width = "full",
                name = L["OPT_AUTO_FUNNEL"],
                desc = L["OPT_AUTO_FUNNEL_DESC"],
                get = function() return DEFunnel.db.profile.autoFunnel end,
                set = function(_, val) DEFunnel.db.profile.autoFunnel = val end,
            },
            openToSendMail = {
                order = 32,
                type = "toggle",
                width = "full",
                name = L["OPT_OPEN_TO_SEND"],
                desc = L["OPT_OPEN_TO_SEND_DESC"],
                get = function() return DEFunnel.db.profile.openToSendMail end,
                set = function(_, val) DEFunnel.db.profile.openToSendMail = val end,
            },
            minimap = {
                order = 33,
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
