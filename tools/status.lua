-- Coverage and validity report for a translation against English.
-- usage: lua tools/status.lua [snapshot/enUS.txt] [snapshot/esES.txt]

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")

local enPath, trPath = arg[1] or "snapshot/enUS.txt", arg[2] or "snapshot/esES.txt"
local en, order = gs.parse(enPath)
local tr, trOrder, dups = gs.parse(trPath)

local missing, same, translated, stale, broken = 0, 0, 0, 0, {}
for _, k in ipairs(order) do
    if tr[k] == nil then
        missing = missing + 1
    elseif gs.untranslated(en[k], tr[k]) then
        same = same + 1
    else
        translated = translated + 1
    end
    if tr[k] ~= nil then
        local problems = gs.check(en[k], tr[k])
        if #problems > 0 then
            broken[#broken + 1] = k .. ": " .. table.concat(problems, "; ")
        end
    end
end
for _, k in ipairs(trOrder) do
    if en[k] == nil then stale = stale + 1 end
end

print(string.format("English keys:            %d", #order))
print(string.format("Translated:              %d (%.0f%%)", translated, 100 * translated / #order))
print(string.format("Identical to English:    %d", same))
print(string.format("Missing:                 %d", missing))
print(string.format("Not in English (stale):  %d", stale))
print(string.format("Duplicate keys:          %d", #dups))
print(string.format("Token/format problems:   %d", #broken))
for _, line in ipairs(broken) do
    print("  " .. line)
end
