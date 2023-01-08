local renkli = require("ansicolors")

local konsol = {}

konsol.yazdir = print

function konsol.uyari(mesaj)
    konsol.yazdir(renkli("%{yellow}" .. mesaj .. "%{reset}"))
end

function konsol.hata(mesaj)
    konsol.yazdir(renkli("%{red}" .. mesaj .. "%{reset}"))
end

function konsol.bilgi(mesaj)
    konsol.yazdir(renkli("%{green}" .. mesaj .. "%{reset}"))
end

function konsol.oneri(mesaj)
    konsol.yazdir(renkli("%{blue}" .. mesaj .. "%{reset}"))
end

function konsol.mesaj(mesaj, renk)
    renk = renk or "reset"
    renk = "%{" .. renk .. "}"
    konsol.yazdir(renkli(renk .. mesaj .. "%{reset}"))
end

return konsol

