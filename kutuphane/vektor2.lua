-- Godot tarzı Vektor2 kütüphanesi
require("kutuphane.genel")

local Vektor2 = { tip = "Vektor" }
Vektor2.__index = Vektor2
Vektor2.__newindex = YENI_INDEKS_UYARISI

function Vektor2:yeni(o)
  o = o or {}

  o.x = o.x or 0
  o.y = o.y or 0
  setmetatable(o, self)
  return o
end

setmetatable(Vektor2, { __call = function (_, gelen_x, gelen_y)
    return Vektor2:yeni({ x = gelen_x, y = gelen_y })
end})

local function yeterince_esit(x, y, esik)
  esik = esik or 0.00001
  return math.abs(x - y) < esik
end

function Vektor2:__newindex(indeks)
  error("Vektor2 " .. indeks .. " elemanına sahip değil", 2)
end

function Vektor2:__tostring()
  return "{ x: " .. self.x .. ", y: " .. self.y .. " }"
end

function Vektor2:__add(b)
  local t = Vektor2:yeni()
  t.x = self.x + b.x
  t.y = self.y + b.y
  return t
end

function Vektor2:__sub(b)
  local t = Vektor2:yeni()
  t.x = self.x - b.x
  t.y = self.y - b.y
  return t
end

function Vektor2:__mul(b)
  local t = Vektor2:yeni()
  if type(b) == "number" then
    t.x = self.x * b
    t.y = self.y * b
  elseif type(b) == "table" then
    t.x = self.x * b.x
    t.y = self.y * b.y
  else
    error("Vektör yalnızca rasyonel sayılar ile çarpılabilir")
  end
  return t
end

function Vektor2:__div(b)
  if b == 0 then
    error("0'a bölme hatası", 2)
    return nil
  end

  local t = Vektor2:yeni()
  if type(b) == "number" then
    t.x = self.x / b
    t.y = self.y / b
  else
    error("Vektör yalnızca rasyonel sayılar ile çarpılabilir")
  end
  return t
end

function Vektor2:__unm()
   self.x = -self.x
   self.y = -self.y
end

function Vektor2:__eq(v)
  return yeterince_esit(self.x, v.x) and yeterince_esit(self.y, v.y)
end

function Vektor2:__lt(v)
  return (self:length() < v:length())
end

function Vektor2:__le(v)
  return (self:length() <= v:length())
end

function Vektor2:abs()
  return Vektor2:yeni{
    x = math.abs(self.x),
    y = math.abs(self.y)
  }
end

function Vektor2:length()
  return (math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2)))
end

function Vektor2:sifirla()
  self.x = 0
  self.y = 0
  return self
end

function Vektor2:normalized()
  if self:length() == 0 then
    return nil
  end
  return (self / self:length())
end

function Vektor2:direction_to(v2)
  return ((v2 - self):normalized())
end

function Vektor2:distance_to(v2)
  return (v2 - self):length()
end

function Vektor2:aspect()
  if self.y == 0 then
    return nil
  end
  return (self.x / self.y)
end

function Vektor2:move_toward(v2, delta)
  local vec = (v2 - self):normalized() * delta
  if (vec + self):length() <= v2:length() then
    return vec + self
  else
    return v2
  end
end

function Vektor2:project(v2)
  if v2:length() == 0 then
    return nil
  end
  return v2:normalized() * (self:dot(v2) / (v2:length()))
end

function Vektor2:reflect(v)
  local normal = Vektor2(v.y, -v.x)
  return (self - (self * normal:normalized() * normal:normalized() * 2 ))
end

function Vektor2:dot(v2)
  return (self.x * v2.x + self.y * v2.y)
end

function Vektor2:angle_to(v)
  if self:length() == 0 or v:length() == 0 then
    return nil
  end
  return math.acos(self:dot(v) / (self:length() * v:length()))
end

