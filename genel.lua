local bildir = require("bildirim")

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

return

