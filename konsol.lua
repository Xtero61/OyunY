require("love_eklenti")
require("love.timer")

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

        if love.keyboard.isDown("backspace") then
            baslama_zamani = 0
            Konsol.ayrac.gorunme = 0
            Konsol.yazi = string.sub(Konsol.yazi,1,string.len(Konsol.yazi)-1)
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
        Konsol:ayrac_cizgi()
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(Konsol.yazi,0,0)
        love.graphics.print(Konsol.gonder_yazi,0,20)
    end
end

function Konsol:ayrac_cizgi()
    local genislik = love.graphics.getFont():getWidth(Konsol.yazi)
    love.graphics.setColor(1,1,1,Konsol.ayrac.gorunme)
    love.graphics.rectangle("fill",genislik,0,8,16)
end

function love.textinput(t)
    if Konsol.durum then
        baslama_zamani = 0
        Konsol.ayrac.gorunme = 0
        Konsol.yazi = Konsol.yazi .. t
    end
end

return Konsol