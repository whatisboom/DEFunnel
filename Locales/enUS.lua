local L = LibStub("AceLocale-3.0"):NewLocale("DEFunnel", "enUS", true, true)
if not L then return end

L["FUNNEL_BUTTON"] = "Funnel DE"

L["RECIPIENT_PROMPT"] = "Enter the name of your enchanter alt on this realm:"
L["RECIPIENT_SAVED"] = "Recipient set to %s."
L["RECIPIENT_EMPTY"] = "No recipient set. Use /defunnel set <name>."

L["FUNNEL_STATUS"] = "Funneled %d items to %s. %d more eligible — send this batch and click again."
L["NO_ELIGIBLE"] = "No eligible items found in your bags."
L["MAIL_NOT_OPEN"] = "Open the mailbox first."
L["IS_SELF"] = "You are the configured recipient — change it to funnel from this character."

L["TOOLTIP_RECIPIENT"] = "Recipient: %s"
L["TOOLTIP_NO_RECIPIENT"] = "No recipient set"
L["TOOLTIP_HINT"] = "Click to open settings"

L["OPT_SECTION_RECIPIENT"] = "Recipient"
L["OPT_SECTION_FILTERS"] = "Filters"
L["OPT_SECTION_BEHAVIOR"] = "Behavior"

L["OPT_RECIPIENT"] = "Character name"
L["OPT_RECIPIENT_DESC"] = "Your enchanter alt's character name. Stored per realm."
L["OPT_RECIPIENT_REALM"] = "Realm: %s"
L["OPT_RECIPIENT_PICK"] = "Recipient"
L["OPT_RECIPIENT_PICK_DESC"] = "Pick one of your characters on this realm, or choose \"Other character...\" to enter a name manually. Only characters you've logged into with this addon enabled appear in the list."
L["OPT_RECIPIENT_CUSTOM"] = "Other character..."
L["OPT_INCLUDE_WARBOUND"] = "Include warbound items"
L["OPT_INCLUDE_WARBOUND_DESC"] = "Warbound items can only be given to characters in your Warband (same WoW account on this realm). Disable if your recipient is on a different account."
L["OPT_ASSIGN_SELF"] = "Use this character for this realm"
L["OPT_ASSIGN_SELF_DESC"] = "Sets the current character (%s) as the recipient for this realm. Useful when you're logged into your enchanter alt and want every other character on this realm to funnel to them."
L["OPT_QUALITIES"] = "Item qualities"
L["OPT_QUALITIES_DESC"] = "Items of this quality will be funneled."
L["OPT_AUTO_FUNNEL"] = "Auto-funnel when Send Mail tab opens"
L["OPT_AUTO_FUNNEL_DESC"] = "Automatically attach eligible items the moment the Send Mail tab is shown. Skipped if the To: field already has a different name typed."
L["OPT_OPEN_TO_SEND"] = "Open mailbox to Send Mail tab"
L["OPT_OPEN_TO_SEND_DESC"] = "When opening a mailbox, jump straight to the Send Mail tab instead of the Inbox."

L["OPT_MINIMAP"] = "Show minimap icon"
L["OPT_MINIMAP_DESC"] = "Toggle the minimap button."

L["SLASH_DESC_OPEN"] = "Open the DEFunnel settings panel."
L["SLASH_DESC_SET"] = "Set the recipient name for this realm."
