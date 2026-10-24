
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Marketplace=game:GetService("MarketplaceService")
local folder=script.Parent:WaitForChild("MidnightCityModules")
local Catalog=require(folder.Catalog)
local Profiles=require(folder.Profiles)
local Shops=require(folder.ShopService)
local City=require(folder.City)
local Style=require(folder.StyleService)
local Transit=require(folder.Transit)
local network=RS:WaitForChild("MidnightNetwork")
require(RS.MidnightStyle.FoodFactory).RegisterAll(RS:WaitForChild("MidnightIcons"))
Catalog.Start();Profiles.Start();Shops.Start();City.Start();Transit.Start();Style.Start(Shops);require(folder.ShopSaves).Start(Shops)
require(folder.Courier).Start(Shops);require(folder.Leaderboards).Start(Shops)
-- Separate buckets so menu refreshes never block gameplay commands (e.g. CookSkill timing).
local lastSnapshot,lastCommand={},{}
local function limited(bucket,player,interval)
 local now=os.clock()
 if now-(bucket[player] or 0)<interval then return true end
 bucket[player]=now;return false
end
network.Snapshot.OnServerInvoke=function(player,full)
 if limited(lastSnapshot,player,.12) then return {Ready=false,Retry=true} end
 -- Clients cache the static catalogs; they pass false to skip them on routine refreshes.
 return Shops.Snapshot(player,full~=false)
end
network.Command.OnServerInvoke=function(player,action,id)
 if type(action)~="string" or #action>24 or (type(id)~="string" and type(id)~="number" and id~=nil) then return {Ok=false,Message="Invalid request"} end
 if type(id)=="string" and #id>80 then return {Ok=false,Message="Invalid item"} end
 if limited(lastCommand,player,.18) then return {Ok=false,Message="Please wait a moment"} end
 if action=="Topup" then
  local product=Catalog.Find(id)
  if not product or not product.ProductId then return {Ok=false,Message="Unknown product"} end
  if Profiles.Sandbox or product.ProductId<=0 then return {Ok=false,Message="Robux purchases are not configured yet"} end
  if not Profiles.Get(player) then return {Ok=false,Message="Profile not ready"} end
  local ok=pcall(function() Marketplace:PromptProductPurchase(player,product.ProductId) end)
  return {Ok=ok,Message=ok and "Complete the Roblox purchase prompt" or "Purchase prompt unavailable"}
 end
 local ok,a,b=pcall(Shops.Command,player,action,id)
 if not ok then warn("Midnight command failed",a);return {Ok=false,Message="Please try again"} end
 return {Ok=a,Message=b or (a and "Done" or "Unavailable")}
end
Marketplace.ProcessReceipt=function(info)
 local player=Players:GetPlayerByUserId(info.PlayerId)
 if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local match
 for _,p in ipairs(Catalog.Products) do if p.ProductId>0 and p.ProductId==info.ProductId then match=p;break end end
 if not match then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local granted=Profiles.Receipt(player,tostring(info.PurchaseId),match.Gems)
 if granted then
  local pd=Shops.PlayerData[player];if pd then Shops.SyncPlayer(player) end
  network.Notice:FireClient(player,"+"..match.Gems.." Gems")
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 return Enum.ProductPurchaseDecision.NotProcessedYet
end
Players.PlayerAdded:Connect(function(p) task.spawn(Shops.AddPlayer,p) end)
Players.PlayerRemoving:Connect(function(p) lastSnapshot[p]=nil;lastCommand[p]=nil;Shops.RemovePlayer(p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(Shops.AddPlayer,p) end
print("Midnight City ready: 4 kitchens / 4 crew per kitchen / "..(Profiles.Sandbox and "Studio sandbox" or "persistent profiles"))
-- Remind the developer which Robux items still have no ID (they show as "Coming soon" to players).
do
 local Money=require(RS.MidnightStyle.MonetizationConfig);local missing={}
 for key,id in pairs(Money.Passes) do if id<=0 then table.insert(missing,"Pass "..key) end end
 for key,id in pairs(Money.Products) do if id<=0 then table.insert(missing,"Product "..key) end end
 table.sort(missing)
 if #missing>0 then warn("MonetizationConfig: "..#missing.." item(s) not configured yet: "..table.concat(missing,", ")) end
end
