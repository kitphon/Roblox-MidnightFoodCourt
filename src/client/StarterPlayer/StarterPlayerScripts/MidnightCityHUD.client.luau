
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Run=game:GetService("RunService")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer
local state=player:WaitForChild("MidnightState")
local icons=game.ReplicatedStorage:WaitForChild("MidnightIcons")
local Recipes=require(game.ReplicatedStorage:WaitForChild("MidnightStyle"):WaitForChild("RecipeCatalog"))
local StyleCatalog=require(game.ReplicatedStorage:WaitForChild("MidnightStyle"):WaitForChild("StyleCatalog"))
local shops=workspace:WaitForChild("MidnightShops")
repeat task.wait() until player:GetAttribute("ShopId")
local function selectedShop()
 local id=player:GetAttribute("ShopId")
 if id and id>0 then return shops:WaitForChild("Shop"..id) end
 return nil
end
local shop=selectedShop()
for _,name in ipairs({"NoodleStation","RiceStation","TeaStation","StartShift","Serve","FuseBox","Radio","Ward"}) do if shop then shop:WaitForChild(name) end end
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false);game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) end)
local gui=Instance.new("ScreenGui");gui.Name="MidnightHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.Parent=player:WaitForChild("PlayerGui")
local canvas=Instance.new("Frame");canvas.Size=UDim2.fromOffset(960,640);canvas.AnchorPoint=Vector2.new(.5,.5);canvas.Position=UDim2.fromScale(.5,.5);canvas.BackgroundTransparency=1;canvas.Parent=gui
local scale=Instance.new("UIScale");scale.Parent=canvas
local C={bg=Color3.fromRGB(17,31,38),gold=Color3.fromRGB(255,196,92),mint=Color3.fromRGB(99,229,192),red=Color3.fromRGB(255,104,121),white=Color3.fromRGB(235,239,230)}
local function rounded(o,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 16);c.Parent=o end
local function card(x,y,w,h)
 local f=Instance.new("Frame");f.Position=UDim2.fromOffset(x,y);f.Size=UDim2.fromOffset(w,h);f.BackgroundColor3=C.bg;f.BackgroundTransparency=.08;f.BorderSizePixel=0;f.Parent=canvas;rounded(f)
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(66,90,93);stroke.Transparency=.3;stroke.Parent=f;return f
end
local function text(parent,str,x,y,w,h,size,color)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.Text=str;t.Font=Enum.Font.GothamBold;t.TextColor3=color or C.white;t.TextSize=size or 18;t.Parent=parent;return t
end

