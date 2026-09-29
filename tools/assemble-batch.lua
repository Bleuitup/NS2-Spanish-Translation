-- Assembles a batch for review: joins work/batchN/source.tsv with the proposal files
-- work/batchN/proposals-*.tsv (key, Spanish, flag, note), checks every proposal, and writes
-- work/batchN/review.tsv for tools/build-review.ps1.
-- usage: lua tools/assemble-batch.lua 1

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")

local n = assert(arg[1], "batch number")
local dir = "work/batch" .. n

local function split(line)
    local cols = {}
    for field in (line:gsub("\r$", "") .. "\t"):gmatch("([^\t]*)\t") do cols[#cols + 1] = field end
    return cols
end

-- Source rows, in order.
local source, order = {}, {}
for line in io.lines(dir .. "/source.tsv") do
    local c = split(line)
    source[c[2]] = { section = c[1], key = c[2], en = c[3], es = c[4], status = c[5] }
    order[#order + 1] = c[2]
end

-- Proposals: every proposals-*.tsv in the folder (listed with dir /b, Windows).
local proposals, problems = {}, {}
local listing = io.popen('dir /b "' .. dir:gsub("/", "\\") .. '\\proposals-*.tsv" 2>nul')
for file in listing:lines() do
    for line in io.lines(dir .. "/" .. file) do
        line = line:gsub("^\239\187\191", "")
        if line ~= "" then
            local c = split(line)
            if proposals[c[1]] then problems[#problems + 1] = "duplicate proposal: " .. c[1] end
            if not source[c[1]] then problems[#problems + 1] = "proposal for a key not in the batch: " .. c[1] end
            proposals[c[1]] = { es = c[2] or "", flag = c[3] or "", note = c[4] or "", file = file }
        end
    end
end
listing:close()
for _, k in ipairs(order) do
    if not proposals[k] then problems[#problems + 1] = "no proposal: " .. k end
end

-- Glossary.
local glossary = {}
local first = true
for line in io.lines("glossary/glossary.tsv") do
    if first then first = false else
        local c = split(line)
        glossary[#glossary + 1] = { en = c[2], handling = c[3], es = c[4] }
    end
end

-- Style-guide words that must not appear (whole words, case-insensitive).
local avoid = {
    { "pulsa", "presiona (style guide 2)" }, { "pulsar", "presionar" }, { "pulsado", "presionado" },
    { "clic", "click (style guide 2)" }, { "clica", "haz click" },
    { "ratón", "mouse" }, { "vídeo", "video" }, { "vídeos", "videos" },
    { "desarrollar", "investigar (style guide 4)" }, { "desarrollado", "investigado" },
    { "chafar", "aplastar" }, { "coger", "tomar/agarrar" }, { "ordenador", "computadora" },
    { "vosotros", "ustedes" }, { "habéis", "ustedes han" }, { "vale", "está bien" }, { "guay", "genial" },
    { "icono", "ícono" }, { "añadir", "agregar" },
}

local function lower(s) return s:lower() end
local function esc(s) return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")) end
local function hasWord(text, word)
    return (" " .. lower(text) .. " "):find("%f[%w\128-\255]" .. esc(lower(word)) .. "%f[^%w\128-\255]") ~= nil
end
-- Same, but also accepts an English plural (Hives, Marines, tech points).
local function hasWordOrPlural(text, word)
    return hasWord(text, word) or hasWord(text, word .. "s") or hasWord(text, word .. "es")
end
-- A capitalized name like "Fade" or "Shift" only counts when written that way in English, so the
-- verb "fade", the Shift key or an ALL CAPS label do not demand the name in Spanish.
local function englishUsesName(text, name)
    if name:match("^%u%l") then
        return (" " .. text .. " "):find("%f[%w]" .. esc(name) .. "%f[%W]") ~= nil
    end
    return hasWord(text, name)
end
-- Visible length in characters (UTF-8 aware).
local function ulen(s) local _, c = s:gsub("[^\128-\191]", ""); return c end

local out = assert(io.open(dir .. "/review.tsv", "wb"))
local counts = { New = 0, Kept = 0, Fixed = 0, flagged = 0, auto = 0 }
for _, k in ipairs(order) do
    local s, p = source[k], proposals[k] or { es = "", flag = "", note = "" }
    local change
    if s.status ~= "translated" then change = "New"
    elseif p.es == s.es then change = "Kept"
    else change = "Fixed" end
    counts[change] = counts[change] + 1

    local auto = {}
    for _, msg in ipairs(gs.check(s.en, p.es)) do auto[#auto + 1] = msg end
    for _, a in ipairs(avoid) do
        if hasWord(p.es, a[1]) then auto[#auto + 1] = "style: '" .. a[1] .. "' -> " .. a[2] end
    end
    for _, g in ipairs(glossary) do
        if g.handling == "keep" and g.es ~= "" and englishUsesName(s.en, g.en)
            and not hasWordOrPlural(p.es, g.es) and not hasWordOrPlural(p.es, g.en) then
            auto[#auto + 1] = "glossary: '" .. g.en .. "' should stay as '" .. g.es .. "'"
        elseif g.handling ~= "keep" and lower(g.en) ~= lower(g.es) and hasWord(s.en, g.en) and hasWord(p.es, g.en) then
            auto[#auto + 1] = "glossary: '" .. g.en .. "' should be translated ('" .. g.es .. "')"
        end
    end
    local le, lp = ulen(s.en), ulen(p.es)
    if le <= 30 and lp > le * 1.6 and lp - le > 8 then
        auto[#auto + 1] = string.format("length: %d chars vs %d in English", lp, le)
    end
    if p.es == "" then auto[#auto + 1] = "empty proposal" end
    if #auto > 0 then counts.auto = counts.auto + 1 end
    if p.flag ~= "" then counts.flagged = counts.flagged + 1 end

    out:write(table.concat({ s.section, k, s.en, s.status == "translated" and s.es or "", p.es, change,
        p.flag, p.note, table.concat(auto, "; ") }, "\t"), "\n")
end
out:close()

for _, msg in ipairs(problems) do print("PROBLEM: " .. msg) end
print(string.format("%d keys: %d new, %d kept, %d fixed; %d flagged by the translator, %d with automatic warnings",
    #order, counts.New, counts.Kept, counts.Fixed, counts.flagged, counts.auto))
print("wrote " .. dir .. "/review.tsv")
