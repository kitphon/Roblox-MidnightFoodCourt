local Bundles=require(script.Parent.MealBundles)

local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.Catalog)
local Profiles=require(script.Parent.Profiles)
local CustomerFlow=require(script.Parent.CustomerFlow)
local Inventory=require(script.Parent.Inventory)
local Transit=require(script.Parent.Transit)
local WorkerVisuals=require(script.Parent.WorkerVisuals)
local Style=require(script.Parent.StyleService)
local PreparedMeals=require(script.Parent.PreparedMeals)
local Saves=require(script.Parent.ShopSaves)
local Service={Shops={},PlayerData={},CommandHandlers={}}
local Quests=require(script.Parent.Quests)
local Experience=require(script.Parent.Experience)
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local foods=Recipes.Theme("")
local allFoods={};for _,recipe in Recipes.All do table.insert(allFoods,recipe.Id) end
local feedback=RS:WaitForChild("MidnightFeedback")
local notify=RS.MidnightNetwork:WaitForChild("Notice")
local function own(shop) return shop.Owner and Profiles.Get(shop.Owner) end
local function shopFoods(shop) return Experience.Foods(shop) end
local function shopData(shop) local d=own(shop);return d and d.Shop end
local function count(shop) local n=0;for _ in pairs(shop.Members) do n+=1 end;return n end
local function tell(player,text) notify:FireClient(player,text) end
local function cue(shop,name)
 for p in pairs(shop.Members) do feedback:FireClient(p,name) end
end
local function personal(p) return Service.PlayerData[p] end
-- Return a carried meal's ingredients to the kitchen before the player leaves it (call while shop.Owner is still set).
local function dropHeld(player,shop)
 local pd=personal(player);if not pd then return end
 if shop and pd.Held~="" then Inventory.Refund(shop,pd.Held) end
 pd.Held="";pd.HeldQuality=nil;pd.HeldScore=nil
end
function Service.Sync(shop)
 if not shop then return end
 PreparedMeals.Update(shop)
 Experience.Prepare(shop)
 Style.Apply(shop)
 Experience.Visuals(shop)
 shop.Model:SetAttribute("Open",shop.Phase=="Playing")
 local data=shopData(shop)
 for p in pairs(shop.Members) do
  local state=p:FindFirstChild("MidnightState");local pd=personal(p);local profile=Profiles.Get(p)
  if state and pd then
   local attrs={Phase=shop.Phase,Time=shop.Time,Cash=shop.Cash,Served=shop.Served,Strikes=shop.Strikes,
    BundleItems=shop.Bundle and table.concat(shop.Bundle.Items,"|") or "",BundleDelivered=shop.Bundle and table.concat((function() local done={};for _,id in shop.Bundle.Items do if shop.Bundle.Done[id] then table.insert(done,id) end end;return done end)(),"|") or "",BundleDone=shop.Bundle and shop.Bundle.Count or 0,OrderExtra=Bundles.Pending(shop)[2] or "",
    Order=shop.Order,Held=pd.Held,Cooking=pd.Cooking,CookEnd=pd.CookEnd,Combo=shop.Combo,
    Reward=shop.Reward,Patience=shop.Patience,Event=shop.Event,EventLeft=shop.EventLeft,
    Coins=profile and profile.Coins or 0,Gems=profile and profile.Gems or 0,Bank=data and data.Bank or 0,
    Members=count(shop),Owner=shop.Owner and shop.Owner.DisplayName or "Vacant",ShopId=shop.Id,
    Message="",OrderUnavailable=Service.OrderUnavailable and Service.OrderUnavailable(shop) or false,Prepared=shop.Prepared,CustomerStage=shop.CustomerStage or "Idle",CustomerName=shop.CustomerName or ""}
   for k,v in pairs(attrs) do state:SetAttribute(k,v) end
   Inventory.Sync(shop,state,p)
   Experience.Sync(shop,state,p,pd)
  end
 end
end

function Service.SyncLobby(player)
 Style.ClearTeam(player)
 local state=player:FindFirstChild("MidnightState");local d=Profiles.Get(player)
 if not state or not d then return end
 for k,v in pairs({Phase="Lobby",Time=0,Cash=0,Served=0,Strikes=0,Order="",Held="",Cooking="",CookEnd=0,Combo=0,
 BundleItems="",BundleDone=0,OrderExtra="",Reward=0,Patience=1,Event="",EventLeft=1,Coins=d.Coins,Gems=d.Gems,Bank=0,Members=0,Owner="",ShopId=0,Message="",Prepared="",CustomerStage="Idle",CustomerName="",OrderUnavailable=false,SupplyFood="",SupplyQuantity=0,SupplyMode="",CloseReason="",ShopOpen=false,FrontNoodles=0,BackNoodles=0,FrontRice=0,BackRice=0,FrontTea=0,BackTea=0}) do state:SetAttribute(k,v) end
