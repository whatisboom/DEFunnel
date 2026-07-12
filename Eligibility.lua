local addonName, addonTable = ...
local DEFunnel = addonTable.DEFunnel or _G.DEFunnel

-- Pure decision logic for MailFrame's item-funneling rules. No WoW API calls
-- here -- callers fetch tooltip lines / item data via the API and pass the
-- extracted values in, which is what makes this testable outside the client
-- (see tests/run.lua).
local Eligibility = {}
DEFunnel.Eligibility = Eligibility

-- Item class IDs (avoid LE_ITEM_CLASS_* removed in some builds).
Eligibility.CLASS_WEAPON = Enum and Enum.ItemClass and Enum.ItemClass.Weapon or 2
Eligibility.CLASS_ARMOR  = Enum and Enum.ItemClass and Enum.ItemClass.Armor  or 4

-- Given a bag-slot's tooltip lines (as returned by C_TooltipInfo.GetBagItem),
-- classify bind status purely from the line text. Callers layer an API-based
-- warbound cross-check on top (see MailFrame.lua:ClassifyBind) -- tooltip
-- text alone isn't authoritative for an already-bound BoE item.
function Eligibility.ClassifyBindFromLines(lines)
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
	return isBoE, isWarbound, isSoulbound
end

-- Decides whether an item is eligible to be funneled, given already-resolved
-- inputs (item class/expansion lookups and bind classification are API calls
-- that happen in MailFrame.lua before this is called).
--
-- p.quality, p.classID, p.expacID, p.currentExpac, p.isBoE, p.isWarbound,
-- p.isSoulbound, p.qualities (settings table), p.allowWarbound
function Eligibility.IsEligibleDecision(p)
	if not p.qualities[p.quality or 0] then return false end
	if p.classID ~= Eligibility.CLASS_WEAPON and p.classID ~= Eligibility.CLASS_ARMOR then return false end
	if p.expacID == nil then return false end
	if p.expacID ~= p.currentExpac then return false end
	if p.isSoulbound then return false end
	if p.isWarbound and not p.allowWarbound then return false end
	if not (p.isBoE or p.isWarbound) then return false end
	return true
end
