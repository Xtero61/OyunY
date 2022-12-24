local enet = require("enet")
local inspect = require("inspect")
local veri = require("veri")
local debug_prefix = "[ SERVER ]"

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
  local v = veri:yeni()
  v:bayt_ekle(2)
  v:bayt_ekle(id)
  v:paketle()
  kanal:send(v.ham_veri:getString())
  Sunucu:ekrana_yaz("id gonderildi " .. tostring(id))
end

function Sunucu:mesaj_isle(mesaj)
  local v = veri:yeni()
  v.ham_veri = mesaj
  v:coz()
  local mesaj_turu = v.veriler[1]
  if mesaj_turu == 0 then
    local id = v.veriler[2]
    local x = v.veriler[3]
    local y = v.veriler[4]
    self.oyuncular[id].x = x
    self.oyuncular[id].y = y
  end

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
    local v = veri:yeni()
    v:bayt_ekle(1):u32_ekle(#self.oyuncular)
    for _, oyuncu in pairs(self.oyuncular) do
      v:bayt_ekle(oyuncu.id)
      :f32_ekle(oyuncu.x)
      :f32_ekle(oyuncu.y)
    end
    v:paketle()
    local g_pkt = v.ham_veri:getString()
    self.ag.kapi:broadcast(g_pkt)
end

function Sunucu:update(dt)
  local olay = self.ag.kapi:service()
  while olay do
    Sunucu:olay_isle(olay)
    olay = self.ag.kapi:service()
  end
    Sunucu:milleti_bilgilendir()
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
