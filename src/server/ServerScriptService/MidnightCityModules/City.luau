
local Tween=game:GetService("TweenService")
local Catalog=require(script.Parent.Catalog)
local City={}
local world=workspace:WaitForChild("MidnightCity")
local citizens=Instance.new("Folder");citizens.Name="Citizens";citizens.Parent=world
local names={"Mia","Leo","Nora","Kai","Ava","Ben","Luna","Max","Theo","Ivy","Sam","Zoe"}
local skins={{241,204,170},{221,181,142},{191,142,104},{150,103,72},{112,76,54}}
local hairs={{52,36,28},{24,24,30},{118,74,42},{214,170,92},{150,62,48}}
local pants={{39,48,57},{58,74,108},{70,60,52},{44,44,48}}
local function create(name,pos,color,index)
 local m=Instance.new("Model");m.Name=name;m:SetAttribute("CitizenSeed",index);m.Parent=citizens
 local frame=CFrame.new(pos)
 local function p(n,s,offset,col,shape,tilt)
  local a=Instance.new("Part");a.Name=n;a.Size=s;a.CFrame=frame*CFrame.new(offset)*CFrame.Angles(0,0,tilt or 0);a.Color=col;a.Anchored=true;a.CanCollide=false;if shape then a.Shape=shape end
  if n~="Root" then
   a:SetAttribute("CitizenRest",frame:ToObjectSpace(a.CFrame))
   local group=(n=="Arm" or n=="Hand") and (offset.X<0 and "LeftArm" or "RightArm") or (n=="Leg" or n=="Shoe") and (offset.X<0 and "LeftLeg" or "RightLeg") or n=="Body" and "Body" or "Head"
   a:SetAttribute("CitizenGroup",group)
  end
  a.Parent=m;return a
 end
 local function rgb(list) return Color3.fromRGB(unpack(list[(index-1)%#list+1])) end
 local skin,hair,leg=rgb(skins),rgb(hairs),rgb(pants)
 local dark=Color3.fromRGB(30,28,34)
 local root=p("Root",Vector3.new(.05,.05,.05),Vector3.zero,Color3.new());root.Transparency=1;root.CanQuery=false;m.PrimaryPart=root
 p("Body",Vector3.new(1.6,1.9,.85),Vector3.new(0,2.45,0),color)
 p("Head",Vector3.new(1.3,1.3,1.3),Vector3.new(0,4.05,0),skin,Enum.PartType.Ball)
 for _,x in ipairs({-.4,.4}) do
  p("Leg",Vector3.new(.55,1.3,.65),Vector3.new(x,.85,0),leg)
  p("Shoe",Vector3.new(.6,.3,.8),Vector3.new(x,.15,-.06),index%3==0 and Color3.fromRGB(232,232,226) or dark)
 end
 -- Sleeves in the shirt colour plus skin-tone forearms so arms read against the body at night.
 for _,x in ipairs({-1.02,1.02}) do
  p("Arm",Vector3.new(.42,.95,.52),Vector3.new(x,2.92,0),color:Lerp(Color3.new(),.15))
  p("Hand",Vector3.new(.38,.8,.46),Vector3.new(x,2.05,0),skin)
 end
 -- Face on the -Z side, which travel() keeps pointed along the walking direction.
 for _,x in ipairs({-.24,.24}) do
  p("Eye",Vector3.new(.15,.2,.06),Vector3.new(x,4.15,-.6),dark).CastShadow=false
  p("EyeShine",Vector3.new(.05,.05,.03),Vector3.new(x+.03,4.2,-.64),Color3.new(1,1,1)).CastShadow=false
  p("Cheek",Vector3.new(.18,.09,.04),Vector3.new(x*1.75,3.9,-.48),Color3.fromRGB(236,140,138)).CastShadow=false
 end
 for _,x in ipairs({-.08,.08}) do p("Smile",Vector3.new(.18,.06,.05),Vector3.new(x,3.8,-.6),Color3.fromRGB(120,52,52),nil,x<0 and -.35 or .35).CastShadow=false end
 local style=index%4
 p("Hair",Vector3.new(1.36,.42,1.36),Vector3.new(0,4.6,.04),hair)
 p("HairBack",Vector3.new(1.3,style==2 and 1.5 or .8,.35),Vector3.new(0,style==2 and 3.95 or 4.25,.5),hair)
 if style==1 then
  p("Cap",Vector3.new(1.45,.34,1.45),Vector3.new(0,4.78,0),color:Lerp(Color3.new(1,1,1),.35))
  p("CapBrim",Vector3.new(1.1,.1,.6),Vector3.new(0,4.66,-.88),color:Lerp(Color3.new(1,1,1),.35))
 elseif style==3 then
  p("HairBun",Vector3.new(.6,.6,.6),Vector3.new(0,4.95,.35),hair,Enum.PartType.Ball)
 end
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
-- Runtime town dressing: lit windows, trim, door lighting, rooftop clutter and one signature prop per building.
local accents={APARTMENTS={255,150,80},["CORNER MARKET"]={110,220,120},["CITY CLINIC"]={120,235,200},["LATE SHIFT OFFICE"]={110,160,255},["BUS TERMINAL"]={255,200,70}}
local function dressBuilding(model,index)
 local body,sign=model:FindFirstChild("Building"),model:FindFirstChild("Sign")
 if not body or not sign then return end
 local old=model:FindFirstChild("TownDetail");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="TownDetail";folder.Parent=model
 local accent=Color3.fromRGB(unpack(accents[model.Name] or {255,190,110}))
 local frameColor,metal=Color3.fromRGB(38,40,46),Color3.fromRGB(96,102,110)
 local half=body.Size/2
 local function at(x,y,z) return body.CFrame*CFrame.new(x,y,z) end
 local function p(name,size,cf,color,material,shape,solid)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.CFrame=cf;a.Color=color;a.Material=material or Enum.Material.SmoothPlastic
  a.Anchored=true;a.CanCollide=solid==true;a.CanQuery=false;a.CanTouch=false;a.CastShadow=size.Magnitude>=2;if shape then a.Shape=shape end;a.Parent=folder;return a
 end
 local function bench(x,width,color,material)
  p("Bench",Vector3.new(width,.4,1.6),at(x,-half.Y+1.4,half.Z+1.6),color,material,nil,true)
  for _,dx in {-width/2+.5,width/2-.5} do p("BenchLeg",Vector3.new(.3,1.2,1.2),at(x+dx,-half.Y+.6,half.Z+1.6),Color3.fromRGB(38,40,46),Enum.Material.Metal) end
 end
 local function light(parent,color,brightness,range) local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Parent=parent;return l end
 -- Darker-than-final tones: Neon + Bloom brightens them, and pale values blow out to white.
 local lit={Color3.fromRGB(230,160,80),Color3.fromRGB(215,135,70),Color3.fromRGB(240,190,110),Color3.fromRGB(95,140,215)}
 local function windowColor(n) local k=(n*7+index*3)%9;if k==0 then return Color3.fromRGB(34,44,56),false end;return lit[k%#lit+1],true end
 -- Front windows: glow, frame cross and sill. Apartments also get flower boxes.
 local n=0
 for _,w in model:GetChildren() do if w.Name=="Window" and w:IsA("BasePart") then
  n+=1;local color,on=windowColor(n)
  w.Color=color;w.Material=on and Enum.Material.Neon or Enum.Material.SmoothPlastic
  p("WindowMullion",Vector3.new(.25,w.Size.Y,.12),w.CFrame*CFrame.new(0,0,.2),frameColor)
  p("WindowMullion",Vector3.new(w.Size.X,.25,.12),w.CFrame*CFrame.new(0,0,.2),frameColor)
  p("WindowSill",Vector3.new(w.Size.X+.8,.3,.7),w.CFrame*CFrame.new(0,-w.Size.Y/2-.15,.3),Color3.fromRGB(196,190,176))
  if model.Name=="APARTMENTS" and on then
   p("FlowerBox",Vector3.new(w.Size.X-.6,.5,.5),w.CFrame*CFrame.new(0,-w.Size.Y/2+.1,.55),Color3.fromRGB(120,74,48),Enum.Material.Wood)
   for i=-2,2 do p("Flower",Vector3.new(.45,.45,.45),w.CFrame*CFrame.new(i*1.1,-w.Size.Y/2+.55,.55),i%2==0 and Color3.fromRGB(255,120,160) or Color3.fromRGB(255,220,90),nil,Enum.PartType.Ball) end
  elseif model.Name=="LATE SHIFT OFFICE" and n%3==0 then
   p("WallAC",Vector3.new(2.2,1.4,1.2),w.CFrame*CFrame.new(2.2,-w.Size.Y/2-1.2,.7),metal,Enum.Material.Metal)
  end
 end end
 -- Side windows so the buildings read as occupied from down the street.
 for _,side in {-1,1} do for row,y in {-6.5,4.5} do for col,z in {-7,0,7} do
  n+=1;local color,on=windowColor(n)
  local wcf=at(side*(half.X+.15),y,z)
  p("SideWindow",Vector3.new(.3,4.6,4),wcf,color,on and Enum.Material.Neon or Enum.Material.SmoothPlastic)
  p("WindowSill",Vector3.new(.7,.3,4.6),wcf*CFrame.new(side*.25,-2.45,0),Color3.fromRGB(196,190,176))
 end end end
 -- Trim: plinth, floor band and an accent neon strip under the roof edge.
 p("Plinth",Vector3.new(body.Size.X+.6,1.2,body.Size.Z+.6),at(0,-half.Y+.6,0),body.Color:Lerp(Color3.new(),.35),Enum.Material.Concrete)
 p("FloorBand",Vector3.new(body.Size.X+.5,.6,body.Size.Z+.5),at(0,-1,0),body.Color:Lerp(Color3.new(1,1,1),.25))
 p("RoofStrip",Vector3.new(body.Size.X+.4,.25,.25),at(0,half.Y-.4,half.Z+.2),accent,Enum.Material.Neon)
 -- Sign glow and underline.
 light(sign,Color3.fromRGB(255,220,170),1.4,12)
 p("SignUnderline",Vector3.new(sign.Size.X-4,.25,.25),CFrame.new(sign.Position+Vector3.new(0,-sign.Size.Y/2-.35,.3)),accent,Enum.Material.Neon)
 -- Entrance: warm lobby glow, frame, small awning and a lamp.
 local door=model:FindFirstChild("Door")
 if door then
  door.Color=Color3.fromRGB(255,214,150);door.Material=Enum.Material.Neon
  local dcf=door.CFrame;local dw,dh=door.Size.X,door.Size.Y
  p("DoorFrame",Vector3.new(.5,dh+.5,.4),dcf*CFrame.new(-dw/2-.25,.25,.2),frameColor)
  p("DoorFrame",Vector3.new(.5,dh+.5,.4),dcf*CFrame.new(dw/2+.25,.25,.2),frameColor)
  p("DoorFrame",Vector3.new(dw+1,.5,.4),dcf*CFrame.new(0,dh/2+.25,.2),frameColor)
  p("DoorBars",Vector3.new(.2,dh,.15),dcf*CFrame.new(0,0,.2),frameColor)
  p("DoorAwning",Vector3.new(dw+3,.35,2.6),dcf*CFrame.new(0,dh/2+1.1,1.3)*CFrame.Angles(math.rad(12),0,0),accent:Lerp(Color3.new(),.2),Enum.Material.Fabric)
  local lamp=p("DoorLamp",Vector3.new(.6,.6,.6),dcf*CFrame.new(0,dh/2+.6,.6),Color3.fromRGB(255,226,170),Enum.Material.Neon,Enum.PartType.Ball)
  light(lamp,Color3.fromRGB(255,206,150),1.6,14)
  p("DoorStep",Vector3.new(dw+2,.3,2),dcf*CFrame.new(0,-dh/2+.1,1.1),Color3.fromRGB(120,120,118),Enum.Material.Concrete,nil,true)
 end
 -- Rooftop clutter seen from across the street.
 local top=half.Y+1
 p("RoofAC",Vector3.new(4,2.4,3),at(-14,top+1.2,-4),metal,Enum.Material.Metal)
 p("RoofAC",Vector3.new(3,2,3),at(16,top+1,-6),metal,Enum.Material.Metal)
 p("AntennaPole",Vector3.new(.3,8,.3),at(22,top+4,4),metal,Enum.Material.Metal)
 p("AntennaLight",Vector3.new(.6,.6,.6),at(22,top+8.2,4),Color3.fromRGB(255,60,60),Enum.Material.Neon,Enum.PartType.Ball)
 -- Signature props on the sidewalk in front (citizens stand further out, near the street).
 local front=half.Z
 if model.Name=="APARTMENTS" then
  p("WaterTank",Vector3.new(5,4,4),at(-22,top+2.5,5)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(150,108,80),Enum.Material.WoodPlanks,Enum.PartType.Cylinder)
  for _,x in {-6,6} do
   p("Planter",Vector3.new(2,1.6,2),at(x,-half.Y+.8,front+1.5),Color3.fromRGB(150,100,70),Enum.Material.Brick,nil,true)
   p("Shrub",Vector3.new(2.6,2.6,2.6),at(x,-half.Y+2.6,front+1.5),Color3.fromRGB(60,128,72),Enum.Material.Grass,Enum.PartType.Ball)
  end
 elseif model.Name=="CORNER MARKET" then
  local fruit={Color3.fromRGB(240,70,60),Color3.fromRGB(255,170,40),Color3.fromRGB(150,210,70)}
  for i,x in {-11,-7.5,7.5} do
   p("Crate",Vector3.new(3,1.6,2.2),at(x,-half.Y+.8,front+1.8),Color3.fromRGB(176,128,76),Enum.Material.Wood,nil,true)
   for j=-1,1 do p("Fruit",Vector3.new(.8,.8,.8),at(x+j*.9,-half.Y+1.9,front+1.8),fruit[i],nil,Enum.PartType.Ball) end
  end
  local open=p("OpenSign",Vector3.new(5,1.6,.2),at(-10,-3,front+.3),Color3.fromRGB(20,24,28))
  local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(300,96);gui.LightInfluence=0;gui.Parent=open
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="OPEN 24H";t.TextScaled=true;t.Font=Enum.Font.GothamBlack;t.TextColor3=Color3.fromRGB(255,90,150);t.Parent=gui
 elseif model.Name=="CITY CLINIC" then
  local green=Color3.fromRGB(70,235,120)
  p("ClinicCross",Vector3.new(1.2,4,.3),at(-27,2,front+.3),green,Enum.Material.Neon)
  p("ClinicCross",Vector3.new(4,1.2,.3),at(-27,2,front+.3),green,Enum.Material.Neon)
  light(folder:FindFirstChild("ClinicCross"),green,1,10)
  bench(9,5,Color3.fromRGB(120,84,56),Enum.Material.Wood)
 elseif model.Name=="LATE SHIFT OFFICE" then
  for _,x in {-5,5} do
   p("Planter",Vector3.new(1.6,1.8,1.6),at(x,-half.Y+.9,front+1.2),Color3.fromRGB(60,64,72),Enum.Material.Metal,nil,true)
   p("Shrub",Vector3.new(1.6,3.2,1.6),at(x,-half.Y+3.3,front+1.2),Color3.fromRGB(56,120,80),Enum.Material.Grass,Enum.PartType.Ball)
  end
 elseif model.Name=="BUS TERMINAL" then
  local board=p("DepartureBoard",Vector3.new(5,2.4,.3),at(-26.5,-3.5,front+.3),Color3.fromRGB(16,18,22))
  local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(300,144);gui.LightInfluence=0;gui.Parent=board
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="NEXT BUS\nMALL";t.TextScaled=true;t.Font=Enum.Font.Code;t.TextColor3=Color3.fromRGB(255,190,60);t.Parent=gui
  bench(9,6,Color3.fromRGB(70,90,110),Enum.Material.Metal)
 end
end
-- Tree variety for any model with trunk/crown pairs (shop rows and the park): size, shape (round, small, pine,
-- cluster, blossom, autumn), bushes at the base and fairy lights strung between neighbours in a row.
-- Extra parts carry TreeRowDecor so ShopService's dining expansion shifts them with the right-hand tree row.
function City.DressTrees(model,trunkName,crownName)
 local trees={}
 for _,trunk in model:GetChildren() do if trunk.Name==trunkName and trunk:IsA("BasePart") and not trunk:GetAttribute("TreeVaried") then
  for _,crown in model:GetChildren() do
   if crown.Name==crownName and crown:IsA("BasePart") and (Vector2.new(crown.Position.X,crown.Position.Z)-Vector2.new(trunk.Position.X,trunk.Position.Z)).Magnitude<3 then table.insert(trees,{trunk,crown});break end
  end
 end end
 local function extra(name,size,pos,color,material,shape)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.Position=pos;a.Color=color;a.Material=material or Enum.Material.Grass
  a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.CastShadow=size.Magnitude>=2;a.Shape=shape or Enum.PartType.Ball;a:SetAttribute("TreeRowDecor",true);a.Parent=model;return a
 end
 local greens={Color3.fromRGB(46,110,72),Color3.fromRGB(64,132,70),Color3.fromRGB(36,94,66),Color3.fromRGB(88,142,62)}
 local info={}
 for i,tree in trees do
  local trunk,crown=tree[1],tree[2];trunk:SetAttribute("TreeVaried",true)
  local x,z=trunk.Position.X,trunk.Position.Z
  local kind=math.abs(math.floor(x*7+z*13+.5))%6
  local scale=.8+(math.abs(math.floor(x*3+z*5+.5))%5)*.1
  local ground=trunk.Position.Y-trunk.Size.Y/2
  local height=trunk.Size.Y*scale*(kind==2 and 1.1 or 1)
  local thin=(kind==1 or kind==2) and .75 or 1
  trunk.Size=Vector3.new(trunk.Size.X*thin,height,trunk.Size.Z*thin);trunk.Position=Vector3.new(x,ground+height/2,z)
  local top=ground+height
  local width=math.min(crown.Size.X,crown.Size.Z)*scale*(kind==1 and .75 or 1)
  local green=greens[(i+kind)%#greens+1]
  crown.Shape=Enum.PartType.Ball
  if kind==2 then -- pine: three stacked, shrinking balls
   crown.Size=Vector3.one*width;crown.Position=Vector3.new(x,top+width*.15,z);crown.Color=Color3.fromRGB(30,84,60)
   extra("TreeExtra",Vector3.one*width*.72,Vector3.new(x,top+width*.65,z),Color3.fromRGB(34,92,64))
   extra("TreeExtra",Vector3.one*width*.45,Vector3.new(x,top+width*1.05,z),Color3.fromRGB(40,100,68))
  elseif kind==3 then -- cluster: a main crown with two side puffs
   crown.Size=Vector3.one*width*.85;crown.Position=Vector3.new(x,top+width*.3,z);crown.Color=green
   for _,side in {-1,1} do extra("TreeExtra",Vector3.one*width*.6,Vector3.new(x+side*width*.42,top+width*.05,z+side*width*.2),green:Lerp(Color3.new(1,1,1),.08)) end
  else
   crown.Size=Vector3.one*width;crown.Position=Vector3.new(x,top+width*.3,z)
   crown.Color=kind==4 and Color3.fromRGB(240,150,195) or kind==5 and Color3.fromRGB(222,132,58) or green
  end
  for _,part in {trunk,crown} do if part:GetAttribute("DiningTreeBaseCFrame") then part:SetAttribute("DiningTreeBaseCFrame",part.CFrame) end end
  if i%2==0 then
   for b,offset in {Vector3.new(2.3,0,1.2),Vector3.new(-1.8,0,-1.6)} do
    local size=2.2+((i+b)%3)*.4
    local bush=extra("TreeBush",Vector3.one*size,Vector3.new(x,ground+size*.4,z)+offset,greens[(i+b)%#greens+1])
    if (i+b)%2==0 then for f=0,2 do extra("BushFlower",Vector3.one*.35,bush.Position+Vector3.new(math.cos(f*2.1)*size*.32,size*.38,math.sin(f*2.1)*size*.32),f%2==0 and Color3.fromRGB(255,120,170) or Color3.fromRGB(255,224,96),Enum.Material.SmoothPlastic) end end
   end
  end
  info[trunk]={X=x,Z=z,Height=height,Ground=ground}
 end
 -- Fairy lights between neighbouring trees that share a row (same X or same Z).
 local bulbColors={Color3.fromRGB(255,214,120),Color3.fromRGB(255,130,190),Color3.fromRGB(120,220,255),Color3.fromRGB(255,170,90)}
 local list={};for trunk,v in info do table.insert(list,v) end
 for _,a in list do for _,b in list do
  local sameRow=(math.abs(a.X-b.X)<.5 and b.Z>a.Z) or (math.abs(a.Z-b.Z)<.5 and b.X>a.X)
  local gap=Vector2.new(b.X-a.X,b.Z-a.Z).Magnitude
  if sameRow and gap<=16 then
   local closer=true;for _,c in list do
    local between=(math.abs(c.X-a.X)<.5 and math.abs(c.X-b.X)<.5 and c.Z>a.Z and c.Z<b.Z) or (math.abs(c.Z-a.Z)<.5 and math.abs(c.Z-b.Z)<.5 and c.X>a.X and c.X<b.X)
    if between then closer=false end
   end
   if closer then
    local y=math.min(a.Ground+a.Height*.6,b.Ground+b.Height*.6)
    for k=1,7 do
     local t=k/8
     local pos=Vector3.new(a.X+(b.X-a.X)*t,y-math.sin(t*math.pi)*1.4,a.Z+(b.Z-a.Z)*t)
     extra("FairyLight",Vector3.one*.4,pos,bulbColors[(k+math.floor(a.X+a.Z))%#bulbColors+1],Enum.Material.Neon)
    end
   end
  end
 end end
end
-- Midnight Mall interior: real window openings in the front wall plus grocery aisles, drink fridges,
-- checkout details and hanging section signs. The supply counter/shelves and their prompts are untouched.
local function dressMall(mall)
 local floor=mall:FindFirstChild("Floor");if not floor then return end
 -- Three wide ceiling lights used to overlap at full brightness and bleach packaging.
 for _,fixture in mall:GetChildren() do if fixture.Name=="MallLight" then
  local light=fixture:FindFirstChildOfClass("PointLight")
  if light then light.Brightness=.65;light.Range=29;light.Color=Color3.fromRGB(255,235,213) end
 end end
 local old=mall:FindFirstChild("MallInterior");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="MallInterior";folder.Parent=mall
 local base=floor.Position.Y+floor.Size.Y/2
 local function p(name,size,cf,color,material,shape,solid)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.CFrame=cf;a.Color=color;a.Material=material or Enum.Material.SmoothPlastic
  a.Anchored=true;a.CanCollide=solid==true;a.CanQuery=false;a.CanTouch=false;a.CastShadow=size.Magnitude>=2;if shape then a.Shape=shape end;a.Parent=folder;return a
 end
 local function at(x,y,z) return CFrame.new(x,base+y,z) end
 local function sign(name,text,cf,width,color)
  local board=p(name,Vector3.new(width,1.6,.2),cf,Color3.fromRGB(20,26,32))
  for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
   local gui=Instance.new("SurfaceGui");gui.Face=face;gui.CanvasSize=Vector2.new(width*60,96);gui.LightInfluence=0;gui.Parent=board
   local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBlack;t.TextColor3=color;t.Parent=gui
  end
  for _,x in {-width/2+.6,width/2-.6} do p("SignWire",Vector3.new(.05,3,.05),cf*CFrame.new(x,2.3,0),Color3.fromRGB(30,30,34)) end
  return board
 end
 -- Front wall: replace each solid segment with pieces framing its display window so the glass is see-through.
 local windows={};for _,w in mall:GetChildren() do if w.Name=="DisplayWindow" and w:IsA("BasePart") then table.insert(windows,w) end end
 for _,wall in mall:GetChildren() do if wall.Name=="FrontWall" and wall:IsA("BasePart") then
  local glass;for _,w in windows do if math.abs(w.Position.X-wall.Position.X)<wall.Size.X/2 then glass=w end end
  if glass then
   wall.Transparency=1;wall.CanCollide=false;wall.CanQuery=false
   local wl,wr=wall.Position.X-wall.Size.X/2,wall.Position.X+wall.Size.X/2
   local wb,wt=wall.Position.Y-wall.Size.Y/2,wall.Position.Y+wall.Size.Y/2
   local gl,gr=glass.Position.X-glass.Size.X/2,glass.Position.X+glass.Size.X/2
   local gb,gt=glass.Position.Y-glass.Size.Y/2,glass.Position.Y+glass.Size.Y/2
   local z=wall.Position.Z
   local function piece(x0,x1,y0,y1) if x1-x0>.01 and y1-y0>.01 then p("FrontWallPiece",Vector3.new(x1-x0,y1-y0,wall.Size.Z),CFrame.new((x0+x1)/2,(y0+y1)/2,z),wall.Color,wall.Material,nil,true) end end
   piece(wl,wr,wb,gb);piece(wl,wr,gt,wt);piece(wl,gl,gb,gt);piece(gr,wr,gb,gt)
   glass.Transparency=.75;glass.Color=Color3.fromRGB(170,215,225);glass.Position=Vector3.new(glass.Position.X,glass.Position.Y,z)
   p("WindowFrame",Vector3.new(glass.Size.X+.4,.3,.7),CFrame.new(glass.Position.X,gb,z),Color3.fromRGB(40,44,50),Enum.Material.Metal)
   p("WindowFrame",Vector3.new(glass.Size.X+.4,.3,.7),CFrame.new(glass.Position.X,gt,z),Color3.fromRGB(40,44,50),Enum.Material.Metal)
  end
 end end
 -- Warm interior lighting so the store reads from the street.
 for _,x in {420,445,470} do
  local lamp=p("MallGlow",Vector3.new(.2,.2,.2),at(x,14,-95),Color3.new(1,1,1));lamp.Transparency=1
  local l=Instance.new("PointLight");l.Color=Color3.fromRGB(255,232,196);l.Brightness=.25;l.Range=22;l.Parent=lamp
 end
 -- Wall dressing: teal wainscot on the back/side walls, an accent strip and a promo banner on the back wall.
 local teal,stripe=Color3.fromRGB(64,128,124),Color3.fromRGB(255,199,101)
 local back=mall:FindFirstChild("BackWall")
 if back then
  local z=back.Position.Z+back.Size.Z/2+.06
  p("Wainscot",Vector3.new(back.Size.X-2,3,.1),CFrame.new(back.Position.X,base+1.5,z),teal)
  p("WallStripe",Vector3.new(back.Size.X-2,.3,.12),CFrame.new(back.Position.X,base+3.15,z),stripe,Enum.Material.Neon)
  local banner=p("PromoBanner",Vector3.new(30,5,.15),CFrame.new(back.Position.X,base+11,z+.05),Color3.fromRGB(150,52,58),Enum.Material.Fabric)
  local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(900,150);gui.LightInfluence=0;gui.Parent=banner
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="FRESH INGREDIENTS 24/7";t.TextScaled=true;t.Font=Enum.Font.GothamBlack;t.TextColor3=Color3.fromRGB(255,236,200);t.Parent=gui
 end
 for _,name in {"LeftWall","RightWall"} do local w=mall:FindFirstChild(name);if w then
  local x=w.Position.X+(name=="LeftWall" and 1 or -1)*(w.Size.X/2+.06)
  p("Wainscot",Vector3.new(.1,3,w.Size.Z-2),CFrame.new(x,base+1.5,w.Position.Z),teal)
  p("WallStripe",Vector3.new(.12,.3,w.Size.Z-2),CFrame.new(x,base+3.15,w.Position.Z),stripe,Enum.Material.Neon)
 end end
 -- Entrance runner and potted plants.
 p("EntranceMat",Vector3.new(8,.06,12),at(445,.03,-84),Color3.fromRGB(150,52,58),Enum.Material.Fabric)
 for _,x in {437,453} do
  p("Planter",Vector3.new(1.8,1.6,1.8),at(x,.8,-80),Color3.fromRGB(210,206,196),Enum.Material.Concrete,nil,true)
  p("Plant",Vector3.new(2.4,3.2,2.4),at(x,2.8,-80),Color3.fromRGB(70,140,82),Enum.Material.Grass,Enum.PartType.Ball)
 end
 -- Left wing: grocery aisles of colourful products, visible through the left window.
 local productColors={{235,80,70},{250,190,60},{80,170,230},{120,200,100},{240,140,190},{250,250,240},{160,110,220},{240,120,50}}
 local function shelf(x,z,seed)
  local frame=Color3.fromRGB(100,124,128)
  p("ShelfBack",Vector3.new(10,6,.3),at(x,3,z),frame,Enum.Material.Metal,nil,true)
  for _,dx in {-5,5} do p("ShelfSide",Vector3.new(.3,6,3),at(x+dx,3,z),frame,Enum.Material.Metal,nil,true) end
  for level=0,2 do
   local y=.6+level*1.9
   p("ShelfBoard",Vector3.new(10,.2,3),at(x,y,z),frame,Enum.Material.Metal,nil,true)
   for side=-1,1,2 do for i=0,6 do
    local c=productColors[(seed+level*3+i+side)%#productColors+1]
    local h=.7+((seed+i+level)%3)*.2
    local cf=at(x-4.2+i*1.4,y+.1+h/2,z+side*.9)
    local tint=Color3.fromRGB(c[1],c[2],c[3])
    if (i+seed)%3==0 then
     p("PantryCan",Vector3.new(h,.72,.72),cf*CFrame.Angles(0,0,math.pi/2),tint,nil,Enum.PartType.Cylinder)
     p("CanLid",Vector3.new(.06,.73,.73),cf*CFrame.new(0,h/2,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(150,161,164),Enum.Material.Metal,Enum.PartType.Cylinder)
    else
     p("Product",Vector3.new(.9,h,.8),cf,tint)
    end
    -- High-contrast package band reads at phone resolution without hundreds of text GUIs.
    p("PackageLabel",Vector3.new(.5,h*.32,.025),cf*CFrame.new(0,0,side*.415),Color3.fromRGB(238,224,189))
   end end
  end
  return p("ShelfTop",Vector3.new(10.2,.3,3.2),at(x,6.1,z),Color3.fromRGB(240,90,80),nil,nil,true)
 end
 shelf(417,-86,1);shelf(417,-97,4);shelf(417,-112,6)
 sign("AisleSign","GROCERY",at(417,11,-92),8,Color3.fromRGB(255,214,92))
 -- Right wing: glowing drink fridges along the right wall and a snack island.
 local wallX=485-.5
 for i=0,4 do
  local z=-84-i*3.4
  -- Open-fronted cabinet (back, base, top, divider) so the bottles show through the glass door.
  local white=Color3.fromRGB(220,224,230)
  p("FridgeBack",Vector3.new(.3,7.5,3.2),at(wallX-.15,3.75,z),white,Enum.Material.Metal,nil,true)
  p("FridgeBase",Vector3.new(2.4,.8,3.2),at(wallX-1.2,.4,z),white,Enum.Material.Metal,nil,true)
  p("FridgeTop",Vector3.new(2.4,.8,3.2),at(wallX-1.2,7.1,z),white,Enum.Material.Metal,nil,true)
  p("FridgeDivider",Vector3.new(2.4,7.5,.15),at(wallX-1.2,3.75,z+1.6),white,Enum.Material.Metal,nil,true)
  if i==4 then p("FridgeDivider",Vector3.new(2.4,7.5,.15),at(wallX-1.2,3.75,z-1.6),white,Enum.Material.Metal,nil,true) end
  for level=0,3 do p("FridgeShelf",Vector3.new(2.1,.08,3),at(wallX-1.2,.82+level*1.5,z),Color3.fromRGB(190,196,204),Enum.Material.Metal) end
  local door=p("FridgeDoor",Vector3.new(.15,5.6,3),at(wallX-2.48,3.75,z),Color3.fromRGB(170,225,255),Enum.Material.Glass,nil,true);door.Transparency=.7
  p("FridgeLight",Vector3.new(.1,6.2,.15),at(wallX-2.3,3.75,z-1.35),Color3.fromRGB(200,240,255),Enum.Material.Neon)
  for level=0,3 do for j=-1,1 do
   local c=productColors[(i+level+j+2)%#productColors+1]
   local cf=at(wallX-1.6,1.3+level*1.5,z+j*.8)
   p("Bottle",Vector3.new(.9,.4,.4),cf*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(c[1],c[2],c[3]),Enum.Material.Glass,Enum.PartType.Cylinder)
   p("BottleCap",Vector3.new(.14,.25,.25),cf*CFrame.new(0,.5,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(53,76,82),nil,Enum.PartType.Cylinder)
  end end
 end
 sign("AisleSign","COLD DRINKS",at(478,11,-92),9,Color3.fromRGB(120,220,255))
 local island=p("SnackIsland",Vector3.new(6,2.4,4),at(468,1.2,-100),Color3.fromRGB(176,128,76),Enum.Material.Wood,nil,true)
 for i=0,5 do local c=productColors[i%#productColors+1];p("SnackBag",Vector3.new(.9,1.1,.5),island.CFrame*CFrame.new(-2.3+i*.92,1.75,0)*CFrame.Angles(math.rad(-15),0,0),Color3.fromRGB(c[1],c[2],c[3]),Enum.Material.Foil) end
 -- Dress the three existing central supply displays; leave their interaction paths clear.
 local displays={}
 for _,item in mall:GetChildren() do if item.Name=="SupplyShelf" and item:IsA("BasePart") then table.insert(displays,item) end end
 table.sort(displays,function(a,b)return a.Position.X<b.Position.X end)
 for index,display in displays do
  local top=display.Position.Y+display.Size.Y/2
  local cf=CFrame.new(display.Position.X,top,display.Position.Z)
  display.Color=Color3.fromRGB(62,95,97);display.Material=Enum.Material.SmoothPlastic
  p("DisplayTop",Vector3.new(display.Size.X+.12,.12,display.Size.Z+.12),cf,Color3.fromRGB(133,92,57),Enum.Material.Wood)
  for tray=1,2 do
   local trayCF=cf*CFrame.new((tray==1 and -1 or 1)*2.1,.15,0)
   p("ProduceTray",Vector3.new(3.7,.22,3.1),trayCF,Color3.fromRGB(80,55,37),Enum.Material.Wood)
   for _,z in {-1.5,1.5} do p("CrateLip",Vector3.new(3.7,.4,.13),trayCF*CFrame.new(0,.24,z),Color3.fromRGB(168,119,68),Enum.Material.Wood) end
   for n=1,6 do
    local x=((n-1)%3-1)*1.05;local z=(math.floor((n-1)/3)-.5)*1.25
    local itemCF=trayCF*CFrame.new(x,.6,z)
    if index==1 then
     p("FlourBag",Vector3.new(.85,.95,.85),itemCF,Color3.fromRGB(211,185,139),Enum.Material.Fabric)
     p("BagLabel",Vector3.new(.55,.35,.03),itemCF*CFrame.new(0,0,.44),Color3.fromRGB(72,113,109))
    elseif index==2 then
     local tint=tray==1 and Color3.fromRGB(197,69,45) or Color3.fromRGB(104,152,61)
     p("FreshProduce",Vector3.new(.85,.8,.85),itemCF,tint,nil,Enum.PartType.Ball)
     p("ProduceLeaf",Vector3.new(.35,.08,.25),itemCF*CFrame.new(0,.43,0),Color3.fromRGB(40,93,46))
    else
     p("TeaTin",Vector3.new(.95,.78,.78),itemCF*CFrame.Angles(0,0,math.pi/2),tray==1 and Color3.fromRGB(183,104,43) or Color3.fromRGB(57,118,111),nil,Enum.PartType.Cylinder)
     p("TeaTinLid",Vector3.new(.08,.82,.82),itemCF*CFrame.new(0,.51,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(199,172,106),nil,Enum.PartType.Cylinder)
    end
   end
  end
  local board=p("DisplayLabel",Vector3.new(5,.85,.08),cf*CFrame.new(0,-.65,display.Size.Z/2+.08),Color3.fromRGB(24,54,58))
  local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(500,85);gui.LightInfluence=0;gui.Parent=board
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextScaled=true
  label.Text=({"PANTRY STAPLES","FRESH PRODUCE","TEA & DRINKS"})[index] or "INGREDIENTS";label.TextColor3=Color3.fromRGB(241,221,176);label.Parent=gui
 end
 -- Checkout details on the existing supply counter, plus carts and baskets by the entrance.
 local counter=mall:FindFirstChild("SuppliesCheckout")
 if counter then
  local top=counter.Position.Y+counter.Size.Y/2
  p("Register",Vector3.new(1.4,.7,1.1),CFrame.new(counter.Position.X+5.2,top+.35,counter.Position.Z),Color3.fromRGB(40,44,52),Enum.Material.Metal)
  p("RegisterScreen",Vector3.new(1.2,.8,.1),CFrame.new(counter.Position.X+5.2,top+1.05,counter.Position.Z+.2)*CFrame.Angles(math.rad(-15),0,0),Color3.fromRGB(110,231,193),Enum.Material.Neon)
  p("Scanner",Vector3.new(1,.1,.8),CFrame.new(counter.Position.X+2.2,top+.05,counter.Position.Z),Color3.fromRGB(240,90,80),Enum.Material.Neon)
  for i=0,3 do p("BasketStack",Vector3.new(1.6,.35,1.1),CFrame.new(counter.Position.X-7.5,base+.2+i*.32,counter.Position.Z+1),Color3.fromRGB(230,70,70)) end
 end
 for i,x in {430,433} do
  local cf=at(x,0,-81)*CFrame.Angles(0,math.rad(20),0)
  p("CartBasket",Vector3.new(2,1.4,3),cf*CFrame.new(0,2,0),Color3.fromRGB(200,206,214),Enum.Material.DiamondPlate,nil,true)
  p("CartHandle",Vector3.new(2,.15,.15),cf*CFrame.new(0,3,1.7),Color3.fromRGB(240,90,80))
  for _,w in {{-.8,-1.2},{.8,-1.2},{-.8,1.2},{.8,1.2}} do p("CartWheel",Vector3.new(.2,.5,.5),cf*CFrame.new(w[1],.25,w[2]),Color3.fromRGB(30,30,34),nil,Enum.PartType.Cylinder) end
  p("CartFrame",Vector3.new(1.8,.15,2.8),cf*CFrame.new(0,.6,0),Color3.fromRGB(160,166,174),Enum.Material.Metal)
 end
end
function City.Start()
 local mall=world:FindFirstChild("ShoppingMall");if mall then dressMall(mall) end
 City.DressTrees(world,"ParkTree","Canopy")
 local index=0
 for _,model in world:GetChildren() do if model:IsA("Model") and model:FindFirstChild("Building") then index+=1;dressBuilding(model,index) end end
 local rain=Instance.new("Part");rain.Name="RainCloud";rain.Size=Vector3.new(620,.1,130);rain.Position=Vector3.new(185,40,-25);rain.Anchored=true;rain.Transparency=1;rain.CanCollide=false;rain.CanQuery=false;rain.Parent=world
 local drops=Instance.new("ParticleEmitter");drops.Name="Rain";drops.Texture="rbxasset://textures/particles/sparkles_main.dds";drops.Rate=0;drops.EmissionDirection=Enum.NormalId.Bottom;drops.Speed=NumberRange.new(38);drops.Lifetime=NumberRange.new(1);drops.Size=NumberSequence.new(.07);drops.Squash=NumberSequence.new(2);drops.Transparency=NumberSequence.new(.45);drops.Color=ColorSequence.new(Color3.fromRGB(161,186,198));drops.Parent=rain

 local destinations=world.Destinations:GetChildren()
 for i,name in ipairs(names) do
  local initial=destinations[(i-1)%#destinations+1].Value+Vector3.new((i-6.5)*3,0,0)
  local m=create(name,initial,Color3.fromHSV(i/#names,.45,.8),i)
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
