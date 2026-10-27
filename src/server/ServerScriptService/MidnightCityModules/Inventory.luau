
local Profiles=require(script.Parent.Profiles)
local Catalog=require(script.Parent.Catalog)
local RS=game:GetService("ReplicatedStorage")
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local Bundles=require(script.Parent.MealBundles)
local Inventory={Service=nil}
local function amount(key,default) return math.max(0,math.floor(Catalog.Get(key,default))) end
Inventory.Foods={
 {Id="NOODLES",Key="Noodles",Name="Prep kits",Route="A",Bin="StockNoodles",Station="NoodleStation",Color={238,188,82}},
 {Id="FRIED RICE",Key="Rice",Name="Kitchen kits",Route="B",Bin="StockRice",Station="RiceStation",Color={225,133,71}},
 {Id="THAI TEA",Key="Tea",Name="Drink kits",Route="C",Bin="StockTea",Station="TeaStation",Color={94,195,158}}
}
function Inventory.Initial()
 local front,back={},{}
 for _,f in ipairs(Inventory.Foods) do front[f.Id]=amount("StartingFrontStock",3);back[f.Id]=amount("StartingBackStock",6) end
 return {Front=front,Back=back,Transit={}}
end
local function ensure(profile)
 if type(profile.Shop.Stock)~="table" then profile.Shop.Stock=Inventory.Initial() end
 local stock=profile.Shop.Stock
 stock.Front=stock.Front or {};stock.Back=stock.Back or {};stock.Transit=stock.Transit or {}
 for _,f in ipairs(Inventory.Foods) do if stock.Front[f.Id]==nil then stock.Front[f.Id]=3 end;if stock.Back[f.Id]==nil then stock.Back[f.Id]=6 end end
 return stock
end
function Inventory.Data(shop)
 local d=shop and shop.Owner and Profiles.Get(shop.Owner)
 return d and ensure(d)
end
function Inventory.Find(food) for _,f in ipairs(Inventory.Foods) do if f.Id==food then return f end end end
function Inventory.RecipeForStock(shop,food)
 local slot=Recipes.Slot(food)
 if not slot then return food end
 local menu=Recipes.MenuForModel(shop.Model,shop.Model:GetAttribute("AppliedStyleTheme") or "")
 return Bundles.StationFood(shop,slot,menu[slot] or food)
end
local function bagRecipe(shop,bag)
 local recipe=bag and Recipes.Get(bag.RecipeId)
 if recipe and recipe.StockId==bag.Food then return recipe.Id end
 return bag and Inventory.RecipeForStock(shop,bag.Food) or ""
end
function Inventory.Bag(player,shop)
 local stock=Inventory.Data(shop)
 return stock and stock.Transit[tostring(player.UserId)]
end
function Inventory.Available(shop,food)
 food=Recipes.StockId(food)
 local stock=Inventory.Data(shop);if not stock then return 0 end
 local n=(stock.Front[food] or 0)+(stock.Back[food] or 0)
 for _,bag in pairs(stock.Transit) do if bag.Food==food and bag.Mode=="Backroom" then n+=bag.Quantity end end
 return n
end
function Inventory.HasStock(shop)
 for _,f in ipairs(Inventory.Foods) do if Inventory.Available(shop,f.Id)>0 then return true end end
 return false
end
local function near(player,part,range)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root and part and (root.Position-part.Position).Magnitude<=(range or 11) and not player:GetAttribute("InTransit")
end
-- Mall deliveries can hold several kit types; older single-crate bags only have Food/Quantity.
local function bagItems(bag)
 if type(bag.Items)=="table" then return bag.Items end
 return {[bag.Food]=bag.Quantity or 0}
end
local function storeBag(stock,bag)
 for food,n in pairs(bagItems(bag)) do if Inventory.Find(food) then stock.Back[food]+=math.max(0,n) end end
end
function Inventory.Recover(player)
 Profiles.Mutate(player,function(d)
  local stock=ensure(d)
  for _,bag in pairs(stock.Transit) do storeBag(stock,bag) end
  stock.Transit={};return true
 end)
end
function Inventory.Consume(shop,food)
 food=Recipes.StockId(food)
 if not Inventory.Find(food) or not shop or not shop.Owner then return false end
 local ok=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d)
  if stock.Front[food]<=0 then return false,"Front stock is empty" end
  stock.Front[food]-=1;return true
 end)
 return ok
