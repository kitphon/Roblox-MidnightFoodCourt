local RS=game:GetService("ReplicatedStorage")
local Inventory=require(script.Parent.Inventory)
local Visuals={}
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local stations={};for _,recipe in Recipes.All do stations[recipe.Id]=recipe.Station end
local repairs={BLACKOUT="FuseBox",WHISPER="Radio",SHADOW="Ward"}
local function prepare(m)
 if m.PrimaryPart then return end
 local body=m:FindFirstChild("Body");if not body then return end
 local foot=body.Position-Vector3.new(0,2.5,0)
 local root=Instance.new("Part");root.Name="WorkerRoot";root.Size=Vector3.new(.05,.05,.05);root.Transparency=1;root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.CFrame=CFrame.new(foot);root.Parent=m;m.PrimaryPart=root
 local leg=0
 for _,p in m:GetChildren() do
  if p:IsA("BasePart") and p.Name=="Leg" then leg+=1;p.Name=leg==1 and "LeftLeg" or "RightLeg" end
 end
 local white=Color3.fromRGB(242,237,221)
 local navy=Color3.fromRGB(35,50,75)
 local blue=Color3.fromRGB(49,103,151)
 local yellow=Color3.fromRGB(247,192,57)
 local function clothing(name,size,offset,color)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CFrame=root.CFrame*CFrame.new(offset);p.Parent=m;return p
 end
 local cap=m:FindFirstChild("Cap")
 local sleeve=white
 if m.Name=="Chef" then
  body.Color=white
  if cap then cap.Size=Vector3.new(1.65,.22,1.65);cap.CFrame=root.CFrame*CFrame.new(0,5,0);cap.Color=white end
  clothing("ChefToque",Vector3.new(1.35,.9,1.35),Vector3.new(0,5.5,0),white)
  clothing("ChefApron",Vector3.new(1.3,1.9,.12),Vector3.new(0,2.1,-.57),Color3.fromRGB(218,208,180))
  clothing("Neckerchief",Vector3.new(.8,.22,.14),Vector3.new(0,3.35,-.59),Color3.fromRGB(167,54,50))
  for _,x in {-.35,.35} do for _,y in {2.7,3.1} do clothing("CoatButton",Vector3.new(.1,.1,.08),Vector3.new(x,y,-.65),navy) end end
 elseif m.Name=="Waiter" then
  body.Color=navy
  if cap then cap:Destroy() end
  clothing("ShirtFront",Vector3.new(.65,1.2,.12),Vector3.new(0,2.9,-.56),white)
  for _,x in {-.18,.18} do clothing("BowTie",Vector3.new(.3,.2,.13),Vector3.new(x,3.3,-.66),Color3.fromRGB(172,55,56)) end
  clothing("WaiterApron",Vector3.new(1.6,.85,.14),Vector3.new(0,1.85,-.6),white)
  clothing("ApronBelt",Vector3.new(1.85,.18,1.05),Vector3.new(0,2.2,0),Color3.fromRGB(24,30,42))
 elseif m.Name=="Technician" then
  body.Color=blue;sleeve=blue
  if cap then cap.Size=Vector3.new(1.85,.25,1.75);cap.CFrame=root.CFrame*CFrame.new(0,5,0);cap.Color=yellow end
  clothing("HardHatCrown",Vector3.new(1.4,.5,1.4),Vector3.new(0,5.28,0),yellow)
  clothing("ToolBelt",Vector3.new(1.95,.28,1.15),Vector3.new(0,1.85,0),Color3.fromRGB(94,65,43))
  clothing("ToolPouch",Vector3.new(.5,.65,.3),Vector3.new(.65,1.6,-.68),Color3.fromRGB(127,85,49))
  clothing("WrenchHandle",Vector3.new(.13,.8,.13),Vector3.new(-.65,1.8,-.7),Color3.fromRGB(180,191,198))
  clothing("WrenchHead",Vector3.new(.35,.25,.15),Vector3.new(-.65,2.2,-.7),Color3.fromRGB(180,191,198))
  clothing("SafetyStripe",Vector3.new(1.82,.16,.12),Vector3.new(0,2.8,-.57),yellow)
 end
 m:SetAttribute("UniformRole",m.Name)
 for _,side in {"Left","Right"} do
  local p=Instance.new("Part");p.Name=side.."Arm";p.Size=Vector3.new(.45,1.7,.6);p.Anchored=true;p.CanCollide=false;p.Color=sleeve
  p.CFrame=root.CFrame*CFrame.new(side=="Left" and -1.15 or 1.15,2.5,0);p.Parent=m
 end
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false;p.CanQuery=false end end
end
local function carrying(m,food)
 if m:GetAttribute("Carrying")==food then return end
 local old=m:FindFirstChild("WorkerMeal");if old then old:Destroy() end
 m:SetAttribute("Carrying",food)
 local template=RS.MidnightIcons:FindFirstChild(food)
 if template then
  local meal=template:Clone();meal.Name="WorkerMeal";meal:ScaleTo(.45)
  for _,p in meal:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false end end
  meal:PivotTo(m:GetPivot()*CFrame.new(0,2.2,-1.35));meal.Parent=m
 end
