-- Shared helpers for NS2 gamestrings files (ns2/gamestrings/<lang>.txt).
--
-- Format: one entry per line, KEY = "text". Files are UTF-8 with a BOM; esES.txt uses CRLF.
-- Escapes inside the text: \n (line break), \" (quote). A key can appear twice; the game keeps
-- the last one, and so does parse().

local M = {}

function M.read(path)
    local f = assert(io.open(path, "rb"))
    local s = f:read("a")
    f:close()
    return (s:gsub("^\239\187\191", ""))
end

-- Returns map key -> text, the keys in file order (first occurrence), and duplicate keys.
function M.parse(path)
    local map, order, dups = {}, {}, {}
    for line in M.read(path):gmatch("[^\r\n]+") do
        local k, v = line:match('^%s*([%w_%.%-]+)%s*=%s*"(.*)"%s*$')
        if k then
            if map[k] == nil then
                order[#order + 1] = k
            else
                dups[#dups + 1] = k
            end
            map[k] = v
        end
    end
    return map, order, dups
end

-- Tokens a translation must keep exactly: printf placeholders, line breaks, key bindings, <tags>.
-- Quote marks are not counted: Spanish may quote differently, as long as each one is escaped.
local kTokenPatterns = {
    "%%{[%w_]+}[a-zA-Z]",    -- %{amount}d (named)
    "%%[%-0-9%.]*[a-zA-Z%%]", -- %s %d %.0f %%
    "\\[nt]",                 -- \n \t
    "BIND_[%w_]+",            -- replaced with the player's key binding
    "<[%w_]+>",               -- <number>
}

function M.tokens(text)
    local list = {}
    for _, pattern in ipairs(kTokenPatterns) do
        for token in text:gmatch(pattern) do
            list[#list + 1] = token
        end
    end
    table.sort(list)
    return list
end

-- Problems with a translation of `english`, as a list of short messages (empty when fine).
function M.check(english, translated)
    local problems = {}
    local a, b = M.tokens(english), M.tokens(translated)
    if table.concat(a, " ") ~= table.concat(b, " ") then
        problems[#problems + 1] = string.format("tokens differ: [%s] vs [%s]", table.concat(a, " "), table.concat(b, " "))
    end
    -- An unescaped quote ends the string early in game.
    if translated:gsub('\\"', ""):find('"', 1, true) then
        problems[#problems + 1] = "unescaped quote"
    end
    if translated:match("^%s") ~= english:match("^%s") or translated:match("%s$") ~= english:match("%s$") then
        problems[#problems + 1] = "leading/trailing space differs"
    end
    return problems
end

-- An entry counts as untranslated when missing, or identical to English and containing a word.
function M.untranslated(english, translated)
    return translated == nil or (translated == english and english:match("%a%a%a") ~= nil)
end

return M
