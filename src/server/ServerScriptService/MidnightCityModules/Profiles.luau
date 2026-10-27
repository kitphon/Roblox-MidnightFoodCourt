
local DataStoreService=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local Catalog=require(script.Parent.Catalog)
-- Set the StudioUsesDataStore attribute on MidnightCityModules (and enable Studio API access) to test real saves in Studio.
-- Studio saves go to a separate store so tests never touch live player data.
local studioStore=Run:IsStudio() and script.Parent:GetAttribute("StudioUsesDataStore")==true
-- Studio-only simulation: ignore real entitlements and keep all purchases in memory.
local purchaseSimulation=Run:IsStudio() and script.Parent:GetAttribute("StudioPurchaseSimulation")==true
local Profiles={Sessions={},Sandbox=purchaseSimulation or game.GameId==0 or (Run:IsStudio() and not studioStore)}
local store
if not Profiles.Sandbox then store=DataStoreService:GetDataStore(Run:IsStudio() and "MidnightCityProfiles_v1_Studio" or "MidnightCityProfiles_v1") end
local token=game.JobId~="" and game.JobId or Http:GenerateGUID(false)
local busy={}
-- Plain deep copy; profiles only hold tables, strings, numbers and booleans. Much cheaper than a JSON round-trip.
local function copy(t)
 if type(t)~="table" then return t end
 local out={}
 for k,v in pairs(t) do out[k]=copy(v) end
 return out
end
Profiles.Copy=copy
local function new()
 return {Version=2,StylePacks={},UseTeamStyle=true,Coins=Catalog.Get("StarterCoins"),Gems=0,Owned={},Equipped={Theme="",Uniform="",Effect="",Emote="",StaffStyle="",ShopEffect="",TeamStyle=""},Shop={DecorSlots={},Bank=Catalog.Get("StarterBank"),Upgrades={Kitchen=0,Service=0,Decor=0,Space=0},Workers={}},Receipts={}}
end
local function clean(d)
 if type(d)~="table" then d=new() end
 local defaults=new()
 for k,v in pairs(defaults) do if d[k]==nil then d[k]=v end end
 for k,v in pairs(defaults.Equipped) do if d.Equipped[k]==nil then d.Equipped[k]=v end end
 for k,v in pairs(defaults.Shop) do if d.Shop[k]==nil then d.Shop[k]=v end end
 for k,v in pairs(defaults.Shop.Upgrades) do if type(d.Shop.Upgrades[k])~="number" then d.Shop.Upgrades[k]=v end end
 return d
end
function Profiles.MergeReceipts(candidate,old)
 for id,amount in pairs(old and old.Receipts or {}) do
  if not candidate.Receipts[id] then
   candidate.Receipts[id]=amount
   if type(amount)=="number" then candidate.Gems+=amount end
  end
 end
 return candidate
end
function Profiles.BuildReceipt(base,old,purchaseId,gems)
 local candidate=Profiles.MergeReceipts(copy(base),old)
 if not candidate.Receipts[purchaseId] then candidate.Gems+=gems;candidate.Receipts[purchaseId]=gems end
 return candidate
end
local function lock(id)
 while busy[id] do task.wait() end
 busy[id]=true
end
local function unlock(id) busy[id]=nil end
function Profiles.Load(player)
 local id=player.UserId
 lock(id)
 local data,problem
 if Profiles.Sandbox then data=new() else
  -- Retry for ~30s: the previous server usually releases the session lock within a few seconds of a server hop.
  for attempt=1,6 do
   local ok,result=pcall(function()
    return store:UpdateAsync("u_"..id,function(old)
     old=clean(old)
     if old.Session and old.Session.Token~=token and old.Session.Expires>os.time() then return nil end
     old.Session={Token=token,Expires=os.time()+180}
     return old
    end)
   end)
   if ok and result then data=result;problem=nil;break end
   problem=ok and "Your save is open on another server. Rejoin shortly." or "Your save could not load. Please rejoin."
   if attempt<6 then
    task.wait(5)
    if not player.Parent then break end
   end
  end
 end
 if data then Profiles.Sessions[id]={Data=clean(data),Player=player} end
 unlock(id)
 return data,problem
end
function Profiles.Get(player) local s=Profiles.Sessions[player.UserId];return s and s.Data end
function Profiles.Mutate(player,fn)
 local id=player.UserId;lock(id)
 local s=Profiles.Sessions[id]
 if not s or s.Closing then unlock(id);return false,"Profile unavailable" end
 local trial=copy(s.Data)
 local ok,allowed,message=pcall(fn,trial)
 if ok and allowed~=false then s.Data=trial;s.Dirty=true end
 unlock(id)
 if not ok then warn("Profile transaction rejected",allowed);return false,"Transaction failed" end
 return allowed~=false,message
end
function Profiles.Save(player,release)
 local id=player.UserId;lock(id);local s=Profiles.Sessions[id]
 if not s then unlock(id);return false end
 if release then s.Closing=true end
 local success=true
 if not Profiles.Sandbox then
  local snapshot=copy(s.Data)
  local ok,result=pcall(function()
   return store:UpdateAsync("u_"..id,function(old)
    if not old or not old.Session or old.Session.Token~=token then return nil end
    local candidate=Profiles.MergeReceipts(copy(snapshot),old)
    if release then candidate.Session=nil else candidate.Session={Token=token,Expires=os.time()+180} end
    return candidate
   end)
  end)
  success=ok and result~=nil
  if success then s.Data=result;s.Dirty=false elseif not release then
   s.Player:Kick("Save connection lost. Please rejoin to protect your progress.")
  end
 end
 if release and success then Profiles.Sessions[id]=nil end
 unlock(id);return success
end
function Profiles.Receipt(player,purchaseId,gems)
 if Profiles.Sandbox then return false end
 local id=player.UserId;lock(id);local s=Profiles.Sessions[id]
 if not s or s.Closing then unlock(id);return false end
 local base=copy(s.Data)
 local ok,result=pcall(function()
  return store:UpdateAsync("u_"..id,function(old)
   if not old or not old.Session or old.Session.Token~=token then return nil end
   local candidate=Profiles.BuildReceipt(base,old,purchaseId,gems)
   candidate.Session={Token=token,Expires=os.time()+180}
   return candidate
  end)
 end)
 if ok and result then s.Data=result;s.Dirty=false end
 unlock(id);return ok and result~=nil
end
function Profiles.Start()
 task.spawn(function()
  while true do
   task.wait(50)
   for _,s in pairs(Profiles.Sessions) do
    if not s.Closing then task.spawn(function() Profiles.Save(s.Player,false) end) end
   end
  end
 end)
 game:BindToClose(function()
  local pending=0
  for _,s in pairs(Profiles.Sessions) do
   pending+=1;task.spawn(function()
    for _=1,3 do if Profiles.Save(s.Player,true) then break end;task.wait(1) end
    pending-=1
   end)
  end
  local deadline=os.clock()+25;while pending>0 and os.clock()<deadline do task.wait(.1) end
 end)
end
return Profiles
