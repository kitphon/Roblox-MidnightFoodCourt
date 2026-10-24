if not plugin then return end
local config=require(script.Parent.Config)
local start=require(script.Parent.Bridge)
local control
local function refresh()
 if game.PlaceId==config.placeId and game.GameId==config.gameId then
  if not control or control.Stopped then control=start(plugin,config) end
 elseif control then control.Stop();control=nil end
end
game:GetPropertyChangedSignal("PlaceId"):Connect(refresh)
game:GetPropertyChangedSignal("GameId"):Connect(refresh)
refresh()
