local bildir = require("kutuphane.bildirim")

function YENI_INDEKS_UYARISI(nesne, indeks, deger)
    local hata_mesaji = "Uyari: "
                                  .. nesne.tip
                                  .. " nesnesine yeni bir değer eklendi: ( "
                                  .. tostring(indeks)
                                  .. " = "
                                  .. tostring(deger)
                                  .. " )"
    bildir.uyari(debug.traceback(hata_mesaji))
    rawset(nesne, indeks, deger)
end

MESAJ_GONDEREN_ID_ALANI = 1
MESAJ_KANAL_TUR_ALANI = 2
MESAJ_TIP_OZEL_1 = 3
MESAJ_TIP_OZEL_2 = 4
MESAJ_TIP_OZEL_3 = 5
MESAJ_TIP_OZEL_4 = 6
MESAJ_TIP_OZEL_5 = 7