end
function Inventory.Refund(shop,food)
 food=Recipes.StockId(food)
 if not Inventory.Find(food) or not shop or not shop.Owner then return end
 Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local cap=math.max(1,amount("FrontStockCapacity",6))
  if stock.Front[food]<cap then stock.Front[food]+=1 else stock.Back[food]+=1 end
  return true
 end)
end
function Inventory.CancelCooking(player,shop)
 local pd=Inventory.Service.PlayerData[player]
 if not pd then return end
 if pd.CookingConsumed and pd.CookingConsumed~="" then Inventory.Refund(shop,pd.CookingConsumed);pd.CookingConsumed="" end
end
function Inventory.Visual(player,shop)
 local char=player.Character;if not char then return end
 local bag=Inventory.Bag(player,shop)
 local old=char:FindFirstChild("SupplyCrate")
 local recipeId=bagRecipe(shop,bag)
 local key=bag and bag.Food..":"..bag.Quantity..":"..bag.Mode..":"..recipeId or ""
 if old and old:GetAttribute("BagKey")==key then return end
 if old then old:Destroy() end
 if not bag then return end
 local root=char:FindFirstChild("HumanoidRootPart");if not root then return end
 local model=Instance.new("Model");model.Name="SupplyCrate";model:SetAttribute("BagKey",key);model.Parent=char
 local f=Inventory.Find(bag.Food)
 local body=Instance.new("Part");body.Name="Box";body.Size=Vector3.new(1.8,1.45,1.35);body.Color=Color3.fromRGB(159,116,68);body.Material=Enum.Material.Wood;body.CanCollide=false;body.Massless=true;body.CFrame=root.CFrame*CFrame.new(0,-.15,-1.7);body.Parent=model
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=body;w.Parent=body
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(320,200);g.Parent=body
 local recipe=Recipes.Get(recipeId)
 local t=Instance.new("TextLabel");t.Name="IngredientLabel";t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(unpack(f.Color));t.Text=bag.Mode=="Delivery" and ("MALL SUPPLIES\n"..(bag.Crates or 1).." CRATE(S)") or string.upper(f.Name).."\n"..(recipe and recipe.Name or "Ingredients").."\n"..bag.Quantity;t.TextColor3=Color3.fromRGB(26,37,42);t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Parent=g
end
function Inventory.Return(player,shop)
 if not Inventory.Bag(player,shop) or not shop.Owner then return end
 Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local bag=stock.Transit[key]
  if bag then storeBag(stock,bag);stock.Transit[key]=nil end
  return true
 end)
 Inventory.Visual(player,shop)
