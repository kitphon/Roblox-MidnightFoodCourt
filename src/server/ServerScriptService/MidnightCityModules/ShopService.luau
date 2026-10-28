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
 Experience.Prepare(shop)
 Style.Apply(shop)
 PreparedMeals.Update(shop)
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
 if sign then local g=sign:FindFirstChildOfClass("SurfaceGui");if g then local t=g:FindFirstChildOfClass("TextLabel");if t then t.Text=shop.Owner and (shop.Owner.DisplayName:upper().."'S KITCHEN") or ("KITCHEN "..shop.Id.." / VACANT") end end end
 shop.Model:SetAttribute("StorefrontLive",shop.Owner~=nil)
 local actions=shop.Model:FindFirstChild("WorldActions")
 local crew=actions and actions:FindFirstChild("CrewJoin")
 local prompt=crew and crew:FindFirstChildWhichIsA("ProximityPrompt",true)
 if prompt then
  prompt.Enabled=shop.Owner~=nil and count(shop)<4 and not shop.Locked
  prompt.ObjectText=shop.Owner and (shop.Owner.DisplayName.."'s crew • "..count(shop).."/4") or "No crew yet"
 end
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
   if l then l.Color=item and Color3.fromRGB(unpack(item.Color)):Lerp(Color3.new(1,1,1),.75) or Color3.fromRGB(255,213,164):Lerp(Color3.fromRGB(255,230,201),.5) end
  end
 end
end
local function lights(shop,on)
 if shop.ShadowLightLevels then
  for light,brightness in pairs(shop.ShadowLightLevels) do if light.Parent then light.Brightness=brightness end end
  shop.ShadowLightLevels=nil
 end
 for _,v in ipairs(shop.Model:GetDescendants()) do if v:IsA("PointLight") and v.Name=="ShopLight" then v.Enabled=on end end
 shop.Model:SetAttribute("StorefrontPower",on)
