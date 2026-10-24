-- Weekly and all-time "meals served" leaderboards (OrderedDataStore). In the Studio sandbox they rank
-- only the players on this server so the UI can still be tested.
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Run=game:GetService("RunService")
local Profiles=require(script.Parent.Profiles)
local Quests=require(script.Parent.Quests)
local L={Weekly={},AllTime={},Names={},Live=not Profiles.Sandbox}
local suffix=Run:IsStudio() and "_Studio" or ""
local function stats(player)
 local d=Profiles.Get(player);if not d then return 0,0 end
 local q=d.Quests
 local week=q and q.Week==Quests.ThisWeek() and q.WeekServed or 0
 return week,d.Stats and d.Stats.Served or 0
end
local function weeklyStore() return DataStoreService:GetOrderedDataStore("MidnightServed_W"..Quests.ThisWeek()..suffix) end
local allTimeStore=L.Live and DataStoreService:GetOrderedDataStore("MidnightServed_All"..suffix)
local function push(userId,week,all)
 if not L.Live then return end
 if week>0 then pcall(function() weeklyStore():SetAsync("u_"..userId,math.floor(week)) end) end
 if all>0 then pcall(function() allTimeStore:SetAsync("u_"..userId,math.floor(all)) end) end
end
local function nameOf(userId)
 local p=Players:GetPlayerByUserId(userId);if p then return p.DisplayName end
 if L.Names[userId] then return L.Names[userId] end
 local ok,name=pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
 L.Names[userId]=ok and name or "Player";return L.Names[userId]
end
local function read(store)
 local rows={}
 local ok,pages=pcall(function() return store:GetSortedAsync(false,10) end)
 if not ok then return nil end
 for _,entry in pages:GetCurrentPage() do
  local userId=tonumber(tostring(entry.key):match("^u_(%d+)$"))
  if userId then table.insert(rows,{Name=nameOf(userId),Value=entry.value,UserId=userId}) end
 end
 return rows
end
local function refresh()
 if L.Live then
  L.Weekly=read(weeklyStore()) or L.Weekly
  L.AllTime=read(allTimeStore) or L.AllTime
  return
 end
 local week,all={},{}
 for _,p in Players:GetPlayers() do local w,a=stats(p);table.insert(week,{Name=p.DisplayName,Value=w,UserId=p.UserId});table.insert(all,{Name=p.DisplayName,Value=a,UserId=p.UserId}) end
 table.sort(week,function(a,b) return a.Value>b.Value end);table.sort(all,function(a,b) return a.Value>b.Value end)
 L.Weekly,L.AllTime=week,all
end
function L.Snapshot(player)
 local w,a=stats(player)
 return {Live=L.Live,Weekly=L.Weekly,AllTime=L.AllTime,MyWeek=w,MyAll=a}
end
function L.Start(service)
 service.SnapshotExtras.Ranks=L.Snapshot
 Players.PlayerRemoving:Connect(function(p) local w,a=stats(p);local id=p.UserId;task.spawn(push,id,w,a) end)
 task.spawn(function()
  local nextPush=os.clock()+30
  while true do
   if os.clock()>=nextPush then
    nextPush=os.clock()+120
    for _,p in Players:GetPlayers() do local w,a=stats(p);push(p.UserId,w,a);task.wait(.5) end
   end
   refresh()
   task.wait(L.Live and 60 or 10)
  end
 end)
end
return L