local function icon(parent,key,x,y,w,h,foodZoom,nonFoodScale)
 local holder=Instance.new("Frame");holder.Position=UDim2.fromOffset(x,y);holder.Size=UDim2.fromOffset(w,h);holder.BackgroundTransparency=1;holder.Parent=parent
 local drawing=Instance.new("Frame");drawing.Size=UDim2.fromOffset(100,100);drawing.AnchorPoint=Vector2.new(.5,.5);drawing.Position=UDim2.fromScale(.5,.5);drawing.BackgroundTransparency=1;drawing.Parent=holder
 local s=Instance.new("UIScale");s.Scale=math.min(w,h)/100;s.Parent=drawing
 local last
 local function shape(px,py,sx,sy,color,r,rotation)
  local f=Instance.new("Frame");f.Position=UDim2.fromOffset(px,py);f.Size=UDim2.fromOffset(sx,sy);f.BackgroundColor3=color;f.BorderSizePixel=0;f.Rotation=rotation or 0;f.Parent=drawing;if r then rounded(f,r) end;return f
 end
 local cream=Color3.fromRGB(247,236,209)
 local orange=Color3.fromRGB(238,151,64)
 local dark=Color3.fromRGB(35,59,65)
 local function change(k)
  if last==k then return end;last=k
  for _,a in ipairs(drawing:GetChildren()) do if a:IsA("GuiObject") then a:Destroy() end end
  local recipe=Recipes.Get(k)
  s.Scale=math.min(w,h)/100*((not recipe and nonFoodScale) or 1)
  if recipe or (type(k)=="string" and k:match("^KIT_%d$")) then
   local template=icons:FindFirstChild(k)
   if template then
    local viewport=Instance.new("ViewportFrame");viewport.Name="RecipePreview";viewport.Size=UDim2.fromScale(1,1);viewport.BackgroundTransparency=1;viewport.Ambient=Color3.fromRGB(210,210,210);viewport.LightColor=Color3.fromRGB(255,237,213);viewport.Parent=drawing
    local world=Instance.new("WorldModel");world.Parent=viewport
    local model=template:Clone();model.Parent=world
    local cf,size=model:GetBoundingBox();local distance=math.max(size.X,size.Y,size.Z)*1.6/(foodZoom or 1)
    local camera=Instance.new("Camera");camera.FieldOfView=42;camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(1,.7,-1)*distance,cf.Position);camera.Parent=viewport;viewport.CurrentCamera=camera
   end
  elseif k=="BELL" then
   shape(23,24,54,56,C.gold,28);shape(17,59,66,15,C.gold,6);shape(12,77,76,8,dark,4);shape(43,14,14,13,cream,6)
   shape(7,27,4,17,C.gold,2,-25);shape(88,27,4,17,C.gold,2,25)
  elseif k=="FUSE" then
   shape(20,12,60,78,C.gold,12);shape(30,23,40,52,dark,7);shape(43,30,14,35,C.white,4,-15)
   shape(43,79,14,4,C.mint,2)
  elseif k=="RADIO" then
   shape(69,3,4,33,C.white,2,20);shape(12,29,76,58,Color3.fromRGB(71,144,154),12)
   shape(20,40,35,35,dark,18);shape(27,47,21,21,Color3.fromRGB(96,179,182),12)
   shape(65,40,12,12,C.gold,6);shape(62,62,18,4,C.white,2);shape(62,71,18,4,C.white,2)
  elseif k=="WARD" then
   shape(27,9,46,81,C.mint,7);shape(35,32,30,30,C.gold,4,45);shape(45,42,10,10,dark,3,45);shape(40,75,20,4,cream,2)
  elseif k=="COIN" then
   shape(16,14,68,73,Color3.fromRGB(213,141,40),36);shape(16,10,68,69,C.gold,35)
   shape(27,22,46,45,Color3.fromRGB(244,172,43),24);text(drawing,"$",25,19,50,52,36,cream)
  end
 end
 change(key);return change,holder
end
local function bar(parent,x,y,w,color)
 local back=Instance.new("Frame");back.Position=UDim2.fromOffset(x,y);back.Size=UDim2.fromOffset(w,8);back.BackgroundColor3=Color3.fromRGB(45,63,67);back.BorderSizePixel=0;back.Parent=parent;rounded(back,4)
 local fill=Instance.new("Frame");fill.Size=UDim2.fromScale(1,1);fill.BackgroundColor3=color;fill.BorderSizePixel=0;fill.Parent=back;rounded(fill,4);return fill
