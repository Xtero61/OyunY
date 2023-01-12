require("love_eklenti")
require("love.timer")

local Konsol = {}

Konsol.__index = Konsol
Konsol.__newindex = YENI_INDEKS_UYARISI

Konsol.yazi = ""
Konsol.gonder_yazi = ""
Konsol.durum = false
Konsol.ayrac = false


setmetatable(Konsol, { __call = Konsol.yeni })

local baslama_zamani = love.timer.getTime()
local gecikme = 1

function Konsol:guncelle(dt)

    if love.keyboard.isPressed("escape") then
        if Konsol.durum == true then
            Konsol.durum = false
        else
            Konsol.durum = true
        end
    end

    if Konsol.durum then
        if love.keyboard.isPressed("return") then
            Konsol.gonder_yazi = Konsol.yazi
            Konsol.yazi = ""
        end

        if love.keyboard.isDown("backspace") then
            love.timer.sleep(0.1)
            Konsol.yazi = string.sub(Konsol.yazi,1,string.len(Konsol.yazi)-1)
        end

        local suanki_zaman = love.timer.getTime()
        if suanki_zaman - baslama_zamani > gecikme then
            baslama_zamani = suanki_zaman
            if Konsol.ayrac then
                Konsol.ayrac = false
            else
                Konsol.ayrac = true
            end
        end
    end
end

function Konsol:ciz()

    if Konsol.durum then
        if Konsol.ayrac then
            Konsol:ayrac_cizgi()
        end
        love.graphics.print(Konsol.yazi,0,0)
        love.graphics.print(Konsol.gonder_yazi,0,20)
    end
end

function Konsol:ayrac_cizgi()
    local genislik = love.graphics.getFont():getWidth(Konsol.yazi)
    love.graphics.rectangle("fill",genislik,0,8,16)
end

function love.textinput(t)
    if Konsol.durum then
        Konsol.yazi = Konsol.yazi .. t
    end
end

return Konsol