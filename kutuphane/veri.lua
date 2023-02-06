--- Veri modülü
-- @module Veri
require("kutuphane.genel")

--- 
-- Veri metatablosu 
-- @type Veri
-- @field veriler
-- @field veri_format
-- @field boyut
-- @field ham_veri
-- @field ham_veri_guncellenmeli
-- @field veriler_guncellenmeli
local veri = { tip = "Veri" }
veri.__index = veri
veri.__newindex = YENI_INDEKS_UYARISI

--- yeni veri nesnesi oluşturur.
-- @return Veri tipinde bir nesne
function veri:yeni(o)
   o = o or {}

   o.veriler = {}
   o.veri_format = ""
   o.boyut = 0
   o.ham_veri = 0
   o.ham_veri_guncellenmeli = false
   o.veriler_guncellenmeli = false

   setmetatable(o, self)

   return o
end

setmetatable(veri, { __call = veri.yeni })

--- Veri nesnesine eklenen değişkenleri ikilik(binary) degerlere cevirir.
-- Paketlenen veri ağdan gönderime veya dosyaya kaydetmeye uygun bir hale gelmiş olur.
-- Veri:getir_paket() ile ikilik(binary) değerler string olarak alınabilir.
-- @return void
function veri:paketle()
   if self.ham_veri ~= 0 then
      self.ham_veri:release()
      self.ham_veri = 0
   end

   local veri_metadata_format = "bc" .. tostring(string.len(self.veri_format))
   local veri_olusturma_format = veri_metadata_format .. self.veri_format
   self.ham_veri = love.data.pack("data", veri_olusturma_format, #self.veri_format, self.veri_format, unpack(self.veriler))

   return self.ham_veri
end

--- İki tane Veri nesnesini birleştirir.
-- Başka bir veri nesnesindeki verileri hedef veriye ekler.
-- @param eklenecek_veri Eklenecek veri değişkeni
-- @return Verinin eklendiği Veri nesnesi döndürülür.
function veri:veri_ekle(eklenecek_veri)
    if self.veriler_guncellenmeli then
        self:getir_tablo()
    end

    if eklenecek_veri.veriler_guncellenmeli then
        eklenecek_veri:getir_tablo()
    end

    for _, deger in pairs(eklenecek_veri.veriler) do
        table.insert(self.veriler, deger)
    end

    self.veri_format = self.veri_format .. eklenecek_veri.veri_format
    self.boyut = self.boyut + eklenecek_veri.boyut
    self.ham_veri_guncellenmeli = true

    return self
end

local function veri_coz(self)
   self.veriler = {}
   local veri_format_str_boyut, yer, veri_format_str
   veri_format_str_boyut, yer = love.data.unpack("b", self.ham_veri)
   local f_str = "c" .. tostring(veri_format_str_boyut)
   veri_format_str, yer = love.data.unpack(f_str, self.ham_veri, tonumber(yer))
   self.veriler = { love.data.unpack(tostring(veri_format_str), self.ham_veri, tonumber(yer)) }
   self.boyut = #self.veriler
end

local function veriye_ekle(gelen_veri, format, deger)
   gelen_veri.veri_format = gelen_veri.veri_format .. format
   gelen_veri.boyut = gelen_veri.boyut + 1
   gelen_veri.ham_veri_guncellenmeli = true
   table.insert(gelen_veri.veriler, deger)
end

--- Veriye bayt eklenir.
-- Veriye bayt eklenir.
-- @param deger Eklenecek bayt degeri
-- @return Eklenen Veri nesnesi döndürülür.
function veri:bayt_ekle(deger)
   veriye_ekle(self, "b", deger)
   return self
end

--- Veriye ubayt eklenir.
-- Veriye unsigned bayt(negatif değer almayan bayt) eklenir.
-- @param deger Eklenecek unsigned bayt degeri
-- @return Eklenen Veri nesnesi döndürülür.
function veri:ubayt_ekle(deger)
   veriye_ekle(self, "B", deger)
   return self
end

--- Veriye 8 bit integer eklenir.
-- Veriye 8 bitlik tamsayı değeri eklenir.
-- [-128 - 127] arası değerleri alabilir.
-- @param deger Eklenecek tamsayı değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:i8_ekle(deger)
   veriye_ekle(self, "i8", deger)
   return self
end

--- Veriye 8 bit unsigned integer eklenir.
-- Veriye 8 bitlik pozitif tamsayı değeri eklenir.
-- [0 - 255] arası değerleri alabilir
-- @param deger Eklenecek tamsayı değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:u8_ekle(deger)
   veriye_ekle(self, "I8", deger)
   return self
end

function veri:i16_ekle(deger)
   veriye_ekle(self, "i16", deger)
   return self
end

function veri:u16_ekle(deger)
   veriye_ekle(self, "I16", deger)
   return self
end

--- Veriye 32 bit signed integer eklenir.
-- Veriye 32 bitlik tamsayı değeri eklenir.
-- [ -2147483648 - 2147483647] arası değerleri alabilir
-- @param deger Eklenecek 32 bitlik tamsayı değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:i32_ekle(deger)
   veriye_ekle(self, "j", deger)
   return self
end

--- Veriye 32 bit unsigned integer eklenir.
-- Veriye 32 bitlik pozitif tamsayı değeri eklenir.
-- [ 0 - 4294967295 ] arası değerleri alabilir
-- @param deger Eklenecek 32 bitlik pozitif tamsayı değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:u32_ekle(deger)
   veriye_ekle(self, "J", deger)
   return self
end

--- Veriye 32 bit float eklenir.
-- Veriye 32 bitlik noktalı sayı değeri eklenir.
-- [ 1.4×10^-45 - 3.4×10^38 ] arası değerleri alabilir
-- @param deger Eklenecek float32 değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:f32_ekle(deger)
   veriye_ekle(self, "f", deger)
   return self
end

--- Veriye 64 bit float eklenir.
-- Veriye 64 bitlik noktalı sayı değeri eklenir.
-- [ 4.9×10^-324 - 1.8×10^308 ] arası değerleri alabilir
-- @param deger Eklenecek float64 değeri.
-- @return Eklenen Veri nesnesi döndürülür.
function veri:f64_ekle(deger)
   veriye_ekle(self, "d", deger)
   return self
end

--- Veriye string eklenir.
-- Verilen string veriye eklenir. Maksimum string uzunluğu maksimum
-- lua string uzunluğuna eşittir.
-- @param deger Eklenecek string değeri
-- @return Eklenen Veri nesnesi döndürülür.
function veri:string_ekle(deger)
   veriye_ekle(self, "c" .. tostring(#deger), deger)
   return self
end

--- Veri nesnesini ikilik(binary) veri değerini harici olarak ayarlar.
-- Ağdan gelen veya dosyadan okunan ikilik(binary) veri değeri nesneye
-- eklenir.
-- @param ham_veri Ayarlanacak ikilik(binary).
-- @return Hedef Veri nesnesi döndürülür.
function veri:ham_veri_ayarla(ham_veri)
   self.ham_veri = ham_veri
   self.veriler_guncellenmeli = true
   return self
end

--- Veri nesnesini ikilik(binary) veri değerini hesaplayıp getirir.
-- Ağdan gönderilebilecek veya dosyaya yazılabilecek ikilik(binary) veri değeri
-- üretilir ve döndürülür.
-- @param str_format İkilik veri türü string mi olacak? (Varsayılan true).
-- @return İkilik(binary) veri değeri döndürülür.
function veri:getir_paket(str_format)
    if str_format ~= false then
        str_format = true
    else
        str_format = false
    end

   if self.ham_veri_guncellenmeli then
      self:paketle()
      self.ham_veri_guncellenmeli = false
   end

   if str_format then
      return self.ham_veri:getString()
   end

   return self.ham_veri
end

--- Veri nesnesinin değerlerini lua tablosu olarak hesaplayıp getirir.
-- ham_veri_ayarla fonksiyonu ile ağdan gelen veya dosyadan okunan ikilik(binary)
-- veri değeri eklenmiş Veri nesnesini tablosu hesaplanıp döndürülür.
-- @return Lua tablosu döndürülür.
function veri:getir_tablo()
   if self.veriler_guncellenmeli then
      veri_coz(self)
      self.veriler_guncellenmeli = false
   end
   return self.veriler
end

function veri:getir_boyut()
   return self.boyut
end

return veri
