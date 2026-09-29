-- Writes out/esES.txt: the snapshot's esES.txt with every finished batch applied
-- (work/batch*/final.tsv, in batch order). Keeps the original's format: UTF-8 BOM, CRLF, line order.
-- Changed keys are replaced in place; keys the Spanish file did not have are inserted after the
-- nearest preceding key in English order, so the file stays diffable against upstream.
-- usage: lua tools/build-output.lua

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")

local _, enOrder = gs.parse("snapshot/enUS.txt")
local final = {}
local batches = {}
local listing = io.popen('dir /b /ad "work\\batch*" 2>nul')
for d in listing:lines() do batches[#batches + 1] = d end
listing:close()
table.sort(batches, function(a, b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)
local applied = 0
for _, d in ipairs(batches) do
    local f = io.open("work/" .. d .. "/final.tsv", "rb")
    if f then
        f:close()
        for line in io.lines("work/" .. d .. "/final.tsv") do
            local k, v = line:gsub("\r$", ""):match("^([^\t]+)\t(.*)$")
            if k then final[k] = v; applied = applied + 1 end
        end
    end
end

-- Original lines, keeping everything that is not a key line (comments, blanks) untouched.
local raw = gs.read("snapshot/esES.txt")
local lines, lineOfKey = {}, {}
for line in (raw:gsub("\r\n", "\n") .. "\n"):gmatch("([^\n]*)\n") do
    lines[#lines + 1] = line
    local k = line:match('^%s*([%w_%.%-]+)%s*=%s*"')
    if k then lineOfKey[k] = #lines end
end
if lines[#lines] == "" then lines[#lines] = nil end

local replaced, inserted = 0, 0
for k, v in pairs(final) do
    local i = lineOfKey[k]
    if i then
        lines[i] = k .. ' = "' .. v .. '"'
        replaced = replaced + 1
    end
end
-- Missing keys: after the nearest preceding English key that exists in the file.
local after = {}
local previous
for _, k in ipairs(enOrder) do
    if lineOfKey[k] then
        previous = k
    elseif final[k] then
        local anchor = previous or ""
        after[anchor] = after[anchor] or {}
        table.insert(after[anchor], k)
        inserted = inserted + 1
    end
end
local outLines = {}
for _, k in ipairs(after[""] or {}) do outLines[#outLines + 1] = k .. ' = "' .. final[k] .. '"' end
for _, line in ipairs(lines) do
    outLines[#outLines + 1] = line
    local k = line:match('^%s*([%w_%.%-]+)%s*=%s*"')
    if k and after[k] then
        for _, m in ipairs(after[k]) do outLines[#outLines + 1] = m .. ' = "' .. final[m] .. '"' end
    end
end

os.execute('if not exist out mkdir out')
local f = assert(io.open("out/esES.txt", "wb"))
f:write("\239\187\191", table.concat(outLines, "\r\n"), "\r\n")
f:close()
print(string.format("wrote out/esES.txt: %d batch lines, %d replaced, %d inserted", applied, replaced, inserted))
