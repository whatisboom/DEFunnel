-- Standalone test runner. Run: lua tests/run.lua
-- Tests DEFunnel's pure-logic module (Eligibility.lua) outside the WoW
-- client, the same way VaultTracker/BoomForge's tests/run.lua do.
local passed, failed = 0, 0

local function eq(actual, expected, msg)
  if actual == expected then passed = passed + 1
  else failed = failed + 1
    print(("FAIL: %s\n  expected %s, got %s"):format(msg, tostring(expected), tostring(actual)))
  end
end

-- Minimal LibStub shim. Core.lua pulls in several Ace3/LDB libs at file
-- scope, but only AceAddon-3.0's NewAddon is actually exercised at load time
-- for these tests -- OnInitialize (where the others get used) is defined but
-- never invoked here, so the rest just need to not error on lookup.
_G.LibStub = function(name)
  if name == "AceAddon-3.0" then
    return { NewAddon = function(_, addonName, ...) return {} end }
  end
  return setmetatable({}, { __index = function() return function() end end })
end

-- Blizzard's localized GlobalStrings, normally injected by the client.
-- Real values don't matter for these tests -- only that ClassifyBindFromLines
-- compares tooltip line text against whatever these globals happen to hold.
_G.ITEM_BIND_ON_EQUIP = "Binds when equipped"
_G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP = "Binds to Warband until equipped"
_G.ITEM_SOULBOUND = "Soulbound"
_G.ITEM_BIND_ON_PICKUP = "Binds when picked up"
-- `Enum` is intentionally left undefined so Eligibility.lua exercises its
-- own numeric-fallback path (CLASS_WEAPON=2, CLASS_ARMOR=4), same as it
-- would on a WoW build old enough to lack Enum.ItemClass.

-- Load a WoW addon file the same way WoW does: chunk(addonName, addonTable).
local addonTable = {}
local function loadModule(path)
  local chunk = assert(loadfile(path))
  chunk("DEFunnel", addonTable)
end

loadModule("Core.lua")
loadModule("Eligibility.lua")

local Eligibility = addonTable.DEFunnel.Eligibility

-- ---- ClassifyBindFromLines ----
do
  local function line(text) return { leftText = text } end

  local nilA, nilB, nilC = Eligibility.ClassifyBindFromLines(nil)
  eq(nilA, false, "nil lines: isBoE false")
  eq(nilB, false, "nil lines: isWarbound false")
  eq(nilC, false, "nil lines: isSoulbound false")

  local isBoE = Eligibility.ClassifyBindFromLines({ line(ITEM_BIND_ON_EQUIP) })
  eq(isBoE, true, "BoE tooltip line sets isBoE")

  local _, isWarbound = Eligibility.ClassifyBindFromLines({ line(ITEM_ACCOUNTBOUND_UNTIL_EQUIP) })
  eq(isWarbound, true, "warbound tooltip line sets isWarbound")

  local _, _, isSoulbound1 = Eligibility.ClassifyBindFromLines({ line(ITEM_SOULBOUND) })
  eq(isSoulbound1, true, "soulbound tooltip line sets isSoulbound")

  local _, _, isSoulbound2 = Eligibility.ClassifyBindFromLines({ line(ITEM_BIND_ON_PICKUP) })
  eq(isSoulbound2, true, "bind-on-pickup tooltip line also sets isSoulbound")

  local a, b, c = Eligibility.ClassifyBindFromLines({ line("Unique-Equipped"), line("Requires Level 80") })
  eq(a, false, "unrelated lines: isBoE false")
  eq(b, false, "unrelated lines: isWarbound false")
  eq(c, false, "unrelated lines: isSoulbound false")

  local d = Eligibility.ClassifyBindFromLines({ {} }) -- line with no leftText
  eq(d, false, "line missing leftText doesn't error, isBoE false")
end

-- ---- IsEligibleDecision ----
do
  local CLASS_WEAPON, CLASS_ARMOR = Eligibility.CLASS_WEAPON, Eligibility.CLASS_ARMOR
  eq(CLASS_WEAPON, 2, "CLASS_WEAPON falls back to 2 without Enum")
  eq(CLASS_ARMOR, 4, "CLASS_ARMOR falls back to 4 without Enum")

  local qualities = { [2] = true, [3] = true, [4] = true } -- Uncommon/Rare/Epic
  local function base(overrides)
    local p = {
      quality = 3,
      classID = CLASS_ARMOR,
      expacID = 12,
      currentExpac = 12,
      isBoE = true,
      isWarbound = false,
      isSoulbound = false,
      qualities = qualities,
      allowWarbound = false,
    }
    for k, v in pairs(overrides or {}) do p[k] = v end
    return p
  end

  eq(Eligibility.IsEligibleDecision(base()), true, "baseline BoE armor, correct expac/quality: eligible")

  eq(Eligibility.IsEligibleDecision(base({ quality = 1 })), false, "quality not in qualities table: ineligible")

  eq(Eligibility.IsEligibleDecision(base({ classID = 6 })), false, "classID not weapon/armor: ineligible")
  eq(Eligibility.IsEligibleDecision(base({ classID = CLASS_WEAPON })), true, "weapon class also eligible")

  local noLinkParams = base()
  noLinkParams.expacID = nil -- {expacID = nil} in a table constructor never sets the key at all
  eq(Eligibility.IsEligibleDecision(noLinkParams), false, "nil expacID (no link resolved yet): ineligible")

  eq(Eligibility.IsEligibleDecision(base({ expacID = 11 })), false, "expacID from a prior expansion: ineligible")

  eq(Eligibility.IsEligibleDecision(base({ isSoulbound = true })), false,
    "soulbound overrides everything else: ineligible even if isBoE true")

  eq(Eligibility.IsEligibleDecision(base({ isBoE = false, isWarbound = true, allowWarbound = false })), false,
    "warbound item ineligible when allowWarbound is off")
  eq(Eligibility.IsEligibleDecision(base({ isBoE = false, isWarbound = true, allowWarbound = true })), true,
    "warbound item eligible when allowWarbound is on")

  eq(Eligibility.IsEligibleDecision(base({ isBoE = false, isWarbound = false })), false,
    "neither BoE nor warbound (e.g. already account-bound freely): ineligible")
end

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then os.exit(1) end
