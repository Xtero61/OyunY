local bildirim = require("kutuphane.bildirim")
local inspect  = require("kutuphane.inspect")

local M = {}
M.__index = M
M.__newindex = YENI_INDEKS_UYARISI

M.zamanlayicilar = {}
M.zamanlayici_sayac = 0

local function saati_al()
    return love.timer.getTime() * 1000
end

local Zamanlayici = {}
Zamanlayici.__index = Zamanlayici
Zamanlayici.__newindex = YENI_INDEKS_UYARISI

function M.yeni(o)
    o = o or {}
    if o.isim == nil then
        o.isim = "Zamanlayici" .. tostring(M.zamanlayici_sayac)
        M.zamanlayici_sayac = M.zamanlayici_sayac + 1
    end
    o.sure = o.sure or 1000
    o.tekrar = o.tekrar or false
    o.tamamlandi = false
    o.calisiyor = false
    o.baslangic = 0
    o.tetik_fonksiyonu = o.tetik_fonksiyonu or function (fark)
        bildirim.bilgi(o.isim .. " tamamlandi " .. tostring(fark))
    end
    setmetatable(o, Zamanlayici)

    M.zamanlayicilar[o.isim] = o
    return o
end

function Zamanlayici:tamamlandi_mi()
    return self.tamamlandi
end

function Zamanlayici:baslat()
    self.calisiyor = true
end

function Zamanlayici:durdur()
    self.calisiyor = false
end

function Zamanlayici:sifirla()
    self.baslangic = saati_al()
    self.tamamlandi = false
end

function Zamanlayici:yeniden_kur()
    self.baslangic = saati_al()
    self.tamamlandi = false
    self:baslat()
end

function M.guncelle(dt)
    local simdiki_zaman = saati_al()

    for _, self in pairs(M.zamanlayicilar) do
        if self.calisiyor then
            if simdiki_zaman - self.baslangic >= self.sure then
                self.tamamlandi = true
                self.tetik_fonksiyonu(simdiki_zaman - self.baslangic)

                if self.tekrar then
                    self.tamamlandi = false
                    self.baslangic = simdiki_zaman
                else
                    self.calisiyor = false
                end
            end
        end
    end
end

return M