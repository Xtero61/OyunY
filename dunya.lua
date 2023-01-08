require("genel")

local erisim_tablosu = {}
erisim_tablosu.__index = erisim_tablosu

function erisim_tablosu:yeni(o)
    o = o or {}
    setmetatable(o, self)

    o.tablo   = o.tablo or nil
    o.indeks  = o.indeks or nil
    o.hedef   = o.hedef or nil
    return o
end

setmetatable(erisim_tablosu, { __call = erisim_tablosu.yeni })

local dunya = { tip = "Dunya" }
dunya.__index = dunya
dunya.__newindex = YENI_INDEKS_UYARISI

function dunya:yeni(o)
    o = o or {}

    o.nesneler       = {}
    o.oyuncular      = {}
    o.y_sort         = {}
    o.nesne_sayisi   = 0
    o.oyuncu_sayisi  = 0
    o.varlik_sayisi  = 0

    setmetatable(o, self)

    return o
end

setmetatable(dunya, { __call = dunya.yeni })

function dunya:oyuncu_ekle(id, oy)
    self.oyuncu_sayisi = self.oyuncu_sayisi + 1
    self.varlik_sayisi = self.varlik_sayisi + 1
    table.insert(self.oyuncular, id, oy)
    table.insert(self.y_sort, erisim_tablosu({
        tablo  = self.oyuncular,
        indeks = id,
        hedef  = oy
    }))
end

function dunya:oyuncu_cikar(id)
    self.oyuncu_sayisi = self.oyuncu_sayisi - 1
    self.varlik_sayisi = self.varlik_sayisi - 1
    table.remove(self.oyuncular, id)
    for i, var in pairs(self.y_sort) do 
        if var.tablo == self.oyuncular and var.indeks == id then
            table.remove(self.y_sort, i)
        end
    end
end

function dunya:nesne_ekle(var)
    self.nesne_sayisi = self.nesne_sayisi + 1
    self.varlik_sayisi = self.varlik_sayisi + 1
    table.insert(self.nesneler, var)
    table.insert(self.y_sort, erisim_tablosu({
        tablo  = self.nesneler,
        indeks = #self.nesneler,
        hedef  = var
    }))
end

function dunya:nesne_cikar(id)
    self.nesne_sayisi = self.nesne_sayisi - 1
    self.varlik_sayisi = self.varlik_sayisi - 1
    table.remove(self.nesneler, id)
    for i, var in pairs(self.y_sort) do 
        if var.tablo == self.nesneler and var.indeks == id then
            table.remove(self.y_sort, i)
        end
    end
end

function dunya:guncelle(dt)
    table.sort(self.y_sort, function (a, b)
        return (a.hedef.yer.y < b.hedef.yer.y)
    end)

    for _, oy in pairs(self.oyuncular) do
        oy:guncelle(dt)
    end

    for _, nes in pairs(self.nesneler) do
        nes:guncelle(dt)
    end
end

function dunya:ciz()
    for _, h in pairs(self.y_sort) do
        h.hedef:ciz()
    end
end

function dunya:getir_oyuncu(id)
    return self.oyuncular[id]
end

return dunya
