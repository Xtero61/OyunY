require("love_eklenti")
local utf8 = require("utf8")

local Konsol = {}

Konsol.__index = Konsol
Konsol.__newindex = YENI_INDEKS_UYARISI

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
            baslama_zamani = 0
            Konsol.ayrac.gorunme = 0
        end
    end

    if Konsol.durum then
        if love.keyboard.isPressed("return") then
            Konsol.gonder_yazi = Konsol.yazi
            Konsol.yazi = ""
        end

        if love.keyboard.isPressed("backspace") then
            baslama_zamani = 0
            Konsol.ayrac.gorunme = 0
            local bit_uzunlugu = utf8.offset(Konsol.yazi, -1)

            if bit_uzunlugu then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                Konsol.yazi = string.sub(Konsol.yazi, 1, bit_uzunlugu - 1)
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
        Konsol:ayrac_cizgi()
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(Konsol.yazi,20,love.graphics.getHeight()-23)
        love.graphics.print(Konsol.gonder_yazi,0,20)
    end
end

function Konsol:ayrac_cizgi()
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
        baslama_zamani = 0
        Konsol.ayrac.gorunme = 0
        Konsol.yazi = Konsol.yazi .. t
    end
end

return Konsol