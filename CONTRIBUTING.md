# Contributing to DEFunnel

Thanks for your interest. This is a small addon — most contributions are easy and merge fast.

## Bug reports

Open a [GitHub issue](https://github.com/whatisboom/DEFunnel/issues). Helpful info:

- WoW client version (e.g. retail 12.0.5).
- DEFunnel version (settings panel header, or the release tag you installed).
- What you did, what happened, what you expected.
- Any errors from `/console scriptErrors 1` or BugSack.

## Feature ideas

Open an issue first so we can talk through fit. DEFunnel is intentionally narrow — *funnel disenchantable gear to a per-realm alt*. Adjacent features (e.g. funnel by item subclass, funnel to multiple alts) are on the table; broader mail features (Postal-style auto-open, mass send-to-many) are out of scope.

## Translations

Locale files live in `Locales/`. `enUS.lua` is the source of truth and the only one currently filled — every other locale falls back to English.

To add or improve a translation:

1. Open the locale file for your language (e.g. `Locales/deDE.lua`). It's already wired into `Locales/Locales.xml`, so you don't need to edit XML.
2. Copy the keys you want to translate from `Locales/enUS.lua`.
3. Paste them in and translate the right-hand side. Keep the `%s`/`%d` placeholders in the same order.
4. Open a PR — title it `Locales: <language> translation` and we'll merge once it loads cleanly in-game.

A minimal example:

```lua
local L = LibStub("AceLocale-3.0"):NewLocale("DEFunnel", "deDE")
if not L then return end

L["FUNNEL_BUTTON"] = "Funnel DE"
L["RECIPIENT_SAVED"] = "Empfänger auf %s gesetzt."
-- …add more keys as you translate them…
```

You don't need to translate every key in one PR — partial translations are welcome and any missing key falls back to English automatically.

## Code changes

- Lua 5.1 (WoW client). No `goto`, no integer division operators.
- Match the surrounding style (2-space indent, no trailing whitespace).
- Pre-commit manifest validation runs on `.toc`/`.xml`/`.lua` changes — install once with `bash scripts/install-hooks.sh`.
- See `CLAUDE.md` for the architecture overview.
- Smoke-test in-game before opening a PR: rsync to your AddOns folder, `/reload`, exercise the mailbox flow.

## Releases

Maintainer-only. Tagging is documented in `CLAUDE.md` under **Publishing**.