end
function Service.SyncPlayer(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if shop then Service.Sync(shop) else Service.SyncLobby(player) end
end
local function updateOwnerBillboard(shop)
 local sign=shop.Model:FindFirstChild("MIDNIGHT • KITCHEN")
 if sign then local g=sign:FindFirstChildOfClass("SurfaceGui");if g then local t=g:FindFirstChildOfClass("TextLabel");if t then t.Text=shop.Owner and (shop.Owner.DisplayName.."'S KITCHEN") or ("KITCHEN "..shop.Id.." / VACANT") end end end
end
local function characterLook(player)
 local d=Profiles.Get(player);local char=player.Character
 if not d or not char then return end
 for _,a in ipairs(char:GetDescendants()) do if a.Name=="MidnightUniform" or a.Name=="MidnightEffect" then a:Destroy() end end
 local eq=d.Equipped
 if eq.Uniform~="" then
  local item=Catalog.Find(eq.Uniform);local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
  if item and torso then
   local apron=Instance.new("Part");apron.Name="MidnightUniform";apron.Size=Vector3.new(torso.Size.X*.88,torso.Size.Y*.95,.12)
   apron.Color=Color3.fromRGB(unpack(item.Color));apron.CanCollide=false;apron.Massless=true;apron.CFrame=torso.CFrame*CFrame.new(0,-.05,-torso.Size.Z/2-.08);apron.Parent=char
   local weld=Instance.new("WeldConstraint");weld.Part0=torso;weld.Part1=apron;weld.Parent=apron
   local head=char:FindFirstChild("Head")
   if head then
    local hat=Instance.new("Part");hat.Name="MidnightUniform";hat.Size=Vector3.new(1.4,.55,1.4);hat.Color=apron.Color;hat.CanCollide=false;hat.Massless=true;hat.CFrame=head.CFrame*CFrame.new(0,.85,0);hat.Parent=char
    local hw=Instance.new("WeldConstraint");hw.Part0=head;hw.Part1=hat;hw.Parent=hat
   end
  end
 end
 if eq.Effect~="" then
  local item=Catalog.Find(eq.Effect);local root=char:FindFirstChild("HumanoidRootPart")
  if item and root then
   local a=Instance.new("Attachment");a.Name="MidnightEffect";a.Parent=root
   local e=Instance.new("ParticleEmitter");e.Texture="rbxasset://textures/particles/sparkles_main.dds";e.Rate=5;e.Lifetime=NumberRange.new(.5,1);e.Speed=NumberRange.new(.4,1);e.Size=NumberSequence.new(.17);e.Color=ColorSequence.new(Color3.fromRGB(unpack(item.Color)));e.Parent=a
  end
 end
end
local function theme(shop)
 if not shop then return end
 local data=own(shop);local item=data and Catalog.Find(data.Equipped.Theme)
 for _,p in ipairs(shop.Model:GetChildren()) do
  if p:IsA("BasePart") and (p.Name=="BackWall" or p.Name=="BackWallRight" or p.Name=="LeftWall" or p.Name=="RightWall") then
   p.Color=item and Color3.fromRGB(unpack(item.Color)) or Color3.fromRGB(28,48,51)
  end
  if p:IsA("BasePart") and p.Name=="CeilingLamp" then
   local l=p:FindFirstChildOfClass("PointLight")
   if l then l.Color=item and Color3.fromRGB(unpack(item.Color)):Lerp(Color3.new(1,1,1),.75) or Color3.fromRGB(255,213,164) end
  end
 end
end
local function lights(shop,on)
 for _,v in ipairs(shop.Model:GetDescendants()) do if v:IsA("PointLight") and v.Name=="ShopLight" then v.Enabled=on end end
end
local function removeCustomer(shop) CustomerFlow.Clear(shop) end
local function customer(shop,shadow) CustomerFlow.Shadow(shop,shadow) end
local function orderSeconds(shop)
 local d=shopData(shop);return math.max(8,(Catalog.Get("OrderSeconds")+(d and d.Upgrades.Service or 0)*8)*(shop.CustomerPatienceFactor or 1))
end


local function mealInProgress(shop,food)
 if shop.Prepared==food then return true end
 for player in pairs(shop.Members) do local pd=personal(player);if pd and (pd.Held==food or pd.Cooking==food) then return true end end
 return false
end
function Service.OrderUnavailable(shop)
 if shop.Phase~="Playing" or shop.CustomerStage~="Ordering" or shop.Order=="" or mealInProgress(shop,shop.Order) then return false end
 local stock=Inventory.Data(shop)
 return not stock or (stock.Front[Recipes.StockId(shop.Order)] or 0)<=0
end
local function stockOrMeals(shop)
 if Inventory.HasStock(shop) then return true end
 for _,food in ipairs(allFoods) do if mealInProgress(shop,food) then return true end end
 return false
end
local function nextOrder(shop,takeaway)
 Bundles.Clear(shop)
 local oldDish=shop.Order
 if shop.Prepared~="" then Inventory.Refund(shop,shop.Prepared);shop.Prepared="" end
 if not stockOrMeals(shop) then Service.CloseShop(shop.Owner,"OUT OF STOCK",takeaway and oldDish or nil);return end
 shop.Prepared="";shop.Order="";shop.Deadline=math.huge;shop.Patience=1
 local token=shop.Token
 local function spawnNext()
  if shop.Phase~="Playing" or shop.Token~=token then return end
  local available={};for _,f in ipairs(shopFoods(shop)) do if Inventory.Available(shop,f)>0 or mealInProgress(shop,f) then table.insert(available,f) end end
  if #available==0 then Service.CloseShop(shop.Owner,"OUT OF STOCK");return end
  local food=Experience.Customer(shop,available)
  local ownerData=shop.Owner and Profiles.Get(shop.Owner)
  Bundles.Begin(shop,food,available,ownerData and Experience.Tier(ownerData)>=2 and not Experience.Training(shop) and shop.CustomerKind~="Party" and ((ownerData.Shop.Career.Visits or 0)%3==1))
  CustomerFlow.Spawn(shop,food,function(model)
   if shop.Phase~="Playing" or shop.Token~=token or shop.Customer~=model then return end
   Experience.Arrived(shop,model)
   shop.Order=food;shop.Deadline=os.clock()+orderSeconds(shop);shop.ChefAt=os.clock();shop.WaiterAt=os.clock()
   cue(shop,"Order");Service.Sync(shop)
  end)
  Service.Sync(shop)
 end
 if shop.Customer then CustomerFlow.Depart(shop,takeaway and oldDish or nil,spawnNext)
 else spawnNext() end
end
function Service.InformUnavailable(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if not shop or not shop.Members[player] or shop.Event~="" or not Service.OrderUnavailable(shop) then return false,"This order is available" end
 local oldFood=shop.Order
 local stock=Inventory.Data(shop);local choices={}
 for _,food in shopFoods(shop) do
  if food~=oldFood and ((stock and (stock.Front[Recipes.StockId(food)] or 0)>0) or mealInProgress(shop,food)) then table.insert(choices,food) end
 end
 local change=#choices>0 and math.random()<math.clamp(Catalog.Get("CustomerChangeOrderChance",.7),0,1)
 shop.ShortageSince=nil
 if change then
  local food=choices[math.random(1,#choices)]
  Bundles.Clear(shop)
  shop.Order=food;shop.Deadline=os.clock()+orderSeconds(shop);shop.Patience=1;shop.ChefAt=os.clock();shop.WaiterAt=os.clock()
  CustomerFlow.ChangeOrder(shop,food)
  for p in pairs(shop.Members) do tell(p,oldFood.." unavailable. Customer chose "..food..".") end
  cue(shop,"Order");Service.Sync(shop)
  return true,"Customer changed their order"
 end
 Bundles.Clear(shop)
 shop.Order="";shop.Deadline=math.huge;shop.Patience=1
 CustomerFlow.Say(shop,"No thanks!")
 for p in pairs(shop.Members) do tell(p,oldFood.." unavailable. Customer left without buying. No penalty.") end
 local token=shop.Token
 CustomerFlow.Depart(shop,nil,function()
  if shop.Phase~="Playing" or shop.Token~=token then return end
  local stockNow=Inventory.Data(shop);local ready=false
  for _,food in shopFoods(shop) do if (stockNow and (stockNow.Front[Recipes.StockId(food)] or 0)>0) or mealInProgress(shop,food) then ready=true end end
  if ready then nextOrder(shop) else Service.CloseShop(shop.Owner,Inventory.HasStock(shop) and "RESTOCK REQUIRED" or "OUT OF STOCK") end
  Service.Sync(shop)
 end)
 Service.Sync(shop)
 return true,"Customer left without buying"
end
local function finish(shop,win)
 if shop.Prepared~="" then Inventory.Refund(shop,shop.Prepared) end
 Bundles.Clear(shop)
 shop.PartyRemaining=0
 shop.Phase=win and "Won" or "Lost";shop.Event="";shop.Order="";shop.Prepared="";shop.Token+=1
 if win then for p in pairs(shop.Members) do task.spawn(Quests.Track,p,{Shifts=1}) end end
 for p in pairs(shop.Members) do local pd=personal(p);if pd then Inventory.CancelCooking(p,shop);if pd.Held~="" then Inventory.Refund(shop,pd.Held) end;pd.Held="";pd.Cooking="";pd.CookEnd=0 end end
 lights(shop,true);removeCustomer(shop);cue(shop,win and "Win" or "Lose");Service.Sync(shop)
end
local function strike(shop)
 shop.Strikes+=1;shop.Combo=0;cue(shop,"Mistake")
 if shop.Strikes>=5 then finish(shop,false) end
end
local function clearEvent(shop)
 shop.Event="";shop.EventLeft=1;lights(shop,true);shop.Deadline=os.clock()+orderSeconds(shop)
 if shop.Phase=="Playing" then customer(shop,false) end
 cue(shop,"Repair")
end
local function reward(shop,actor,quality,score)
 shop.Combo+=1;shop.Served+=1
 Style.Burst(shop)
 local d=shopData(shop);local decor=d and d.Upgrades.Decor or 0
 local city=workspace:FindFirstChild("MidnightCity")
 local multiplier=city and city:GetAttribute("Event")=="Lunch Rush" and 1.2 or 1
 local amount=math.floor((shop.Bundle and 2.2 or 1)*(Catalog.Get("ServeReward")+math.min(shop.Combo-1,5)*5+decor*5)*multiplier)
 amount=Experience.Reward(shop,actor,quality,amount,score)
 if actor and actor:GetAttribute("Role")=="Waiter" then -- Waiter role: +10% on meals they serve
  local extra=math.floor(amount*.1);amount+=extra
  if shop.LastSale then shop.LastSale.Bonus+=extra;shop.LastSale.Total=amount end
 end
 shop.Cash+=amount;shop.Reward=amount
 if shop.Owner then Profiles.Mutate(shop.Owner,function(profile) profile.Shop.Bank+=amount;return true end) end
 local tip=math.max(5,math.floor(amount*.3))
 for p in pairs(shop.Members) do Profiles.Mutate(p,function(profile) profile.Coins+=tip;return true end) end
 -- Quest progress is shared by the whole crew; Perfect counts for the player who cooked/served it.
 local special=shop.CustomerKind=="Reviewer" or shop.CustomerKind=="Regular" or shop.CustomerKind=="Party"
 for p in pairs(shop.Members) do task.spawn(Quests.Track,p,{Served=1,Earned=amount,Special=special and 1 or nil,Perfect=(p==actor and quality=="Perfect") and 1 or nil}) end
 Service.Sync(shop);Experience.SaleNotice(shop);cue(shop,"Serve");nextOrder(shop,true);Service.Sync(shop)
end
local function tryServe(shop,actor,dish,quality,score)
 if shop.Phase~="Playing" or shop.CustomerStage~="Ordering" or dish=="" then return end
 if shop.Event=="SHADOW" then strike(shop);if shop.Phase=="Playing" then clearEvent(shop);nextOrder(shop) end
 else
  local accepted,complete,finalQuality,finalScore=Bundles.Accept(shop,dish,quality,score)
  if not accepted then strike(shop);if shop.Phase=="Playing" then nextOrder(shop) end
  elseif complete then reward(shop,actor,finalQuality,finalScore)
  else
   shop.Deadline=os.clock()+orderSeconds(shop);shop.ChefAt=os.clock();shop.WaiterAt=os.clock()
   CustomerFlow.ChangeOrder(shop,shop.Order)
   for p in pairs(shop.Members) do tell(p,"Set meal: 1 / 2 delivered. Still waiting for "..Recipes.Get(shop.Order).Name..".") end
   cue(shop,"Serve");Service.Sync(shop)
  end
 end
end

function Service.CloseShop(player,reason,takeaway)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if not shop or shop.Owner~=player then return false,"Owner only" end
 if shop.Phase=="Closed" then return true,"Shop is already closed" end
 if shop.Phase=="Playing" then shop.Time=math.max(0,math.ceil(shop.Ends-os.clock())) end
 shop.PartyRemaining=0
 shop.Phase="Closed";shop.Token+=1;shop.CloseReason=reason or "TEMPORARILY CLOSED";shop.Combo=0;shop.Event="";lights(shop,true)
 for member in pairs(shop.Members) do
  local data=personal(member)
  Inventory.CancelCooking(member,shop)
  if data and data.Held~="" then Inventory.Refund(shop,data.Held);data.Held="" end
  if data then data.Cooking="";data.CookEnd=0 end
  tell(member,shop.CloseReason..". Restock, then reopen at the OPEN/CLOSED sign.")
 end
 if shop.Prepared~="" then Inventory.Refund(shop,shop.Prepared) end
 shop.Prepared="";shop.Order="";shop.Deadline=math.huge
 local m=shop.Customer
 if m then
  local head=m:FindFirstChild("Head")
  if head then
   local g=Instance.new("BillboardGui");g.Name="ClosedNotice";g.Size=UDim2.fromOffset(220,34);g.StudsOffset=Vector3.new(0,1.5,0);g.AlwaysOnTop=true;g.Parent=head
   local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(27,38,44);t.Text=reason=="OUT OF STOCK" and "Sorry, sold out!" or "Temporarily closed";t.Font=Enum.Font.GothamBold;t.TextSize=17;t.TextColor3=Color3.fromRGB(255,201,122);t.Parent=g
  end
  CustomerFlow.Depart(shop,takeaway,function() Service.Sync(shop) end)
 else shop.CustomerStage="Idle" end
 Service.Sync(shop);return true,"Shop closed. Shift time is paused."
end
function Service.ToggleShop(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if not shop or shop.Owner~=player then return false,"Owner only" end
 if shop.Phase=="Playing" then return Service.CloseShop(player,"TEMPORARILY CLOSED") end
 return Service.StartShift(player)
end
function Service.StartShift(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if not shop then return false,"Join a kitchen first" end
 if shop.Owner~=player then return false,"Only the owner can open the shop" end
 if shop.Phase=="Playing" then return false,"Shop is already open" end
 if not Inventory.HasStock(shop) then return false,"No ingredients. Buy supplies at the mall and deliver them to the backroom." end
 local resume=shop.Phase=="Closed" and shop.Time>0
 shop.Phase="Playing";shop.CloseReason="";shop.Token+=1
 if not resume then Experience.BeginShift(shop);shop.Time=Catalog.Get("ShiftSeconds");shop.Cash=0;shop.Served=0;shop.Strikes=0;shop.Combo=0;shop.Reward=0 end
 shop.Ends=os.clock()+shop.Time;shop.Event="";shop.Prepared=""
 for member in pairs(shop.Members) do
  local data=personal(member);Inventory.CancelCooking(member,shop)
  data.Held="";data.Cooking="";data.CookEnd=0
 end
 shop.NextEvent=os.clock()+Catalog.Get("EventInterval");shop.EventIndex=0;shop.ChefAt=os.clock();shop.WaiterAt=os.clock()
 if shop.Customer then CustomerFlow.Clear(shop) end
 Experience.Tutorial(player,"Open")
 nextOrder(shop);cue(shop,"Start");Service.Sync(shop);return true,resume and "Shop reopened. Shift resumed." or "Shop is open."
end
local function near(player,part)
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local humanoid=char and char:FindFirstChildOfClass("Humanoid")
 return root and humanoid and humanoid.Health>0 and (root.Position-part.Position).Magnitude<=10
end
function Service.PickupPrepared(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if not shop or not shop.Members[player] or shop.Phase~="Playing" or shop.CustomerStage~="Ordering" or shop.Prepared=="" then return false,"No meal ready" end
 if pd.Held~="" or pd.Cooking~="" or Inventory.Bag(player,shop) then return false,"Empty your hands first" end
 local names={NOODLES="NoodleStation",["FRIED RICE"]="RiceStation",["THAI TEA"]="TeaStation"}
 local station=shop.Model:FindFirstChild(Recipes.Station(shop.Prepared) or "")
 if not station or not near(player,station) then return false,"Go to the ready meal" end
 local dish=shop.Prepared
 shop.Prepared="";pd.Held=dish;pd.HeldQuality=shop.PreparedQuality or "Normal";pd.HeldScore=nil;shop.PreparedQuality=nil
 feedback:FireClient(player,"Ready");Service.Sync(shop)
 return true,"Meal picked up. Serve the customer."
end
local function cook(player,shop,food)
 if shop.Prepared==food then local ok,msg=Service.PickupPrepared(player);if not ok then tell(player,msg) end;return end
 local pd=personal(player)
 if Inventory.Bag(player,shop) then local ok,msg=Inventory.Restock(player,shop,food);tell(player,msg or "Done");return end
 if shop.Phase~="Playing" or shop.CustomerStage~="Ordering" or shop.Order=="" or pd.Cooking~="" or pd.Held~="" then return end
 if Service.OrderUnavailable(shop) then tell(player,"Menu unavailable. Tell the customer at the serving counter or refill ingredients.");return end
 if shop.Event=="BLACKOUT" then tell(player,"Restore power first");return end
 if not Inventory.Consume(shop,food) then
  if Inventory.Available(shop,food)<=0 and not mealInProgress(shop,food) then Service.CloseShop(shop.Owner,"OUT OF STOCK")
  else tell(player,"Front stock empty. Get a crate from the backroom.") end
  Service.Sync(shop);return
 end
 pd.CookingConsumed=food
 local d=shopData(shop);local duration=Catalog.Get("CookSeconds")-(d and d.Upgrades.Kitchen or 0)*.55
 if player:GetAttribute("Role")=="Chef" then duration*=.8 end -- Chef role: 20% faster cooking
 duration=math.max(.7,duration)
 pd.Cooking=food;pd.CookEnd=workspace:GetServerTimeNow()+duration;pd.CookDuration=duration
 pd.SkillHit=false;pd.SkillTarget=Experience.NewTimingTarget(pd.LastSkillTarget);pd.LastSkillTarget=pd.SkillTarget;pd.CookQuality="Poor";pd.CookScore=0;pd.HeldQuality=nil;pd.HeldScore=nil
 Experience.Tutorial(player,"Cook")
 local state=player:FindFirstChild("MidnightState");if state then state:SetAttribute("CookDuration",duration) end
 feedback:FireClient(player,"Cook");Service.Sync(shop)
 local token=shop.Token;local cookEnd=pd.CookEnd
 task.delay(duration,function()
  if personal(player)==pd and pd.ShopId==shop.Id and pd.CookEnd==cookEnd and pd.Cooking==food and shop.Token==token and shop.Phase=="Playing" then
   Experience.Tutorial(player,"Skill");pd.CookingConsumed="";pd.Held=food;pd.HeldQuality=pd.CookQuality or "Poor";pd.HeldScore=pd.CookScore or 0;if not pd.SkillHit then feedback:FireClient(player,"Poor",0) end;pd.Cooking="";pd.CookEnd=0;feedback:FireClient(player,"Ready");Service.Sync(shop)
  end
 end)
end
local function bind(shop,name,promptName,fn)
 local part=shop.Model:WaitForChild(name);local prompt=part:WaitForChild(promptName)
 prompt.Triggered:Connect(function(player)
  local pd=personal(player)
  if pd and pd.ShopId==shop.Id and shop.Members[player] and near(player,part) then fn(player) end
 end)
end
local function spawnWorker(shop,kind,index)
 local folder=shop.Model:FindFirstChild("Employees")
 if not folder then folder=Instance.new("Folder");folder.Name="Employees";folder.Parent=shop.Model end
 if folder:FindFirstChild(kind) then return end
 local m=Instance.new("Model");m.Name=kind;m.Parent=folder
 local floor=shop.Model.ShopFloor
 local pos=floor.Position+Vector3.new((index-2)*4,floor.Size.Y/2,0)
 local function p(n,size,offset,col)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.Position=pos+offset;a.Color=col;a.Anchored=true;a.CanCollide=false;a.Parent=m;return a
 end
 local body=p("Body",Vector3.new(1.8,2,1),Vector3.new(0,2.5,0),Color3.fromRGB(90,153,134))
 p("Head",Vector3.new(1.4,1.4,1.4),Vector3.new(0,4.2,0),Color3.fromRGB(222,182,143)).Shape=Enum.PartType.Ball
 p("Cap",Vector3.new(1.55,.35,1.55),Vector3.new(0,5,0),Color3.fromRGB(241,231,205))
 for _,x in ipairs({-.45,.45}) do p("Leg",Vector3.new(.6,1.5,.7),Vector3.new(x,.8,0),Color3.fromRGB(41,48,56)) end
 local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(140,32);g.StudsOffset=Vector3.new(0,3.7,0);g.AlwaysOnTop=true;g.Parent=body
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(19,32,40);t.Text=kind;t.TextColor3=Color3.fromRGB(166,242,208);t.Font=Enum.Font.GothamBold;t.TextSize=16;t.Parent=g
end
local function refreshWorkers(shop)
 local d=shopData(shop)
 if d then for i,item in ipairs(Catalog.Workers) do if d.Workers[item.Id] then spawnWorker(shop,item.Id,i) end end end
end

local function refreshDecor(shop)
 local d=shopData(shop)
 local old=shop.Model:FindFirstChild("Patio");if old then old:Destroy() end
 if not d or d.Upgrades.Decor==0 then return end
 local folder=Instance.new("Folder");folder.Name="Patio";folder.Parent=shop.Model
 local ground=shop.Model.Pavement.Position.Y+shop.Model.Pavement.Size.Y/2
 local floor=shop.Model.ShopFloor
 local function p(name,size,pos,color)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.Position=pos;a.Color=color;a.Material=Enum.Material.Wood;a.Anchored=true;a.Parent=folder;return a
 end
 for i=1,d.Upgrades.Decor do
  local origin=Vector3.new(floor.Position.X+22,ground,floor.Position.Z+(i-2)*5)
  p("TableLeg",Vector3.new(.5,2,.5),origin+Vector3.new(0,1,0),Color3.fromRGB(74,62,50))
  p("TableTop",Vector3.new(3.5,.25,3),origin+Vector3.new(0,2.125,0),Color3.fromRGB(173,127,78))
  for _,x in ipairs({-2.7,2.7}) do
   p("Chair",Vector3.new(1.7,1.3,1.7),origin+Vector3.new(x,.65,0),Color3.fromRGB(62,104,97))
  end
 end
end
-- Called after the owner has been removed from shop.Members. Hands the kitchen to the longest-serving crew member,
-- or vacates it when nobody is left. Refunds run first while the old owner's stock is still attached.
local function releaseShop(shop)
 for member in pairs(shop.Members) do Inventory.Return(member,shop) end
 local heir,joined
 for member in pairs(shop.Members) do
  local d=personal(member);local t=d and d.JoinedAt or math.huge
  if Profiles.Get(member) and (not heir or t<joined) then heir,joined=member,t end
 end
 local function clearStaff()
  local employees=shop.Model:FindFirstChild("Employees");if employees then employees:Destroy() end
  local patio=shop.Model:FindFirstChild("Patio");if patio then patio:Destroy() end
 end
 if not heir then
  finish(shop,false);shop.Owner=nil;shop.Locked=false;clearStaff()
  local remaining={};for member in pairs(shop.Members) do table.insert(remaining,member) end
  for _,member in ipairs(remaining) do Service.VisitCity(member) end
  theme(shop);updateOwnerBillboard(shop)
  return
 end
 if shop.Prepared~="" then Inventory.Refund(shop,shop.Prepared) end
 for member in pairs(shop.Members) do
  Inventory.CancelCooking(member,shop);dropHeld(member,shop)
  local d=personal(member);if d then d.Cooking="";d.CookEnd=0 end
 end
 shop.Token+=1;shop.Phase="Ready";shop.Time=Catalog.Get("ShiftSeconds");shop.Event="";shop.Order="";shop.Prepared="";shop.Deadline=math.huge
 shop.PartyRemaining=0;shop.CloseReason="";shop.Combo=0;shop.Locked=false;shop.Kicked={}
 lights(shop,true);removeCustomer(shop);clearStaff()
 shop.Owner=heir;heir:SetAttribute("Role","Owner")
 theme(shop);refreshWorkers(shop);refreshDecor(shop);updateOwnerBillboard(shop)
 for member in pairs(shop.Members) do tell(member,heir.DisplayName.." now owns this kitchen. Open the shop when ready.") end
 Service.Sync(shop)
end
function Service.Join(player,id)
 local pd=personal(player);local target=Service.Shops[id]
 if not pd or not target then return false,"Shop not found" end
 if pd.ShopId==id then return true,"Already in this shop" end
 if not target.Owner then
  local current=Service.Shops[pd.ShopId]
  if current and current.Owner==player then return false,"Use your own shop or join another owner" end
  return false,"This shop has no owner"
 end
 if target.Locked or count(target)>=4 then return false,"Shop is locked or full" end
 local ban=target.Kicked and target.Kicked[player.UserId]
 if ban and ban.By==target.Owner.UserId and ban.Until>os.clock() then return false,"The owner removed you from this kitchen. Try again in "..math.ceil((ban.Until-os.clock())/60).." min." end
 local old=Service.Shops[pd.ShopId]
 if old then
  Inventory.Return(player,old);Inventory.CancelCooking(player,old);dropHeld(player,old)
  old.Members[player]=nil;old.Model:RemovePersistentPlayer(player)
  if old.Owner==player then releaseShop(old) end
 end
 pd.ShopId=id;pd.JoinedAt=os.clock();pd.Held="";pd.Cooking="";pd.CookEnd=0;target.Members[player]=true;target.Model:AddPersistentPlayer(player);player:SetAttribute("ShopId",id);player:SetAttribute("Role",target.Owner==player and "Owner" or "Crew")
 Service.Teleport(player);if old then Service.Sync(old) end;Service.Sync(target)
 return true,"Joined shop "..id
end
function Service.Teleport(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if player:GetAttribute("InTransit") then return end
 if player.Character then
  if shop then player.Character:PivotTo(shop.Model.ShopFloor.CFrame*CFrame.new(0,4,0))
  else
   local spawn=workspace:FindFirstChild("CityLobbySpawn")
   if spawn then player.Character:PivotTo(spawn.CFrame*CFrame.new(0,3,0)) end
  end
 end
end

function Service.VisitCity(player)
 local pd=personal(player);if not pd then return false,"Not ready" end
 local old=Service.Shops[pd.ShopId]
 if old and old.Owner==player then return false,"Join another kitchen to release your shop" end
 if old then Inventory.Return(player,old);Inventory.CancelCooking(player,old);dropHeld(player,old);old.Members[player]=nil;old.Model:RemovePersistentPlayer(player);Service.Sync(old) end
 pd.ShopId=0;pd.Held="";pd.Cooking="";pd.CookEnd=0
 player:SetAttribute("ShopId",0);player:SetAttribute("Role","Visitor")
 Service.SyncLobby(player);Service.Teleport(player)
 return true,"In the city. Choose a kitchen in Co-op."
end
function Service.ReturnHome(player)
 local pd=personal(player);if not pd then return false,"Not ready" end
 local old=Service.Shops[pd.ShopId]
 if old and old.Owner==player then Service.Teleport(player);return true end
 local free
 for _,s in ipairs(Service.Shops) do if not s.Owner then free=s;break end end
 if not free then return false,"No vacant kitchens. Choose a crew in Co-op." end
 if old then Inventory.Return(player,old);Inventory.CancelCooking(player,old);dropHeld(player,old);old.Members[player]=nil;old.Model:RemovePersistentPlayer(player);Service.Sync(old) end
 free.Owner=player;free.Members[player]=true;free.Model:AddPersistentPlayer(player);free.Locked=false;free.Phase="Ready";pd.ShopId=free.Id;pd.Held="";pd.Cooking="";pd.CookEnd=0
 player:SetAttribute("ShopId",free.Id);player:SetAttribute("Role","Owner")
 theme(free);refreshWorkers(free);refreshDecor(free);updateOwnerBillboard(free);Service.Teleport(player);Service.Sync(free)
 return true,"Your shop is ready"
end
function Service.AddPlayer(player)
 local d,problem=Profiles.Load(player)
 if not d then player:Kick(problem);return end
 Saves.Join(player)
 Inventory.Recover(player)
 if player.Parent~=Players then Profiles.Save(player,true);return end
 local state=Instance.new("Folder");state.Name="MidnightState";state.Parent=player
 Service.PlayerData[player]={ShopId=0,Held="",Cooking="",CookEnd=0}
 local free
 for _,s in ipairs(Service.Shops) do if not s.Owner then free=s;break end end
 if free then
  free.Owner=player;free.Members[player]=true;free.Model:AddPersistentPlayer(player);free.Locked=false;free.Phase="Ready";Service.PlayerData[player].ShopId=free.Id

 end
 player:SetAttribute("ShopId",free and free.Id or 0)
 player:SetAttribute("Role",free and "Owner" or "Visitor")
 player:SetAttribute("SaveMode",Profiles.Sandbox and "Studio sandbox" or "Persistent")

 player.CharacterAdded:Connect(function()
  local pd=personal(player);if pd then local shop=Service.Shops[pd.ShopId];Inventory.CancelCooking(player,shop);if shop and pd.Held~="" then Inventory.Refund(shop,pd.Held) end;pd.Held="";pd.Cooking="";pd.CookEnd=0 end
  task.wait(.4);characterLook(player);Service.Teleport(player)
 end)
 if free then theme(free);refreshWorkers(free);refreshDecor(free);updateOwnerBillboard(free);Service.Sync(free) else Service.SyncLobby(player) end
 if player.Character then characterLook(player);Service.Teleport(player) end
end
function Service.RemovePlayer(player)
 local pd=personal(player);local shop=pd and Service.Shops[pd.ShopId]
 if shop then Inventory.Return(player,shop);Inventory.CancelCooking(player,shop);dropHeld(player,shop);if shop.Owner==player then for member in pairs(shop.Members) do Inventory.Return(member,shop) end end end
 Service.PlayerData[player]=nil
 if shop then
  shop.Members[player]=nil
  -- Departing clients may already be outside Players; streaming removal then throws.
  if player.Parent==Players then shop.Model:RemovePersistentPlayer(player) end
  if shop.Owner==player then releaseShop(shop) end
  Service.Sync(shop)
 end
 task.spawn(function() for _=1,3 do if Profiles.Save(player,true) then return end;task.wait(1) end end)
end
local function publicCatalog(list)
 local out={}
 for _,item in ipairs(list) do
  local row=table.clone(item)
  if not item.ProductId then
   if item.Gems then row.Gems=Catalog.Cost(item) else row.Price=Catalog.Cost(item) end
  end
  table.insert(out,row)
 end
 return out
end
function Service.Snapshot(player,full)
 local pd=personal(player);local d=Profiles.Get(player);if not pd or not d then return {Ready=false} end
 local shops={}
 for _,s in ipairs(Service.Shops) do
  local members={};for p in pairs(s.Members) do table.insert(members,{Id=p.UserId,Name=p.DisplayName,Role=p:GetAttribute("Role")}) end
  table.insert(shops,{Id=s.Id,Owner=s.Owner and s.Owner.DisplayName or "",OwnerId=s.Owner and s.Owner.UserId or 0,Members=members,Count=count(s),Locked=s.Locked,Phase=s.Phase})
 end
 local current=Service.Shops[pd.ShopId];local sd=current and shopData(current)
 local style=Style.Snapshot(player)
 local out={Ready=true,Full=full,Journey=Experience.Snapshot(player),Saves=Saves.Snapshot(player),Style=style,Coins=d.Coins,Gems=d.Gems,Owned=d.Owned,Equipped=d.Equipped,Bank=sd and sd.Bank or 0,
 Upgrades=sd and sd.Upgrades or {},Workers=sd and sd.Workers or {},ShopId=pd.ShopId,Owner=current and current.Owner==player,
 Supplies=Inventory.Snapshot(player,current),Travel=Transit.Snapshot(player),Shops=shops,Sandbox=Profiles.Sandbox}
 for key,fn in pairs(Service.SnapshotExtras) do local ok,value=pcall(fn,player);if ok then out[key]=value end end
 if full then
  out.Items=publicCatalog(Catalog.Items);out.Premium=publicCatalog(Catalog.Premium);out.Products=Catalog.Products
  out.UpgradeCatalog=publicCatalog(Catalog.Upgrades);out.WorkerCatalog=publicCatalog(Catalog.Workers)
 elseif style then
  -- Lite refresh: the client keeps the static style catalog from its last full snapshot.
  local lite=table.clone(style);lite.Items=nil;lite.Packs=nil;lite.Slots=nil;out.Style=lite
 end
 return out
end
-- Other modules (quests, leaderboards, courier jobs) register snapshot sections here.
Service.SnapshotExtras={}
function Service.Command(player,action,id)
 local pd=personal(player);if not pd then return false,"Please wait for your profile" end
 local shop=Service.Shops[pd.ShopId];local d=Profiles.Get(player)
 local handler=Service.CommandHandlers[action]
 if handler then local ok,msg=handler(player,id);Service.SyncPlayer(player);return ok,msg end
 if ({CookSkill=true,CrewPing=true,PassMeal=true,FeatureDish=true,SignatureMenu=true,TutorialSkip=true,TutorialReplay=true})[action] then local ok,msg=Experience.Command(player,action,id);Service.SyncPlayer(player);return ok,msg end
 if action:sub(1,4)=="Save" or action=="LoadDesign" then return Saves.Command(player,action) end
 if action:sub(1,5)=="Style" then local ok,msg=Style.Command(player,action,id);Service.SyncPlayer(player);return ok,msg end
 if action=="Travel" then return Transit.Travel(player,id) end
 if action=="ToggleShop" then return Service.ToggleShop(player) end
 if action=="BuySupplies" then return Inventory.Buy(player,shop,id) end
 if action=="TakeStock" then return Inventory.Take(player,shop,id) end
 if action=="FillStock" then return Inventory.Restock(player,shop,id) end
 if action=="Join" then return Service.Join(player,tonumber(id)) end
 if action=="Home" then return Service.ReturnHome(player) end
 if action=="Leave" then return Service.VisitCity(player) end
 if action=="Teleport" then Service.Teleport(player);return true,shop and "Returned to your kitchen" or "Returned to city spawn" end
 if action=="Lock" then if not shop or shop.Owner~=player then return false,"Owner only" end;shop.Locked=not shop.Locked;return true,shop.Locked and "Shop locked" or "Shop open to crew" end
 if action=="Kick" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local member=Players:GetPlayerByUserId(tonumber(id) or 0)
  if not member or member==player or not shop.Members[member] then return false,"Crew member not found" end
  shop.Kicked=shop.Kicked or {}
  shop.Kicked[member.UserId]={By=player.UserId,Until=os.clock()+300}
  local ok,msg=Service.VisitCity(member)
  if ok then tell(member,"You were removed from "..player.DisplayName.."'s kitchen.") end
  return ok,ok and (member.DisplayName.." removed for 5 minutes") or msg
 end
 if action=="Deposit" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local ok,msg=Profiles.Mutate(player,function(profile) if profile.Coins<100 then return false,"Need 100 coins" end;profile.Coins-=100;profile.Shop.Bank+=100;return true,"Deposited 100 coins into shop funds (one-way)" end);Service.SyncPlayer(player);return ok,msg
 end
 if action=="Role" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local userId,role=tostring(id):match("^(%-?%d+):(%a+)$")
  local allowed={Chef=true,Waiter=true,Technician=true,Crew=true}
  if not userId or not allowed[role] then return false,"Unknown role" end
  local member=Players:GetPlayerByUserId(tonumber(userId))
  if not member or member==shop.Owner or not shop.Members[member] then return false,"Crew member not found" end
  member:SetAttribute("Role",role)
  local perks={Chef=" • cook 20% faster",Waiter=" • +10% on meals you serve",Technician=" • +$15 shop funds per repair"}
  tell(member,"You are now the "..role..(perks[role] or ""))
  return true,member.DisplayName.." assigned as "..role
 end
 if action=="Emote" then
  if d.Equipped.Emote=="" then return false,"Equip an emote first" end
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
  if hum then
   local name=d.Equipped.Emote=="emote_wave" and "wave" or "dance"
   local animate=char:FindFirstChild("Animate")
   local entry=animate and (animate:FindFirstChild(name) or animate:FindFirstChild(name.."1"))
   local anim=entry and entry:FindFirstChildWhichIsA("Animation",true)
   if anim then
    local animator=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator",hum)
    local ok,track=pcall(function() return animator:LoadAnimation(anim) end)
    if ok then track.Priority=Enum.AnimationPriority.Action;track.Looped=false;track:Play();task.delay(6,function() track:Stop();track:Destroy() end);return true,"Enjoy!" end
   end
   local ok,result=pcall(function() return hum:PlayEmote(name) end)
   if ok and result then return true,"Enjoy!" end
  end
  return false,"This avatar does not support the emote"
 end
 local item=Catalog.Find(id);if not item then return false,"Item not found" end
 if action=="Buy" then
  if not item.Kind then return false,"Use the matching menu" end
  local currency=item.Gems and "Gems" or "Coins";local price=Catalog.Cost(item)
  local ok,message=Profiles.Mutate(player,function(profile)
   if profile.Owned[id] then return false,"Already owned" end
   if profile[currency]<price then return false,"Not enough "..currency end
   profile[currency]-=price;profile.Owned[id]=true;return true,"Purchased "..item.Name
  end)
  Service.SyncPlayer(player);return ok,message
 elseif action=="Equip" then
  if not item.Kind or not d.Owned[id] then return false,"Buy this item first" end
  if item.Kind=="Theme" and (not shop or shop.Owner~=player) then return false,"Only the shop owner can apply a theme" end
  local ok,message=Profiles.Mutate(player,function(profile) profile.Equipped[item.Kind]=profile.Equipped[item.Kind]==id and "" or id;return true,"Updated "..item.Kind end)
  theme(shop);characterLook(player);return ok,message
 elseif action=="Upgrade" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local valid=false;for _,v in ipairs(Catalog.Upgrades) do if v.Id==id then valid=true end end;if not valid then return false,"Unknown upgrade" end
  local ok,message=Profiles.Mutate(player,function(profile)
   local level=profile.Shop.Upgrades[id] or 0
   if level>=item.Max then return false,"Maximum level" end
   local price=Catalog.Cost(item,level+1)
   if profile.Shop.Bank<price then return false,"Not enough shop funds" end
   profile.Shop.Bank-=price;profile.Shop.Upgrades[id]=level+1;return true,item.Name.." level "..(level+1)
  end)
  if ok then Experience.Tutorial(player,"Upgrade") end
  refreshDecor(shop);Service.SyncPlayer(player);return ok,message
 elseif action=="Hire" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local valid=false;for _,v in ipairs(Catalog.Workers) do if v.Id==id then valid=true end end;if not valid then return false,"Unknown employee" end
  local ok,message=Profiles.Mutate(player,function(profile)
   if profile.Shop.Workers[id] then return false,"Already hired" end
   local price=Catalog.Cost(item)
   if profile.Shop.Bank<price then return false,"Not enough shop funds" end
   profile.Shop.Bank-=price;profile.Shop.Workers[id]=true;return true,item.Name.." hired • Shop funds -$"..price
  end)
  refreshWorkers(shop);Service.SyncPlayer(player);return ok,message
 end
 return false,"Unknown action"
end
function Service.Start()
 Experience.Start(Service)
 Inventory.Start(Service)
 Quests.Start(Service)
 for i,model in ipairs(workspace.MidnightShops:GetChildren()) do
  if model:IsA("Model") then
   local id=model:GetAttribute("ShopId")
   local s={Id=id,Model=model,Members={},Owner=nil,Phase="Ready",Time=300,Cash=0,Served=0,Strikes=0,Combo=0,Reward=0,Order="",Event="",EventLeft=1,Patience=1,Prepared="",Token=0,Locked=false}
   Service.Shops[id]=s;updateOwnerBillboard(s);Inventory.Bind(s)
   bind(s,"StartShift","Start",function(p) Service.StartShift(p) end)
   for n,name in ipairs(Recipes.Stations) do bind(s,name,"Cook",function(p)
    local food=shopFoods(s)[n]
    food=Bundles.StationFood(s,n,food)
    cook(p,s,food)
   end) end
   bind(s,"Serve","Serve",function(p)
    if s.Phase~="Playing" or s.CustomerStage~="Ordering" then tell(p,"Wait for the next customer");return end
    if Service.OrderUnavailable(s) then Service.InformUnavailable(p);return end
    local pd=personal(p);local dish=pd.Held
    if dish~="" then pd.Held="";tryServe(s,p,dish,pd.HeldQuality,pd.HeldScore);pd.HeldQuality=nil;pd.HeldScore=nil
    elseif s.Prepared~="" then tell(p,"Pick up the ready meal from the cooking station first")
    else tell(p,"Cook a dish or wait for your chef") end
    Service.Sync(s)
   end)
   for _,e in ipairs({{"FuseBox","Repair","BLACKOUT"},{"Radio","Silence","WHISPER"},{"Ward","Ward","SHADOW"}}) do
    bind(s,e[1],e[2],function(p)
     if s.Phase=="Playing" and s.Event==e[3] then
      clearEvent(s)
      if p:GetAttribute("Role")=="Technician" and s.Owner then -- Technician role: repair bonus
       Profiles.Mutate(s.Owner,function(profile) profile.Shop.Bank+=15;return true end)
       tell(p,"Technician repair bonus • +$15 shop funds")
      end
      Service.Sync(s)
     end
    end)
   end
  end
 end
 task.spawn(function()
  while true do
   local now=os.clock()
   -- One shop's error must not stop the loop for every kitchen on the server.
   for _,s in ipairs(Service.Shops) do local stepOk,stepError=pcall(function() WorkerVisuals.Step(s,now);Style.Apply(s);if s.Phase=="Playing" then
    local unavailable=Service.OrderUnavailable(s)
    if unavailable then
     if not s.ShortageSince then s.ShortageSince=now;for p in pairs(s.Members) do tell(p,"Menu unavailable. Tell the customer or refill ingredients.") end end
     s.Deadline=now+orderSeconds(s);s.Patience=1
     local data=shopData(s)
     if data and data.Workers.Waiter and now-s.ShortageSince>=3 and s.Event=="" then Service.InformUnavailable(s.Owner) end
    else s.ShortageSince=nil end
    s.Time=math.max(0,math.ceil(s.Ends-now))
    if now>=s.Ends then finish(s,true) else
     if s.Event~="" then
      s.EventLeft=math.clamp((s.EventDeadline-now)/Catalog.Get("EventSeconds"),0,1)
      local d=shopData(s)
      if d and d.Workers.Technician and now-s.EventBegan>=Catalog.Get("WorkerTechSeconds") then clearEvent(s)
      elseif now>=s.EventDeadline then clearEvent(s);strike(s) end
     else
      s.Patience=math.clamp((s.Deadline-now)/orderSeconds(s),0,1)
      if s.CustomerStage=="Ordering" and now>=s.Deadline then Experience.Missed(s);strike(s);if s.Phase=="Playing" then nextOrder(s) end end
      if s.Phase=="Playing" and s.CustomerStage=="Ordering" and not Service.OrderUnavailable(s) and not Experience.Training(s) and now>=s.NextEvent then
       s.EventIndex=s.EventIndex%3+1;s.Event=({"BLACKOUT","WHISPER","SHADOW"})[s.EventIndex]
       s.EventBegan=now;s.EventDeadline=now+Catalog.Get("EventSeconds");s.NextEvent=now+Catalog.Get("EventInterval");cue(s,"Danger")
       if s.Event=="BLACKOUT" then lights(s,false) elseif s.Event=="SHADOW" then customer(s,true) end
      end
     end
     local d=shopData(s)
     if s.Phase=="Playing" and s.CustomerStage=="Ordering" and s.Event=="" and d then
      if not Experience.Training(s) and d.Workers.Chef and not Service.OrderUnavailable(s) and s.Prepared=="" and not mealInProgress(s,s.Order) and now-s.ChefAt>=Catalog.Get("WorkerChefSeconds") then
       s.ChefAt=now
       if Inventory.Consume(s,s.Order) then s.Prepared=s.Order;s.PreparedQuality="Normal";s.WaiterAt=now;cue(s,"Ready")
       elseif Inventory.Available(s,s.Order)<=0 and not mealInProgress(s,s.Order) then Service.CloseShop(s.Owner,"OUT OF STOCK") end
      end
      if s.Phase=="Playing" and not Experience.Training(s) and d.Workers.Waiter and s.Prepared~="" and now-s.WaiterAt>=Catalog.Get("WorkerWaiterSeconds") then local dish=s.Prepared;s.Prepared="";s.WaiterAt=now;tryServe(s,nil,dish) end
     end
     Service.Sync(s)
    end
   end end)
    if not stepOk and now-(s.LastLoopWarn or -60)>=10 then s.LastLoopWarn=now;warn("Midnight shop "..tostring(s.Id).." tick failed:",stepError) end
   end
   task.wait(.25)
  end
 end)
end
return Service
