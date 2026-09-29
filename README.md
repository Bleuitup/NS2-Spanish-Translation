# NS2 Spanish Translation

Completing and reviewing the Spanish translation of Natural Selection 2 (`ns2/gamestrings/esES.txt`),
in neutral Latin American Spanish. An AI first pass is followed by a full manual review by Bleu;
nothing is delivered without that review.

Private for now. The finished text is meant for the NS2 game repository (ns2-game), delivered in
the way its maintainer prefers.

## Snapshot

Work is done against a fixed snapshot, so upstream changes do not move the target mid-batch:

- `snapshot/enUS.txt` and `snapshot/esES.txt`, from the ns2-game `beta` branch
- commit and date in `snapshot/COMMIT.txt` (currently `c94ff24af`, 2026-09-28)

When upstream moves on, a re-sync lists new keys, keys whose English changed (their translation is
flagged for re-check) and removed keys, and those become a small follow-up batch.

## Where it stands

| | Strings |
|---|---|
| English | 3,834 |
| Spanish, translated | 1,338 (35%) |
| Spanish, identical to English | 1,636 |
| Missing from Spanish | 860 |

Run `lua tools/status.lua` for current numbers and technical problems.

## Plan

1. **Terminology and style** (current phase): decide how each game term is handled (keep English,
   translate, or both) and the general style rules, in `work/terminology-decisions.xlsx`.
2. **Style guide**: the decisions written up as one document, also used as the AI instructions.
3. **AI first pass, in batches**, most-seen text first: menus and options; server browser; buy
   menus, HUD and tooltips; help screen and exos; items and badges; Competitive Play; tutorial.
   Uncertain lines are flagged.
4. **Review** of each batch in Excel. Edits feed back into the glossary.
5. **In-game check** of the busiest screens with the game set to Spanish.
6. **Delivery** batch by batch.

Existing Spanish lines are kept unless they break the glossary or are technically broken; those
are flagged for review, never rewritten silently.

## Tools

Run from the repository root. Lua 5.4 for the scripts, Excel for the workbooks.

| Command | What it does |
|---|---|
| `lua tools/status.lua` | Coverage numbers and technical problems (placeholders, key bindings, escapes, spacing) |
| `lua tools/terms.lua` | Term audit: usage counts and example pairs, to `work/terminology.tsv` |
| `powershell -ExecutionPolicy Bypass -File tools/build-terminology.ps1` | Builds `work/terminology-decisions.xlsx` from the audit and `work/style-questions.tsv` |

`tools/gamestrings.lua` holds the shared parser and the checks: every translation must keep the
English line's `%s` / `%d` / `%%` placeholders, `\n` line breaks, `BIND_…` key bindings and
`<tags>`, and escape any quote marks.

## Technical problems in the current Spanish file

Found by `tools/status.lua`; to be fixed in the first batch. See `docs/bugs.md`.