end
function Visuals.Step(shop,now)
 local folder=shop.Model:FindFirstChild("Employees");if not folder then return end
 local floor=shop.Model.ShopFloor
 local y=floor.Position.Y+floor.Size.Y/2
 local dt=math.clamp(now-(shop.WorkerVisualAt or now),0,.5);shop.WorkerVisualAt=now
 for _,m in folder:GetChildren() do
  prepare(m);if not m.PrimaryPart then continue end
  local kind=m.Name
  local index=kind=="Chef" and -1 or kind=="Waiter" and 0 or 1
  local target=Vector3.new(floor.Position.X+index*4,y,floor.Position.Z-2)
  local face=target+Vector3.new(0,0,-1)
  local status=shop.Phase=="Playing" and "Waiting for order" or "Off duty"
  local active=false;local meal=""
  local mealReady=shop.Prepared~=""
  local teammateCooking=false
  for p in pairs(shop.Members) do
   local state=p:FindFirstChild("MidnightState")
   if state then
    if shop.Order~="" and state:GetAttribute("Held")==shop.Order then mealReady=true end
    if shop.Order~="" and state:GetAttribute("Cooking")==shop.Order then teammateCooking=true end
   end
  end

  if shop.Phase=="Playing" then
   if kind=="Chef" and shop.CustomerStage=="Ordering" and shop.Event=="" then
    local stock=Inventory.Data(shop)
    if mealReady then status="Order ready"
    elseif teammateCooking then status="Waiting for cook"
    elseif shop.Prepared=="" and (not stock or (stock.Front[Recipes.StockId(shop.Order)] or 0)<=0) then status="Needs ingredients"
    elseif shop.Prepared=="" and stations[shop.Order] then
     local station=shop.Model[stations[shop.Order]]
     target=Vector3.new(station.Position.X,y,station.Position.Z-3)
     face=station.Position;status="Cooking";active=true
    else status="Order ready" end
   elseif kind=="Waiter" and not mealReady and not teammateCooking and shop.Order~="" and shop.CustomerStage=="Ordering" and shop.Prepared=="" and (not Inventory.Data(shop) or (Inventory.Data(shop).Front[Recipes.StockId(shop.Order)] or 0)<=0) then
    target=Vector3.new(shop.Model.Serve.Position.X,y,shop.Model.CounterTop.Position.Z+3);face=shop.Model.CounterTop.Position;status="Notifying customer";active=true
   elseif kind=="Waiter" and shop.Prepared~="" then
    target=Vector3.new(shop.Model.Serve.Position.X,y,shop.Model.CounterTop.Position.Z+3)
    face=shop.Model.CounterTop.Position;status="Serving";active=true;meal=shop.Prepared
   elseif kind=="Technician" and repairs[shop.Event] then
    local station=shop.Model[repairs[shop.Event]]
    target=Vector3.new(station.Position.X,y,math.min(station.Position.Z-2,floor.Position.Z+3))
    face=station.Position;status="Repairing";active=true
   end
  end
  carrying(m,meal)
  local pos=m:GetPivot().Position
  local delta=target-pos
  local moving=delta.Magnitude>.12
  local nextPos=moving and pos+delta.Unit*math.min(delta.Magnitude,9*dt) or target
  local look=moving and target or Vector3.new(face.X,y,face.Z)
  if (look-nextPos).Magnitude<.01 then look=nextPos+Vector3.new(0,0,-1) end
  local cf=CFrame.lookAt(nextPos,look)
  m:PivotTo(cf)
  local swing=moving and math.sin(now*12)*.45 or 0
  for _,side in {"Left","Right"} do
   local sign=side=="Left" and -1 or 1
   local leg=m:FindFirstChild(side.."Leg")
   if leg then leg.CFrame=cf*CFrame.new(sign*.45,.8,0)*CFrame.Angles(sign*swing,0,0) end
   local arm=m:FindFirstChild(side.."Arm")
   if arm then
    local angle=meal~="" and -1.1 or active and not moving and (-.6+math.sin(now*10)*.25) or -sign*swing
    arm.CFrame=cf*CFrame.new(sign*1.15,2.5,0)*CFrame.Angles(angle,0,0)
   end
  end
  m:SetAttribute("Activity",moving and "Walking" or status)
  local label=m:FindFirstChildWhichIsA("TextLabel",true)
  if label then label.Text=kind.."\n"..(moving and "Walking" or status);label.TextSize=13;label.Parent.Size=UDim2.fromOffset(155,46) end
 end
end
return Visuals
