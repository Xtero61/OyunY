if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local Sunucu = require("sunucu")
local s

function love.load()
  s = Sunucu:yeni({ adres = "*:6161" })
end

function love.update(dt)
  s:guncelle(dt)
end

function love.draw()
end
