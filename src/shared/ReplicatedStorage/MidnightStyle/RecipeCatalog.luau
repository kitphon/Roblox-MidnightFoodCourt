local R={All={},ById={},Menus={},Stations={"NoodleStation","RiceStation","TeaStation","CookingStationD","CookingStationE","CookingStationF"},StockIds={"NOODLES","FRIED RICE","THAI TEA"}}
local function menu(theme,entries)
 local ids={}
 for slot,entry in ipairs(entries) do
  local item={Id=entry[1],Name=entry[2],Shape=entry[3],Color=entry[4] or {235,179,92},Slot=slot,StockId=R.StockIds[slot],Station=R.Stations[slot],Kits=1}
  R.ById[item.Id]=item;table.insert(R.All,item);table.insert(ids,item.Id)
 end
 R.Menus[theme]=ids
end
menu("default",{{"NOODLES","Noodles","Noodles"},{"FRIED RICE","Fried Rice","Rice"},{"THAI TEA","Thai Tea","Cup",{228,139,59}}})
menu("japan_night",{{"JP_RAMEN","Ramen","Noodles"},{"JP_SUSHI","Sushi","Sushi"},{"JP_MATCHA","Matcha Latte","Cup",{99,152,81}}})
menu("neon_bangkok",{{"BK_PAD_THAI","Pad Thai","Noodles",{202,133,66}},{"BK_BASIL_RICE","Basil Rice","Rice",{94,153,72}},{"BK_THAI_TEA","Iced Thai Tea","Cup",{236,144,63}}})
menu("cozy_cafe",{{"CA_CROISSANT","Croissant","Croissant"},{"CA_CLUB","Club Sandwich","Sandwich"},{"CA_LATTE","Cafe Latte","Mug",{163,107,70}}})
menu("halloween",{{"HW_SOUP","Pumpkin Soup","Soup",{240,144,45}},{"HW_BURGER","Monster Burger","Burger",{131,174,70}},{"HW_SODA","Witch Soda","Soda",{151,80,185}}})
menu("christmas",{{"XM_COOKIES","Gingerbread","Cookies"},{"XM_ROAST","Roast Dinner","Roast"},{"XM_COCOA","Hot Chocolate","Mug",{107,65,47}}})
menu("songkran",{{"SK_SOM_TAM","Som Tam","Salad",{112,170,77}},{"SK_CHICKEN","Grilled Chicken","Chicken"},{"SK_PEA_TEA","Butterfly Pea Tea","Cup",{94,94,195}}})
menu("retro_diner",{{"RD_HOT_DOG","Hot Dog","HotDog"},{"RD_BURGER","Cheeseburger","Burger"},{"RD_SHAKE","Strawberry Shake","Soda",{244,152,175}}})
menu("ocean_breeze",{{"OC_TACO","Fish Taco","Taco"},{"OC_RICE","Seafood Rice","Rice",{240,170,100}},{"OC_LEMONADE","Lemonade","Cup",{244,221,112}}})
menu("bamboo_garden",{{"BG_DUMPLINGS","Veggie Dumplings","Dumplings"},{"BG_TOFU","Tofu Rice","Rice",{190,212,142}},{"BG_JASMINE","Jasmine Tea","Mug",{210,185,105}}})
menu("space_bistro",{{"SP_PIZZA","Galaxy Pizza","Pizza",{169,122,220}},{"SP_BURGER","Meteor Burger","Burger",{149,131,211}},{"SP_SODA","Cosmic Soda","Soda",{110,164,233}}})
local special={Id="SIGNATURE_RICE",Name="Signature Chicken Rice",Shape="Rice",Color={231,177,79},Slot=2,StockId="FRIED RICE",Station="RiceStation",Kits=1}
R.ById[special.Id]=special;table.insert(R.All,special)

