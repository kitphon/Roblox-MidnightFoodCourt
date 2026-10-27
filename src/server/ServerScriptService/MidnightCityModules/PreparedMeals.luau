local RS=game:GetService("ReplicatedStorage")
local Meals={}
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
function Meals.Update(shop)
 local food=shop.Phase=="Playing" and shop.Prepared or ""
 local old=shop.Model:FindFirstChild("ReadyMeal")
 if old and old:GetAttribute("Food")~=food then old:Destroy();old=nil end
 local station=shop.Model:FindFirstChild(Recipes.Station(food) or "")
 if station and not old then
  local template=RS.MidnightIcons:FindFirstChild(food)
  if template then
   local meal=template:Clone();meal.Name="ReadyMeal";meal:SetAttribute("Food",food);meal:ScaleTo(.6)
   for _,p in meal:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false end end
   meal:PivotTo(CFrame.new(station.Position+Vector3.new(0,station.Size.Y/2+1,-.65)));meal.Parent=shop.Model
  end
 end
 local obsolete=shop.Model:FindFirstChild("StationOrderDisplays");if obsolete then obsolete:Destroy() end
 local theme=shop.Model:GetAttribute("AppliedStyleTheme") or ""
 local full=Recipes.FullMenuForModel(shop.Model,theme)
 local available=Recipes.MenuForModel(shop.Model,theme)
 for slot,name in Recipes.Stations do
  local p=shop.Model:FindFirstChild(name);local prompt=p and p:FindFirstChild("Cook")
  local id=full[slot];local recipe=id and Recipes.Get(id)
  local unlocked=id~=nil and table.find(available,id)~=nil
  if p then
   p:SetAttribute("SelectedRecipe",id or "");p:SetAttribute("Unlocked",unlocked)
   if not p:GetAttribute("StationBaseColor") then p:SetAttribute("StationBaseColor",p.Color) end
   p.Color=unlocked and p:GetAttribute("StationBaseColor") or Color3.fromRGB(53,61,66)
  end
  if prompt then
   prompt.Enabled=unlocked
   prompt.ActionText=food==id and "Pick up meal" or "Cook"
   prompt.ObjectText=string.char(64+slot).." / "..(unlocked and recipe.Name or "Locked • Lv. "..(recipe and recipe.UnlockLevel or 1))
  end
 end
 local group=shop.Model:FindFirstChild("ShopStyle")
 if group then for _,model in group:GetChildren() do
  local id=model.Name:match("^StationDish_(.+)$")
  if id then for _,p in model:GetDescendants() do if p:IsA("BasePart") then
   if p:GetAttribute("DishBaseTransparency")==nil then p:SetAttribute("DishBaseTransparency",p.Transparency) end
   p.Transparency=id==food and 1 or p:GetAttribute("DishBaseTransparency")
  end end end
 end end
end
return Meals