end
text(canvas,"MIDNIGHT",20,17,150,25,20,C.gold);text(canvas,"K I T C H E N",20,43,150,18,11,C.white)
local stats=card(235,16,490,94);stats.Name="TopStats"
local clock=text(stats,"05:00",12,7,110,42,26,C.gold)
icon(stats,"COIN",130,3,48,48)
local cash=text(stats,"0",176,3,90,32,24,C.gold)
text(stats,"SHOP FUNDS",170,36,102,15,10,C.gold)
local hearts=text(stats,"♥ ♥ ♥ ♥ ♥",278,10,198,36,23,C.red)
local orderCard=card(18,118,148,190);orderCard.Name="OrderCard";local orderTitle=text(orderCard,"ORDER",8,8,132,23,16,C.mint)
local changeOrder,orderIconHolder=icon(orderCard,"",2,33,144,104,1.1)
local changeSetFood,setFoodHolder=icon(orderCard,"",4,38,68,82,1.1)
local changeSetDrink,setDrinkHolder=icon(orderCard,"",76,38,68,82,1.1)
setFoodHolder.Name="SetMealFood";setDrinkHolder.Name="SetMealDrink"
setFoodHolder.Visible=false;setDrinkHolder.Visible=false
local orderDish=text(orderCard,"",6,140,136,19,12,C.white);orderDish.Name="DishName"
local patience=bar(orderCard,15,163,118,C.mint)
local customerBadge=text(orderCard,"",6,175,136,13,10,C.gold);customerBadge.Name="CustomerBadge"
local heldCard=card(794,118,148,190);heldCard.Name="CarryingCard";local carryingTitle=text(heldCard,"CARRYING",8,8,132,23,16,C.gold)
local changeHeld,heldIconHolder=icon(heldCard,"",2,33,144,104)
local heldDish=text(heldCard,"",6,140,136,19,12,C.white);heldDish.Name="DishName"
local heldLabel=text(heldCard,"—",10,158,128,22,14,C.gold)
local combo=text(canvas,"",330,305,300,28,29,C.gold)
local taskCard=card(300,520,360,98)
local changeTask=icon(taskCard,"BELL",0,0,100,94,1.1,.85)
local taskLabel=text(taskCard,"START SHIFT",95,12,250,30,22,C.white)
local keyLabel=text(taskCard,"Go to the golden bell",95,49,250,25,14,C.gold)
local action=Instance.new("TextButton");action.Size=UDim2.fromScale(1,1);action.Text="";action.BackgroundTransparency=1;action.Parent=taskCard
local cookingCard=card(300,435,360,65);cookingCard.Visible=false
local changeCooking=icon(cookingCard,"",0,0,72,62,1.1)
local cookingTitle=text(cookingCard,"COOKING",75,5,265,22,16,C.white)
local cookbar=bar(cookingCard,85,40,250,C.gold)
local eventCard=card(332,125,296,90);eventCard.Visible=false
local changeEvent=icon(eventCard,"FUSE",0,0,90,82)
local eventText=text(eventCard,"",85,10,205,36,21,C.red)
local eventbar=bar(eventCard,99,64,178,C.red)
local result=card(260,220,440,220);result.Name="ShiftResult";result.Visible=false
local resultDismissed=false
local resultTitle=text(result,"",20,10,400,50,32,C.gold)
local resultCash=text(result,"",20,68,400,45,26,C.mint)
text(result,"Ring the bell to start a new shift",20,124,400,26,16,C.white)
local acknowledge=Instance.new("TextButton");acknowledge.Name="Acknowledge";acknowledge.Position=UDim2.fromOffset(130,164);acknowledge.Size=UDim2.fromOffset(180,42);acknowledge.BackgroundColor3=C.mint;acknowledge.TextColor3=C.bg;acknowledge.Text="OK";acknowledge.TextSize=20;acknowledge.Font=Enum.Font.GothamBold;acknowledge.BorderSizePixel=0;acknowledge.Parent=result;rounded(acknowledge,10)
acknowledge.Activated:Connect(function() resultDismissed=true;result.Visible=false end)
local toast=text(canvas,"",300,330,360,65,38,C.gold);toast.TextTransparency=1
local muted=false
local mute=Instance.new("TextButton");mute.Position=UDim2.fromOffset(840,20);mute.Size=UDim2.fromOffset(100,42);mute.BackgroundColor3=C.bg;mute.Text="♫ ON";mute.TextColor3=C.gold;mute.TextSize=17;mute.Font=Enum.Font.GothamBold;mute.Parent=canvas;rounded(mute,12)
local sounds={}
-- Base volume per sound; the mute button restores these. All sources live in SoundService as MK_<name>.
local baseVolume={Music=.17,Sizzle=.42,Ding=.4,Cash=.45,Blackout=.5,Static=.45,Shadow=.5,DoorBell=.35,LevelUp=.5,Rain=.35,CityNight=.18,Pour=.45}
for name,volume in baseVolume do
 local source=SoundService:WaitForChild("MK_"..name,10)
 if source then local s=source:Clone();s.Name="Local_"..name;s.Volume=volume;s.Parent=SoundService;sounds[name]=s end