end
function Inventory.Take(player,shop,food)
 food=Recipes.StockId(food)
 local f=Inventory.Find(food);local pd=Inventory.Service.PlayerData[player]
 if not f or not shop or not shop.Owner or not pd or not shop.Members[player] then return false,"Join a kitchen first" end
 local bin=shop.Model:FindFirstChild(f.Bin)
 if not near(player,bin) then return false,"Go to this ingredient bin in the backroom" end
 local bag=Inventory.Bag(player,shop)
 if bag then
  if bag.Mode=="Delivery" then return Inventory.Deliver(player,shop,food) end
  return false,"Carry this crate to the matching cooking station"
 end
 if pd.Held~="" or pd.Cooking~="" then return false,"Empty your hands first" end
 local orderRecipe=Recipes.Get(shop.Order)
 if require(script.Parent.Experience).Training(shop) and orderRecipe and orderRecipe.StockId~=food then
  local station=string.char(64+(orderRecipe.CookingSlot or orderRecipe.Slot))
  return false,"Wrong ingredients for "..orderRecipe.Name..". Follow the order icon to STATION "..station.."."
 end
 local recipeId=Inventory.RecipeForStock(shop,food)
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId)
  if stock.Transit[key] then return false,"Already carrying a crate" end
  local reserved=0;for _,b in pairs(stock.Transit) do if b.Food==food and b.Mode=="Backroom" then reserved+=b.Quantity end end
  local room=math.max(0,math.max(1,amount("FrontStockCapacity",6))-stock.Front[food]-reserved)
  local quantity=math.min(math.max(1,amount("StockCarryQuantity",3)),stock.Back[food],room)
  if quantity<=0 then return false,stock.Back[food]<=0 and "Backroom empty. Buy a crate at the mall." or "Front stock is full or already being refilled" end
  stock.Back[food]-=quantity;stock.Transit[key]={Food=food,RecipeId=recipeId,Quantity=quantity,Mode="Backroom"};return true,"Take "..Recipes.Get(recipeId).Name.." ingredients ("..f.Name..") to STATION "..string.char(64+Recipes.CookingSlot(recipeId))
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Restock(player,shop,food)
 food=Recipes.StockId(food)
 local bag=Inventory.Bag(player,shop);local f=Inventory.Find(food)
 if not bag then return false,"No crate" end
 if bag.Food~=food then return false,"Use the "..Inventory.Find(bag.Food).Name.." station" end
 if bag.Mode=="Delivery" then return false,"Deliver purchases to the backroom first" end
 local matching=false
 for _,name in Recipes.Stations do
  local station=shop.Model:FindFirstChild(name)
  local selected=station and Recipes.Get(station:GetAttribute("SelectedRecipe"))
  if selected and selected.StockId==food and station:GetAttribute("Unlocked")==true and near(player,station,7) then matching=true;break end
 end
 if not matching then return false,"Go to an unlocked matching cooking station" end
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local b=stock.Transit[key]
  if not b or b.Food~=food or b.Mode~="Backroom" then return false,"Crate unavailable" end
  local quantity=math.min(b.Quantity,math.max(0,math.max(1,amount("FrontStockCapacity",6))-stock.Front[food]))
  stock.Front[food]+=quantity;stock.Back[food]+=b.Quantity-quantity;stock.Transit[key]=nil
  return true,"Front stock refilled +"..quantity
 end)
 if ok then
  require(script.Parent.Experience).Goal(shop,"Refills",player);task.spawn(require(script.Parent.Quests).Track,player,{Refills=1})
  -- First successful refill completes the one-time refill lesson for this player.
  local own=Profiles.Get(player);if own and not own.RefillTaught then Profiles.Mutate(player,function(d) d.RefillTaught=true;return true end) end
 end
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Deliver(player,shop,food)
 local f=Inventory.Find(food)
 if not f or not near(player,shop.Model[f.Bin]) then return false,"Go to a backroom ingredient shelf" end
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local bag=stock.Transit[key]
  if not bag or bag.Mode~="Delivery" then return false,"No delivery crates" end
  -- Any shelf accepts the whole mall order; every kit goes to its own backroom pool.
  storeBag(stock,bag);stock.Transit[key]=nil;return true,"Delivery stored in the backroom ("..(bag.Crates or 1).." crate(s))"
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.TripLimit() return math.max(1,amount("SupplyTripCrateLimit",8)) end
function Inventory.Buy(player,shop,id)
 if not shop or shop.Owner~=player then return false,"Only the owner can purchase with shop funds" end
 local food,count=tostring(id or ""):match("^(.-):(%d+)$")
 food=food or id;count=math.floor(tonumber(count) or 1)
 local f=Inventory.Find(food);if not f then return false,"Unknown ingredient" end
 local limit=Inventory.TripLimit()
 if count<1 or count>limit then return false,"Choose 1 to "..limit.." crates" end
 local checkout=workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true)
 if not near(player,checkout,16) then return false,"Visit the supply counter inside the mall" end
 local pd=Inventory.Service.PlayerData[player]
 if pd.Held~="" or pd.Cooking~="" then return false,"Empty your hands first" end
 local price=amount("SupplyCratePrice",45);local quantity=math.max(1,amount("SupplyCrateQuantity",6))
 local ok,msg=Profiles.Mutate(player,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local bag=stock.Transit[key]
  if bag and bag.Mode~="Delivery" then return false,"Refill the station crate you are carrying first" end
  local carried=bag and (bag.Crates or 1) or 0
  if carried+count>limit then return false,"You can carry "..limit.." crates per trip ("..math.max(0,limit-carried).." more)" end
  local total=price*count
  if d.Shop.Bank<total then return false,"Not enough shop funds (need $"..total..")" end
  d.Shop.Bank-=total
  if not bag then bag={Food=food,Quantity=0,Mode="Delivery",Crates=0,Items={}};stock.Transit[key]=bag end
  bag.Items=table.clone(bagItems(bag));bag.Items[food]=(bag.Items[food] or 0)+quantity*count
  bag.Crates=carried+count;bag.Quantity+=quantity*count
  return true,"Purchased "..count.." "..f.Name.." crate(s). Carrying "..bag.Crates.."/"..limit.."."
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
-- Dishes that use each shared kit pool, so players can see which crate feeds stations D-F.
local function kitDishes(shop)
 local out={};for _,f in Inventory.Foods do out[f.Id]={} end
 if not shop then return out end
 local level=shop.Model:GetAttribute("MenuLevel") or 1
 for index,id in Recipes.FullMenuForModel(shop.Model,shop.Model:GetAttribute("AppliedStyleTheme") or "") do
  local recipe=Recipes.Get(id)
  if recipe and out[recipe.StockId] then table.insert(out[recipe.StockId],{Name=recipe.Name,Station=string.char(64+index),Level=recipe.UnlockLevel or 1,Unlocked=(recipe.UnlockLevel or 1)<=level}) end
 end
 return out
end
function Inventory.Snapshot(player,shop)
 local stock=Inventory.Data(shop)
 local checkout=workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true)
 return {Foods=Inventory.Foods,Front=stock and stock.Front or {},Back=stock and stock.Back or {},
 Carry=Inventory.Bag(player,shop),Capacity=math.max(1,amount("FrontStockCapacity",6)),Price=amount("SupplyCratePrice",45),
 Quantity=math.max(1,amount("SupplyCrateQuantity",6)),NearMall=near(player,checkout,16) or false,
 TripLimit=Inventory.TripLimit(),Dishes=kitDishes(shop),
 IsOpen=shop and shop.Phase=="Playing" or false,CloseReason=shop and shop.CloseReason or ""}
