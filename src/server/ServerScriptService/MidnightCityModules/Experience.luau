local RS=game:GetService("ReplicatedStorage")
local Profiles=require(script.Parent.Profiles)
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local E={Service=nil,Pings={},PingAt={}}
E.Tiers={{Name="Corner Kitchen",Need=0},{Name="Neighborhood Favorite",Need=8},{Name="City Hotspot",Need=25},{Name="Midnight Landmark",Need=60},{Name="Kitchen Legend",Need=125}}
local function career(d)
 d.Shop.Career=d.Shop.Career or {Served=0,Perfect=0,Reviews=0,ReviewTotal=0,Visits=0}
 return d.Shop.Career
end
function E.Tier(d)
 local c=career(d);local level=1
 for i,t in E.Tiers do if c.Served>=t.Need then level=i end end
 return level,E.Tiers[level],E.Tiers[level+1]
end
-- Prestige after Kitchen Legend: one Legend Star per 50 more served orders (max 20), +2% meal value each.
E.StarStart,E.StarStep,E.MaxStars=125,50,20
function E.Stars(d)
 local c=career(d)
 if c.Served<E.StarStart then return 0 end
 return math.min(E.MaxStars,math.floor((c.Served-E.StarStart)/E.StarStep))
end
function E.NextStarAt(d)
 local stars=E.Stars(d)
 return stars<E.MaxStars and E.StarStart+E.StarStep*(stars+1) or nil
end
function E.Foods(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner)
 local ids=Recipes.Unlocked(d and d.Equipped.Theme or "",d and E.Tier(d) or 1)
 if d and E.Tier(d)>=3 and d.Shop.SignatureEnabled then ids[2]="SIGNATURE_RICE" end
 return ids
end
function E.Prepare(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner)
 local level=d and E.Tier(d) or 1
 if shop.Model:GetAttribute("MenuLevel")~=level then shop.Model:SetAttribute("MenuLevel",level);shop.StyleKey=nil end
 local enabled=d and E.Tier(d)>=3 and d.Shop.SignatureEnabled==true or false
 if shop.Model:GetAttribute("SignatureMenu")~=enabled then shop.Model:SetAttribute("SignatureMenu",enabled);shop.StyleKey=nil end
end
local function notice(shop,message)
 for p in pairs(shop.Members) do RS.MidnightNetwork.Notice:FireClient(p,message) end
end
function E.Tutorial(player,event)
 local d=Profiles.Get(player);if not d then return end
 local step=d.TutorialStep or 1
 local events={"Open","Cook","Skill","Serve","Upgrade"}
 if events[step]~=event then return end
 Profiles.Mutate(player,function(data)
  data.TutorialStep=step+1
  if data.TutorialStep==6 and not data.TutorialRewarded then data.TutorialRewarded=true;data.Coins+=50 end
  return true
 end)
 if step==5 then RS.MidnightNetwork.Notice:FireClient(player,"Training complete! +50 Coins on your first completion.") end
end
function E.Training(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner);return d and (d.TutorialStep or 1)<=4
end
function E.BeginShift(shop)
 shop.ShiftGoals={Manual=0,Perfect=0,Refills=0,Paid={}}
 shop.PartyRemaining=0;shop.PartySize=0;shop.PartyIndex=0
end
function E.Goal(shop,kind,actor)
 local g=shop.ShiftGoals;if not g then return end
 g[kind]=(g[kind] or 0)+1
 local targets={Manual=3,Perfect=2,Refills=2}
 if targets[kind] and g[kind]>=targets[kind] and not g.Paid[kind] and shop.Owner then
  g.Paid[kind]=true
  Profiles.Mutate(shop.Owner,function(d) d.Shop.Bank+=60;return true end)
  notice(shop,"Team goal complete: "..kind.." • +$60 shop funds")
 end
end
function E.RegularLevel(d)
 local visits=d.Shop.RileyServed or 0
 local level=visits>=15 and 4 or visits>=8 and 3 or visits>=3 and 2 or 1
 return level,visits,({3,8,15,15})[level]
end
function E.Popularity(d)
 local c=career(d)
 return c.Reviews>0 and math.clamp(math.floor(c.ReviewTotal/c.Reviews*20+.5),0,100) or 0
