local enet = require("enet")
local inspect = require("inspect")
local debug_prefix = "[ SRVR ]"

local Sunucu = {
  ag = {
    kapi = nil,
  },
  mesajlar = {},
  oyuncular = {},
  hazirlanan_id = 1,
}

function Sunucu:ekrana_yaz(yazi)
  print("\27[101;94m" .. debug_prefix .. "\27[0m" .. " " .. yazi)
end

function Sunucu:ready()
  self.ag.kapi = enet.host_create("*:6161")
  love.window.close()
  Sunucu:ekrana_yaz("Sunucu basladi pencere kapandi! Havagi :)")
end

function Sunucu.id_gonder(kanal, id)
  local data = love.data.pack("data", "bb", 2, id)
  kanal:send(data:getString())
  Sunucu:ekrana_yaz("id gonderildi " .. tostring(id))
end

function Sunucu:mesaj_isle(mesaj)
      local mesaj_turu, yer = love.data.unpack("b", mesaj)
      local id, x, y
      if mesaj_turu == 0 then
        id, x, y = love.data.unpack("bff", mesaj, yer)
      end

      self.oyuncular[id].x = x
      self.oyuncular[id].y = y
end

function Sunucu:olay_isle(olay)
    if olay.type == "connect" then
      Sunucu:oyuncu_ekle(olay.peer)
    elseif olay.type == "receive" then
      Sunucu:mesaj_isle(olay.data)
    elseif olay.type == "disconnect" then
      Sunucu:ekrana_yaz("Adam kesildi " .. inspect.inspect(olay))
    end
end

function Sunucu:milleti_bilgilendir()
    local mesaj = ""
    local veri = love.data.pack("data", "bJ", 1, #self.oyuncular)
    mesaj = mesaj .. veri:getString()
    for _, oyuncu in pairs(self.oyuncular) do
      veri = love.data.pack("data", "bff",
                            oyuncu.id, oyuncu.x,
                            oyuncu.y)
      mesaj = mesaj .. veri:getString()
    end
    self.ag.kapi:broadcast(mesaj)
end

function Sunucu:update(dt)
  local olay = self.ag.kapi:service()
  while olay do
    Sunucu:olay_isle(olay)
    olay = self.ag.kapi:service()
    Sunucu:milleti_bilgilendir()
  end
end

function Sunucu:oyuncu_ekle(gelen_kanal)
  local yeni_oyuncu = {
    x = 0,
    y = 0,
    kanal = gelen_kanal,
    id = self.hazirlanan_id
  }
  self.hazirlanan_id = self.hazirlanan_id + 1
  self.oyuncular[yeni_oyuncu.id] = yeni_oyuncu
  Sunucu:ekrana_yaz("Oyuncu baglandi.")
  self.id_gonder(yeni_oyuncu.kanal, yeni_oyuncu.id)
end

function love.load()
  Sunucu:ready()
end

function love.update(dt)
  Sunucu:update(dt)
end

function love.draw()
end