end
local function shadowLights(shop,now)
 shop.ShadowLightLevels=shop.ShadowLightLevels or {}
 -- Slow, partial dimming on the existing shop tick; no independent flashing task.
 local factor=.35+.65*(.5+.5*math.sin((now-shop.EventBegan)*math.pi*1.5))
 for _,v in ipairs(shop.Model:GetDescendants()) do if v:IsA("PointLight") and v.Name=="ShopLight" then
  if shop.ShadowLightLevels[v]==nil then shop.ShadowLightLevels[v]=v.Brightness end
  v.Enabled=true;v.Brightness=shop.ShadowLightLevels[v]*factor
 end end
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
 if shop.Event=="SHADOW" then if actor then tell(actor,"Banish the shadow behind the radio first") end;return
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
 shop.Phase="Closed";shop.Token+=1;shop.CloseReason=reason or "TEMPORARILY CLOSED";shop.Combo=0;shop.Event="";lights(shop,true);customer(shop,false)
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
 -- Crew lock: one cook per current order, so a teammate can't make a duplicate that becomes a wrong-dish strike.
 if food==shop.Order then
  for member in pairs(shop.Members) do
   local other=member~=player and personal(member)
   if other and (other.Cooking==food or other.Held==food) then tell(player,member.DisplayName.." is already making "..Recipes.Get(food).Name.." for this order");return end
  end
 end
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
 local trainingGrace=Experience.Training(shop)
 Experience.Tutorial(player,"Cook")
 local state=player:FindFirstChild("MidnightState");if state then state:SetAttribute("CookDuration",duration) end
 feedback:FireClient(player,"Cook");Service.Sync(shop)
 local token=shop.Token;local cookEnd=pd.CookEnd
 task.delay(duration,function()
  if personal(player)==pd and pd.ShopId==shop.Id and pd.CookEnd==cookEnd and pd.Cooking==food and shop.Token==token and shop.Phase=="Playing" then
   if not pd.SkillHit and trainingGrace then pd.CookQuality="Good";pd.CookScore=70;feedback:FireClient(player,"TrainingGrace",70)
   elseif not pd.SkillHit then feedback:FireClient(player,"Poor",0) end
   Experience.Tutorial(player,"Skill");pd.CookingConsumed="";pd.Held=food;pd.HeldQuality=pd.CookQuality or "Poor";pd.HeldScore=pd.CookScore or 0;pd.Cooking="";pd.CookEnd=0;feedback:FireClient(player,"Ready");Service.Sync(shop)
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
 if (d.Upgrades.Space or 0)>0 then
  -- Expanded dining owns its table layout. Decor becomes planters inside it,
  -- rather than creating a second row of tables outside the upgraded room.
  for i=1,d.Upgrades.Decor do
   local width=d.Upgrades.Space*7
   local pos=floor.Position+Vector3.new(floor.Size.X/2+1.3+(i-1)*(width-2.6)/2,1,7.5)
   p("DiningPlanter",Vector3.new(1.6,1,1.6),pos,Color3.fromRGB(99,73,52))
   local leaves=p("DiningPlant",Vector3.new(1.6,1.4,1.6),pos+Vector3.new(0,1.1,0),Color3.fromRGB(72,132,82));leaves.Shape=Enum.PartType.Ball;leaves.CanCollide=false
  end
  return
 end
 for i=1,d.Upgrades.Decor do
  local sideOffset=floor.Size.X/2+(d.Upgrades.Space or 0)*7+6
  local origin=Vector3.new(floor.Position.X+sideOffset,ground,floor.Position.Z+(i-2)*5)
  p("TableLeg",Vector3.new(.5,2,.5),origin+Vector3.new(0,1,0),Color3.fromRGB(74,62,50))
  p("TableTop",Vector3.new(3.5,.25,3),origin+Vector3.new(0,2.125,0),Color3.fromRGB(173,127,78))
  for _,x in ipairs({-2.7,2.7}) do
   p("Chair",Vector3.new(1.7,1.3,1.7),origin+Vector3.new(x,.65,0),Color3.fromRGB(62,104,97))
  end
 end
end

local function refreshExpansion(shop)
 local old=shop.Model:FindFirstChild("DiningExpansion");if old then old:Destroy() end
 local d=shopData(shop);local level=d and (d.Upgrades.Space or 0) or 0
 local floor=shop.Model.ShopFloor
 -- Keep the decorative right-side tree row clear of the enlarged roof/seats.
 for _,tree in shop.Model:GetChildren() do
  if tree:IsA("BasePart") and (tree.Name=="TreeTrunk" or tree.Name=="TreeCrown" or tree:GetAttribute("TreeRowDecor")) then
   local base=tree:GetAttribute("DiningTreeBaseCFrame") or tree.CFrame
   if base.Position.X>floor.Position.X+floor.Size.X/2+10 then
    tree:SetAttribute("DiningTreeBaseCFrame",base)
    local shift=level>0 and math.max(0,floor.Position.X+floor.Size.X/2+level*7+6.5-base.Position.X) or 0
    tree.CFrame=base+Vector3.new(shift,0,0)
   end
  end
 end
 local rightWall=shop.Model:FindFirstChild("RightWall")
 if rightWall then
  if rightWall:GetAttribute("ExpansionBaseTransparency")==nil then rightWall:SetAttribute("ExpansionBaseTransparency",rightWall.Transparency) end
  rightWall.Transparency=level>0 and 1 or rightWall:GetAttribute("ExpansionBaseTransparency");rightWall.CanCollide=level<=0
 end
 if level<=0 then return end
 local folder=Instance.new("Folder");folder.Name="DiningExpansion";folder.Parent=shop.Model
 local width=level*7
 local center=floor.Position+Vector3.new(floor.Size.X/2+width/2,0,0)
 local function part(name,size,pos,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.WoodPlanks;p.Anchored=true;p.Parent=folder;return p
 end
 part("ExpandedFloor",Vector3.new(width,1,floor.Size.Z),Vector3.new(center.X,floor.Position.Y,center.Z),floor.Color,floor.Material)
 local roof=shop.Model.Roof
 local canopyCenter=Vector3.new(roof.Position.X+roof.Size.X/2+width/2,roof.Position.Y,roof.Position.Z)
 part("Canopy",Vector3.new(width,roof.Size.Y,roof.Size.Z),canopyCenter,roof.Color,roof.Material)
 local floorTop=floor.Position.Y+floor.Size.Y/2
 local postHeight=roof.Position.Y-roof.Size.Y/2-floorTop
 for _,x in ipairs({center.X-width/2+.35,center.X+width/2-.35}) do
  for _,z in ipairs({center.Z-floor.Size.Z/2+.35,center.Z+floor.Size.Z/2-.35}) do part("Post",Vector3.new(.45,postHeight,.45),Vector3.new(x,floorTop+postHeight/2,z),Color3.fromRGB(72,117,108),Enum.Material.Metal) end
 end
 for i=1,level do
  local x=floor.Position.X+floor.Size.X/2-3.5+i*7
  part("DiningTable",Vector3.new(3.8,.3,3),Vector3.new(x,floor.Position.Y+2.2,floor.Position.Z),Color3.fromRGB(177,126,76))
  part("TableLeg",Vector3.new(.45,2.2,.45),Vector3.new(x,floor.Position.Y+1.1,floor.Position.Z),Color3.fromRGB(60,55,50),Enum.Material.Metal)
  for _,z in ipairs({-2.5,2.5}) do part("DiningSeat",Vector3.new(2,1.2,1.5),Vector3.new(x,floor.Position.Y+1,floor.Position.Z+z),Color3.fromRGB(68,119,107)) end
 end
end

-- Built from maintained source so every plot uses the same expanded layout.
local function buildBackroom(shop)
 local model=shop.Model;local origin=model.ShopFloor.Position
 local stockFront,stockDepth,officeDepth=10,11,14
 local dividerZ=stockFront+stockDepth
 local backZ=dividerZ+officeDepth
 local backCenter=(stockFront+backZ)/2
 local rackScale=.95
 -- Keep a small gap behind the scaled shelf at the INGREDIENTS divider wall.
 local rackZ=dividerZ-.25-.15-1.85*rackScale
 local function resize(name,size,offset)
  local p=model:FindFirstChild(name);if p then p.Size=size;p.Position=origin+offset end
 end
 resize("BackroomFloor",Vector3.new(32,1,stockDepth+officeDepth),Vector3.new(0,0,backCenter))
 resize("BackroomRoof",Vector3.new(33,1,stockDepth+officeDepth+1),Vector3.new(0,12,backCenter))
 resize("BackroomLeft",Vector3.new(1,12,stockDepth+officeDepth),Vector3.new(-16,6,backCenter))
 resize("BackroomRight",Vector3.new(1,12,stockDepth+officeDepth),Vector3.new(16,6,backCenter))
 resize("BackroomWall",Vector3.new(32,12,1),Vector3.new(0,6,backZ))
 local pavement=model.Pavement
 local pavementFront=origin.Z-36
 local pavementBack=origin.Z+backZ+3
 pavement.Size=Vector3.new(84,1,pavementBack-pavementFront)
 pavement.Position=Vector3.new(origin.X,pavement.Position.Y,(pavementFront+pavementBack)/2)
 -- The original rear grass tiles start at the old pavement edge. Trim only
 -- this plot's rear tile to the new edge instead of rendering coplanar faces.
 local city=workspace:FindFirstChild("MidnightCity")
 local grass=city and city:FindFirstChild("GrassTiles")
 for _,tile in ipairs(grass and grass:GetChildren() or {}) do
  if tile:IsA("BasePart") and math.abs(tile.Position.X-origin.X)<.01 and math.abs(tile.Size.X-pavement.Size.X)<.01 then
   local front=tile.Position.Z-tile.Size.Z/2
   local back=tile.Position.Z+tile.Size.Z/2
   if front>origin.Z and front<pavementBack and back>pavementBack then
    tile.Size=Vector3.new(tile.Size.X,tile.Size.Y,back-pavementBack)
    tile.Position=Vector3.new(tile.Position.X,tile.Position.Y,(pavementBack+back)/2)
   end
  end
 end
 local old=model:FindFirstChild("BackroomLayout");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="BackroomLayout";folder.Parent=model
 local rackParent
 local function part(name,size,offset,color)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+offset;p.Anchored=true;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Parent=rackParent or folder;return p
 end
 local wall=Color3.fromRGB(34,59,62)
 -- Stock occupies the front room; a six-stud doorway on the right leads into the office.
 part("OfficeDivider",Vector3.new(23,12,.5),Vector3.new(-4.5,6,dividerZ),wall)
 part("OfficeDoorSide",Vector3.new(3,12,.5),Vector3.new(14.5,6,dividerZ),wall)
 part("OfficeDoorHeader",Vector3.new(6,3,.5),Vector3.new(10,10.5,dividerZ),wall)
 local function sign(name,text,offset,color)
  local board=part(name,Vector3.new(7,1.6,.2),offset,Color3.fromRGB(17,31,38))
  local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(700,160);g.LightInfluence=0;g.Parent=board
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.Font=Enum.Font.GothamBold;t.TextSize=70;t.TextColor3=color;t.Parent=g
 end
 -- Raised clear of the shelf route guides that sit above each rack (StyleService ingredient guides).
 sign("StockRoomSign","INGREDIENTS",Vector3.new(-4,10.6,dividerZ-.35),Color3.fromRGB(126,238,205))
 sign("OfficeSign","OFFICE",Vector3.new(10,10.4,dividerZ-.35),Color3.fromRGB(255,213,139))
 local lamp=part("OfficeLamp",Vector3.new(5,.2,1),Vector3.new(0,10.8,dividerZ+7),Color3.fromRGB(255,216,164));lamp.Material=Enum.Material.Neon;lamp.CanCollide=false
 local light=Instance.new("PointLight");light.Name="ShopLight";light.Color=lamp.Color;light.Brightness=1.2;light.Range=22;light.Parent=lamp
 local stockLamp=part("StockCeilingLight",Vector3.new(8,.2,1),Vector3.new(-2,10.5,12),Color3.fromRGB(245,238,212));stockLamp.Material=Enum.Material.Neon;stockLamp.CanCollide=false
 local stockLight=Instance.new("PointLight");stockLight.Name="ShopLight";stockLight.Color=stockLamp.Color;stockLight.Brightness=.65;stockLight.Range=18;stockLight.Parent=stockLamp
 -- Compact ingredient pantry: lower pick bins retain their prompts and server validation.
 local steel=Color3.fromRGB(84,99,107);local shelf=Color3.fromRGB(150,157,152)
 for i,name in ipairs({"StockNoodles","StockRice","StockTea"}) do
  local x=-11+(i-1)*7.5
  local rackPivot=CFrame.new(origin+Vector3.new(x,.5,rackZ))
  rackParent=Instance.new("Model");rackParent.Name=name.."Rack";rackParent.Parent=folder
  rackParent.WorldPivot=rackPivot
  local function scaleBinPart(p)
   local relative=rackPivot:ToObjectSpace(p.CFrame)
   p.Size*=rackScale
   p.CFrame=rackPivot*CFrame.new(relative.Position*rackScale)*relative.Rotation
  end
  local bin=model:FindFirstChild(name)
  if bin then
   local delta=origin+Vector3.new(x,1.5,rackZ)-bin.Position
   bin.CFrame+=delta
   for _,child in bin:GetDescendants() do if child:IsA("BasePart") then child.CFrame+=delta end end
   -- Ingredient box visuals are siblings of the pick bin, not children of it.
   local icon=model:FindFirstChild(name.."Icon")
   if icon and icon:IsA("Model") then
    icon:PivotTo(icon:GetPivot()+delta)
    icon.WorldPivot=rackPivot
    icon:ScaleTo(icon:GetScale()*rackScale)
   end
   scaleBinPart(bin)
   for _,child in bin:GetDescendants() do if child:IsA("BasePart") then scaleBinPart(child) end end
  end
  for _,dx in ipairs({-3.5,3.5}) do for _,dz in ipairs({-1.7,1.7}) do
   local post=part("RackPost",Vector3.new(.22,6,.22),Vector3.new(x+dx,3.5,rackZ+dz),steel);post.Material=Enum.Material.Metal
  end end
  for _,y in ipairs({.65,3.6,6.5}) do
   local deck=part("RackShelf",Vector3.new(7.4,.18,3.7),Vector3.new(x,y,rackZ),shelf);deck.Material=Enum.Material.Metal
  end
  for n=1,3 do
   local bx=x+(n-2)*2.15
   if i==1 then
    local sack=part("RiceFlourSack",Vector3.new(1.7,2,2.1),Vector3.new(bx,4.7,rackZ),Color3.fromRGB(221,207,163));sack.Shape=Enum.PartType.Ball;sack.Material=Enum.Material.Fabric
    part("SackTie",Vector3.new(.65,.25,.65),Vector3.new(bx,5.65,rackZ),Color3.fromRGB(120,94,52))
   elseif i==2 then
    part("ProduceCrate",Vector3.new(1.95,.25,2.5),Vector3.new(bx,3.9,rackZ),Color3.fromRGB(88,123,64)).Material=Enum.Material.Wood
    for _,dz in ipairs({-1.15,1.15}) do part("CrateRim",Vector3.new(1.95,.7,.15),Vector3.new(bx,4.2,rackZ+dz),Color3.fromRGB(88,123,64)).Material=Enum.Material.Wood end
    for a=1,2 do for b=1,3 do
     local vegetable=part(n==1 and "Cabbage" or n==2 and "Tomato" or "Carrot",n==3 and Vector3.new(.3,1.1,.3) or Vector3.new(.65,.65,.65),Vector3.new(bx+(a-1.5)*.8,4.5,rackZ+(b-2)*.7),n==1 and Color3.fromRGB(116,173,66) or n==2 and Color3.fromRGB(213,66,44) or Color3.fromRGB(237,134,42));vegetable.Shape=Enum.PartType.Ball
    end end
   else
    local jar=part("TeaIngredientJar",Vector3.new(1.6,1.2,1.2),Vector3.new(bx,4.55,rackZ),Color3.fromRGB(147,91,43));jar.Shape=Enum.PartType.Cylinder;jar.CFrame=CFrame.new(jar.Position)*CFrame.Angles(0,0,math.pi/2)
    part("JarLid",Vector3.new(1.4,.15,1.4),Vector3.new(bx,5.4,rackZ),Color3.fromRGB(229,218,185))
   end
  end
  rackParent:ScaleTo(rackScale)
  rackParent=nil
 end
 -- Small receiving surface leaves the front aisle clear in the compact room.
 part("ReceivingBenchTop",Vector3.new(3,.25,2),Vector3.new(-13,2.7,11.5),Color3.fromRGB(157,165,163)).Material=Enum.Material.Metal
 for _,x in ipairs({-14.2,-11.8}) do part("ReceivingBenchLeg",Vector3.new(.25,2.1,1.6),Vector3.new(x,1.6,11.5),steel).Material=Enum.Material.Metal end
 -- Office furniture is kept away from the doorway and central access aisle.
 local cabinet=part("FilingCabinet",Vector3.new(3.2,4.8,2.2),Vector3.new(-13,2.9,backZ-4),Color3.fromRGB(99,112,117));cabinet.Material=Enum.Material.Metal
 for y=1.7,4.1,1.2 do
  part("DrawerFront",Vector3.new(2.9,1.05,.1),Vector3.new(-13,y,backZ-5.15),Color3.fromRGB(115,130,134))
  part("DrawerHandle",Vector3.new(.8,.12,.15),Vector3.new(-13,y,backZ-5.3),Color3.fromRGB(44,51,55))
 end
 part("OfficeNoticeBoard",Vector3.new(7,3.3,.18),Vector3.new(-6,7.2,backZ-.65),Color3.fromRGB(155,118,77)).Material=Enum.Material.Wood
 for n=1,3 do part("OfficePaper",Vector3.new(1.4,2,.04),Vector3.new(-9+n*1.8,7.2,backZ-.79),Color3.fromRGB(235,229,203)).CanCollide=false end
end

local function buildWorldActions(shop)
 local old=shop.Model:FindFirstChild("WorldActions");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="WorldActions";folder.Parent=shop.Model
 local floor=shop.Model.ShopFloor
 local function part(parent,name,size,pos,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.Parent=parent;return p
 end
 local function prompt(parent,name,actionText,objectText)
  local p=Instance.new("ProximityPrompt");p.Name=name.."Prompt";p.ActionText=actionText;p.ObjectText=objectText;p.KeyboardKeyCode=Enum.KeyCode.E;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.HoldDuration=.15;p.MaxActivationDistance=9;p.RequiresLineOfSight=false;p.Parent=parent;return p
 end
 local function signText(parent,name,text,color)
  for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
   local gui=Instance.new("SurfaceGui");gui.Name=name.."Gui";gui.Adornee=parent;gui.Face=face;gui.CanvasSize=Vector2.new(500,280);gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Parent=parent
   local label=Instance.new("TextLabel");label.Name=name.."Text";label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.BorderSizePixel=0;label.Text=text;label.TextColor3=color;label.TextStrokeTransparency=.55;label.Font=Enum.Font.GothamBlack;label.TextSize=66;label.TextWrapped=true;label.Parent=gui
  end
 end

 -- The owner upgrades from a real work desk in the backroom, not from the front pavement.
 local backroom=shop.Model:FindFirstChild("BackroomFloor") or floor
 local desk=Instance.new("Model");desk.Name="Upgrade";desk.Parent=folder
 local deskPos=Vector3.new(backroom.Position.X-4,backroom.Position.Y,shop.Model.BackroomWall.Position.Z-5)
 local top=part(desk,"DeskTop",Vector3.new(8,.35,3.6),deskPos+Vector3.new(0,3.2,0),Color3.fromRGB(125,86,52),Enum.Material.WoodPlanks)
 for _,x in ipairs({-3.4,3.4}) do part(desk,"DeskLeg",Vector3.new(.35,2.7,2.8),deskPos+Vector3.new(x,1.85,0),Color3.fromRGB(49,58,62),Enum.Material.Metal) end
 part(desk,"MonitorStand",Vector3.new(.35,.65,.3),deskPos+Vector3.new(0,3.65,.65),Color3.fromRGB(49,58,62),Enum.Material.Metal)
 part(desk,"MonitorBase",Vector3.new(1.5,.15,.8),deskPos+Vector3.new(0,3.45,.65),Color3.fromRGB(49,58,62),Enum.Material.Metal)
 part(desk,"Monitor",Vector3.new(3,1.9,.25),deskPos+Vector3.new(0,4.75,.65),Color3.fromRGB(25,39,47),Enum.Material.Metal)
 local screen=part(desk,"MonitorGlow",Vector3.new(2.7,1.6,.06),deskPos+Vector3.new(0,4.75,.49),Color3.fromRGB(101,167,178));screen.Material=Enum.Material.SmoothPlastic
 part(desk,"Keyboard",Vector3.new(2.2,.12,.7),deskPos+Vector3.new(0,3.45,-.7),Color3.fromRGB(40,49,55))
 for row=1,3 do for col=1,10 do part(desk,"Key",Vector3.new(.15,.035,.13),deskPos+Vector3.new(-1.05+col*.19,3.53,-1+row*.18),Color3.fromRGB(123,137,143)).CanCollide=false end end
 part(desk,"MousePad",Vector3.new(1.1,.04,1.1),deskPos+Vector3.new(2,3.4,-.6),Color3.fromRGB(42,73,77))
 local mouse=part(desk,"Mouse",Vector3.new(.4,.18,.65),deskPos+Vector3.new(2,3.51,-.6),Color3.fromRGB(170,177,179));mouse.Shape=Enum.PartType.Ball
 part(desk,"ComputerTower",Vector3.new(1.3,2.2,2),deskPos+Vector3.new(2.5,1.65,.3),Color3.fromRGB(39,47,53),Enum.Material.Metal)
 part(desk,"DeskLampStem",Vector3.new(.15,1.6,.15),deskPos+Vector3.new(-3,4.1,.5),Color3.fromRGB(47,57,60),Enum.Material.Metal)
 part(desk,"DeskLampShade",Vector3.new(1.2,.35,.9),deskPos+Vector3.new(-3,4.9,.3),Color3.fromRGB(227,186,96))
 local chair=Instance.new("Seat");chair.Name="OfficeChair";chair.Size=Vector3.new(2.3,.35,2.1);chair.CFrame=CFrame.new(deskPos+Vector3.new(0,2.1,-3.3))*CFrame.Angles(0,math.pi,0);chair.TopSurface=Enum.SurfaceType.Smooth;chair.BottomSurface=Enum.SurfaceType.Smooth;chair.Anchored=true;chair.Color=Color3.fromRGB(40,63,72);chair.Parent=desk
 part(desk,"ChairBack",Vector3.new(2.3,2.1,.35),deskPos+Vector3.new(0,3.2,-4.25),Color3.fromRGB(40,63,72))
 part(desk,"ChairStem",Vector3.new(.35,1.3,.35),deskPos+Vector3.new(0,1.3,-3.3),Color3.fromRGB(90,100,105),Enum.Material.Metal)
 for _,size in ipairs({Vector3.new(2.6,.18,.35),Vector3.new(.35,.18,2.6)}) do part(desk,"ChairBase",size,deskPos+Vector3.new(0,.65,-3.3),Color3.fromRGB(63,73,78),Enum.Material.Metal) end
 local lamp=Instance.new("PointLight");lamp.Color=Color3.fromRGB(255,199,101);lamp.Brightness=.65;lamp.Range=8;lamp.Parent=top
 signText(desk.MonitorGlow,"UpgradeDesk","UPGRADE\nDESK",Color3.fromRGB(46,44,35))
 local upgrade=prompt(top,"Upgrade","Open upgrades","WORK DESK")
 upgrade.Triggered:Connect(function(player)
  local pd=personal(player)
  if pd and pd.ShopId==shop.Id and shop.Owner==player and near(player,upgrade.Parent) then RS.MidnightNetwork.OpenPanel:FireClient(player,"Upgrade")
  else tell(player,"Only this kitchen's owner can upgrade here") end
 end)

 -- Applicants walk to the hiring sign beside the restaurant. The small green pad keeps the action discoverable.
 local hiring=Instance.new("Model");hiring.Name="CrewJoin";hiring.Parent=folder
 local sidePos=floor.Position+Vector3.new(-floor.Size.X/2-5,floor.Size.Y/2,-1)
 local pad=part(hiring,"HiringPad",Vector3.new(.25,6,6),sidePos+Vector3.new(0,.15,0),Color3.fromRGB(111,231,193),Enum.Material.Neon);pad.Shape=Enum.PartType.Cylinder;pad.CFrame=CFrame.new(pad.Position)*CFrame.Angles(0,0,math.rad(90));pad.CanCollide=false;pad.Transparency=.18
 part(hiring,"SignPost",Vector3.new(.45,4,.45),sidePos+Vector3.new(0,2,0),Color3.fromRGB(55,70,72),Enum.Material.Metal)
 local board=part(hiring,"HiringBoard",Vector3.new(5,2.8,.35),sidePos+Vector3.new(0,4.4,0),Color3.fromRGB(28,65,64),Enum.Material.Wood)
 signText(board,"CrewHiring","CREW WANTED\nJOIN HERE",Color3.fromRGB(143,255,218))
 local crew=prompt(board,"CrewJoin","Apply for crew","NOW HIRING")
 crew.Triggered:Connect(function(player)
  local pd=personal(player)
  if not pd or pd.ShopId==shop.Id then tell(player,"You already work here");return end
  local ok,msg=Service.Join(player,shop.Id);tell(player,msg or (ok and "Joined crew" or "Could not join"))
 end)
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
  local expansion=shop.Model:FindFirstChild("DiningExpansion");if expansion then expansion:Destroy() end
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
 theme(shop);refreshWorkers(shop);refreshDecor(shop);refreshExpansion(shop);updateOwnerBillboard(shop)
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
 updateOwnerBillboard(target);if old then updateOwnerBillboard(old) end
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
 if old then Inventory.Return(player,old);Inventory.CancelCooking(player,old);dropHeld(player,old);old.Members[player]=nil;old.Model:RemovePersistentPlayer(player);updateOwnerBillboard(old);Service.Sync(old) end
 pd.ShopId=0;pd.Held="";pd.Cooking="";pd.CookEnd=0
 player:SetAttribute("ShopId",0);player:SetAttribute("Role","Visitor")
 Service.SyncLobby(player);Service.Teleport(player)
 return true,"In the city. Open your own kitchen from Kitchen, or apply at a green NOW HIRING sign."
end
function Service.ReturnHome(player)
 local pd=personal(player);if not pd then return false,"Not ready" end
 local old=Service.Shops[pd.ShopId]
 if old and old.Owner==player then Service.Teleport(player);return true end
 local free
 for _,s in ipairs(Service.Shops) do if not s.Owner then free=s;break end end
 if not free then return false,"No vacant kitchens. Apply at a green NOW HIRING sign beside a restaurant." end
 if old then Inventory.Return(player,old);Inventory.CancelCooking(player,old);dropHeld(player,old);old.Members[player]=nil;old.Model:RemovePersistentPlayer(player);Service.Sync(old) end
 free.Owner=player;free.Members[player]=true;free.Model:AddPersistentPlayer(player);free.Locked=false;free.Phase="Ready";pd.ShopId=free.Id;pd.Held="";pd.Cooking="";pd.CookEnd=0
 player:SetAttribute("ShopId",free.Id);player:SetAttribute("Role","Owner")
 theme(free);refreshWorkers(free);refreshDecor(free);refreshExpansion(free);updateOwnerBillboard(free);Service.Teleport(player);Service.Sync(free)
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
 if free then theme(free);refreshWorkers(free);refreshDecor(free);refreshExpansion(free);updateOwnerBillboard(free);Service.Sync(free) else Service.SyncLobby(player) end
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
 if action=="Lock" then if not shop or shop.Owner~=player then return false,"Owner only" end;shop.Locked=not shop.Locked;updateOwnerBillboard(shop);return true,shop.Locked and "Shop locked" or "Shop open to crew" end
 if action=="Kick" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local member=Players:GetPlayerByUserId(tonumber(id) or 0)
  if not member or member==player or not shop.Members[member] then return false,"Crew member not found" end
  shop.Kicked=shop.Kicked or {}
  shop.Kicked[member.UserId]={By=player.UserId,Until=os.clock()+300}
  local ok,msg=Service.VisitCity(member)
  if ok then tell(member,"You were removed from "..player.DisplayName.."'s kitchen. Open your own kitchen, or apply at another green NOW HIRING sign.") end
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
  refreshDecor(shop);refreshExpansion(shop);Service.SyncPlayer(player);return ok,message
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
-- Decorative equipment per ingredient kit: 1 noodle pot (A/D), 2 wok burner (B/E), 3 tea bar (C/F).
-- The menu dish sits front-left (StyleRenderer); gear uses the right half, the back strip and the front panel.
local function buildStationGear(station,kit,recipe)
 local model=station.Parent
 local old=model:FindFirstChild("StationGear_"..station.Name)
 local recipeId=recipe and recipe.Id or ""
 if old and old:GetAttribute("RecipeId")==recipeId then return end
 if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="StationGear_"..station.Name;folder.Parent=model
 folder:SetAttribute("RecipeId",recipeId)
 local shape=recipe and recipe.Shape or ""
 local gear=({Croissant="Oven",Cookies="Oven",Pizza="Oven",Roast="Oven",Burger="Grill",HotDog="Grill",Chicken="Grill",Taco="Grill",Sandwich="Prep",Sushi="Prep",Salad="Prep",Dumplings="Steamer",Mug="Coffee",Soda="Blender",Noodles="Pot",Soup="Pot",Rice="Wok",Cup="Tea"})[shape] or ({"Pot","Wok","Tea"})[kit]
 if recipeId=="BK_PAD_THAI" then gear="Wok" end
 if recipeId:find("CHICKEN_RICE",1,true) or recipeId=="SIGNATURE_RICE" or recipeId=="OC_RICE" then gear="RiceCooker" end
 if recipeId=="BG_JASMINE" then gear="Tea" end
 folder:SetAttribute("Equipment",gear)
 local top=station.Size.Y/2+.12
 local function at(x,y,z) return station.CFrame*CFrame.new(x,top+y,z) end
 local function p(name,size,cf,color,material,shape)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.CFrame=cf;a.Color=color;a.Material=material or Enum.Material.SmoothPlastic
  a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.CastShadow=false;if shape then a.Shape=shape end;a.Parent=folder;return a
 end
 local function cyl(name,height,diameter,cf,color,material) return p(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,Enum.PartType.Cylinder) end
 local function lens(name,size,cf,color,material) local a=p(name,size,cf,color,material);local m=Instance.new("SpecialMesh");m.MeshType=Enum.MeshType.Sphere;m.Parent=a;return a end
 local steel,dark=Color3.fromRGB(100,113,127),Color3.fromRGB(42,44,50)
 local splash=({Color3.fromRGB(145,158,149),Color3.fromRGB(154,86,67),Color3.fromRGB(70,137,123)})[kit]
 p("Backsplash",Vector3.new(station.Size.X,1.8,.1),at(0,.9,station.Size.Z/2-.05),splash,Enum.Material.CeramicTiles)
 p("KickPlate",Vector3.new(station.Size.X-.2,.35,.06),station.CFrame*CFrame.new(0,-station.Size.Y/2+.25,-station.Size.Z/2-.03),dark,Enum.Material.Metal)
 if kit==1 or kit==2 then
  for i=-1,1 do p("Knob",Vector3.new(.14,.28,.28),station.CFrame*CFrame.new(i*.6,-.85,-station.Size.Z/2-.07)*CFrame.Angles(0,math.rad(90),0),dark,Enum.Material.Metal,Enum.PartType.Cylinder) end
 end
 if gear=="Oven" then
  p("OvenBody",Vector3.new(1.8,1.45,1.55),at(.95,.73,.3),steel,Enum.Material.Metal)
  p("OvenDoor",Vector3.new(1.5,.9,.08),at(.95,.68,-.51),dark)
  local glass=p("OvenWindow",Vector3.new(1.2,.55,.06),at(.95,.65,-.57),Color3.fromRGB(117,69,31),Enum.Material.Glass);glass.Transparency=.2
  p("OvenHandle",Vector3.new(1,.1,.12),at(.95,1.18,-.61),steel,Enum.Material.Metal)
  for _,x in {.45,1.45} do cyl("OvenDial",.09,.18,at(x,1.43,.3),dark) end
  p("BakingTray",Vector3.new(1.25,.08,.55),at(-.9,.05,1),steel,Enum.Material.Metal)
 elseif gear=="Grill" then
  p("GrillBase",Vector3.new(1.8,.45,1.8),at(.95,.23,.25),steel,Enum.Material.Metal)
  p("Griddle",Vector3.new(1.65,.1,1.6),at(.95,.5,.25),dark,Enum.Material.Metal)
  for i=0,5 do p("GrillRidge",Vector3.new(.07,.06,1.5),at(.3+i*.26,.57,.25),steel,Enum.Material.Metal) end
  p("SpatulaBlade",Vector3.new(.4,.05,.5),at(-.7,.08,1),steel,Enum.Material.Metal)
  p("SpatulaHandle",Vector3.new(.1,.07,.6),at(-.7,.1,.5),Color3.fromRGB(102,66,39),Enum.Material.Wood)
 elseif gear=="Prep" then
  p("CuttingBoard",Vector3.new(1.8,.15,1.75),at(.95,.08,.25),Color3.fromRGB(174,123,67),Enum.Material.Wood)
  p("KnifeBlade",Vector3.new(.08,.25,.65),at(1.55,.26,.4),steel,Enum.Material.Metal)
  p("KnifeHandle",Vector3.new(.13,.15,.35),at(1.55,.22,-.1),dark)
  for i=1,3 do lens("IngredientBowl",Vector3.new(.5,.25,.5),at(-1.7+i*.6,.15,1),({Color3.fromRGB(93,151,74),Color3.fromRGB(202,88,60),Color3.fromRGB(228,205,156)})[i]) end
 elseif gear=="Steamer" or gear=="RiceCooker" then
  local bamboo=Color3.fromRGB(177,128,71)
  cyl("CookerBase",.18,1.65,at(.95,.09,.25),dark,Enum.Material.Metal)
  cyl(gear=="Steamer" and "BambooBasket" or "RiceCooker",.85,1.5,at(.95,.61,.25),gear=="Steamer" and bamboo or steel,gear=="Steamer" and Enum.Material.Wood or Enum.Material.Metal)
  cyl("CookerLid",.14,1.6,at(.95,1.12,.25),gear=="Steamer" and bamboo or dark)
  p("LidHandle",Vector3.new(.45,.18,.18),at(.95,1.27,.25),dark)
  if gear=="Steamer" then for i=-2,2 do p("BasketSlat",Vector3.new(.06,.04,1.1),at(.95+i*.22,1.21,.25),Color3.fromRGB(101,70,40),Enum.Material.Wood) end
  else p("CookerControl",Vector3.new(.4,.2,.05),at(.95,.5,-.53),Color3.fromRGB(66,146,125)) end
 elseif gear=="Coffee" then
  p("CoffeeMachine",Vector3.new(1.8,1.3,.9),at(.95,.8,.75),steel,Enum.Material.Metal)
  p("CoffeePanel",Vector3.new(1.5,.45,.08),at(.95,1.15,.26),dark)
  p("DripTray",Vector3.new(1.8,.12,1.5),at(.95,.06,.35),dark,Enum.Material.Metal)
  for _,x in {.55,1.3} do
   p("CoffeeSpout",Vector3.new(.12,.25,.25),at(x,.75,.2),steel,Enum.Material.Metal)
   cyl("CoffeeCup",.35,.4,at(x,.3,.1),Color3.fromRGB(230,211,179))
  end
 elseif gear=="Blender" then
  cyl("BlenderBase",.35,1,at(.95,.18,.4),dark)
  local jug=cyl("BlenderJug",1.1,.9,at(.95,.92,.4),Color3.fromRGB(177,215,219),Enum.Material.Glass);jug.Transparency=.45
  cyl("BlenderDrink",.6,.72,at(.95,.7,.4),Color3.fromRGB(unpack(recipe.Color)))
  cyl("BlenderLid",.12,1,at(.95,1.53,.4),dark)
  p("JugHandle",Vector3.new(.15,.6,.25),at(1.56,1,.4),steel)
 elseif gear=="Pot" then
  cyl("Burner",.14,1.7,at(1,.07,.2),dark,Enum.Material.Metal)
  cyl("StockPot",1,1.35,at(1,.64,.2),steel,Enum.Material.Metal)
  cyl("PotRim",.08,1.45,at(1,1.16,.2),steel:Lerp(Color3.new(1,1,1),.2),Enum.Material.Metal)
  cyl("Broth",.04,1.2,at(1,1.1,.2),Color3.fromRGB(222,166,88))
  for i,angle in {15,75,130} do p("Noodle",Vector3.new(.7,.05,.09),at(1+math.cos(math.rad(angle))*.2,1.13,.2+math.sin(math.rad(angle))*.2)*CFrame.Angles(0,math.rad(angle*i),0),Color3.fromRGB(246,224,150)) end
  for _,x in {-.78,.78} do p("PotHandle",Vector3.new(.3,.12,.18),at(1+x,.95,.2),steel,Enum.Material.Metal) end
  local source=p("SteamSource",Vector3.new(.1,.1,.1),at(1,1.15,.2),Color3.new(1,1,1));source.Transparency=1
  local steam=Instance.new("ParticleEmitter");steam.Name="PotSteam";steam.Texture="rbxasset://textures/particles/smoke_main.dds";steam.Rate=3
  steam.Lifetime=NumberRange.new(1.5,2.5);steam.Speed=NumberRange.new(1,2);steam.SpreadAngle=Vector2.new(15,15)
  steam.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.4),NumberSequenceKeypoint.new(1,1.4)});steam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.7),NumberSequenceKeypoint.new(1,1)})
  steam.LightEmission=.2;steam.Parent=source
  cyl("UtensilCup",.6,.5,at(-1.55,.3,1.05),steel,Enum.Material.Metal)
  for i,x in {-.1,.1,0} do p("Ladle",Vector3.new(.06,1.1,.06),at(-1.55+x,.85,1.05+(i==3 and .1 or -.05))*CFrame.Angles(0,0,math.rad(x*60)),dark,Enum.Material.Metal) end
  for i=0,2 do cyl("Bowl",.12,.8,at(-.55,.06+i*.13,1.05),Color3.fromRGB(242,240,232)) end
 elseif gear=="Wok" then
  cyl("Grate",.1,1.5,at(1,.05,.2),dark,Enum.Material.Metal)
  for i=0,7 do
   local a=i*math.pi/4
   local flame=p("Flame",Vector3.new(.16,.3,.16),at(1+math.cos(a)*.6,.22,.2+math.sin(a)*.55),Color3.fromRGB(255,140,40),Enum.Material.Neon)
   if i==0 then local glow=Instance.new("PointLight");glow.Color=Color3.fromRGB(255,150,60);glow.Brightness=1;glow.Range=5;glow.Parent=flame end
  end
  lens("Wok",Vector3.new(1.9,.5,1.9),at(1,.5,.2),dark,Enum.Material.Metal)
  cyl("WokRim",.05,1.92,at(1,.5,.2),Color3.fromRGB(90,94,102),Enum.Material.Metal)
  lens("WokRice",Vector3.new(1.5,.42,1.5),at(1,.68,.2),Color3.fromRGB(232,186,96))
  for i,color in {Color3.fromRGB(110,180,80),Color3.fromRGB(240,120,60),Color3.fromRGB(250,230,140)} do p("WokBit",Vector3.new(.16,.16,.16),at(1+(i-2)*.3,.8,.2+(i%2)*.2),color,nil,Enum.PartType.Ball) end
  p("WokHandle",Vector3.new(.14,.14,1),at(1,.72,-1.15)*CFrame.Angles(math.rad(-12),0,0),Color3.fromRGB(70,46,32),Enum.Material.Wood)
  p("Spatula",Vector3.new(.07,1.1,.07),at(1.45,1.05,.35)*CFrame.Angles(0,0,math.rad(-35)),dark,Enum.Material.Metal)
  for i,color in {Color3.fromRGB(60,36,24),Color3.fromRGB(200,50,40),Color3.fromRGB(230,190,70)} do
   cyl("SauceBottle",.7,.3,at(-1.75+i*.38,.35,1.1),color,Enum.Material.Glass)
   cyl("BottleCap",.12,.2,at(-1.75+i*.38,.76,1.1),Color3.fromRGB(240,240,236))
  end
 else
  for i,tea in {Color3.fromRGB(228,139,59),Color3.fromRGB(150,200,120)} do
   local x=.45+(i-1)*1.05
   p("DispenserBase",Vector3.new(.9,.25,.9),at(x,.12,.85),dark,Enum.Material.Metal)
   local tank=cyl("DispenserTank",1.3,.85,at(x,.9,.85),tea,Enum.Material.Glass);tank.Transparency=.25
   cyl("DispenserLid",.12,.9,at(x,1.6,.85),steel,Enum.Material.Metal)
   p("Tap",Vector3.new(.14,.18,.3),at(x,.4,.33),steel,Enum.Material.Metal)
  end
  for i=0,3 do local cup=cyl("CupStack",.22,.55,at(1.5,.11+i*.2,-.85),Color3.fromRGB(240,244,246),Enum.Material.Glass);cup.Transparency=.2 end
  cyl("Shaker",.7,.42,at(.55,.35,-.85),steel,Enum.Material.Metal)
  cyl("StrawCup",.5,.4,at(-1.6,.25,1.1),Color3.fromRGB(60,64,72))
  for i,color in {Color3.fromRGB(255,90,150),Color3.fromRGB(90,220,255),Color3.fromRGB(255,214,92)} do p("Straw",Vector3.new(.05,.8,.05),at(-1.6+(i-2)*.08,.7,1.1)*CFrame.Angles(0,0,math.rad((i-2)*12)),color) end
  p("BarFront",Vector3.new(station.Size.X-.2,1.2,.06),station.CFrame*CFrame.new(0,-.7,-station.Size.Z/2-.03),Color3.fromRGB(150,98,60),Enum.Material.Wood)
 end
