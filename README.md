# NS2 Spanish Translation

A complete, reviewed Spanish translation of Natural Selection 2 (`ns2/gamestrings/esES.txt`), in
neutral Latin American Spanish. Version 1.01 covers all 3,854 strings; the finished file is
[`out/esES.txt`](out/esES.txt). It is meant for the NS2 game repository (ns2-game), delivered in the
way its maintainer prefers.

## How it was made, and who decided what

AI was used to speed the work up: it produced a first draft of each line and ran the mechanical
checks. Every decision about the Spanish was made by a person: Bleu, a native Spanish speaker with
C2-level English and an NS2 player. He:

- **Went through every glossary term by hand** before any translation started (which game names
  stay in English, which are translated, and how), and kept revising the glossary as the work
  went on. The rule the file follows (translate as much as possible, keep lifeform names and most
  building names) is his, as are the individual choices: Exotraje, Destello, Puñalada, Nodo de
  energía, "vida" rather than "salud", and the rest.
- **Resolved every disagreement.** Where the draft and his judgment differed, or two approved
  lines contradicted each other, he chose the wording, and the earlier lines were brought in
  line with it.
- **Checked how other games are translated** when a term had no obvious Spanish, so the choices
  match what Spanish-speaking players already know. Blink is the example: Overwatch has an
  ability of the same name and translates it as "Destello", because the literal "Parpadeo"
  sounds off in Spanish. The Fade's Blink is "Destello" here for the same reason.
- **Reviewed every line of every batch himself, one by one.** All 3,854 strings passed through
  that review in nine batches; each has a recorded decision (accepted, replaced with his own
  Spanish, or kept as it was) in `work/batchN/decisions.tsv`. Jokes that did not work in Spanish
  were rewritten by him, not left to the draft.

Nothing is in the final file without that review. Existing Spanish lines were only changed where
they broke the glossary or were technically broken, and each such change was shown to him with
the reason.

## Glossary criteria

The full list is in [`glossary/glossary.md`](glossary/glossary.md). These are the criteria behind it, as of
version 1.01, decided by Bleu in each case.

| Handling | What falls under it | Why | Examples |
|---|---|---|---|
| **Translated** | Abilities | Players read them as actions, and Spanish has a natural word for each | Blink → Destello, Stab → Puñalada, Leap → Impulso, Xenocide → Xenocidio, Bile Bomb → Bomba de Bilis, Stomp → Pisotón |
| | Weapons and equipment | Generic objects, not names | Shotgun → escopeta, Welder → soldador, Flamethrower → lanzallamas, Ammo pack → paquete de munición |
| | Alien upgrades | Ordinary words in both languages | Carapace → caparazón, Celerity → celeridad, Regeneration → regeneración |
| | Research and tech names | Technologies are translated like any other description | Phase Tech → tecnología de fase, Advanced Weaponry → armamento avanzado |
| | Game concepts and interface | Everyday vocabulary | health → vida, respawn → renacer, lifeform → forma de vida, research → investigar, lobby → sala, badge → insignia |
| | Exosuit and its modules | Descriptive compound words | Exosuit → Exotraje, Thrusters → propulsores, Ejection Seat → asiento eyectable |
| **Kept in English** | Lifeforms | Proper names of the species | Skulk, Gorge, Lerk, Fade, Onos |
| | Every faction structure | Names players use as-is in voice chat, and they match the map and the wiki. No exceptions, so the rule is easy to apply | Hive, Armory, Command Station, Infantry Portal, Phase Gate, Sentry Battery, Tunnel, Hydra, Crag, Shift, Shade, Whip, Cargo Gate |
| | Acronyms and unit names | Nothing to translate | MAC, ARC, Exo, Drifter, Babbler, Clog |
| | Factions and roles | Proper names | Marine, Alien, Kharaa, Frontiersmen, Commander |
| | Words Spanish-speaking players already use in English | Community usage wins over a formal term | mod, bot, mouse, tooltip, killfeed, Sandbox, Ready Room, Jetpack |
| | Cosmetic and product names | Collection and calling card names | Abyss, Chroma, Auric, Reinforced, "Lazy Gorge" |
| **Case by case** | Things that look like structures but are not faction structures | Translated | Power Node → Nodo de energía (part of the map, not of a faction); Evolution Chamber → cámara de evolución (a button inside the Hive) |
| | Individual exceptions decided by Bleu | Kept or translated against the general rule | Med pack stays (but Ammo pack is translated); Umbra and Aura stay, being the same word in Spanish; tech point stays |
| | Words that are both a name and a verb | Name and verb handled separately | Charge: the ability is "Carga", the verb is "cargar" or "embestir" |
| | Jokes and wordplay | Rewritten by Bleu when the joke does not survive, otherwise translated for sense | The Blink help text, the rifle-butt joke, the tutorial narrator |
| **Mixed** | An English name with a Spanish noun | The English part is the recognizable name; the Spanish part says what it is | Distress Beacon → Beacon de emergencia, Heal Spray → spray de curación, Steam Workshop → Workshop de Steam |
| | A Spanish long name with the English abbreviation | Players say the abbreviation | Heavy Machine Gun → ametralladora pesada (HMG), Submachine gun → subfusil (SMG) |
| | Item names | Collection name kept, object translated | Chroma Axe → Hacha Chroma, Damascus Green Rifle → Rifle de Damasco verde |

