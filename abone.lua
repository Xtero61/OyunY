local renkli = require("ansicolors")
local Veri   = require("veri")
require("genel")

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
    local konu, _ = string.match(mesaj[1], "(%a+)/(%a+)")
    if self:abonemiyim(konu) then
        return mesaj
    end
    return nil
end

function Abone:abonemiyim(konu)
    for _, v in pairs(self.abonelikler) do
        if v == konu then
            return true
        end
    end
    return false
end

function Abone:abone_ol(konu)
    table.insert(self.abonelikler, konu)
    return self
end

function Abone:abonelik_iptal(konu)
    for i, v in pairs(self.abonelikler) do
        if v == konu then
            table.remove(self.abonelikler, i)
        end
    end
    return self
end

function Abone:getir_kimlik()
    return self.abonelikler[1]
end

function Abone:ayarla_kimlik(kimlik)
    self.abonelikler[1] = kimlik
    return self
end

return Abone
