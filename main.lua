local Sunucu = require("sunucu")
local s

function love.load()
  s = Sunucu:yeni("*:6161")
end

function love.update(dt)
  s:guncelle(dt)
end

function love.draw()
end
