-- Extracts batch 1 (menus and options) to work/batch1/source.tsv:
--   section, key, English, current Spanish, status
-- The batch is every key with a menu/options prefix, plus every key the options menu code uses
-- (work/batch1/options-code-keys.txt: the UPPER_CASE string literals in ns2/lua/menu2/MenuData.lua,
-- AdvancedMenuData.lua, MenuDataUtils.lua and NavBar/Screens/Options/*, at the snapshot commit).
-- status: missing | english (identical to English) | translated

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")
local en, order = gs.parse("snapshot/enUS.txt")
local es = gs.parse("snapshot/esES.txt")

local refs = {}
for k in io.lines("work/batch1/options-code-keys.txt") do refs[k:gsub("\r", "")] = true end

local sections = {
    { "Key bindings", { "BINDINGS", "COMBINDINGS", "COMMANDER_BINDINGS", "FIELD_PLAYER_BINDINGS", "COMMANDER_GRID" } },
    { "Advanced options", { "ADVANCED_OPTION", "ADVANCED_CATEGORY" } },
    { "Mods", { "MODS_" } },
    { "Play menu", { "PLAY_", "JOIN_", "SERVERBROWSER_" } },
    { "Menus", { "MENU_" } },
    { "Options", { "OPTION_", "OPTIONS_" } },
}
local function sectionOf(k)
    for _, s in ipairs(sections) do
        for _, p in ipairs(s[2]) do
            if k:sub(1, #p) == p then return s[1] end
        end
    end
    if refs[k] then return "Options" end
end

local rows = {}
for i, k in ipairs(order) do
    local s = sectionOf(k)
    if s and (refs[k] or s ~= "Play menu" or k:sub(1, 5) == "PLAY_" or k:sub(1, 5) == "JOIN_") then
        local status = es[k] == nil and "missing" or (gs.untranslated(en[k], es[k]) and "english" or "translated")
        rows[#rows + 1] = { s, k, en[k], es[k] or "", status, i }
    end
end
local rank = {}
for i, s in ipairs({ "Menus", "Play menu", "Options", "Advanced options", "Key bindings", "Mods" }) do rank[s] = i end
table.sort(rows, function(a, b) if a[1] ~= b[1] then return rank[a[1]] < rank[b[1]] end return a[6] < b[6] end)

local out = assert(io.open("work/batch1/source.tsv", "wb"))
local count = {}
for _, r in ipairs(rows) do
    out:write(table.concat({ r[1], r[2], r[3], r[4], r[5] }, "\t"), "\n")
    count[r[1]] = (count[r[1]] or 0) + 1
    count[r[5]] = (count[r[5]] or 0) + 1
end
out:close()
for k, v in pairs(count) do io.write(k, "=", v, "  ") end
print("\nwrote work/batch1/source.tsv (" .. #rows .. " keys)")