end
function E.Review(shop,quality,score,missed)
 if not shop.Owner then return end
 local speed=shop.Patience or 0
 local meal=quality=="Perfect" and 5 or quality=="Good" and 4 or quality=="Normal" and 3 or quality=="Fair" and 2 or 1
 local service=speed>=.65 and 5 or speed>=.35 and 4 or speed>=.15 and 3 or 2
 local stars=missed and 2 or math.clamp(math.floor((meal+service)/2+.5),1,5)
 local speedName=speed>=.65 and "Fast" or speed>=.35 and "On time" or "Slow"
 local reason=missed and "The order was not served before the guest left." or ("Meal: "..(quality or "Normal")..(type(score)=="number" and (" ("..score.."/100)") or "")..". Service: "..speedName..".")
 local review
 Profiles.Mutate(shop.Owner,function(d)
  local c=career(d);c.Reviews+=1;c.ReviewTotal+=stars
  local popularity=E.Popularity(d)
  review={Stars=stars,Reason=reason,Popularity=popularity,At=os.time(),Rush=stars>=4 and popularity>=80}
  d.Shop.LastFoodReview=review
  return true
 end)
 if not review then return end -- Owner profile closing/unavailable: skip the review safely.
 if review.Rush then shop.RushUntil=workspace:GetServerTimeNow()+60
 elseif review.Popularity<80 then shop.RushUntil=0 end
 for p in pairs(shop.Members) do RS.MidnightFeedback:FireClient(p,"ReviewResult",review) end
 notice(shop,"Food review: "..stars.."/5 • Popularity "..review.Popularity.."/100"..(review.Rush and " • Rush hour for 60 seconds!" or ""))
