local anim8   = require("anim8")
local renkli  = require("ansicolors")
local vektor2 = require("vektor2")

local oyuncu   = {
    tip     = "oyuncu",
    SUNUCU  = "OyuncuTip::Sunucu",
    ISTEMCI = "OyuncuTip::Istemci",
    NORMAL  = "OyuncuTip::Normal"
}

oyuncu.__index = oyuncu

function oyuncu:yeni(o)
    o = o or {}
    setmetatable(o, self)

    o.oyuncu_tip     = o.oyuncu_tip or oyuncu.NORMAL
    o.hareket_vektor = vektor2(0,0)
    o.isim           = o.isim or "oyuncu"
    o.hiz            = 100
    o.yer            = vektor2(0,0)
    o.animasyon      = {
        resim = nil,
        kosma = nil,
        durma = nil,
        yon = 1,
        secili = nil,
    }

    if o.oyuncu_tip ~= oyuncu.SUNUCU then
	    o:animasyon_yukle()
	    o.animasyon.secili = o.animasyon.durma
    end

    return o
end

function oyuncu:__tostring()
    return renkli("%{yellow}<Oyuncu> [\n%{reset}" .. inspect.inspect(self) .. "\n%{yellow}]")
end

setmetatable(oyuncu, { __call = oyuncu.yeni })

function oyuncu:yerelx(bideger)
    return self.yer.x + bideger
end

function oyuncu:yerely(bideger)
    return self.yer.y + bideger
end

function oyuncu:animasyon_yukle()
    self.animasyon.resim = love.graphics.newImage("ast.png")
    self.animasyon.resim:setFilter("nearest","nearest")

    local grid =  anim8.newGrid(32, 32, self.animasyon.resim:getWidth(), self.animasyon.resim:getHeight())
    self.animasyon.kosma = anim8.newAnimation(grid("1-8",2), 0.1)
    self.animasyon.durma = anim8.newAnimation(grid("1-8",1), 0.1)
end

function oyuncu:animasyon_guncelle(dt)
    self.animasyon.secili:update(dt)
end

function oyuncu:animasyon_ciz()
    self.animasyon.secili:draw(self.animasyon.resim, self.yer.x, self.yer.y, 0, self.animasyon.yon * 2 ,2,16,16)
end

local function tustan_sayi(tus)
    if love.keyboard.isDown(tus) then
        return 1
    else
        return 0
    end
end

function oyuncu:guncelle(dt)
    if self.oyuncu_tip == oyuncu.NORMAL then
        self.hareket_vektor.x = tustan_sayi("d") - tustan_sayi("a")
        self.hareket_vektor.y = tustan_sayi("s") - tustan_sayi("w")
    end

    if self.hareket_vektor:length() == 0 then
        self.animasyon.secili = self.animasyon.durma
    else
        if self.oyuncu_tip == oyuncu.NORMAL then
            self.yer = self.yer + self.hareket_vektor:normalized() * dt * self.hiz
        end

        self.animasyon.secili = self.animasyon.kosma

        if self.hareket_vektor.x ~= 0 then
            self.animasyon.yon = self.hareket_vektor.x
        end
    end

    if self.oyuncu_tip ~= oyuncu.SUNUCU then
        self:animasyon_guncelle(dt)
    end
end

function oyuncu:ciz()
    love.graphics.print(self.isim, self:yerelx(-20),self:yerely(-32))
    self:animasyon_ciz()
end

return oyuncu
