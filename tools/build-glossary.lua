-- Builds glossary/glossary.tsv, the single source of truth for game terms, from:
--   work/decisions-terms.tsv  Bleu's decisions in the terminology workbook (phase 1)
--   the follow-up decisions below (chat, 2026-09-29), which override the workbook
--   proposed articles for names left in English (Bleu to correct)
-- Columns: category, english, handling (keep | translate | mixed), spanish, article, notes
-- usage: lua tools/build-glossary.lua

local function readTsv(path)
    local rows = {}
    for line in io.lines(path) do
        line = line:gsub("^\239\187\191", ""):gsub("\r$", "")
        if line ~= "" then
            local cols = {}
            for field in (line .. "\t"):gmatch("([^\t]*)\t") do cols[#cols + 1] = field end
            rows[#rows + 1] = cols
        end
    end
    return rows
end

-- Categories come from the audit file (same row order as the decisions file).
local categories = {}
for _, r in ipairs(readTsv("work/terminology.tsv")) do categories[r[2]] = r[1] end

-- Follow-up decisions, 2026-09-29. nil fields keep the workbook value.
local overrides = {
    ["tech point"] = { handling = "keep", notes = "The existing tutorial already writes 'tech point'." },
    ["Evolution Chamber"] = { handling = "translate", spanish = "cámara de evolución", article = "la" },
    ["Command Chair"] = { handling = "keep", spanish = "Command Station", article = "la",
        notes = "Always 'Command Station', also where English says Command Chair (the seat)." },
    ["Charge"] = { handling = "translate", spanish = "Carga", article = "la",
        notes = "Ability name 'Carga' (batch 3 review); the verb is cargar / embestir." },
    ["Bite"] = { handling = "translate", spanish = "Mordida", article = "la",
        notes = "Ability name 'Mordida'; the verb is morder." },
    ["Spit"] = { handling = "translate", spanish = "Escupitajo", article = "el",
        notes = "Ability name 'Escupitajo'; the verb is escupir." },
    ["skill"] = { handling = "translate", spanish = "nivel de habilidad", article = "el",
        notes = "Player rating and bot difficulty. 'Skill Tier' = rango de habilidad; 'relative skill' = habilidad relativa. Not ELO." },
    ["Stomp"] = { handling = "translate", spanish = "Pisotón", article = "el" },
    ["Swipe"] = { handling = "translate", spanish = "Zarpazo", article = "el" },
    ["Gore"] = { handling = "translate", spanish = "Cornada", article = "la" },
    ["Leap"] = { handling = "translate", spanish = "Impulso", article = "el",
        notes = "Batch 3: 'Impulso', so it is not confused with an ordinary jump (salto)." },
    ["Crush"] = { handling = "translate", spanish = "Aplastamiento", article = "el" },
    -- spelling fixes to the workbook entries
    ["Hallucination"] = { spanish = "alucinación" },
    ["Camouflage"] = { spanish = "camuflaje" },
    ["Nano Shield Field"] = { spanish = "campo de nano-escudo" },
    ["Ejection Seat"] = { spanish = "asiento eyectable" },
    ["chamber"] = { drop = true }, -- never appears alone in the game text
    -- From the batch 1 review, 2026-09-30
    ["Ready Room"] = { article = "el", notes = "Bleu: 'IR AL READY ROOM'." },
    -- From the batch 3 review, 2026-10-02. The rule Bleu settled on: translate as much as possible.
    -- Lifeform names and acronyms stay; buildings stay in English unless the Spanish is nearly the
    -- same word (Tunnel, Hydra) or the name is plain descriptive words (Power Node).
    ["Exosuit"] = { handling = "translate", spanish = "Exotraje", article = "el", notes = "Batch 3. Capitalized like a unit name; 'Exo' stays." },
    ["Power Node"] = { handling = "translate", spanish = "Nodo de energía", article = "el", notes = "Batch 3." },
    ["Sentry Battery"] = { handling = "translate", spanish = "Batería de Energía", article = "la", notes = "Batch 3: the game calls it Power Battery." },
    ["Bone Wall"] = { handling = "translate", spanish = "Muro de Huesos", article = "el", notes = "Batch 3." },
    ["Bone Shield"] = { handling = "translate", spanish = "Escudo de Huesos", article = "el", notes = "Batch 3, to match Muro de Huesos." },
    ["Power Surge"] = { handling = "translate", spanish = "Sobretensión", article = "la", notes = "Batch 3." },
    ["Bile Bomb"] = { handling = "translate", spanish = "Bomba de Bilis", article = "la", notes = "Batch 3. Bile Mine = Mina de Bilis." },
    ["Metabolize"] = { handling = "translate", spanish = "Metabolización", article = "la", notes = "Batch 3. Advanced Metabolize = Metabolización Avanzada." },
    ["Xenocide"] = { handling = "translate", spanish = "Xenocidio", article = "el", notes = "Batch 3." },
    ["Blink"] = { handling = "translate", spanish = "Destello", article = "el", notes = "Batch 3: as Overwatch does." },
    ["Stab"] = { handling = "translate", spanish = "Puñalada", article = "la", notes = "Batch 3." },
    ["Catalyst pack"] = { handling = "translate", spanish = "paquete catalizador", article = "el", notes = "Batch 3." },
    ["Ammo pack"] = { handling = "translate", spanish = "paquete de munición", article = "el", notes = "Batch 3. The short label stays 'Paq. de munición'." },
    ["Welder"] = { handling = "translate", spanish = "soldador", article = "el", notes = "Batch 3." },
    ["Hydra"] = { handling = "translate", spanish = "Hidra", article = "la", notes = "Batch 3: nearly the same word, like Túnel." },
    ["Med pack"] = { notes = "Batch 3: Bleu keeps 'Med pack'." },
    -- From the batch 5 review, 2026-10-02
    ["Catalyst Field"] = { handling = "translate", spanish = "campo catalizador", article = "el", notes = "Batch 5: follows paquete catalizador." },
    ["Regen Field"] = { handling = "translate", spanish = "campo de regeneración", article = "el", notes = "Batch 5." },
    ["Competitive Play"] = { handling = "translate", spanish = "Partida competitiva", article = "la",
        notes = "The mode name, settled 2026-10-02: singular, capital P only, used like a proper name with no article (Partida competitiva no está disponible). Bleu tried the plural and dropped it." },
    ["resource node"] = { spanish = "nodo de recursos", article = "el", notes = "Also the resource nozzle (batch 3)." },
}

-- Proposed articles for English names (gender of the Spanish word the name stands for).
-- Only used where the workbook row has no article.
local proposedArticles = {
    Commander = "el", Marine = "el", Alien = "el", Kharaa = "los", Frontiersmen = "los",
    ["Ready Room"] = "la", bot = "el", ["tech point"] = "el", Sandbox = "el", mod = "el",
    ["Command Station"] = "la", ["Infantry Portal"] = "el", Armory = "el", ["Advanced Armory"] = "el",
    ["Arms Lab"] = "el", Observatory = "el", ["Robotics Factory"] = "la", ["ARC Factory"] = "la",
    ["Prototype Lab"] = "el", Extractor = "el", Sentry = "la", ["Sentry Battery"] = "la",
    ["Power Node"] = "el", MAC = "el", ARC = "el", Exosuit = "el", Exo = "el", Jetpack = "el",
    Rifle = "el", Welder = "el", Minigun = "la", Railgun = "la", ["Med pack"] = "el",
    ["Ammo pack"] = "el", ["Catalyst pack"] = "el", ["Distress Beacon"] = "el", ["Power Surge"] = "la",
    Skulk = "el", Gorge = "el", Lerk = "el", Fade = "el", Onos = "el",
    Drifter = "el", Hydra = "la", Babbler = "el", Clog = "el", ["Bone Wall"] = "la",
    Hive = "la", Cyst = "el", Harvester = "el", Crag = "el", Shift = "el", Shade = "la", Whip = "el",
    Shell = "la", Spur = "el", Veil = "el",
    Xenocide = "el", ["Heal Spray"] = "el", ["Bile Bomb"] = "la", Umbra = "la", Blink = "el",
    Metabolize = "el", Stab = "la", ["Bone Shield"] = "el", Aura = "el",
    ["Quick Play"] = "la", ["Competitive Play"] = "la",
}

-- Terms first met during batch reviews (not in the phase 1 workbook).
-- { category, english, handling, spanish, article, notes }
local additions = {
    { "General", "killfeed", "keep", "killfeed", "el", "Batch 1: kept in English." },
    { "General", "nameplate", "translate", "etiqueta", "la", "Batch 1: the info shown over a unit you look at." },
    { "General", "crosshair", "translate", "mira", "la", "Batch 1." },
    { "General", "waypoint", "translate", "punto de ruta", "el", "Batch 1." },
    { "General", "viewmodel", "translate", "modelo en primera persona", "el", "Batch 1." },
    { "General", "Bootcamp", "translate", "entrenamiento básico", "el", "Batch 1: the rookie server mode." },
    { "General", "Spectate", "translate", "ser espectador", "", "Batch 1: the join button reads 'Ser espectador'." },
    { "General", "location", "translate", "cuarto", "el", "Batch 1: room names on the map ('nombres de los cuartos')." },
    { "General", "Steam Workshop", "mixed", "Workshop de Steam", "el", "Batch 1." },
    { "General", "Community Servers", "translate", "servidores comunitarios", "los", "Batch 1: menu button." },
    { "General", "nickname", "translate", "apodo", "el", "Batch 1." },
    { "General", "mouse", "keep", "mouse", "el", "Batch 1: never 'ratón' (Spain)." },
    { "General", "hit sound", "translate", "sonido de impacto", "el", "Batch 1." },
    { "General", "tooltip", "keep", "tooltip", "el", "Batch 1: in option names." },
    { "General", "ranked", "translate", "rankeado", "", "Batch 2: servers that count for skill and rewards; unranked = no rankeado." },
    { "General", "kick", "translate", "expulsar", "", "Batch 2: kicked = expulsado; the commander eject vote stays 'echar al Commander'." },
    { "General", "lobby", "translate", "sala", "la", "Batch 2." },
    { "General", "replay", "translate", "repetición", "la", "Batch 2." },
    { "General", "leaderboard", "translate", "tabla de clasificación", "la", "Batch 2." },
    { "General", "Skill Tier", "translate", "rango de habilidad", "el", "Batch 2. Tier names: Novato, Recluta, Frontiersman, Líder de escuadrón, Veterano, Comandante, Operaciones Especiales, Superviviente de Sanji." },
    { "Marine structures", "Cargo Gate", "translate", "Puerta de Carga", "la", "Batch 4 (CBM): Bleu translated it." },
    { "Alien abilities", "Vortex", "translate", "Vórtice", "el", "Batch 4." },
    { "Marine weapons", "SMG", "mixed", "subfusil (SMG)", "el", "Batch 4 (CBM): subfusil as the long name, SMG as the short one." },
    { "General", "bundle", "translate", "paquete", "el", "Batch 4: Paquete Abyss, Paquete Kodiak; supporter packs are Pack de apoyo B.M.A.C." },
    { "General", "respawn", "translate", "renacer", "", "Batch 3 and 4: Bleu keeps renacer / renaciendo." },
    { "General", "health", "translate", "vida", "la", "Final pass, 2026-10-02: always vida, never salud. Players say 'no tengo vida'." },
    { "General", "taunt", "translate", "burla", "la", "Final pass: Burla / burlarse, not provocar." },
    { "Alien abilities", "Bait Ball", "translate", "bola cebo", "la", "Batch 5." },
    { "Alien abilities", "Shadow Step", "translate", "paso de sombra", "el", "Batch 5." },
    { "General", "trait", "translate", "mejora", "la", "Batch 5: the alien upgrades (Adrenalina, Aura, Caparazón...)." },
    { "Exo modules", "refit", "translate", "reequipar", "", "Batch 5: change the modules of an Exotraje." },
}

local handlingOf = {
    ["Keep English"] = "keep", ["Translate"] = "translate", ["English name + Spanish noun"] = "mixed",
}

local out = assert(io.open("glossary/glossary.tsv", "wb"))
out:write("category\tenglish\thandling\tspanish\tarticle\tnotes\n")
local n, proposed = 0, 0
for _, r in ipairs(readTsv("work/decisions-terms.tsv")) do
    local term, suggested, suggestedSpanish, decision, spanish, article, notes = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
    local o = overrides[term] or {}
    if not o.drop then
        local handling
        if decision == "OK as suggested" or decision == "" then
            handling = handlingOf[suggested]
            if spanish == "" then spanish = suggestedSpanish end
        else
            handling = handlingOf[decision]
        end
        handling = o.handling or handling
        spanish = o.spanish or spanish
        if handling == "keep" and spanish == "" then spanish = term end
        article = o.article or article
        if article == "" and proposedArticles[term] then
            article = proposedArticles[term] .. " (proposed)"
            proposed = proposed + 1
        end
        notes = o.notes or notes
        out:write(table.concat({ categories[term] or "", term, handling, spanish, article, notes }, "\t"), "\n")
        n = n + 1
    end
end
for _, a in ipairs(additions) do
    out:write(table.concat(a, "\t"), "\n")
    n = n + 1
end
out:close()
print(string.format("wrote glossary/glossary.tsv: %d terms, %d proposed articles", n, proposed))

-- Readable copy, grouped by category, for GitHub and quick lookup.
local md = assert(io.open("glossary/glossary.md", "wb"))
md:write("# Glossary\n\nGenerated from `glossary/glossary.tsv` by `tools/build-glossary.lua`; edit the decisions, not this file.\n\n")
md:write("Handling: **keep** = English name in Spanish text; **translate** = Spanish term; **mixed** = English name with a Spanish noun.\n")
md:write("Articles marked *(proposed)* are suggestions awaiting confirmation.\n")
local byCategory, orderOfCategories = {}, {}
local first = true
for line in io.lines("glossary/glossary.tsv") do
    if first then
        first = false
    else
        local c = {}
        for field in (line .. "\t"):gmatch("([^\t]*)\t") do c[#c + 1] = field end
        if not byCategory[c[1]] then byCategory[c[1]] = {}; orderOfCategories[#orderOfCategories + 1] = c[1] end
        table.insert(byCategory[c[1]], c)
    end
end
for _, cat in ipairs(orderOfCategories) do
    md:write("\n## " .. cat .. "\n\n| English | Handling | Spanish | Article | Notes |\n|---|---|---|---|---|\n")
    for _, c in ipairs(byCategory[cat]) do
        local article = c[5]:gsub(" %(proposed%)", " *(proposed)*")
        md:write(string.format("| %s | %s | %s | %s | %s |\n", c[2], c[3], c[4], article, (c[6]:gsub("|", "/"))))
    end
end
md:close()
print("wrote glossary/glossary.md")
