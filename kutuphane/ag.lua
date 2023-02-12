local enet    = require("enet")
local Abone   = require("kutuphane.abone")
local Yayinci = require("kutuphane.yayinci")
local bildir  = require("kutuphane.bildirim")
require("kutuphane.genel")

math.randomseed(os.clock()*100000000000)

local function rastgele_isim(eklenti)
    eklenti = eklenti or ""

    local harf_uret = function ()
        return string.char(math.random(0, 25) + 97) -- ascii 'a'
    end

    local isim = ""
    for _=1, 12 do
        isim = isim .. harf_uret()
    end

    return isim .. eklenti
end

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
    o.yayinci = 0
    o.abone = 0
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

    o.yayinci = Yayinci({
        ag = o,
    })


    if o.tip == "Sunucu" then
        o.abone = Abone({ ag = o }):abone_ol("0")
                        :abone_ol("Sunucu")
                        :abone_ol("Lobi")
        o.abone:ayarla_kimlik("0")
    elseif o.tip == "Istemci" then
        local rast_isim = rastgele_isim()
        o.abone = Abone({ ag = o }):abone_ol(rast_isim)
                        :abone_ol("Lobi")
                        :abone_ol("Yonetim")
                        :abone_ol("Istemci")
        o.abone:ayarla_kimlik(rast_isim)
    end

    return o
end

setmetatable(Ag, { __call = Ag.yeni })

return Ag
