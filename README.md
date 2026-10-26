<p align="center">
  <img src="client/gui/icons/256x256/phonehook.png" width="128" alt="Hookline icon">
</p>

# Hookline

Call blocking for **Sailfish OS 5**: unwanted calls are rejected before the phone rings.

## Blocks

- Numbers, number ranges (`prefix*`), hidden numbers and contacts you choose
- Optional: unknown callers checked with [PhoneBlock](https://phoneblock.net) (off by default)
- Daily block lists, on by default for your country:

| Country | Blocks | Source |
|---|---|---|
| 🇫🇷 France | ARCEP telemarketing prefixes, most reported numbers | [Saracroche](https://saracroche.org) (CC BY-NC-SA 4.0) |
| 🇪🇸 Spain | `400` commercial calls | [BOE](https://www.boe.es/diario_boe/txt.php?id=BOE-A-2026-8409) |
| 🇸🇰 Slovakia | `0888` direct marketing | Act 452/2021 |
| 🇮🇹 Italy | `0844` sales, `0843` surveys | [AGCOM](https://www.agcom.it/sites/default/files/migration/delibera/Delibera%20156-18-CIR.pdf) |
| 🇨🇱 Chile | `809` commercial calls | [SUBTEL](https://www.subtel.gob.cl/) |
| 🇮🇳 India | `140` promotional calls | [TRAI](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2102413) |
| 🇵🇱 Poland | Spoofed receive-only numbers | [UKE](https://numeracja.uke.gov.pl/pl/orvc_tables) |

## How

- **Filter:** uses the Sailfish OS 5 call filter ([voicecall#15](https://github.com/sailfishos/voicecall/pull/15)).
- **Fallback:** hidden numbers are hung up instead.
- **Privacy:** nothing about your calls leaves the phone, unless you turn on the PhoneBlock check.

## Build

```sh
cd client && sfdk build
```

The package is still named `phonehook`: it upgrades Phonehook and keeps your blocks.

## Add a country

- **Where:** one entry in [blocklists/index.json](https://github.com/SpecSierra/hookline-sources/blob/master/blocklists/index.json).
- **Accepted sources:** official ones (a regulator or a law) or openly licensed lists only.

## Credits

- **[Phonehook](https://github.com/omnight/phonehook):** by Johan Ekman (omnight), maintained by Armin Felder.
- **French lists:** [Saracroche](https://saracroche.org).

License: [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
