# NS2 Spanish Translation

A complete, reviewed Spanish translation of Natural Selection 2 (`ns2/gamestrings/esES.txt`), in
neutral Latin American Spanish. Version 1.0 covers all 3,854 strings; the finished file is
[`out/esES.txt`](out/esES.txt). It is meant for the NS2 game repository (ns2-game), delivered in the
way its maintainer prefers.

## How it was made, and who decided what

AI was used to speed the work up: it produced a first draft of each line and ran the mechanical
checks. Every decision about the Spanish was made by a person: Bleu, a native Spanish speaker and
NS2 player, who:

- **Went through every glossary term by hand** before any translation started (which game names
  stay in English, which are translated, and how), and kept revising the glossary as the work
  went on. The rule the file follows (translate as much as possible, keep lifeform names and most
  building names) is Bleu's, as are the individual choices: Exotraje, Destello, Puñalada, Nodo de
  energía, "vida" rather than "salud", and the rest.
- **Resolved every disagreement.** Where the draft and Bleu's judgment differed, or two approved
  lines contradicted each other, Bleu chose the wording, and the earlier lines were brought in
  line with it.
- **Checked how other games are translated** when a term had no obvious Spanish, so the choices
  match what Spanish-speaking players already know.
- **Reviewed every line of every batch personally, one by one.** All 3,854 strings passed through
  that review in nine batches; each has a recorded decision (accepted, replaced with Bleu's own
  Spanish, or kept as it was) in `work/batchN/decisions.tsv`. Jokes that did not work in Spanish
  were rewritten by Bleu, not left to the draft.

Nothing is in the final file without that review. Existing Spanish lines were only changed where
they broke the glossary or were technically broken, and each such change was shown to Bleu with
the reason.

## Snapshot

Work is done against a fixed snapshot, so upstream changes do not move the target mid-batch:

- `snapshot/enUS.txt` and `snapshot/esES.txt`, from the ns2-game `beta` branch
- commit and date in `snapshot/COMMIT.txt` (currently `c94ff24af`, 2026-09-28)

When upstream moves on, a re-sync lists new keys, keys whose English changed (their translation is
flagged for re-check) and removed keys, and those become a small follow-up batch.

## Where it stands

| | At the snapshot | Version 1.0 |
|---|---|---|
| English strings | 3,854 | 3,854 |
| Spanish, differs from English | 1,338 (35%) | 3,637 (94%) |
| Spanish, identical to English | 1,636 | 217, all names that stay as they are (buildings, lifeforms, maps, calling cards) |
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
