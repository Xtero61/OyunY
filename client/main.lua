local istemci = require("istemci")
local oyuncu  = require("oyuncu")

local o = oyuncu:yeni{
    uzak = false,
    isim = "<Sen>",
}

local ben = istemci({ adres = "127.0.0.1:6161", oyuncu = o })

function love.load()
   love.graphics.setBackgroundColor(0x24 / 0xFF,
                                    0x27 / 0xFF,
                                    0x2E / 0xFF)
end

function love.update(dt)
   ben:guncelle(dt)
end

function love.draw()
   love.graphics.setColor(0, 0, 1)
   love.graphics.print(tostring(love.timer.getFPS()))
   love.graphics.setColor(1,1,1)
   ben:ciz()
end
