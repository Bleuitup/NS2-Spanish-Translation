-- Terminology audit: for each game term, how often English uses it, how the current Spanish
-- file handles it (keeps the English word or not), a real example pair, and a suggested
-- decision. Writes work/terminology.tsv for tools/build-terminology.ps1.
-- usage: lua tools/terms.lua

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")

local en, order = gs.parse("snapshot/enUS.txt")
local es = gs.parse("snapshot/esES.txt")

-- { category, English term, suggested decision, suggested Spanish, note }
-- K = keep English, T = translate, M = English name + Spanish noun. "Suggested Spanish" is only
-- filled where translating. Suggestions follow what the current Spanish file already does where it
-- is consistent; the counts in the workbook show the evidence.
local K, T, M = "Keep English", "Translate", "English name + Spanish noun"
local terms = {
    -- General / UI
    { "General", "Commander", K, "", "Current file keeps it (41 vs 2)." },
    { "General", "Marine", K, "", "" },
    { "General", "Alien", K, "", "Same word in Spanish; 'alienígena' only as an adjective?" },
    { "General", "Kharaa", K, "", "Proper name." },
    { "General", "Frontiersmen", K, "", "Proper name (TSF)." },
    { "General", "team resources", T, "recursos de equipo", "Abbreviation Tres stays." },
    { "General", "personal resources", T, "recursos personales", "Abbreviation Pres stays." },
    { "General", "resources", T, "recursos", "" },
    { "General", "supply", T, "suministro", "Supply limit for commander units." },
    { "General", "round", T, "ronda", "Current file mixes 'ronda' and 'partida'; suggest round = ronda." },
    { "General", "match", T, "partida", "A match can be several rounds (Competitive Play)." },
    { "General", "game", T, "partida / juego", "Context: a game being played = partida; the game itself = juego." },
    { "General", "team", T, "equipo", "" },
    { "General", "player", T, "jugador", "" },
    { "General", "server", T, "servidor", "" },
    { "General", "Ready Room", K, "", "Place name in the game." },
    { "General", "spectator", T, "espectador", "" },
    { "General", "rookie", T, "novato", "" },
    { "General", "bot", K, "", "" },
    { "General", "lifeform", T, "forma de vida", "" },
    { "General", "structure", T, "estructura", "Current file: 'estructura' (65)." },
    { "General", "upgrade", T, "mejora", "Current file: 'mejora' (47)." },
    { "General", "research", T, "investigar / investigación", "" },
    { "General", "tech point", K, "", "Map feature; players say 'tech point'." },
    { "General", "resource node", T, "nodo de recursos", "Resource point / nozzle on the map." },
    { "General", "Tech Tree", T, "árbol tecnológico", "" },
    { "General", "badge", T, "insignia", "" },
    { "General", "skill", T, "habilidad / nivel", "Player skill rating = nivel de habilidad?" },
    { "General", "Quick Play", K, "", "Menu mode name; could be 'Partida rápida'." },
    { "General", "Competitive Play", K, "", "Menu mode name; could be 'Juego competitivo'." },
    { "General", "tutorial", T, "tutorial", "" },
    { "General", "Sandbox", K, "", "Current file: 'Modo sandbox'." },
    { "General", "mod", K, "", "" },
    -- Marine structures
    { "Marine structures", "Command Station", K, "", "Current file keeps it (14 vs 0)." },
    { "Marine structures", "Command Chair", K, "", "" },
    { "Marine structures", "Infantry Portal", K, "", "" },
    { "Marine structures", "Armory", K, "", "Current file keeps it (20 vs 1 'arsenal')." },
    { "Marine structures", "Advanced Armory", K, "", "" },
    { "Marine structures", "Arms Lab", K, "", "" },
    { "Marine structures", "Observatory", K, "", "" },
    { "Marine structures", "Phase Gate", K, "", "" },
    { "Marine structures", "Robotics Factory", K, "", "" },
    { "Marine structures", "ARC Factory", K, "", "" },
    { "Marine structures", "Prototype Lab", K, "", "" },
    { "Marine structures", "Extractor", K, "", "Same word in Spanish." },
    { "Marine structures", "Sentry", K, "", "" },
    { "Marine structures", "Sentry Battery", K, "", "" },
    { "Marine structures", "Power Node", K, "", "Current file keeps it (13 vs 0)." },
    -- Marine units and equipment
    { "Marine units", "MAC", K, "", "" },
    { "Marine units", "ARC", K, "", "" },
    { "Marine units", "Exosuit", K, "", "Current file keeps 'Exosuit' (9 vs 0 'exotraje'). Short form 'Exo'?" },
    { "Marine units", "Exo", K, "", "" },
    { "Marine units", "Jetpack", K, "", "Current file keeps it." },
    { "Marine weapons", "Rifle", K, "", "Same word in Spanish." },
    { "Marine weapons", "Pistol", T, "pistola", "" },
    { "Marine weapons", "Axe", T, "hacha", "" },
    { "Marine weapons", "Welder", K, "", "Current file keeps it (11 vs 0)." },
    { "Marine weapons", "Shotgun", T, "escopeta", "Current file: 'escopeta' (12 vs 2)." },
    { "Marine weapons", "Grenade Launcher", T, "lanzagranadas", "Current file: 'lanzagranadas' (9 vs 1)." },
    { "Marine weapons", "Flamethrower", T, "lanzallamas", "Current file: 'lanzallamas' (11 vs 2)." },
    { "Marine weapons", "Heavy Machine Gun", M, "ametralladora pesada (HMG)", "Players say HMG." },
    { "Marine weapons", "Minigun", K, "", "" },
    { "Marine weapons", "Railgun", K, "", "" },
    { "Marine weapons", "Claw", T, "garra", "Exo arm." },
    { "Marine weapons", "Plasma Launcher", T, "lanzaplasma", "Exo arm." },
    { "Marine weapons", "Mine", T, "mina", "Current file: 'mina' (16 vs 6)." },
    { "Marine weapons", "Cluster Grenade", M, "granada Cluster", "" },
    { "Marine weapons", "Pulse Grenade", M, "granada Pulse", "" },
    { "Marine weapons", "Nerve Gas Grenade", M, "granada de gas nervioso", "" },
    { "Marine equipment", "Med pack", K, "", "Medpack; current file mostly keeps it." },
    { "Marine equipment", "Ammo pack", K, "", "" },
    { "Marine equipment", "Catalyst pack", K, "", "Catpack." },
    { "Marine equipment", "Nano-shield", K, "", "Also 'Nano Shield'." },
    { "Marine equipment", "Scan", T, "escaneo", "" },
    { "Marine equipment", "Distress Beacon", K, "", "" },
    { "Marine equipment", "Power Surge", K, "", "" },
    { "Marine research", "Advanced Weaponry", K, "", "" },
    { "Marine research", "Advanced Support", K, "", "" },
    { "Marine research", "Phase Tech", K, "", "" },
    { "Marine research", "Armor", T, "armadura", "Armor #1-3: 'Armadura #1'?" },
    { "Marine research", "Weapons", T, "armas", "Weapons #1-3: 'Armas #1'?" },
    { "Exo modules", "Thrusters", K, "", "New modular exo text." },
    { "Exo modules", "Ejection Seat", K, "", "" },
    { "Exo modules", "Armor Plating", K, "", "" },
    { "Exo modules", "Nano Shield Field", K, "", "" },
    { "Exo modules", "Catalyst Field", K, "", "" },
    { "Exo modules", "Regen Field", K, "", "" },
    -- Alien lifeforms and units
    { "Alien lifeforms", "Skulk", K, "", "" },
    { "Alien lifeforms", "Gorge", K, "", "" },
    { "Alien lifeforms", "Lerk", K, "", "" },
    { "Alien lifeforms", "Fade", K, "", "" },
    { "Alien lifeforms", "Onos", K, "", "" },
    { "Alien lifeforms", "Embryo", T, "embrión", "" },
    { "Alien lifeforms", "Egg", T, "huevo", "Current file: 'huevo' (22 vs 1)." },
    { "Alien units", "Drifter", K, "", "" },
    { "Alien units", "Hydra", K, "", "" },
    { "Alien units", "Babbler", K, "", "" },
    { "Alien units", "Clog", K, "", "" },
    { "Alien units", "Web", T, "telaraña", "Gorge web." },
    { "Alien units", "Bone Wall", K, "", "" },
    -- Alien structures
    { "Alien structures", "Hive", K, "", "Current file keeps it (42 vs 0 'colmena')." },
    { "Alien structures", "Cyst", K, "", "Current file keeps it (8 vs 0 'quiste')." },
    { "Alien structures", "Harvester", K, "", "Current file keeps it (19 vs 0)." },
    { "Alien structures", "Crag", K, "", "" },
    { "Alien structures", "Shift", K, "", "" },
    { "Alien structures", "Shade", K, "", "" },
    { "Alien structures", "Whip", K, "", "" },
    { "Alien structures", "Shell", K, "", "" },
    { "Alien structures", "Spur", K, "", "" },
    { "Alien structures", "Veil", K, "", "" },
    { "Alien structures", "chamber", K, "", "Upgrade chambers (Shell, Spur, Veil); B2TP keeps 'chamber'." },
    { "Alien structures", "Tunnel", T, "túnel", "Gorge tunnels; 'Tunnel Entrance' = 'entrada de túnel'?" },
    { "Alien structures", "Evolution Chamber", K, "", "" },
    { "Alien structures", "Contamination", K, "", "" },
    -- Alien concepts
    { "Alien concepts", "Infestation", T, "infestación", "Current file: 'infestación' (17 vs 1)." },
    { "Alien concepts", "Biomass", K, "", "Current file keeps it (14 vs 0 'biomasa')." },
    { "Alien concepts", "evolve", T, "evolucionar", "" },
    -- Alien abilities
    { "Alien abilities", "Bite", K, "", "" },
    { "Alien abilities", "Leap", K, "", "" },
    { "Alien abilities", "Parasite", K, "", "" },
    { "Alien abilities", "Xenocide", K, "", "" },
    { "Alien abilities", "Spit", K, "", "" },
    { "Alien abilities", "Heal Spray", K, "", "" },
    { "Alien abilities", "Bile Bomb", K, "", "" },
    { "Alien abilities", "Spikes", K, "", "" },
    { "Alien abilities", "Spores", K, "", "" },
    { "Alien abilities", "Umbra", K, "", "" },
    { "Alien abilities", "Swipe", K, "", "" },
    { "Alien abilities", "Blink", K, "", "" },
    { "Alien abilities", "Metabolize", K, "", "" },
    { "Alien abilities", "Stab", K, "", "" },
    { "Alien abilities", "Gore", K, "", "" },
    { "Alien abilities", "Stomp", K, "", "" },
    { "Alien abilities", "Charge", K, "", "" },
    { "Alien abilities", "Bone Shield", K, "", "Also written 'Boneshield'." },
    { "Alien abilities", "Enzyme", K, "", "Drifter ability." },
    { "Alien abilities", "Mucous Membrane", K, "", "" },
    { "Alien abilities", "Hallucination", K, "", "" },
    { "Alien abilities", "Cloaking Haze", K, "", "" },
    { "Alien abilities", "Nutrient Mist", K, "", "" },
    { "Alien abilities", "Rupture", K, "", "" },
    { "Alien abilities", "Echo", K, "", "" },
    { "Alien abilities", "Ink", K, "", "" },
    { "Alien abilities", "Contamination", K, "", "" },
    -- Alien upgrades
    { "Alien upgrades", "Carapace", K, "", "" },
    { "Alien upgrades", "Regeneration", K, "", "" },
    { "Alien upgrades", "Vampirism", K, "", "" },
    { "Alien upgrades", "Camouflage", K, "", "" },
    { "Alien upgrades", "Aura", K, "", "" },
    { "Alien upgrades", "Focus", K, "", "" },
    { "Alien upgrades", "Celerity", K, "", "" },
    { "Alien upgrades", "Adrenaline", K, "", "" },
    { "Alien upgrades", "Crush", K, "", "" },
}