-- Yazılan vektör fonksiyonlarının doğru çalışıp
-- çalışmadığını test eden fonksiyon
function Vektor2_test()
  local test_sayisi = 0
  local basarili = 0
  local basarisiz = 0

  local function test(f, test_ismi, sonuc)
    test_sayisi = test_sayisi + 1
    if not (sonuc == false) then
      sonuc = true
    end
    local t, _ = pcall(f)
    if t == sonuc then
      basarili = basarili + 1
      print("Test: " .. test_ismi .. " başarılı.")
    else
      basarisiz = basarisiz + 1
      print("Hata: " .. test_ismi .. " başarısız.")
    end
  end

  local v = Vektor2:yeni()
  test(function ()
    if tostring(v) == "{ x: 0, y: 0 }" then
      return true
    else
      error("", 2)
    end
  end, "Vektör ekrana yazdırma")
  test(function ()
    local vec = Vektor2(3, 5)
    if vec.x == 3 and vec.y == 5 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2() constructor fonksiyonu")
  test(function ()
    v.x = 10
    v.y = 10
    if v.x == 10 and v.y == 10 then
      return true
    else
      error("", 2)
    end
  end, "Vektör x,y atama")
  test(function ()
    local son = v * 5
    if son.x == v.x * 5 and son.y == v.y * 5 then
      return true
    else
      error("", 2)
    end
  end, "Vektör sayı ile çarpma")
  test(function ()
    local son = v + v
    if son.x == v.x + v.x and son.y == v.y + v.y then
      return true
    else
      error("", 2)
    end
  end, "Vektörleri toplama")
  test(function ()
    local son = v / 4
    if son.x == v.x / 4 and son.y == v.y / 4 then
      return true
    else
      error("", 2)
    end
  end, "Vektörü sayı ile bölme")
  test(function ()
    v.z = 5
  end, "Vektör geçersiz indeks", false)
  test(function ()
    local vec = Vektor2:yeni{ x = -4, y = -2 }
    vec = vec:abs()

    if vec.x == 4 and vec.y == 2 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:abs()")
  test(function ()
    local vec = Vektor2:yeni { x = 3, y = 4 }
    if vec:length() == 5 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:length()")
  test(function ()
    local vec = Vektor2:yeni { x = 3, y = 4 }
    vec = vec:normalized()
    if vec.x == 0.6 and vec.y == 0.8 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:normalized()")
  test(function ()
    local vec = Vektor2:yeni{ x = 3, y = 4 }:direction_to(Vektor2:yeni{ x = 6, y = 8 })
    if vec.x == 0.6 and vec.y == 0.8 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:direction_to()")
  test(function ()
    local dist = Vektor2:yeni{ x = 3, y = 4 }:distance_to(Vektor2:yeni{ x = 6, y = 8 })
    if dist == 5 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:distance_to()")
  test(function ()
    local vec = Vektor2:yeni{ x = 4, y = 2 }
    if vec:aspect() == 2 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:aspect()")
  test(function ()
    local vec = Vektor2:yeni{ x = 3, y = 4 }:move_toward(Vektor2:yeni{ x = 6, y = 8 }, 2)
    if vec.x == 4.2 and vec.y == 5.6 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:move_toward()")
  test(function ()
    local vec = (Vektor2:yeni{ x = 3, y = 2 }):project(Vektor2:yeni{ x = 5, y = 5 })
    if yeterince_esit(vec.x, 2.5) and yeterince_esit(vec.y, 2.5) then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:project()")
  test(function ()
    local vec = Vektor2:yeni{ x = 6, y = 2 }:reflect(Vektor2:yeni{ x = 0, y = 1 })
    if yeterince_esit(vec.x, -6) and yeterince_esit(vec.y, 2) then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:reflect()")
  test(function ()
    local dot = Vektor2:yeni{ x = 7, y = 2 }:dot(Vektor2:yeni{ x = 1, y = 0 })
    if dot == 7 then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:dot()")
  test(function ()
    local angle = Vektor2:yeni{ x = 7, y = 2 }:angle_to(Vektor2:yeni{ x = 1, y = 5 })
    if yeterince_esit(angle, 1.095101) then
      return true
    else
      error("", 2)
    end
  end, "Vektor2:angle_to()")

  print("Yapılan Test Sayısı: " .. test_sayisi .. " -> başarılı: " .. basarili .. ", başarısız: " .. basarisiz)
end

-- Vektor2_test()
return Vektor2
