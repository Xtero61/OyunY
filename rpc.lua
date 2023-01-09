local Veri   = require("veri")
local renkli = require("ansicolors")
require("genel")
local bildir = require("bildirim")

local rpc = {
    SENKRON = 0,
    USTA    = 1,
    KUKLA   = 2,
}
rpc.__index = rpc
rpc.__newindex = YENI_INDEKS_UYARISI

function rpc:yeni(o)
    o = o or {}

    o.fonksiyonlar                = {}
    o.fonksiyonlar[ rpc.SENKRON ] = {} -- tum cihazlarda calisir
    o.fonksiyonlar[ rpc.USTA    ] = {} -- istemciden sunucuya
    o.fonksiyonlar[ rpc.KUKLA   ] = {} -- sunucudan istemciye

    setmetatable(o, self)
    o.hedef   = o.hedef or nil

    assert(o.hedef ~= nil)
    if not (o.hedef.tip == "Sunucu" or o.hedef.tip == "Istemci") then
        error("Geçerli bir hedef verilmedi", 2)
    end

    return o
end

setmetatable(rpc, { __call = rpc.yeni })

local function argumani_ayir(h_veri, arguman)
    if type(arguman) == "number" then
        h_veri:i32_ekle(arguman)
    elseif type(arguman) == "string" then
        h_veri:string_ekle(arguman)
    elseif type(arguman) == "boolean" then
        local sayi
        if arguman then sayi = 1 else sayi = 0 end
        h_veri:bayt_ekle(sayi)
    elseif type(arguman) == "table" then
        local tip = arguman[1]
        local deger = arguman[2]

        if tip == "f32" then
            h_veri:f32_ekle(deger)
        elseif tip == "f64" then
            h_veri:f64_ekle(deger)
        else
            error("ulasilamaz", 2)
        end
    else
        error("ulasilamaz", 2)
    end
end

local function paketi_hazirla(h_veri, argumanlar)
    assert(type(argumanlar) == "table")
    for _, arg in pairs(argumanlar) do
        argumani_ayir(h_veri, arg)
    end
end

function rpc:kesin_cagir(fonksiyon_adi, argumanlar)
    self:kesin_cagir_hedef(self.hedef.ag.kapi, fonksiyon_adi, argumanlar)
end

function rpc:cagir(fonksiyon_adi, argumanlar)
    self:cagir_hedef(self.hedef.ag.kapi, fonksiyon_adi, argumanlar)
end

function rpc:kesin_cagir_hedef(hedef, fonksiyon_adi, fonksiyon_tipi, argumanlar)
    assert(self.hedef.tip == "Sunucu" or self.hedef.tip == "Istemci")
    local v = Veri():i32_ekle(self.hedef.ag.id):i32_ekle(fonksiyon_tipi):string_ekle(fonksiyon_adi)
    paketi_hazirla(v, argumanlar)
    hedef:send(v:getir_paket(), 0, "reliable")
end

function rpc:cagir_hedef(hedef, fonksiyon_adi, argumanlar)
    assert(self.hedef.tip == "Sunucu" or self.hedef.tip == "Istemci")
    local v = Veri():string_ayarla(fonksiyon_adi)
    paketi_hazirla(v, argumanlar)
    hedef:send(v:getir_paket())
end

function rpc:kontrol_et(gelen_kapi, veri)
    local v = Veri():ham_veri_ayarla(veri):getir_tablo()
    local id = table.remove(v, 1)
    local tip = table.remove(v, 1)
    local fonk_adi = table.remove(v, 1)

    if self.fonksiyonlar[tip][fonk_adi] ~= nil then
        self.fonksiyonlar[tip][fonk_adi](gelen_kapi, id, unpack(v)) -- v tablosu argumanlari içeriyor
    else
        bildir.hata("Rpc hatasi!! `" .. fonk_adi .. "` rpcde bulunamadi.")
   end
end

return rpc
