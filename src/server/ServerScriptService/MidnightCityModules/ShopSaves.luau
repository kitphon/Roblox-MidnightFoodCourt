local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Marketplace=game:GetService("MarketplaceService")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Profiles=require(script.Parent.Profiles)
local Legacy=require(script.Parent.Catalog)
local Catalog=require(RS.MidnightStyle.StyleCatalog)
local Config=require(RS.MidnightStyle.MonetizationConfig)
local S={Service=nil,Access={},LastAction={}}
local lookKeys={"Theme","Uniform","Effect","Emote","StaffStyle","ShopEffect","TeamStyle"}
local function copy(value) return Http:JSONDecode(Http:JSONEncode(value)) end
local function passId() return Config.Passes.shop_save_slot or 0 end
function S.Check(player,force)
 local cached=S.Access[player]
 if cached and (cached.Test or not force and os.clock()-cached.Checked<60) then return cached.Owned end
 if Profiles.Sandbox or passId()<=0 then
  S.Access[player]={Owned=false,Checked=os.clock()};return false
 end
 local ok,owns=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,passId()) end)
 if ok then S.Access[player]={Owned=owns,Checked=os.clock()};return owns end
 -- A temporary ownership lookup failure must not erase a verified entitlement.
 return cached and cached.Owned or false
end
function S.Capture(data)
 local look={}
 for _,key in lookKeys do look[key]=data.Equipped[key] or "" end
 return {Version=1,SavedAt=os.time(),Look=look,DecorSlots=copy(data.Shop.DecorSlots or {}),UseTeamStyle=data.UseTeamStyle~=false}
end
function S.Restore(data,slot)
 if type(slot)~="table" or slot.Version~=1 or type(slot.Look)~="table" or type(slot.DecorSlots)~="table" then return false,"Saved design is unavailable" end
 local cleanLook={}
 for _,key in lookKeys do
  local id=slot.Look[key] or ""
  if type(id)~="string" then return false,"Saved style is invalid" end
  if id~="" then
   local item=Catalog.Find(id) or Legacy.Find(id)
   if not item or item.Kind~=key or not data.Owned[id] then return false,"A saved style is no longer in your collection" end
  end
  cleanLook[key]=id
 end
 local slots={}
 for position,id in pairs(slot.DecorSlots) do
  local item=Catalog.Find(id)
  if not item or item.Kind~="Decoration" or item.Slot~=position or not data.Owned[id] then return false,"A saved decoration is unavailable" end
  slots[position]=id
 end
 for _,key in lookKeys do data.Equipped[key]=cleanLook[key] end
 data.Shop.DecorSlots=slots;data.UseTeamStyle=slot.UseTeamStyle~=false
 -- Currency, stock, workers, upgrades, receipts and purchased ownership are never rolled back.
 return true,"Saved shop design loaded. Your latest progress is unchanged."
end
function S.Join(player)
 if not S.Check(player,true) then return end
 local d=Profiles.Get(player)
 if d and d.ShopSaveSlot and d.ShopSaveAutoResume then
  local ok,message=Profiles.Mutate(player,function(profile) return S.Restore(profile,profile.ShopSaveSlot) end)
  player:SetAttribute("ShopDesignResumed",ok)
  if not ok then warn("Saved design could not resume",player.UserId,message) end
 end
end
function S.Snapshot(player)
 local d=Profiles.Get(player);local cached=S.Access[player]
 local saved=d and d.ShopSaveSlot
 local theme=saved and saved.Look and saved.Look.Theme or ""
 local item=Catalog.Find(theme) or Legacy.Find(theme)
 return {Owned=cached and cached.Owned==true or false,PassId=passId(),Configured=passId()>0 and not Profiles.Sandbox,
 SuggestedRobux=Config.ShopSaveSuggestedRobux or 79,HasSave=saved~=nil,SavedAt=saved and saved.SavedAt or 0,
 ThemeName=item and item.Name or "Classic",AutoResume=d and d.ShopSaveAutoResume==true,
 Sandbox=Profiles.Sandbox,TestEnabled=Run:IsStudio() and Profiles.Sandbox and Config.EnableStudioTesting}
end
function S.Command(player,action)
 local data=Profiles.Get(player);if not data then return false,"Profile loading" end
 if action=="SaveTestUnlock" then
  if not Run:IsStudio() or not Profiles.Sandbox or not Config.EnableStudioTesting then return false,"Studio testing only" end
  S.Access[player]={Owned=true,Checked=os.clock(),Test=true}
  return true,"Studio test unlocked. No Robux charged; resets after Stop."
 end
 if action=="SaveBuyPass" then
  if S.Check(player,true) then return true,"Save slot already unlocked" end
  if Profiles.Sandbox or passId()<=0 then return false,"Save Slot pass is not configured yet" end
  local ok=pcall(function() Marketplace:PromptGamePassPurchase(player,passId()) end)
  return ok,ok and "Complete the Roblox purchase prompt" or "Purchase prompt unavailable"
 end
 if not S.Check(player,false) then return false,"Unlock the permanent Save Slot pass first" end
 local pd=S.Service.PlayerData[player];local shop=pd and S.Service.Shops[pd.ShopId]
 if not shop or shop.Owner~=player then return false,"Only save or load your own kitchen" end
 if action~="SaveDesign" and action~="LoadDesign" and action~="SaveAutoResume" then return false,"Unknown save action" end
 if os.clock()-(S.LastAction[player] or -10)<3 then return false,"Please wait a few seconds" end
 if action=="LoadDesign" and shop.Phase=="Playing" then return false,"Close your shop before loading a design" end
 if action=="LoadDesign" and not data.ShopSaveSlot then return false,"Save a shop design first" end
 S.LastAction[player]=os.clock()
 local ok,message=Profiles.Mutate(player,function(profile)
  if action=="SaveDesign" then
   profile.ShopSaveSlot=S.Capture(profile)
   if profile.ShopSaveAutoResume==nil then profile.ShopSaveAutoResume=true end
   return true,"Shop design saved"
  elseif action=="LoadDesign" then return S.Restore(profile,profile.ShopSaveSlot)
  else
   if not profile.ShopSaveSlot then return false,"Save a shop design first" end
   profile.ShopSaveAutoResume=not profile.ShopSaveAutoResume
   return true,profile.ShopSaveAutoResume and "Saved design will load next visit" or "Using your latest design next visit"
  end
 end)
 if not ok then return false,message end
 if not Profiles.Save(player,false) then return false,"Save failed. Your previous cloud save is protected." end
 S.Service.SyncPlayer(player)
 return true,Profiles.Sandbox and message.." (Studio session only)" or message
end
function S.Start(service)
 S.Service=service
 Players.PlayerRemoving:Connect(function(player) S.Access[player]=nil;S.LastAction[player]=nil end)
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  if not purchased or id~=passId() or id<=0 then return end
  if Profiles.Get(player) and S.Check(player,true) then
   RS.MidnightNetwork.Notice:FireClient(player,"Shop Save Slot unlocked permanently. Open Kitchen > Saves.")
   service.SyncPlayer(player)
  end
 end)
end
return S
