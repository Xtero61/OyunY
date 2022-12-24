local inspect = require("inspect")

local veri = {
   ham_veri = nil,
   veriler = {},
   boyut = 0,
   veri_format = "",
}

function veri:yeni(o)
   o = o or {
      veriler = {},
      veri_format = "",
      boyut = 0,
      ham_veri = nil,
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

local function tum_verileri_tabloya_ekle(...)
   return {...}
end

function veri:coz()
   self.veriler = {}
   local veri_format_str_boyut, yer, veri_format_str
   veri_format_str_boyut, yer = love.data.unpack("b", self.ham_veri)
   local f_str = "c" .. tostring(veri_format_str_boyut)
   veri_format_str, yer = love.data.unpack(f_str, self.ham_veri, yer)
   self.veriler = tum_verileri_tabloya_ekle(love.data.unpack(veri_format_str, self.ham_veri, yer))
end

function veri:bayt_ekle(deger)
   self.veri_format = self.veri_format .. "b"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:ubayt_ekle(deger)
   self.veri_format = self.veri_format .. "B"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:i8_ekle(deger)
   self.veri_format = self.veri_format .. "i8"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:u8_ekle(deger)
   self.veri_format = self.veri_format .. "I8"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:i16_ekle(deger)
   self.veri_format = self.veri_format .. "i16"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:u16_ekle(deger)
   self.veri_format = self.veri_format .. "I16"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:i32_ekle(deger)
   self.veri_format = self.veri_format .. "j"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:u32_ekle(deger)
   self.veri_format = self.veri_format .. "J"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:f32_ekle(deger)
   self.veri_format = self.veri_format .. "f"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

function veri:f64_ekle(deger)
   self.veri_format = self.veri_format .. "d"
   self.boyut = self.boyut + 1
   table.insert(self.veriler, deger)
   return self
end

return veri
