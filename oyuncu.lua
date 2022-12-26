local anim8 = require("anim8")

local oyuncu = {
    yer = {x = 0, y = 0},
    ag = {kapi = nil, sunucu = nil, id = 0},
    animasyon = {
        secili = nil,
        kosma = nil,
        durma = nil,
    }
}

oyuncu.__index = oyuncu

function oyuncu:yeni()
    local o = {
        yer = {x = 0, y = 0},
        ag = {kapi = nil, sunucu = nil, id = 0},
        animasyon = {
            kosma = nil,
            durma = nil,
        }
    }
    setmetatable(o, self)

    o:animasyon_yukle()
    o.animasyon.secili = self.animasyon.durma


    return o
end

function oyuncu:animasyon_yukle()
    self.resim = love.graphics.newImage("ast-DY-sheet.png", {mipmaps = false})
    self.resim:setFilter("nearest","nearest")

    local grid =  anim8.newGrid(32, 32, self.resim:getWidth(), self.resim:getHeight())
    self.animasyon.kosma = anim8.newAnimation(grid("1-8",2), 0.1)
    self.animasyon.durma = anim8.newAnimation(grid("1-8",1), 0.1)
end

function oyuncu:animasyon_guncelle(dt)
    self.animasyon.secili:update(dt)
end

function oyuncu:animasyon_ciz()
    self.animasyon.secili:draw(self.resim, self.yer.x, self.yer.y ,0 ,2 ,2)
end

local function tustan_sayi(tus)
    if love.keyboard.isDown(tus) then
        return 1
    else
        return 0
    end
end

function oyuncu:guncelle(dt)
    local vektor = {}
    vektor.x = tustan_sayi("a") - tustan_sayi("d")
    vektor.y = tustan_sayi("s") - tustan_sayi("w")

    if vektor.x == 0 and vektor.y == 0 then
        self.animasyon.secili = self.animasyon.durma
    else
        self.animasyon.secili = self.animasyon.kosma
    end

    self:animasyon_guncelle(dt)
end

function oyuncu:ciz()
    self:animasyon_ciz()
end

return oyuncu