local SUNUCU_ADRESI = "127.0.0.1:6161"
-- local SUNUCU_ADRESI = "192.168.1.133:6161"
local enet = require("enet")
local anim8 = require("anim8")
local vektor2 = require("vektor2")
local veri = require("veri")
players = {}

local oyuncu = {
    isim = "oyuncu",
    hiz = 100,
    yer = vektor2(0,0),
    ag = {kapi = nil, sunucu = nil, id = 0},
    animasyon = {
        secili = nil,
        yon = 1,
        kosma = nil,
        durma = nil,
    }
}

oyuncu.__index = oyuncu

function oyuncu:yeni(sahte_oyuncu)
    local o = {
        isim = "oyuncu",
        hiz = 100,
        yer = vektor2(0,0),
        ag = {kapi = nil, sunucu = nil, id = 0},
        animasyon = {
            kosma = nil,
            durma = nil,
            yon = 1,
            secili = nil,
        }
    }
    setmetatable(o, self)
    if not sahte_oyuncu then
        o.ag.kapi = enet.host_create()
        o.ag.sunucu = o.ag.kapi:connect(SUNUCU_ADRESI)
        print(".")
    end
    o:animasyon_yukle()
    o.animasyon.secili = o.animasyon.durma


    return o
end

function oyuncu:yerelx(bideger)
    return self.yer.x + bideger
end

function oyuncu:yerely(bideger)
    return self.yer.y + bideger
end

function oyuncu:animasyon_yukle()
    self.resim = love.graphics.newImage("ast.png")
    self.resim:setFilter("nearest","nearest")

    local grid =  anim8.newGrid(32, 32, self.resim:getWidth(), self.resim:getHeight())
    self.animasyon.kosma = anim8.newAnimation(grid("1-8",2), 0.1)
    self.animasyon.durma = anim8.newAnimation(grid("1-8",1), 0.1)
end

function oyuncu:animasyon_guncelle(dt)
    self.animasyon.secili:update(dt)
end

function oyuncu:animasyon_ciz()
    self.animasyon.secili:draw(self.resim, self.yer.x, self.yer.y ,0 ,self.animasyon.yon * 2 ,2,16,16)
end

local function tustan_sayi(tus)
    if love.keyboard.isDown(tus) then
        return 1
    else
        return 0
    end
end

function oyuncu:olay_isle(olay)
    if olay.type == "connect" then
        print("baglanti başarılı")
    elseif olay.type == "receive" then
        -- print("Mesaj alindi " .. inspect.inspect(event))
        local v = veri:yeni()
                      :ham_veri_ayarla(olay.data)
                      :getir_tablo()

        local msg_turu = v[1]
        if msg_turu == 2 then
	    assert(v[2] ~= 0)
            self.ag.id = v[2]
        elseif msg_turu == 1 then
            local oyuncu_sayisi = v[2]
            local pid, x, y, idx
            idx = 3
            for _ = 1, oyuncu_sayisi do
                pid = v[idx]
                idx = idx + 1
                x = v[idx]
                idx = idx + 1
                y = v[idx]
                idx = idx + 1

                if pid ~= self.ag.id then
                    if players[pid] == nil then
                        players[pid] = oyuncu:yeni(true)
                        players[pid].ag.id = pid
                    end
                    players[pid].yer.x = x
                    players[pid].yer.y = y
                end
            end
        end
    elseif olay.type == "disconnect" then
        print("baglantı koptu")
    end
end

function oyuncu:ag_islemleri()
    local olay = self.ag.kapi:service()
    while olay do
        self:olay_isle(olay)
    	olay = self.ag.kapi:service()
    end
end
function oyuncu:paket_gonder()
    if self.ag.id ~= nil and self.ag.id ~= 0 then
        local pkt = veri:yeni()
                        :bayt_ekle(0)
                        :bayt_ekle(self.ag.id)
                        :f32_ekle(self.yer.x)
                        :f32_ekle(self.yer.y)
                        :getir_paket()
        self.ag.sunucu:send(pkt)
    end
end
function oyuncu:guncelle(dt)
    local input_vektor = vektor2(0,0)
    input_vektor.x = tustan_sayi("d") - tustan_sayi("a")
    input_vektor.y = tustan_sayi("s") - tustan_sayi("w")

    if input_vektor:length() == 0 then
        self.animasyon.secili = self.animasyon.durma
    else
        self.yer = self.yer + input_vektor:normalized() * dt * self.hiz
        self.animasyon.secili = self.animasyon.kosma
        if input_vektor.x ~= 0 then
            self.animasyon.yon = input_vektor.x
        end
    end

    if self.ag.sunucu then
        self:ag_islemleri()
        self:paket_gonder()
    end
    self:animasyon_guncelle(dt)
end

function oyuncu:ciz()
    love.graphics.print(self.isim,self:yerelx(-20),self:yerely(-32))
    self:animasyon_ciz()
end

return oyuncu
