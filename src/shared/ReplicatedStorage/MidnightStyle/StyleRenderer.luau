local Catalog=require(script.Parent.StyleCatalog)
local Recipes=require(script.Parent.RecipeCatalog)
local FoodFactory=require(script.Parent.FoodFactory)
local R={}
local function col(rgb) return Color3.fromRGB(unpack(rgb)) end
local function part(parent,name,size,pos,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
local function sign(parent,name,text,pos,size,color)
 local p=part(parent,name,Vector3.new(size.X,size.Y,.12),pos,Color3.fromRGB(19,29,38))
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=40;gui.Parent=p
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundTransparency=1;l.Text=text;l.TextColor3=color;l.Font=Enum.Font.GothamBold;l.TextScaled=true;l.Parent=gui
 return p
end
function R.Paint(model,item)
 if not item or item.Kind~="Theme" then return end
 local wall=col(item.Color);local accent=col(item.Accent)
 for _,p in model:GetChildren() do
  if p:IsA("BasePart") then
   if p.Name:find("Wall") or p.Name=="BackDoorHeader" or p.Name=="BackroomLeft" or p.Name=="BackroomRight" then p.Color=wall
   elseif p.Name=="CounterTop" then p.Color=accent
   elseif p.Name=="ShopFloor" or p.Name=="BackroomFloor" then p.Color=wall:Lerp(Color3.fromRGB(164,142,112),.6) end
  end
 end
end
function R.MatchSurfaces(model)
 local wall,floor=model:FindFirstChild("LeftWall"),model:FindFirstChild("ShopFloor")
 local function match(target,source)
  if target and source then
   target.Color=source.Color;target.Material=source.Material
   target.MaterialVariant=source.MaterialVariant;target.Reflectance=source.Reflectance
  end
 end
 for _,name in {"BackroomLeft","BackroomRight","BackroomWall","BackDoorHeader"} do match(model:FindFirstChild(name),wall) end
 local layout=model:FindFirstChild("BackroomLayout")
 if layout then for _,name in {"OfficeDivider","OfficeDoorSide","OfficeDoorHeader"} do match(layout:FindFirstChild(name),wall) end end
 match(model:FindFirstChild("BackroomFloor"),floor)
 local dining=model:FindFirstChild("DiningExpansion")
 if dining then match(dining:FindFirstChild("ExpandedFloor"),floor) end
end
function R.BuildMenu(model,themeId,parent)
 local skin=Catalog.Menu(themeId)
 local floor=model.ShopFloor
 local origin=floor.Position+Vector3.new(0,floor.Size.Y/2,0)
 local board=part(parent,"ThemedFoodMenu",Vector3.new(11.5,3.1,.16),origin+Vector3.new(-1,8.4,9.42),col(skin.Background))
 board:SetAttribute("ThemeId",themeId or "")
 local gui=Instance.new("SurfaceGui");gui.Name="FoodMenu";gui.LightInfluence=0;gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(960,300);gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.Parent=board
 local font=Enum.Font[skin.Font] or Enum.Font.GothamBold
 local function textLabel(p,name,value,x,y,w,h,color,size)
  local t=Instance.new("TextLabel");t.Name=name;t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.Text=value;t.TextColor3=color;t.Font=font;t.TextSize=size;t.TextScaled=true;t.Parent=p;return t
 end
 textLabel(gui,"MenuTitle",skin.Title,24,8,912,42,col(skin.Accent),30)
 local foodIds=Recipes.MenuForModel(model,themeId)
 -- Cards mirror the physical station line as seen from the dining side (F E D C B A, Station A on the right).
 -- Stations A-C share one row; once D-F unlock they take the row above so the board reads F..A left to right.
 local function cardCell(i,food)
  local s=Recipes.CookingSlot(food) or i
  return 2-((s-1)%3),(#foodIds>3 and s<=3) and 1 or 0
 end
 for i,food in foodIds do
  local column,row=cardCell(i,food)
  local card=Instance.new("Frame");card.Name=food;card.Position=UDim2.fromOffset(20+column*314,54+row*120);card.Size=UDim2.fromOffset(292,114);card.BackgroundColor3=col(skin.Background):Lerp(col(skin.Text),.08);card.BorderSizePixel=0;card.Parent=gui
  local corners=Instance.new("UICorner");corners.CornerRadius=UDim.new(0,skin.Radius);corners.Parent=card
  -- Display the actual dish geometry in a recessed menu display, rather than a separate drawing.
  local recipe=Recipes.Get(food)
  local miniature=FoodFactory.Build(recipe,board,"MenuDish_"..food)
  miniature:PivotTo(CFrame.Angles(0,math.pi,0)*CFrame.lookAt(Vector3.new(1,.7,-1),Vector3.zero).Rotation:Inverse())
  local bounds,size=miniature:GetBoundingBox()
  miniature:ScaleTo(math.min(.65/size.X,.48/size.Y,.45/size.Z))
  bounds,size=miniature:GetBoundingBox()
  local pixelX=20+column*314+146
  local pixelY=54+row*120+35
  local center=board.CFrame:PointToWorldSpace(Vector3.new((.5-pixelX/960)*board.Size.X,(.5-pixelY/300)*board.Size.Y,-board.Size.Z/2-size.Z/2-.025))
  miniature:PivotTo(CFrame.new(center-bounds.Position)*miniature:GetPivot())
  miniature:SetAttribute("DisplayRecipe",food)
  local lamp=part(board,"MenuDisplayLight_"..i,Vector3.new(.05,.05,.05),center+Vector3.new(0,.35,-1.1),Color3.new(1,1,1));lamp.Transparency=1
  local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,241,222);light.Brightness=2;light.Range=2.3;light.Shadows=false;light.Parent=lamp
  textLabel(card,"DishName",Recipes.Get(food).Name,10,64,272,26,col(skin.Text),25)
  textLabel(card,"BaseDish","MADE TO ORDER",10,91,272,16,col(skin.Accent),16)
 end
 return board
end
function R.Build(model,themeId,slots,parent,name)
 local folder=Instance.new("Folder");folder.Name=name or "ShopStyle";folder.Parent=parent or model
 local floor=model.ShopFloor
 local origin=floor.Position+Vector3.new(0,floor.Size.Y/2,0)
 local function at(x,y,z) return origin+Vector3.new(x,y,z) end
 local item=Catalog.Find(themeId)
 do -- Every theme, including the empty/default and legacy color themes, uses canonical dishes.
  local shownSlots={}
  for _,id in Recipes.MenuForModel(model,themeId) do
   local recipe=Recipes.Get(id);local station=model:FindFirstChild(recipe.Station)
   if station and not shownSlots[recipe.CookingSlot] then
    shownSlots[recipe.CookingSlot]=true
    local dish=FoodFactory.Build(recipe,folder,"StationDish_"..id)
    local _,size=dish:GetBoundingBox()
    -- Plating spot on the front-left; the right side and back hold the station's cooking gear (ShopService StationGear).
    dish:ScaleTo(math.min(dish:GetScale(),1.85/size.X,1.7/size.Z))
    dish:PivotTo(station.CFrame*CFrame.new(-.9,station.Size.Y/2+.12,-.55))
   end
  end
 end
 if item and item.Kind=="Theme" then
  local accent=col(item.Accent);local wood=Color3.fromRGB(93,67,52)
  -- The themed food menu occupies the upper back-wall sign area.
  for _,x in {-13,13} do
   part(folder,"CounterTrim",Vector3.new(.18,3,.18),at(x,2.8,-8.8),accent,Enum.Material.Neon)
  end
  for i=-2,2 do
   local x=i*5
   if themeId=="japan_night" then
    local l=part(folder,"PaperLantern",Vector3.new(1.15,1.5,1.15),at(x,8,-6.5),accent);l.Shape=Enum.PartType.Ball
    part(folder,"LanternCap",Vector3.new(.55,.15,.55),at(x,8.7,-6.5),wood)
    if math.abs(i)==2 then part(folder,"WoodBeam",Vector3.new(.22,2.5,.22),at(x,6.9,9.2),wood) end
   elseif themeId=="neon_bangkok" then
    part(folder,"NeonBar",Vector3.new(3,.16,.16),at(x,8,-6.5),i%2==0 and accent or Color3.fromRGB(232,105,255),Enum.Material.Neon)
    if math.abs(i)==2 then part(folder,"NeonWallTrim",Vector3.new(.12,2,.12),at(x,6.8,9.2),accent,Enum.Material.Neon) end
   elseif themeId=="cozy_cafe" then
    part(folder,"PendantCord",Vector3.new(.08,1.6,.08),at(x,8.7,-6),wood)
    local lamp=part(folder,"Pendant",Vector3.new(1.4,.45,1.4),at(x,7.7,-6),accent);lamp.Shape=Enum.PartType.Cylinder
    part(folder,"CafeShelf",Vector3.new(3.7,.18,.8),at(x,6.7,9.1),wood)
   elseif themeId=="halloween" then
    local pumpkin=part(folder,"Pumpkin",Vector3.new(1.2,1,1.2),at(x,5.9,9.1),accent);pumpkin.Shape=Enum.PartType.Ball
    part(folder,"PumpkinStem",Vector3.new(.2,.35,.2),at(x,6.5,9.1),wood)
    sign(folder,"SpookyFace",":)",at(x,5.9,8.45),Vector2.new(.7,.4),Color3.fromRGB(255,223,117))
   elseif themeId=="christmas" then
    for j=0,2 do local ball=part(folder,"FestiveLight",Vector3.new(.25,.25,.25),at(x+j,8.1,-6.5),j%2==0 and accent or Color3.fromRGB(113,240,148),Enum.Material.Neon);ball.Shape=Enum.PartType.Ball end
   elseif themeId=="retro_diner" then
    part(folder,"DinerStripe",Vector3.new(3,.3,.15),at(x,5,9.2),accent)
    for j=0,2 do part(folder,"CheckerTile",Vector3.new(.65,.65,.1),at(x+j*.68-1,5.8,9.2),j%2==0 and Color3.fromRGB(245,237,216) or Color3.fromRGB(38,39,44)) end
   elseif themeId=="ocean_breeze" then
    if math.abs(i)==2 then
    local ring=part(folder,"Porthole",Vector3.new(1.15,1.15,.12),at(x,8,9.2),accent,Enum.Material.Metal);ring.Shape=Enum.PartType.Ball
    local window=part(folder,"PortholeGlass",Vector3.new(.75,.75,.13),at(x,8,9.1),Color3.fromRGB(23,80,120));window.Shape=Enum.PartType.Ball
    end
   elseif themeId=="bamboo_garden" then
    if math.abs(i)==2 then
    part(folder,"BambooStem",Vector3.new(.22,2,.22),at(x,7.8,9.2),accent,Enum.Material.Wood)
    local leaf=part(folder,"BambooLeaves",Vector3.new(1.5,.4,.35),at(x+.4,8.3,9.1),Color3.fromRGB(101,163,83));leaf.Rotation=Vector3.new(0,0,25)
    end
   elseif themeId=="space_bistro" then
    local planet=part(folder,"MiniPlanet",Vector3.new(.65,.65,.65),at(x,8,-6.5),i%2==0 and accent or Color3.fromRGB(107,197,239));planet.Shape=Enum.PartType.Ball
    local star=part(folder,"CosmicStar",Vector3.new(.12,.5,.12),at(x+1,8.2,-6.5),accent,Enum.Material.Neon);star.Rotation=Vector3.new(0,0,45)
   elseif themeId=="songkran" then
    local flag=part(folder,"FestivalFlag",Vector3.new(2.8,.9,.12),at(x,8,-6.5),i%2==0 and accent or Color3.fromRGB(249,121,167))
    flag.Rotation=Vector3.new(0,0,i*5)
   end
  end
  if themeId=="christmas" then
   for i=1,3 do local tree=part(folder,"FestivalTree",Vector3.new(3-i*.5,.8,3-i*.5),at(-19,1+i*.8,-1),Color3.fromRGB(46,131,79));tree.Shape=Enum.PartType.Ball end
   local star=part(folder,"TreeStar",Vector3.new(.5,.5,.5),at(-19,4,-1),accent,Enum.Material.Neon);star.Rotation=Vector3.new(0,0,45)
  elseif themeId=="songkran" then
   part(folder,"WaterBasin",Vector3.new(3,1,2),at(-19,.6,-1),accent)
   local water=part(folder,"FestivalWater",Vector3.new(2.7,.12,1.7),at(-19,1.15,-1),Color3.fromRGB(98,208,235));water.Transparency=.3
  end
 end
 for slot,id in pairs(slots or {}) do
  local decor=Catalog.Find(id)
  if not decor or decor.Kind~="Decoration" or decor.Slot~=slot then continue end
  local base=slot=="Entrance" and at(-19,0,-7) or slot=="Patio" and at(30,0,1) or at(8,6.8,9.1)
  local c=col(decor.Color)
  if slot=="Front" then
   local position=at(0,13.5,-11.3)
   local title=({front_mint="FRESH & HOT",front_sunset="COZY BITES",front_sakura="SAKURA KITCHEN",front_cosmic="COSMIC BITES"})[id] or "MIDNIGHT KITCHEN"
   local board=sign(folder,"FrontFeatureSign",title,position,Vector2.new(14,2.2),Color3.fromRGB(250,239,212))
   board.Color=c:Lerp(Color3.new(),.45)
   for _,x in {-7.2,7.2} do part(folder,"FrontFeaturePost",Vector3.new(.22,2.5,.22),position+Vector3.new(x,-.4,.15),c,Enum.Material.Metal) end
   for _,y in {-1.2,1.2} do part(folder,"FrontFeatureTrim",Vector3.new(14.6,.15,.2),position+Vector3.new(0,y,-.1),c,id=="front_cosmic" and Enum.Material.Neon or Enum.Material.SmoothPlastic) end
   if id=="front_sakura" then
    for _,x in {-6,6} do for i=1,5 do local a=i*math.pi*2/5
     local petal=part(folder,"SakuraPetal",Vector3.new(.85,.85,.3),position+Vector3.new(x+math.cos(a)*.55,2+math.sin(a)*.55,0),c);petal.Shape=Enum.PartType.Ball;petal.CastShadow=false
    end local center=part(folder,"BlossomCenter",Vector3.new(.45,.45,.35),position+Vector3.new(x,2,-.1),Color3.fromRGB(255,215,115));center.Shape=Enum.PartType.Ball end
   elseif id=="front_cosmic" then
    local center=position+Vector3.new(0,3,0)
    local planet=part(folder,"RoofPlanet",Vector3.new(2.3,2.3,2.3),center,c);planet.Shape=Enum.PartType.Ball
    for i=1,16 do local a=i*math.pi*2/16;local b=(i+1)*math.pi*2/16
     local from=center+Vector3.new(math.cos(a)*1.85,math.sin(a)*.4,math.sin(a)*.65)
     local to=center+Vector3.new(math.cos(b)*1.85,math.sin(b)*.4,math.sin(b)*.65)
     local ring=part(folder,"PlanetRing",Vector3.new(.12,.12,(to-from).Magnitude+.04),(from+to)/2,Color3.fromRGB(130,221,234),Enum.Material.Neon);ring.CFrame=CFrame.lookAt((from+to)/2,to);ring.CastShadow=false
    end
    for _,x in {-5,5} do local star=part(folder,"RoofStar",Vector3.new(.8,.8,.12),position+Vector3.new(x,2.1,0),Color3.fromRGB(248,213,119),Enum.Material.Neon);star.Rotation=Vector3.new(0,0,45) end
   end
  elseif id=="decor_plant" then
   for _,x in {-.9,.9} do
    part(folder,"PlantPot",Vector3.new(1,1,1),base+Vector3.new(x,.5,0),Color3.fromRGB(167,112,75))
    part(folder,"PlantStem",Vector3.new(.15,1.2,.15),base+Vector3.new(x,1.5,0),c)
    local leaf=part(folder,"PlantLeaves",Vector3.new(1.4,1,1.4),base+Vector3.new(x,2,0),c);leaf.Shape=Enum.PartType.Ball
   end
  elseif id=="decor_aquarium" then
   part(folder,"TankStand",Vector3.new(4,1.7,1.8),base+Vector3.new(0,.85,0),Color3.fromRGB(42,54,62))
   local glass=part(folder,"AquariumGlass",Vector3.new(4,2,1.8),base+Vector3.new(0,2.7,0),c,Enum.Material.Glass);glass.Transparency=.45
   for i=-1,1 do local fish=part(folder,"Fish",Vector3.new(.45,.25,.16),base+Vector3.new(i,2.7+i*.3,-.4),Color3.fromRGB(255,184,86));fish.Shape=Enum.PartType.Ball end
   part(folder,"TankLid",Vector3.new(4.2,.2,2),base+Vector3.new(0,3.8,0),Color3.fromRGB(33,48,58))
  elseif id=="decor_neon" then
   sign(folder,"PersonalSign","OPEN LATE",base,Vector2.new(5,1.4),c)
  elseif id=="decor_speaker" then
   for _,x in {-1.3,1.3} do
    part(folder,"Speaker",Vector3.new(1.3,2.4,1.1),base+Vector3.new(x,1.2,0),Color3.fromRGB(32,35,45))
    for _,y in {.65,1.65} do local cone=part(folder,"SpeakerCone",Vector3.new(.8,.8,.13),base+Vector3.new(x,y,-.6),c);cone.Shape=Enum.PartType.Ball end
   end
   part(folder,"RecordDesk",Vector3.new(1.2,1.3,1.4),base+Vector3.new(0,.65,0),c)
  end
 end
 R.BuildMenu(model,themeId,folder)
 return folder
end
return R
