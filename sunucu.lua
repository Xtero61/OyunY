local enet = require("enet")
local inspect = require("inspect")
local veri = require("veri")
local mesaj   = require("mesaj")
local oyuncu  = require("oyuncu")
-- TODO: sunucuya versiyon kontrolü ekle
local Sunucu = {
  ag = {
    kapi = nil,
  },
  mesajlar = {},
  oyuncular = {},
  oyuncu_sayisi = 0,
  hazirlanan_id = 1,
}

function Sunucu:yeni(adres)
    local sunucu = {}
    for k, v in pairs(Sunucu) do
        sunucu[k] = v
    end

    adres = adres or "*:6161"
    sunucu.ag.kapi = enet.host_create("*:6161")
    sunucu:ekrana_yaz("Sunucu basladi! Havagi :)")

    return sunucu
end

function Sunucu:kapat()
  self.ag.kapi:destroy()
end

function Sunucu:getir_bagli_oyuncu_sayisi()
  return self.ag.kapi.peer_count()
end

function Sunucu:ekrana_yaz(yazi)
  print("\27[101;94m[" .. tostring(math.ceil(love.timer.getTime() * 1000)) .. "]\27[0m" .. " " .. yazi)
end

function Sunucu.id_gonder(kanal, id)
  local v = veri:yeni():bayt_ekle(2):bayt_ekle(id):getir_paket()
  kanal:send(v)
  Sunucu:ekrana_yaz("id gonderildi " .. tostring(id))
end

function Sunucu:mesaj_isle(gelen_mesaj)
  local v = veri:yeni():ham_veri_ayarla(gelen_mesaj):getir_tablo()
  local mesaj_turu = v[1]
  if mesaj_turu == mesaj.ISTEMCI_DURUM_BILDIRISI then
    local id = v[2]
    local hx = v[3]
    local hy = v[4]
    local x = v[5]
    local y = v[6]

    self.oyuncular[id].hareket_vektor.x = hx
    self.oyuncular[id].hareket_vektor.y = hy

    self.oyuncular[id].yer.x = x
    self.oyuncular[id].yer.y = y
  end
end

function Sunucu:oyuncu_cikar(olay)
  local adam_kayip = true
  for i, oyuncu in pairs(self.oyuncular) do
    if olay.peer == oyuncu.kanal then
      table.remove(self.oyuncular, i)
	  self.oyuncu_sayisi = self.oyuncu_sayisi - 1
      self:ekrana_yaz("Adam kesildi " .. inspect.inspect(olay))
      adam_kayip = false
    end
  end

  if adam_kayip then
    self:ekrana_yaz("Adam kayip Rıza baba :)")
  end
end

function Sunucu:olay_isle(olay)
  if olay.type == "connect" then
    self:oyuncu_ekle(olay.peer)
  elseif olay.type == "receive" then
    self:mesaj_isle(olay.data)
  elseif olay.type == "disconnect" then
    self:oyuncu_cikar(olay)
  end
end

function Sunucu:milleti_bilgilendir()
    self.ag.kapi:broadcast(mesaj:uret(mesaj.SUNUCU_DURUM_BILDIRISI, self))
end

function Sunucu:guncelle(dt)
  local olay = self.ag.kapi:service()
  while olay do
    self:olay_isle(olay)
    olay = self.ag.kapi:service()
  end
  self:milleti_bilgilendir()
end

function Sunucu:oyuncu_ekle(gelen_kanal)
  local y_oyuncu = oyuncu({
      sunucu = true,
      uzak = true,
      kanal = gelen_kanal,
      id = self.hazirlanan_id,
  })
  self.hazirlanan_id = self.hazirlanan_id + 1
  self.oyuncular[y_oyuncu.id] = y_oyuncu
  self:ekrana_yaz("Oyuncu baglandi.")
  self.id_gonder(y_oyuncu.kanal, y_oyuncu.id)
  self.oyuncu_sayisi = self.oyuncu_sayisi + 1
end

return Sunucu
