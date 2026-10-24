
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Profiles=require(script.Parent.Profiles)
local Catalog=require(script.Parent.Catalog)
local RS=game:GetService("ReplicatedStorage")
local Transit={Trips={},Stops={},Serial=0}
local function closest(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 local best,dist
 for _,s in pairs(Transit.Stops) do local d=(root.Position-s.Pad.Position).Magnitude;if not dist or d<dist then best=s;dist=d end end
 return best,dist
end
function Transit.Snapshot(player)
 local current,distance=closest(player);local list={}
 for _,id in ipairs({"Shop1","Shop2","Shop3","Shop4","Mall"}) do local s=Transit.Stops[id];if s then table.insert(list,{Id=id,Name=s.Name}) end end
 return {Stops=list,Nearest=current and current.Id or "",AtStop=distance and distance<=13 or false,Fare=Catalog.Get("BusFare",5),Riding=player:GetAttribute("InTransit")==true}
end
local function makeBus(origin,id)
 local m=Instance.new("Model");m.Name="Shuttle_"..id;m.Parent=workspace.MidnightCity
 local cf=CFrame.lookAt(origin,origin+Vector3.xAxis)
 local function p(n,size,offset,col,shape)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.CFrame=cf*CFrame.new(offset);a.Color=col;if n=="Window" or n=="Windshield" then a.Transparency=.45 end;a.Anchored=true;a.CanCollide=false;if shape then a.Shape=shape end;a.Parent=m;return a
 end
 local root=p("Root",Vector3.new(.02,.02,.02),Vector3.zero,Color3.new());root.Transparency=1;root.CanQuery=false;m.PrimaryPart=root
 local source=game:GetService("SoundService"):FindFirstChild("MK_BusHorn")
 if source then local horn=source:Clone();horn.Name="Horn";horn.RollOffMaxDistance=120;horn.Parent=root end
 
p("Floor",Vector3.new(6,.5,12),Vector3.new(0,1,0),Color3.fromRGB(57,134,128))
 p("Roof",Vector3.new(6,.25,12),Vector3.new(0,6.6,0),Color3.fromRGB(37,87,86))
 for _,x in ipairs({-2.9,2.9}) do
  p("SidePanel",Vector3.new(.2,2,12),Vector3.new(x,2.25,0),Color3.fromRGB(57,134,128))
  for _,z in ipairs({-5.9,5.9}) do p("Pillar",Vector3.new(.2,5.2,.2),Vector3.new(x,3.9,z),Color3.fromRGB(57,134,128)) end
 end
 p("Windshield",Vector3.new(5.4,1.7,.1),Vector3.new(0,4.6,-6.05),Color3.fromRGB(151,207,219))
 for _,x in ipairs({-3.05,3.05}) do for _,z in ipairs({-3.8,-.9,2,4}) do p("Window",Vector3.new(.1,1.7,1.8),Vector3.new(x,4.6,z),Color3.fromRGB(151,207,219)) end end
 for _,x in ipairs({-3.05,3.05}) do for _,z in ipairs({-3.7,3.7}) do p("Wheel",Vector3.new(.55,2.1,2.1),Vector3.new(x,1.05,z),Color3.fromRGB(28,32,37),Enum.PartType.Cylinder) end end
 p("Destination",Vector3.new(4.6,.65,.1),Vector3.new(0,5.75,-6.06),Color3.fromRGB(21,35,42))
 return m
end
local function offset(i) return CFrame.new((i%2==0 and 1 or -1)*1.25,4.3,((math.ceil(i/2)-1)*2)-.5) end
local function release(passenger,stop)
 local p,char,root,hum=passenger.Player,passenger.Character,passenger.Root,passenger.Humanoid
 p:SetAttribute("InTransit",false)
 if root.Parent then root.Anchored=passenger.Anchored end
 if hum.Parent then hum.PlatformStand=passenger.PlatformStand end
 if p.Character==char and char.Parent and hum.Health>0 then char:PivotTo(stop.Pad.CFrame*CFrame.new((passenger.Index-2)*1.2,3,0)) end
end
local function drive(trip,point)
 local from=trip.Model:GetPivot().Position;local delta=point-from;if delta.Magnitude<.05 then return end
 local start=CFrame.lookAt(from,point);trip.Model:PivotTo(start)
 local v=Instance.new("CFrameValue");v.Value=start
 local connection=v.Changed:Connect(function(cf)
  if not trip.Model.Parent then return end
  trip.Model:PivotTo(cf)
  for _,passenger in ipairs(trip.Passengers) do
   if passenger.Player.Character==passenger.Character and passenger.Root.Parent and passenger.Humanoid.Health>0 then passenger.Character:PivotTo(cf*offset(passenger.Index)) end
  end
 end)
 local speed=math.max(10,Catalog.Get("BusSpeed",45))
 local tween=Tween:Create(v,TweenInfo.new(delta.Magnitude/speed,Enum.EasingStyle.Linear),{Value=CFrame.lookAt(point,point+delta.Unit)})
 tween:Play();tween.Completed:Wait();connection:Disconnect();v:Destroy()
end
local function run(trip)
 task.wait(2.5);trip.Boarding=false
 local horn=trip.Model.PrimaryPart and trip.Model.PrimaryPart:FindFirstChild("Horn");if horn then horn:Play() end
 local ok,problem=pcall(function()
  local from,to=trip.From,trip.To
  if from.Id=="Mall" then
   drive(trip,Vector3.new(397,1.18,-70));drive(trip,Vector3.new(397,1.18,-27))
  end
  if to.Id=="Mall" then
   drive(trip,Vector3.new(397,1.18,-27));drive(trip,Vector3.new(397,1.18,-70))
  end
  drive(trip,to.Road)
 end)
 for _,passenger in ipairs(trip.Passengers) do
  release(passenger,ok and trip.To or trip.From)
  if not ok and Profiles.Get(passenger.Player) then Profiles.Mutate(passenger.Player,function(d) d.Coins+=trip.Fare;return true end) end
  if passenger.Player.Parent==Players then RS.MidnightNetwork.Notice:FireClient(passenger.Player,ok and ("Arrived at "..trip.To.Name) or "Trip cancelled; fare refunded") end
 end
 if not ok then warn("Shuttle trip interrupted",problem) end
 if trip.Model.Parent then trip.Model:Destroy() end
 Transit.Trips[trip.Id]=nil
end
function Transit.Travel(player,id)
 local to=Transit.Stops[id];if not to then return false,"Unknown destination" end
 if player:GetAttribute("InTransit") then return false,"Already riding" end
 local from,distance=closest(player)
 if not from or distance>13 then return false,"Go to a bus stop first" end
 if from.Id==to.Id then return false,"You are already at this stop" end
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 then return false,"Character not ready" end
 local fare=Catalog.Get("BusFare",5)
 local paid,msg=Profiles.Mutate(player,function(d) if player:GetAttribute("InTransit") then return false,"Already riding" end;if d.Coins<fare then return false,"Need "..fare.." Coins for the bus" end;d.Coins-=fare;return true end)
 if not paid then return false,msg end
 local trip
 for _,t in pairs(Transit.Trips) do if t.Boarding and t.From==from and t.To==to and #t.Passengers<4 then trip=t;break end end
 if not trip then
  Transit.Serial+=1;trip={Id=Transit.Serial,From=from,To=to,Fare=fare,Boarding=true,Passengers={}}
  trip.Model=makeBus(from.Road,trip.Id);Transit.Trips[trip.Id]=trip
  task.spawn(run,trip)
 end
 local passenger={Player=player,Character=char,Root=root,Humanoid=hum,Anchored=root.Anchored,PlatformStand=hum.PlatformStand,Index=#trip.Passengers+1}
 table.insert(trip.Passengers,passenger)
 player:SetAttribute("InTransit",true);hum.PlatformStand=true;root.Anchored=true;char:PivotTo(trip.Model:GetPivot()*offset(passenger.Index))
 return true,"Boarding shuttle to "..to.Name
end
function Transit.Start()
 for _,pad in ipairs(workspace.MidnightCity.BusStops:GetChildren()) do
  local stop={Id=pad.Name,Name=pad:GetAttribute("StopName"),Pad=pad,Road=pad:GetAttribute("RoadPosition")}
  Transit.Stops[stop.Id]=stop
  pad.Ride.Triggered:Connect(function(player)
   local current,d=closest(player)
   if current==stop and d<=13 then RS.MidnightNetwork.OpenPanel:FireClient(player,"Travel") end
  end)
 end
 Players.PlayerRemoving:Connect(function(p)
  for _,trip in pairs(Transit.Trips) do for _,passenger in ipairs(trip.Passengers) do if passenger.Player==p then if passenger.Root.Parent then passenger.Root.Anchored=passenger.Anchored end end end end
 end)
end
return Transit