end
function Service.RefreshStationGear(model,themeId)
 for index,id in Recipes.FullMenuForModel(model,themeId) do
  local station=model:FindFirstChild(Recipes.Stations[index])
  if station then buildStationGear(station,Recipes.Slot(id),Recipes.Get(id)) end
 end
end
local function buildCookingStations(model)
 -- User-selected midpoint between original warm lights and the softer visual-polish preset.
 -- Preserve ShopLight identity for BLACKOUT/SHADOW control.
 for _,fixture in model:GetChildren() do
  if fixture.Name=="CeilingLamp" then
   local light=fixture:FindFirstChildOfClass("PointLight")
   if light then
    light.Brightness=1.35;light.Range=21
    light.Color=Color3.fromRGB(255,213,164):Lerp(Color3.fromRGB(255,230,201),.5)
   end
  end
 end
 local cooktops={}
 for _,p in model:GetChildren() do if p.Name=="Cooktop" and p:IsA("BasePart") then table.insert(cooktops,p) end end
 table.sort(cooktops,function(a,b)return a.Position.X<b.Position.X end)
 for index=4,6 do
  local source=model[Recipes.Stations[index-3]]
  local station=source:Clone();station.Name=Recipes.Stations[index]
  station.Cook.Enabled=false;station.Parent=model
 end
 local floor,wall=model.ShopFloor,model.BackWall
 local rear=wall.Position.Z-wall.Size.Z/2-.15
 for index,name in Recipes.Stations do
  local station=model[name]
  station.Size=Vector3.new(4.1,station.Size.Y,3)
  station.CFrame=CFrame.new(floor.Position.X-13.25+(index-1)*4.4,station.Position.Y,rear-station.Size.Z/2)*station.CFrame.Rotation
  local top=cooktops[index]
  if not top and cooktops[index-3] then top=cooktops[index-3]:Clone();top.Parent=model end
  if top then
   top.Size=Vector3.new(station.Size.X-.4,.12,station.Size.Z-.4)
   top.CFrame=station.CFrame*CFrame.new(0,station.Size.Y/2+.06,0)
   top:SetAttribute("CookingStation",name)
  end
  buildStationGear(station,(index-1)%3+1)
 end
