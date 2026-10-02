# Style guide: NS2 Spanish (esES)

The rules for every new or revised line of `esES.txt`. The AI first pass follows them; the review
checks against them. Game terms live in the [glossary](../glossary/glossary.md), which takes
precedence over anything here.

Decided by Bleu, 2026-09-29 (terminology workbook, then follow-ups in chat).

## 1. Language and tone

- **Neutral Latin American Spanish**, readable in Spain too. No voseo, no Rioplatense or Spain-only
  words (see section 8).
- **Tú** for the player, never usted or vosotros: «puedes», «selecciona», «tu equipo».
- Short and direct, like the English. Game text, not literature.

## 2. Verbs for controls

| Action | Use | Not |
|---|---|---|
| Pressing a key | **presiona** («Presiona BIND_Jump para saltar») | pulsa, aprieta |
| Clicking | **haz click** («Haz click en el Armory») | haz clic, clica, cliquea |
| Holding | **mantén presionado** | mantén pulsado |

## 3. Buttons, labels and sentences

- **Buttons and menu actions: infinitive.** «Guardar», «Aceptar», «Volver», «Investigar Jetpacks».
- **Instructions in sentences: tú imperative.** «Selecciona el Armory y compra una escopeta.»
- **ALL CAPS in English stays ALL CAPS**: «CONFIGURACIÓN», «INVESTIGACIÓN COMPLETADA». Accents stay
  on capitals.
- Titles and labels start with a capital; the rest follows Spanish rules (no Title Case):
  «Opciones de sonido», not «Opciones De Sonido».

## 4. Game terms

Follow the glossary. Its handling column means:

- **keep**: the English name stays, exactly as written: Hive, Armory, Skulk, Command Station.
- **translate**: the Spanish term: lanzallamas, biomasa, zarpazo, cámara de evolución, Exotraje.

**The rule for which is which (Bleu, batch 3 review, 2026-10-02): translate as much as possible.**
Abilities, equipment and generic things are translated (Xenocidio, Destello, Puñalada, soldador).
Lifeform names (Skulk, Gorge, Lerk, Fade, Onos) and acronyms (MAC, ARC) stay. Buildings stay in
English unless the Spanish is nearly the same word (Túnel, Hidra) or the name is plain descriptive
words (Nodo de energía, Batería de Energía). 'Med pack' stays by choice.
- **mixed**: English name with a Spanish noun: Beacon de emergencia, campo de regen.

How English names behave inside Spanish sentences:

- **Article:** the gender of the Spanish word the name stands for, as listed in the glossary:
  la Hive (colmena), el Armory (arsenal), la Command Station (estación), el Skulk.
- **Plural:** English plural: Skulks, Hives, Armories, ARCs, MACs. The article follows the Spanish
  gender: las Hives, los Armories.
- **Capitals:** as in English: Hive, Command Station, Bile Bomb.

Translated names:

- As a **name** (ability labels, research names, headings): capitalized: «Zarpazo», «Mordida»,
  «Aplastamiento».
- In **running text**, as a common noun: lowercase: «usa el zarpazo contra los marines».

Names that are also verbs:

- **Charge**: name «Carga»; the verb is **cargar** / **embestir** («el Onos puede cargar contra…»).
- **Leap**: name «Impulso», never «Salto», which is an ordinary jump.
- **Bite**: name «Mordida»; verb **morder**. **Spit**: name «Escupitajo»; verb **escupir**.

Specific terms:

- **Command Station always**, also where English says "command chair" (the seat): «vuelve a la
  Command Station».
- **Research: investigar / investigación**, never «desarrollar». «INVESTIGACIÓN COMPLETADA».
- **Upgrade:** noun **mejora**; verb **mejorar a** («Mejorar a Advanced Armory»).
- **Round / match / game:** round = **ronda**, match = **partida**, the game itself = **juego**.
  Decide case by case where English is loose; «partida» is the default for "game" as in a game
  being played.
- **Skill:** **nivel de habilidad** (player rating, bot difficulty). "Skill Tier" = **rango de
  habilidad**; "relative skill" = **habilidad relativa**. Never ELO.
- **Quick Play** = «Partida rápida», **Competitive Play** = «Partidas competitivas» (the mode; plural, capital P only).

## 5. Punctuation

- Always open **¿** and **¡**: «¿Quieres salir?», «¡Hive bajo ataque!».
- **Quotes: straight double quotes, escaped** as in the English file: `\"texto\"`.
- Decimal point, not comma, for numbers that come from the game (1.5 s).
- Keep the English line's final punctuation unless Spanish grammar needs otherwise.

## 6. Technical rules (checked by `tools/status.lua`)

- Never translate, remove or add: `%s`, `%d`, `%.0f`, `%%`, `\n`, `BIND_…` (replaced by the
  player's key), `<tags>`. Word order around them may change; each one must still appear.
- An English line that **starts or ends with a space** is glued to other text by the game. Keep
  the space in the same place. Example: `CONSTRUCT_UNBUILT = "Unbuilt "` is placed before the
  structure name, so the Spanish must read as a prefix with its trailing space: `"Sin construir "`.
- `[1:AdvancedMenu]`, `[TechPoint]` and similar bracketed codes in tutorials are UI markers: keep
  them exactly, in the matching place in the sentence.
- Escape every quote mark inside the text: `\"`.

## 7. Length

Spanish runs 20-30% longer than English. Keep buttons, tabs, column headers and HUD alerts about as
long as the English. When a line needs a shorter form than the natural Spanish, use it and flag
it. Tooltips and tutorial text have room.

## 8. Words to avoid (Spain-only)

| Avoid | Use |
|---|---|
| pulsar | presionar |
| chafar | aplastar |
| coger | tomar, agarrar |
| ordenador | computadora |
| vale | está bien, de acuerdo |
| móvil | celular |
| guay | genial |
| vosotros / os | ustedes / les |

## 9. Existing Spanish lines

- Lines that follow these rules stay as they are.
- Lines that break the glossary or these rules (e.g. «desarrollar», «pulsa», «chafar») are
  **flagged for review** in the batch they belong to, with a proposed fix. Never rewritten
  silently.
- Technically broken lines ([docs/bugs.md](bugs.md)) are fixed in the first batch.

## 10. What the AI pass flags

Each proposed line gets a flag when:

- the context is ambiguous (the key and code do not settle whether a word is a noun or a verb, who
  is speaking, etc.)
- it is much longer than the English in a tight UI spot
- the glossary does not cover a game term that appears
- an existing line is changed (always flagged, with the reason)
- the English itself looks wrong (a typo or broken text upstream)

## Still to confirm

- Articles marked *(proposed)* in the glossary (65 English names).
- Research verb: Bleu wants «investigar» checked against how popular RTS games translate it.
- Round / match: case by case during review.
