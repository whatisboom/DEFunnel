# DEFunnel

[![CurseForge](https://img.shields.io/curseforge/dt/1536948?label=CurseForge&logo=curseforge)](https://www.curseforge.com/wow/addons/defunnel)
[![GitHub release](https://img.shields.io/github/v/release/whatisboom/DEFunnel)](https://github.com/whatisboom/DEFunnel/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**For enchanters with alt-funnel workflows: stop dragging BoEs into mail one at a time.**

DEFunnel adds a single button to the Send Mail frame that auto-attaches every eligible disenchantable gear piece in your bags to a mail addressed to your designated enchanter alt. Set the recipient once per realm; one click per stack of 12.

Built for **World of Warcraft: Midnight (retail, patch 12.0.7)**.

## Why DEFunnel

- **Purpose-built for the DE pipeline.** General mail addons (Postal, Mail-Service-Reborn, etc.) are great at bulk mail, but you still hand-pick what to attach. DEFunnel knows what "disenchantable" means and only grabs that.
- **Filters by current expansion + bind state.** Won't grab a stray heirloom, won't grab last-expansion gear you forgot to vendor, won't grab anything already soulbound.
- **Warbound-until-equipped aware.** Cross-checks `C_Item.IsBoundToAccountUntilEquip` so Warband gear funnels correctly, even when the tooltip text is ambiguous.

## Features

- Adds a **Funnel DE** button to the Send Mail tab.
- Scans your regular bags and attaches up to 12 eligible items per click.
- Eligibility rules:
  - Quality at or above your configured minimum (default: Uncommon).
  - Bind on Equip *or* Warbound-until-equipped.
  - From the current expansion only (uses item expansion ID, not item level).
  - Not currently soulbound.
  - Item class is Armor or Weapon.
- Per-realm recipient — set once per realm and forget.
- Minimap launcher (toggleable).
- Localization scaffolding for 11 locales (translations welcome — see [CONTRIBUTING.md](CONTRIBUTING.md)).

## Installation

- **CurseForge:** install via the CurseForge desktop app or website.
- **Manual:** download a release zip, extract `DEFunnel/` into `World of Warcraft/_retail_/Interface/AddOns/`.

## Usage

1. Open a mailbox.
2. Click the **Funnel DE** button on the Send Mail tab.
3. The first time, you'll be prompted for your enchanter alt's name on this realm. Confirm and the funnel runs immediately.
4. Up to 12 items are attached. The chat window prints how many more are still eligible — click **Send**, then click **Funnel DE** again to attach the next batch.

DEFunnel never auto-clicks Send. You stay in control.

## Configuration

Open the settings panel via:
- `/defunnel` or `/df`
- The minimap icon (left-click)
- Blizzard's AddOns settings panel

Available options:
- **Recipient** — character name on the current realm.
- **Item qualities** — pick which qualities (Uncommon / Rare / Epic) get funneled.
- **Show minimap icon** — toggle the launcher.

### Slash commands

- `/defunnel` — opens settings.
- `/defunnel set <name>` — sets the recipient for the current realm.

## Contributing

Bug reports, feature ideas, and locale translations are all welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) — adding a translation is roughly a 4-line PR.

## License

[MIT](LICENSE) © whatisboom
