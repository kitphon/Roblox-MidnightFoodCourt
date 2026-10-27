local Recipes=require(script.Parent.RecipeCatalog)
local F={}
local Details=require(script.Parent.FoodDetails)
function F.Build(recipe,parent,name)
 if recipe.BaseId then
  local model=F.Build(Recipes.Get(recipe.BaseId),nil,name or recipe.Id)
  model:SetAttribute("RecipeId",recipe.Id)
  -- Variants keep the same canonical geometry in icons, menus and carried meals.
  if recipe.Id=="OC_FISH_BURGER" then
   for _,part in model:GetDescendants() do if part:IsA("BasePart") and (part.Name=="GrilledPatty" or part.Name=="PattyTexture") then part.Color=Color3.fromRGB(220,167,84) end end
  end
  local drinkColors={MK_LEMON_TEA={174,105,38},JP_ICED_TEA={146,161,67},BK_LIME_SODA={197,225,145},SK_LIME_SODA={197,225,145}}
  local tint=drinkColors[recipe.Id]
  if tint then for _,part in model:GetDescendants() do if part:IsA("BasePart") then
   if part.Name=="Drink" or part.Name=="Lemonade" then part.Color=Color3.fromRGB(unpack(tint))
   elseif (recipe.Id=="BK_LIME_SODA" or recipe.Id=="SK_LIME_SODA") and part.Name=="LemonSliceRind" then part.Color=Color3.fromRGB(83,160,57) end
  end end end
  model.Parent=parent;return model
 end
 if Details.Supports(recipe.Id) then return Details.Build(recipe,parent,name,F.Build,Recipes) end
 local m=Instance.new("Model");m.Name=name or recipe.Id
 local dark=Color3.fromRGB(47,52,48);local cream=Color3.fromRGB(248,235,202);local gold=Color3.fromRGB(223,158,71);local green=Color3.fromRGB(97,156,67);local red=Color3.fromRGB(198,72,58)
 local color=Color3.fromRGB(unpack(recipe.Color))
 local function p(n,size,pos,c,shape)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.Position=pos;a.Color=c;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.Parent=m
  if shape then a.Shape=shape end
  return a
 end
 local root=p("Root",Vector3.new(.02,.02,.02),Vector3.zero,dark);root.Transparency=1;m.PrimaryPart=root
 local function ball(n,size,pos,c)
  if recipe.Id=="NOODLES" or recipe.Id=="FRIED RICE" or recipe.Id=="RD_BURGER" or recipe.Id=="RD_HOT_DOG" or recipe.Id:match("^OC_") then
   local a=p(n,size,pos,c)
   local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=a
   return a
  end
  return p(n,size,pos,c,Enum.PartType.Ball)
 end
 local function plate() p("Plate",Vector3.new(2,.14,1.55),Vector3.new(0,.1,0),cream) end
 local shape=recipe.Shape
 if recipe.Id=="NOODLES" then
  -- Open ceramic bowl: visible broth, curled noodles, meatballs and greens.
  ball("BowlFoot",Vector3.new(1.15,.18,1.15),Vector3.new(0,.12,0),Color3.fromRGB(38,87,94))
  ball("BowlBody",Vector3.new(1.92,.65,1.92),Vector3.new(0,.39,0),Color3.fromRGB(78,137,143))
  ball("Broth",Vector3.new(1.76,.11,1.76),Vector3.new(0,.7,0),Color3.fromRGB(151,82,36))
  for i=1,24 do
   local a=i*math.pi*2/24
   local rim=p("CeramicRim",Vector3.new(.26,.12,.13),Vector3.new(math.cos(a)*.9,.76,math.sin(a)*.9),Color3.fromRGB(43,101,108))
   rim.Rotation=Vector3.new(0,-math.deg(a)-90,0)
  end
  for strand=1,6 do
   local cx=(strand%3-1)*.36;local cz=(math.floor((strand-1)/3)-.5)*.46
   for j=1,8 do
    local a=j*math.pi*2/8;local b=(j+1)*math.pi*2/8
    local from=Vector3.new(cx+math.cos(a)*.22,.79,cz+math.sin(a)*.15)
    local to=Vector3.new(cx+math.cos(b)*.22,.79,cz+math.sin(b)*.15)
    local noodle=p("CurledNoodle",Vector3.new(.055,.055,(to-from).Magnitude+.025),(from+to)/2,Color3.fromRGB(250,211,125))
    noodle.CFrame=CFrame.lookAt((from+to)/2,to)
   end
  end
  for i=1,3 do ball("Meatball",Vector3.new(.29,.25,.29),Vector3.new(-.45+(i-1)*.38,.84,.46),Color3.fromRGB(173,128,91)) end
  for i=1,3 do local leaf=ball("BokChoyLeaf",Vector3.new(.29,.09,.5),Vector3.new(.5+(i-2)*.13,.84,-.35),Color3.fromRGB(48,128,52));leaf.Rotation=Vector3.new(0,(i-2)*30,0) end
  ball("EggSlice",Vector3.new(.5,.1,.4),Vector3.new(-.48,.85,-.38),cream)
  ball("EggYolk",Vector3.new(.28,.06,.24),Vector3.new(-.48,.92,-.38),Color3.fromRGB(238,141,25))
  for i=1,7 do p("Scallion",Vector3.new(.07,.035,.07),Vector3.new(math.sin(i*3)*.6,.85,math.cos(i*2)*.5),green) end
 elseif recipe.Id=="FRIED RICE" then
  -- A golden mound on a wide plate with individually visible grains.
  ball("PlateRim",Vector3.new(2.45,.17,2.05),Vector3.new(0,.12,0),Color3.fromRGB(43,101,108))
  ball("PlateWell",Vector3.new(2.12,.08,1.72),Vector3.new(0,.22,0),Color3.fromRGB(255,250,233))
  ball("FriedRiceMound",Vector3.new(1.65,.68,1.35),Vector3.new(-.08,.43,0),Color3.fromRGB(215,164,65))
  for i=1,76 do
   local radius=math.sqrt(i/77);local a=i*2.399963
   local x=math.cos(a)*radius*.76-.08;local z=math.sin(a)*radius*.61
   local y=.43+.34*math.sqrt(1-radius*radius)
   local grain=ball("RiceGrain",Vector3.new(.065,.05,.14),Vector3.new(x,y,z),i%3==0 and Color3.fromRGB(250,220,135) or Color3.fromRGB(231,186,89))
   grain.Rotation=Vector3.new(0,i*47%180,0)
  end
  for i=1,9 do
   local a=i*2.4;local radius=.25+(i%3)*.17
   local x=math.cos(a)*radius-.08;local z=math.sin(a)*radius*.8
   local y=.43+.34*math.sqrt(1-(radius/.8)^2)+.04
   ball("Pea",Vector3.new(.14,.12,.14),Vector3.new(x,y,z),Color3.fromRGB(53,130,52))
   local carrot=p("CarrotDice",Vector3.new(.14,.1,.14),Vector3.new(-x-.1,y,z+.1),Color3.fromRGB(218,91,30));carrot.Rotation=Vector3.new(0,i*23,0)
  end
  ball("FriedEggWhite",Vector3.new(.68,.09,.59),Vector3.new(.55,.6,-.3),Color3.fromRGB(255,247,216))
  ball("FriedEggYolk",Vector3.new(.3,.12,.29),Vector3.new(.55,.69,-.3),Color3.fromRGB(255,183,37))
  for i=1,3 do ball("CucumberSlice",Vector3.new(.28,.06,.29),Vector3.new(.85,.27,-.25+i*.25),Color3.fromRGB(93,155,64));ball("CucumberCenter",Vector3.new(.2,.02,.21),Vector3.new(.85,.31,-.25+i*.25),Color3.fromRGB(195,216,142)) end
 elseif recipe.Id~="OC_RICE" and (shape=="Noodles" or shape=="Rice" or shape=="Soup" or shape=="Salad") then
  ball("Bowl",Vector3.new(1.8,.8,1.55),Vector3.new(0,.4,0),cream)
  ball("Food",Vector3.new(1.55,.24,1.32),Vector3.new(0,.75,0),shape=="Rice" and cream or color)
  if shape=="Noodles" then
   for i=-2,2 do p("Noodle",Vector3.new(1.15,.05,.06),Vector3.new(0,.89,i*.17),gold) end
   p("Chopstick",Vector3.new(.06,.06,2),Vector3.new(.45,1,0),Color3.fromRGB(116,75,49)).Rotation=Vector3.new(0,-25,0)
  elseif shape=="Rice" then
   for i=-1,1 do ball("Topping",Vector3.new(.25,.12,.22),Vector3.new(i*.38,.92,.15),color) end
   ball("EggWhite",Vector3.new(.6,.1,.55),Vector3.new(.35,.94,-.25),cream);ball("Yolk",Vector3.new(.28,.1,.28),Vector3.new(.35,1.01,-.25),gold)
  elseif shape=="Salad" then for i=-2,2 do p("Papaya",Vector3.new(.9,.06,.07),Vector3.new(0,.9,i*.17),cream).Rotation=Vector3.new(0,i*14,0) end
  end
 elseif recipe.Id=="OC_TACO" then
  ball("OvalPlate",Vector3.new(2.45,.14,2.15),Vector3.new(0,.12,0),cream)
  -- A folded tortilla with an open top, rather than sandwich slabs.
  for i=0,10 do
   local a=math.pi+(i+.5)*math.pi/11
   local shell=p("CurvedTortilla",Vector3.new(.18,.075,1.65),Vector3.new(math.cos(a)*.6,.99+math.sin(a)*.6,0),Color3.fromRGB(236,186,79))
   shell.Rotation=Vector3.new(0,0,math.deg(a)+90)
  end
  for i=1,8 do
   local leaf=ball("ShreddedCabbage",Vector3.new(.28,.11,.38),Vector3.new(math.sin(i*2)*.27,.77,-.65+i*.15),i%2==0 and Color3.fromRGB(130,177,74) or Color3.fromRGB(153,89,143))
   leaf.Rotation=Vector3.new(0,i*31,0)
  end
  for _,x in {-.15,.15} do
   local fish=ball("CrispyFishFillet",Vector3.new(.3,.26,1.23),Vector3.new(x,.89,0),Color3.fromRGB(202,137,54))
   for i=1,5 do ball("FishCrumb",Vector3.new(.11,.09,.13),Vector3.new(x,.995,-.5+i*.18),Color3.fromRGB(246,199,107)) end
  end
  for i=1,7 do
   p("TomatoDice",Vector3.new(.11,.1,.1),Vector3.new(math.sin(i*2)*.24,1.055,-.62+i*.16),red)
   local sauce=p("LimeCrema",Vector3.new(.065,.045,.18),Vector3.new(math.cos(i)*.15,1.085,-.65+i*.17),cream);sauce.Rotation=Vector3.new(0,i*25,0)
  end
  ball("LimeWedge",Vector3.new(.4,.17,.3),Vector3.new(.8,.29,.56),Color3.fromRGB(106,168,63))
  ball("LimeFlesh",Vector3.new(.32,.06,.23),Vector3.new(.8,.39,.56),Color3.fromRGB(209,229,136))
 elseif recipe.Id=="OC_RICE" then
  ball("WhitePlate",Vector3.new(2.5,.15,2.15),Vector3.new(0,.12,0),cream)
  ball("SeafoodRiceMound",Vector3.new(1.8,.55,1.48),Vector3.new(0,.42,0),Color3.fromRGB(226,177,74))
  for i=1,54 do
   local r=math.sqrt(i/56);local a=i*2.399963
   local grain=ball("GoldenRiceGrain",Vector3.new(.065,.05,.14),Vector3.new(math.cos(a)*r*.82,.42+.275*math.sqrt(1-r*r),math.sin(a)*r*.67),Color3.fromRGB(250,211,122))
   grain.Rotation=Vector3.new(0,i*47,0)
  end
  for shrimp=1,3 do
   local cx=({-.47,.43,.05})[shrimp];local cz=({-.22,-.16,.42})[shrimp]
   for j=0,5 do
    local a=math.rad(-55+j*47)
    ball("ShrimpSegment",Vector3.new(.17,.14,.17),Vector3.new(cx+math.cos(a)*.21,.74,cz+math.sin(a)*.21),j%2==0 and Color3.fromRGB(242,143,106) or Color3.fromRGB(255,194,158))
   end
   local tail=p("ShrimpTail",Vector3.new(.21,.07,.14),Vector3.new(cx+.12,.77,cz-.2),Color3.fromRGB(216,102,75));tail.Rotation=Vector3.new(0,35,0)
  end
  for _,x in {-.55,.55} do
   local shell=ball("MusselShell",Vector3.new(.29,.13,.48),Vector3.new(x,.74,.37),Color3.fromRGB(43,57,65));shell.Rotation=Vector3.new(0,x*45,0)
   ball("MusselMeat",Vector3.new(.15,.06,.28),Vector3.new(x,.82,.37),Color3.fromRGB(235,166,79))
  end
  for i=1,9 do p("Parsley",Vector3.new(.07,.035,.08),Vector3.new(math.sin(i*3)*.65,.73,math.cos(i*2)*.5),green) end
  ball("LemonWedge",Vector3.new(.43,.17,.31),Vector3.new(.83,.27,-.47),Color3.fromRGB(250,220,68))
 elseif recipe.Id=="OC_LEMONADE" then
  local function cylinder(n,diam,height,y,c)
   local a=p(n,Vector3.new(height,diam,diam),Vector3.new(0,y,0),c,Enum.PartType.Cylinder)
   a.Rotation=Vector3.new(0,0,90);return a
  end
  local glass=cylinder("ClearGlass",1,1.5,.8,Color3.fromRGB(215,240,244));glass.Transparency=.72;glass.CastShadow=false
  cylinder("Lemonade",.86,1.14,.68,Color3.fromRGB(245,217,100))
  cylinder("GlassBase",.98,.08,.08,Color3.fromRGB(211,234,235)).Transparency=.35
  for i=1,5 do
   local ice=p("IceCube",Vector3.new(.23,.2,.24),Vector3.new(math.sin(i*2)*.25,1.24+(i%2)*.05,math.cos(i*2)*.24),Color3.fromRGB(231,249,249))
   ice.Transparency=.25;ice.Rotation=Vector3.new(i*8,i*37,0)
  end
  local straw=p("PaperStraw",Vector3.new(.075,1.18,.075),Vector3.new(-.24,1.63,.1),Color3.fromRGB(85,175,164));straw.Rotation=Vector3.new(0,0,10)
  ball("LemonSliceRind",Vector3.new(.07,.53,.53),Vector3.new(.45,1.32,-.12),Color3.fromRGB(245,208,45))
  ball("LemonSliceFlesh",Vector3.new(.085,.41,.41),Vector3.new(.45,1.32,-.12),Color3.fromRGB(255,240,154))
  ball("LemonSliceCenter",Vector3.new(.1,.075,.075),Vector3.new(.45,1.32,-.12),cream)
  for i=1,6 do
   local a=i*math.pi/3
   local line=p("LemonSegment",Vector3.new(.09,.025,.17),Vector3.new(.45,1.32+math.sin(a)*.105,-.12+math.cos(a)*.105),cream)
   line.Rotation=Vector3.new(-math.deg(a),0,0)
  end
  ball("MintLeaf",Vector3.new(.26,.05,.4),Vector3.new(.15,1.43,.15),green)
 elseif shape=="Sushi" then
  plate()
  for i=-1,1 do
   p("Nori",Vector3.new(.48,.43,.65),Vector3.new(i*.56,.38,0),dark)
   p("Rice",Vector3.new(.4,.12,.56),Vector3.new(i*.56,.64,0),cream)
   p("Salmon",Vector3.new(.24,.08,.34),Vector3.new(i*.56,.74,0),Color3.fromRGB(239,135,106))
  end
 elseif recipe.Id=="THAI TEA" then
  -- A round takeaway cup with visible tea, milk cap and ice instead of a solid white block.
  local function cupCylinder(n,h,d,y,c)
   local a=p(n,Vector3.new(h,d,d),Vector3.new(0,y,0),c,Enum.PartType.Cylinder)
   a.Rotation=Vector3.new(0,0,90);return a
  end
  cupCylinder("CupBase",.1,.92,.12,Color3.fromRGB(71,100,98))
  cupCylinder("Drink",1.22,.86,.78,Color3.fromRGB(194,91,26))
  cupCylinder("MilkCap",.16,.86,1.32,Color3.fromRGB(239,206,156))
  cupCylinder("CupSleeve",.35,.9,.64,Color3.fromRGB(39,103,100))
  local glass=cupCylinder("ClearCup",1.38,.94,.8,Color3.fromRGB(185,218,217));glass.Transparency=.78;glass.Material=Enum.Material.Glass
  for i=1,4 do
   local ice=p("IceCube",Vector3.new(.23,.15,.23),Vector3.new(math.sin(i*2)*.23,1.45,math.cos(i*2)*.23),Color3.fromRGB(199,228,229));ice.Transparency=.25;ice.Rotation=Vector3.new(0,i*35,0)
  end
  local lid=cupCylinder("Lid",.07,1.02,1.53,Color3.fromRGB(173,211,207));lid.Transparency=.5
  p("Straw",Vector3.new(.09,.85,.09),Vector3.new(.2,1.85,0),Color3.fromRGB(169,53,60)).Rotation=Vector3.new(0,0,-8)
 elseif shape=="Cup" or shape=="Mug" or shape=="Soda" then
  p("CupBase",Vector3.new(.92,1.45,.92),Vector3.new(0,.76,0),cream)
  p("Drink",Vector3.new(.82,1.05,.94),Vector3.new(0,.7,-.03),color)
  p("Lid",Vector3.new(1.04,.1,1.04),Vector3.new(0,1.52,0),cream)
  if shape=="Mug" then p("Handle",Vector3.new(.3,.7,.24),Vector3.new(.63,.9,0),cream)
  else p("Straw",Vector3.new(.09,.8,.09),Vector3.new(.25,1.9,0),shape=="Soda" and red or green) end
  if shape=="Soda" then ball("Cream",Vector3.new(.75,.45,.75),Vector3.new(0,1.7,0),cream) end
 elseif recipe.Id=="RD_BURGER" then
  ball("DinnerPlate",Vector3.new(2.35,.14,2.1),Vector3.new(0,.12,0),cream)
  ball("BottomBun",Vector3.new(1.72,.3,1.6),Vector3.new(0,.34,0),Color3.fromRGB(195,119,48))
  ball("ToastedBread",Vector3.new(1.64,.12,1.53),Vector3.new(0,.49,0),Color3.fromRGB(239,178,91))
  for i=1,9 do
   local a=i*math.pi*2/9
   local leaf=ball("LettuceFrill",Vector3.new(.54,.13,.42),Vector3.new(math.cos(a)*.61,.58,math.sin(a)*.58),green)
   leaf.Rotation=Vector3.new(0,-math.deg(a),i%2*9)
  end
  ball("GrilledPatty",Vector3.new(1.65,.26,1.51),Vector3.new(0,.73,0),Color3.fromRGB(91,51,30))
  for i=1,7 do
   local a=i*math.pi*2/7
   ball("PattyTexture",Vector3.new(.2,.12,.18),Vector3.new(math.cos(a)*.74,.76,math.sin(a)*.68),Color3.fromRGB(118,68,37))
  end
  local cheese=p("CheddarSlice",Vector3.new(1.43,.055,1.43),Vector3.new(0,.9,0),Color3.fromRGB(255,187,43));cheese.Rotation=Vector3.new(0,22,0)
  for _,x in {-.38,.38} do ball("TomatoSlice",Vector3.new(.83,.1,.76),Vector3.new(x,.99,0),Color3.fromRGB(211,63,42)) end
  ball("TopBun",Vector3.new(1.78,.72,1.65),Vector3.new(0,1.34,0),Color3.fromRGB(219,147,66))
  for i=1,20 do
   local a=i*2.399963;local r=math.sqrt(i/22)*.72
   local x=math.cos(a)*r;local z=math.sin(a)*r*.92
   local y=1.34+.36*math.sqrt(1-(r/.89)^2)
   local seed=ball("SesameSeed",Vector3.new(.055,.025,.12),Vector3.new(x,y,z),Color3.fromRGB(255,236,183))
   seed.Rotation=Vector3.new(0,i*39,0)
  end
 elseif recipe.Id=="RD_HOT_DOG" then
  ball("OvalPlate",Vector3.new(2.2,.14,2.7),Vector3.new(0,.12,0),cream)
  ball("BreadBase",Vector3.new(1.35,.28,2.15),Vector3.new(0,.31,0),Color3.fromRGB(198,121,49))
  for _,x in {-.42,.42} do
   ball("GoldenBunSide",Vector3.new(.69,.65,2.18),Vector3.new(x,.57,0),Color3.fromRGB(227,162,78))
   ball("SoftBreadInside",Vector3.new(.26,.42,1.96),Vector3.new(x*.6,.65,0),Color3.fromRGB(249,218,158))
  end
  ball("GrilledSausage",Vector3.new(.5,.5,2.28),Vector3.new(0,.72,0),Color3.fromRGB(174,67,38))
  for _,z in {-1.03,1.03} do ball("SausageEnd",Vector3.new(.28,.29,.19),Vector3.new(0,.73,z),Color3.fromRGB(147,50,30)) end
  for i=1,20 do
   local z=-.88+(i-1)*1.76/20;local nextZ=z+1.76/20
   local x=math.sin(i*.8)*.14;local nextX=math.sin((i+1)*.8)*.14
   local a=Vector3.new(x,.975,z);local b=Vector3.new(nextX,.975,nextZ)
   local sauce=p("MustardZigzag",Vector3.new(.065,.045,(b-a).Magnitude+.02),(a+b)/2,Color3.fromRGB(255,206,42));sauce.CFrame=CFrame.lookAt((a+b)/2,b)
  end
  for i=1,10 do
   ball("Relish",Vector3.new(.065,.035,.07),Vector3.new(.12,.97,-.7+i*.13),Color3.fromRGB(96,136,55))
  end
 elseif shape=="Burger" then
  plate();ball("BottomBun",Vector3.new(1.6,.35,1.35),Vector3.new(0,.36,0),gold)
  p("Patty",Vector3.new(1.4,.22,1.16),Vector3.new(0,.64,0),Color3.fromRGB(101,65,45))
  p("Cheese",Vector3.new(1.5,.08,1.26),Vector3.new(0,.8,0),color)
  p("Lettuce",Vector3.new(1.6,.09,1.32),Vector3.new(0,.91,0),green)
  ball("TopBun",Vector3.new(1.65,.55,1.4),Vector3.new(0,1.15,0),gold)
 elseif shape=="Croissant" then
  plate()
  for i=-2,2 do local b=ball("PastryLayer",Vector3.new(.48,.46,.7),Vector3.new(i*.32,.48,math.abs(i)*.17),gold);b.Rotation=Vector3.new(0,i*18,0) end
 elseif shape=="Sandwich" or shape=="Taco" then
  plate()
  p("Bottom",Vector3.new(1.6,.15,1.25),Vector3.new(0,.28,0),shape=="Taco" and gold or cream)
  p("Lettuce",Vector3.new(1.45,.12,1.15),Vector3.new(0,.43,0),green)
  p("Filling",Vector3.new(1.35,.15,1.05),Vector3.new(0,.59,0),shape=="Taco" and color or red)
  local top=p("Top",Vector3.new(1.6,.15,1.25),Vector3.new(0,.78,0),gold);top.Rotation=Vector3.new(0,0,shape=="Taco" and 22 or 0)
 elseif shape=="HotDog" then
  plate()
  for _,x in {-.35,.35} do ball("Bun",Vector3.new(.65,.55,1.5),Vector3.new(x,.45,0),gold) end
  ball("Sausage",Vector3.new(.42,.42,1.6),Vector3.new(0,.6,0),red)
  p("Mustard",Vector3.new(.09,.07,1.3),Vector3.new(0,.85,0),Color3.fromRGB(248,210,53))
 elseif shape=="Pizza" then
  plate();ball("Crust",Vector3.new(1.85,.2,1.45),Vector3.new(0,.28,0),gold)
  ball("Cheese",Vector3.new(1.6,.12,1.23),Vector3.new(0,.42,0),color)
  for _,v in {Vector3.new(-.4,.52,0),Vector3.new(.3,.52,-.3),Vector3.new(.3,.52,.3)} do ball("Topping",Vector3.new(.3,.08,.3),v,red) end
 elseif shape=="Dumplings" then
  plate();for i=-1,1 do ball("Dumpling",Vector3.new(.5,.5,.7),Vector3.new(i*.55,.45,0),cream);p("Pleat",Vector3.new(.06,.15,.4),Vector3.new(i*.55,.73,0),gold) end
 elseif shape=="Cookies" then
  plate();for i=-1,1 do ball("GingerbreadBody",Vector3.new(.4,.5,.15),Vector3.new(i*.55,.4,0),gold);ball("GingerbreadHead",Vector3.new(.3,.3,.15),Vector3.new(i*.55,.75,0),gold) end
 elseif shape=="Roast" or shape=="Chicken" then
  plate();ball("Roast",Vector3.new(1.4,.65,1),Vector3.new(0,.55,0),Color3.fromRGB(166,100,53))
  for _,x in {-.65,.65} do ball("Drumstick",Vector3.new(.5,.3,.7),Vector3.new(x,.45,.5),gold) end
 end
 m:SetAttribute("RecipeId",recipe.Id);m.Parent=parent;return m
