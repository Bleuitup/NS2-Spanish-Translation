-- Turns a reviewed batch into its final lines: work/batchN/final.tsv (key, Spanish, escaped as
-- in the game file). Reads source.tsv, decisions.tsv (tools/export-review.ps1) and the optional
-- corrections.tsv (key, Spanish, reason: obvious typos in reviewer edits, applied last).
--   OK             -> the proposal
--   Use my Spanish -> the reviewer's Spanish
--   Keep current   -> the existing Spanish (or English, when there was none)
--   Discuss / blank-> left out, so the key stays as it is in the game file
-- usage: lua tools/finalize-batch.lua 1

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")
local n = assert(arg[1], "batch number")
local dir = "work/batch" .. n

local function split(line)
    local cols = {}
    for field in (line:gsub("\r$", "") .. "\t"):gmatch("([^\t]*)\t") do cols[#cols + 1] = field end
    return cols
end
local function lines(path)
    local f = io.open(path, "rb")
    if not f then return function() return nil end end
    f:close()
    return io.lines(path)
end

-- Text typed in Excel has plain quotes; the game file needs them escaped.
local function escapeQuotes(s)
    return (s:gsub('\\"', "\1"):gsub('"', '\\"'):gsub("\1", '\\"'))
end

local source, order = {}, {}
for line in lines(dir .. "/source.tsv") do
    local c = split(line)
    source[c[2]] = { en = c[3], es = c[4], status = c[5] }
    order[#order + 1] = c[2]
end

local final, skipped = {}, {}
for line in lines(dir .. "/decisions.tsv") do
    local c = split(line)
    local key, proposed, decision, mine = c[1], c[2], c[3], c[4]
    local s = source[key]
    if s then
        if decision == "OK" then
            final[key] = proposed
        elseif decision == "Use my Spanish" and mine ~= "" then
            final[key] = escapeQuotes(mine)
        elseif decision == "Keep current" then
            final[key] = s.status == "translated" and s.es or s.en
        else
            skipped[#skipped + 1] = key .. " (" .. (decision == "" and "no decision" or decision) .. ")"
        end
    end
end
-- The review sheet shows \" as " and \n as a line break; proposals come back from Excel that way.
for key, v in pairs(final) do final[key] = escapeQuotes(v) end

local corrections = 0
for line in lines(dir .. "/corrections.tsv") do
    local c = split(line:gsub("^\239\187\191", ""))
    if c[1] ~= "" and final[c[1]] then
        final[c[1]] = c[2]
        corrections = corrections + 1
    end
end

local out = assert(io.open(dir .. "/final.tsv", "wb"))
local problems, count = 0, 0
for _, key in ipairs(order) do
    if final[key] then
        for _, msg in ipairs(gs.check(source[key].en, final[key])) do
            print("CHECK " .. key .. ": " .. msg)
            problems = problems + 1
        end
        out:write(key, "\t", final[key], "\n")
        count = count + 1
    end
end
out:close()
for _, k in ipairs(skipped) do print("skipped " .. k) end
print(string.format("wrote %s/final.tsv: %d lines, %d corrections applied, %d skipped, %d check problems",
    dir, count, corrections, #skipped, problems))