-- Six dishes per theme; each station keeps using its existing ingredient kit.
local additions={["default"]={{"MK_DUMPLINGS","Pork Dumplings","BG_DUMPLINGS",1},{"MK_CHICKEN_RICE","Chicken Rice","SIGNATURE_RICE",2},{"MK_LEMON_TEA","Lemon Iced Tea","OC_LEMONADE",3}},["japan_night"]={{"JP_GYOZA","Gyoza","BG_DUMPLINGS",1},{"JP_CHICKEN_RICE","Chicken Rice Bowl","SIGNATURE_RICE",2},{"JP_ICED_TEA","Iced Green Tea","JP_MATCHA",3}},["neon_bangkok"]={{"BK_DUMPLINGS","Steamed Dumplings","BG_DUMPLINGS",1},{"BK_CHICKEN_RICE","Chicken Rice","SIGNATURE_RICE",2},{"BK_LIME_SODA","Lime Soda","OC_LEMONADE",3}},["cozy_cafe"]={{"CA_COOKIES","Gingerbread Cookies","XM_COOKIES",1},{"CA_BURGER","Cafe Cheeseburger","RD_BURGER",2},{"CA_SHAKE","Strawberry Milkshake","RD_SHAKE",3}},["halloween"]={{"HW_DUMPLINGS","Ghost Dumplings","BG_DUMPLINGS",1},{"HW_PIZZA","Midnight Pizza","SP_PIZZA",2},{"HW_COCOA","Dark Hot Chocolate","XM_COCOA",3}},["christmas"]={{"XM_CROISSANT","Holiday Croissant","CA_CROISSANT",1},{"XM_CHICKEN_RICE","Festive Chicken Rice","SIGNATURE_RICE",2},{"XM_SHAKE","Strawberry Snow Shake","RD_SHAKE",3}},["songkran"]={{"SK_DUMPLINGS","Steamed Dumplings","BG_DUMPLINGS",1},{"SK_BASIL_RICE","Spicy Basil Rice","BK_BASIL_RICE",2},{"SK_LIME_SODA","Lime Soda","OC_LEMONADE",3}},["retro_diner"]={{"RD_CLUB","Club Sandwich","CA_CLUB",1},{"RD_PIZZA","Pepperoni Pizza","SP_PIZZA",2},{"RD_LEMONADE","Iced Lemonade","OC_LEMONADE",3}},["ocean_breeze"]={{"OC_DUMPLINGS","Harbor Dumplings","BG_DUMPLINGS",1},{"OC_FISH_BURGER","Fish Burger","RD_BURGER",2},{"OC_ICED_TEA","Seaside Iced Tea","BK_THAI_TEA",3}},["bamboo_garden"]={{"BG_SALAD","Papaya Salad","SK_SOM_TAM",1},{"BG_SUSHI","Garden Sushi","JP_SUSHI",2},{"BG_MATCHA","Iced Matcha","JP_MATCHA",3}},["space_bistro"]={{"SP_DUMPLINGS","Moon Dumplings","BG_DUMPLINGS",1},{"SP_CHICKEN_RICE","Orbit Chicken Rice","SIGNATURE_RICE",2},{"SP_SHAKE","Nebula Strawberry Shake","RD_SHAKE",3}}}
for theme,entries in pairs(additions) do
 for index,entry in ipairs(entries) do
  local base=assert(R.ById[entry[3]])
  local recipe=table.clone(base);recipe.Id=entry[1];recipe.Name=entry[2];recipe.BaseId=entry[3]
  recipe.Slot=entry[4];recipe.StockId=R.StockIds[recipe.Slot];recipe.Station=R.Stations[recipe.Slot]
  recipe.UnlockLevel=index+1
  R.ById[recipe.Id]=recipe;table.insert(R.All,recipe);table.insert(R.Menus[theme],recipe.Id)
 end
end
for _,recipe in R.All do recipe.UnlockLevel=recipe.UnlockLevel or 1 end
-- Ingredient Slot stays A/B/C for compatible stock; CookingSlot is the fixed six-bay menu position.
for _,ids in R.Menus do for index,id in ids do local recipe=R.ById[id];recipe.CookingSlot=index;recipe.Station=R.Stations[index] end end
special.CookingSlot=2
function R.CookingSlot(id) local recipe=R.Get(id);return recipe and recipe.CookingSlot end
function R.FullMenuForModel(model,theme)
 local ids=table.clone(R.Theme(theme))
 if model:GetAttribute("SignatureMenu") then ids[2]="SIGNATURE_RICE" end
 return ids
end
function R.Unlocked(theme,level)
 local out={};for _,id in R.Theme(theme) do if R.Get(id).UnlockLevel<=(level or 1) then table.insert(out,id) end end;return out
end

function R.MenuForModel(model,theme)
 local ids=R.Unlocked(theme,model:GetAttribute("MenuLevel") or 1)
 if model:GetAttribute("SignatureMenu") then ids[2]="SIGNATURE_RICE" end
 return ids
end
function R.Get(id) return R.ById[id] end
function R.Theme(id) return R.Menus[id] or R.Menus.default end
function R.StockId(id) local recipe=R.Get(id);return recipe and recipe.StockId or id end
function R.Slot(id) local recipe=R.Get(id);return recipe and recipe.Slot end
function R.Station(id) local recipe=R.Get(id);return recipe and recipe.Station end
return R
