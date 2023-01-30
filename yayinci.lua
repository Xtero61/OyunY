local renkli = require("ansicolors")
local Veri   = require("veri")
require("genel")

local Yayinci = {}
Yayinci.__index = Yayinci
Yayinci.__newindex = YENI_INDEKS_UYARISI

function Yayinci:yeni(o)
    o = o or {}
    o.ag = o.ag or nil
    assert(o.ag ~= nil)

    setmetatable(o, self)
    return o
end

setmetatable(Yayinci, { __call = Yayinci.yeni })

function Yayinci:yayinla(konu, veri)
    assert(konu ~= nil and veri ~= nil)
    local v = Veri():bayt_ekle(self.ag.id):string_ekle(konu):veri_ekle(veri)

    if self.ag.tip == "Sunucu" then
        self.ag.kapi:broadcast(v:getir_paket())
    elseif self.ag.tip == "Istemci" then
        self.ag.sunucu:send(v:getir_paket())
    else
        error(renkli("%{red}Bilinmeyen ag tipi: " .. self.ag.tip .. "%{reset}"), 1)
    end
end

return Yayinci
