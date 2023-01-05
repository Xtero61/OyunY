local oyuncu  = require("oyuncu")
local enet    = require("enet")
local mesaj   = require("mesaj")
local veri    = require("veri")
local renkli  = require("ansicolors")
local inspect = require("inspect")

local VARSAYILAN =
{
    ADRES = "127.0.0.1:6161",
}

local istemci = { tip = "istemci" }

-- eger bir tabloda bir fonksiyon veya deger bulunamassa
-- o tablonun metatablosunun __index degiskenindeki 
-- fonksiyon cagrilir. eger __index degiskeni fonksiyon yerine
-- tablo ise bu tabloda bu deger aranır. burada bu durum kullanıldı
istemci.__index = istemci

function istemci:yeni(o)
    o = o or {}
    setmetatable(o, self)

    o.adres                        = o.adres or VARSAYILAN.ADRES
    o.oyuncu                       = o.oyuncu or oyuncu:yeni()
    o.id                           = nil
    o.kapi                         = enet.host_create()
    o.sunucu                       = o.kapi:connect(o.adres)
    o.sunucu_varliklar             = {}
    o.istatistik                   = {}
    o.istatistik.gonderilen_paket  = 0
    o.istatistik.alinan_paket      = 0

    return o
end

-- istemci tablosunun istemci:yeni(...) seklinde cagrilmasi
-- yerine istemci(...) seklinde cagrilabilmesini saglar
setmetatable(istemci, { __call = istemci.yeni })

function istemci:__tostring()
    return renkli("%{yellow}<Istemci> [\n%{reset}" .. inspect.inspect(self) .. "\n%{yellow}]")
end

local function oyuncu_guncelle(hedef, tablo, baslangic_indeks, yoksay)
    local id = tablo[baslangic_indeks]
    local hx = tablo[baslangic_indeks + 1]
    local hy = tablo[baslangic_indeks + 2]
    local x  = tablo[baslangic_indeks + 3]
    local y  = tablo[baslangic_indeks + 4]

    if id == yoksay then
        return baslangic_indeks + 5
    end

    if hedef[id] == nil then
        hedef[id] = oyuncu:yeni {
            oyuncu_tip = oyuncu.ISTEMCI
        }
    end

    hedef[id].hareket_vektor.x = hx
    hedef[id].hareket_vektor.y = hy
    hedef[id].yer.x = x
    hedef[id].yer.y = y

    return baslangic_indeks + 5
end

function istemci:mesaj_isle(paket)
    local v = veri:yeni():ham_veri_ayarla(paket):getir_tablo()
    local mesaj_turu = v[1]
    local yoksay = self.id

    if mesaj_turu == mesaj.SUNUCU_ID_BILDIRISI then
        local id = v[2]
        self.id = id
    elseif mesaj_turu == mesaj.SUNUCU_DURUM_BILDIRISI then
        local varlik_sayisi = v[2]
        local idx = 3

        for _ = 1, varlik_sayisi do
            idx = oyuncu_guncelle(self.sunucu_varliklar, v, idx, yoksay)
        end
    end
end

function istemci:durum_bildirimi_yap()
    if self.id ~= nil then
        self.sunucu:send(mesaj:uret(mesaj.ISTEMCI_DURUM_BILDIRISI, self))
        self.istatistik.gonderilen_paket = self.istatistik.gonderilen_paket + 1
    end
end

function istemci:ag_islemleri()
    local olay = self.kapi:service()
    while olay do
        if olay.type == "receive" then
            self.istatistik.alinan_paket = self.istatistik.alinan_paket + 1
            self:mesaj_isle(olay.data)
        elseif olay.type == "connect" then
            print("Baglanti basarili")
        elseif olay.type == "disconnect" then
            print("Baglanti koptu")
        end
        olay = self.kapi:service()
    end
end

function istemci:varliklari_guncelle(dt)
    for _, varlik in pairs(self.sunucu_varliklar) do
        varlik:guncelle(dt)
    end
end

function istemci:varliklari_ciz()
    for _, varlik in pairs(self.sunucu_varliklar) do
        varlik:ciz()
    end
end

function istemci:guncelle(dt)
    self:ag_islemleri()
    self.oyuncu:guncelle(dt)
    self:durum_bildirimi_yap()
    self:varliklari_guncelle(dt)
end

function istemci:ciz()
    self.oyuncu:ciz()
    self:varliklari_ciz()
end

return istemci
