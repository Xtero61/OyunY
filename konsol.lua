require("love_eklenti")
local utf8 = require("utf8")

local Konsol = {}

Konsol.__index = Konsol
Konsol.__newindex = YENI_INDEKS_UYARISI

Konsol.yazi_gonderme_fonksiyonu = nil
Konsol.metin = {}
Konsol.metin.durum = false
Konsol.metin.yazi = ""
Konsol.metin.boyu = 14
Konsol.yaziSon = ""
Konsol.yazi = ""
Konsol.gonder_yazi = ""
Konsol.durum = false
Konsol.ayrac = {}
Konsol.ayrac.gorunme = 1

setmetatable(Konsol, { __call = Konsol.yeni })

local baslangic = love.timer.getTime()
local baslama_zamani = love.timer.getTime()
local gecikme = 0.7
local metin_kaybolma = 5
love.keyboard.setKeyRepeat(true)

function Konsol:guncelle(dt)
    if love.keyboard.isPressed("escape") then -- konsol açıp kapama
        if Konsol.durum == true then
            Konsol.durum = false
        else
            Konsol.durum = true
            Konsol.metin:gorunurluk_zamanlayici()
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
        end
    end
    if Konsol.durum then
        if love.keyboard.isPressed("return") then -- yazılan yazıyı gönderme 
            Konsol.gonder_yazi = Konsol.yazi .. Konsol.yaziSon
            Konsol.yazi = ""
            Konsol.yaziSon = ""
            Konsol.metin:metine_yazi_ekle("[Sen]", Konsol.gonder_yazi)
            if Konsol.yazi_gonderme_fonksiyonu ~= nil then
                Konsol.yazi_gonderme_fonksiyonu(Konsol.gonder_yazi)
            end
        end
        if love.keyboard.isDown("lctrl") and love.keyboard.isPressed("t") then -- yazışma kutucuğunu temizleme
            Konsol.metin.yazi = ""
            Konsol.metin.boyu = 14
        end
        if love.keyboard.isPressed("backspace") then -- yazılan yazının sonundaki harfi silme
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local bit_uzunlugu = utf8.offset(Konsol.yazi, -1)
            if bit_uzunlugu then
                Konsol.yazi = string.sub(Konsol.yazi, 1, bit_uzunlugu - 1)
            end
        end
        if love.keyboard.isPressed("left") then -- yazılan yazıda imleci sağa kaydırma 
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local harf_yeri = utf8.offset(Konsol.yazi, -1)
            if harf_yeri then
                Konsol.yaziSon = string.sub(Konsol.yazi, harf_yeri, - 1) .. Konsol.yaziSon
                Konsol.yazi = string.sub(Konsol.yazi, 1, harf_yeri - 1)
            end
        elseif love.keyboard.isPressed("right") then -- yazılan yazıda imleci sola kaydırma 
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local son_yazi_ilk_harf_uzunlugu = utf8.offset(Konsol.yaziSon,2)
            if son_yazi_ilk_harf_uzunlugu then
	        son_yazi_ilk_harf_uzunlugu = son_yazi_ilk_harf_uzunlugu - 1
                Konsol.yazi = Konsol.yazi .. string.sub(Konsol.yaziSon, 1, son_yazi_ilk_harf_uzunlugu)
                Konsol.yaziSon = string.sub(Konsol.yaziSon, son_yazi_ilk_harf_uzunlugu + 1, -1)
            end
        end
        local suanki_zaman = love.timer.getTime()
        if suanki_zaman - baslama_zamani > gecikme then -- imlecin yanıp söndüren zamanlayıcı
            baslama_zamani = suanki_zaman
            if Konsol.ayrac.gorunme == 0 then
                Konsol.ayrac.gorunme = 1
            else
                Konsol.ayrac.gorunme = 0
            end
        end
    else
        if Konsol.metin.durum == true then
            local suan = love.timer.getTime()
            if suan - baslangic > metin_kaybolma then
                Konsol.metin.durum = false
            end
        end
    end
end

function Konsol:ciz()
    if Konsol.durum then
        Konsol:arkaplan()
        Konsol.ayrac:ayrac_cizgi()
        love.graphics.setColor(1,1,1)
        love.graphics.print(Konsol.yazi,20,love.graphics.getHeight()-22.5)
        local genislik = love.graphics.getFont():getWidth(Konsol.yazi) + 20
        love.graphics.print(Konsol.yaziSon,genislik,love.graphics.getHeight()-22.5)
    end
    if Konsol.metin.durum == true then
        local metin = love.graphics.newText(love.graphics.getFont(),Konsol.metin.yazi)
        love.graphics.draw(metin,7,love.graphics.getHeight()-51.5+Konsol.metin.boyu)            
    end
end

function Konsol.metin:gorunurluk_zamanlayici()
    baslangic = love.timer.getTime()
    Konsol.metin.durum = true
end

function Konsol.metin:metine_yazi_ekle(isim,yazi)
    Konsol.metin.yazi = Konsol.metin.yazi .. isim .." : " .. yazi .. "\n"
    Konsol.metin:metinin_boyunu_ayarlama()
end

function Konsol.metin:metine_komut_yazi_ekle(komut)
    Konsol.metin.yazi = Konsol.metin.yazi .. komut .. "\n"
    Konsol.metin:metinin_boyunu_ayarlama()
end

function Konsol.metin:metinin_boyunu_ayarlama()
    if Konsol.metin.boyu <= -126 then -- metinin ilk satırını silme
        Konsol.metin.yazi = string.gmatch(Konsol.metin.yazi, "[^\n]+\n(.+)")()
    else
        Konsol.metin.boyu = Konsol.metin.boyu - 14
    end
    Konsol.metin:gorunurluk_zamanlayici()
end

function Konsol.ayrac:ayrac_zamanlayici_sifirla()
    baslama_zamani = 0
    Konsol.ayrac.gorunme = 0
end

function Konsol.ayrac:ayrac_cizgi()
    local genislik = love.graphics.getFont():getWidth(Konsol.yazi) + 20
    love.graphics.setColor(1,1,1,Konsol.ayrac.gorunme)
    love.graphics.rectangle("fill",genislik,love.graphics.getHeight()-22.5,8,16)
end

function Konsol:arkaplan()
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle("fill",0,love.graphics.getHeight()-30,love.graphics.getWidth(),30)
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",0,love.graphics.getHeight()-180,love.graphics.getWidth(),150)
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.rectangle("line",0,love.graphics.getHeight()-180,love.graphics.getWidth(),150)
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.rectangle("line",0,love.graphics.getHeight()-30,love.graphics.getWidth(),30)
    love.graphics.setColor(0,0,1,1)
    love.graphics.polygon("fill", 10, 10+love.graphics.getHeight()-30, 16, 15+love.graphics.getHeight()-30, 10, 20+love.graphics.getHeight()-30)
end

function love.textinput(t)
    if Konsol.durum then
        Konsol.ayrac:ayrac_zamanlayici_sifirla()
        Konsol.yazi = Konsol.yazi .. t
    end
end

return Konsol