end
function Inventory.Sync(shop,state,player)
 local stock=Inventory.Data(shop);local bag=Inventory.Bag(player,shop)
 for _,f in ipairs(Inventory.Foods) do
  state:SetAttribute("Front"..f.Key,stock and stock.Front[f.Id] or 0)
  state:SetAttribute("Back"..f.Key,stock and stock.Back[f.Id] or 0)
  local bin=shop.Model:FindFirstChild(f.Bin)
  local recipe=Recipes.Get(Inventory.RecipeForStock(shop,f.Id))
  local prompt=bin and bin:FindFirstChild("TakeStock")
  if prompt and recipe then prompt.ObjectText="STATION "..string.char(64+(recipe.CookingSlot or recipe.Slot)).." / "..recipe.Name.." ingredients" end
  local label=bin and bin:FindFirstChild("Count",true)
  if label then label.Text=tostring(stock and stock.Back[f.Id] or 0) end
 end
 state:SetAttribute("SupplyFood",bag and bag.Food or "");state:SetAttribute("SupplyQuantity",bag and bag.Quantity or 0);state:SetAttribute("SupplyMode",bag and bag.Mode or "")
 state:SetAttribute("SupplyRecipe",bagRecipe(shop,bag));state:SetAttribute("SupplyCrates",bag and bag.Mode=="Delivery" and (bag.Crates or 1) or 0)
 state:SetAttribute("CloseReason",shop.CloseReason or "");state:SetAttribute("ShopOpen",shop.Phase=="Playing")
 Inventory.Visual(player,shop)
 local sign=shop.Model:FindFirstChild("OpenClose");local label=sign and sign:FindFirstChild("Status",true)
 if label then label.Text=shop.Phase=="Playing" and "OPEN" or "CLOSED";label.TextColor3=shop.Phase=="Playing" and Color3.fromRGB(111,234,172) or Color3.fromRGB(255,165,104) end
end
function Inventory.Bind(shop)
 for _,f in ipairs(Inventory.Foods) do
  local bin=shop.Model:WaitForChild(f.Bin)
  for _,label in bin:GetDescendants() do if label:IsA("TextLabel") and label.Name~="Count" and (label.Text=="NOODLES" or label.Text=="FRIED RICE" or label.Text=="THAI TEA") then label.Text=f.Name:upper() end end
  bin:WaitForChild("TakeStock").Triggered:Connect(function(player)
   local pd=Inventory.Service.PlayerData[player]
   if pd and pd.ShopId==shop.Id and near(player,bin) then
    local ok,msg=Inventory.Take(player,shop,f.Id)
    RS.MidnightNetwork.Notice:FireClient(player,msg or (ok and "Done" or "Unavailable"))
   end
  end)
 end
 local sign=shop.Model:WaitForChild("OpenClose")
 sign.Toggle.Triggered:Connect(function(player)
  if near(player,sign) then local ok,msg=Inventory.Service.ToggleShop(player);RS.MidnightNetwork.Notice:FireClient(player,msg or "Done") end
 end)
end
function Inventory.Start(service)
 Inventory.Service=service
 local checkout=workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true)
 checkout.Shop.Triggered:Connect(function(player) if near(player,checkout,16) then RS.MidnightNetwork.OpenPanel:FireClient(player,"Mall") end end)
end
return Inventory
