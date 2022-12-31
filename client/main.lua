local o = require("oyuncu")
local inspect = require("inspect")
local veri = require("veri")
local debug_prefix = "[ CLI ] "

local oyuncu = o:yeni()

local function printd(...)
  table.insert(messages, debug_prefix .. ...)

  if #messages > 5 then
    table.remove(messages, 1)
  end
end

function love.load()
   love.graphics.setBackgroundColor(0x24 / 0xFF,
                                    0x27 / 0xFF,
                                    0x2E / 0xFF)

end

function love.update(dt)
   oyuncu:guncelle(dt)
end

function love.draw()
   for _, oyuncu in pairs(players) do
      oyuncu:ciz()
   end
   love.graphics.setColor(0, 0, 1)
   love.graphics.print(tostring(love.timer.getFPS()))
   love.graphics.setColor(1,1,1)
   oyuncu:ciz()
end
