-- One-off: builds batch 9 (final consistency pass). Rows are (a) the 20 keys whose names contain
-- / # ( ) and were invisible to the tools until the key pattern was widened, (b) Marine / Alien
-- capitalized everywhere, and (c) a few wording alignments. Writes source.tsv and proposals-1.tsv.
package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")
local en, order = gs.parse("snapshot/enUS.txt")
local cur = gs.parse("out/esES.txt")
local done = {}
for i = 1, 8 do for line in io.lines("work/batch" .. i .. "/final.tsv") do done[line:match("^([^\t]+)")] = true end end

local function cap(s)
  local t = " " .. s .. " "
  for _, w in ipairs({ "marine", "alien" }) do
    local W = w:sub(1, 1):upper() .. w:sub(2)
    t = t:gsub("([^%a\128-\255])" .. w .. "(s?)([^%a\128-\255])", "%1" .. W .. "%2%3")
    t = t:gsub("([^%a\128-\255])" .. w .. "(s?)([^%a\128-\255])", "%1" .. W .. "%2%3")
  end
  return t:sub(2, -2)
end

local manual = {
  ["BINDINGS_BUY/EVOLVE_MENU"] = { "MENÚ DE COMPRA/EVOLUCIÓN", "", "" },
  ["BINDINGS_DROP_WEAPON_/_EJECT"] = { "SOLTAR ARMA / EYECTARSE", "", "" },
  ["BINDINGS_REQUEST_AMMO_/_ENZYME"] = { "PEDIR MUNICIÓN / ENZIMA", "", "" },
  ["BINDINGS_REQUEST_HEALING_/_MEDPACK"] = { "PEDIR CURACIÓN / MED PACK", "", "" },
  ["ADVANCED_OPTION_AV_INITIALSTATE_TOOLTIP"] = { "Define si la visión Alien está activada o no al renacer.", "FIX", "\"renacer\", the word you kept for respawn; Alien capitalized." },
  ["INFANTRY_PORTAL_TOOLTIP"] = { "Hace renacer a un Marine cada 9 segundos. Solo se puede construir cerca de una Command Station. Máximo 3 por Command Station.", "FIX", "\"renacer\", the word you kept for respawn." },
  ["SPAWN_MARINE_TOOLTIP"] = { "Los Marines muertos renacen aquí cada 9 segundos", "FIX", "\"renacer\", the word you kept for respawn." },
  ["CLAWRAILGUN_EXOSUIT"] = { "Exotraje con garra y Railgun", "CHECK", "You kept \"puño y railgun\" here in batch 3, but approved \"GARRA Y RAILGUN\" in the batch 4 event line and \"Garra\" for the module in batch 5." },
  ["BINDINGS_TAUNT"] = { "BURLA", "CHECK", "Batch 1 has PROVOCAR; the request menu and the achievement (batch 4) say Burla / Búrlate. One word for taunt." },
  ["BINDINGS_VOICE_HOSTILES"] = { "(MARINE) \\\"ENEMIGOS\\\"", "CHECK", "The request menu line you approved in batch 4 says \"Enemigos\"." },
  ["BINDINGS_VOICE_ACKOWLEDGED"] = { "\\\"ENTENDIDO\\\"/RISA", "CHECK", "The request menu line you approved in batch 4 says \"Entendido\"." },
  ["DRIFTER_REGENERATION_TOOLTIP"] = { "Los Drifters regeneran el 3% de su salud cada 2 segundos mientras reciben daño", "CHECK", "Health is \"salud\" in 21 lines and \"vida\" in these few. \"Barra de vida\" is left alone as a set phrase." },
  ["MED_PACK_TOOLTIP"] = { "Restablece 50 puntos de salud del jugador", "CHECK", "salud, as above." },
  ["OPTION_ENEMY_HEALTH"] = { "Muestra la salud total del enemigo al atacarlo", "CHECK", "salud, as above." },
  ["ENEMY_HEALTH_BARS"] = { "MOSTRAR SALUD DEL ENEMIGO", "CHECK", "salud, as above." },
  ["UPGRADE_INFESTED_TUNNEL_ENTRANCE_TOOLTIP"] = { "Las entradas de túnel infestado tienen más salud y extienden la infestación", "CHECK", "salud, as above." },
  ["VAMPIRISM_TOOLTIP"] = { "Crea un escudo temporal para ti absorbiendo salud de los enemigos cuando los golpeas con tu ataque principal", "CHECK", "salud, as above." },
  ["ADVANCED_OPTION_INSTANT_ALIENHEALTH_TOOLTIP"] = { "El círculo de salud Alien se actualiza al instante, sin animaciones, cuando cambia la salud.", "CHECK", "salud, as above; Alien capitalized." },
}
for n = 1, 5 do manual["BINDINGS_WEAPON_#" .. n] = { "ARMA #" .. n, "", "" } end
local letters = { "Q", "W", "E", "A", "S", "D", "F", "Z", "X", "G", "V" }
for n = 1, 11 do
  manual["COMBINDINGS_GRID_SPOT_" .. n .. "_(DEFAULT_" .. letters[n] .. ")"] =
    { "Posición " .. n .. " de la cuadrícula (por defecto " .. letters[n] .. ")", n == 1 and "CHECK" or "", n == 1 and "Commander button grid hotkeys." or "" }
end

local src = assert(io.open("work/batch9/source.tsv", "wb"))
local prop = assert(io.open("work/batch9/proposals-1.tsv", "wb"))
local n, caps = 0, 0
local capNote = "Marine and Alien capitalized everywhere, as the glossary keeps them as names. About half the file already did."
for _, k in ipairs(order) do
  local m, c = manual[k], cur[k]
  local section, es, flag, note
  if not done[k] then
    assert(m, "no proposal for new key " .. k)
    section, es, flag, note = "Keys the tools had missed", m[1], m[2], m[3]
  elseif m then
    section, es, flag, note = "Wording alignment", m[1], m[2], m[3]
  elseif c and cap(c) ~= c then
    section, es, flag, note = "Marine and Alien capitalized", cap(c), "FIX", capNote
    caps = caps + 1
  end
  if section then
    local status = (not done[k]) and "english" or "translated"
    src:write(table.concat({ section, k, en[k], c or "", status }, "\t"), "\n")
    prop:write(table.concat({ k, es, flag, note }, "\t"), "\n")
    n = n + 1
  end
end
src:close(); prop:close()
print("batch 9 rows:", n, "capitalization rows:", caps)
