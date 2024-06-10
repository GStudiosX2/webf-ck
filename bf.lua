local BF = {}
BF.__index = BF

function BF.new(loopStackSize: number?, cells: number?, maxCell: number?, minCell: number?)
  loopStackSize = loopStackSize or 32
  cells = cells or 30000
  maxCell = maxCell or 255
  minCell = minCell or 0
  if minCell > 0 then minCell = 0 end

  local cellTable = table.create(cells, 0)
  local pointer = { pointer = 1 }

  function pointer.next()
    if pointer.pointer >= cells then
      pointer.pointer = 1
    else
      pointer.pointer += 1
    end
  end

  function pointer.prev()
    if pointer.pointer <= 1 then
      pointer.pointer = cells
    else
      pointer.pointer -= 1
    end
  end

  function pointer.set(value: number)
    if value < minCell then value = maxCell end
    if value > maxCell then value = minCell end
    cellTable[pointer.pointer] = value
  end

  function pointer.inc() pointer.set(pointer.get() + 1) end

  function pointer.dec() pointer.set(pointer.get() - 1) end

  function pointer.get() return cellTable[pointer.pointer] end

  local loopStack = {}

  function loopStack.push(item: number)
    if #loopStack >= loopStackSize then
      error("loop stack is full")
      return
    end
    table.insert(loopStack, item) 
  end

  function loopStack.pop()
    return table.remove(loopStack)
  end

  local self = setmetatable({
    cells = cellTable,
    loopStack = loopStack,
    pointer = pointer,
  }, BF)
  return self
end

function BF:parse(str: string)
  local output = ""
  local i = 1
  repeat
    local char = string.sub(str, i, i)
    if char == ">" then
      self.pointer.next()
    elseif char == "<" then
      self.pointer.prev()
    elseif char == "+" then
      self.pointer.inc()
    elseif char == "-" then
      self.pointer.dec()
    elseif char == "[" then
      if self.pointer.get() == 0 then
        local array = {}
        local x = 0
        for j=i,#str do
          if string.sub(str, j, j) == "]" then
            table.insert(array, j)
            x += 1
            if x >= #self.loopStack then break end
          end
        end
        i = array[x]
      else
        self.loopStack.push(i - 1)
      end
    elseif char == "]" then
      local j = self.loopStack.pop()
      if self.pointer.get() ~= 0 then
        i = j
      end
    elseif char == "." then
      output = output .. string.char(self.pointer.get())
    end
    i += 1
  until i > #str
  self.pointer.pointer = 1
  if #self.loopStack > 0 then
    self:clearLoopStack()
    error("loop stack is not empty")
  end
  return output
end

function BF:reset()
  self:clearLoopStack()
  for i, _ in ipairs(self.cells) do
    self.cells[i] = 0
  end
  self.pointer.pointer = 1
end

function BF:clearLoopStack()
  while #self.loopStack > 0 do
    self.loopStack.pop()
  end
end

return BF
