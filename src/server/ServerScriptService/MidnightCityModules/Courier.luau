-- City courier jobs for players without a kitchen: pick up a free supply crate at the mall,
-- carry it to the kitchen that needs it most and earn coins. The kitchen's backroom gets the kits.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Profiles=require(script.Parent.Profiles)
local Catalog=require(script.Parent.Catalog)
local Inventory=require(script.Parent.Inventory)
local Quests=require(script.Parent.Quests)
local C={Service=nil,Jobs={},Cooldown={}}
local function reward() return math.max(1,math.floor(Catalog.Get("CourierReward",25))) end
local function quantity() return math.max(1,math.floor(Catalog.Get("CourierQuantity",3))) end
local function notice(player,text) RS.MidnightNetwork.Notice:FireClient(player,text) end
local function checkout() return workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true) end
local function near(player,part,range)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root and part and (root.Position-part.Position).Magnitude<=range and not player:GetAttribute("InTransit")
end
local function visual(player)
 local char=player.Character;if not char then return end
 local old=char:FindFirstChild("CourierCrate");if old then old:Destroy() end
 local job=C.Jobs[player];local root=char:FindFirstChild("HumanoidRootPart")
 if not job or not root then return end
 local f=Inventory.Find(job.Food)
 local box=Instance.new("Part");box.Name="CourierCrate";box.Size=Vector3.new(1.8,1.45,1.35);box.Color=Color3.fromRGB(96,140,170);box.Material=Enum.Material.WoodPlanks
 box.CanCollide=false;box.CanQuery=false;box.Massless=true;box.CFrame=root.CFrame*CFrame.new(0,-.15,-1.7);box.Parent=char
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=box;w.Parent=box
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(320,200);g.Parent=box
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(unpack(f.Color));t.TextScaled=true;t.Font=Enum.Font.GothamBold
 t.TextColor3=Color3.fromRGB(26,37,42);t.Text="COURIER\n"..string.upper(f.Name);t.Parent=g
end
local function setJob(player,job)
 C.Jobs[player]=job
 player:SetAttribute("CourierShop",job and job.ShopId or 0);player:SetAttribute("CourierFood",job and job.Food or "")
 visual(player)
end
-- The kitchen with the emptiest backroom shelf gets the next crate.
local function pickTarget(player)
 local best,bestFood,bestCount
 for _,shop in C.Service.Shops do
  if shop.Owner and shop.Owner~=player then
   local stock=Inventory.Data(shop)
   if stock then for _,f in Inventory.Foods do
    local n=stock.Back[f.Id] or 0
    if not bestCount or n<bestCount or (n==bestCount and math.random()<.5) then best,bestFood,bestCount=shop,f,n end
   end end
  end
 end
 return best,bestFood
end
function C.Take(player)
 local pd=C.Service.PlayerData[player];if not pd then return false,"Profile loading" end
 if pd.ShopId~=0 then return false,"Courier jobs are for city visitors without a kitchen" end
 if C.Jobs[player] then return false,"Deliver the crate you are carrying first" end
 if not near(player,checkout(),16) then return false,"Pick up courier crates at the mall supply counter" end
 if os.clock()<(C.Cooldown[player] or 0) then return false,"Next courier crate is being packed. Try again in a few seconds." end
 local shop,f=pickTarget(player)
 if not shop then return false,"No kitchens need deliveries right now" end
 setJob(player,{ShopId=shop.Id,Owner=shop.Owner,Food=f.Id,Quantity=quantity()})
 return true,"Deliver "..f.Name.." to "..shop.Owner.DisplayName.."'s backroom bin (Kitchen "..shop.Id..") for "..reward().." Coins"
end
function C.Cancel(player,reason)
 if not C.Jobs[player] then return false,"No courier job" end
 setJob(player,nil);C.Cooldown[player]=os.clock()+10
 return true,reason or "Courier job cancelled"
end
function C.Deliver(player,shop,food)
 local job=C.Jobs[player]
 if not job or job.ShopId~=shop.Id or job.Food~=food then return end
 if shop.Owner~=job.Owner then C.Cancel(player,"This kitchen changed owner. Courier job cancelled.");notice(player,"This kitchen changed owner. Courier job cancelled.");return end
 local f=Inventory.Find(food)
 if not near(player,shop.Model:FindFirstChild(f.Bin),11) then return end
 Inventory.Data(shop) -- makes sure the owner's stock table exists before mutating it
 local ok=Profiles.Mutate(shop.Owner,function(d) d.Shop.Stock.Back[food]=(d.Shop.Stock.Back[food] or 0)+job.Quantity;return true end)
 if not ok then notice(player,"Delivery failed. Try again.");return end
 Profiles.Mutate(player,function(d) d.Coins+=reward();return true end)
 setJob(player,nil);C.Cooldown[player]=os.clock()+5
 task.spawn(Quests.Track,player,{Deliveries=1})
 notice(player,"Delivery complete! +"..reward().." Coins")
 for member in pairs(shop.Members) do notice(member,"Courier "..player.DisplayName.." delivered "..job.Quantity.." "..f.Name.." to your backroom") end
 RS.MidnightFeedback:FireClient(player,"Ready")
 C.Service.Sync(shop);C.Service.SyncPlayer(player)
end
function C.Snapshot(player)
 local pd=C.Service.PlayerData[player];local job=C.Jobs[player]
 local shop=job and C.Service.Shops[job.ShopId];local f=job and Inventory.Find(job.Food)
 return {Eligible=pd~=nil and pd.ShopId==0,Active=job~=nil,ShopId=job and job.ShopId or 0,Owner=shop and shop.Owner and shop.Owner.DisplayName or "",
  Food=f and f.Name or "",Quantity=quantity(),Reward=reward(),NearMall=near(player,checkout(),16) or false}
end
function C.Start(service)
 C.Service=service
 service.SnapshotExtras.Courier=C.Snapshot
 service.CommandHandlers.CourierTake=function(player) return C.Take(player) end
 service.CommandHandlers.CourierCancel=function(player) return C.Cancel(player) end
 for _,shop in service.Shops do
  for _,f in Inventory.Foods do
   local bin=shop.Model:WaitForChild(f.Bin)
   bin:WaitForChild("TakeStock").Triggered:Connect(function(player) if C.Jobs[player] then C.Deliver(player,shop,f.Id) end end)
  end
 end
 local function watch(player)
  player:GetAttributeChangedSignal("ShopId"):Connect(function()
   if (player:GetAttribute("ShopId") or 0)~=0 and C.Jobs[player] then C.Cancel(player,"Joined a kitchen. Courier job cancelled.") end
  end)
  player.CharacterAdded:Connect(function() task.wait(.5);visual(player) end)
 end
 Players.PlayerAdded:Connect(watch);for _,p in Players:GetPlayers() do watch(p) end
 Players.PlayerRemoving:Connect(function(p) C.Jobs[p]=nil;C.Cooldown[p]=nil end)
end
return C
