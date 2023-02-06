local renkli = require("kutuphane.ansicolors")

local bildirim = {}

bildirim.yazdir = print

function bildirim.uyari(mesaj)
    bildirim.yazdir(renkli("%{yellow}" .. mesaj .. "%{reset}"))
end

function bildirim.hata(mesaj)
    bildirim.yazdir(renkli("%{red}" .. mesaj .. "%{reset}"))
end

function bildirim.bilgi(mesaj)
    bildirim.yazdir(renkli("%{green}" .. mesaj .. "%{reset}"))
end

function bildirim.oneri(mesaj)
    bildirim.yazdir(renkli("%{blue}" .. mesaj .. "%{reset}"))
end

function bildirim.mesaj(mesaj, renk)
    renk = renk or "reset"
    renk = "%{" .. renk .. "}"
    bildirim.yazdir(renkli(renk .. mesaj .. "%{reset}"))
end

return bildirim

