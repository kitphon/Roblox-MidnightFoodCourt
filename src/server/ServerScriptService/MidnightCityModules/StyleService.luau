local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Marketplace=game:GetService("MarketplaceService")
local Tween=game:GetService("TweenService")
local Http=game:GetService("HttpService")
local Profiles=require(script.Parent.Profiles)
local Legacy=require(script.Parent.Catalog)
local Catalog=require(RS.MidnightStyle.StyleCatalog)
local Renderer=require(RS.MidnightStyle.StyleRenderer)
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local Config=require(RS.MidnightStyle.MonetizationConfig)
local Style={Service=nil,TestCooldown={}}
local function ensure(d)
 d.StylePacks=d.StylePacks or {};d.Shop.DecorSlots=d.Shop.DecorSlots or {}
 if d.UseTeamStyle==nil then d.UseTeamStyle=true end
 for _,k in {"StaffStyle","ShopEffect","TeamStyle"} do if d.Equipped[k]==nil then d.Equipped[k]="" end end
 return d
end
local function rgb(v) return Color3.fromRGB(unpack(v)) end
function Style.GrantPack(player,id)
 local pack=Catalog.Find(id);if not pack or not pack.Items then return false,"Unknown pack" end
 return Profiles.Mutate(player,function(d)
  ensure(d);d.StylePacks[id]=true
  for _,item in pack.Items do d.Owned[item]=true end
  return true,pack.Name.." unlocked"
 end)
end
function Style.CheckPasses(player)
 if Profiles.Sandbox then return end
 for _,pack in Catalog.Packs do
  if pack.PassId>0 then
   local ok,owns=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,pack.PassId) end)
   if ok and owns and Profiles.Get(player) then Style.GrantPack(player,pack.Id) end
  end
 end
end
local function teamLook(player,item,key)
 local char=player.Character;if not char then return end
 if char:GetAttribute("CrewStyleKey")==key then return end
 char:SetAttribute("CrewStyleKey",key)
 for _,v in char:GetChildren() do if v.Name=="StyleCrewApron" or v.Name=="StyleCrewBadge" then v:Destroy() end end
 if not item then return end
 local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso");if not torso then return end
 local apron=Instance.new("Part");apron.Name="StyleCrewApron";apron.Size=Vector3.new(torso.Size.X*.92,torso.Size.Y*.9,.13);apron.Color=rgb(item.Color);apron.CanCollide=false;apron.CanQuery=false;apron.Massless=true;apron.CFrame=torso.CFrame*CFrame.new(0,-.08,-torso.Size.Z/2-.16);apron.Parent=char
 local weld=Instance.new("WeldConstraint");weld.Part0=torso;weld.Part1=apron;weld.Parent=apron
 local badge=Instance.new("Part");badge.Name="StyleCrewBadge";badge.Size=Vector3.new(.25,.25,.05);badge.Color=rgb(item.Accent);badge.Material=Enum.Material.Neon;badge.CanCollide=false;badge.CanQuery=false;badge.Massless=true;badge.CFrame=apron.CFrame*CFrame.new(.25,.3,-.1);badge.Parent=char
 local w=Instance.new("WeldConstraint");w.Part0=apron;w.Part1=badge;w.Parent=badge
