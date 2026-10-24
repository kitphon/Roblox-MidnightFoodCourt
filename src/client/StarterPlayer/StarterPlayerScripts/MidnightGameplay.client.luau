local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local state=player:WaitForChild("MidnightState")
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local network=RS.MidnightNetwork
local gui=Instance.new("ScreenGui");gui.Name="MidnightGameplay";gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=12;gui.Parent=player.PlayerGui
local root=Instance.new("Frame");root.Size=UDim2.fromOffset(960,640);root.AnchorPoint=Vector2.new(.5,.5);root.Position=UDim2.fromScale(.5,.5);root.BackgroundTransparency=1;root.Parent=gui
local scale=Instance.new("UIScale");scale.Parent=root
local C={bg=Color3.fromRGB(19,35,42),mint=Color3.fromRGB(111,231,193),gold=Color3.fromRGB(255,199,101),white=Color3.fromRGB(237,241,230)}
local function corner(o) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,12);c.Parent=o end
local function box(name,x,y,w,h)
 local f=Instance.new("Frame");f.Name=name;f.Position=UDim2.fromOffset(x,y);f.Size=UDim2.fromOffset(w,h);f.BackgroundColor3=C.bg;f.BorderSizePixel=0;f.Parent=root;corner(f);return f
end
local function text(p,name,value,x,y,w,h,size,color)
 local t=Instance.new("TextLabel");t.Name=name;t.Text=value;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.BackgroundTransparency=1;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBold;t.TextSize=size or 15;t.TextWrapped=true;t.Parent=p;return t
end
local networkError
local busy=false
local function send(action,id)
 if busy then return end;busy=true
 task.spawn(function() local ok,r=pcall(function() return network.Command:InvokeServer(action,id) end);busy=false;if ok and r and (not r.Ok or action=="PassMeal") then networkError=r.Message elseif not ok then networkError="Could not connect. Please try again." end end)
end
local function button(p,name,value,x,y,w,h,fn)
 local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,h);b.BackgroundColor3=C.mint;b.TextColor3=C.bg;b.TextSize=13;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.Parent=p;corner(b);b.Activated:Connect(fn);return b
end
local rankCard=box("RestaurantProgress",8,58,474,32)
local hud=player.PlayerGui:WaitForChild("MidnightHUD")
local topStats=hud:FindFirstChild("TopStats",true)
while not topStats do task.wait();topStats=hud:FindFirstChild("TopStats",true) end
rankCard.Parent=topStats
rankCard.BackgroundTransparency=1
local levelText=text(rankCard,"Level","Lv. 1",4,0,49,25,18,C.gold)
local rankText=text(rankCard,"Rank","Corner Kitchen",58,0,252,19,13,C.white)
local progressText=text(rankCard,"Orders","0 / 8 orders  ›",310,0,154,19,11,C.mint)
local progressBack=Instance.new("Frame");progressBack.Name="ProgressTrack";progressBack.Position=UDim2.fromOffset(8,26);progressBack.Size=UDim2.fromOffset(458,4);progressBack.BackgroundColor3=Color3.fromRGB(54,76,80);progressBack.BorderSizePixel=0;progressBack.Parent=rankCard;corner(progressBack)
local progressFill=Instance.new("Frame");progressFill.Name="ProgressFill";progressFill.Size=UDim2.fromScale(0,1);progressFill.BackgroundColor3=C.mint;progressFill.BorderSizePixel=0;progressFill.Parent=progressBack;corner(progressFill)
local rankOpen=Instance.new("TextButton");rankOpen.Name="OpenJourney";rankOpen.Size=UDim2.fromScale(1,1);rankOpen.BackgroundTransparency=1;rankOpen.Text="";rankOpen.Parent=rankCard
rankOpen.Activated:Connect(function() local event=player.PlayerGui:FindFirstChild("OpenMidnightManagement");if event then event:Fire("Journey") end end)
local promotion=box("LevelUpNotice",300,220,360,62);promotion.Visible=false
local promotionTitle=text(promotion,"Title","LEVEL UP!",8,4,344,25,22,C.gold)
local promotionRank=text(promotion,"Rank","",8,31,344,24,15,C.white)
local promotionUntil=0
local lastShop,lastLevel,lastServed,lastNext,lastStars
local cooking=box("CookingSkill",300,348,360,78);cooking.Visible=false
local cookTitle=text(cooking,"Action","TOSS / FLIP / POUR",8,3,250,22,14,C.gold)
local track=Instance.new("Frame");track.Name="TimingTrack";track.Position=UDim2.fromOffset(12,33);track.Size=UDim2.fromOffset(220,20);track.BackgroundColor3=Color3.fromRGB(52,78,79);track.BorderSizePixel=0;track.ClipsDescendants=true;track.Parent=cooking;corner(track)
local zone=Instance.new("Frame");zone.Name="PerfectZone";zone.Size=UDim2.fromScale(.15,1);zone.BackgroundColor3=C.gold;zone.BorderSizePixel=0;zone.Parent=track
local marker=Instance.new("Frame");marker.Name="TimingMarker";marker.Size=UDim2.fromOffset(4,24);marker.BackgroundColor3=C.white;marker.BorderSizePixel=0;marker.Parent=track
local hit=button(cooking,"TimingAction","TOSS [F]",242,30,108,36,function() send("CookSkill") end)
local result=text(cooking,"Quality","Hit the gold zone!",8,56,220,18,12,C.mint)
local customer=box("CustomerType",300,115,360,28)
local customerText=text(customer,"Title","",6,2,348,26,13,C.mint)
local guide=box("FirstShiftGuide",18,475,258,112)
local guideTitle=text(guide,"Step","",9,4,240,24,16,C.gold)
local guideText=text(guide,"Instruction","",10,28,238,47,13,C.white)
button(guide,"SkipTraining","Skip",174,80,72,24,function() send("TutorialSkip") end)
local steps={
 {"1 / 5 • OPEN YOUR SHOP","Walk to the golden bell and open your shop.","StartShift"},
 {"2 / 5 • COOK AN ORDER","Follow the dish icon to its cooking station and interact.",""},
 {"3 / 5 • PERFECT TIMING","While cooking, tap the action button or press F when the marker reaches gold.",""},
 {"4 / 5 • SERVE YOUR GUEST","Carry your finished dish to the serving counter.","Serve"},
 {"5 / 5 • YOUR FIRST UPGRADE","Kitchen > Upgrades: purchase an upgrade with Shop funds.",""}
}
-- Local prompts target a specific teammate; the server validates every transfer.
local dishPrompts={}
local function removeDishPrompt(other)
 local entry=dishPrompts[other];if entry then entry.Prompt:Destroy();dishPrompts[other]=nil end
