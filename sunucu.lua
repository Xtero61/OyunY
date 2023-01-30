local inspect = require("inspect")
local Veri    = require("veri")
local Ag      = require("ag")
local oyuncu  = require("oyuncu")
local renkli  = require("ansicolors")
local Dunya   = require("dunya")
require("genel")
local bildir  = require("bildirim")
-- TODO: sunucuya versiyon kontrolü ekle

local Sunucu = { tip = "Sunucu" }
Sunucu.__index = Sunucu
Sunucu.__newindex = YENI_INDEKS_UYARISI

function Sunucu:yeni(o)
    o = o or {}

    o.adres         = o.adres or "*:6161"
    o.ag            = Ag({adres = o.adres, tip = "Sunucu"})
    o.dunya         = 0
    o.hazirlanan_id = 1

    setmetatable(o, self)
    o.dunya         = Dunya()

    o:ekrana_yaz("Sunucu basladi! Havagi :)")

    return o
end

function Sunucu:__tostring()
    return renkli("%{yellow}<Sunucu>\n[%{reset}\n" .. inspect.inspect(self) .. "\n%{yellow}] %{reset}")
end

setmetatable(Sunucu, { __call = Sunucu.yeni })

function Sunucu:kapat()
  self.ag.kapi:destroy()
end

function Sunucu:getir_bagli_oyuncu_sayisi()
  return self.ag.kapi.peer_count()
end

function Sunucu:ekrana_yaz(yazi)
  print(renkli("%{green}[ " .. tostring(math.ceil(love.timer.getTime() * 1000)) .. " ]%{reset} " .. yazi))
end

function Sunucu:mesaj_isle(mesaj)
    if mesaj == nil then
        return
    end

    local _, mesaj_turu = string.match(mesaj[MESAJ_KANAL_TUR_ALANI], "(%a+)/(.+)")

    if mesaj_turu == "id_al" then
      -- baglanan oyuncuya oyun durumu burada gönderilmeli
      -- şuan sadece oyuncular var o yüzden yalnızca onları göndereceğiz
      -- en son id göndereceğiz ve istemci id konusuna geçiş yapacak
        local hedef_konu = mesaj[MESAJ_TIP_OZEL_1]
        local isim = mesaj[MESAJ_TIP_OZEL_2]
        for id, oy in pairs(self.dunya.oyuncular) do
            self.ag.yayinci:yayinla(hedef_konu .. "/oyuncu_ekle", Veri():i32_ekle(id)
                                                                        :string_ekle(oy.isim))
        end

        self.ag.yayinci:yayinla(hedef_konu .. "/id_al", Veri():i32_ekle(self.hazirlanan_id))
        self:oyuncu_ekle(self.hazirlanan_id, oyuncu({isim = isim, oyuncu_tip = oyuncu.SUNUCU}))
        self.ag.yayinci:yayinla("Istemci/oyuncu_ekle", Veri():i32_ekle(self.hazirlanan_id)
                                                             :string_ekle(isim))
        self.hazirlanan_id = self.hazirlanan_id + 1

    elseif mesaj_turu == "oyuncu_durum_guncelle" then
        local oyuncu_id  = mesaj[MESAJ_TIP_OZEL_1]
        local oyuncu_hx  = mesaj[MESAJ_TIP_OZEL_2]
        local oyuncu_hy  = mesaj[MESAJ_TIP_OZEL_3]
        local oyuncu_yx  = mesaj[MESAJ_TIP_OZEL_4]
        local oyuncu_yy  = mesaj[MESAJ_TIP_OZEL_5]

        local oy = self.dunya:getir_oyuncu(oyuncu_id)
        oy.hareket_vektor.x = oyuncu_hx
        oy.hareket_vektor.y = oyuncu_hy
        oy.yer.x = oyuncu_yx
        oy.yer.y = oyuncu_yy

    elseif mesaj_turu == "sohbet" then
        local gonderen_id = mesaj[MESAJ_GONDEREN_ID_ALANI]
        local oy_isim = self.dunya:getir_oyuncu(tonumber(gonderen_id)).isim
        local yazi = mesaj[MESAJ_TIP_OZEL_1]
        self.ag.yayinci:yayinla("Istemci/sohbet", Veri():string_ekle(oy_isim):string_ekle(yazi):bayt_ekle(gonderen_id))
    end
end

function Sunucu:oyuncu_cikar(olay)
  local adam_kayip = true
  for i, oy in pairs(self.oyuncular) do
    if olay.peer == oy.kanal then
      table.remove(self.oyuncular, i)
	  self.nesne_sayisi = self.nesne_sayisi - 1
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
    elseif olay.type == "receive" then
        self:mesaj_isle(self.ag.abone:filtrele(olay.data))
    elseif olay.type == "disconnect" then
    end
end

function Sunucu:guncelle(dt)
    local olay = self.ag.kapi:service()
    while olay do
        self:olay_isle(olay)
        olay = self.ag.kapi:service()
    end
    self.dunya:guncelle(dt)

    local durum_guncelle_veri = Veri():i32_ekle(self.dunya.oyuncu_sayisi)
    for id, oy in pairs(self.dunya.oyuncular) do
        durum_guncelle_veri:i32_ekle(id)
                           :bayt_ekle(oy.hareket_vektor.x)
                           :bayt_ekle(oy.hareket_vektor.y)
                           :f32_ekle(oy.yer.x)
                           :f32_ekle(oy.yer.y)
    end
    self.ag.yayinci:yayinla("Istemci/durum_guncelle", durum_guncelle_veri)
end

function Sunucu:oyuncu_ekle(id, oy)
    self.dunya:oyuncu_ekle(id, oy)
    self:ekrana_yaz("Oyuncu baglandi.")
end

return Sunucu