end
function Style.Apply(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner)
 local eq=d and ensure(d).Equipped or {}
 local slots=d and d.Shop.DecorSlots or {}
 local key=tostring(shop.Owner and shop.Owner.UserId or 0)..":"..(eq.Theme or "")..":"..Http:JSONEncode(slots)
 if shop.StyleKey~=key then
  shop.StyleKey=key
  shop.Model:SetAttribute("AppliedStyleTheme",eq.Theme or "")
  shop.Model:SetAttribute("AppliedStyleRevision",key)
  for _,p in shop.Model:GetChildren() do if p:IsA("BasePart") then
   if not p:GetAttribute("StyleBaseColor") then p:SetAttribute("StyleBaseColor",p.Color) end
   if p.Name:find("Wall") or p.Name=="BackDoorHeader" or p.Name=="BackroomLeft" or p.Name=="BackroomRight" or p.Name=="CounterTop" or p.Name=="ShopFloor" or p.Name=="BackroomFloor" then p.Color=p:GetAttribute("StyleBaseColor") end
  end end
  local theme=Catalog.Find(eq.Theme)
  if theme then Renderer.Paint(shop.Model,theme)
  else
   local legacy=Legacy.Find(eq.Theme)
   if legacy and legacy.Kind=="Theme" then for _,p in shop.Model:GetChildren() do if p:IsA("BasePart") and (p.Name:find("Wall") or p.Name=="BackDoorHeader") then p.Color=rgb(legacy.Color) end end end
  end
  for slot,stationName in Recipes.Stations do
   local legacy=shop.Model:FindFirstChild("StationIcon_"..stationName)
   if legacy then for _,p in legacy:GetDescendants() do if p:IsA("BasePart") then
    if p:GetAttribute("RecipeBaseTransparency")==nil then p:SetAttribute("RecipeBaseTransparency",p.Transparency) end
    p.Transparency=1 -- Canonical StationDish models now cover default and legacy themes too.
   end end end
   local station=shop.Model:FindFirstChild(stationName);local prompt=station and station:FindFirstChild("Cook")
   if prompt then prompt.ObjectText=Recipes.Get(Recipes.Theme(eq.Theme)[slot]).Name end
  end
  local old=shop.Model:FindFirstChild("ShopStyle");if old then old:Destroy() end
  Renderer.Build(shop.Model,eq.Theme,slots)
 end
 local employees=shop.Model:FindFirstChild("Employees")
 local outfit=Catalog.Find(eq.StaffStyle)
 if employees then for _,m in employees:GetChildren() do
  local outfitKey=(eq.StaffStyle or "")..":"..#m:GetChildren()
  if m:GetAttribute("StaffStyleKey")~=outfitKey and m.PrimaryPart then
   m:SetAttribute("StaffStyleKey",outfitKey)
   local oldAccessory=m:FindFirstChild("StyleAccessory");if oldAccessory then oldAccessory:Destroy() end
   for _,p in m:GetChildren() do if p:IsA("BasePart") then
    if not p:GetAttribute("UniformBaseColor") then p:SetAttribute("UniformBaseColor",p.Color) end
    if p.Name=="Body" or p.Name:find("Arm") or p.Name:find("Apron") or p.Name=="ToolBelt" then p.Color=outfit and rgb(outfit.Color) or p:GetAttribute("UniformBaseColor")
    elseif p.Name=="Neckerchief" or p.Name=="SafetyStripe" or p.Name=="BowTie" then p.Color=outfit and rgb(outfit.Accent) or p:GetAttribute("UniformBaseColor") end
   end end
   if outfit then
    local accessory=Instance.new("Part");accessory.Name="StyleAccessory";accessory.Anchored=true;accessory.CanCollide=false;accessory.CanQuery=false;accessory.Color=rgb(outfit.Accent)
    local offset
    if outfit.Id=="staff_sushi" then accessory.Size=Vector3.new(1.5,.18,1.5);offset=Vector3.new(0,4.7,0)
    elseif outfit.Id=="staff_cyber" then accessory.Size=Vector3.new(1.35,.22,.13);offset=Vector3.new(0,4.3,-.74);accessory.Material=Enum.Material.Neon
    else accessory.Size=Vector3.new(.4,.4,.1);offset=Vector3.new(.4,3,-.63) end
    accessory.CFrame=m.PrimaryPart.CFrame*CFrame.new(offset);accessory.Parent=m
   end
  end
 end end
 for p in pairs(shop.Members) do
  local pd=Profiles.Get(p);local item=pd and ensure(pd).UseTeamStyle and Catalog.Find(eq.TeamStyle) or nil
  teamLook(p,item,item and tostring(shop.Owner.UserId)..eq.TeamStyle or "")
 end