end
Players.PlayerRemoving:Connect(removeDishPrompt)
local function updateDishPrompts(enabled)
 local mine=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local shopId=player:GetAttribute("ShopId") or 0
 for _,other in Players:GetPlayers() do if other~=player then
  local part=other.Character and other.Character:FindFirstChild("HumanoidRootPart")
  local entry=dishPrompts[other]
  if entry and entry.Part~=part then removeDishPrompt(other);entry=nil end
  if part and not entry then
   local prompt=Instance.new("ProximityPrompt");prompt.Name="GiveDishPrompt"
   prompt.ActionText="Give dish";prompt.ObjectText=other.DisplayName
   prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY
   prompt.MaxActivationDistance=7;prompt.HoldDuration=.25;prompt.RequiresLineOfSight=true
   prompt.Exclusivity=Enum.ProximityPromptExclusivity.OneGlobally;prompt.Enabled=false;prompt.Parent=part
   prompt.Triggered:Connect(function(who) if who==player then send("PassMeal",tostring(other.UserId)) end end)
   entry={Prompt=prompt,Part=part};dishPrompts[other]=entry
  end
  if entry then
   local otherState=other:FindFirstChild("MidnightState")
   entry.Prompt.Enabled=enabled and mine~=nil and shopId>0 and other:GetAttribute("ShopId")==shopId
    and otherState~=nil and (otherState:GetAttribute("Held") or "")==""
    and (otherState:GetAttribute("Cooking") or "")==""
    and (mine.Position-entry.Part.Position).Magnitude<=7
  end
 end end
end
-- Touch controls use screen pixels, independent of the desktop canvas scale.
local function layoutTouch(size)
 local width=math.min(420,size.X-32)
 cooking.Parent=gui;cooking.AnchorPoint=Vector2.new(.5,1)
 cooking.Position=UDim2.new(.5,0,1,-16);cooking.Size=UDim2.fromOffset(width,96)
 cookTitle.Size=UDim2.fromOffset(width-16,22)
 track.Size=UDim2.fromOffset(width-156,20);track.Position=UDim2.fromOffset(12,36)
 hit.Position=UDim2.fromOffset(width-132,29);hit.Size=UDim2.fromOffset(120,48)
 result.Position=UDim2.fromOffset(8,73);result.Size=UDim2.fromOffset(width-16,20)

