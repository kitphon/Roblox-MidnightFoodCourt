
local Tween=game:GetService("TweenService")
local RS=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.Catalog)
local Flow={}
local function clearCompanions(shop)
 for _,name in {"PartyCompanions","PartyServed"} do local group=shop.Model:FindFirstChild(name);if group then group:Destroy() end end
end
local activeTweens=setmetatable({},{__mode="k"})
local sequence=0
local shirts={{65,120,128},{161,83,79},{88,104,153},{139,111,68},{110,139,91},{142,94,137},{72,130,162},{169,119,76}}
local skins={{219,178,141},{171,124,88},{237,199,167},{126,88,66}}
local names={"Alex","Mia","Kai","Nora","Leo","Ivy","Sam","Zoe"}
local function frameAt(shop)
 local counter,floor=shop.Model.CounterTop,shop.Model.ShopFloor
 local outward=counter.Position-floor.Position;outward=Vector3.new(outward.X,0,outward.Z).Unit
 local half=math.abs(outward:Dot(counter.CFrame.RightVector))*counter.Size.X/2+math.abs(outward:Dot(counter.CFrame.LookVector))*counter.Size.Z/2
 local point=counter.Position+outward*(half+1.8)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={shop.Model.Pavement,workspace.MidnightCity}
 local hit=workspace:Raycast(Vector3.new(point.X,counter.Position.Y+6,point.Z),Vector3.new(0,-30,0),params)
 local y=hit and hit.Position.Y or shop.Model.Pavement.Position.Y+shop.Model.Pavement.Size.Y/2
 local foot=Vector3.new(point.X,y,point.Z)
 return CFrame.lookAt(foot,Vector3.new(counter.Position.X,y,counter.Position.Z)),outward
end
local function walk(m,point)
 if not m.Parent then return false end
 if activeTweens[m] then activeTweens[m]:Cancel();activeTweens[m]=nil end
 local from=m:GetPivot().Position;local delta=point-from
 if delta.Magnitude<.05 then return true end
 local start=CFrame.lookAt(from,point);m:PivotTo(start)
 local value=Instance.new("CFrameValue");value.Value=start
 local began=os.clock()
 local legL,legR=m:FindFirstChild("LeftLeg"),m:FindFirstChild("RightLeg")
 local armL,armR=m:FindFirstChild("LeftArm"),m:FindFirstChild("RightArm")
 local handL,handR=m:FindFirstChild("LeftHand"),m:FindFirstChild("RightHand")
 local shoeL,shoeR=m:FindFirstChild("LeftShoe"),m:FindFirstChild("RightShoe")
 local connection=value.Changed:Connect(function(cf)
  if not m.Parent then return end
  m:PivotTo(cf)
  local swing=math.sin((os.clock()-began)*12)*.28
  local legLCf=cf*CFrame.new(-.45,.75,0)*CFrame.Angles(swing,0,0)
  local legRCf=cf*CFrame.new(.45,.75,0)*CFrame.Angles(-swing,0,0)
  local armLCf=cf*CFrame.new(-1.05,2.62,0)*CFrame.Angles(-swing,0,0)
  local armRCf=cf*CFrame.new(1.05,2.62,0)*CFrame.Angles(swing,0,0)
  if legL then legL.CFrame=legLCf end
  if legR then legR.CFrame=legRCf end
  if shoeL then shoeL.CFrame=legLCf*CFrame.new(0,-.72,-.12) end
  if shoeR then shoeR.CFrame=legRCf*CFrame.new(0,-.72,-.12) end
  if armL then armL.CFrame=armLCf end
  if armR then armR.CFrame=armRCf end
  if handL then handL.CFrame=armLCf*CFrame.new(0,-.72,0) end
  if handR then handR.CFrame=armRCf*CFrame.new(0,-.72,0) end
 end)
 local speed=math.max(1,Catalog.Get("CustomerWalkSpeed",7))*(m:GetAttribute("VisitSpeed") or 1)
 local tween=Tween:Create(value,TweenInfo.new(delta.Magnitude/speed,Enum.EasingStyle.Linear),{Value=CFrame.lookAt(point,point+delta.Unit)})
 local removed=m.Destroying:Connect(function() tween:Cancel() end)
 activeTweens[m]=tween
 tween:Play();local status=tween.Completed:Wait()
 if activeTweens[m]==tween then activeTweens[m]=nil end
 removed:Disconnect();connection:Disconnect();value:Destroy()
 if status~=Enum.PlaybackState.Completed or not m.Parent then return false end
 local cf=m:GetPivot()
 if legL then legL.CFrame=cf*CFrame.new(-.45,.75,0) end
 if legR then legR.CFrame=cf*CFrame.new(.45,.75,0) end
 if shoeL then shoeL.CFrame=cf*CFrame.new(-.45,.03,-.12) end
 if shoeR then shoeR.CFrame=cf*CFrame.new(.45,.03,-.12) end
 if armL then armL.CFrame=cf*CFrame.new(-1.05,2.62,0) end
 if armR then armR.CFrame=cf*CFrame.new(1.05,2.62,0) end
 if handL then handL.CFrame=cf*CFrame.new(-1.05,1.9,0) end
 if handR then handR.CFrame=cf*CFrame.new(1.05,1.9,0) end
 return true
