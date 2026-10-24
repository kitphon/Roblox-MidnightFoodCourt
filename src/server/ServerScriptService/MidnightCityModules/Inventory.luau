
local Profiles=require(script.Parent.Profiles)
local Catalog=require(script.Parent.Catalog)
local RS=game:GetService("ReplicatedStorage")
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local Inventory={Service=nil}
local function amount(key,default) return math.max(0,math.floor(Catalog.Get(key,default))) end
Inventory.Foods={
 {Id="NOODLES",Key="Noodles",Name="Prep kits",Bin="StockNoodles",Station="NoodleStation",Color={238,188,82}},
 {Id="FRIED RICE",Key="Rice",Name="Kitchen kits",Bin="StockRice",Station="RiceStation",Color={225,133,71}},
 {Id="THAI TEA",Key="Tea",Name="Drink kits",Bin="StockTea",Station="TeaStation",Color={94,195,158}}
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
function Inventory.Recover(player)
 Profiles.Mutate(player,function(d)
  local stock=ensure(d)
  for _,bag in pairs(stock.Transit) do if Inventory.Find(bag.Food) then stock.Back[bag.Food]+=math.max(0,bag.Quantity or 0) end end
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
 local key=bag and bag.Food..":"..bag.Quantity..":"..bag.Mode or ""
 if old and old:GetAttribute("BagKey")==key then return end
 if old then old:Destroy() end
 if not bag then return end
 local root=char:FindFirstChild("HumanoidRootPart");if not root then return end
 local model=Instance.new("Model");model.Name="SupplyCrate";model:SetAttribute("BagKey",key);model.Parent=char
 local f=Inventory.Find(bag.Food)
 local body=Instance.new("Part");body.Name="Box";body.Size=Vector3.new(1.8,1.45,1.35);body.Color=Color3.fromRGB(159,116,68);body.Material=Enum.Material.Wood;body.CanCollide=false;body.Massless=true;body.CFrame=root.CFrame*CFrame.new(0,-.15,-1.7);body.Parent=model
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=body;w.Parent=body
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(320,200);g.Parent=body
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(unpack(f.Color));t.Text=string.upper(f.Name).."\n"..bag.Quantity;t.TextColor3=Color3.fromRGB(26,37,42);t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Parent=g
end
function Inventory.Return(player,shop)
 if not Inventory.Bag(player,shop) or not shop.Owner then return end
 Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local bag=stock.Transit[key]
  if bag then stock.Back[bag.Food]+=bag.Quantity;stock.Transit[key]=nil end
  return true
 end)
 Inventory.Visual(player,shop)
end
function Inventory.Take(player,shop,food)
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
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId)
  if stock.Transit[key] then return false,"Already carrying a crate" end
  local reserved=0;for _,b in pairs(stock.Transit) do if b.Food==food and b.Mode=="Backroom" then reserved+=b.Quantity end end
  local room=math.max(0,math.max(1,amount("FrontStockCapacity",6))-stock.Front[food]-reserved)
  local quantity=math.min(math.max(1,amount("StockCarryQuantity",3)),stock.Back[food],room)
  if quantity<=0 then return false,stock.Back[food]<=0 and "Backroom empty. Buy a crate at the mall." or "Front stock is full or already being refilled" end
  stock.Back[food]-=quantity;stock.Transit[key]={Food=food,Quantity=quantity,Mode="Backroom"};return true,"Take the crate to "..f.Name.." station"
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Restock(player,shop,food)
 local bag=Inventory.Bag(player,shop);local f=Inventory.Find(food)
 if not bag then return false,"No crate" end
 if bag.Food~=food then return false,"Use the "..Inventory.Find(bag.Food).Name.." station" end
 if bag.Mode=="Delivery" then return false,"Deliver purchases to the backroom first" end
 if not near(player,shop.Model[f.Station],7) then return false,"Go to the matching station" end
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local b=stock.Transit[key]
  if not b or b.Food~=food or b.Mode~="Backroom" then return false,"Crate unavailable" end
  local quantity=math.min(b.Quantity,math.max(0,math.max(1,amount("FrontStockCapacity",6))-stock.Front[food]))
  stock.Front[food]+=quantity;stock.Back[food]+=b.Quantity-quantity;stock.Transit[key]=nil
  return true,"Front stock refilled +"..quantity
 end)
 if ok then require(script.Parent.Experience).Goal(shop,"Refills",player);task.spawn(require(script.Parent.Quests).Track,player,{Refills=1}) end
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Deliver(player,shop,food)
 local f=Inventory.Find(food)
 if not f or not near(player,shop.Model[f.Bin]) then return false,"Go to the matching backroom bin" end
 local ok,msg=Profiles.Mutate(shop.Owner,function(d)
  local stock=ensure(d);local key=tostring(player.UserId);local bag=stock.Transit[key]
  if not bag or bag.Food~=food or bag.Mode~="Delivery" then return false,"No matching delivery crate" end
  stock.Back[food]+=bag.Quantity;stock.Transit[key]=nil;return true,"Delivery stored in the backroom"
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Buy(player,shop,food)
 if not shop or shop.Owner~=player then return false,"Only the owner can purchase with shop funds" end
 local f=Inventory.Find(food);if not f then return false,"Unknown ingredient" end
 local checkout=workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true)
 if not near(player,checkout,16) then return false,"Visit the supply counter inside the mall" end
 local pd=Inventory.Service.PlayerData[player]
 if pd.Held~="" or pd.Cooking~="" then return false,"Empty your hands first" end
 local price=amount("SupplyCratePrice",45);local quantity=math.max(1,amount("SupplyCrateQuantity",6))
 local ok,msg=Profiles.Mutate(player,function(d)
  local stock=ensure(d);local key=tostring(player.UserId)
  if stock.Transit[key] then return false,"Deliver the crate you are carrying first" end
  if d.Shop.Bank<price then return false,"Not enough shop funds" end
  d.Shop.Bank-=price;stock.Transit[key]={Food=food,Quantity=quantity,Mode="Delivery"}
  return true,"Purchased "..quantity.." "..f.Name..". Deliver to your backroom."
 end)
 Inventory.Service.Sync(shop);if ok then RS.MidnightFeedback:FireClient(player,"Ready") end;return ok,msg
