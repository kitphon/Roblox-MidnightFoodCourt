
local Tween=game:GetService("TweenService")
local Catalog=require(script.Parent.Catalog)
local City={}
local world=workspace:WaitForChild("MidnightCity")
local citizens=Instance.new("Folder");citizens.Name="Citizens";citizens.Parent=world
local names={"Mia","Leo","Nora","Kai","Ava","Ben","Luna","Max","Theo","Ivy","Sam","Zoe"}
local function create(name,pos,color)
 local m=Instance.new("Model");m.Name=name;m.Parent=citizens
 local frame=CFrame.new(pos)
 local function p(n,s,offset,col)
  local a=Instance.new("Part");a.Name=n;a.Size=s;a.CFrame=frame*CFrame.new(offset);a.Color=col;a.Anchored=true;a.CanCollide=false;a.Parent=m;return a
 end
 local root=p("Root",Vector3.new(.05,.05,.05),Vector3.zero,Color3.new());root.Transparency=1;root.CanQuery=false;m.PrimaryPart=root
 p("Body",Vector3.new(1.6,1.9,.85),Vector3.new(0,2.45,0),color)
 local h=p("Head",Vector3.new(1.3,1.3,1.3),Vector3.new(0,4.05,0),Color3.fromRGB(221,181,142));h.Shape=Enum.PartType.Ball
 for _,x in ipairs({-.4,.4}) do p("Leg",Vector3.new(.55,1.5,.65),Vector3.new(x,.75,0),Color3.fromRGB(39,48,57)) end
 for _,x in ipairs({-1,1}) do p("Arm",Vector3.new(.4,1.7,.5),Vector3.new(x,2.4,0),color) end
 return m
end
local function move(m,point,speed)
 if not m.Parent then return end
 local origin=m:GetPivot().Position;local delta=point-origin
 if delta.Magnitude<.1 then return end
 local cf=CFrame.lookAt(origin,point)
 m:PivotTo(cf)
 local value=Instance.new("CFrameValue");value.Value=cf
 local connection=value.Changed:Connect(function(v) if m.Parent then m:PivotTo(v) end end)
 local tween=Tween:Create(value,TweenInfo.new(delta.Magnitude/(speed or 7),Enum.EasingStyle.Linear),{Value=CFrame.lookAt(point,point+delta.Unit)})
 tween:Play();tween.Completed:Wait();connection:Disconnect();value:Destroy()
end
local function travel(m,target)
 local origin=m:GetPivot().Position
 local sourceLane=origin.Z< -35 and -53 or -18
 local targetLane=target.Z< -35 and -53 or -18
 move(m,Vector3.new(origin.X,1.35,sourceLane))
 if sourceLane~=targetLane then
  local crossing=math.clamp(53+math.floor((origin.X-53)/110+.5)*110,53,383)
  move(m,Vector3.new(crossing,1.35,sourceLane));move(m,Vector3.new(crossing,1.35,targetLane))
 end
 move(m,Vector3.new(target.X,1.35,targetLane));move(m,target)
end

local function bus()
 if world:FindFirstChild("CityBus") then return end
 local m=Instance.new("Model");m.Name="CityBus";m.Parent=world
 local origin=Vector3.new(-110,1.18,-41)
 local frame=CFrame.lookAt(origin,origin+Vector3.xAxis)
 local function p(n,s,offset,col,shape)
  local a=Instance.new("Part");a.Name=n;a.Size=s;a.CFrame=frame*CFrame.new(offset);a.Color=col;a.Anchored=true;a.CanCollide=false;if shape then a.Shape=shape end;a.Parent=m;return a
 end
 local root=p("Root",Vector3.new(.02,.02,.02),Vector3.zero,Color3.new());root.Transparency=1;root.CanQuery=false;m.PrimaryPart=root
 p("Body",Vector3.new(6,4.8,14),Vector3.new(0,4.1,0),Color3.fromRGB(203,157,66))
 p("Windshield",Vector3.new(5.3,2,.12),Vector3.new(0,4.7,-7.08),Color3.fromRGB(71,119,135))
 for _,x in ipairs({-3.06,3.06}) do for _,z in ipairs({-4.5,-1.5,1.5,4.5}) do p("Window",Vector3.new(.12,1.9,2.2),Vector3.new(x,4.8,z),Color3.fromRGB(75,121,135)) end end
 for _,x in ipairs({-3.1,3.1}) do for _,z in ipairs({-4.5,4.5}) do p("Wheel",Vector3.new(.6,2.2,2.2),Vector3.new(x,1.1,z),Color3.fromRGB(30,33,38),Enum.PartType.Cylinder) end end
 for _,x in ipairs({-2.2,2.2}) do local a=p("Headlight",Vector3.new(.7,.6,.12),Vector3.new(x,2.8,-7.1),Color3.fromRGB(255,232,174));a.Material=Enum.Material.Neon end
 local source=game:GetService("SoundService"):FindFirstChild("MK_BusHorn")
 local horn=source and source:Clone();if horn then horn.Name="Horn";horn.RollOffMaxDistance=150;horn.Parent=root end
 task.spawn(function() move(m,Vector3.new(330,1.18,-41),24);if horn then horn:Play() end;m:SetAttribute("Activity","Boarding");task.wait(8);if horn then horn:Play() end;move(m,Vector3.new(530,1.18,-41),24);m:Destroy() end)