end
function E.Customer(shop,available)
 local owner=shop.Owner;local d=owner and Profiles.Get(owner)
 local kind="Guest";local food=available[math.random(1,#available)]
 if not d then return food end
 local visits=career(d).Visits+1
 Profiles.Mutate(owner,function(data) career(data).Visits=visits;return true end)
 if (shop.PartyRemaining or 0)>0 then
   kind="Party";shop.PartyRemaining-=1;shop.PartyIndex+=1
 elseif not E.Training(shop) then
  if visits%7==0 then kind="Reviewer"
  elseif visits%5==0 or (shop.RushUntil or 0)>workspace:GetServerTimeNow() and visits%2==0 then
   kind="Party";shop.PartySize=math.random(2,3);shop.PartyIndex=1;shop.PartyRemaining=shop.PartySize-1;shop.PartyServed=0
   shop.PartyMenu=table.clone(available)
   for i=#shop.PartyMenu,2,-1 do local j=math.random(1,i);shop.PartyMenu[i],shop.PartyMenu[j]=shop.PartyMenu[j],shop.PartyMenu[i] end
  elseif visits%3==0 then kind="Regular" end
 end
 if kind=="Party" then
  local planned=shop.PartyMenu and shop.PartyMenu[(shop.PartyIndex-1)%#shop.PartyMenu+1]
  if planned and table.find(available,planned) then food=planned end
 elseif kind=="Regular" then
  local theme=d.Equipped.Theme or "";local favorite=d.Shop.RegularFavorites and d.Shop.RegularFavorites[theme]
  if not favorite or not table.find(available,favorite) then
   favorite=food
   Profiles.Mutate(owner,function(data) data.Shop.RegularFavorites=data.Shop.RegularFavorites or {};data.Shop.RegularFavorites[theme]=favorite;return true end)
  end
  food=favorite
 elseif (d.Shop.FeatureSlot or 0)>0 and math.random()<.35 then
  local feature=E.Foods(shop)[d.Shop.FeatureSlot]
  if table.find(available,feature) then food=feature end
 end
 local regularLevel=E.RegularLevel(d)
 shop.CustomerRegularLevel=kind=="Regular" and regularLevel or 0
 shop.CustomerKind=kind;shop.CustomerPatienceFactor=kind=="Reviewer" and .8 or kind=="Regular" and (1.25+.05*(regularLevel-1)) or kind=="Party" and .9 or 1
 shop.CustomerBonus=kind=="Reviewer" and 1.5 or kind=="Regular" and (1.15+.05*(regularLevel-1)) or kind=="Party" and 1.1 or 1
 shop.CustomerTitle=kind=="Regular" and ("Riley • Friend Lv. "..regularLevel) or kind=="Reviewer" and "Food Reviewer" or kind=="Party" and ("Dinner Party "..shop.PartyIndex.."/"..shop.PartySize) or "Guest"
 shop.OrderStarted=workspace:GetServerTimeNow()
 return food
end
function E.Arrived(shop,model)
 model:SetAttribute("CustomerKind",shop.CustomerKind)
 if shop.CustomerKind=="Regular" then shop.CustomerName="Riley";model:SetAttribute("CustomerName","Riley") end
 if shop.CustomerKind=="Reviewer" then
  notice(shop,"Food reviewer! Serve promptly; a Perfect meal earns the best review.")
 elseif shop.CustomerKind=="Regular" then notice(shop,"Riley is back for a favorite dish.")
 elseif shop.CustomerKind=="Party" then notice(shop,shop.CustomerTitle.." • Each guest orders and leaves in turn.") end
end
function E.NewTimingTarget(previous)
 local choices={.25,.35,.45,.55,.65,.75,.82}
 local available={}
 for _,v in choices do if not previous or math.abs(v-previous)>=.18 then table.insert(available,v) end end
 return available[math.random(1,#available)]
end
function E.TimingScore(phase,target)
 local distance=math.abs(phase-target)
 local score=math.clamp(math.floor(100*(1-distance/math.max(target,1-target))+.5),0,100)
 local quality=distance<=.075 and "Perfect" or distance<=.22 and "Good" or distance<=.4 and "Fair" or "Poor"
 return quality,score
end
function E.Skill(player)
 local pd=E.Service.PlayerData[player];local shop=pd and E.Service.Shops[pd.ShopId]
 if not shop or not shop.Members[player] or shop.Phase~="Playing" or pd.Cooking=="" or pd.SkillHit then return false,"No cooking action available" end
 local now=workspace:GetServerTimeNow();local started=pd.CookEnd-(pd.CookDuration or 1)
 if now<started or now>=pd.CookEnd then return false,"Cooking action expired" end
 local station=shop.Model:FindFirstChild(Recipes.Station(pd.Cooking) or "")
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not station or not root or (root.Position-station.Position).Magnitude>10 then return false,"Stay at your cooking station" end
 pd.SkillHit=true
 local phase=(now-started)/pd.CookDuration
 local quality,score=E.TimingScore(phase,pd.SkillTarget or .65)
 pd.CookQuality=quality;pd.CookScore=score;E.Tutorial(player,"Skill")
 RS.MidnightFeedback:FireClient(player,quality,score);E.Service.Sync(shop)
 return true,quality.." • "..score.."/100 timing score"
end
function E.Reward(shop,actor,quality,base,score)
 local d=shop.Owner and Profiles.Get(shop.Owner);if not d then return base end
 local featured=E.Foods(shop)[d.Shop.FeatureSlot or 0]==shop.Order
 local rank=E.Tier(d)
 local timingMultiplier=(quality=="Normal" or quality==nil) and 1 or nil
 if not timingMultiplier then timingMultiplier=.75+.5*math.clamp((score or (quality=="Perfect" and 100 or quality=="Good" and 70 or 0))/100,0,1) end
 local popularity=E.Popularity(d)
 local oldStars=E.Stars(d)
 local foodValue=math.floor(base*(1+.03*(rank-1))*timingMultiplier*(featured and 1.15 or 1)*(1+popularity/1000)*(1+.02*oldStars))
 local amount=math.floor(foodValue*(shop.CustomerBonus or 1))
 shop.LastSale={FoodValue=foodValue,Bonus=amount-foodValue,Total=amount,Kind=shop.CustomerKind or "Guest"}
 local oldTier=E.Tier(d)
 local review=shop.CustomerKind=="Reviewer"
 Profiles.Mutate(shop.Owner,function(data)
  local c=career(data);c.Served+=1
  if quality=="Perfect" then c.Perfect+=1 end
  if shop.CustomerKind=="Regular" then data.Shop.RileyServed=(data.Shop.RileyServed or 0)+1 end
  local newTier=E.Tier(data)
  if newTier>oldTier then data.Shop.Bank+=newTier*100;data.Coins+=newTier*25 end
  if E.Stars(data)>oldStars then data.Shop.Bank+=150;data.Coins+=40 end
  return true
 end)
 local nowStars=E.Stars(Profiles.Get(shop.Owner))
 if nowStars>oldStars then
  notice(shop,"Legend Star ★"..nowStars.."! Meals now earn +"..(nowStars*2).."% • +$150 shop funds")
  for p in pairs(shop.Members) do RS.MidnightFeedback:FireClient(p,"LevelUp") end
 end
 if shop.CustomerKind=="Regular" then shop.LastSale.FriendLevel=E.RegularLevel(Profiles.Get(shop.Owner)) end
 if actor then E.Goal(shop,"Manual",actor);E.Tutorial(actor,"Serve") end
 if quality=="Perfect" then E.Goal(shop,"Perfect",actor) end
 local nowTier=E.Tier(Profiles.Get(shop.Owner))
 if nowTier>oldTier then notice(shop,"Restaurant promoted: "..E.Tiers[nowTier].Name.."! New seating and equipment unlocked.") end
 if review then E.Review(shop,quality or "Normal",score,false) end
 if shop.CustomerKind=="Party" then shop.PartyServed=(shop.PartyServed or 0)+1;if shop.PartyIndex==shop.PartySize then notice(shop,"Dinner party complete! "..shop.PartyServed.."/"..shop.PartySize.." guests served.") end end
 return amount
end
function E.SaleNotice(shop)
 if not shop.LastSale then return end
 for p in pairs(shop.Members) do RS.MidnightFeedback:FireClient(p,"SaleBreakdown",shop.LastSale) end
end
function E.Missed(shop)
 if shop.CustomerKind=="Reviewer" then E.Review(shop,"Poor",0,true) end
 if shop.CustomerKind~="Party" then shop.PartyRemaining=0
 else notice(shop,"A party guest left. The remaining guests are still waiting.") end
end
function E.Visuals(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner);local old=shop.Model:FindFirstChild("CareerDisplay")
 if not d then if old then old:Destroy() end;return end
 local level,tier=E.Tier(d)
 local style=shop.Model:FindFirstChild("ShopStyle")
 local board=style and style:FindFirstChild("ThemedFoodMenu")
 if board and board:FindFirstChild("FoodMenu") then
  for i,id in E.Foods(shop) do
   local card=board.FoodMenu:FindFirstChild(id);local label=card and card:FindFirstChild("BaseDish")
   if label then label.Text=d.Shop.FeatureSlot==i and "HOUSE SPECIAL +15%" or "MADE TO ORDER" end
  end
 end
 if old and old:GetAttribute("Tier")==level then return end
 if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="CareerDisplay";folder:SetAttribute("Tier",level);folder.Parent=shop.Model
 local origin=shop.Model.ShopFloor.Position+Vector3.new(0,.5,0)
 local function part(name,size,offset,color)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+offset;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.TopSurface=Enum.SurfaceType.Smooth;p.Parent=folder;return p
 end
 local plaque=part("ReputationPlaque",Vector3.new(5,1,.12),Vector3.new(-9,8.8,9.35),Color3.fromRGB(30,47,51))
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(500,100);gui.LightInfluence=0;gui.Parent=plaque
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.TextColor3=Color3.fromRGB(255,200,100);text.Text="★ "..tier.Name;text.Parent=gui
 if level>=2 then
  local ground=shop.Model.Pavement.Position.Y+shop.Model.Pavement.Size.Y/2
  local platform=part("UnlockedPatio",Vector3.new(6,.2,math.min(level-1,3)*4),Vector3.new(33,.1,math.min(level-1,3)*2-1),Color3.fromRGB(106,89,69))
  platform.Position=Vector3.new(origin.X+33,ground+.1,origin.Z+math.min(level-1,3)*2-1);platform.CanCollide=true
  for i=1,math.min(level-1,3) do
   local z=(i-1)*4+1
   local tabletop=part("UnlockedTable",Vector3.new(2.5,.2,2.5),Vector3.new(33,2.6,z),Color3.fromRGB(151,104,65))
   local tableleg=part("TableLeg",Vector3.new(.25,2.4,.25),Vector3.new(33,1.3,z),Color3.fromRGB(55,69,74))
   tabletop.Position=Vector3.new(origin.X+33,ground+2.6,origin.Z+z);tabletop.CanCollide=true
   tableleg.Position=Vector3.new(origin.X+33,ground+1.3,origin.Z+z)
   for _,x in {31.2,34.8} do
    local seat=Instance.new("Seat");seat.Name="UnlockedSeat";seat.Size=Vector3.new(1.2,.2,1.2);seat.CFrame=CFrame.lookAt(Vector3.new(origin.X+x,ground+1.5,origin.Z+z),Vector3.new(origin.X+33,ground+1.5,origin.Z+z));seat.Color=Color3.fromRGB(112,174,157);seat.Anchored=true;seat.CanCollide=true;seat.Parent=folder
   end
  end
 end
 if level>=3 then
  for _,name in Recipes.Stations do
   local station=shop.Model:FindFirstChild(name)
   if station then
    local panel=part("EquipmentTrim",Vector3.new(station.Size.X-.2,.15,.12),Vector3.zero,Color3.fromRGB(255,197,91))
    panel.CFrame=station.CFrame*CFrame.new(0,.9,-station.Size.Z/2-.07)
   end
  end
 end
end
function E.Sync(shop,state,player,pd)
 if shop.Phase=="Playing" then E.Tutorial(player,"Open") end
 local d=shop.Owner and Profiles.Get(shop.Owner);local personal=Profiles.Get(player)
 local level,tier,nextTier=1,E.Tiers[1],E.Tiers[2];if d then level,tier,nextTier=E.Tier(d) end
 local c=d and career(d) or {Served=0,Perfect=0,Reviews=0,ReviewTotal=0}
 local ping=E.Pings[shop];if ping and ping.Expires<workspace:GetServerTimeNow() then E.Pings[shop]=nil;ping=nil end
 local g=shop.ShiftGoals or {}
 local stars=d and E.Stars(d) or 0
 local nextAt=nextTier and nextTier.Need or (d and E.NextStarAt(d)) or c.Served
 local attrs={RestaurantTier=level,RestaurantRank=tier.Name..(stars>0 and (" ★"..stars) or ""),LegendStars=stars,CareerServed=c.Served,CareerPerfect=c.Perfect,NextRankAt=nextAt,
 ReviewScore=c.Reviews>0 and c.ReviewTotal/c.Reviews or 0,CustomerKind=shop.CustomerKind or "Guest",CustomerTitle=shop.CustomerTitle or "",CustomerBonusPct=math.floor(((shop.CustomerBonus or 1)-1)*100+.5),PartyIndex=shop.CustomerKind=="Party" and (shop.PartyIndex or 0) or 0,PartySize=shop.CustomerKind=="Party" and (shop.PartySize or 0) or 0,Popularity=d and E.Popularity(d) or 0,RushUntil=shop.RushUntil or 0,RushSeconds=math.max(0,math.ceil((shop.RushUntil or 0)-workspace:GetServerTimeNow())),RegularLevel=shop.CustomerRegularLevel or 0,
 SkillTarget=pd.SkillTarget or .65,SkillHit=pd.SkillHit==true,CookQuality=pd.CookQuality or "",HeldQuality=pd.HeldQuality or "Normal",CookScore=pd.CookScore or 0,HeldScore=pd.HeldScore or 0,
 TutorialStep=personal and (personal.TutorialStep or 1) or 1,TeamPing=ping and ping.Message or "",PingStation=ping and ping.Station or "",
 GoalManual=g.Manual or 0,GoalPerfect=g.Perfect or 0,GoalRefills=g.Refills or 0,FeatureSlot=d and d.Shop.FeatureSlot or 0}
 for k,v in attrs do state:SetAttribute(k,v) end
end
function E.Snapshot(player)
 local pd=E.Service.PlayerData[player];local shop=pd and E.Service.Shops[pd.ShopId];local d=shop and shop.Owner and Profiles.Get(shop.Owner);local own=Profiles.Get(player)
 local level,tier,nextTier=1,E.Tiers[1],E.Tiers[2];if d then level,tier,nextTier=E.Tier(d) end
 local c=d and career(d) or {Served=0,Perfect=0,Reviews=0,ReviewTotal=0}
 return {Level=level,Rank=tier.Name,Next=nextTier and nextTier.Need or c.Served,Served=c.Served,Perfect=c.Perfect,Reviews=c.Reviews,Rating=c.Reviews>0 and c.ReviewTotal/c.Reviews or 0,
 Goals=shop and shop.ShiftGoals or {},Popularity=d and E.Popularity(d) or 0,LastReview=d and d.Shop.LastFoodReview or nil,RegularServed=d and (d.Shop.RileyServed or 0) or 0,RegularLevel=d and E.RegularLevel(d) or 1,TutorialStep=own and (own.TutorialStep or 1) or 1,FeatureSlot=d and d.Shop.FeatureSlot or 0,
 Menu=table.clone(Recipes.Theme(d and d.Equipped.Theme or "")),SignatureEnabled=d and d.Shop.SignatureEnabled==true or false,Foods=shop and E.Foods(shop) or Recipes.Theme(""),
 Stars=d and E.Stars(d) or 0,NextStar=d and E.NextStarAt(d) or 0,MaxStars=E.MaxStars}
end
function E.Command(player,action,id)
 local pd=E.Service.PlayerData[player];local shop=pd and E.Service.Shops[pd.ShopId]
 if action=="TutorialSkip" or action=="TutorialReplay" then
  return Profiles.Mutate(player,function(d) d.TutorialStep=action=="TutorialSkip" and 6 or 1;return true,action=="TutorialSkip" and "Training skipped. Replay anytime in Journey." or "Training restarted. Follow the guide." end)
 end
 if not shop or not shop.Members[player] then return false,"Join a kitchen first" end
 if action=="CookSkill" then return E.Skill(player) end
 if action=="SignatureMenu" then
  if shop.Owner~=player then return false,"Owner only" end
  if E.Tier(Profiles.Get(player))<3 then return false,"Reach City Hotspot to unlock Signature Chicken Rice" end
  return Profiles.Mutate(player,function(d) d.Shop.SignatureEnabled=not d.Shop.SignatureEnabled;return true,d.Shop.SignatureEnabled and "Signature Chicken Rice added to your menu" or "Original theme menu restored" end)
 end
 if action=="FeatureDish" then
  if shop.Owner~=player then return false,"Owner only" end
  if E.Tier(Profiles.Get(player))<2 then return false,"Reach Neighborhood Favorite first" end
  local slot=tonumber(id);if not slot or slot%1~=0 or slot<0 or slot>6 then return false,"Unknown menu slot" end
  return Profiles.Mutate(player,function(d) d.Shop.FeatureSlot=slot;return true,slot==0 and "House special removed" or "House special updated. +15% value for this dish." end)
 end
 if action=="CrewPing" then
  local options={Stock={"Need ingredients!","StockNoodles"},Ready={"Meal ready — pick up and serve!",""},Help={"Help at the counter!","Serve"}}
  local option=options[id];if not option then return false,"Choose Stock, Ready or Help" end
  if os.clock()-(E.PingAt[player] or -10)<4 then return false,"Wait before sending another signal" end
  E.PingAt[player]=os.clock()
  local station=option[2]
  if id=="Stock" then station=Recipes.Station(shop.Order) or "NoodleStation"
  elseif id=="Ready" then if shop.Prepared=="" and pd.Held=="" then return false,"No meal ready to signal" end;station=Recipes.Station(shop.Prepared~="" and shop.Prepared or pd.Held) or "Serve" end
  E.Pings[shop]={Message=player.DisplayName..": "..option[1],Station=station,Expires=workspace:GetServerTimeNow()+6}
  for member in pairs(shop.Members) do RS.MidnightFeedback:FireClient(member,"CrewSignal") end
  E.Service.Sync(shop);return true,"Signal sent to your kitchen crew"
 end
 if action=="PassMeal" then
  local target=game.Players:GetPlayerByUserId(tonumber(id) or 0);local other=target and E.Service.PlayerData[target]
  local a=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  local b=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
  if not target or target==player or not shop.Members[target] or not other or other.ShopId~=pd.ShopId or not a or not b or (a.Position-b.Position).Magnitude>7 then return false,"Stand beside a crew member (within 7 studs)" end
  if pd.Held=="" or pd.Cooking~="" or other.Held~="" or other.Cooking~="" then return false,"Hold a meal; your teammate needs empty hands" end
  local inventory=require(script.Parent.Inventory)
  if inventory.Bag(target,shop) or inventory.Bag(player,shop) then return false,"Put away ingredient crates first" end
  other.Held=pd.Held;other.HeldQuality=pd.HeldQuality;other.HeldScore=pd.HeldScore;pd.Held="";pd.HeldQuality=nil;pd.HeldScore=nil
  E.Service.Sync(shop);game.ReplicatedStorage.MidnightNetwork.Notice:FireClient(target,"Dish received from "..player.DisplayName);return true,"Dish passed to "..target.DisplayName
 end
 return false,"Unknown gameplay action"
end
function E.Start(service)
 E.Service=service
 game.Players.PlayerRemoving:Connect(function(p) E.PingAt[p]=nil end)
end
return E
