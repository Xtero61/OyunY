local konsol = require("konsol")
local veri = require("veri")


local tab = {
    x = 0,
    y = 0,
    z = { a = 1, b = 0 },
    ["baba"] = "baba",
}
function love.load()
    love.filesystem.setIdentity("game")
    dosya = love.filesystem.newFile("save.bin")
    local v = veri()

    for an,deg in pairs(tab) do
        if type(deg) == "number" then
            v:f32_ekle(deg)
        elseif type(deg) == "string" then
            v:string_ekle(deg)
        end
    end
    dosya:write(v:getir_paket())
    dosya:close()
end

function love.update(dt)
    konsol:guncelle(dt)
end

function love.draw()
    konsol:ciz()
end
