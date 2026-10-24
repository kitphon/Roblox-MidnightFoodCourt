-- Recognizable food silhouettes shared by menu, HUD, stations and served meals.
local D={}
local supported={SIGNATURE_RICE=true,BG_DUMPLINGS=true,BG_TOFU=true,BG_JASMINE=true,SP_PIZZA=true,SP_BURGER=true,SP_SODA=true,CA_CROISSANT=true,CA_CLUB=true,CA_LATTE=true,JP_RAMEN=true,JP_SUSHI=true,JP_MATCHA=true,BK_PAD_THAI=true,BK_BASIL_RICE=true,BK_THAI_TEA=true}
function D.Supports(id) return supported[id]==true end
function D.Build(recipe,parent,name,baseBuild,recipes)
 local id=recipe.Id
 local cream=Color3.fromRGB(248,235,207);local gold=Color3.fromRGB(218,153,64)
 local green=Color3.fromRGB(76,139,58);local red=Color3.fromRGB(204,67,43)
 local m
 local bases={SIGNATURE_RICE="FRIED RICE",JP_RAMEN="NOODLES",BG_TOFU="FRIED RICE",BK_BASIL_RICE="FRIED RICE",SP_BURGER="RD_BURGER"}
 if bases[id] then m=baseBuild(recipes.Get(bases[id]),nil,name or id) else m=Instance.new("Model");m.Name=name or id end
 local function p(n,size,pos,color,rotation)
  local a=Instance.new("Part");a.Name=n;a.Size=size;a.CFrame=CFrame.new(pos)*(rotation or CFrame.identity);a.Color=color
  a.Anchored=true;a.CanCollide=false;a.CanTouch=false;a.CanQuery=false;a.TopSurface=Enum.SurfaceType.Smooth;a.BottomSurface=Enum.SurfaceType.Smooth;a.Parent=m;return a
 end
 local function ball(n,size,pos,color)
  local a=p(n,size,pos,color);local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=a;return a
 end
 local function cyl(n,diam,h,pos,color,rot)
  local a=p(n,Vector3.new(h,diam,diam),pos,color,rot or CFrame.Angles(0,0,math.pi/2));a.Shape=Enum.PartType.Cylinder;return a
 end
 local function line(n,a,b,width,color)
  return p(n,Vector3.new(width,width,(b-a).Magnitude+width/2),(a+b)/2,color,CFrame.lookAt(a,b).Rotation)
 end
 local function plate()
  ball("CeramicPlate",Vector3.new(2.35,.15,2),Vector3.new(0,.13,0),cream)
 end
 local function remove(names)
  for _,a in m:GetChildren() do if names[a.Name] then a:Destroy() end end
 end
 if not m.PrimaryPart then local root=p("Root",Vector3.new(.02,.02,.02),Vector3.zero,cream);root.Transparency=1;m.PrimaryPart=root end
 if id=="SIGNATURE_RICE" then
  remove({FriedEggWhite=true,FriedEggYolk=true,CucumberSlice=true,CucumberCenter=true})
  for i=1,4 do
   local x=(i-2.5)*.29
   local meat=ball("GrilledChickenSlice",Vector3.new(.24,.17,.79),Vector3.new(x,.86,0),Color3.fromRGB(178,112,54))
   meat.Rotation=Vector3.new(0,-15,0)
   for j=1,2 do line("GrillMark",Vector3.new(x-.08,.96,-.3+j*.21),Vector3.new(x+.08,.96,-.3+j*.21),.026,Color3.fromRGB(94,59,33)) end
  end
  for i=1,3 do ball("HerbGarnish",Vector3.new(.19,.04,.27),Vector3.new(-.55+i*.14,.99,.37),green) end
 elseif id=="JP_RAMEN" then
  remove({Meatball=true,EggSlice=true,EggYolk=true})
  for i=1,2 do
   ball("ChashuPork",Vector3.new(.46,.1,.39),Vector3.new(-.38+(i-1)*.38,.87,.37),Color3.fromRGB(180,109,74))
   ball("PorkFatCenter",Vector3.new(.29,.025,.23),Vector3.new(-.38+(i-1)*.38,.93,.37),Color3.fromRGB(234,184,142))
  end
  ball("RamenEggWhite",Vector3.new(.46,.1,.35),Vector3.new(-.4,.88,-.38),cream)
  ball("SoftEggYolk",Vector3.new(.24,.06,.21),Vector3.new(-.4,.95,-.38),Color3.fromRGB(249,165,29))
  p("NoriSheet",Vector3.new(.5,.55,.035),Vector3.new(.25,1,-.56),Color3.fromRGB(36,61,40),CFrame.Angles(math.rad(-15),0,math.rad(12)))
 elseif id=="BG_TOFU" or id=="BK_BASIL_RICE" then
  remove({FriedEggWhite=id=="BG_TOFU",FriedEggYolk=id=="BG_TOFU",CucumberSlice=true,CucumberCenter=true,Pea=true,CarrotDice=true})
  if id=="BG_TOFU" then
   for i=1,6 do
    local x=(i%3-1)*.42;local z=(math.floor((i-1)/3)-.5)*.48
    p("GoldenTofuCube",Vector3.new(.32,.27,.31),Vector3.new(x,.82,z),Color3.fromRGB(219,169,85))
    p("TofuSoftTop",Vector3.new(.25,.025,.24),Vector3.new(x,.97,z),cream)
   end
  else
   for i=1,16 do
    local r=math.sqrt(i/17);local a=i*2.4
    ball("MincedPork",Vector3.new(.18,.1,.14),Vector3.new(math.cos(a)*r*.6,.78,math.sin(a)*r*.48),Color3.fromRGB(139,85,49))
   end
   for i=1,5 do p("ChiliSlice",Vector3.new(.08,.04,.16),Vector3.new(math.sin(i)*.5,.86,math.cos(i)*.4),red,CFrame.Angles(0,i,0)) end
  end
  for i=1,7 do ball(id=="BG_TOFU" and "BokChoy" or "BasilLeaf",Vector3.new(.22,.045,.35),Vector3.new(math.sin(i*2)*.6,.84,math.cos(i*2)*.45),green).Rotation=Vector3.new(0,i*37,0) end
 elseif id=="SP_BURGER" then
  for _,a in m:GetChildren() do
   if a.Name=="TopBun" or a.Name=="BottomBun" then a.Color=Color3.fromRGB(71,53,88)
   elseif a.Name=="SesameSeed" then a.Color=Color3.fromRGB(210,222,255) end
  end
  p("StarPickStem",Vector3.new(.035,.5,.035),Vector3.new(0,1.9,0),cream)
  for i=1,5 do local a=i*math.pi*2/5
   line("StarPick",Vector3.new(0,2.2,0),Vector3.new(math.cos(a)*.18,2.2+math.sin(a)*.18,0),.055,Color3.fromRGB(155,207,246))
  end
 elseif id=="BG_DUMPLINGS" then
  plate()
  for i=1,4 do
   local x=(i%2-.5)*.85;local z=(math.floor((i-1)/2)-.5)*.7
   ball("DumplingBody",Vector3.new(.72,.4,.43),Vector3.new(x,.43,z),cream)
   for j=-2,2 do
    local pleat=p("FoldedPleat",Vector3.new(.055,.19,.13),Vector3.new(x+j*.11,.62-math.abs(j)*.025,z),Color3.fromRGB(230,213,175))
    pleat.Rotation=Vector3.new(0,0,j*15)
   end
  end
  ball("SoySauceDish",Vector3.new(.54,.11,.5),Vector3.new(.76,.25,.66),Color3.fromRGB(69,78,66))
  ball("SoySauce",Vector3.new(.42,.025,.38),Vector3.new(.76,.32,.66),Color3.fromRGB(71,42,25))
 elseif id=="JP_SUSHI" then
  local tray=p("SushiTray",Vector3.new(2.2,.12,1.75),Vector3.new(0,.12,0),Color3.fromRGB(55,51,48))
  for i=1,4 do
   local x=(i%2-.5)*.66;local z=(math.floor((i-1)/2)-.5)*.7
   cyl("NoriWrap",.55,.4,Vector3.new(x,.39,z),Color3.fromRGB(32,53,37))
   cyl("SushiRice",.45,.025,Vector3.new(x,.6,z),Color3.fromRGB(253,246,224))
   p("SalmonCenter",Vector3.new(.16,.035,.16),Vector3.new(x-.06,.63,z),Color3.fromRGB(239,132,97))
   p("CucumberCenter",Vector3.new(.09,.035,.14),Vector3.new(x+.1,.63,z),green)
  end
  ball("Wasabi",Vector3.new(.25,.17,.23),Vector3.new(.83,.26,.52),Color3.fromRGB(159,187,91))
  for i=1,3 do ball("PickledGinger",Vector3.new(.27,.045,.22),Vector3.new(.75,.25+i*.035,-.5+i*.04),Color3.fromRGB(243,173,153)) end
 elseif id=="CA_CROISSANT" then
  plate()
  for i=-4,4 do
   local a=i*.27
   local b=ball("LaminatedPastry",Vector3.new(.38-math.abs(i)*.035,.5-math.abs(i)*.052,.78-math.abs(i)*.075),Vector3.new(math.sin(a)*.84,.43-math.abs(i)*.017,math.cos(a)*.55-.3),i%2==0 and Color3.fromRGB(215,142,58) or Color3.fromRGB(235,172,83))
   b.Rotation=Vector3.new(0,-math.deg(a),0)
  end
  for _,x in {-.88,.88} do ball("CurledPastryTip",Vector3.new(.25,.2,.37),Vector3.new(x,.29,-.19),gold) end
 elseif id=="CA_CLUB" then
  plate()
  for _,x in {-.52,.52} do
   for level,layer in {{.26,.12,cream},{.36,.075,green},{.44,.075,red},{.53,.12,Color3.fromRGB(220,174,124)},{.64,.11,cream},{.74,.07,green},{.82,.1,Color3.fromRGB(238,211,151)},{.94,.13,gold}} do
    local a=Instance.new("WedgePart");a.Name=level==8 and "ToastedTriangle" or "SandwichLayer";a.Size=Vector3.new(layer[2],.87,1.25);a.CFrame=CFrame.new(x,layer[1],0)*CFrame.Angles(0,0,math.pi/2);a.Color=layer[3];a.Anchored=true;a.CanCollide=false;a.CanQuery=false;a.CanTouch=false;a.Parent=m
   end
   p("CocktailPick",Vector3.new(.035,.47,.035),Vector3.new(x,1.13,.17),Color3.fromRGB(167,104,58))
  end
 elseif id=="BK_PAD_THAI" then
  plate()
  ball("NoodlePile",Vector3.new(1.65,.28,1.32),Vector3.new(0,.36,0),Color3.fromRGB(179,108,44))
  for strand=1,8 do
   local x=math.sin(strand*2)*.45;local z=math.cos(strand*2)*.35
   for j=1,6 do local a=j*math.pi/3;local b=(j+1)*math.pi/3
    line("FlatRiceNoodle",Vector3.new(x+math.cos(a)*.3,.54,z+math.sin(a)*.17),Vector3.new(x+math.cos(b)*.3,.54,z+math.sin(b)*.17),.055,Color3.fromRGB(223,160,82))
   end
  end
  for i=1,3 do for j=1,5 do local a=j*.9
   ball("CookedShrimp",Vector3.new(.16,.12,.16),Vector3.new((i-2)*.43+math.cos(a)*.14,.62,.26+math.sin(a)*.14),Color3.fromRGB(246,155,115))
  end end
  for i=1,8 do
   line("BeanSprout",Vector3.new(-.72,.55,-.5+i*.09),Vector3.new(-.43,.61,-.53+i*.09),.027,cream)
   p("CrushedPeanut",Vector3.new(.065,.04,.065),Vector3.new(.56,.56,-.5+i*.11),Color3.fromRGB(222,184,119))
  end
  ball("Lime",Vector3.new(.38,.15,.32),Vector3.new(.8,.28,.5),green)
  for i=1,3 do line("GarlicChive",Vector3.new(.5,.56,-.6),Vector3.new(-.3+i*.12,.6,.25),.035,green) end
 elseif id=="SP_PIZZA" then
  plate()
  cyl("BakedCrust",1.96,.18,Vector3.new(0,.31,0),Color3.fromRGB(187,121,59))
  cyl("TomatoSauce",1.77,.045,Vector3.new(0,.42,0),Color3.fromRGB(158,57,43))
  cyl("MeltedCheese",1.68,.04,Vector3.new(0,.46,0),Color3.fromRGB(247,205,113))
  for i=1,7 do local a=i*2.4
   cyl("Pepperoni",.26,.03,Vector3.new(math.cos(a)*.56,.5,math.sin(a)*.56),red)
  end
  for i=1,6 do local a=i*math.pi/3
   line("SliceCut",Vector3.new(0,.49,0),Vector3.new(math.cos(a)*.86,.49,math.sin(a)*.86),.018,Color3.fromRGB(172,117,64))
  end
  for i=1,5 do local a=i*math.pi*2/5
   ball("PurpleOnion",Vector3.new(.17,.04,.07),Vector3.new(math.cos(a)*.39,.53,math.sin(a)*.39),Color3.fromRGB(155,99,177))
  end
 else
  -- Round cups: visible drink surfaces, ice or foam, and a real curved handle.
  local mug=id=="CA_LATTE" or id=="BG_JASMINE"
  local drink= id=="JP_MATCHA" and Color3.fromRGB(122,165,84) or id=="BK_THAI_TEA" and Color3.fromRGB(210,116,40) or id=="CA_LATTE" and Color3.fromRGB(155,102,61) or id=="BG_JASMINE" and Color3.fromRGB(190,150,58) or Color3.fromRGB(104,125,206)
  if mug then
   ball("Saucer",Vector3.new(1.65,.11,1.5),Vector3.new(0,.1,0),cream)
   cyl("CeramicCup",1.04,.92,Vector3.new(0,.61,0),cream)
   cyl("TeaOrCoffee",.89,.025,Vector3.new(0,1.08,0),drink)
   for i=1,10 do local a=-math.pi/2+(i-1)*math.pi/9
    ball("CupHandle",Vector3.new(.12,.14,.14),Vector3.new(.49+math.cos(a)*.35,.64+math.sin(a)*.31,0),cream)
   end
   if id=="CA_LATTE" then
    for i=1,5 do ball("LatteArtLeaf",Vector3.new(.14+(5-i)*.045,.012,.075),Vector3.new(0,1.102,-.21+i*.075),cream) end
    line("LatteArtStem",Vector3.new(0,1.106,-.25),Vector3.new(0,1.106,.24),.022,cream)
   else
    for i=1,5 do ball("JasminePetal",Vector3.new(.06,.015,.14),Vector3.new(math.cos(i*1.256)*.09,1.11,math.sin(i*1.256)*.09),cream).Rotation=Vector3.new(0,-i*72,0) end
   end
  else
   local glass=cyl("ClearGlass",1,1.5,Vector3.new(0,.8,0),Color3.fromRGB(214,237,239));glass.Transparency=.72;glass.CastShadow=false
   cyl("Drink",.87,1.15,Vector3.new(0,.69,0),drink)
   cyl("GlassBase",.99,.07,Vector3.new(0,.08,0),cream).Transparency=.4
   if id=="JP_MATCHA" then cyl("MilkLayer",.88,.32,Vector3.new(0,.26,0),cream)
   elseif id=="BK_THAI_TEA" then cyl("CreamLayer",.88,.17,Vector3.new(0,1.19,0),Color3.fromRGB(243,205,147)) end
   for i=1,5 do local ice=p("IceCube",Vector3.new(.24,.2,.24),Vector3.new(math.sin(i*2)*.23,1.3,math.cos(i*2)*.23),Color3.fromRGB(232,249,247),CFrame.Angles(0,i,0));ice.Transparency=.3 end
   p("PaperStraw",Vector3.new(.075,1.03,.075),Vector3.new(-.24,1.64,.12),id=="SP_SODA" and Color3.fromRGB(218,180,248) or green,CFrame.Angles(0,0,.12))
   if id=="SP_SODA" then
    for i=1,8 do ball("SodaBubble",Vector3.new(.05,.05,.05),Vector3.new(math.sin(i*2)*.3,.3+i*.12,-.34),Color3.fromRGB(207,230,253)) end
    ball("CitrusGarnish",Vector3.new(.07,.47,.47),Vector3.new(.46,1.35,0),Color3.fromRGB(238,199,75))
   end
  end
 end
 m.Name=name or id;m:SetAttribute("RecipeId",id);m.Parent=parent;return m
end
return D