end
function Style.ClearTeam(player) teamLook(player,nil,"") end
function Style.Burst(shop)
 local d=shop.Owner and Profiles.Get(shop.Owner);local item=d and Catalog.Find(d.Equipped.ShopEffect)
 if not item then return end
 local counter=shop.Model.CounterTop
 local anchor=Instance.new("Part");anchor.Name="ServiceCelebration";anchor.Size=Vector3.new(.1,.1,.1);anchor.Position=counter.Position+Vector3.new(0,1,0);anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.Parent=shop.Model
 for i=1,5 do
  local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(34,34);g.StudsOffset=Vector3.new((i-3)*.7,0,0);g.AlwaysOnTop=true;g.Parent=anchor
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=item.Id=="serve_hearts" and "♥" or "★";label.TextColor3=rgb(item.Color);label.TextSize=28;label.Font=Enum.Font.GothamBold;label.Parent=g
  Tween:Create(g,TweenInfo.new(1.2),{StudsOffset=g.StudsOffset+Vector3.new(0,2+i*.2,0)}):Play()
  Tween:Create(label,TweenInfo.new(1.2),{TextTransparency=1}):Play()
 end
 for p in pairs(shop.Members) do RS.MidnightFeedback:FireClient(p,"Style:"..item.Id) end
 task.delay(1.4,function() anchor:Destroy() end)
end
function Style.Snapshot(player)
 local d=Profiles.Get(player);if not d then return nil end;ensure(d)
 return {Items=Catalog.Items,Packs=Catalog.Packs,Slots=Catalog.Slots,Owned=d.Owned,Equipped=d.Equipped,PacksOwned=d.StylePacks,DecorSlots=d.Shop.DecorSlots,UseTeamStyle=d.UseTeamStyle,Sandbox=Profiles.Sandbox}
end
function Style.Command(player,action,id)
 local d=Profiles.Get(player);if not d then return false,"Profile loading" end;ensure(d)
 local pd=Style.Service.PlayerData[player];local shop=pd and Style.Service.Shops[pd.ShopId]
 if action=="StyleVisit" then
  local target=Style.Service.Shops[tonumber(id)]
  if not target or not target.Owner or not player.Character or player:GetAttribute("InTransit") then return false,"Kitchen unavailable" end
  player.Character:PivotTo(CFrame.new(target.Model.ShopFloor.Position+Vector3.new(24,4,-10)))
  return true,"Visiting "..target.Owner.DisplayName.."'s kitchen"
 end
 if action=="StyleTeamOpt" then
  local ok,msg=Profiles.Mutate(player,function(profile) ensure(profile);profile.UseTeamStyle=not profile.UseTeamStyle;return true,profile.UseTeamStyle and "Crew outfit enabled" or "Using your own outfit" end)
  if shop then Style.Apply(shop) end;return ok,msg
 end
 local item=Catalog.Find(id)
 if action=="StyleTestGems" or action=="StyleTestPack" then
  if not game:GetService("RunService"):IsStudio() or not Profiles.Sandbox or not Config.EnableStudioTesting then return false,"Studio testing only" end
  if os.clock()-(Style.TestCooldown[player.UserId] or -10)<.5 then return false,"Please wait" end
  Style.TestCooldown[player.UserId]=os.clock()
  if action=="StyleTestPack" then return Style.GrantPack(player,id) end
  local product=Legacy.Find(id)
  if not product or not product.ProductId or not product.Gems or product.Kind then return false,"Unknown gem pack" end
  return Profiles.Mutate(player,function(profile) profile.Gems+=product.Gems;return true,"Studio test: +"..product.Gems.." Gems. No Robux charged." end)
 end
 if action=="StylePlace" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  local slot,itemId=tostring(id):match("^(%a+):([%w_]*)$")
  local valid=false;for _,v in Catalog.Slots do if v==slot then valid=true end end
  if not valid then return false,"Unknown decoration spot" end
  local decor=Catalog.Find(itemId)
  if itemId~="" and (not decor or decor.Kind~="Decoration" or decor.Slot~=slot or not d.Owned[itemId]) then return false,"Decoration not owned or wrong spot" end
  local ok,msg=Profiles.Mutate(player,function(profile) ensure(profile);profile.Shop.DecorSlots[slot]=itemId~="" and itemId or nil;return true,"Decoration updated" end)
  if ok then Style.Apply(shop) end;return ok,msg
 end
 if action=="StyleApplyPack" then
  if not shop or shop.Owner~=player then return false,"Owner only" end
  if not item or not item.Items then return false,"Pack unavailable" end
  local ok,msg=Profiles.Mutate(player,function(profile)
   ensure(profile)
   for _,itemId in item.Items do if not profile.Owned[itemId] then return false,"Unlock this pack first" end end
   for _,itemId in item.Items do local entry=Catalog.Find(itemId);if entry.Kind=="Decoration" then profile.Shop.DecorSlots[entry.Slot]=entry.Id else profile.Equipped[entry.Kind]=entry.Id end end
   return true,"Pack applied"
  end)
  if ok then Style.Apply(shop) end;return ok,msg
 end
 if action=="StylePack" then
  if not item or not item.Items then return false,"Pack unavailable" end
  if d.StylePacks[id] then return false,"You own this pack" end
  if Profiles.Sandbox or item.PassId<=0 then return false,"Robux purchases are coming soon. Try Preview." end
  local ok,owns=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,item.PassId) end)
  if not ok then return false,"Purchase connection unavailable" end
  if owns then local granted,msg=Style.GrantPack(player,id);Style.Service.SyncPlayer(player);return granted,msg end
  local prompted=pcall(function() Marketplace:PromptGamePassPurchase(player,item.PassId) end)
  return prompted,prompted and "Complete the Roblox purchase prompt" or "Purchase unavailable"
 end
 if not item or item.Items then return false,"Item unavailable" end
 if action=="StyleBuy" then
  local ok,msg=Profiles.Mutate(player,function(profile)
   ensure(profile);if profile.Owned[id] then return false,"Already owned" end
   local price=math.max(0,math.floor(item.Gems))
   if profile.Gems<price then return false,"Not enough Gems" end
   profile.Gems-=price;profile.Owned[id]=true;return true,item.Name.." unlocked"
  end)
  Style.Service.SyncPlayer(player);return ok,msg
 elseif action=="StyleEquip" then
  if not d.Owned[id] then return false,"Unlock this item first" end
  if not shop or shop.Owner~=player then return false,"Only the owner can style this kitchen. Your items stay in your collection." end
  if item.Kind=="Decoration" then return Style.Command(player,"StylePlace",item.Slot..":"..id) end
  local ok,msg=Profiles.Mutate(player,function(profile) ensure(profile);profile.Equipped[item.Kind]=profile.Equipped[item.Kind]==id and "" or id;return true,"Style updated" end)
  if ok then Style.Apply(shop) end;Style.Service.SyncPlayer(player);return ok,msg
 end
 return false,"Unknown style action"
