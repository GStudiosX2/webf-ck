local BF = require("bf.lua")
local state = BF.new(nil, 200)
local input = get("bfinput")
local text = get("output")

function dump_cells(cells)
  local str = ""
  for i, v in ipairs(cells) do
    str = str .. string.format("0x%02x ", v)
    if i % 20 == 0 then str = str .. "\n" end
  end
  return str
end

input.on_submit(function()
  state:reset()
  text.set_content(state:parse(input.get_content())
    .. "\n" .. dump_cells(state.cells))
end)