### Changed in 1.01: structure names

In 1.0 a few structures were translated (Phase Gate as "portal de fase", Tunnel as "túnel", Hydra
as "Hidra", the Sentry Battery, the Cargo Gate) while almost every other structure kept its English
name. Bleu found that inconsistent, and 1.01 returns all of them to English: 97 lines changed. Tech
names are still translated, so Phase Tech remains "tecnología de fase" next to "Phase Gate".

## Snapshot

Work is done against a fixed snapshot, so upstream changes do not move the target mid-batch:

- `snapshot/enUS.txt` and `snapshot/esES.txt`, from the ns2-game `beta` branch
- commit and date in `snapshot/COMMIT.txt` (currently `c94ff24af`, 2026-09-28)

When upstream moves on, a re-sync lists new keys, keys whose English changed (their translation is
flagged for re-check) and removed keys, and those become a small follow-up batch.

## Where it stands

| | At the snapshot | Version 1.01 |
|---|---|---|
| English strings | 3,854 | 3,854 |
| Spanish, differs from English | 1,338 (35%) | 3,630 (94%) |
| Spanish, identical to English | 1,636 | 224, all names that stay as they are (buildings, lifeforms, maps, calling cards) |
| Missing from Spanish | 860 | 0 |

Run `lua tools/status.lua` for current numbers and technical problems.

## How the work went

1. **Terminology and style** (done): decisions in `work/terminology-decisions.xlsx`, exported to
   `work/decisions-*.tsv`.
2. **Style guide and glossary** (done): [`docs/style-guide.md`](docs/style-guide.md) and
   [`glossary/glossary.md`](glossary/glossary.md) (source: `glossary/glossary.tsv`). Proposed articles are
   reviewed in `work/glossary-review.xlsx`.
3. **Draft, in nine batches** (done), most-seen text first: menus and options; server browser; tech
   names and tooltips; the rest of the in-game text; help screens and exos; cosmetics; Competitive
   Play; tutorials; and a final consistency pass. Uncertain lines were flagged for the reviewer.
4. **Review** of every line of each batch by Bleu, in Excel (done). Those edits fed back into the
   glossary, and earlier batches were brought in line with later decisions.
5. **In-game check** of the busiest screens with the game set to Spanish (to do).
6. **Delivery** to the game repository (to do).

## Tools

Run from the repository root. Lua 5.4 for the scripts, Excel for the workbooks.

| Command | What it does |
|---|---|
| `lua tools/status.lua` | Coverage numbers and technical problems (placeholders, key bindings, escapes, spacing) |
| `lua tools/terms.lua` | Term audit: usage counts and example pairs, to `work/terminology.tsv` |
| `powershell -ExecutionPolicy Bypass -File tools/build-terminology.ps1` | Builds `work/terminology-decisions.xlsx` from the audit and `work/style-questions.tsv` |
| `powershell -ExecutionPolicy Bypass -File tools/export-decisions.ps1` | Exports the filled-in terminology workbook to `work/decisions-terms.tsv` and `work/decisions-style.tsv` |
| `lua tools/build-glossary.lua` | Builds `glossary/glossary.tsv` and `glossary.md` from the decisions and later follow-ups |
| `powershell -ExecutionPolicy Bypass -File tools/build-glossary-review.ps1` | Builds `work/glossary-review.xlsx` for confirming articles and terms |
| `lua tools/make-batch1.lua`, `lua tools/make-batch.lua N` | Extract a batch to `work/batchN/source.tsv` (batch 1 had its own script) |
| `lua tools/convert-proposals.lua work/batchN name...` | Turns proposal drafts written with a visible ` @@ ` delimiter into the `proposals-*.tsv` files |
| `lua tools/assemble-batch.lua N` | Joins a batch with its `proposals-*.tsv`, checks placeholders, style words, glossary and length, writes `review.tsv` |
| `powershell -ExecutionPolicy Bypass -File tools/build-review.ps1 N` | Builds `work/batchN/batchN-review.xlsx` for review in Excel |
| `powershell -ExecutionPolicy Bypass -File tools/export-review.ps1 N` | Exports the reviewer's columns to `work/batchN/decisions.tsv` |
| `powershell -ExecutionPolicy Bypass -File tools/patch-review.ps1 N file` | Updates proposals inside a workbook already under review, keeping the reviewer's marks |
| `lua tools/finalize-batch.lua N` | Applies the decisions (and `corrections.tsv`) to `work/batchN/final.tsv` |
| `lua tools/build-output.lua` | Writes `out/esES.txt`: the snapshot with every finished batch applied, same format as the game file |

`tools/gamestrings.lua` holds the shared parser and the checks: every translation must keep the
English line's `%s` / `%d` / `%%` placeholders, `\n` line breaks, `BIND_…` key bindings and
`<tags>`, and escape any quote marks.

## Technical problems in the original Spanish file

Found by `tools/status.lua` and fixed in version 1.0. See `docs/bugs.md`.