end
local ping=box("CrewSignal",270,182,420,42);ping.Visible=false
local pingText=text(ping,"Message","",6,3,408,36,14,C.gold)
local feedback=box("ActionFeedback",300,288,360,38);feedback.Visible=false
local feedbackText=text(feedback,"Message","",5,3,350,32,20,C.gold)
local feedbackUntil=0
local sale=box("SaleBreakdown",300,292,360,49);sale.Visible=false
local saleParts=text(sale,"Parts","",6,2,348,21,13,C.white)
local saleTotal=text(sale,"Total","",6,24,348,21,17,C.mint)
local saleUntil=0
local review=box("ReviewSummary",300,149,360,132);review.Visible=false
local reviewTitle=text(review,"Stars","",8,4,298,26,20,C.gold)
local reviewReason=text(review,"Reason","",10,33,340,47,12,C.white)
local reviewImpact=text(review,"Impact","",10,84,340,40,12,C.mint)
local reviewUntil=0
button(review,"DismissReview","OK",309,5,41,25,function() reviewUntil=0 end)
local rush=box("PopularityRush",300,149,360,26);rush.Visible=false
local rushText=text(rush,"Message","",5,2,350,22,12,C.gold)

local highlight=Instance.new("Highlight");highlight.Name="TrainingTarget";highlight.FillTransparency=.85;highlight.FillColor=C.mint;highlight.OutlineColor=C.mint;highlight.Enabled=false;highlight.Parent=workspace
local pingHighlight=highlight:Clone();pingHighlight.Name="CrewSignalTarget";pingHighlight.FillColor=C.gold;pingHighlight.OutlineColor=C.gold;pingHighlight.Parent=workspace
local pulse
local function sound(cue)
 local source=game.SoundService:FindFirstChild(cue=="Perfect" and "MK_Cash" or "MK_Ding")
 if source then local s=source:Clone();s.Volume=.35;s.PlaybackSpeed=cue=="Perfect" and 1.45 or 1.12;s.Parent=game.SoundService;s:Play();game.Debris:AddItem(s,3) end
