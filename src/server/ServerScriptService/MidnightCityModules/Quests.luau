-- Daily / weekly quests and the 7-day login streak. All progress lives in the player's profile.
local RS=game:GetService("ReplicatedStorage")
local Profiles=require(script.Parent.Profiles)
local Q={Service=nil}
local DAY=86400
local function today() return math.floor(os.time()/DAY) end
-- Weeks start on Monday UTC (day 4 of the Unix epoch was a Monday).
local function thisWeek() return math.floor((os.time()-4*DAY)/(7*DAY)) end
Q.Today,Q.ThisWeek=today,thisWeek
Q.DailyPool={
 {Id="serve",Kind="Served",Goal=10,Coins=80,Text="Serve 10 meals with your crew"},
 {Id="perfect",Kind="Perfect",Goal=3,Coins=90,Text="Cook 3 Perfect meals"},
 {Id="refill",Kind="Refills",Goal=3,Coins=60,Text="Refill front stock 3 times"},
 {Id="shift",Kind="Shifts",Goal=1,Coins=100,Text="Finish a full shift"},
 {Id="earn",Kind="Earned",Goal=400,Coins=90,Text="Earn $400 for your kitchen"},
 {Id="special",Kind="Special",Goal=2,Coins=80,Text="Serve 2 reviewers, regulars or party guests"},
}
Q.Weekly={
 {Id="w_serve",Kind="Served",Goal=80,Coins=500,Gems=10,Text="Serve 80 meals this week"},
 {Id="w_shift",Kind="Shifts",Goal=5,Coins=400,Gems=5,Text="Finish 5 shifts this week"},
 {Id="w_perfect",Kind="Perfect",Goal=20,Coins=350,Gems=5,Text="Cook 20 Perfect meals this week"},
}
Q.Login={{Coins=50},{Coins=75},{Coins=100},{Coins=125},{Coins=150},{Coins=200},{Coins=250,Gems=15}}
local function daily(id) for _,def in Q.DailyPool do if def.Id==id then return def end end end
local function weekly(id) for _,def in Q.Weekly do if def.Id==id then return def end end end
local function notice(player,text) RS.MidnightNetwork.Notice:FireClient(player,text) end
-- Rolls quests over at the UTC day / week boundary. Safe to call on any profile copy.
local function ensure(d,userId)
 d.Quests=d.Quests or {}
 local q=d.Quests;local day,week=today(),thisWeek()
 if q.Day~=day then
  q.Day=day;q.Daily={}
  local rng=Random.new(day*7919+userId%100003)
  local pool=table.clone(Q.DailyPool)
  for i=#pool,2,-1 do local j=rng:NextInteger(1,i);pool[i],pool[j]=pool[j],pool[i] end
  for i=1,3 do q.Daily[i]={Id=pool[i].Id,Progress=0,Claimed=false} end
 end
 if q.Week~=week then q.Week=week;q.WeeklyProgress={};q.WeeklyClaimed={};q.WeekServed=0 end
 d.Stats=d.Stats or {Served=0}
 d.Login=d.Login or {Streak=0,LastDay=-1,Claimed=-1}
 local L=d.Login
 if L.LastDay~=day then L.Streak=(L.LastDay==day-1) and (L.Streak%7)+1 or 1;L.LastDay=day end
 return q
end
-- Adds progress, e.g. Q.Track(player,{Served=1,Earned=45}).
function Q.Track(player,amounts)
 if not player or not player.Parent or not Profiles.Get(player) then return end
 local done={}
 Profiles.Mutate(player,function(d)
  local q=ensure(d,player.UserId)
  if amounts.Served then q.WeekServed=(q.WeekServed or 0)+amounts.Served;d.Stats.Served=(d.Stats.Served or 0)+amounts.Served end
  for _,entry in q.Daily do
   local def=daily(entry.Id);local add=def and amounts[def.Kind]
   if add and entry.Progress<def.Goal then entry.Progress=math.min(def.Goal,entry.Progress+add);if entry.Progress>=def.Goal then table.insert(done,def.Text) end end
  end
  for _,def in Q.Weekly do
   local add=amounts[def.Kind];local p=q.WeeklyProgress[def.Id] or 0
   if add and p<def.Goal then p=math.min(def.Goal,p+add);q.WeeklyProgress[def.Id]=p;if p>=def.Goal then table.insert(done,def.Text) end end
  end
  return true
 end)
 for _,text in done do notice(player,"Quest complete: "..text.." • Claim in Kitchen > Quests") end
