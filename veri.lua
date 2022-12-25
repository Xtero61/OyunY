local veri = {
   ham_veri = nil,
   veriler = {},
   boyut = 0,
   veri_format = "",
   ham_veri_guncellenmeli = false,
   veriler_guncellenmeli = false,
}

function veri:yeni(o)
   o = o or {
      veriler = {},
      veri_format = "",
      boyut = 0,
      ham_veri = nil,
      ham_veri_guncellenmeli = false,
      veriler_guncellenmeli = false,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

function veri:paketle()
   if self.ham_veri then
      self.ham_veri:release()
   end

   local veri_metadata_format = "bc" .. tostring(string.len(self.veri_format))
   local veri_olusturma_format = veri_metadata_format .. self.veri_format
   self.ham_veri = love.data.pack("data", veri_olusturma_format, #self.veri_format, self.veri_format, unpack(self.veriler))

   return self.ham_veri
end

function veri:coz()
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

function veri:bayt_ekle(deger)
   veriye_ekle(self, "b", deger)
   return self
end

function veri:ubayt_ekle(deger)
   veriye_ekle(self, "B", deger)
   return self
end

function veri:i8_ekle(deger)
   veriye_ekle(self, "i8", deger)
   return self
end

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

function veri:i32_ekle(deger)
   veriye_ekle(self, "j", deger)
   return self
end

function veri:u32_ekle(deger)
   veriye_ekle(self, "J", deger)
   return self
end

function veri:f32_ekle(deger)
   veriye_ekle(self, "f", deger)
   return self
end

function veri:f64_ekle(deger)
   veriye_ekle(self, "d", deger)
   return self
end

function veri:string_ekle(deger)
   veriye_ekle(self, "c" .. tostring(#deger), deger)
   return self
end

function veri:ham_veri_ayarla(ham_veri)
   self.ham_veri = ham_veri
   self.veriler_guncellenmeli = true
   return self
end

function veri:getir_paket(str_format)
   str_format = str_format or true
   if self.ham_veri_guncellenmeli then
      self:paketle()
      self.ham_veri_guncellenmeli = false
   end

   if str_format then
      return self.ham_veri:getString()
   end

   return self.ham_veri
end

function veri:getir_tablo()
   if self.veriler_guncellenmeli then
      self:coz()
      self.veriler_guncellenmeli = false
   end
   return self.veriler
end

function veri:getir_boyut()
   return self.boyut
end

return veri
