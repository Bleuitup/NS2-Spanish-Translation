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
    ["Charge"] = { handling = "keep", article = "la",
        notes = "Ability name stays 'Charge'; the verb is translated: cargar / embestir." },
    ["Bite"] = { handling = "translate", spanish = "Mordida", article = "la",
        notes = "Ability name 'Mordida'; the verb is morder." },
    ["Spit"] = { handling = "translate", spanish = "Escupitajo", article = "el",
        notes = "Ability name 'Escupitajo'; the verb is escupir." },
    ["skill"] = { handling = "translate", spanish = "nivel de habilidad", article = "el",
        notes = "Player rating and bot difficulty. 'Skill Tier' = rango de habilidad; 'relative skill' = habilidad relativa. Not ELO." },
    ["Stomp"] = { handling = "translate", spanish = "Pisotón", article = "el" },
    ["Swipe"] = { handling = "translate", spanish = "Zarpazo", article = "el" },
    ["Gore"] = { handling = "translate", spanish = "Cornada", article = "la" },
    ["Leap"] = { handling = "translate", spanish = "Salto", article = "el" },
    ["Crush"] = { handling = "translate", spanish = "Aplastamiento", article = "el" },
    -- spelling fixes to the workbook entries
    ["Hallucination"] = { spanish = "alucinación" },
    ["Camouflage"] = { spanish = "camuflaje" },
    ["Nano Shield Field"] = { spanish = "campo de nano-escudo" },
    ["Ejection Seat"] = { spanish = "asiento eyectable" },
    ["chamber"] = { drop = true }, -- never appears alone in the game text
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
