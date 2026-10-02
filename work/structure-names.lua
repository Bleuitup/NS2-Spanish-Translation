-- One-off, 2026-10-03: every faction structure keeps its English name (Bleu's rule after 1.0).
-- Phase Gate, Tunnel / Gorge Tunnel / Infested Tunnel, Hydra, Cargo Gate and the Sentry (Power)
-- Battery go back to English in every approved line. Power Node stays "Nodo de energía" (a map
-- element), Phase Tech stays "tecnología de fase" (tech names are translated) and the Evolution
-- Chamber stays "cámara de evolución" (a button inside the Hive, not a structure).
-- Appends the changed lines to each owning batch's corrections.tsv.
package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")
local en, order = gs.parse("snapshot/enUS.txt")

local rules = {
  { "TÚNELES DE GORGE", "GORGE TUNNELS" }, { "[Tt]úneles de Gorge", "Gorge Tunnels" }, { "[Tt]únel de Gorge", "Gorge Tunnel" },
  { "[Tt]únel infestado", "Infested Tunnel" },
  { "TÚNELES", "TUNNELS" }, { "TÚNEL", "TUNNEL" }, { "[Tt]úneles", "Tunnels" }, { "[Tt]únel", "Tunnel" },
  { "PORTALES DE FASE", "PHASE GATES" }, { "PORTAL DE FASE", "PHASE GATE" },
  { "[Pp]ortales de fase", "Phase Gates" }, { "[Pp]ortal de fase", "Phase Gate" },
  { "HIDRAS", "HYDRAS" }, { "HIDRA", "HYDRA" }, { "Hidras", "Hydras" }, { "Hidra", "Hydra" },
  { "Puertas de Carga", "Cargo Gates" }, { "Puerta de Carga", "Cargo Gate" },
}
local function convert(key, v)
  for _, r in ipairs(rules) do v = v:gsub(r[1], r[2]) end
  -- The battery: the name the English line uses (the structure is "Power Battery"; tips say "Sentry Battery").
  local name = en[key]:find("Power Batter") and "Power Battery" or "Sentry Battery"
  local plural = name == "Power Battery" and "Power Batteries" or "Sentry Batteries"
  v = v:gsub("Baterías de Energía", plural):gsub("Batería de Energía", name)
  return v
end

local reason = "Faction structure names stay in English (Bleu, 2026-10-03)."
local total = 0
for b = 1, 9 do
  local path = "work/batch" .. b .. "/final.tsv"
  local add = {}
  for line in io.lines(path) do
    local k, v = line:gsub("\r$", ""):match("^([^\t]+)\t(.*)$")
    if k and en[k] then
      local nv = convert(k, v)
      if nv ~= v then add[#add + 1] = k .. "\t" .. nv .. "\t" .. reason end
    end
  end
  if #add > 0 then
    local f = assert(io.open("work/batch" .. b .. "/corrections.tsv", "ab"))
    for _, l in ipairs(add) do f:write(l, "\n") end
    f:close()
  end
  print("batch " .. b, #add)
  total = total + #add
end
print("total", total)