end
-- Street-facing decor: striped awning, neon frame around the name board and chase bulbs (animated on the client).
local function buildStorefront(model)
 local old=model:FindFirstChild("Storefront");if old then old:Destroy() end
 local sign,roof=model:FindFirstChild("MIDNIGHT • KITCHEN"),model:FindFirstChild("Roof")
 local posts={};for _,c in model:GetChildren() do if c.Name=="FrontPost" and c:IsA("BasePart") then table.insert(posts,c) end end
 table.sort(posts,function(a,b) return a.Position.X<b.Position.X end)
 if not sign or not roof or #posts<2 then return end
 local folder=Instance.new("Folder");folder.Name="Storefront";folder.Parent=model
 local function part(name,size,cf,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Parent=folder;return p
 end
 local front=sign.Position.Z-sign.Size.Z/2
 local left,right=posts[1].Position.X,posts[#posts].Position.X
 local cream,coral=Color3.fromRGB(255,238,206),Color3.fromRGB(236,88,96)
 local slats,width,depth,drop=8,right-left-1,4,1.4
 local top=sign.Position.Y-sign.Size.Y/2-.2
 local slope=math.atan2(drop,depth);local length=math.sqrt(depth*depth+drop*drop);local w=width/slats
 for i=0,slats-1 do
  local x=left+.5+w*(i+.5);local color=i%2==0 and coral or cream
  part("AwningSlat",Vector3.new(w,.25,length),CFrame.new(x,top-drop/2,front-depth/2)*CFrame.Angles(-slope,0,0),color,Enum.Material.Fabric)
  part("AwningValance",Vector3.new(w,.8,.2),CFrame.new(x,top-drop-.4,front-depth),color,Enum.Material.Fabric)
 end
 -- Counter cameras sit under the awning; the client fades it while the camera is inside this box.
 folder:SetAttribute("AwningCenter",Vector3.new((left+right)/2,top-drop/2-2,front-(depth+8)/2+.5))
 folder:SetAttribute("AwningSize",Vector3.new(width+4,drop+6,depth+9))
 local glow=Instance.new("PointLight");glow.Name="ShopLight";glow.Color=Color3.fromRGB(255,206,150);glow.Brightness=1.2;glow.Range=14
 glow.Parent=part("AwningGlow",Vector3.new(.2,.2,.2),CFrame.new((left+right)/2,top-drop-.2,front-depth+.6),cream)
 folder.AwningGlow.Transparency=1
 local pink=Color3.fromRGB(255,92,170);local sx,sy=sign.Size.X/2-.15,sign.Size.Y/2-.15;local c=sign.Position
 for _,bar in {{Vector3.new(sx*2+.25,.25,.25),Vector3.new(0,sy,0)},{Vector3.new(sx*2+.25,.25,.25),Vector3.new(0,-sy,0)},{Vector3.new(.25,sy*2,.25),Vector3.new(-sx,0,0)},{Vector3.new(.25,sy*2,.25),Vector3.new(sx,0,0)}} do
  part("NeonFrame",bar[1],CFrame.new(c.X+bar[2].X,c.Y+bar[2].Y,front-.15),pink,Enum.Material.Neon)
 end
 -- Bulb path: up the left post, across the roof edge, down the right post.
 local points={}
 local postTop=posts[1].Position.Y+posts[1].Size.Y/2
 local edgeZ,edgeY=roof.Position.Z-roof.Size.Z/2-.2,roof.Position.Y
 for y=posts[1].Position.Y-posts[1].Size.Y/2+1.5,postTop-.5,1.5 do table.insert(points,Vector3.new(left,y,posts[1].Position.Z-.45)) end
 local x0,x1=roof.Position.X-roof.Size.X/2+.5,roof.Position.X+roof.Size.X/2-.5
 local count=math.floor((x1-x0)/1.5)
 for i=0,count do table.insert(points,Vector3.new(x0+(x1-x0)*i/count,edgeY,edgeZ)) end
 for y=postTop-.5,posts[1].Position.Y-posts[1].Size.Y/2+1.5,-1.5 do table.insert(points,Vector3.new(right,y,posts[#posts].Position.Z-.45)) end
 for i,pos in points do
  local bulb=part("ChaseBulb",Vector3.new(.5,.5,.5),CFrame.new(pos),Color3.fromRGB(255,196,120),Enum.Material.Neon)
  bulb.Shape=Enum.PartType.Ball;bulb:SetAttribute("ChaseIndex",i)
 end
end
function Service.Start()
 Experience.Start(Service)
 Inventory.Start(Service)
 Quests.Start(Service)
 for i,model in ipairs(workspace.MidnightShops:GetChildren()) do
  if model:IsA("Model") then
   local id=model:GetAttribute("ShopId")
   local s={Id=id,Model=model,Members={},Owner=nil,Phase="Ready",Time=300,Cash=0,Served=0,Strikes=0,Combo=0,Reward=0,Order="",Event="",EventLeft=1,Patience=1,Prepared="",Token=0,Locked=false}
   Service.Shops[id]=s;buildCookingStations(model);buildBackroom(s);buildWorldActions(s);buildStorefront(model);require(script.Parent.City).DressTrees(model,"TreeTrunk","TreeCrown");updateOwnerBillboard(s);Inventory.Bind(s)
   local floor,radio,ward=model.ShopFloor,model.Radio,model.Ward
   local counter=model.CounterTop
   local inward=Vector3.new(floor.Position.X-counter.Position.X,0,floor.Position.Z-counter.Position.Z).Unit
   local behind=radio.Position+inward*3
   ward.Size=Vector3.new(2,.15,2);ward.Position=Vector3.new(behind.X,floor.Position.Y+floor.Size.Y/2+.075,behind.Z)
   local wardPrompt=ward:FindFirstChildWhichIsA("ProximityPrompt");if wardPrompt then wardPrompt.ObjectText="Shadow behind radio";wardPrompt.ActionText="Banish Shadow" end
   bind(s,"StartShift","Start",function(p) Service.StartShift(p) end)
   for n,name in ipairs(Recipes.Stations) do bind(s,name,"Cook",function(p)
    local food=shopFoods(s)[n]
    if not food or not table.find(shopFoods(s),food) then tell(p,"This cooking station is locked");return end
    cook(p,s,food)
   end) end
   bind(s,"Serve","Serve",function(p)
    if s.Phase~="Playing" or s.CustomerStage~="Ordering" then tell(p,"Wait for the next customer");return end
    if s.Event=="SHADOW" then tell(p,"Banish the shadow behind the radio first");return end
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
    -- Customer patience is frozen while an interruption is active or the owner is still in the guide.
    local tick=math.clamp(now-(s.LastPatienceTick or now),0,1);s.LastPatienceTick=now
    if s.CustomerStage=="Ordering" and (s.Event~="" or Experience.TutorialActive(s)) then s.Deadline+=tick end
    if now>=s.Ends then finish(s,true) else
     if s.Event~="" then
      s.EventLeft=s.Event=="SHADOW" and 1 or math.clamp((s.EventDeadline-now)/Catalog.Get("EventSeconds"),0,1)
      if s.Event=="SHADOW" then shadowLights(s,now) end
      local d=shopData(s)
      if d and d.Workers.Technician and now-s.EventBegan>=Catalog.Get("WorkerTechSeconds") then clearEvent(s)
      elseif s.Event~="SHADOW" and now>=s.EventDeadline then clearEvent(s);strike(s) end
     else
      s.Patience=math.clamp((s.Deadline-now)/orderSeconds(s),0,1)
      if s.CustomerStage=="Ordering" and now>=s.Deadline then Experience.Missed(s);strike(s);if s.Phase=="Playing" then nextOrder(s) end end
      -- No interruptions during the whole guide (including the Upgrade Desk step) or in the final stretch,
      -- so an unbanished SHADOW cannot void the last held dish when the shift ends.
      local closingStretch=s.Ends-now<Catalog.Get("EventSeconds")+10
      if s.Phase=="Playing" and s.CustomerStage=="Ordering" and not Service.OrderUnavailable(s) and not Experience.TutorialActive(s) and not closingStretch and now>=s.NextEvent then
       s.EventIndex=s.EventIndex%3+1;s.Event=({"BLACKOUT","WHISPER","SHADOW"})[s.EventIndex]
       s.EventBegan=now;s.EventDeadline=now+Catalog.Get("EventSeconds");s.NextEvent=now+Catalog.Get("EventInterval");cue(s,"Danger")
       if s.Event=="BLACKOUT" then lights(s,false) elseif s.Event=="SHADOW" then customer(s,true);shadowLights(s,now) end
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