end
sounds.Music.Looped=true;sounds.Music:Play()
sounds.Sizzle.Looped=true
if sounds.Rain then sounds.Rain.Looped=true end
if sounds.CityNight then sounds.CityNight.Looped=true;sounds.CityNight:Play() end
local function volumeFor(name) if name=="Music" and state:GetAttribute("Event")~="" then return .04 end;return baseVolume[name] end
mute.Activated:Connect(function() muted=not muted;mute.Text=muted and "♫ OFF" or "♫ ON";for name,s in pairs(sounds) do s.Volume=muted and 0 or volumeFor(name) end end)
local function play(name,speed) local s=sounds[name];if s then s.PlaybackSpeed=speed or 1;s.TimePosition=0;s:Play() end end
local toastGeneration=0
local function pop(str,color)
 toastGeneration+=1;local token=toastGeneration;toast.Text=str;toast.TextColor3=color or C.gold;toast.TextTransparency=0;toast.Position=UDim2.fromOffset(300,345)
 Tween:Create(toast,TweenInfo.new(.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(300,305)}):Play()
 task.delay(1,function() if toastGeneration==token then Tween:Create(toast,TweenInfo.new(.5),{TextTransparency=1}):Play() end end)
end
game.ReplicatedStorage:WaitForChild("MidnightFeedback").OnClientEvent:Connect(function(cue)
 if cue=="Order" then play("DoorBell")
 elseif cue=="LevelUp" then play("LevelUp")
 elseif cue=="Start" then play("Ding",.85)
 elseif cue=="Ready" then sounds.Sizzle:Stop();play("Ding",1.4)
 elseif cue=="Serve" then play("Cash")
 elseif cue=="Repair" then play("Ding",1.6);pop("✓",C.mint)
 elseif cue=="Mistake" then play("Ding",.5);pop("✕",C.red)
 elseif cue=="Danger" then play("Ding",.35)
 elseif cue=="Win" then play("Cash");sounds.Sizzle:Stop()
 elseif cue=="Lose" then play("Ding",.45);sounds.Sizzle:Stop() end
end)
local stockCard=card(18,325,148,134);stockCard.Name="StockCard"
local sideCardFactor=.9
for _,panel in {orderCard,stockCard,heldCard} do
 local cardScale=Instance.new("UIScale");cardScale.Name="SideCardScale";cardScale.Scale=sideCardFactor;cardScale.Parent=panel
end
local stockTitle=text(stockCard,"FRONT / BACK",4,4,140,20,11,C.mint)
icon(stockCard,"KIT_1",7,27,36,30)
icon(stockCard,"KIT_2",7,62,36,30)
icon(stockCard,"KIT_3",7,97,36,30)
local stockNoodles=text(stockCard,"",46,27,94,28,17,C.gold)
local stockRice=text(stockCard,"",46,62,94,28,17,C.gold)
local stockTea=text(stockCard,"",46,97,94,28,17,C.gold)
local currentOrder,currentHeld,currentEvent,currentCooking="","","",""
local lastTier
local highlight=Instance.new("Highlight");highlight.Name="NextAction";highlight.Enabled=false;highlight.FillColor=C.gold;highlight.FillTransparency=.85;highlight.OutlineColor=C.gold;highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;highlight.Parent=workspace
local targets={BLACKOUT="FuseBox",WHISPER="Radio",SHADOW="Ward"};for _,recipe in Recipes.All do targets[recipe.Id]=recipe.Station end
local eventIcons={BLACKOUT="FUSE",WHISPER="RADIO",SHADOW="WARD"}
local eventLabels={BLACKOUT="RESTORE POWER",WHISPER="SILENCE RADIO",SHADOW="BANISH SHADOW"}
local target,nearPrompt
for _,p in ipairs(shop and shop:GetDescendants() or {}) do if p:IsA("ProximityPrompt") then p.Style=(p.Name=="Toggle" or p.Name=="TakeStock") and Enum.ProximityPromptStyle.Default or Enum.ProximityPromptStyle.Custom end end
local foodTheme=""
local menuPalette=StyleCatalog.Menu("")
local foodIndex={};for _,recipe in Recipes.All do foodIndex[recipe.Id]=recipe.Slot end
local function menuColor(rgb) return Color3.fromRGB(unpack(rgb)) end
local function foodName(food) local recipe=Recipes.Get(food);return recipe and recipe.Name or "" end
local function applyFoodMenuStyle()
 local themeId=shop and shop:GetAttribute("AppliedStyleTheme") or ""
 if foodTheme==themeId and orderCard:GetAttribute("MenuStyled") then return end
 foodTheme=themeId;menuPalette=StyleCatalog.Menu(themeId)
 local bg,ink,accent=menuColor(menuPalette.Background),menuColor(menuPalette.Text),menuColor(menuPalette.Accent)
 local font=Enum.Font[menuPalette.Font] or Enum.Font.GothamBold
 for _,frame in {orderCard,heldCard,cookingCard,taskCard,stockCard} do
  frame.BackgroundColor3=bg;frame.BackgroundTransparency=.04
  local stroke=frame:FindFirstChildOfClass("UIStroke");if stroke then stroke.Color=accent;stroke.Transparency=.12 end
  local corner=frame:FindFirstChildOfClass("UICorner");if corner then corner.CornerRadius=UDim.new(0,menuPalette.Radius) end
  frame:SetAttribute("ThemeId",themeId)
 end
 for _,label in {orderTitle,carryingTitle,cookingTitle,stockTitle,orderDish,heldDish,heldLabel,taskLabel,keyLabel} do label.Font=font;label.TextColor3=ink end
 for _,label in {orderTitle,carryingTitle,stockTitle,keyLabel} do label.TextColor3=accent end
 for _,holder in {orderIconHolder,heldIconHolder} do holder.BackgroundColor3=bg:Lerp(accent,.15);holder.BackgroundTransparency=.15 end
 cookbar.BackgroundColor3=accent
 orderCard:SetAttribute("MenuStyled",true)
