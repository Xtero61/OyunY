-- Debug aktiflestirmek icin
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local Istemci     = require("kutuphane.istemci")
local Sunucu      = require("kutuphane.sunucu")
local Konsol      = require("kutuphane.konsol")
local Oyuncu      = require("kutuphane.oyuncu")
local Zamanlayici = require("kutuphane.zamanlayici")

local OyuncuIsmi = os.getenv("USER")
local hedef_nesne, sunucu_nesne

local function komut_isle(komut_satiri)
    local komut = komut_satiri:match("/([^%d%s]+)")
    if komut == "oyun_kur" then
        local it = komut_satiri:gmatch("%S+")
        it() -- /oyun_kur gitti
        local port = it()
        local oyuncu_siniri = it()
        local ip_adres = "*:" .. port
        Konsol.metin:metine_komut_yazi_ekle("Sunucu baslatiliyor...")
        Konsol.metin:metine_komut_yazi_ekle("Adres: " .. ip_adres)
        Konsol.metin:metine_komut_yazi_ekle("Oyuncu Siniri: " .. oyuncu_siniri)
        sunucu_nesne = Sunucu:yeni({adres = ip_adres})
        Konsol.metin:metine_komut_yazi_ekle("Sunucuya otomatik baglanma devre disi!!!")
        Konsol.metin:metine_komut_yazi_ekle("Baglanmak icin -> /baglan <adres>:<port>")
        return true
    end

    if komut == "k" then
        local ip_adres = "*:" .. "6565"
        sunucu_nesne = Sunucu:yeni({adres = ip_adres})
        return true
    end

    if komut == "b" then
        local o = Oyuncu({isim = OyuncuIsmi, oyuncu_tip = Oyuncu.NORMAL })
        hedef_nesne = Istemci:yeni({adres = "127.0.0.1:6565", oyuncu = o})
        return true
    end

    if komut == "baglan" then
        local it = komut_satiri:gmatch("%S+")
        it()
        local ip_adres = it()
        Konsol.metin:metine_komut_yazi_ekle("Baglaniliyor -> " .. ip_adres)
        local o = Oyuncu({isim = OyuncuIsmi, oyuncu_tip = Oyuncu.NORMAL })
        hedef_nesne = Istemci:yeni({adres = ip_adres, oyuncu = o})
    elseif komut == "cik" then
        love.event.quit(0)
    elseif komut == "yardim" then
        Konsol.metin:metine_komut_yazi_ekle("")
        Konsol.metin:metine_komut_yazi_ekle("")
        Konsol.metin:metine_komut_yazi_ekle(" Komutlar")
        Konsol.metin:metine_komut_yazi_ekle("===========")
        Konsol.metin:metine_komut_yazi_ekle("/oyun_kur <port> <maks_oyuncu_sayisi> ->  Sunucu olusturur.")
        Konsol.metin:metine_komut_yazi_ekle("/baglan <ip_adres:port> -> Sunucuya baglanir.")
        Konsol.metin:metine_komut_yazi_ekle("/isim <isim> -> Isim verilirse isim ayarlar verilmezse degerini gosterir.")
        Konsol.metin:metine_komut_yazi_ekle("/yardim -> Bu metni gosterir.")
        Konsol.metin:metine_komut_yazi_ekle("/cik -> Oyunu kapatir.")
    elseif komut == "isim" then
        local it = komut_satiri:gmatch("%S+")
        it() -- /isim gitti
        local yeni_isim = it()

        if yeni_isim then
            OyuncuIsmi = yeni_isim
            Konsol.metin:metine_komut_yazi_ekle("Isim ayarlandi -> " .. yeni_isim)
        else
            Konsol.metin:metine_komut_yazi_ekle("Isim -> " .. OyuncuIsmi)
        end
    else
        Konsol.metin:metine_komut_yazi_ekle("!!! Hata bilinmeyen komut !!! -> " .. komut)
    end
end

function love.load()
    love.graphics.setBackgroundColor(0x24 / 0xFF,
    0x27 / 0xFF,
    0x2E / 0xFF)

    sinyal_fonksiyon_bagla("Konsol.yazi_girildi", function (yazi)
        if yazi:find("/") == 1 then
            return komut_isle(yazi)
        end
    end)
end

function love.update(dt)
    Zamanlayici.guncelle(dt)
    Konsol:guncelle(dt)

    if hedef_nesne and hedef_nesne.guncelle then
        hedef_nesne:guncelle(dt)
    end

    if sunucu_nesne ~= nil then
        sunucu_nesne:guncelle(dt)
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.print(tostring(love.timer.getFPS()))
    love.graphics.setColor(1, 1, 1)
    
    if hedef_nesne then
        hedef_nesne:ciz()
    end
    Konsol:ciz()
end