end
function Inventory.Snapshot(player,shop)
 local stock=Inventory.Data(shop)
 local checkout=workspace.MidnightCity:FindFirstChild("SuppliesCheckout",true)
 return {Foods=Inventory.Foods,Front=stock and stock.Front or {},Back=stock and stock.Back or {},
 Carry=Inventory.Bag(player,shop),Capacity=math.max(1,amount("FrontStockCapacity",6)),Price=amount("SupplyCratePrice",45),
 Quantity=math.max(1,amount("SupplyCrateQuantity",6)),NearMall=near(player,checkout,16) or false,
 IsOpen=shop and shop.Phase=="Playing" or false,CloseReason=shop and shop.CloseReason or ""}
end
function Inventory.Sync(shop,state,player)
 local stock=Inventory.Data(shop);local bag=Inventory.Bag(player,shop)
 for _,f in ipairs(Inventory.Foods) do
  state:SetAttribute("Front"..f.Key,stock and stock.Front[f.Id] or 0)
  state:SetAttribute("Back"..f.Key,stock and stock.Back[f.Id] or 0)
  local bin=shop.Model:FindFirstChild(f.Bin)
  local label=bin and bin:FindFirstChild("Count",true)
  if label then label.Text=tostring(stock and stock.Back[f.Id] or 0) end
 end
 state:SetAttribute("SupplyFood",bag and bag.Food or "");state:SetAttribute("SupplyQuantity",bag and bag.Quantity or 0);state:SetAttribute("SupplyMode",bag and bag.Mode or "")
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
 checkout.Shop.Triggered:Connect(function(player) if near(player,checkout,16) then RS.MidnightNetwork.OpenPanel:FireClient(player,"Stock") end end)
end
return Inventory
