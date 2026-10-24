local Recipes=require(game.ReplicatedStorage.MidnightStyle.RecipeCatalog)
local B={}
function B.Clear(shop) shop.Bundle=nil end
function B.Begin(shop,food,available,enabled)
 B.Clear(shop)
 if not enabled or Recipes.Slot(food)==3 then return end
 local drinks={};for _,id in available do if Recipes.Slot(id)==3 then table.insert(drinks,id) end end
 if #drinks==0 then return end
 shop.Bundle={Items={food,drinks[math.random(1,#drinks)]},Done={},Count=0,Score=0,Quality=4}
end
function B.Pending(shop)
 local out={};local b=shop.Bundle
 if b then for _,id in b.Items do if not b.Done[id] then table.insert(out,id) end end
 elseif shop.Order~="" then table.insert(out,shop.Order) end
 return out
end
function B.StationFood(shop,slot,fallback)
 for _,id in B.Pending(shop) do if Recipes.Slot(id)==slot then return id end end
 return fallback
end
function B.Accept(shop,dish,quality,score)
 local b=shop.Bundle
 if not b then return dish==shop.Order,true,quality,score end
 if not table.find(b.Items,dish) or b.Done[dish] then return false,false end
 b.Done[dish]=true;b.Count+=1;b.Score+=(score or 50)
 b.Quality=math.min(b.Quality,({Poor=1,Fair=2,Good=3,Normal=3,Perfect=4})[quality or "Normal"] or 3)
 local pending=B.Pending(shop)
 shop.Order=pending[1] or dish
 return true,#pending==0,({"Poor","Fair","Good","Perfect"})[b.Quality],math.floor(b.Score/b.Count)
end
return B