local function esc(s) return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")) end
local function contains(text, term)
    -- whole-word, case-insensitive
    return (" " .. text:lower() .. " "):find("%f[%w]" .. esc(term:lower()) .. "%f[%W]") ~= nil
end
local function clean(s) return (s:gsub("\\n", " "):gsub("\\\"", '"'):gsub("\t", " ")) end

local out = assert(io.open("work/terminology.tsv", "wb"))
out:write("\239\187\191")
local seenTerm = {}
for _, t in ipairs(terms) do
    local cat, term, dec, spa, note = t[1], t[2], t[3], t[4], t[5]
    if not seenTerm[term] then -- terms that never occur in the English text are skipped below
        seenTerm[term] = true
        local uses, translated, kept = 0, 0, 0
        local exampleKept, exampleOther -- shortest example of each handling; the majority one is shown
        for _, k in ipairs(order) do
            local e = en[k]
            if contains(e, term) then
                uses = uses + 1
                local s = es[k]
                if not gs.untranslated(e, s) then
                    translated = translated + 1
                    local keeps = contains(s, term)
                    if keeps then kept = kept + 1 end
                    if #e <= 160 and #e >= #term + 12 then
                        if keeps and (not exampleKept or #e < #en[exampleKept]) then exampleKept = k end
                        if not keeps and (not exampleOther or #e < #en[exampleOther]) then exampleOther = k end
                    end
                end
            end
        end
        local example = (kept * 2 >= translated) and (exampleKept or exampleOther) or (exampleOther or exampleKept)
        if uses > 0 then
            out:write(table.concat({ cat, term, uses, translated, kept, dec, spa, note,
                example and clean(en[example]) or "", example and clean(es[example]) or "", example or "" }, "\t"), "\n")
        end
    end
end
out:close()
print("wrote work/terminology.tsv")
