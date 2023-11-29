local vektor2  = require("kutuphane.vektor2")
local carpisma = require("kutuphane.carpisma")

require("kutuphane.love_eklenti")
local Kullanici_Arayuz = {}

Kullanici_Arayuz.__index = Kullanici_Arayuz
Kullanici_Arayuz.__newindex = YENI_INDEKS_UYARISI

function Kullanici_Arayuz:yeni(o)
    o = o or {}
    o.yer = o.yer or vektor2(0,0)
    assert(o.oyuncu, "Arayuz bir oyuncuya ait olmali!!!")
    o.oyuncu = o.oyuncu
    o.elleri_goster = false
    o.el_gosterge_yer = vektor2(o.oyuncu.yer.x, o.oyuncu.yer.y)
    setmetatable(o, self)
    return o
end

function Kullanici_Arayuz:ciz()
    love.graphics.print("Can: ", self.yer.x, self.yer.y)

    if self.elleri_goster then
        love.graphics.rectangle("fill", self.el_gosterge_yer.x - 16, self.el_gosterge_yer.y + 30, 30, 30)
    end
end

function Kullanici_Arayuz:guncelle(dt)
    local fare_yer = vektor2(love.mouse.getX(), love.mouse.getY())
    self.el_gosterge_yer.x, self.el_gosterge_yer.y = self.oyuncu.yer.x, self.oyuncu.yer.y
    if(carpisma.nokta_dortgene_dahil_mi(fare_yer, self.oyuncu.yer, self.oyuncu.boyut)) then
        self.elleri_goster = true
    else
        self.elleri_goster = false
    end
end

return Kullanici_Arayuz