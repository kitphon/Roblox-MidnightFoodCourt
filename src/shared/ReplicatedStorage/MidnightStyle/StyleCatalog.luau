local Catalog={}
Catalog.Items={
 {Id="retro_diner",Name="Retro Diner",Kind="Theme",Gems=145,Color={108,39,48},Accent={250,218,164},Description="Cherry-red trim, checker tiles and a classic diner menu."},
 {Id="ocean_breeze",Name="Ocean Breeze",Kind="Theme",Gems=145,Color={25,79,99},Accent={103,224,233},Description="Ocean colors, portholes and a seaside menu."},
 {Id="bamboo_garden",Name="Bamboo Garden",Kind="Theme",Gems=135,Color={40,73,47},Accent={191,218,133},Description="Bamboo accents, leafy details and a garden menu."},
 {Id="space_bistro",Name="Space Bistro",Kind="Theme",Gems=165,Color={27,27,64},Accent={181,158,255},Description="Planet decorations, star lights and a cosmic menu."},

 {Id="japan_night",Name="Japanese Night",Kind="Theme",Gems=140,Color={72,48,54},Accent={255,164,101},Description="Wood trim, paper lanterns and a ramen sign."},
 {Id="neon_bangkok",Name="Neon Bangkok",Kind="Theme",Gems=160,Color={39,31,74},Accent={91,240,220},Description="Electric signs, bright strips and a city-night counter."},
 {Id="cozy_cafe",Name="Cozy Cafe",Kind="Theme",Gems=120,Color={97,77,61},Accent={244,211,155},Description="Warm wood, pendant lights and cafe shelves."},
 {Id="halloween",Name="Haunted Kitchen",Kind="Theme",Gems=150,Color={49,36,63},Accent={255,151,55},Description="Pumpkins and purple lights. Available all year.",Season="Halloween"},
 {Id="christmas",Name="Winter Cafe",Kind="Theme",Gems=150,Color={36,72,58},Accent={242,91,95},Description="Festive lights and a Christmas tree.",Season="Christmas"},
 {Id="songkran",Name="Songkran Splash",Kind="Theme",Gems=150,Color={33,102,123},Accent={244,207,72},Description="Colorful flags and a water-festival display.",Season="Songkran"},
 {Id="staff_sushi",Name="Sushi Team",Kind="StaffStyle",Gems=65,Color={36,50,73},Accent={239,235,217},Description="Indigo uniforms, headbands and matching aprons."},
 {Id="staff_barista",Name="Cafe Team",Kind="StaffStyle",Gems=65,Color={113,77,53},Accent={233,211,173},Description="Warm cafe aprons for all three employee roles."},
 {Id="staff_cyber",Name="Cyber Team",Kind="StaffStyle",Gems=85,Color={35,34,62},Accent={89,237,226},Description="Dark uniforms with luminous mint details."},
 {Id="serve_stars",Name="Star Service",Kind="ShopEffect",Gems=45,Color={255,211,100},Description="Stars and a bright chime on successful service."},
 {Id="serve_hearts",Name="Heart Service",Kind="ShopEffect",Gems=45,Color={255,125,156},Description="Floating hearts when an order is served."},
 {Id="serve_gold",Name="Golden Service",Kind="ShopEffect",Gems=65,Color={255,193,69},Description="Golden sparkles and a signature bell sound."},
 {Id="decor_aquarium",Name="Aquarium",Kind="Decoration",Gems=70,Slot="Patio",Color={70,178,209},Description="A lit fish tank beside your shop."},
 {Id="decor_plant",Name="Plant Corner",Kind="Decoration",Coins=350,Slot="Entrance",Color={102,170,103},Description="Standard decor · Buy with Coins. Potted plants beside the entrance."},
 {Id="front_mint",Name="Mint Market Sign",Kind="Decoration",Coins=600,Slot="Front",Color={87,178,153},Description="Standard storefront · A mint rooftop sign. Buy once with Coins, equip anytime."},
 {Id="front_sunset",Name="Sunset Kitchen Sign",Kind="Decoration",Coins=600,Slot="Front",Color={210,109,70},Description="Standard storefront · A warm terracotta rooftop sign. Buy with Coins."},
 {Id="front_sakura",Name="Sakura Rooftop",Kind="Decoration",Gems=75,Slot="Front",Color={236,142,184},Description="Special storefront · Blossom clusters and a pink rooftop sign. Gems only."},
 {Id="front_cosmic",Name="Cosmic Rooftop",Kind="Decoration",Gems=85,Slot="Front",Color={149,132,227},Description="Special storefront · A ringed planet and star accents. Gems only."},
 {Id="decor_neon",Name="Open Late Sign",Kind="Decoration",Gems=40,Slot="Wall",Color={105,234,201},Description="A neon wall sign with your shop name."},
 {Id="decor_speaker",Name="Music Corner",Kind="Decoration",Gems=45,Slot="Patio",Color={146,113,194},Description="Decorative speakers and a record player."},
 {Id="team_sakura",Name="Sakura Crew",Kind="TeamStyle",Gems=75,Color={172,97,125},Accent={255,218,227},Description="Matching player aprons and crew badges."},
 {Id="team_midnight",Name="Midnight Crew",Kind="TeamStyle",Gems=75,Color={39,72,98},Accent={110,233,208},Description="Navy player aprons with mint crew badges."}
}
-- Fill in PassId after creating passes in the published experience.
Catalog.Packs={
 {Id="retro_collection",Name="Retro Diner Pack",PassId=0,SuggestedRobux=179,Items={"retro_diner","staff_barista","serve_gold","decor_speaker"},Description="Retro Diner + Cafe Team + Golden Service + Music Corner."},
 {Id="ocean_collection",Name="Ocean Breeze Pack",PassId=0,SuggestedRobux=179,Items={"ocean_breeze","staff_sushi","serve_hearts","decor_aquarium"},Description="Ocean Breeze + Sushi Team + Heart Service + Aquarium."},
 {Id="garden_collection",Name="Bamboo Garden Pack",PassId=0,SuggestedRobux=169,Items={"bamboo_garden","staff_barista","serve_stars","decor_plant"},Description="Bamboo Garden + Cafe Team + Star Service + Plant Corner."},
 {Id="space_collection",Name="Space Bistro Pack",PassId=0,SuggestedRobux=199,Items={"space_bistro","staff_cyber","serve_stars","decor_neon"},Description="Space Bistro + Cyber Team + Star Service + neon sign."},

 {Id="starter_style",Name="Starter Style Pack",PassId=0,SuggestedRobux=69,Items={"cozy_cafe","staff_barista","decor_plant"},Description="Cozy Cafe + Cafe Team + Plant Corner."},
 {Id="signature_japan",Name="Japanese Night Pack",PassId=0,SuggestedRobux=199,Items={"japan_night","staff_sushi","serve_stars","decor_neon"},Description="Japanese Night + Sushi Team + Star Service + neon sign."},
 {Id="signature_neon",Name="Neon Bangkok Pack",PassId=0,SuggestedRobux=199,Items={"neon_bangkok","staff_cyber","serve_gold","decor_speaker"},Description="Neon Bangkok + Cyber Team + Golden Service + Music Corner."},
 {Id="outfit_collection",Name="Staff Outfit Collection",PassId=0,SuggestedRobux=79,Items={"staff_sushi","staff_barista","staff_cyber"},Description="All three employee outfit sets."},
 {Id="crew_collection",Name="Crew Collection",PassId=0,SuggestedRobux=129,Items={"team_sakura","team_midnight","serve_hearts"},Description="Two player crew sets + Heart Service."},
 {Id="festival_collection",Name="Festival Collection",PassId=0,SuggestedRobux=249,Items={"halloween","christmas","songkran","serve_stars"},Description="Three festival themes + Star Service. No expiry."}
}
local Config=require(script.Parent.MonetizationConfig)
for _,pack in Catalog.Packs do pack.PassId=Config.Passes[pack.Id] or 0 end
Catalog.MenuStyles={
 default={Title="MIDNIGHT MENU",Background={17,31,38},Text={235,239,230},Accent={111,231,193},Font="GothamBold",Radius=12,Labels={"Noodles","Fried Rice","Thai Tea"}},
 japan_night={Title="MIDNIGHT RAMEN",Background={47,29,31},Text={255,236,196},Accent={255,164,101},Font="Antique",Radius=3,Labels={"Tokyo Noodles","House Fried Rice","Tokyo Thai Tea"}},
 neon_bangkok={Title="NEON BITES",Background={20,18,43},Text={212,255,249},Accent={91,240,220},Font="SciFi",Radius=6,Labels={"Neon Noodles","Bangkok Rice","Neon Thai Tea"}},
 cozy_cafe={Title="COZY CAFE MENU",Background={69,50,41},Text={255,242,213},Accent={244,211,155},Font="GothamMedium",Radius=16,Labels={"Cafe Noodles","Comfort Rice","Cafe Thai Tea"}},
 halloween={Title="BOO BITES",Background={40,27,49},Text={255,237,204},Accent={255,158,64},Font="Cartoon",Radius=14,Labels={"Midnight Noodles","Pumpkin-Night Rice","Haunted Thai Tea"}},
 christmas={Title="WINTER FAVORITES",Background={29,57,45},Text={255,245,220},Accent={246,146,147},Font="GothamBold",Radius=12,Labels={"Winter Noodles","Holiday Fried Rice","Festive Thai Tea"}},
 songkran={Title="SPLASH MENU",Background={20,68,83},Text={255,249,218},Accent={244,207,72},Font="Cartoon",Radius=18,Labels={"Splash Noodles","Festival Rice","Golden Thai Tea"}},
 retro_diner={Title="CLASSIC DINER MENU",Background={242,226,198},Text={84,35,42},Accent={174,47,64},Font="Cartoon",Radius=6,Labels={"Diner Noodles","Classic Fried Rice","Diner Thai Tea"}},
 ocean_breeze={Title="SEASIDE FAVORITES",Background={15,63,82},Text={229,252,250},Accent={104,224,234},Font="GothamBold",Radius=18,Labels={"Coastal Noodles","Island Fried Rice","Sunset Thai Tea"}},
 bamboo_garden={Title="GARDEN KITCHEN",Background={32,62,42},Text={238,244,212},Accent={187,219,123},Font="Antique",Radius=4,Labels={"Garden Noodles","Wok Fried Rice","Amber Thai Tea"}},
 space_bistro={Title="COSMIC MENU",Background={18,23,53},Text={231,232,255},Accent={185,171,255},Font="SciFi",Radius=5,Labels={"Cosmic Noodles","Orbit Fried Rice","Starlight Tea"}}
}
local Recipes=require(script.Parent.RecipeCatalog)
function Catalog.Menu(themeId)
 local skin=table.clone(Catalog.MenuStyles[themeId] or Catalog.MenuStyles.default)
 skin.Labels={}
 for _,id in Recipes.Theme(themeId) do table.insert(skin.Labels,Recipes.Get(id).Name) end
 return skin
end
Catalog.Slots={"Entrance","Patio","Wall","Front"}
function Catalog.Find(id)
 for _,list in {Catalog.Items,Catalog.Packs} do for _,item in list do if item.Id==id then return item end end end
end
return Catalog
