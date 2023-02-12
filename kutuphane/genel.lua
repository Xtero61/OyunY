local bildir = require("kutuphane.bildirim")

function YENI_INDEKS_UYARISI(nesne, indeks, deger)
    local hata_mesaji = "Uyari: "
                                  .. nesne.tip
                                  .. " nesnesine yeni bir değer eklendi: ( "
                                  .. tostring(indeks)
                                  .. " = "
                                  .. tostring(deger)
                                  .. " )"
    bildir.uyari(debug.traceback(hata_mesaji))
    rawset(nesne, indeks, deger)
end

-- Sabitler
MESAJ_GONDEREN_ID_ALANI = 1
MESAJ_KANAL_TUR_ALANI = 2
MESAJ_TIP_OZEL_1 = 3
MESAJ_TIP_OZEL_2 = 4
MESAJ_TIP_OZEL_3 = 5
MESAJ_TIP_OZEL_4 = 6
MESAJ_TIP_OZEL_5 = 7

-- Sinyal sistemi
local Sinyal = {}
Sinyal.__index = Sinyal
Sinyal.__newindex = YENI_INDEKS_UYARISI

local sinyal_listesi = {}

function _G.sinyal_tanimla(sinyal_ismi)
    sinyal_listesi[sinyal_ismi] = {}
    local o = sinyal_listesi[sinyal_ismi]
    o.isleyici_fonksiyonlar = {}
    o.isim = sinyal_ismi
    setmetatable(o, Sinyal)
end

function _G.sinyal_ver(sinyal_ismi, ...)
    local sinyal = sinyal_listesi[sinyal_ismi]
    for _, fonksiyon in pairs(sinyal.isleyici_fonksiyonlar) do
        fonksiyon(...)
    end
end

function _G.sinyal_fonksiyon_bagla(sinyal_ismi, fonksiyon)
    assert(sinyal_listesi[sinyal_ismi], "Var olmayan sinyale fonksiyon baglanamaz!");
    table.insert(sinyal_listesi[sinyal_ismi].isleyici_fonksiyonlar, fonksiyon)
end