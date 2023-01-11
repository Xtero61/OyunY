local basilan_tuslar = {}
local birakilan_tuslar = {}

function love.keypressed(tus)
    basilan_tuslar[tus] = true
end

function love.keyreleased(tus)
    birakilan_tuslar[tus] = true
end

function love.keyboard.isPressed(tus)
    local deger = basilan_tuslar[tus]
    basilan_tuslar[tus] = false
    return deger
end

function love.keyboard.isReleased(tus)
    local deger = birakilan_tuslar[tus]
    birakilan_tuslar[tus] = false
    return deger
end
