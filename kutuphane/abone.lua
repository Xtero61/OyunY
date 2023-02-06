local renkli = require("kutuphane.ansicolors")
local Veri   = require("kutuphane.veri")
require("kutuphane.genel")

local Abone = {}
Abone.__index = Abone
Abone.__newindex = YENI_INDEKS_UYARISI

function Abone:yeni(o)
    o = o or {}
    o.abonelikler = {}

    setmetatable(o, self)
    return o
end

setmetatable(Abone, { __call = Abone.yeni })

function Abone:filtrele(paket)
    local mesaj = Veri():ham_veri_ayarla(paket):getir_tablo()
    local konu, _ = string.match(mesaj[MESAJ_KANAL_TUR_ALANI], "(%a+)/(%a+)")
    if self:abonemiyim(konu) then
        return mesaj
    end
    return nil
end

function Abone:abonemiyim(konu)
    if self.abonelikler[konu] then
        return true
    end
    return false
end

function Abone:abone_ol(konu)
    self.abonelikler[konu] = true
    return self
end

function Abone:abonelik_iptal(konu)
    self.abonelikler[konu] = false
    return self
end

function Abone:getir_kimlik()
    return self.abonelikler["kimlik"]
end

function Abone:ayarla_kimlik(kimlik)
    self.abonelikler["kimlik"] = kimlik
    return self
end

return Abone