end
function Style.Start(service)
 Style.Service=service
 Players.PlayerRemoving:Connect(function(p) Style.TestCooldown[p.UserId]=nil end)
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
  if not purchased then return end
  for _,pack in Catalog.Packs do if pack.PassId==passId and passId>0 then
   local ok,owns=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,passId) end)
   if ok and owns and Profiles.Get(player) then Style.GrantPack(player,pack.Id);service.SyncPlayer(player);RS.MidnightNetwork.Notice:FireClient(player,pack.Name.." unlocked") end
  end end
 end)
 for _,shop in service.Shops do
  local marker=Instance.new("Part");marker.Name="PhotoSpot";marker.Size=Vector3.new(4,.12,4);marker.Color=Color3.fromRGB(103,217,191);marker.Material=Enum.Material.Neon;marker.Anchored=true;marker.CanCollide=false;marker.Position=shop.Model.ShopFloor.Position+Vector3.new(25,-.39,-8);marker.Parent=shop.Model
  local prompt=Instance.new("ProximityPrompt");prompt.Name="Photo";prompt.ActionText="Photo mode";prompt.ObjectText="Kitchen photo spot";prompt.MaxActivationDistance=8;prompt.HoldDuration=.2;prompt.Parent=marker
  prompt.Triggered:Connect(function(p)
   local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if root and (root.Position-marker.Position).Magnitude<=10 then RS.MidnightNetwork.OpenPanel:FireClient(p,"Photo:"..shop.Id) end
  end)
 end
 local function join(p) task.spawn(function()
  local untilAt=os.clock()+20
  repeat task.wait(.2) until Profiles.Get(p) or not p.Parent or os.clock()>untilAt
  if p.Parent and Profiles.Get(p) then Style.CheckPasses(p);service.SyncPlayer(p) end
 end) end
 Players.PlayerAdded:Connect(join);for _,p in Players:GetPlayers() do join(p) end
end
return Style
