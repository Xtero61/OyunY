local veri = require("veri")
require("genel")

local Mesaj = {
	ISTEMCI_DURUM_BILDIRISI    = 1,
	SUNUCU_ID_BILDIRISI        = 2,
	SUNUCU_DURUM_BILDIRISI     = 3,
	__newindex = YENI_INDEKS_UYARISI,
}

function Mesaj:uret(mesaj_tipi, hedef_ag_nesnesi)
	local v = veri:yeni()
	if mesaj_tipi == Mesaj.ISTEMCI_DURUM_BILDIRISI then
		local istemci = hedef_ag_nesnesi
		local oyuncu  = istemci.oyuncu

		v:bayt_ekle(Mesaj.ISTEMCI_DURUM_BILDIRISI)
		:bayt_ekle(istemci.id)
		:bayt_ekle(oyuncu.hareket_vektor.x)
		:bayt_ekle(oyuncu.hareket_vektor.y)
		:f32_ekle(oyuncu.yer.x)
		:f32_ekle(oyuncu.yer.y)

	elseif mesaj_tipi == Mesaj.SUNUCU_ID_BILDIRISI then
		local sunucu = hedef_ag_nesnesi

		v:bayt_ekle(Mesaj.SUNUCU_ID_BILDIRISI)
		:bayt_ekle(sunucu.hazirlanan_id)

	elseif mesaj_tipi == Mesaj.SUNUCU_DURUM_BILDIRISI then
		local sunucu = hedef_ag_nesnesi

		v:bayt_ekle(Mesaj.SUNUCU_DURUM_BILDIRISI)
		v:bayt_ekle(sunucu.oyuncu_sayisi)

		for _, oyuncu in pairs(sunucu.oyuncular) do
			v:bayt_ekle(oyuncu.id)
			:bayt_ekle(oyuncu.hareket_vektor.x)
			:bayt_ekle(oyuncu.hareket_vektor.y)
			:f32_ekle(oyuncu.yer.x)
			:f32_ekle(oyuncu.yer.y)
		end

	end
	return v:getir_paket()
end

setmetatable(Mesaj, {__call = Mesaj.yeni })

return Mesaj