end
local function grant(profile,reward)
 profile.Coins+=reward.Coins or 0;profile.Gems+=reward.Gems or 0
 local parts={};if reward.Coins then table.insert(parts,"+"..reward.Coins.." Coins") end;if reward.Gems then table.insert(parts,"+"..reward.Gems.." Gems") end
 return table.concat(parts," ")
end
function Q.Command(player,action,id)
 return Profiles.Mutate(player,function(d)
  local q=ensure(d,player.UserId)
  if action=="LoginClaim" then
   if d.Login.Claimed==d.Login.LastDay then return false,"Today's login reward is already claimed" end
   d.Login.Claimed=d.Login.LastDay
   return true,"Day "..d.Login.Streak.." reward: "..grant(d,Q.Login[d.Login.Streak])
  elseif action=="QuestClaim" then
   local index=tonumber(id)
   local entry=index and q.Daily[index]
   if entry then
    local def=daily(entry.Id)
    if entry.Claimed then return false,"Already claimed" end
    if entry.Progress<def.Goal then return false,"Quest not finished yet" end
    entry.Claimed=true;return true,"Quest reward: "..grant(d,def)
   end
   local def=weekly(tostring(id))
   if not def then return false,"Unknown quest" end
   if q.WeeklyClaimed[def.Id] then return false,"Already claimed" end
   if (q.WeeklyProgress[def.Id] or 0)<def.Goal then return false,"Quest not finished yet" end
   q.WeeklyClaimed[def.Id]=true;return true,"Weekly reward: "..grant(d,def)
  end
  return false,"Unknown quest action"
 end)
end
function Q.Snapshot(player)
 -- Mutate so a new day/week rolls over even while the player stays online.
 local view
 Profiles.Mutate(player,function(d)
  local q=ensure(d,player.UserId)
  local dailyRows={}
  for i,entry in q.Daily do local def=daily(entry.Id);table.insert(dailyRows,{Index=i,Text=def.Text,Goal=def.Goal,Progress=entry.Progress,Claimed=entry.Claimed,Coins=def.Coins}) end
  local weeklyRows={}
  for _,def in Q.Weekly do table.insert(weeklyRows,{Id=def.Id,Text=def.Text,Goal=def.Goal,Progress=q.WeeklyProgress[def.Id] or 0,Claimed=q.WeeklyClaimed[def.Id]==true,Coins=def.Coins,Gems=def.Gems}) end
  view={Daily=dailyRows,Weekly=weeklyRows,Streak=d.Login.Streak,LoginClaimed=d.Login.Claimed==d.Login.LastDay,Login=Q.Login,
   DailyReset=(today()+1)*DAY-os.time(),WeeklyReset=((thisWeek()+1)*7+4)*DAY-os.time(),WeekServed=q.WeekServed or 0}
  return true
 end)
 return view
end
-- Number of rewards waiting to be claimed (for the HUD badge).
function Q.Ready(player)
 local d=Profiles.Get(player);local q=d and d.Quests
 if not q or q.Day~=today() then return 0 end
 local n=(d.Login and d.Login.Claimed~=d.Login.LastDay) and 1 or 0
 for _,entry in q.Daily do local def=daily(entry.Id);if def and not entry.Claimed and entry.Progress>=def.Goal then n+=1 end end
 if q.Week==thisWeek() then for _,def in Q.Weekly do if not q.WeeklyClaimed[def.Id] and (q.WeeklyProgress[def.Id] or 0)>=def.Goal then n+=1 end end end
 return n
end
function Q.Start(service)
 Q.Service=service
 service.SnapshotExtras.Quests=Q.Snapshot
 for _,action in {"LoginClaim","QuestClaim"} do service.CommandHandlers[action]=function(player,id) return Q.Command(player,action,id) end end
end
return Q
