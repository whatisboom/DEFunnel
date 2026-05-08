local L = LibStub("AceLocale-3.0"):NewLocale("DEFunnel", "enUS", true, true)
if not L then return end

L["FUNNEL_BUTTON"] = "Funnel DE"

L["RECIPIENT_PROMPT"] = "Enter the name of your enchanter alt on this realm:"
L["RECIPIENT_SAVED"] = "Recipient set to %s."
L["RECIPIENT_EMPTY"] = "No recipient set. Use /defunnel set <name>."

L["FUNNEL_STATUS"] = "Funneled %d items to %s. %d more eligible — send this batch and click again."
L["NO_ELIGIBLE"] = "No eligible items found in your bags."
L["MAIL_NOT_OPEN"] = "Open the mailbox first."

L["TOOLTIP_RECIPIENT"] = "Recipient: %s"
L["TOOLTIP_NO_RECIPIENT"] = "No recipient set"
L["TOOLTIP_HINT"] = "Click to open settings"

L["OPT_SECTION_RECIPIENT"] = "Recipient"
L["OPT_SECTION_FILTERS"] = "Filters"
L["OPT_SECTION_BEHAVIOR"] = "Behavior"

L["OPT_RECIPIENT"] = "Character name"
L["OPT_RECIPIENT_DESC"] = "Your enchanter alt's character name. Stored per realm."
L["OPT_RECIPIENT_REALM"] = "Realm: %s"
L["OPT_QUALITIES"] = "Item qualities"
L["OPT_QUALITIES_DESC"] = "Items of this quality will be funneled."
L["OPT_MINIMAP"] = "Show minimap icon"
L["OPT_MINIMAP_DESC"] = "Toggle the minimap button."

L["SLASH_DESC_OPEN"] = "Open the DEFunnel settings panel."
L["SLASH_DESC_SET"] = "Set the recipient name for this realm."
