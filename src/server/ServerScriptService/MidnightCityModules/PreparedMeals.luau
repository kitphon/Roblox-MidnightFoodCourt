local RS=game:GetService("ReplicatedStorage")
local Meals={}
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local stations={};for _,recipe in Recipes.All do stations[recipe.Id]=recipe.Station end
function Meals.Update(shop)
 local food=shop.Phase=="Playing" and shop.Prepared or ""
 local old=shop.Model:FindFirstChild("ReadyMeal")
 if old and old:GetAttribute("Food")~=food then old:Destroy();old=nil end
 local station=stations[food] and shop.Model:FindFirstChild(stations[food])
 if station and not old then
  local template=RS.MidnightIcons:FindFirstChild(food)
  if template then
   local meal=template:Clone();meal.Name="ReadyMeal";meal:SetAttribute("Food",food);meal:ScaleTo(.6)
   for _,p in meal:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false end end
   meal:PivotTo(CFrame.new(station.Position+Vector3.new(0,station.Size.Y/2+1,-.65)))
   meal.Parent=shop.Model
  end
 end
 local group=shop.Model:FindFirstChild("ShopStyle")
 if group then for _,model in group:GetChildren() do
  local id=model.Name:match("^StationDish_(.+)$")
  if id then for _,part in model:GetDescendants() do if part:IsA("BasePart") then
   if part:GetAttribute("DishBaseTransparency")==nil then part:SetAttribute("DishBaseTransparency",part.Transparency) end
   part.Transparency=(food~="" and Recipes.Slot(id)==Recipes.Slot(food)) and 1 or part:GetAttribute("DishBaseTransparency")
  end end end
 end end
 for slot,name in ipairs(Recipes.Stations) do local p=shop.Model:FindFirstChild(name);local prompt=p and p:FindFirstChild("Cook")
  if prompt then prompt.ActionText=Recipes.Slot(food)==slot and "Pick up meal" or "Cook" end
 end
end
return Meals