end
local function update()
 applyFoodMenuStyle()
 local phase=state:GetAttribute("Phase")
 if phase~="Won" and phase~="Lost" then resultDismissed=false end
 local supply=state:GetAttribute("SupplyFood") or ""
 local supplyMode=state:GetAttribute("SupplyMode") or ""
 stockCard.Visible=shop~=nil
 stockNoodles.Text=tostring(state:GetAttribute("FrontNoodles") or 0).." / "..tostring(state:GetAttribute("BackNoodles") or 0)
 stockRice.Text=tostring(state:GetAttribute("FrontRice") or 0).." / "..tostring(state:GetAttribute("BackRice") or 0)
 stockTea.Text=tostring(state:GetAttribute("FrontTea") or 0).." / "..tostring(state:GetAttribute("BackTea") or 0)
 stockNoodles.TextColor3=(state:GetAttribute("FrontNoodles") or 0)==0 and C.red or menuColor(menuPalette.Accent)
 stockRice.TextColor3=(state:GetAttribute("FrontRice") or 0)==0 and C.red or C.gold
 stockTea.TextColor3=(state:GetAttribute("FrontTea") or 0)==0 and C.red or C.gold

 local o,h,e,c=state:GetAttribute("Order") or "",state:GetAttribute("Held") or "",state:GetAttribute("Event") or "",state:GetAttribute("Cooking") or ""
 local kind=state:GetAttribute("CustomerKind") or "Guest"
 local bonus=state:GetAttribute("CustomerBonusPct") or 0
 local customerType=kind=="Reviewer" and "REVIEWER" or kind=="Party" and ("PARTY "..tostring(state:GetAttribute("PartyIndex") or 1).."/"..tostring(state:GetAttribute("PartySize") or 1)) or kind=="Regular" and ("RILEY Lv."..tostring(state:GetAttribute("RegularLevel") or 1)) or "GUEST"
 customerBadge.Text=customerType..(bonus>0 and (" • +"..bonus.."%") or "")
 local bundle=state:GetAttribute("BundleItems") or ""
 local items=string.split(bundle,"|");local isSet=bundle~="" and phase=="Playing"
 orderIconHolder.Visible=not isSet;setFoodHolder.Visible=isSet;setDrinkHolder.Visible=isSet
 orderTitle.Text=isSet and ("SET "..tostring(state:GetAttribute("BundleDone") or 0).."/2") or "ORDER"
 if isSet then
  changeSetFood(items[1]);changeSetDrink(items[2])
  local delivered="|"..(state:GetAttribute("BundleDelivered") or "").."|"
  local function itemName(id) return (delivered:find("|"..id.."|",1,true) and "✓ " or "")..foodName(id) end
  orderDish.Position=UDim2.fromOffset(6,122);orderDish.Size=UDim2.fromOffset(136,38)
  orderDish.Text=itemName(items[1]).."\n"..itemName(items[2])
 else orderDish.Position=UDim2.fromOffset(6,140);orderDish.Size=UDim2.fromOffset(136,19);orderDish.Text=foodName(o) end
 heldDish.Text=foodName(h)
 if o~=currentOrder then currentOrder=o;changeOrder(o) end
 if h~=currentHeld then
  currentHeld=h;changeHeld(h)
 end
 if c~=currentCooking then
  currentCooking=c;changeCooking(c)
  local recipe=Recipes.Get(c)
  local drink=recipe and (recipe.Shape=="Cup" or recipe.Shape=="Mug" or recipe.Shape=="Soda")
  if c~="" and drink then sounds.Sizzle:Stop();play("Pour")
  elseif c~="" then sounds.Sizzle:Play() else sounds.Sizzle:Stop() end
 end
 local tier=(state:GetAttribute("RestaurantTier") or 1)
 if lastTier and tier>lastTier and shop then play("LevelUp") end
 lastTier=tier
 if supply~="" then changeHeld("KIT_"..(Recipes.Slot(supply) or 1));heldLabel.Text="CRATE ×"..tostring(state:GetAttribute("SupplyQuantity") or 0)
 else changeHeld(h);heldLabel.Text=h~="" and "READY" or "—" end
 stats.Visible=shop~=nil
 orderCard.Visible=phase=="Playing";heldCard.Visible=phase=="Playing" or supply~=""
 cookingCard.Visible=c~=""
 taskCard.Visible=c=="" or e~=""
 eventCard.Visible=e~=""
 if e~=currentEvent then currentEvent=e;changeEvent(eventIcons[e] or "");eventText.Text=eventLabels[e] or ""
  -- Each disturbance has its own sound; the radio static loops until it is silenced.
  if sounds.Static then sounds.Static.Looped=e=="WHISPER";if e~="WHISPER" then sounds.Static:Stop() end end
  if e=="BLACKOUT" then play("Blackout") elseif e=="WHISPER" then play("Static") elseif e=="SHADOW" then play("Shadow") end
  if not muted then Tween:Create(sounds.Music,TweenInfo.new(.6),{Volume=e~="" and .04 or .17}):Play() end
 end
 local t=state:GetAttribute("Time") or 0
 clock.Text=string.format("%02d:%02d",math.floor(t/60),t%60);cash.Text=tostring(state:GetAttribute("Bank") or 0)
 local strikes=math.clamp(state:GetAttribute("Strikes") or 0,0,5);hearts.Text=string.rep("♥ ",5-strikes)..string.rep("♡ ",strikes)
 local n=state:GetAttribute("Combo") or 0;combo.Text=n>=2 and ("COMBO ×"..n) or ""
 local patienceValue=state:GetAttribute("Patience") or 1;patience.Size=UDim2.fromScale(patienceValue,1);patience.BackgroundColor3=patienceValue<.3 and C.red or menuColor(menuPalette.Accent)
 eventbar.Size=UDim2.fromScale(state:GetAttribute("EventLeft") or 1,1)
 result.Visible=(phase=="Won" or phase=="Lost") and not resultDismissed;resultTitle.Text=phase=="Won" and "SHIFT COMPLETE ☀" or "SHIFT FAILED"
 resultCash.Text="$"..tostring(state:GetAttribute("Cash") or 0).."  •  "..tostring(state:GetAttribute("Served") or 0).." served"
 local key,label
 local courierShop=(player:GetAttribute("CourierShop") or 0)>0 and shops:FindFirstChild("Shop"..player:GetAttribute("CourierShop"))
 if not shop and courierShop then
  -- Visitor carrying a courier crate: guide them to the destination kitchen's backroom bin.
  local food=player:GetAttribute("CourierFood") or ""
  local bins={NOODLES="StockNoodles",["FRIED RICE"]="StockRice",["THAI TEA"]="StockTea"}
  local slots={NOODLES=1,["FRIED RICE"]=2,["THAI TEA"]=3}
  target=courierShop:FindFirstChild(bins[food] or "");key="KIT_"..(slots[food] or 1);label="COURIER DELIVERY"
 elseif not shop then target=nil;key="";label="CHOOSE A CREW"
 elseif supply~="" then
  local bins={};for _,recipe in Recipes.All do bins[recipe.Id]=({"StockNoodles","StockRice","StockTea"})[recipe.Slot] end
  target=shop[supplyMode=="Delivery" and bins[supply] or targets[supply]];key=supply;label=supplyMode=="Delivery" and "STORE DELIVERY" or "REFILL STATION"
 elseif phase=="Closed" then
  if state:GetAttribute("CloseReason")=="OUT OF STOCK" then
   local stops=workspace.MidnightCity:FindFirstChild("BusStops")
   target=stops and stops:FindFirstChild("Shop"..tostring(player:GetAttribute("ShopId")));key="";label="BUY SUPPLIES"
  else target=shop.OpenClose;key="BELL";label="SHOP CLOSED" end
 elseif phase~="Playing" then target=shop.StartShift;key="BELL";label="OPEN SHOP"
 elseif e~="" then target=shop[targets[e]];key=eventIcons[e];label=eventLabels[e]
 elseif c~="" then target=nil;key=c;label="COOKING…"
 elseif (state:GetAttribute("CustomerStage") or "")~="Ordering" then target=nil;key="";label="NEXT CUSTOMER"
 elseif state:GetAttribute("OrderUnavailable") then target=shop.Serve;key=o;label="MENU UNAVAILABLE"
 elseif h~="" then target=shop.Serve;key=h;label="SERVE"
 elseif (state:GetAttribute("Prepared") or "")~="" then key=state:GetAttribute("Prepared");target=shop[targets[key]];label="PICK UP MEAL"
 else
  local stockKeys={};for _,recipe in Recipes.All do stockKeys[recipe.Id]=({"Noodles","Rice","Tea"})[recipe.Slot] end
  local bins={NOODLES="StockNoodles",["FRIED RICE"]="StockRice",["THAI TEA"]="StockTea"}
  if (state:GetAttribute("Front"..(stockKeys[o] or "Noodles")) or 0)<=0 then
   target=shop[bins[o] or "StockNoodles"];key=o;label="GET INGREDIENTS"
  else target=shop[targets[o] or "NoodleStation"];key=o;label="COOK" end
 end
 changeTask(key);taskLabel.Text=label
 local highlightTarget=target and (shop and shop:FindFirstChild("StationIcon_"..target.Name) or target)
 highlight.Enabled=false
 highlight.Adornee=highlightTarget
 highlight.Enabled=highlightTarget~=nil
