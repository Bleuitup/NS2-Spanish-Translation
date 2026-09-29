# Technical problems in the current Spanish file

Found by `lua tools/status.lua` on the snapshot (`c94ff24af`), then checked against how the game uses
each string. To be fixed in the first batch.

## Visible in game

| Key | English | Current Spanish | Problem |
|---|---|---|---|
| `RIFLE_TOOLTIP` | `BIND_PrimaryAttack to attack with standard-issue rifle. BIND_SecondaryAttack will perform a rifle butt.` | `BIND_Primary attack para disparar con el rifle. …` | `BIND_Primary` is not a key binding name, so the fire key is never shown; the tooltip reads "BIND_Primary attack". Must be `BIND_PrimaryAttack`. |
| `CONSTRUCT_UNBUILT` | `Unbuilt ` (trailing space) | `Sin construir` | The game joins this directly onto the structure name (`NS2Utility.lua`, `string.format("%s%s%s%s", maturity, secondaryText, primaryText, …)`), so Spanish players see "Sin construirExtractor". Needs the trailing space. |
| `CONSTRUCT_UNPOWERED` | `Unpowered ` (trailing space) | `Sin energia` | Same join: "Sin energiaArmory". Needs the trailing space, and the accent: "Sin energía ". |

Translation note for these two: the game puts this text *before* the name, so the Spanish must work
as a prefix ("Sin construir Extractor"); "Extractor sin construir" is not possible without a code
change.

## Harmless

- A trailing space at the end of a sentence, missing in Spanish: `COMMANDER_TUT_BUILD_SECOND_SHELL`,
  `_SPUR`, `_VEIL`, `COMMANDER_TUT_ORDER_DRIFTER_TO_HIVE`, `COMMANDER_TUT_ORDER_TROOPS`,
  `COMMANDER_TUT_RESEARCH_WEAPON_ONE`, `TECH_POINT_TOOLTIP`, `TIPVIDEO_2_GORGE_GORGE_CLOGS`,
  `TUT_MARINE_MSG_16`. Nothing is appended after these.
- `EXPLORE_MODE_INITIALIZED`: `<number>` is translated as `<número>`. It is a description of what to
  type ("speed <number>"), not a placeholder, so translating it is fine.