end
function F.BuildKit(slot,parent,name)
 local m=Instance.new("Model");m.Name=name or "KIT_"..slot
 local colors={Color3.fromRGB(235,184,82),Color3.fromRGB(224,135,81),Color3.fromRGB(87,184,157)}
 local function p(n,size,pos,color)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.Position=pos;a.Color=color;a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.Parent=m;return a
 end
 local root=p("Root",Vector3.new(.02,.02,.02),Vector3.zero,colors[slot]);root.Transparency=1;m.PrimaryPart=root
 local box=p("IngredientKit",Vector3.new(1.8,1.1,1.4),Vector3.new(0,.6,0),Color3.fromRGB(147,109,71))
 p("KitLid",Vector3.new(1.92,.14,1.52),Vector3.new(0,1.22,0),colors[slot])
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(360,150);g.LightInfluence=0;g.Parent=box
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundColor3=colors[slot];l.TextColor3=Color3.fromRGB(25,38,41);l.Text=({"PREP KITS","KITCHEN KITS","DRINK KITS"})[slot];l.Font=Enum.Font.GothamBold;l.TextScaled=true;l.Parent=g
 m:SetAttribute("KitSlot",slot);m.Parent=parent;return m
end
function F.RegisterAll(parent)
 for slot=1,3 do if not parent:FindFirstChild("KIT_"..slot) then F.BuildKit(slot,parent) end end
 for i,recipe in Recipes.All do
  local previous=parent:FindFirstChild(recipe.Id)
  if previous then previous:Destroy() end
  F.Build(recipe,parent)
  if i%6==0 then task.wait() end
 end
end
return F