end
local function icon(m,food)
 local old=m:FindFirstChild("OrderIcon");if old then old:Destroy() end
 local template=RS.MidnightIcons:FindFirstChild(food)
 if template then local clone=template:Clone();clone.Name="OrderIcon";clone:ScaleTo(.6);clone.Parent=m;clone:PivotTo(m:GetPivot()*CFrame.new(0,5.3,0)) end
end
function Flow.Clear(shop)
 clearCompanions(shop)
 local shadow=shop.Model:FindFirstChild("BanishShadow");if shadow then shadow:Destroy() end
 if shop.Customer then local m=shop.Customer;shop.Customer=nil;m:Destroy() end
 shop.CustomerStage="Idle";shop.CustomerName=""
end
function Flow.Shadow(shop,enabled)
 local old=shop.Model:FindFirstChild("BanishShadow");if old then old:Destroy() end
 if not enabled or not shop.Customer then return end
 -- A separate apparition leaves the actual guest and their order untouched.
 local m=shop.Customer:Clone();m.Name="BanishShadow";m:SetAttribute("Activity","Shadow");m:SetAttribute("Shadow",true)
 for _,p in ipairs(m:GetDescendants()) do
  if p:IsA("BillboardGui") or p.Name=="OrderIcon" then p:Destroy()
  elseif p:IsA("BasePart") then
   p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
   p.Color=p.Name=="Eye" and Color3.fromRGB(255,65,81) or Color3.fromRGB(16,17,24)
  end
 end
 local ward,radio=shop.Model.Ward,shop.Model.Radio
 local foot=ward.Position+Vector3.new(0,ward.Size.Y/2,0)
 m:PivotTo(CFrame.lookAt(foot,Vector3.new(radio.Position.X,foot.Y,radio.Position.Z)))
 m.Parent=shop.Model
