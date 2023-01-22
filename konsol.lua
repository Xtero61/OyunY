require("love_eklenti")
local utf8 = require("utf8")

local Konsol = {}

Konsol.__index = Konsol
Konsol.__newindex = YENI_INDEKS_UYARISI

Konsol.yaziSon = ""
Konsol.yazi = ""
Konsol.gonder_yazi = ""
Konsol.durum = false
Konsol.ayrac = {}
Konsol.ayrac.gorunme = 1

setmetatable(Konsol, { __call = Konsol.yeni })

local baslama_zamani = love.timer.getTime()
local gecikme = 0.7
love.keyboard.setKeyRepeat(true)

function Konsol:guncelle(dt)
    if love.keyboard.isPressed("escape") then
        if Konsol.durum == true then
            Konsol.durum = false
        else
            Konsol.durum = true
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
        end
    end

    if Konsol.durum then
        if love.keyboard.isPressed("return") then
            Konsol.gonder_yazi = Konsol.yazi .. Konsol.yaziSon
            Konsol.yazi = ""
            Konsol.yaziSon = ""
        end
        if love.keyboard.isPressed("backspace") then
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local bit_uzunlugu = utf8.offset(Konsol.yazi, -1)
            if bit_uzunlugu then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                Konsol.yazi = string.sub(Konsol.yazi, 1, bit_uzunlugu - 1)
            end
        end
        if love.keyboard.isPressed("left") then
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local bit_uzunlugu = utf8.offset(Konsol.yazi, -1)
            print(bit_uzunlugu)
            if bit_uzunlugu then
                Konsol.yaziSon = string.sub(Konsol.yazi, bit_uzunlugu, - 1) .. Konsol.yaziSon
                Konsol.yazi = string.sub(Konsol.yazi, 1, bit_uzunlugu - 1)
            end
        elseif love.keyboard.isPressed("right") then
            Konsol.ayrac:ayrac_zamanlayici_sifirla()
            local bit_uzunlugu = utf8.offset(string.reverse(Konsol.yaziSon),-1)
            print(bit_uzunlugu)
            if bit_uzunlugu then
                Konsol.yazi = Konsol.yazi .. string.sub(string.reverse(Konsol.yaziSon), bit_uzunlugu,-1)
                Konsol.yaziSon = string.reverse(string.sub(string.reverse(Konsol.yaziSon), 1, bit_uzunlugu - 1))
            end
        end
        local suanki_zaman = love.timer.getTime()
        if suanki_zaman - baslama_zamani > gecikme then
            baslama_zamani = suanki_zaman
            if Konsol.ayrac.gorunme == 0 then
                Konsol.ayrac.gorunme = 1
            else
                Konsol.ayrac.gorunme = 0
            end
        end
    end
end

function Konsol:ciz()
    if Konsol.durum then
        Konsol:arkaplan()
        Konsol.ayrac:ayrac_cizgi()
        love.graphics.setColor(1,1,1)
        love.graphics.print(Konsol.yazi,20,love.graphics.getHeight()-23)
        local genislik = love.graphics.getFont():getWidth(Konsol.yazi) + 20
        love.graphics.print(Konsol.yaziSon,genislik,love.graphics.getHeight()-23)
        love.graphics.print(Konsol.gonder_yazi,0,20)
    end
end

function Konsol.ayrac:ayrac_zamanlayici_sifirla()
    baslama_zamani = 0
    Konsol.ayrac.gorunme = 0
end

function Konsol.ayrac:ayrac_cizgi()
    local genislik = love.graphics.getFont():getWidth(Konsol.yazi) + 20
    love.graphics.setColor(1,1,1,Konsol.ayrac.gorunme)
    love.graphics.rectangle("fill",genislik,love.graphics.getHeight()-23,8,16)
end

function Konsol:arkaplan()
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle("fill",0,love.graphics.getHeight()-30,love.graphics.getWidth(),30)
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.rectangle("line",0,love.graphics.getHeight()-30,love.graphics.getWidth(),30)
    love.graphics.setColor(0,0,1,1)
    love.graphics.polygon("fill", 10, 10+love.graphics.getHeight()-30, 15, 15+love.graphics.getHeight()-30, 10, 20+love.graphics.getHeight()-30)
end

function love.textinput(t)
    if Konsol.durum then
        Konsol.ayrac:ayrac_zamanlayici_sifirla()
        Konsol.yazi = Konsol.yazi .. t
    end
end

return Konsol