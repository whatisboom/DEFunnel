# DEFunnel

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Auto-funnel disenchantable gear to your enchanter alt. One click on the Send Mail frame attaches every eligible BoE and Warbound-until-equipped armor or weapon piece from the current expansion to a mail addressed to your designated alt.

Built for **World of Warcraft: Midnight (retail, patch 12.0.5)**.

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
- Localization scaffolding for 11 locales (translations welcome via PR).

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

## License

[MIT](LICENSE) © whatisboom
