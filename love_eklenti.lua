local basilan_tuslar = {}
local birakilan_tuslar = {}

function love.keypressed(tus)
    basilan_tuslar[tus] = love.timer.getTime() * 1000
end

function love.keyreleased(tus)
    birakilan_tuslar[tus] = love.timer.getTime() * 1000
end

local function tablo_degerini_kontrol_et(tablo, tus)
    local zaman = love.timer.getTime() * 1000

    if zaman - tablo[tus] < 200 then
        return true
    end

    return false
end

function love.keyboard.isPressed(tus)
    return tablo_degerini_kontrol_et(basilan_tuslar, tus)
end

function love.keyboard.isReleased(tus)
    return tablo_degerini_kontrol_et(birakilan_tuslar, tus)
end

