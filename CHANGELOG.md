# Changelog

All notable changes to **DEFunnel** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-06-15

### Changed
- Updated for World of Warcraft patch 12.0.7 (Interface 120007).

## [0.2.0] - 2026-05-08

### Changed
- The Funnel DE button is now hidden on the character configured as the realm's recipient. Visibility updates live if the recipient is changed in-session from any source (Options panel, `/df set`, or the recipient popup).

## [0.1.0] - 2026-05-08

### Added
- `Funnel DE` button on the Send Mail tab.
- Funnels current-expansion BoE and Warbound-until-equipped armor and weapons.
- Per-realm recipient with a dropdown of characters you've logged into.
- "Use this character for this realm" button.
- "Include warbound items" toggle for cross-account recipients.
- Quality filters (Uncommon / Rare / Epic).
- Auto-funnel when the Send Mail tab opens (optional).
- Open mailbox straight to Send Mail (optional).
- Minimap launcher.
- Slash commands `/defunnel` and `/defunnel set <name>`.
- Localization scaffold for 10 non-English locales.
