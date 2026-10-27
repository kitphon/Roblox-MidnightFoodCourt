
local Catalog={}
Catalog.Items={
 {Id="theme_teal",Name="Midnight Teal",Kind="Theme",Price=180,Color={28,100,105},Description="Teal walls and mint counter trim"},
 {Id="theme_sakura",Name="Sakura Diner",Kind="Theme",Price=300,Color={145,73,102},Description="Rose walls and warm pink lighting"},
 {Id="theme_gold",Name="Golden Hour",Kind="Theme",Price=450,Color={121,88,37},Description="Brass accents and warm lighting"},
 {Id="uniform_chef",Name="Chef Whites",Kind="Uniform",Price=160,Color={240,236,223},Description="Chef coat, apron and tall hat"},
 {Id="uniform_night",Name="Night Crew",Kind="Uniform",Price=220,Color={46,64,88},Description="Navy apron and crew cap"},
 {Id="effect_mint",Name="Mint Spark",Kind="Effect",Price=240,Color={91,234,188},Description="A small mint glow trail"},
 {Id="effect_gold",Name="Golden Spark",Kind="Effect",Price=320,Color={255,200,87},Description="Golden sparkles while walking"},
 {Id="emote_wave",Name="Friendly Wave",Kind="Emote",Price=80,Description="Wave to your guests"},
 {Id="emote_dance",Name="Shift Dance",Kind="Emote",Price=180,Description="Celebrate a successful shift"}
}
Catalog.Upgrades={
 {Id="Kitchen",Name="Kitchen",Price=250,Max=3,Description="Cook faster at each level"},
 {Id="Service",Name="Service",Price=200,Max=3,Description="More patient customers"},
 {Id="Decor",Name="Decor",Price=220,Max=3,Description="Higher earnings per order"},
 {Id="Space",Name="Dining Area",Price=300,Max=3,Description="Expand the shop with more seating and a larger covered floor"}
}
Catalog.Workers={
 {Id="Chef",Name="NPC Chef",Price=300,Description="Cooks the correct dish every 9 seconds"},
 {Id="Waiter",Name="NPC Waiter",Price=250,Description="Serves prepared dishes every 6 seconds"},
 {Id="Technician",Name="NPC Technician",Price=350,Description="Clears disturbances after 8 seconds"}
}
Catalog.Products={
 {Id="gems_100",Name="100 Gems",Gems=100,ProductId=0},
 {Id="gems_300",Name="300 Gems",Gems=300,ProductId=0},
 {Id="gems_700",Name="700 Gems",Gems=700,ProductId=0}
}
local MonetizationConfig=require(game.ReplicatedStorage.MidnightStyle.MonetizationConfig)
for _,product in Catalog.Products do product.ProductId=MonetizationConfig.Products[product.Id] or 0 end
Catalog.Premium={
 {Id="premium_neon",Name="Neon District",Kind="Theme",Gems=100,Color={64,38,118},Description="Violet theme with electric blue lamps"},
 {Id="premium_chef",Name="Executive Chef",Kind="Uniform",Gems=80,Color={42,39,35},Description="Black and gold chef uniform"}
}
Catalog.Defaults={StarterCoins=500,StarterBank=500,ShiftSeconds=300,CookSeconds=3,OrderSeconds=40,ServeReward=35,EventInterval=45,EventSeconds=20,WorkerChefSeconds=9,WorkerWaiterSeconds=6,WorkerTechSeconds=8,CityEventSeconds=90,CityNightHour=23}
local snapshot
function Catalog.Get(key,fallback)
 local value=snapshot and snapshot:GetValue("Midnight_"..key)
 if typeof(value)=="number" and value==value then return math.clamp(value,0,1000000) end
 return fallback or Catalog.Defaults[key]
end
function Catalog.Start()
 if game.GameId==0 then return end
 task.spawn(function()
  local ok,s=pcall(function() return game:GetService("ConfigService"):GetConfigAsync() end)
  if ok then snapshot=s;s.UpdateAvailable:Connect(function() pcall(function() s:Refresh() end) end) end
 end)
end
function Catalog.Find(id)
 for _,list in ipairs({Catalog.Items,Catalog.Premium,Catalog.Upgrades,Catalog.Workers,Catalog.Products}) do
  for _,item in ipairs(list) do if item.Id==id then return item end end
 end
end
function Catalog.Cost(item,level)
 local base=Catalog.Get("Price_"..item.Id,item.Price or item.Gems or 0)
 return math.floor(base*(level or 1))
end
return Catalog
