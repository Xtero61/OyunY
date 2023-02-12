local enet    = require("enet")
local bildir  = require("kutuphane.bildirim")
local renkli = require("kutuphane.ansicolors")
local Veri   = require("kutuphane.veri")

require("kutuphane.genel")

local Ag = {}
Ag.__index = Ag
Ag.__newindex = YENI_INDEKS_UYARISI

function Ag:yeni(o)
    o = o or {}
    o.id = -1
    o.tip = o.tip or nil
    assert(o.tip ~= nil)
    o.adres = o.adres or "127.0.0.1"
    o.sunucu = 0
    o.kapi = 0
    o.abonelikler = {}
    setmetatable(o, self)

    if o.adres == "127.0.0.1" then
        bildir.uyari("Adres girilmedi yerel adres kullanılıyor: " .. o.adres )
    end

    if o.tip == "Sunucu" then
        o.kapi = enet.host_create(o.adres)
    elseif o.tip == "Istemci" then
        o.kapi = enet.host_create()
        o.sunucu = o.kapi:connect(o.adres)
    else
        error("Bilinmeyen ağ nesnesi tipi: " .. o.tip, 2)
    end

    if o.tip == "Sunucu" then
        o:abone_ol("0")
         :abone_ol("Sunucu")
         :abone_ol("Lobi")
        o:ayarla_kimlik("0")
    elseif o.tip == "Istemci" then
        local rast_isim = rastgele_isim()
        o:abone_ol(rast_isim)
         :abone_ol("Lobi")
         :abone_ol("Yonetim")
         :abone_ol("Istemci")
        o:ayarla_kimlik(rast_isim)
    end

    return o
end

setmetatable(Ag, { __call = Ag.yeni })

function Ag:yayinla(konu, veri)
    assert(konu ~= nil and veri ~= nil)
    local v = Veri():bayt_ekle(self.id):string_ekle(konu):veri_ekle(veri)

    if self.tip == "Sunucu" then
        self.kapi:broadcast(v:getir_paket())
    elseif self.tip == "Istemci" then
        self.sunucu:send(v:getir_paket())
    else
        error(renkli("%{red}Bilinmeyen ag tipi: " .. self.tip .. "%{reset}"), 1)
    end
end

function Ag:filtrele(paket)
    local mesaj = Veri():ham_veri_ayarla(paket):getir_tablo()
    local konu, _ = string.match(mesaj[MESAJ_KANAL_TUR_ALANI], "(%a+)/(%a+)")
    if self:abonemiyim(konu) then
        return mesaj
    end
    return nil
end

function Ag:abonemiyim(konu)
    if self.abonelikler[konu] then
        return true
    end
    return false
end

function Ag:abone_ol(konu)
    self.abonelikler[konu] = true
    return self
end

function Ag:abonelik_iptal(konu)
    self.abonelikler[konu] = false
    return self
end

function Ag:getir_kimlik()
    return self.abonelikler["kimlik"]
end

function Ag:ayarla_kimlik(kimlik)
    self.abonelikler["kimlik"] = kimlik
    return self
end

return Ag