end
RS.MidnightFeedback.OnClientEvent:Connect(function(cue,score)
 if cue=="Perfect" or cue=="Good" or cue=="Fair" or cue=="Poor" then
  feedbackText.Text=string.upper(cue).." • "..tostring(score or 0).."/100";feedbackUntil=workspace:GetServerTimeNow()+1.8
  feedback.BackgroundColor3=cue=="Perfect" and Color3.fromRGB(83,62,29) or C.bg;sound(cue)
 elseif cue=="SaleBreakdown" and type(score)=="table" then
  local label=score.Kind=="Reviewer" and "Reviewer" or score.Kind=="Regular" and "Regular" or score.Kind=="Party" and "Party" or "Customer"
  saleParts.Text="Food $"..score.FoodValue.." + "..label.." bonus $"..score.Bonus
  saleTotal.Text="TOTAL +$"..score.Total..(score.FriendLevel and (" • RILEY Lv."..score.FriendLevel) or "");saleUntil=workspace:GetServerTimeNow()+4
 elseif cue=="ReviewResult" and type(score)=="table" then
  reviewTitle.Text=string.rep("★",score.Stars)..string.rep("☆",5-score.Stars).."  "..score.Stars.."/5"
  reviewReason.Text=score.Reason
  reviewImpact.Text="POPULARITY "..score.Popularity.."/100"..(score.Rush and "\nRUSH HOUR! More party visits for 60s" or "\nHigher popularity improves meal earnings")
  reviewUntil=workspace:GetServerTimeNow()+12;sound("Perfect")
 elseif cue=="CrewSignal" then sound(cue) end
end)
CAS:BindActionAtPriority("KitchenTiming",function(_,phase)
 if state:GetAttribute("Cooking")~="" and state:GetAttribute("Phase")=="Playing" then
  if phase==Enum.UserInputState.Begin then send("CookSkill") end
  return Enum.ContextActionResult.Sink
 end
 return Enum.ContextActionResult.Pass
end,false,2500,Enum.KeyCode.F,Enum.KeyCode.ButtonX)
local lastMotion
Run.RenderStepped:Connect(function()
 local now=workspace:GetServerTimeNow();local size=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(size.X/960,size.Y/640)
 local sideScale=math.max(scale.Scale,.01)
 if UIS.TouchEnabled then layoutTouch(size) end
 local management=player.PlayerGui:FindFirstChild("MidnightManagement")
 local kitchenButton
 if management then
  for _,child in management:GetChildren() do
   if child:IsA("TextButton") and child.Text:find("KITCHEN",1,true) then kitchenButton=child;break end
  end
 end
 local buttonTop=kitchenButton and kitchenButton.AbsolutePosition.Y or size.Y-70
 local guideX=kitchenButton and (kitchenButton.AbsolutePosition.X-root.AbsolutePosition.X)/sideScale or (960-size.X/sideScale)/2+16/sideScale
 local guideY=(buttonTop-16-root.AbsolutePosition.Y)/sideScale-guide.Size.Y.Offset
 guide.Position=UDim2.fromOffset(guideX,guideY)
 if UIS.TouchEnabled then
  local portrait=size.X<size.Y
  local gs=guide:FindFirstChild("MobileGuideScale") or Instance.new("UIScale",guide);gs.Name="MobileGuideScale"
  if portrait then
   guide.Parent=gui;gs.Scale=.9;guide.Position=UDim2.fromOffset(16,math.max(16,size.Y-((state:GetAttribute("Cooking")~="" and state:GetAttribute("Phase")=="Playing") and 124 or 24)-(kitchenButton and kitchenButton.AbsoluteSize.Y or 46)-16-112*.9))
  else guide.Parent=root;gs.Scale=1 end
  if kitchenButton then
   local active=state:GetAttribute("Cooking")~="" and state:GetAttribute("Phase")=="Playing"
   kitchenButton.AnchorPoint=active and not portrait and Vector2.new(0,0) or Vector2.new(0,1)
   kitchenButton.Position=active and (portrait and UDim2.new(0,16,1,-124) or UDim2.fromOffset(16,16)) or UDim2.new(0,16,1,-24)
  end
 end
 local pg=player.PlayerGui;local manage=pg:FindFirstChild("MidnightManagement");local style=pg:FindFirstChild("MidnightStyleShop")
 local modal=(manage and manage:FindFirstChild("KitchenPanel") and manage.KitchenPanel.Visible) or (style and style:FindFirstChild("StylePanel") and style.StylePanel.Visible)
 local photo=pg:FindFirstChild("MidnightHUD") and not pg.MidnightHUD.Enabled
 gui.Enabled=not modal and not photo
 local id=player:GetAttribute("ShopId") or 0;local shop=id>0 and workspace.MidnightShops:FindFirstChild("Shop"..id) or nil
 rankCard.Visible=shop~=nil
 local level=state:GetAttribute("RestaurantTier") or 1
 local served=state:GetAttribute("CareerServed") or 0
 local nextAt=state:GetAttribute("NextRankAt") or 8
 local stars=state:GetAttribute("LegendStars") or 0
 if lastShop~=id then lastShop=id;lastLevel=level;lastStars=stars;lastServed=nil;promotionUntil=0 end
 if shop and lastStars and stars>lastStars then
  promotionTitle.Text="LEGEND STAR ★"..stars
  promotionRank.Text="Meals now earn +"..(stars*2).."%"
  promotionUntil=now+4;sound("Perfect")
 end
 lastStars=stars
 if shop and lastLevel and level>lastLevel then
  promotionTitle.Text="LEVEL UP!  Lv. "..level
  promotionRank.Text=state:GetAttribute("RestaurantRank") or ""
  promotionUntil=now+4
  sound("Perfect")
 end
 lastLevel=level
 levelText.Text="Lv. "..level
 rankText.Text=state:GetAttribute("RestaurantRank") or "Corner Kitchen"
 -- After Kitchen Legend the bar tracks progress to the next Legend Star (every 50 orders from 125).
 local starsMaxed=level>=5 and nextAt<=served
 progressText.Text=level<5 and (served.." / "..nextAt.." orders  •  Journey ›")
  or starsMaxed and ("★"..stars.." MAX • "..served.." orders")
  or ("★"..stars.." • "..served.." / "..nextAt.." next star")
 if served~=lastServed or nextAt~=lastNext then
  lastServed=served;lastNext=nextAt
  local fill
  if level<5 then fill=math.clamp(served/math.max(nextAt,1),0,1)
  elseif starsMaxed then fill=1
  else local from=nextAt-50;fill=math.clamp((served-from)/50,0,1) end
  Tween:Create(progressFill,TweenInfo.new(.35),{Size=UDim2.fromScale(fill,1)}):Play()
 end
 promotion.Visible=shop~=nil and now<promotionUntil and state:GetAttribute("Phase")~="Won" and state:GetAttribute("Phase")~="Lost"
 local food=state:GetAttribute("Cooking") or "";local recipe=Recipes.Get(food)
 cooking.Visible=food~="" and state:GetAttribute("Phase")=="Playing"
 if cooking.Visible then
  local duration=state:GetAttribute("CookDuration") or 4;local ending=state:GetAttribute("CookEnd") or now
  local fraction=math.clamp(1-(ending-now)/duration,0,1)
  marker.Position=UDim2.fromScale(fraction,0);zone.Position=UDim2.fromScale((state:GetAttribute("SkillTarget") or .65)-.075,0)
  local action=recipe and (recipe.Shape=="Cup" or recipe.Shape=="Mug" or recipe.Shape=="Soda") and "POUR" or recipe and recipe.Shape=="Burger" and "FLIP" or "TOSS"
  cookTitle.Text=action.." • HIT THE GOLD ZONE";hit.Text=UIS.TouchEnabled and ("TAP "..action) or (action.." [F]");hit.Active=not state:GetAttribute("SkillHit");hit.BackgroundColor3=hit.Active and C.mint or Color3.fromRGB(75,91,90)
  result.Text=state:GetAttribute("SkillHit") and (string.upper(state:GetAttribute("CookQuality") or "Poor").." • "..tostring(state:GetAttribute("CookScore") or 0).."/100") or "Closer to gold = higher score"
  -- Local wrist movement gives cooking feedback without needing uploaded animations.
  local char=player.Character;local arm=char and (char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Torso"))
  local joint=arm and (arm:FindFirstChild("RightShoulder") or arm:FindFirstChild("Right Shoulder"))
  if joint and joint:IsA("Motor6D") then joint.Transform=CFrame.Angles(-.45+math.sin(now*10)*.2,0,.2);lastMotion=joint end
 elseif lastMotion and lastMotion.Parent then lastMotion.Transform=CFrame.identity;lastMotion=nil end
 local phase=state:GetAttribute("Phase");local step=state:GetAttribute("TutorialStep") or 1
 guide.Visible=shop~=nil and step<=5 and phase~="Won" and phase~="Lost"
 if guide.Visible then guideTitle.Text=steps[step][1];guideText.Text=steps[step][2] end
 local target=guide.Visible and steps[step][3] or ""
 if step==2 and recipe==nil then target=Recipes.Station(state:GetAttribute("Order") or "") or "" end
 highlight.Adornee=shop and shop:FindFirstChild(target);highlight.Enabled=gui.Enabled and highlight.Adornee~=nil
 updateDishPrompts(gui.Enabled and shop~=nil and (state:GetAttribute("Held") or "")~="" and (state:GetAttribute("Cooking") or "")=="")
 customer.Visible=shop~=nil and phase=="Playing" and state:GetAttribute("Event")=="" and (state:GetAttribute("CustomerStage")=="Ordering" or state:GetAttribute("CustomerStage")=="Arriving")
 customerText.Text=(state:GetAttribute("CustomerTitle") or "Guest")..((state:GetAttribute("CustomerKind")=="Reviewer") and " • BONUS REVIEW" or "")
 local msg=state:GetAttribute("TeamPing") or "";ping.Visible=msg~="" and shop~=nil;pingText.Text=msg
 pingHighlight.Adornee=shop and shop:FindFirstChild(state:GetAttribute("PingStation") or "");pingHighlight.Enabled=gui.Enabled and ping.Visible and pingHighlight.Adornee~=nil
 if networkError then feedbackText.Text=networkError;feedbackUntil=now+2;networkError=nil end
 sale.Visible=saleUntil>now
 review.Visible=reviewUntil>now
 local rushSeconds=math.max(0,math.ceil((state:GetAttribute("RushUntil") or 0)-now))
 rush.Visible=shop~=nil and state:GetAttribute("Phase")=="Playing" and rushSeconds>0 and not review.Visible
 rushText.Text="RUSH "..rushSeconds.."s • POPULARITY "..tostring(state:GetAttribute("Popularity") or 0).."/100"
 feedback.Visible=feedbackUntil>now and not sale.Visible
 if not gui.Enabled then highlight.Enabled=false;pingHighlight.Enabled=false end
end)