end
function City.Start()
 local rain=Instance.new("Part");rain.Name="RainCloud";rain.Size=Vector3.new(620,.1,130);rain.Position=Vector3.new(185,40,-25);rain.Anchored=true;rain.Transparency=1;rain.CanCollide=false;rain.CanQuery=false;rain.Parent=world
 local drops=Instance.new("ParticleEmitter");drops.Name="Rain";drops.Texture="rbxasset://textures/particles/sparkles_main.dds";drops.Rate=0;drops.EmissionDirection=Enum.NormalId.Bottom;drops.Speed=NumberRange.new(38);drops.Lifetime=NumberRange.new(1);drops.Size=NumberSequence.new(.07);drops.Squash=NumberSequence.new(2);drops.Transparency=NumberSequence.new(.45);drops.Color=ColorSequence.new(Color3.fromRGB(161,186,198));drops.Parent=rain

 local destinations=world.Destinations:GetChildren()
 for i,name in ipairs(names) do
  local initial=destinations[(i-1)%#destinations+1].Value+Vector3.new((i-6.5)*3,0,0)
  local m=create(name,initial,Color3.fromHSV(i/#names,.35,.65))
  m:SetAttribute("Home","Apartments");m:SetAttribute("Activity","Walking")
  task.spawn(function()
   task.wait(i*.3)
   local step=i
   while m.Parent do
    step+=1
    local hour=world:GetAttribute("SimulationHour") or world:GetAttribute("Hour") or 23
    local location=destinations[(step-1)%#destinations+1]
    local target=location.Value
    local activity=location.Name=="Office" and "Working" or location.Name=="Market" and "Shopping" or location.Name=="Home" and "Resting" or "Visiting "..location.Name
    -- Counter visits belong to CustomerFlow, which creates actual food orders.
    if hour>=2 and hour<=6 then target=world.Destinations.Home.Value;activity="Resting" end
    target+=Vector3.new((i-6.5)*3,0,0)
    m:SetAttribute("Activity","Walking");m:SetAttribute("Destination",activity)
    travel(m,target);m:SetAttribute("Activity",activity);task.wait(8+(i%4)*3)
   end
  end)
 end
 task.spawn(function()
  local started=os.clock();local nextEvent=os.clock()+Catalog.Get("CityEventSeconds");local index=0
  while world.Parent do
   local simulationHour=(23+(os.clock()-started)/60)%24
   local nightHour=Catalog.Get("CityNightHour",23)%24
   -- NPC schedules advance independently of the permanent nighttime sky.
   world:SetAttribute("SimulationHour",math.floor(simulationHour*10)/10)
   world:SetAttribute("Hour",nightHour)
   game.Lighting.ClockTime=nightHour
   if os.clock()>=nextEvent then
    index=index%4+1
    world:SetAttribute("Event",({"Lunch Rush","Bus Arrival","Rain Shower","Quiet Night"})[index])
    nextEvent=os.clock()+Catalog.Get("CityEventSeconds")
    if index==2 then bus() end
    drops.Rate=index==3 and 180 or 0
    if index==3 then game.Lighting.FogEnd=150;game.Lighting.FogColor=Color3.fromRGB(66,77,86)
    else game.Lighting.FogEnd=400;game.Lighting.FogColor=Color3.fromRGB(30,42,58) end
   end
   task.wait(1)
  end
 end)
end
return City