end
state.AttributeChanged:Connect(update);update()
-- Rain ambience follows the city's Rain Shower event.
local cityWorld=workspace:WaitForChild("MidnightCity")
local function weather() if sounds.Rain then if cityWorld:GetAttribute("Event")=="Rain Shower" then if not sounds.Rain.IsPlaying then sounds.Rain:Play() end else sounds.Rain:Stop() end end end
cityWorld:GetAttributeChangedSignal("Event"):Connect(weather);weather()
player:GetAttributeChangedSignal("CourierShop"):Connect(update)
local menuThemeConnection
local function bindMenuTheme()
 if menuThemeConnection then menuThemeConnection:Disconnect();menuThemeConnection=nil end
 if shop then menuThemeConnection=shop:GetAttributeChangedSignal("AppliedStyleTheme"):Connect(update) end
 foodTheme="";orderCard:SetAttribute("MenuStyled",false);update()
end
bindMenuTheme()
local pulse=0
Run.RenderStepped:Connect(function(dt)
 local viewport=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(viewport.X/960,viewport.Y/640)
 -- Keep side cards 16 screen pixels from the actual viewport edge, including wide screens.
 local sideScale=math.max(scale.Scale,.01)
 local leftEdge=(960-viewport.X/sideScale)/2+16/sideScale
 orderCard.Position=UDim2.fromOffset(leftEdge,118)
 stockCard.Position=UDim2.fromOffset(leftEdge,325)
 heldCard.Position=UDim2.fromOffset(960-leftEdge-148*sideCardFactor,118)
 -- Portrait uses readable screen-space cards instead of shrinking the desktop canvas.
 local portrait=game.UserInputService.TouchEnabled and viewport.X<viewport.Y
 local function placeMobile(frame,position,factor)
  local saved=frame:FindFirstChild("MobileLayoutScale")
  if not saved then
   saved=Instance.new("UIScale");saved.Name="MobileLayoutScale";saved.Parent=frame
   frame:SetAttribute("DesktopPosition",frame.Position)
  end
  if portrait then frame.Parent=gui;frame.Position=position;saved.Scale=factor
  else frame.Parent=canvas;saved.Scale=1;frame.Position=frame:GetAttribute("DesktopPosition") end
 end
 placeMobile(stats,UDim2.fromOffset((viewport.X-(viewport.X-32))/2,16),(viewport.X-32)/490)
 placeMobile(orderCard,UDim2.fromOffset(16,100),.9)
 placeMobile(heldCard,UDim2.fromOffset(viewport.X-16-148*.9,100),.9)
 placeMobile(stockCard,UDim2.fromOffset(16,288),.9)
 placeMobile(taskCard,UDim2.fromOffset((viewport.X-288)/2,math.max(390,viewport.Y*.55)),.8)
 if not portrait then
  orderCard.Position=UDim2.fromOffset(leftEdge,118);stockCard.Position=UDim2.fromOffset(leftEdge,325)
  heldCard.Position=UDim2.fromOffset(960-leftEdge-148*sideCardFactor,118)
 end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 pulse+=dt

 if target and root then
  local distance=(root.Position-target.Position).Magnitude;nearPrompt=distance<=6 and target:FindFirstChildOfClass("ProximityPrompt") or nil
  local destinations={
 StartShift="Go to the golden bell",
 NoodleStation="Go to the prep station",
 RiceStation="Go to the kitchen station",
 TeaStation="Go to the drinks station",
 Serve="Go to the serving counter",
 FuseBox="Go to the fuse box",
 Radio="Go to the radio",
 Ward="Go to the cyan ward",
 OpenClose="F to reopen / Kitchen → Supplies",
 StockNoodles="Go to the backroom bin",StockRice="Go to the backroom bin",StockTea="Go to the backroom bin"
}
keyLabel.Text=nearPrompt and ("Hold "..nearPrompt.KeyboardKeyCode.Name.." / Tap") or (target.Parent and target.Parent.Name=="BusStops" and "Go to the BUS stop / MANAGE → Travel" or destinations[target.Name] or "Move closer")

 else
  nearPrompt=nil
  if not shop then keyLabel.Text="Tap here / MANAGE → Co-op"
  elseif state:GetAttribute("Phase")=="Playing" then
   keyLabel.Text=state:GetAttribute("CustomerStage")=="Leaving" and "Customer is leaving" or "Customer is walking over"
  else keyLabel.Text="" end
 end
 highlight.OutlineTransparency=.15+.25*(math.sin(pulse*4)+1)/2
 local cookEnd=state:GetAttribute("CookEnd") or 0
 cookbar.Size=UDim2.fromScale(math.clamp(1-(cookEnd-workspace:GetServerTimeNow())/math.max(.1,state:GetAttribute("CookDuration") or 3),0,1),1)
 for _,a in ipairs(shop and shop:GetChildren() or {}) do if a.Name=="Cooktop" then
  local emitter=a:FindFirstChild("Steam",true)
  if emitter then local station=shop and shop:FindFirstChild(Recipes.Station(currentCooking) or "");local x=station and station.Position.X;emitter.Rate=x and math.abs(a.Position.X-x)<1 and 15 or 0 end
 end end
end)
local activating=false
action.Activated:Connect(function()
 if not shop and not nearPrompt then
  local event=player.PlayerGui:FindFirstChild("OpenMidnightManagement");if event then event:Fire("Co-op") end
  return
 end
 if activating or not nearPrompt then return end
 activating=true;local p=nearPrompt;p:InputHoldBegin();task.wait(.25);p:InputHoldEnd();activating=false
end)

player:GetAttributeChangedSignal("ShopId"):Connect(function()
 resultDismissed=false
 shop=selectedShop()
 bindMenuTheme()
 for _,p in ipairs(shop and shop:GetDescendants() or {}) do if p:IsA("ProximityPrompt") then p.Style=Enum.ProximityPromptStyle.Custom end end
 update()
end)
if shop then
 local center=shop.ShopFloor.Position
 workspace.CurrentCamera.CFrame=CFrame.lookAt(center+Vector3.new(0,8,8),shop.CounterTop.Position)
end
