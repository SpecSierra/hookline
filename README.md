<p align="center">
  <img src="client/gui/icons/256x256/phonehook.png" width="128" alt="Hookline icon">
</p>

# Hookline

**Call blocking for Sailfish OS 5.** Hookline rejects unwanted calls *before the phone rings*: the numbers, prefixes, hidden numbers and contacts you block, plus block lists that are updated every day.

Hookline is a rework of [Phonehook](https://github.com/omnight/phonehook) for Sailfish OS 5. It drops Phonehook's website lookups, which no longer work, and keeps what protects you.

## What it blocks

- **Your rules:** a number, every number starting with a prefix (`0899*`), hidden numbers, or any number of a contact.
- **Block lists for your country:** they are enabled automatically when your SIM's country has one, and can be switched on or off in *Block lists*.

| Country | List | Source |
|---|---|---|
| 🇫🇷 France | Telemarketing prefixes set by ARCEP, plus the operator ranges and numbers most reported by the community | [Saracroche](https://saracroche.org), CC BY-NC-SA 4.0 |
| 🇪🇸 Spain | `400`, the range all commercial calls must use | [BOE-A-2026-8409](https://www.boe.es/diario_boe/txt.php?id=BOE-A-2026-8409) |
| 🇸🇰 Slovakia | `0888`, the direct-marketing range | Act 452/2021, §116(12) |
| 🇮🇹 Italy | `0844` (sales) and `0843` (surveys); optional for callers, so only part of the telemarketing | [AGCOM 156/18/CIR](https://www.agcom.it/sites/default/files/migration/delibera/Delibera%20156-18-CIR.pdf) |
| 🇨🇱 Chile | `809`, unsolicited mass and commercial calls | [SUBTEL](https://www.subtel.gob.cl/) |
| 🇮🇳 India | `140`, promotional calls | [TRAI](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2102413) |

Most other countries do not reserve a number range for telemarketing, so there is nothing reliable to block there by default. Your own rules work everywhere.

## How it works

Sailfish OS 5 has an official call filter in the voicecall service ([sailfishos/voicecall#15](https://github.com/sailfishos/voicecall/pull/15)): numbers in its reject list are refused before the phone rings, with no call screen. Hookline's background service keeps that list in sync with your rules and the enabled block lists. Numbers already in the list that Hookline didn't add are left alone.

A few rules can't be expressed in that list, such as hidden numbers or a `*` in the middle of a number. For those, the service hangs up the call as soon as it is detected, like Phonehook did.

- **Privacy:** Hookline sends nothing about your calls anywhere. The only network traffic is the daily download of the block lists.
- **Rejected calls** still appear in the call history, so you can see what was blocked.

## Install

Hookline needs **Sailfish OS 5** (the call filter is not available on older versions). Build the RPM with the Sailfish SDK from `client/`:

```sh
cd client
sfdk build
```

Then install it with `pkcon install-local phonehook-*.rpm` or the file manager. The package is still called `phonehook`, so it upgrades an existing Phonehook installation and keeps its blocks.

## Adding a block list

Block lists are not built into the app: they are described in [`blocklists/index.json`](https://github.com/SpecSierra/phonehook-sources/blob/master/blocklists/index.json) in the [phonehook-sources](https://github.com/SpecSierra/phonehook-sources) repository, so a new country only needs a pull request there. Each list gives:

- **Basics:** its country, name, description and licence.
- **Number format:** `country_code` and `trunk_prefix`, so numbers are matched in both international and national form.
- **Files to download:** one JSON object per line, `{"name": "…", "pattern": "34400######"}`, where each `#` stands for any digit.

Please only add official sources (a regulator or a law) or lists with an open licence.

## Credits

- **Phonehook** was created by **Johan Ekman (omnight)** in 2015 and maintained from 2019 by **Armin Felder**, with many contributors and translators.
- **French lists** come from [Saracroche](https://saracroche.org) (cbouvat), licensed CC BY-NC-SA 4.0.
- The other country lists come from the regulations linked above.

## License

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
