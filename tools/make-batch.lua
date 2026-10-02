-- Extracts a batch to work/batchN/source.tsv (section, key, English, current Spanish, status).
-- Batch contents are defined below by key prefix, plus the UPPER_CASE string literals found in the
-- relevant menu code (work/batchN/code-keys.txt). Keys already finished in an earlier batch are
-- skipped. (Batch 1 was made with tools/make-batch1.lua.)
-- status: missing | english (identical to English) | translated
-- usage: lua tools/make-batch.lua 2

package.path = "tools/?.lua;" .. package.path
local gs = require("gamestrings")
local n = tonumber((assert(arg[1], "batch number")))

local batches = {
    [2] = { -- Server browser and connection (code keys: menu2/NavBar/Screens/ServerBrowser,
            -- menu2/QuickPlay, menu2/popup, ServerBrowser.lua, GUIMenuDisconnectPopup.lua)
        { "Server browser", { "SERVERBROWSER", "SB_", "SERVER_", "PASSWORD", "CONNECT", "QUICK_PLAY" }, true },
        { "Friends and Steam", { "FRIEND", "STEAM_", "STEAMLOBBYJOIN", "AUTOJOIN" } },
        { "Disconnect", { "DISCONNECT" } },
        { "Votes", { "VOTE" } },
        { "Skill and leaderboard", { "SKILLTIER", "LEADERBOARD" } },
    },
    [3] = { -- Tech data: every key TechData.lua uses (display names, tooltips, hints), plus the
            -- _TOOLTIP of each. Areas that get their own batch later are left out.
        { "Tech data", {}, true },
        exclude = { "HELP", "EXO", "TIPVIDEO", "LOADING", "TIP_", "ITEM", "BADGE", "CALLINGCARD", "CUSTOMIZE",
                    "STICKY", "SHOULDER", "SKIN", "BUY_", "THUNDERDOME", "TD_", "GMTD", "TUTORIAL", "TUT_", "TUT",
                    "BOOTCAMP", "CHALLENGE", "COMMANDER_TUT", "HIVE_CHALLENGE" },
        tooltipsOfCodeKeys = true,
    },
    [4] = { -- The rest of the in-game text: everything not done in batches 1 to 3 and not held back
            -- for batches 5 to 8 (same exclusions as batch 3). Grouped by key prefix for the reviewer.
        { "Achievements", { "NEW_ACHIEVEMENT" } },
        { "Events and alerts", { "EVT_", "COMMANDERERROR", "MARINE_ALERT", "ALIEN_ALERT" } },
        { "Requests and voice", { "REQUEST" } },
        { "Buy menu and weapons", { "BUYMENU", "WEAPON_", "ABM_", "BMAC" } },
        { "Bots", { "BOT_" } },
        { "Infested", { "INFESTED" } },
        { "Welcome, missions and feedback", { "WELCOME", "MISSION", "FEEDBACK", "ROOKIE" } },
        { "In-game text", {} },
        catchAll = "In-game text",
        exclude = { "HELP", "EXO", "TIPVIDEO", "LOADING", "TIP_", "ITEM", "BADGE", "CALLINGCARD", "CUSTOMIZE",
                    "STICKY", "SHOULDER", "SKIN", "BUY_", "THUNDERDOME", "TD_", "GMTD", "TUTORIAL", "TUT_", "TUT",
                    "BOOTCAMP", "CHALLENGE", "COMMANDER_TUT", "HIVE_CHALLENGE" },
    },
    [5] = { -- Help screens, exo text, tip videos and loading tips.
        { "Help screens", { "HELP" } },
        { "Exo", { "EXO" } },
        { "Tip videos", { "TIPVIDEO" } },
        { "Loading tips", { "LOADING", "TIP_" } },
    },
    [6] = { -- Cosmetics: items, badges, calling cards, the customize screen and the store.
        { "Customize screen", { "CUSTOMIZE" } },
        { "Store", { "BUY_" } },
        { "Badges", { "BADGE" } },
        { "Calling cards", { "CALLINGCARD" } },
        { "Skins and patches", { "SKIN", "SHOULDER", "STICKY" } },
        { "Items", { "ITEM" } },
    },
}
local def = assert(batches[n], "no definition for batch " .. n)

local en, order = gs.parse("snapshot/enUS.txt")
local es = gs.parse("snapshot/esES.txt")

local done = {}
for i = 1, n - 1 do
    local f = io.open("work/batch" .. i .. "/final.tsv", "rb")
    if f then
        f:close()
        for line in io.lines("work/batch" .. i .. "/final.tsv") do done[line:match("^([^\t]+)")] = true end
    end
end
local refs = {}
local f = io.open("work/batch" .. n .. "/code-keys.txt", "rb")
if f then f:close(); for k in io.lines("work/batch" .. n .. "/code-keys.txt") do refs[(k:gsub("\r", ""))] = true end end

local function excluded(k)
    for _, p in ipairs(def.exclude or {}) do if k:sub(1, #p) == p then return true end end
    return false
end

local function sectionOf(k)
    if excluded(k) then return nil end
    if def.tooltipsOfCodeKeys and k:match("_TOOLTIP$") and refs[k:gsub("_TOOLTIP$", "")] then
        for _, s in ipairs(def) do if s[3] then return s[1] end end
    end
    for _, s in ipairs(def) do
        for _, p in ipairs(s[2]) do if k:sub(1, #p) == p then return s[1] end end
    end
    if refs[k] then
        for _, s in ipairs(def) do if s[3] then return s[1] end end -- code keys go to the flagged section
    end
    return def.catchAll
end

local rows, rank = {}, {}
for i, s in ipairs(def) do rank[s[1]] = i end
for i, k in ipairs(order) do
    local s = not done[k] and sectionOf(k)
    if s then
        local status = es[k] == nil and "missing" or (gs.untranslated(en[k], es[k]) and "english" or "translated")
        rows[#rows + 1] = { s, k, en[k], es[k] or "", status, i }
    end
end
table.sort(rows, function(a, b) if a[1] ~= b[1] then return rank[a[1]] < rank[b[1]] end return a[6] < b[6] end)

local out = assert(io.open("work/batch" .. n .. "/source.tsv", "wb"))
local count = {}
for _, r in ipairs(rows) do
    out:write(table.concat({ r[1], r[2], r[3], r[4], r[5] }, "\t"), "\n")
    count[r[1]] = (count[r[1]] or 0) + 1
    count[r[5]] = (count[r[5]] or 0) + 1
end
out:close()
for k, v in pairs(count) do io.write(k, "=", v, "  ") end
print("\nwrote work/batch" .. n .. "/source.tsv (" .. #rows .. " keys)")
