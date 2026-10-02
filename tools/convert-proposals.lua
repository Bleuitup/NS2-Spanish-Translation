-- Converts proposal drafts written with " @@ " between fields (key @@ Spanish @@ flag @@ note)
-- into the tab-separated proposals files tools/assemble-batch.lua reads. Drafting with a visible
-- delimiter keeps leading and trailing spaces in the Spanish intact. <SAME_AS_ENGLISH> copies the
-- English text (for lines that are only spaces).
-- usage: lua tools/convert-proposals.lua work/batch5 1-help-exo 2-tipvideos
local dir, names = arg[1], {}
for i = 2, #arg do names[#names + 1] = arg[i] end
local en = {}
for line in io.lines(dir .. "/source.tsv") do
  local c = {}
  for f in (line:gsub("\r$", "") .. "\t"):gmatch("([^\t]*)\t") do c[#c + 1] = f end
  en[c[2]] = c[3]
end
for _, name in ipairs(names) do
  local out = assert(io.open(dir .. "/proposals-" .. name .. ".tsv", "wb"))
  local n = 0
  for line in io.lines(dir .. "/proposals-" .. name .. ".src") do
    line = line:gsub("\r$", "")
    if line ~= "" then
      local parts, pos = {}, 1
      while true do
        local s, e = line:find(" @@ ", pos, true)
        if not s then parts[#parts + 1] = (line:sub(pos):gsub(" @@$", "")); break end
        parts[#parts + 1] = line:sub(pos, s - 1)
        pos = e + 1
      end
      assert(#parts >= 2, "bad line: " .. line)
      if parts[2] == "<SAME_AS_ENGLISH>" then parts[2] = en[parts[1]] end
      out:write(parts[1], "\t", parts[2], "\t", parts[3] or "", "\t", parts[4] or "", "\n")
      n = n + 1
    end
  end
  out:close()
  print(name, n)
end
