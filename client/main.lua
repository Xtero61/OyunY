local SUNUCU_ADRESI = "127.0.0.1:6161"
local enet = require("enet")
local inspect = require("inspect")
local debug_prefix = "[ CLI ] "
local players = {}
local ben = {
   x = 0,
   y = 0,
   hiz = 100,
   net = {
      server = nil,
      id = nil,
      kapi = nil,
   }
}

local messages = {}

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
  ben.net.kapi = enet.host_create()
  ben.net.server = ben.net.kapi:connect(SUNUCU_ADRESI)
end

function love.update(dt)
  if ben.net.server then
      local event = ben.net.kapi:service()
      while event do
         if event.type == "connect" then
            printd("Adam baglandi " .. "" .. inspect.inspect(event))
         elseif event.type == "receive" then
            printd("Mesaj alindi " .. inspect.inspect(event))
            local msg_turu = love.data.unpack("b", event.data)
            if msg_turu == 2 then
               _, ben.net.id = love.data.unpack("bb", event.data)
            elseif msg_turu == 1 then
               local pid, x, y
               local _, oyuncu_sayisi, pos = love.data.unpack("bJ", event.data)
               for i = 0, oyuncu_sayisi - 1 do
                  pid, x, y, pos = love.data.unpack("bff", event.data, pos)

                  if pid ~= ben.net.id then
                     if players[pid] == nil then
                        players[pid] = {}
                     end
                     players[pid].x = x
                     players[pid].y = y
                  end
               end
            end
         elseif event.type == "disconnect" then
            printd("Adam kesildi " .. inspect.inspect(event))
         end
         event = ben.net.kapi:service()
      end

      if love.keyboard.isDown("w") then
         ben.y = ben.y - ben.hiz * dt
      end

      if love.keyboard.isDown("s") then
         ben.y = ben.y + ben.hiz * dt
      end

      if love.keyboard.isDown("d") then
         ben.x = ben.x + ben.hiz * dt
      end

      if love.keyboard.isDown("a") then
         ben.x = ben.x - ben.hiz * dt
      end

      if ben.net.id then
         local msg = love.data.pack("data", "bbff", 0, ben.net.id,
                         ben.x, ben.y)
         ben.net.server:send(msg:getString())
      end
  end

end

function love.draw()
   love.graphics.setColor(0,1,0)
   love.graphics.rectangle("fill", ben.x, ben.y, 20, 20)
   love.graphics.setColor(1,1,1)
   for _, oyuncu in pairs(players) do
      love.graphics.rectangle("fill", oyuncu.x, oyuncu.y, 20, 20)
   end
end