end
function Flow.Spawn(shop,food,onArrive)
 -- Keep the actual waiting party guests and promote each one to the counter.
 local queue=shop.Model:FindFirstChild("PartyCompanions")
 if shop.CustomerKind=="Party" and (shop.PartyIndex or 1)>1 and queue and #queue:GetChildren()>0 then
  local guests=queue:GetChildren()
  table.sort(guests,function(a,b) return (a:GetAttribute("PartyMember") or 0)<(b:GetAttribute("PartyMember") or 0) end)
  local m=guests[1];m.Parent=shop.Model;m.Name="Customer";sequence+=1
  m:SetAttribute("CustomerId",sequence);m:SetAttribute("Activity","Arriving");m:SetAttribute("OrderCount",1)
  shop.Customer=m;shop.CustomerStage="Arriving";shop.CustomerName="Party Guest "..shop.PartyIndex
  m:SetAttribute("CustomerName",shop.CustomerName);m:SetAttribute("CustomerKind","Party")
  local stand=frameAt(shop)
  local head=m:FindFirstChild("Head")
  if head then
   local g=Instance.new("BillboardGui");g.Name="CustomerPersona";g.Size=UDim2.fromOffset(210,32);g.StudsOffset=Vector3.new(0,1.6,0);g.AlwaysOnTop=true;g.Parent=head
   local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(22,38,44);label.BackgroundTransparency=.15;label.Text=shop.CustomerTitle;label.TextColor3=Color3.fromRGB(166,235,211);label.Font=Enum.Font.GothamBold;label.TextSize=14;label.Parent=g
  end
  task.spawn(function()
   if not walk(m,stand.Position) or shop.Customer~=m then return end
   m:PivotTo(stand);m:SetAttribute("Activity","Ordering");shop.CustomerStage="Ordering";icon(m,food);onArrive(m)
  end)
  return m
 end
 Flow.Clear(shop);sequence+=1
 local serial=sequence
 local stand,outward=frameAt(shop)
 local side=stand.RightVector
 local start=stand.Position+outward*4+side*((serial%2==0 and -1 or 1)*14)
 local m=Instance.new("Model");m.Name="Customer";m:SetAttribute("CustomerId",serial);m:SetAttribute("OrderCount",1);m:SetAttribute("Activity","Arriving");m.Parent=shop.Model
 shop.Customer=m;shop.CustomerStage="Arriving";shop.CustomerName=names[(serial-1)%#names+1]
 m:SetAttribute("CustomerName",shop.CustomerName)
 local facing=CFrame.lookAt(start,stand.Position+outward*4)
 local function part(n,size,pos,col,shape)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.CFrame=facing*CFrame.new(pos);a.Color=col;a.Anchored=true;a.CanCollide=false;a.CanTouch=false;a.CanQuery=false;a.TopSurface=Enum.SurfaceType.Smooth;a.BottomSurface=Enum.SurfaceType.Smooth;if shape then a.Shape=shape end;a.Parent=m;return a
 end
 local root=part("Root",Vector3.new(.02,.02,.02),Vector3.zero,Color3.new());root.Transparency=1;m.PrimaryPart=root
 local shirt=Color3.fromRGB(unpack(shirts[(serial-1)%#shirts+1]))
 local skin=Color3.fromRGB(unpack(skins[(serial-1)%#skins+1]))
 if shop.CustomerKind=="Regular" then shirt=Color3.fromRGB(57,133,119);skin=Color3.fromRGB(219,178,141) end
 m:SetAttribute("VisitSpeed",shop.RushUntil and shop.RushUntil>workspace:GetServerTimeNow() and 1.3 or 1)
 local dark=Color3.fromRGB(30,36,45)
 local hair=serial%2==0 and Color3.fromRGB(77,52,35) or dark
 local accent=Color3.fromRGB(unpack(shirts[(serial+2)%#shirts+1]))
 local shoe=serial%3==0 and Color3.fromRGB(132,92,64) or Color3.fromRGB(23,28,36)
 part("LeftLeg",Vector3.new(.6,1.5,.7),Vector3.new(-.45,.75,0),dark)
 part("RightLeg",Vector3.new(.6,1.5,.7),Vector3.new(.45,.75,0),dark)
 part("LeftShoe",Vector3.new(.68,.32,.95),Vector3.new(-.45,.03,-.12),shoe)
 part("RightShoe",Vector3.new(.68,.32,.95),Vector3.new(.45,.03,-.12),shoe)
 part("Body",Vector3.new(1.8,1.9,1),Vector3.new(0,2.45,0),shirt)
 part("LeftArm",Vector3.new(.46,1.2,.56),Vector3.new(-1.05,2.62,0),shirt)
 part("RightArm",Vector3.new(.46,1.2,.56),Vector3.new(1.05,2.62,0),shirt)
 part("LeftHand",Vector3.new(.48,.38,.58),Vector3.new(-1.05,1.9,0),skin,Enum.PartType.Ball)
 part("RightHand",Vector3.new(.48,.38,.58),Vector3.new(1.05,1.9,0),skin,Enum.PartType.Ball)
 part("Head",Vector3.new(1.4,1.4,1.4),Vector3.new(0,4.1,0),skin,Enum.PartType.Ball)
 part("Hair",Vector3.new(1.44,.4,1.42),Vector3.new(0,4.65,.03),hair)
 local hairStyle=serial%4
 if hairStyle==0 then
  part("HairBack",Vector3.new(1.4,1.05,.32),Vector3.new(0,4.28,.58),hair)
  part("HairSide",Vector3.new(.25,.75,.75),Vector3.new(-.67,4.32,.18),hair)
 elseif hairStyle==1 then
  part("HairSweep",Vector3.new(.75,.25,1.43),Vector3.new(-.32,4.73,-.02),hair)
 elseif hairStyle==2 then
  part("HairSide",Vector3.new(.26,.82,.8),Vector3.new(.66,4.3,.18),hair)
  part("HairSide",Vector3.new(.26,.82,.8),Vector3.new(-.66,4.3,.18),hair)
 else
  part("HairBun",Vector3.new(.62,.62,.62),Vector3.new(0,4.95,.32),hair,Enum.PartType.Ball)
 end
 for _,x in ipairs({-.28,.28}) do
  local e=part("Eye",Vector3.new(.14,.17,.06),Vector3.new(x,4.22,-.67),dark);e.Material=Enum.Material.Neon
  local shine=part("EyeShine",Vector3.new(.045,.055,.025),Vector3.new(x-.025,4.26,-.715),Color3.fromRGB(235,248,245));shine.Material=Enum.Material.Neon
  part("Brow",Vector3.new(.3,.055,.055),Vector3.new(x,4.43,-.66),hair)
 end
 part("Nose",Vector3.new(.1,.13,.07),Vector3.new(0,4.07,-.7),skin:Lerp(Color3.fromRGB(112,72,66),.18),Enum.PartType.Ball)
 part("Smile",Vector3.new(.34,.055,.055),Vector3.new(0,3.89,-.68),skin:Lerp(Color3.fromRGB(92,40,53),.7))
 local blush=skin:Lerp(Color3.fromRGB(235,102,118),.38)
 part("LeftBlush",Vector3.new(.18,.07,.035),Vector3.new(-.43,4.01,-.66),blush)
 part("RightBlush",Vector3.new(.18,.07,.035),Vector3.new(.43,4.01,-.66),blush)
 part("Collar",Vector3.new(1.1,.16,1.04),Vector3.new(0,3.34,0),accent)
 if serial%3==0 and shop.CustomerKind~="Regular" then
  part("Cap",Vector3.new(1.55,.2,1.7),Vector3.new(0,4.92,-.1),shirt)
  part("CapBrim",Vector3.new(.9,.09,.4),Vector3.new(0,4.84,-.78),shirt)
 elseif serial%3==1 then
  part("ChestStripe",Vector3.new(1.82,.22,1.02),Vector3.new(0,2.55,0),accent)
 else
  part("Pocket",Vector3.new(.42,.38,.07),Vector3.new(.48,2.55,-.53),accent)
 end
 if shop.CustomerKind=="Regular" then
  m.Hair.Color=Color3.fromRGB(70,45,32)
  m:SetAttribute("RegularId","riley")
  for _,x in {-.3,.3} do
   part("RileyGlasses",Vector3.new(.47,.28,.055),Vector3.new(x,4.23,-.72),Color3.fromRGB(37,44,51))
   part("RileyLens",Vector3.new(.33,.17,.06),Vector3.new(x,4.23,-.76),Color3.fromRGB(165,215,214))
  end
  part("GlassesBridge",Vector3.new(.16,.055,.06),Vector3.new(0,4.23,-.76),Color3.fromRGB(37,44,51))
  part("RileyScarf",Vector3.new(1.05,.16,1.08),Vector3.new(0,3.35,0),Color3.fromRGB(221,165,87))
 end
 local head=m:FindFirstChild("Head")
 if head then
  local g=Instance.new("BillboardGui");g.Name="CustomerPersona";g.Size=UDim2.fromOffset(190,32);g.StudsOffset=Vector3.new(0,1.6,0);g.AlwaysOnTop=true;g.Parent=head
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(22,38,44);label.BackgroundTransparency=.15;label.Text=shop.CustomerTitle or "Guest";label.TextColor3=shop.CustomerKind=="Reviewer" and Color3.fromRGB(255,203,91) or Color3.fromRGB(166,235,211);label.Font=Enum.Font.GothamBold;label.TextSize=14;label.Parent=g
 end
 if shop.CustomerKind=="Reviewer" then part("ReviewerBadge",Vector3.new(.35,.4,.06),Vector3.new(.4,2.7,-.54),Color3.fromRGB(255,198,72)) end
 if shop.CustomerKind=="Party" and shop.PartyIndex==1 and (shop.PartyRemaining or 0)>0 then
  local group=Instance.new("Folder");group.Name="PartyCompanions";group.Parent=shop.Model
  for i=1,shop.PartyRemaining do
   local guest=m:Clone();guest.Name="WaitingPartyGuest";guest:SetAttribute("Activity","WaitingForFriend");guest:SetAttribute("PartyMember",i+1)
   for _,v in guest:GetDescendants() do if v:IsA("BillboardGui") then v:Destroy() end end
   if guest:FindFirstChild("Body") then guest.Body.Color=Color3.fromRGB(unpack(shirts[(serial+i-1)%#shirts+1])) end
   guest.Parent=group;guest:PivotTo(facing*CFrame.new(i*2.5,0,2))
   local waitAt=stand.Position+outward*3.5+side*(i*2.8)
   task.spawn(function() walk(guest,waitAt) end)
  end
 end
 task.spawn(function()
  if not walk(m,stand.Position+outward*4) then return end
  if not walk(m,stand.Position) then return end
  if shop.Customer~=m then return end
  m:PivotTo(stand);m:SetAttribute("Activity","Ordering");shop.CustomerStage="Ordering";icon(m,food);onArrive(m)
 end)
 return m
end
function Flow.Say(shop,message)
 local m=shop.Customer;if not m then return end
 local old=m:FindFirstChild("CustomerReply");if old then old:Destroy() end
 local head=m:FindFirstChild("Head");if not head then return end
 local g=Instance.new("BillboardGui");g.Name="CustomerReply";g.Adornee=head;g.Size=UDim2.fromOffset(180,32);g.StudsOffset=Vector3.new(0,3,0);g.AlwaysOnTop=true;g.Parent=m
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(22,39,46);label.BackgroundTransparency=.1;label.TextColor3=Color3.fromRGB(244,226,181);label.Font=Enum.Font.GothamBold;label.TextSize=15;label.Text=message;label.Parent=g
 task.delay(4,function() if g.Parent then g:Destroy() end end)
end
function Flow.ChangeOrder(shop,food)
 local m=shop.Customer;if not m or shop.CustomerStage~="Ordering" then return end
 m:SetAttribute("OrderRevision",(m:GetAttribute("OrderRevision") or 0)+1)
 icon(m,food)
 Flow.Say(shop,"Another menu, please!")
end
function Flow.Depart(shop,food,onExit)
 shop.DepartureSerial=(shop.DepartureSerial or 0)+1
 local ticket=shop.DepartureSerial
 local m=shop.Customer
 local stand,outward=frameAt(shop);local side=stand.RightVector
 local function addTakeaway(model)
  local orderIcon=model:FindFirstChild("OrderIcon");if orderIcon then orderIcon:Destroy() end
  if food and not model:FindFirstChild("Takeaway") then
   local template=RS.MidnightIcons:FindFirstChild(food)
   if template then local bag=template:Clone();bag.Name="Takeaway";bag:ScaleTo(.45);bag.Parent=model;bag:PivotTo(model:GetPivot()*CFrame.new(0,2,-1.1)) end
   model:SetAttribute("HasTakeaway",true)
  end
 end
 if m then addTakeaway(m) end
 if m and shop.CustomerKind=="Party" and shop.Phase=="Playing" and (shop.PartyRemaining or 0)>0 then
  local served=shop.Model:FindFirstChild("PartyServed")
  if not served then served=Instance.new("Folder");served.Name="PartyServed";served.Parent=shop.Model end
  m.Parent=served;m:SetAttribute("Activity","WaitingForParty")
  local member=shop.PartyIndex or 1
  m:SetAttribute("PartyMember",member)
  local label=m:FindFirstChild("CustomerPersona",true)
  if label then local text=label:FindFirstChildOfClass("TextLabel");if text then text.Text=food and "Meal received • Waiting for friends" or "Waiting for friends" end end
  shop.CustomerStage="PartyWaiting"
  local waitAt=stand.Position+outward*3.5-side*(member*2.8)
  task.spawn(function()
   if not walk(m,stand.Position+outward*2) then return end
   if not walk(m,waitAt) then return end
   if shop.DepartureSerial~=ticket or shop.Customer~=m then return end
   m:PivotTo(CFrame.lookAt(waitAt,stand.Position));m:SetAttribute("Activity","WaitingForParty")
   shop.Customer=nil;shop.CustomerStage="Idle";shop.CustomerName=""
   onExit()
  end)
  return
 end
 local companions=shop.Model:FindFirstChild("PartyCompanions")
 local served=shop.Model:FindFirstChild("PartyServed")
 if companions or served then
  -- Last member (or explicit closure): the entire party leaves as one group.
  local guests={};local seen={}
  local function include(model)
   if model and model.Parent and not seen[model] then seen[model]=true;table.insert(guests,model) end
  end
  if served then for _,guest in served:GetChildren() do include(guest) end end
  if companions then for _,guest in companions:GetChildren() do include(guest) end end
  include(m)
  shop.CustomerStage="Leaving"
  local remaining=#guests
  if remaining==0 then
   clearCompanions(shop);shop.Customer=nil;shop.CustomerStage="Idle";shop.CustomerName="";onExit();return
  end
  for i,guest in guests do
   guest:SetAttribute("Activity","LeavingTogether")
   local persona=guest:FindFirstChild("CustomerPersona",true)
   if persona then local text=persona:FindFirstChildOfClass("TextLabel");if text then text.Text="Heading home together" end end
   task.spawn(function()
    local lane=(i-1)*1.9
    local walked=walk(guest,stand.Position+outward*(4+lane))
    if walked and shop.DepartureSerial==ticket then walk(guest,stand.Position+outward*(4+lane)+side*18) end
    if shop.DepartureSerial~=ticket then return end
    if guest.Parent then guest:Destroy() end
    remaining-=1
    if remaining==0 then
     clearCompanions(shop);shop.Customer=nil;shop.CustomerStage="Idle";shop.CustomerName=""
     task.wait(Catalog.Get("CustomerSpacingSeconds",.5))
     if shop.DepartureSerial==ticket then onExit() end
    end
   end)
  end
  return
 end
 if not m then onExit();return end
 shop.CustomerStage="Leaving";m:SetAttribute("Activity","Leaving")
 task.spawn(function()
  if not walk(m,stand.Position+outward*4) then return end
  if not walk(m,stand.Position+outward*4+side*16) then return end
  if shop.DepartureSerial~=ticket or shop.Customer~=m then return end
  shop.Customer=nil;m:Destroy();shop.CustomerStage="Idle";shop.CustomerName=""
  task.wait(Catalog.Get("CustomerSpacingSeconds",.5)*(shop.RushUntil and shop.RushUntil>workspace:GetServerTimeNow() and .5 or 1))
  if shop.DepartureSerial==ticket then onExit() end
 end)
end

return Flow
