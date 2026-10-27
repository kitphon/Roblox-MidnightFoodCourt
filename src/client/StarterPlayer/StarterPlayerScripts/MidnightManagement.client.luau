local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local LocalizationService=game:GetService("LocalizationService")
local player=Players.LocalPlayer
local network=RS:WaitForChild("MidnightNetwork")
local Recipes=require(RS.MidnightStyle.RecipeCatalog)
local gui=Instance.new("ScreenGui");gui.Name="MidnightManagement";gui.ResetOnSpawn=false;gui.DisplayOrder=20;gui.IgnoreGuiInset=true;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild("PlayerGui")
local C={bg=Color3.fromRGB(17,30,38),panel=Color3.fromRGB(28,46,54),mint=Color3.fromRGB(111,231,193),gold=Color3.fromRGB(255,199,101),white=Color3.fromRGB(235,239,231),muted=Color3.fromRGB(159,180,180),disabled=Color3.fromRGB(45,58,64)}
local thai=LocalizationService.RobloxLocaleId:lower():sub(1,2)=="th"
local TH={
 ["KITCHEN  [M]"]="ร้านอาหาร  [M]",["YOUR KITCHEN"]="ร้านของคุณ",["Keep your kitchen running."]="ดูแลร้านให้พร้อมรับลูกค้า",
 ["Overview"]="หน้าหลัก",["Supplies"]="วัตถุดิบ",["Staff"]="พนักงาน",["Upgrades"]="อัปเกรด",["Co-op"]="ทีมร้าน",["Quests"]="ภารกิจ",["More"]="เพิ่มเติม",["Journey"]="ความก้าวหน้า",["Travel"]="เดินทาง",
 ["Kitchen overview"]="ภาพรวมร้าน",["Your next step, all in one place."]="เลือกสิ่งที่จะทำต่อได้ตรงนี้",["Grow your kitchen"]="ขยายร้านของคุณ",["Spend Shop funds to improve cooking, service and earnings."]="ใช้เงินร้านเพื่อพัฒนาการทำอาหาร บริการ และรายได้",
 ["Play together"]="เล่นด้วยกัน",["Join a kitchen or invite up to 3 friends to yours."]="สมัครเข้าร้านหรือชวนเพื่อนได้สูงสุด 3 คน",["Open shop"]="เปิดร้าน",["Close shop"]="ปิดร้าน",["View supplies"]="ดูวัตถุดิบ",
 ["Find a crew"]="หาทีมร้าน",["Walk to a green CREW circle"]="เดินไปที่วง CREW สีเขียว",["Return to kitchen"]="กลับร้าน",["Owner only"]="เฉพาะเจ้าของร้าน",["Fully upgraded"]="อัปเกรดเต็มแล้ว",
 ["More options"]="ตัวเลือกเพิ่ม",["Less options"]="ซ่อนตัวเลือก",["Refresh"]="รีเฟรช",["Working…"]="กำลังดำเนินการ…",["Loading your kitchen…"]="กำลังโหลดร้าน…",
 ["SHOP FUNDS"]="เงินร้าน",["YOUR COINS"]="เหรียญของคุณ",["GEMS"]="เจม",["Daily quests"]="ภารกิจประจำวัน",["Check your supplies"]="ตรวจวัตถุดิบ",["My shop"]="ร้านของฉัน",
 ["SHOP OPEN"]="ร้านเปิดอยู่",["SHOP CLOSED"]="ร้านปิดอยู่",["Player crew"]="ทีมผู้เล่น",["Dining Area"]="พื้นที่รับประทานอาหาร",["Kitchen"]="ครัว",["Service"]="บริการ",["Decor"]="ตกแต่ง",
 ["Start your own kitchen"]="เปิดร้านของตัวเอง",["Open my kitchen"]="เปิดร้านของฉัน",["Join another crew"]="สมัครร้านอื่น",["Go to city spawn"]="ไปจุดเริ่มต้นเมือง",["Choose what you want to do next."]="เลือกสิ่งที่ต้องการทำต่อ"
}
local function localizeTree(root)
 if not thai then return end
 for _,v in root:GetDescendants() do
  if v:IsA("TextLabel") or v:IsA("TextButton") then v.Text=TH[v.Text] or v.Text end
 end
end
local function localizeWorldPrompt(object)
 if not thai then return end
 if object:IsA("TextLabel") and object.Name=="UpgradeDeskText" then object.Text="โต๊ะอัปเกรด"
 elseif object:IsA("TextLabel") and object.Name=="CrewHiringText" then object.Text="รับสมัครพนักงาน\nสมัครที่นี่"
 elseif object:IsA("ProximityPrompt") then
  if object.Name=="UpgradePrompt" then object.ActionText="เปิดอัปเกรด";object.ObjectText="โต๊ะทำงาน"
  elseif object.Name=="CrewJoinPrompt" then
   object.ActionText="สมัครเป็นพนักงาน"
   local owner,count=object.ObjectText:match("^(.-)'s crew • (%d+/4)$")
   if owner then object.ObjectText="ทีมของ "..owner.." • "..count
   elseif object.ObjectText=="No crew yet" or object.ObjectText=="NOW HIRING" then object.ObjectText="ป้ายรับสมัครงาน" end
  end
 end
end
local function watchWorldPrompt(v)
 localizeWorldPrompt(v)
 if thai and v:IsA("ProximityPrompt") and (v.Name=="UpgradePrompt" or v.Name=="CrewJoinPrompt") then
  v:GetPropertyChangedSignal("ObjectText"):Connect(function() task.defer(localizeWorldPrompt,v) end)
 end
end
for _,v in workspace:GetDescendants() do watchWorldPrompt(v) end
workspace.DescendantAdded:Connect(watchWorldPrompt)
local tileWidth=364
local isCompact=false
local function corner(a) local v=Instance.new("UICorner");v.CornerRadius=UDim.new(0,12);v.Parent=a end
local function label(parent,str,x,y,w,h,size,color)
 local a=Instance.new("TextLabel");a.Position=UDim2.fromOffset(x,y);a.Size=UDim2.fromOffset(w,h);a.BackgroundTransparency=1;a.Text=str;a.TextSize=size or 17;a.Font=Enum.Font.GothamBold;a.TextColor3=color or C.white;a.TextWrapped=true;a.TextXAlignment=Enum.TextXAlignment.Left;a.Parent=parent;return a
end
local function button(parent,str,x,y,w,h,fn,color)
 if parent:GetAttribute("ManagementTile") then
  if w==234 then w=tileWidth-24;y=isCompact and 150 or 144;h=isCompact and 56 or h end
  if w==76 then local i=math.floor((x-10)/82);w=math.floor((tileWidth-40)/3);x=12+i*(w+8);y=isCompact and 150 or 144;h=isCompact and 52 or h end
 end
 local a=Instance.new("TextButton");a.Position=UDim2.fromOffset(x,y);a.Size=UDim2.fromOffset(w,h);a.BorderSizePixel=0;a.BackgroundColor3=color or C.mint;a.TextColor3=C.bg;a.Text=str;a.Font=Enum.Font.GothamBold;a.TextSize=14;a.AutoButtonColor=false;a.Parent=parent;corner(a)
 local base=a.BackgroundColor3
 a:SetAttribute("RestColor",base)
 local function restColor() return a:GetAttribute("RestColor") or base end
 a.MouseEnter:Connect(function() if a.Active then Tween:Create(a,TweenInfo.new(.12),{BackgroundColor3=restColor():Lerp(Color3.new(1,1,1),.12)}):Play() end end)
 a.MouseLeave:Connect(function() if a.Active then Tween:Create(a,TweenInfo.new(.12),{BackgroundColor3=restColor()}):Play() end end)
 a.Activated:Connect(function() if a.Active then fn() end end);return a
end
local function disabled(b,reason)
 b.Active=false;b.Selectable=false;b.BackgroundColor3=C.disabled;b.TextColor3=C.muted
 if reason then b.Text=reason end
end
local openButton=button(gui,"KITCHEN  [M]",16,0,158,46,function() end)
openButton.AnchorPoint=Vector2.new(0,1);openButton.Position=UDim2.new(0,16,1,-24)
openButton.Name="KitchenButton"
-- Touch screens have no M key; MidnightGameplay also moves this button off the left-side thumbstick zone.
if UIS.TouchEnabled then openButton.Text=thai and "ร้านอาหาร" or "KITCHEN";openButton.Size=UDim2.fromOffset(124,40) end
local dim=Instance.new("TextButton");dim.Name="ManagementBackdrop";dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new();dim.BackgroundTransparency=.25;dim.Text="";dim.AutoButtonColor=false;dim.Active=true;dim.Visible=false;dim.Parent=gui
local panel=Instance.new("Frame");panel.Name="KitchenPanel";panel.Active=true;panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(980,650);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;corner(panel)
local scale=Instance.new("UIScale");scale.Parent=panel
local title=label(panel,"YOUR KITCHEN",22,16,310,30,24,C.white)
local tagline=label(panel,"Keep your kitchen running.",22,48,320,20,13,C.muted)
local wallets={}
for i,spec in ipairs({{"Bank","SHOP FUNDS",C.gold},{"Coins","YOUR COINS",C.mint},{"Gems","GEMS",Color3.fromRGB(190,166,249)}}) do
 local f=Instance.new("Frame");f.Size=UDim2.fromOffset(150,65);f.Position=UDim2.fromOffset(426+(i-1)*164,17);f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.Parent=panel;corner(f)
 label(f,spec[2],12,7,130,16,10,C.muted)
 wallets[spec[1]]={frame=f,value=label(f,"—",12,25,130,30,23,spec[3])}
end
local nav=Instance.new("ScrollingFrame");nav.Name="Navigation";nav.BackgroundTransparency=1;nav.BorderSizePixel=0;nav.ScrollBarThickness=3;nav.AutomaticCanvasSize=Enum.AutomaticSize.Y;nav.CanvasSize=UDim2.new();nav.Parent=panel
local navLayout=Instance.new("UIListLayout");navLayout.Padding=UDim.new(0,7);navLayout.SortOrder=Enum.SortOrder.LayoutOrder;navLayout.Parent=nav
local navPadding=Instance.new("UIPadding");navPadding.PaddingTop=UDim.new(0,4);navPadding.PaddingBottom=UDim.new(0,4);navPadding.PaddingLeft=UDim.new(0,4);navPadding.PaddingRight=UDim.new(0,4);navPadding.Parent=nav
local heading=label(panel,"Kitchen overview",210,111,570,30,23,C.white)
local subtitle=label(panel,"Your next step, all in one place.",210,145,730,25,13,C.muted)
local message=label(panel,"",22,604,910,28,13,C.gold);message.Name="Feedback"
local content=Instance.new("ScrollingFrame");content.Name="Content";content.Position=UDim2.fromOffset(210,185);content.Size=UDim2.fromOffset(752,407);content.CanvasSize=UDim2.new();content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=5;content.ScrollBarImageColor3=C.mint;content.Parent=panel
local layout=Instance.new("UIGridLayout");layout.CellSize=UDim2.fromOffset(364,190);layout.CellPadding=UDim2.fromOffset(12,12);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=content
local snapshot,currentTab,busy=nil,"Overview",false
local confirmSaveAction,confirmSaveUntil="",0
local tabs={}
local showMore=false
local showMyShop=false
local secondaryTabs={Travel=true,Journey=true}
local render,refresh,command,resize,renderUpgrade
local refreshQueued=false
local upgradeGui=Instance.new("ScreenGui");upgradeGui.Name="MidnightUpgrade";upgradeGui.ResetOnSpawn=false;upgradeGui.DisplayOrder=21;upgradeGui.IgnoreGuiInset=true;upgradeGui.Parent=player.PlayerGui
local upgradeDim=Instance.new("Frame");upgradeDim.Name="UpgradeBackdrop";upgradeDim.Size=UDim2.fromScale(1,1);upgradeDim.BackgroundColor3=Color3.new();upgradeDim.BackgroundTransparency=.25;upgradeDim.Visible=false;upgradeDim.Parent=upgradeGui
local upgradePanel=Instance.new("Frame");upgradePanel.Name="UpgradePanel";upgradePanel.AnchorPoint=Vector2.new(.5,.5);upgradePanel.Position=UDim2.fromScale(.5,.5);upgradePanel.BackgroundColor3=C.bg;upgradePanel.Visible=false;upgradePanel.Parent=upgradeGui;corner(upgradePanel)
label(upgradePanel,"UPGRADE DESK",20,16,260,32,24,C.gold)
local upgradeFunds=label(upgradePanel,"",20,54,650,28,14,C.mint)
local upgradeMessage=label(upgradePanel,"",20,0,650,32,13,C.gold)
local upgradeContent=Instance.new("ScrollingFrame");upgradeContent.Name="Upgrades";upgradeContent.BackgroundTransparency=1;upgradeContent.BorderSizePixel=0;upgradeContent.ScrollBarThickness=5;upgradeContent.AutomaticCanvasSize=Enum.AutomaticSize.Y;upgradeContent.CanvasSize=UDim2.new();upgradeContent.Parent=upgradePanel
local upgradeLayout=Instance.new("UIGridLayout");upgradeLayout.CellPadding=UDim2.fromOffset(12,12);upgradeLayout.SortOrder=Enum.SortOrder.LayoutOrder;upgradeLayout.Parent=upgradeContent
local function closeUpgrade() upgradePanel.Visible=false;upgradeDim.Visible=false end
local upgradeClose=button(upgradePanel,"×",0,12,44,44,closeUpgrade,C.panel);upgradeClose.Name="CloseUpgrade"
upgradeClose.TextColor3=C.white;upgradeClose.TextSize=24
upgradePanel.Active=true;upgradeDim.Active=true
-- Mall supply counter: its own window, separate from the Kitchen menu.
local mallGui=Instance.new("ScreenGui");mallGui.Name="MidnightMall";mallGui.ResetOnSpawn=false;mallGui.DisplayOrder=21;mallGui.IgnoreGuiInset=true;mallGui.Parent=player.PlayerGui
local mallDim=Instance.new("Frame");mallDim.Name="MallBackdrop";mallDim.Size=UDim2.fromScale(1,1);mallDim.BackgroundColor3=Color3.new();mallDim.BackgroundTransparency=.25;mallDim.Active=true;mallDim.Visible=false;mallDim.Parent=mallGui
local mallPanel=Instance.new("Frame");mallPanel.Name="MallPanel";mallPanel.Active=true;mallPanel.AnchorPoint=Vector2.new(.5,.5);mallPanel.Position=UDim2.fromScale(.5,.5);mallPanel.BackgroundColor3=C.bg;mallPanel.Visible=false;mallPanel.Parent=mallGui;corner(mallPanel)
local mallTitle=label(mallPanel,"MIDNIGHT MALL • SUPPLIES",20,16,520,32,24,C.gold)
local mallFunds=label(mallPanel,"",20,52,650,22,14,C.mint)
local mallHint=label(mallPanel,"",20,76,650,36,13,C.muted)
local mallMessage=label(mallPanel,"",20,0,650,32,13,C.gold);mallMessage.Name="Feedback"
local mallContent=Instance.new("ScrollingFrame");mallContent.Name="Crates";mallContent.BackgroundTransparency=1;mallContent.BorderSizePixel=0;mallContent.ScrollBarThickness=5;mallContent.ScrollBarImageColor3=C.mint;mallContent.AutomaticCanvasSize=Enum.AutomaticSize.Y;mallContent.CanvasSize=UDim2.new();mallContent.Parent=mallPanel
local mallLayout=Instance.new("UIGridLayout");mallLayout.CellPadding=UDim2.fromOffset(12,12);mallLayout.SortOrder=Enum.SortOrder.LayoutOrder;mallLayout.Parent=mallContent
local mallQty={}
local function closeStyleWindowEarly() local event=player.PlayerGui:FindFirstChild("CloseStyleShop");if event then event:Fire() end end
local renderMall
local function closeMall() mallPanel.Visible=false;mallDim.Visible=false end
local mallClose=button(mallPanel,"×",0,12,44,44,closeMall,C.panel);mallClose.Name="CloseMall"
mallClose.TextColor3=C.white;mallClose.TextSize=24
local function resizeMall()
 local view=workspace.CurrentCamera.ViewportSize
 local width,height=math.min(940,view.X-24),math.min(600,view.Y-24)
 local narrow=width<650
 mallPanel.Size=UDim2.fromOffset(width,height);mallClose.Position=UDim2.fromOffset(width-56,12)
 mallTitle.Size=UDim2.fromOffset(width-90,32);mallTitle.TextScaled=narrow
 mallFunds.Size=UDim2.fromOffset(width-40,22);mallHint.Size=UDim2.fromOffset(width-40,36)
 mallMessage.Position=UDim2.fromOffset(20,height-42);mallMessage.Size=UDim2.fromOffset(width-40,32)
 mallContent.Position=UDim2.fromOffset(20,118);mallContent.Size=UDim2.fromOffset(width-40,height-166)
 mallLayout.CellSize=UDim2.fromOffset(narrow and width-52 or math.floor((width-64)/3),236)
 if renderMall and mallPanel.Visible then renderMall() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeMall);resizeMall()
local function resizeUpgrade()
 local view=workspace.CurrentCamera.ViewportSize
 local width,height=math.min(900,view.X-24),math.min(680,view.Y-24)
 upgradePanel.Size=UDim2.fromOffset(width,height);upgradeClose.Position=UDim2.fromOffset(width-56,12)
 upgradeFunds.Size=UDim2.fromOffset(width-40,32);upgradeMessage.Position=UDim2.fromOffset(20,height-42);upgradeMessage.Size=UDim2.fromOffset(width-40,32)
 upgradeContent.Position=UDim2.fromOffset(20,98);upgradeContent.Size=UDim2.fromOffset(width-40,height-154)
 upgradeLayout.CellSize=UDim2.fromOffset(width<650 and width-52 or (width-64)/2,202)
 if renderUpgrade and upgradePanel.Visible then renderUpgrade() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeUpgrade);resizeUpgrade()
renderUpgrade=function()
 if not snapshot then return end
 local scroll=upgradeContent.CanvasPosition
 for _,v in upgradeContent:GetChildren() do if v:IsA("GuiObject") then v:Destroy() end end
 upgradeFunds.Text="Shop funds: $"..snapshot.Bank.."    •    Your coins: "..snapshot.Coins
 local function card(titleText,description,actionText,callback,reason)
  local f=Instance.new("Frame");f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.Parent=upgradeContent;corner(f)
  label(f,titleText,14,12,upgradeLayout.CellSize.X.Offset-28,30,19,C.white)
  label(f,description,14,48,upgradeLayout.CellSize.X.Offset-28,76,13,C.muted)
  local b=button(f,actionText,14,144,upgradeLayout.CellSize.X.Offset-28,42,callback,C.mint)
  if reason then b.Active=false;b.Text=reason;b.BackgroundColor3=C.disabled;b.TextColor3=C.muted end
 end
 for _,item in ipairs(snapshot.UpgradeCatalog or {}) do
  local level=snapshot.Upgrades[item.Id] or 0;local cost=item.Price*(level+1)
  local reason=level>=item.Max and "Fully upgraded" or not snapshot.Owner and "Owner only" or snapshot.Bank<cost and ("Need Shop $"..cost) or nil
  card(item.Name.."  "..level.."/"..item.Max,item.Description,"$"..cost.." • Upgrade",function() command("Upgrade",item.Id) end,reason)
 end
 card("Shop funds","Move 100 personal coins into the shop fund. Shop funds cannot be withdrawn as coins.","Deposit 100 coins",function() command("Deposit") end,not snapshot.Owner and "Owner only" or snapshot.Coins<100 and "Need 100 coins" or nil)
 upgradeContent.CanvasPosition=scroll
end
local function icon(parent,symbol,color)
 local badge=Instance.new("Frame");badge.Size=UDim2.fromOffset(42,42);badge.BackgroundColor3=color or C.mint;badge.BorderSizePixel=0;badge.Parent=parent;corner(badge)
 local function shape(x,y,w,h,rotation,round)
 local a=Instance.new("Frame");a.Position=UDim2.fromOffset(x,y);a.Size=UDim2.fromOffset(w,h);a.BackgroundColor3=C.bg;a.BorderSizePixel=0;a.Rotation=rotation or 0;a.Parent=badge;if round then corner(a) end;return a
end
if symbol=="Save" then
 shape(8,7,27,29);local top=shape(14,8,15,10);top.BackgroundColor3=color or C.mint;local bottom=shape(13,24,17,10);bottom.BackgroundColor3=color or C.mint
elseif symbol=="♙" then
 shape(15,5,12,12,0,true);shape(10,20,22,16,0,true)
elseif symbol=="✓" then
 shape(8,22,13,5,45,true);shape(16,17,22,5,-45,true)
elseif symbol=="✦" then
 shape(18,8,6,26,0,true);shape(8,18,26,6,0,true);shape(18,8,6,26,45,true)
elseif symbol=="↑" then
 shape(18,14,6,22);shape(12,8,12,12,45);shape(16,14,10,10)
elseif symbol=="☀" then
 shape(11,11,20,20,0,true);shape(19,3,4,5);shape(19,34,4,5);shape(3,19,5,4);shape(34,19,5,4)
elseif symbol=="▦" then
 for i=0,2 do for j=0,2 do shape(9+i*9,9+j*9,6,6) end end
elseif symbol=="♪" then
 shape(24,8,4,20);shape(14,25,14,9,0,true);shape(24,8,9,4)
elseif symbol=="FoodNoodles" then
 shape(7,20,28,15,0,true);shape(5,18,32,4);shape(12,13,19,3);shape(12,8,3,7)
elseif symbol=="FoodRice" then
 shape(5,20,32,15,0,true);shape(10,14,22,15,0,true);shape(20,10,10,10,0,true)
elseif symbol=="FoodTea" then
 shape(12,14,20,24,0,true);shape(10,12,24,4);shape(26,4,3,14)
elseif symbol=="Bus" then
 shape(5,10,32,23,0,true);shape(9,31,7,7,0,true);shape(27,31,7,7,0,true)
 local a=shape(10,14,8,8);a.BackgroundColor3=color or C.mint
 local b=shape(23,14,8,8);b.BackgroundColor3=color or C.mint
elseif symbol=="Chef" then
 shape(7,7,28,14,0,true);shape(12,17,18,9);shape(9,27,24,7)
elseif symbol=="Waiter" then
 shape(5,27,32,4);shape(19,8,4,15);shape(11,22,20,4);shape(12,9,18,3)
elseif symbol=="Technician" then
 shape(17,15,7,22,25);shape(11,6,19,14,0,true)
elseif symbol=="Home" then
 shape(9,20,24,17);shape(11,8,21,21,45)
elseif symbol=="♦" then
 shape(11,11,20,20,45)
else local glyph=label(badge,symbol,0,0,42,42,24,C.bg);glyph.TextXAlignment=Enum.TextXAlignment.Center;glyph.TextYAlignment=Enum.TextYAlignment.Center end

 return badge
end
local function tile(titleText,description,symbol,color)
 local f=Instance.new("Frame");f.Name=titleText;f:SetAttribute("ManagementTile",true);f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.Parent=content;corner(f)
 local badge=icon(f,symbol,color);badge.Position=UDim2.fromOffset(14,14)
 label(f,titleText,70,12,tileWidth-84,46,18,C.white)
 label(f,description,14,68,tileWidth-28,64,isCompact and 16 or 14,C.muted)
 return f
end
local function describeReward(r)
 local parts={};if r and r.Coins then table.insert(parts,r.Coins.." Coins") end;if r and r.Gems then table.insert(parts,r.Gems.." Gems") end
 return #parts>0 and table.concat(parts," + ") or "—"
end
local function duration(seconds)
 seconds=math.max(0,math.floor(seconds))
 if seconds>=86400 then return string.format("%dd %dh",seconds//86400,(seconds%86400)//3600) end
 return string.format("%dh %02dm",seconds//3600,(seconds%3600)//60)
end
local function questsReady(q)
 if not q then return 0 end
 local n=q.LoginClaimed and 0 or 1
 for _,row in q.Daily do if not row.Claimed and row.Progress>=row.Goal then n+=1 end end
 for _,row in q.Weekly do if not row.Claimed and row.Progress>=row.Goal then n+=1 end end
 return n
end
-- Courier card for city visitors (players without a kitchen).
local function courierTile()
 local job=snapshot.Courier
 if not job or not job.Eligible then return end
 local f=tile(job.Active and ("Courier • "..job.Food) or "City courier",job.Active and ("Carry this crate to "..job.Owner.."'s backroom bin (Kitchen "..job.ShopId.."). Reward: "..job.Reward.." Coins.") or ("Free crates at the mall supply counter. Deliver one to a kitchen that needs it and earn "..job.Reward.." Coins."),"Bus",C.gold)
 if job.Active then button(f,"Cancel delivery",12,130,234,34,function() command("CourierCancel") end)
 else
  local b=button(f,"Take a courier crate",12,130,234,34,function() command("CourierTake") end)
  if not job.NearMall then disabled(b,"Go to the mall supply counter") end
 end
end
renderMall=function()
 if not snapshot then return end
 local scroll=mallContent.CanvasPosition
 for _,v in mallContent:GetChildren() do if v:IsA("GuiObject") then v:Destroy() end end
 local stock=snapshot.Supplies
 local cell=mallLayout.CellSize.X.Offset
 local function card(titleText,symbol,color)
  local f=Instance.new("Frame");f.Name=titleText;f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.Parent=mallContent;corner(f)
  local badge=icon(f,symbol,color);badge.Position=UDim2.fromOffset(14,14)
  label(f,titleText,68,12,cell-82,24,18,C.white)
  return f
 end
 if not stock or snapshot.ShopId==0 then
  mallFunds.Text="Your coins: "..snapshot.Coins
  mallHint.Text="Join or open a kitchen to buy supplies with shop funds."
  local job=snapshot.Courier
  if job and job.Eligible then
   local f=card(job.Active and ("Courier • "..job.Food) or "City courier","Bus",C.gold)
   label(f,job.Active and ("Carry this crate to "..job.Owner.."'s backroom (Kitchen "..job.ShopId..").") or ("Take a free crate to a kitchen that needs it and earn "..job.Reward.." Coins."),14,64,cell-28,90,14,C.muted).TextYAlignment=Enum.TextYAlignment.Top
   local b=button(f,job.Active and "Cancel delivery" or "Take a courier crate",14,182,cell-28,40,function() command(job.Active and "CourierCancel" or "CourierTake") end)
   if not job.Active and not job.NearMall then disabled(b,"Go to the supply counter") end
  end
  mallContent.CanvasPosition=scroll;return
 end
 local carry=stock.Carry
 local delivering=carry and carry.Mode=="Delivery"
 local carried=delivering and (carry.Crates or 1) or 0
 local limit=stock.TripLimit or 1
 local room=math.max(0,limit-carried)
 mallFunds.Text="Shop funds: $"..snapshot.Bank.."    •    Carrying "..carried.."/"..limit.." crates"
 mallHint.Text="1 crate = "..stock.Quantity.." kits • $"..stock.Price.." each. Buy as many kinds as you need, then deliver them to any backroom shelf."
 for i,food in ipairs(stock.Foods) do
  local f=card(food.Name,"Food"..food.Key,Color3.fromRGB(unpack(food.Color)));f.LayoutOrder=i
  label(f,"Backroom "..tostring(stock.Back[food.Id] or 0).." • Front "..tostring(stock.Front[food.Id] or 0).."/"..stock.Capacity,68,36,cell-82,18,12,C.muted)
  local lines={}
  for _,dish in (stock.Dishes and stock.Dishes[food.Id]) or {} do
   table.insert(lines,dish.Unlocked and ("Station "..dish.Station.." • "..dish.Name) or ("Lv. "..dish.Level.." • "..dish.Name))
  end
  local used=label(f,"For: "..(#lines>0 and table.concat(lines,"\n       ") or "—"),14,64,cell-28,60,13,C.white);used.TextYAlignment=Enum.TextYAlignment.Top
  local qty=math.clamp(mallQty[food.Id] or 1,1,math.max(1,room));mallQty[food.Id]=qty
  local minus=button(f,"−",14,132,44,38,function() mallQty[food.Id]=math.max(1,qty-1);renderMall() end,C.disabled);minus.TextColor3=C.white;minus.TextSize=22
  local count=label(f,qty.." crate"..(qty>1 and "s" or ""),64,132,cell-128,38,16,C.white);count.TextXAlignment=Enum.TextXAlignment.Center
  local plus=button(f,"+",cell-58,132,44,38,function() mallQty[food.Id]=math.min(math.max(1,room),qty+1);renderMall() end,C.disabled);plus.TextColor3=C.white;plus.TextSize=22
  local total=qty*stock.Price
  local buy=button(f,"Buy "..qty.." • $"..total,14,182,cell-28,40,function() command("BuySupplies",food.Id..":"..qty) end)
  if not snapshot.Owner then disabled(buy,"Owner only")
  elseif not stock.NearMall then disabled(buy,"Go to the supply counter")
  elseif carry and not delivering then disabled(buy,"Refill your station crate first")
  elseif room<=0 then disabled(buy,"Hands full • deliver first")
  elseif snapshot.Bank<total then disabled(buy,"Need Shop $"..total) end
 end
 if delivering then
  local items={}
  for _,food in ipairs(stock.Foods) do local n=carry.Items and carry.Items[food.Id] or (carry.Food==food.Id and carry.Quantity) or 0;if n>0 then table.insert(items,food.Name.." ×"..n) end end
  local f=card("Your delivery","▦",C.gold);f.LayoutOrder=10
  label(f,table.concat(items,"\n").."\n\nTake the BUS back and drop everything at any backroom shelf.",14,64,cell-28,150,13,C.muted).TextYAlignment=Enum.TextYAlignment.Top
 end
 mallContent.CanvasPosition=scroll
end
local function openMall()
 closeUpgrade();closeStyleWindowEarly()
 panel.Visible=false;dim.Visible=false
 mallPanel.Visible=true;mallDim.Visible=true;mallMessage.Text="";mallContent.CanvasPosition=Vector2.zero
 refresh()
end
local function clear()
 for _,v in ipairs(content:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
end
local tabInfo={
 Journey={"Journey","↑","Your restaurant journey","Reputation, shift goals, house specials and training."},
 Quests={"Quests","✓","Daily quests & rewards","Login streak, daily and weekly goals. Resets at 00:00 UTC."},
 Ranks={"Ranks","✦","Leaderboards","Top cooks by meals served, this week and all time."},
 Saves={"Saves","Save","Your saved kitchen","One permanent design slot. Your progress always saves automatically."},
 Overview={"Overview","Home","Kitchen overview","A quick look at your shop and what to do next."},
 Staff={"Staff","♙","Your team","Hire help with Shop funds. Choose jobs for your player crew."},
 ["Co-op"]={"Co-op","♙","Play together","Join a kitchen or invite up to 3 friends to yours."},
 Travel={"Travel","Bus","Get around town","Walk to a bus stop, then choose where to go."},
 Store={"SHOP","▦","Make it yours","Themes, outfits and effects. Paid with your Coins."},
 Robux={"GET GEMS","♦","Gem shop","Special styles and optional gem packs."},
 City={"City","☀","Around the city","City events, emotes and a quick trip home."},
 More={"More","…","More options","Rewards, travel and progress."}
}
local function destination(name)
 if name=="Saves" then showMyShop=true;return "Overview" end
 if name=="Ranks" then return "Journey" end
 if name=="City" then return "Travel" end
 if name=="Co-op" or name=="Stock" then return "Overview" end
 return name
end
local function selectTab(name)
 closeUpgrade();closeMall()
 if name=="Overview" then showMyShop=false end
 name=destination(name)
 if name=="More" then showMore=not showMore;if snapshot then render() end;return end
 if name=="Store" or name=="Robux" then
  local event=player.PlayerGui:FindFirstChild("OpenStyleShop")
  if event then panel.Visible=false;dim.Visible=false;event:Fire(name=="Robux" and "Gems" or "Packs");return end
 end
 if not tabInfo[name] then name="Overview" end
 confirmSaveAction="";confirmSaveUntil=0
 currentTab=name;content.CanvasPosition=Vector2.zero;message.Text=""
 if snapshot then render() else refresh() end
end
command=function(action,id)
 if busy then return end
 busy=true;local status=mallPanel.Visible and mallMessage or upgradePanel.Visible and upgradeMessage or message;status.Text="Working…"
 for _,root in {content,upgradeContent,mallContent} do for _,b in root:GetDescendants() do if b:IsA("TextButton") then b.Active=false end end end
 local ok,result=pcall(function() return network.Command:InvokeServer(action,id) end)
 status.Text=ok and result.Message or "Connection interrupted. Please try again."
 status.TextColor3=ok and result.Ok and C.mint or C.gold
 task.wait(.2);busy=false
 refresh()
end
local catalogKeys={"Items","Premium","Products","UpgradeCatalog","WorkerCatalog"}
local catalogCache,catalogAt=nil,0
refresh=function()
 -- Ask for the static catalogs only on first load and once a minute (prices can change remotely).
 local wantFull=catalogCache==nil or os.clock()-catalogAt>60
 local ok,result=pcall(function() return network.Snapshot:InvokeServer(wantFull) end)
 if ok and result.Ready then
  if result.Full then catalogCache={};catalogAt=os.clock();for _,k in catalogKeys do catalogCache[k]=result[k] end
  elseif catalogCache then for _,k in catalogKeys do result[k]=catalogCache[k] end end
 end
 if not ok or not result.Ready then
  if not snapshot then message.Text="Loading your kitchen…" end
  if ok and result.Retry and not refreshQueued then refreshQueued=true;task.delay(.25,function() refreshQueued=false;if panel.Visible then refresh() end end) end
  return
 end
 if message.Text=="Loading your kitchen…" then message.Text="" end
 snapshot=result;render();if upgradePanel.Visible then renderUpgrade() end;if mallPanel.Visible then renderMall() end
end
local function renderShopSaves()

  local save=snapshot.Saves
  if not save then tile("Loading saves","Please reopen this menu in a moment.","Save",C.gold)
  else
   local function confirm(action)
    if confirmSaveAction==action and os.clock()<confirmSaveUntil then
     confirmSaveAction="";confirmSaveUntil=0;command(action)
    else confirmSaveAction=action;confirmSaveUntil=os.clock()+12;render() end
   end
   local access=tile("Shop Save Slot",save.Owned and "Owned forever. Save and reuse one shop design." or "One-time unlock. Save your favorite design and load it on your next visit.","Save",C.gold)
   local testing=save.TestEnabled==true
   local buy=button(access,save.Owned and (testing and "TEST UNLOCKED" or "PERMANENTLY OWNED") or testing and "Test unlock (free)" or save.Configured and "Buy Save Slot" or "Coming soon",12,130,234,34,function() command(testing and "SaveTestUnlock" or "SaveBuyPass") end)
   buy.Name="BuySaveSlot"
   if save.Owned then disabled(buy,testing and "TEST UNLOCKED" or "PERMANENTLY OWNED") elseif not save.Configured and not testing then disabled(buy,"Coming soon") elseif not testing then
    task.spawn(function()
     local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(save.PassId,Enum.InfoType.GamePass) end)
     if buy.Parent then
      if ok and info.IsForSale and type(info.PriceInRobux)=="number" then buy.Text="Unlock • "..info.PriceInRobux.." Robux"
      else disabled(buy,"Price unavailable") end
     end
    end)
   end
   local date=save.HasSave and os.date("!%d %b %Y • %H:%M UTC",save.SavedAt) or "Empty slot"
   local slot=tile(save.HasSave and save.ThemeName.." design" or "Your design slot",save.HasSave and date.."\nTheme, decorations and equipped styles." or "Save your current theme, decorations and equipped styles here.","Save",C.mint)
   local saveButton=button(slot,confirmSaveAction=="SaveDesign" and os.clock()<confirmSaveUntil and "Confirm overwrite" or save.HasSave and "Overwrite saved design" or "Save current design",12,130,234,34,function()
    if save.HasSave then confirm("SaveDesign") else command("SaveDesign") end
   end)
   saveButton.Name="SaveCurrentDesign"
   if not save.Owned then disabled(saveButton,"Unlock Save Slot first") elseif not snapshot.Owner then disabled(saveButton,"Your kitchen only") end
   local load=tile("Load your saved design","Close your shop first. Loading changes its look; money, stock, upgrades and employees keep their latest values.","Home",C.mint)
   local loadButton=button(load,confirmSaveAction=="LoadDesign" and os.clock()<confirmSaveUntil and "Confirm load design" or "Load saved design",12,130,234,34,function() confirm("LoadDesign") end)
   loadButton.Name="LoadSavedDesign"
   if not save.Owned then disabled(loadButton,"Unlock Save Slot first") elseif not save.HasSave then disabled(loadButton,"Save a design first") elseif not snapshot.Owner then disabled(loadButton,"Your kitchen only") elseif snapshot.Supplies and snapshot.Supplies.IsOpen then disabled(loadButton,"Close shop before loading") end
   local resume=tile("Next visit",save.AutoResume and "Your saved design loads automatically when you return." or "Return with your latest design. Your saved slot stays available.","Home",C.gold)
   local auto=button(resume,save.AutoResume and "Auto-load: ON" or "Auto-load: OFF",12,130,234,34,function() command("SaveAutoResume") end);auto.Name="ToggleSaveAutoResume"
   if not save.Owned or not save.HasSave or not snapshot.Owner then disabled(auto,"Save your design first") end
   tile("Progress stays safe","Funds, stock, upgrades, employees and purchased items save automatically for everyone. Loading never duplicates currency or supplies.","✓",C.mint)
   if save.TestEnabled then
    local test=tile("Studio test","No Robux charged. Saves last only until Stop; cloud saving needs a published game.","Save",C.gold)
    local testButton=button(test,"Test unlock (Studio)",12,130,234,34,function() command("SaveTestUnlock") end);testButton.Name="TestUnlockSaveSlot"
    if save.Owned then disabled(testButton,"Test access active") end
   end
  end

end
local function renderRanks()

  local r=snapshot.Ranks
  if not r then tile("Loading leaderboards","Please wait a moment.","✦",C.gold) else
   tile("Your meals served",r.MyWeek.." this week • "..r.MyAll.." all time\n"..(r.Live and "Global boards refresh every few minutes. Crew meals count for everyone in the kitchen." or "Studio preview: ranks players on this server only."),"♙",C.mint)
   for _,board in {{"This week",r.Weekly},{"All time",r.AllTime}} do
    local f=tile("Top cooks • "..board[1],"","✦",C.gold)
    local lines={}
    for i,row in board[2] do if i>7 then break end;table.insert(lines,(i<=3 and "★ " or "   ")..i..".  "..row.Name.."  •  "..row.Value) end
    local list=label(f,#lines>0 and table.concat(lines,"\n") or "No meals served yet. Be the first!",14,64,tileWidth-28,118,13,C.white)
    list.TextYAlignment=Enum.TextYAlignment.Top
   end
  end

end
render=function()
 if not snapshot then return end
 local scroll=content.CanvasPosition
 clear()
 for key,w in pairs(wallets) do w.value.Text=tostring(snapshot[key] or 0) end
 local info=tabInfo[currentTab] or tabInfo.Overview;heading.Text=info[3];subtitle.Text=info[4]
 for name,b in pairs(tabs) do
  local selected=name==currentTab
  b.Visible=not secondaryTabs[name] or showMore or selected
  if name=="More" then b.NavigationLabel.Text=showMore and "Less options" or "More options" end
  local color=name=="Store" and Color3.fromRGB(104,76,30) or name=="Robux" and Color3.fromRGB(77,51,121) or selected and Color3.fromRGB(39,85,77) or C.panel
  b:SetAttribute("Selected",selected);b:SetAttribute("RestColor",color);b.BackgroundColor3=color
  b.SelectionBar.Visible=selected
  b.SelectionOutline.Transparency=selected and .15 or 1
  b.NavigationLabel.TextColor3=(selected or name=="Store") and C.gold or C.white
  b.NavigationIcon.BackgroundColor3=selected and C.gold or C.mint
 end
 if currentTab=="Overview" then
  if showMyShop then
   heading.Text="My shop";subtitle.Text="Save and load your shop design."
   local back=tile("My shop","Your progress saves automatically. This slot stores your shop design.","Save",C.gold)
   button(back,"Back to overview",12,130,234,34,function() showMyShop=false;render() end)
   renderShopSaves()
  else
  local supplies=snapshot.Supplies
  local inShop=snapshot.ShopId>0
  local isOpen=supplies and supplies.IsOpen
  local f=tile(inShop and (isOpen and "Open for business" or "Ready when you are") or "Start your own kitchen",inShop and (isOpen and "Your shift is running. Close temporarily to restock." or "Check ingredients, then open for customers.") or "Choose what you want to do next.","Home",C.mint)
  local b=button(f,inShop and (isOpen and "Close shop" or "Open shop") or "Open my kitchen",12,130,234,34,function() command(inShop and "ToggleShop" or "Home") end)
  if inShop and not snapshot.Owner then disabled(b,"Only the owner can open / close") end
  if not inShop then
   local crew=tile("Join another crew","Walk to the green NOW HIRING sign beside any restaurant. You can join a different crew immediately.","♙",C.gold)
   button(crew,"Go to city spawn",12,130,234,34,function() command("Teleport") end)
  end
  local empty=0;local low=0
  if supplies then for _,food in ipairs(supplies.Foods) do local n=supplies.Front[food.Id] or 0;if n==0 then empty+=1 elseif n<=2 then low+=1 end end end
  local f2=tile("Check your supplies",(not inShop and "Join a kitchen to view ingredients." or empty>0 and (empty.." ingredient type(s) empty. Refill before cooking.") or low>0 and (low.." ingredient type(s) running low.") or "All cooking stations have ingredients.")..(inShop and " Need more? Take the BUS to the MALL." or ""),"FoodNoodles",empty>0 and C.gold or C.mint)
  if inShop and supplies then
   local parts={};for _,food in ipairs(supplies.Foods) do table.insert(parts,food.Name.." "..tostring(supplies.Front[food.Id] or 0).."/"..tostring(supplies.Back[food.Id] or 0)) end
   label(f2,"Front / Backroom: "..table.concat(parts,"  •  "),12,138,tileWidth-24,42,12,C.white)
  end
  local myShop=tile("My shop","Save or load your favorite shop design. Your money and progress stay current.","Save",C.gold)
  button(myShop,"Save / Load design",12,130,234,34,function() showMyShop=true;content.CanvasPosition=Vector2.zero;render() end)
  local ready=questsReady(snapshot.Quests)
  local f5=tile("Daily quests",ready>0 and (ready.." reward(s) ready to claim!") or ("Login streak day "..tostring(snapshot.Quests and snapshot.Quests.Streak or 1).."/7. Check today's goals."),"✓",ready>0 and C.gold or C.mint)
  button(f5,ready>0 and "Claim rewards" or "View quests",12,130,234,34,function() selectTab("Quests") end)
  if not inShop then courierTile() end
  end
 elseif currentTab=="Journey" then
  local j=snapshot.Journey
  if j then
   tile("★ "..j.Rank,tostring(j.Served).." lifetime orders • "..j.Perfect.." Perfect meals\nNext rank: "..j.Next.." orders. Higher ranks increase meal earnings.","↑",C.gold)
   tile("Menu • "..#j.Foods.." / 6 recipes","Start with 3 dishes. Unlock another at Lv. 2, 3 and 4. Set meals unlock at Lv. 2 after training: deliver food + a drink before the customer pays.","FoodNoodles",C.mint)
   local tierNames={"Corner Kitchen","Neighborhood Favorite","City Hotspot","Midnight Landmark","Kitchen Legend"}
   local needs={0,8,25,60,125}
   for i,name in tierNames do
    local reward=i==1 and "Your first kitchen." or i==2 and "House special selection. Buy Dining Area for seating." or i==3 and "Signature Chicken Rice + equipment trim." or i==4 and "Better meal earnings." or "Legend status + maximum rank earnings."
    tile((j.Level>=i and "✓ " or "")..name,needs[i].." served orders • "..reward,"↑",j.Level>=i and C.mint or C.gold)
   end
   local goals=j.Goals or {}
   for _,goal in {{"Manual","Serve meals yourself",3},{"Perfect","Cook Perfect meals",2},{"Refills","Refill front stock",2}} do
    tile(goal[2],math.min(goals[goal[1]] or 0,goal[3]).."/"..goal[3].." this shift • +$60 shop funds once per goal.","✓",C.mint)
   end
   tile("Food reviews",j.Reviews>0 and string.format("%.1f / 5 stars • %d reviews",j.Rating,j.Reviews) or "Food reviewers visit after training. Timing and quick service matter.","✦",C.gold)
   local signature=tile("Signature Chicken Rice","Unlock at City Hotspot. Replace the middle menu dish with your signature grilled chicken rice.","FoodRice",C.gold)
   local special=button(signature,j.SignatureEnabled and "Restore theme menu" or "Add signature recipe",12,130,234,34,function() command("SignatureMenu") end)
   if not snapshot.Owner then disabled(special,"Owner only") elseif j.Level<3 then disabled(special,"Unlock at rank 3") end
   tile("Popularity "..tostring(j.Popularity or 0).."/100","Based on food reviews. Up to +10% meal value; a strong review starts a 60-second rush with faster arrivals and more parties.","✦",C.gold)
   local friendLevel=j.RegularLevel or 1;local count=j.RegularServed or 0
   local nextFriend=({3,8,15,15})[friendLevel]
   tile("Riley • Friend Lv. "..friendLevel,count.." meals served • "..(friendLevel>=4 and "MAX FRIENDSHIP" or "Next level at "..nextFriend).." • Regular bonus +"..(15+(friendLevel-1)*5).."%","♙",C.mint)
   if j.LastReview then tile("Last review • "..j.LastReview.Stars.."/5",j.LastReview.Reason,"✦",C.gold) end
   for i,id in (j.Menu or j.Foods) do
    local recipe=Recipes.Get(id)
    local card=tile(recipe.Name,j.FeatureSlot==i and "CURRENT HOUSE SPECIAL • +15% meal value." or ("Unlock at Lv. "..(recipe.UnlockLevel or 1).." • Feature for +15% value."),"Food"..({"Noodles","Rice","Tea"})[recipe.Slot],C.mint)
    local b=button(card,j.FeatureSlot==i and "Remove special" or "Feature this dish",12,130,234,34,function() command("FeatureDish",j.FeatureSlot==i and "0" or tostring(i)) end)
    if j.Level<(recipe.UnlockLevel or 1) then disabled(b,"Unlock at Lv. "..recipe.UnlockLevel) elseif not snapshot.Owner then disabled(b,"Owner only") elseif j.Level<2 then disabled(b,"Unlock at rank 2") end
   end
   if j.Level>=5 then
    local maxed=(j.NextStar or 0)==0
    tile("Legend Stars ★"..(j.Stars or 0).."/"..(j.MaxStars or 20),maxed and "All Legend Stars earned! Meals earn +"..((j.Stars or 0)*2).."%." or ("Next star at "..j.NextStar.." orders ("..j.Served.." now). Each star: +2% meal value, +$150 shop funds and 40 Coins."),"✦",C.gold)
   else
    tile("Legend Stars","Reach Kitchen Legend (125 orders) to start earning Legend Stars: +2% meal value each, up to 20.","✦",C.muted)
   end
   local lesson=tile("First shift training","Open > Cook > Timing > Serve > Upgrade. First completion awards 50 Coins.","Home",C.gold)
   button(lesson,j.TutorialStep>5 and "Replay training" or "Restart training",12,130,234,34,function() command("TutorialReplay") end)
  end
  renderRanks()
 elseif currentTab=="Saves" then
  renderShopSaves()
 elseif currentTab=="Store" or currentTab=="Robux" then
  local list=currentTab=="Store" and snapshot.Items or snapshot.Premium
  if currentTab=="Robux" then
   for _,item in ipairs(snapshot.Products) do
    local configured=not snapshot.Sandbox and item.ProductId>0
    local testing=game:GetService("RunService"):IsStudio() and snapshot.Sandbox and require(RS.MidnightStyle.MonetizationConfig).EnableStudioTesting
    local f=tile(item.Name,testing and "Free simulation. Resets after Stop; no Robux charged." or configured and "Complete payment in the Roblox prompt" or "Gem packs are coming soon.","♦",C.gold)
    button(f,testing and "Test buy (free)" or configured and "Buy with Robux" or "Coming soon",12,130,234,34,function() if testing then command("StyleTestGems",item.Id) elseif configured then command("Topup",item.Id) end end)
    if not configured and not testing then for _,b in f:GetChildren() do if b:IsA("TextButton") then disabled(b,"Coming soon") end end end
    if configured then
     task.spawn(function()
      local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(item.ProductId,Enum.InfoType.Product) end)
      if ok and f.Parent then local buttons=f:GetChildren();for _,b in ipairs(buttons) do if b:IsA("TextButton") then b.Text=tostring(info.PriceInRobux).." Robux" end end end
     end)
    end
   end
  end
  for _,item in ipairs(list) do
   local owned=snapshot.Owned[item.Id];local eq=snapshot.Equipped[item.Kind]==item.Id
   local currency=item.Gems and " Gems" or " Coins"
   local f=tile(item.Name,item.Description,item.Kind=="Theme" and "▦" or item.Kind=="Uniform" and "♙" or item.Kind=="Effect" and "✦" or "♪",item.Color and Color3.fromRGB(unpack(item.Color)) or C.gold)
   local buyButton=button(f,owned and (eq and "Unequip" or "Equip") or tostring(item.Gems or item.Price)..currency,12,130,234,34,function() command(owned and "Equip" or "Buy",item.Id) end)
   if not owned and (item.Gems and snapshot.Gems or snapshot.Coins)<(item.Gems or item.Price) then disabled(buyButton,"Need "..tostring(item.Gems or item.Price)..currency) end
  end
 
elseif currentTab=="Travel" then
  local travel=snapshot.Travel
  if travel then
   tile("CITY SHUTTLE",travel.Riding and "You are riding. Ingredients can travel with you." or travel.AtStop and ("Board here • "..travel.Fare.." Coins per rider") or "Walk to a BUS sign, then choose a destination.","Bus",C.mint)
   for _,stop in ipairs(travel.Stops) do
    local here=travel.Nearest==stop.Id and travel.AtStop
    local f=tile(stop.Name,here and "You are at this stop." or "Shared shuttles carry up to 4 riders.","Bus",C.gold)
    local rideButton=button(f,here and "CURRENT STOP" or "Ride • "..travel.Fare.." Coins",12,130,234,34,function() if not here then command("Travel",stop.Id) end end)
    if here then disabled(rideButton,"You are here") elseif travel.Riding then disabled(rideButton,"On the way…") elseif not travel.AtStop then disabled(rideButton,"Go to a bus stop") elseif snapshot.Coins<travel.Fare then disabled(rideButton,"Need "..travel.Fare.." Coins") end
   end
  end
 elseif currentTab=="Staff" then
  for _,item in ipairs(snapshot.WorkerCatalog) do
   local hired=snapshot.Workers[item.Id]
   local descriptions={Chef="Cooks customer orders. Pick up the meal or let your waiter serve.",Waiter="Serves chef meals and offers alternatives for unavailable menus.",Technician="Fixes power, radio and shadow disturbances."}
   local f=tile(item.Name,descriptions[item.Id] or item.Description,item.Id,C.mint)
   local hireButton=button(f,hired and "EMPLOYED" or "Hire • Shop $"..item.Price,12,130,234,34,function() if not hired then command("Hire",item.Id) end end)
   if hired then disabled(hireButton,"On your team") elseif not snapshot.Owner then disabled(hireButton,"Owner only") elseif snapshot.Bank<item.Price then disabled(hireButton,"Need Shop $"..item.Price) end
  end
  for _,shop in ipairs(snapshot.Shops) do if shop.Id==snapshot.ShopId then
   for _,member in ipairs(shop.Members) do if member.Role~="Owner" then
    local roleInfo={Chef="Cooks 20% faster",Waiter="+10% on meals they serve",Technician="+$15 shop funds per repair"}
    local memberCard=tile(member.Name,member.Role.." • "..(roleInfo[member.Role] or "Earns coins per successful order"),"♙",C.mint)
    -- Four buttons per row: three roles plus Kick (two taps to confirm).
    local gap=6;local bw=math.floor((tileWidth-24-gap*3)/4);local by=isCompact and 150 or 144;local bh=isCompact and 52 or 34
    for i,spec in ipairs({{"Cook","Chef"},{"Serve","Waiter"},{"Repair","Technician"}}) do
     button(memberCard,spec[1],12+(i-1)*(bw+gap),by,bw,bh,function() command("Role",member.Id..":"..spec[2]) end)
    end
    local confirmUntil=0
    local kick
    kick=button(memberCard,"Kick",12+3*(bw+gap),by,bw,bh,function()
     if os.clock()>confirmUntil then
      confirmUntil=os.clock()+3;kick.Text="Sure?"
      task.delay(3,function() if kick.Parent and os.clock()>=confirmUntil then kick.Text="Kick" end end)
      return
     end
     confirmUntil=0;command("Kick",tostring(member.Id))
    end,Color3.fromRGB(236,124,106))
    kick.Name="KickMember"
    if not snapshot.Owner then disabled(kick,"Kick") end
   end end
  end end
  local f=tile("Player crew","New crew members apply at the green circle outside your restaurant. Every member earns coins on successful orders.","2–4",C.gold)
  button(f,"Return to kitchen",12,130,234,34,function() command("Teleport") end)
 elseif currentTab=="Co-op" then
  if snapshot.ShopId==0 then local f=tile("Choose a crew","You are visiting the city. Join a kitchen below to start working.","2–4",C.gold) end
  for _,shop in ipairs(snapshot.Shops) do
   local members={};for _,p in ipairs(shop.Members) do table.insert(members,p.Name.." ("..p.Role..")") end
   local current=shop.Id==snapshot.ShopId
   local f=tile("Kitchen "..shop.Id.." • "..shop.Count.."/4",shop.Owner~="" and (shop.Owner.."'s kitchen\n"..table.concat(members,", ")) or "Vacant kitchen",current and "✓" or "♙",C.mint)
   local joinButton=button(f,current and "Your crew" or shop.Locked and "Locked" or "Join crew",12,130,234,34,function() if not current then command("Join",shop.Id) end end)
   local half=(tileWidth-36)/2
   joinButton.Size=UDim2.fromOffset(half,isCompact and 56 or 34);joinButton.Position=UDim2.fromOffset(12,isCompact and 150 or 144)
   local visit=button(f,"Visit",24+half,isCompact and 150 or 144,half,isCompact and 56 or 34,function() command("StyleVisit",shop.Id) end,C.gold)
   if shop.Owner=="" then disabled(visit,"Vacant") end
   if current then disabled(joinButton,"Your kitchen") elseif shop.Owner=="" then disabled(joinButton,"No owner yet") elseif shop.Locked then disabled(joinButton,"Private crew") elseif shop.Count>=4 then disabled(joinButton,"Crew is full") end
  end
  if snapshot.ShopId>0 and not snapshot.Owner then
   local leave=tile("Leave crew","Return to the city without joining another shop.","2–4",C.gold)
   button(leave,"Leave kitchen",12,130,234,34,function() command("Leave") end)
  end
  local f=tile("Kitchen access",snapshot.Owner and "Lock your kitchen to keep the current crew." or "Return to your own kitchen when a plot is free.","⌂",C.gold)
  button(f,snapshot.Owner and "Toggle crew lock" or "Open my own kitchen",12,130,234,34,function() command(snapshot.Owner and "Lock" or "Home") end)
 elseif currentTab=="Quests" then
  local q=snapshot.Quests
  if not q then tile("Loading quests","Please wait a moment.","✓",C.gold) else
   local day=q.Streak or 1
   local login=tile("Login streak • Day "..day.."/7","Today: "..describeReward(q.Login[day])..(day<7 and (" • Day 7: "..describeReward(q.Login[7])) or "").."\nMiss a day and the streak restarts.","✦",C.gold)
   local lb=button(login,q.LoginClaimed and "Claimed" or "Claim day "..day,12,130,234,34,function() command("LoginClaim") end)
   if q.LoginClaimed then disabled(lb,"Next reward in "..duration(q.DailyReset)) end
   for _,row in q.Daily do
    local f=tile(row.Text,math.min(row.Progress,row.Goal).." / "..row.Goal.." • "..describeReward(row).."\nDaily • new quests in "..duration(q.DailyReset),"✓",C.mint)
    local b=button(f,"Claim reward",12,130,234,34,function() command("QuestClaim",tostring(row.Index)) end)
    if row.Claimed then disabled(b,"Claimed") elseif row.Progress<row.Goal then disabled(b,"In progress") end
   end
   for _,row in q.Weekly do
    local f=tile(row.Text,math.min(row.Progress,row.Goal).." / "..row.Goal.." • "..describeReward(row).."\nWeekly • resets in "..duration(q.WeeklyReset),"✦",C.gold)
    local b=button(f,"Claim reward",12,130,234,34,function() command("QuestClaim",row.Id) end)
    if row.Claimed then disabled(b,"Claimed") elseif row.Progress<row.Goal then disabled(b,"In progress") end
   end
  end
 elseif currentTab=="Ranks" then
  renderRanks()
 elseif currentTab=="City" then
  local city=workspace:FindFirstChild("MidnightCity")
  local hour=city and city:GetAttribute("Hour") or 23
  local event=city and city:GetAttribute("Event") or "Quiet Night"
  local f=tile("City life",string.format("%02d:%02d • %s",math.floor(hour),math.floor((hour%1)*60),event),"☀",C.gold)
  button(f,snapshot.ShopId>0 and "Return to kitchen" or "City spawn",12,130,234,34,function() command("Teleport") end)
  tile("Population","Residents travel between homes, work, the market, clinic and park.","♙",C.mint)
  tile("City events","Lunch Rush adds 20% shop income. Bus arrivals bring visitors. Weather and time change.","✦",C.gold)
  local f2=tile("Emotes","Equip an emote from the store, then perform it here.","♪",C.mint)
  button(f2,"Perform emote",12,130,234,34,function() command("Emote") end)
  courierTile()

 end
 localizeTree(gui)
 content.CanvasPosition=scroll
end
for i,name in ipairs({"Overview","Staff","Quests","Store","Robux","More","Journey","Travel"}) do
 local info=tabInfo[name]
 local destination=name
 local b=button(nav,"",0,0,170,44,function() selectTab(destination) end,C.panel);b.Name="Nav_"..destination;b:SetAttribute("Destination",destination);b.LayoutOrder=i
 local badge=icon(b,info[2],C.mint);badge.Name="NavigationIcon";badge.Position=UDim2.fromOffset(12,8)
 local iconScale=Instance.new("UIScale");iconScale.Scale=.66;iconScale.Parent=badge
 local navLabel=label(b,info[1],48,0,115,44,14,C.white);navLabel.Name="NavigationLabel"
 local bar=Instance.new("Frame");bar.Name="SelectionBar";bar.AnchorPoint=Vector2.new(0,.5);bar.Position=UDim2.new(0,1,.5,0);bar.Size=UDim2.fromOffset(4,28);bar.BackgroundColor3=C.gold;bar.BorderSizePixel=0;bar.Visible=false;bar.Parent=b;corner(bar)
 local outline=Instance.new("UIStroke");outline.Name="SelectionOutline";outline.Color=C.gold;outline.Thickness=1.5;outline.Transparency=1;outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;outline.Parent=b
 tabs[name]=b
end
local function closeStyleWindow()
 local event=player.PlayerGui:FindFirstChild("CloseStyleShop");if event then event:Fire() end
end
local function toggle()
 closeUpgrade();closeMall()
 if not panel.Visible then closeStyleWindow() end
 panel.Visible=not panel.Visible;dim.Visible=panel.Visible
 if panel.Visible then refresh() end
end
local close=button(panel,"×",930,20,32,34,toggle,C.panel);close.TextColor3=C.white;close.TextSize=24
local reload=button(panel,"Refresh",856,119,104,34,refresh,C.panel);reload.TextColor3=C.muted
local characterAction=button(panel,"Emote",310,20,80,44,function() command("Emote") end,C.panel)
characterAction.Name="CharacterEmote";characterAction.TextColor3=C.white
resize=function()
 local size=workspace.CurrentCamera.ViewportSize
 local touchLandscape=UIS.TouchEnabled and size.X>size.Y and size.Y<600
 if touchLandscape then
  isCompact=true
  local width,height=size.X-24,size.Y-24;characterAction.Position=UDim2.fromOffset(190,8);panel.Size=UDim2.fromOffset(width,height);scale.Scale=1
  title.Position=UDim2.fromOffset(16,10);title.Size=UDim2.fromOffset(170,28);tagline.Visible=false
  close.Position=UDim2.fromOffset(width-52,6);close.Size=UDim2.fromOffset(44,44)
  for i,key in ipairs({"Bank","Coins","Gems"}) do local f=wallets[key].frame
   f.Position=UDim2.fromOffset(width-326+(i-1)*88,6);f.Size=UDim2.fromOffset(82,48)
  end
  nav.Position=UDim2.fromOffset(12,64);nav.Size=UDim2.fromOffset(136,height-76)
  nav.AutomaticCanvasSize=Enum.AutomaticSize.Y;nav.ScrollingDirection=Enum.ScrollingDirection.Y;navLayout.FillDirection=Enum.FillDirection.Vertical
  for _,b in pairs(tabs) do b.Size=UDim2.fromOffset(128,48);b.NavigationIcon.Visible=false
   b.NavigationLabel.Position=UDim2.fromOffset(10,0);b.NavigationLabel.Size=UDim2.fromOffset(116,48)
  end
  local available=width-176
  heading.Position=UDim2.fromOffset(160,64);heading.Size=UDim2.fromOffset(available,28)
  subtitle.Position=UDim2.fromOffset(160,94);subtitle.Size=UDim2.fromOffset(available,36)
  tileWidth=available-12;layout.CellSize=UDim2.fromOffset(tileWidth,214)
  content.Position=UDim2.fromOffset(160,136);content.Size=UDim2.fromOffset(available,height-160)
  message.Position=UDim2.fromOffset(160,height-24);message.Size=UDim2.fromOffset(available,24);reload.Visible=false
  if snapshot then render() end
  return
 end
 title.Size=UDim2.fromOffset(380,32)
 local compact=size.X<720
 isCompact=compact
 local width=compact and 450 or 980
 local height=compact and math.clamp(450*size.Y/math.max(size.X,1)-24,620,900) or 650
 panel.Size=UDim2.fromOffset(width,height)
 scale.Scale=math.min(1,(size.X-24)/width,(size.Y-24)/height)
 characterAction.Position=compact and UDim2.fromOffset(width-160,8) or UDim2.fromOffset(310,20)
 title.Position=UDim2.fromOffset(22,compact and 10 or 16)
 tagline.Visible=not compact
 close.Position=UDim2.fromOffset(width-(compact and 70 or 48),compact and 8 or 20)
 close.Size=UDim2.fromOffset(compact and 54 or 32,compact and 54 or 34)
 for i,key in ipairs({"Bank","Coins","Gems"}) do local f=wallets[key].frame
  f.Position=compact and UDim2.fromOffset(16+(i-1)*142,64) or UDim2.fromOffset(426+(i-1)*164,17)
  f.Size=UDim2.fromOffset(compact and 134 or 150,compact and 57 or 65)
 end
 nav.Position=compact and UDim2.fromOffset(12,134) or UDim2.fromOffset(16,116)
 nav.Size=compact and UDim2.fromOffset(112,height-188) or UDim2.fromOffset(182,470)
 nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
 nav.ScrollingDirection=Enum.ScrollingDirection.Y
 navLayout.FillDirection=Enum.FillDirection.Vertical
 for _,b in pairs(tabs) do
  b.Size=UDim2.fromOffset(compact and 104 or 170,compact and 56 or 44)
  b.NavigationIcon.Visible=not compact
  b.NavigationLabel.Position=UDim2.fromOffset(compact and 12 or 48,0)
  b.NavigationLabel.Size=UDim2.fromOffset(compact and 92 or 115,compact and 56 or 44)
 end
 heading.Position=compact and UDim2.fromOffset(136,134) or UDim2.fromOffset(210,111)
 heading.Size=UDim2.fromOffset(compact and 298 or 570,30)
 subtitle.Position=compact and UDim2.fromOffset(136,169) or UDim2.fromOffset(210,145)
 subtitle.Size=UDim2.fromOffset(compact and 298 or 730,38)
 tileWidth=compact and 286 or 364
 layout.CellSize=UDim2.fromOffset(tileWidth,compact and 214 or 190)
 content.Position=compact and UDim2.fromOffset(136,220) or UDim2.fromOffset(210,185)
 content.Size=compact and UDim2.fromOffset(298,height-274) or UDim2.fromOffset(752,407)
 message.Position=UDim2.fromOffset(22,height-44);message.Size=UDim2.fromOffset(width-44,32)
 reload.Visible=not compact
 if snapshot then render() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);resize()
openButton.Activated:Connect(toggle)
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.M then toggle()
 elseif input.KeyCode==Enum.KeyCode.Escape then
  if mallPanel.Visible then closeMall() elseif upgradePanel.Visible then closeUpgrade() elseif panel.Visible then toggle() end
 end
end)
network.Notice.OnClientEvent:Connect(function(text)
 if panel.Visible then message.Text=text end
 if upgradePanel.Visible then upgradeMessage.Text=text end
 if mallPanel.Visible then mallMessage.Text=text end
end)
player:GetAttributeChangedSignal("ShopId"):Connect(function() closeUpgrade();if mallPanel.Visible then refresh() end;if panel.Visible then task.wait(.3);refresh() end end)
local openEvent=Instance.new("BindableEvent");openEvent.Name="OpenMidnightManagement";openEvent.Parent=player.PlayerGui
openEvent.Event:Connect(function(tab)
 closeUpgrade();closeMall();closeStyleWindow()
 if tab=="Upgrade" then tab="Overview" end
 currentTab=tab=="Classic" and "Store" or destination(tabInfo[tab] and tab or "Overview");content.CanvasPosition=Vector2.zero
 if not panel.Visible then toggle() else refresh() end
end)
task.spawn(function()
 while player:GetAttribute("ShopId")==nil do task.wait(.1) end
 if player:GetAttribute("ShopId")==0 then currentTab="Overview";if not panel.Visible then toggle() end end
end)
network:WaitForChild("OpenPanel").OnClientEvent:Connect(function(tab)
 if tab=="Upgrade" then
  closeStyleWindow();panel.Visible=false;dim.Visible=false
  upgradePanel.Visible=true;upgradeDim.Visible=true;upgradeMessage.Text="";upgradeContent.CanvasPosition=Vector2.zero
  refresh();return
 end
 if tab=="Mall" or tab=="Stock" then openMall();return end
 closeUpgrade();closeMall()
 if type(tab)=="string" and tab:sub(1,6)=="Photo:" then
  local event=player.PlayerGui:FindFirstChild("OpenKitchenPhoto");if event then panel.Visible=false;dim.Visible=false;event:Fire(tonumber(tab:sub(7))) end
  return
 end
 if tab=="Store" or tab=="Robux" then selectTab(tab);return end
 currentTab=destination(tabInfo[tab] and tab or "Overview");content.CanvasPosition=Vector2.zero
 if not panel.Visible then toggle() else refresh() end
end)
task.spawn(function()
 while gui.Parent do
  task.wait(mallPanel.Visible and 1 or 5)
  if (panel.Visible or upgradePanel.Visible or mallPanel.Visible) and not busy then refresh() end
  -- Walking away from the supply counter closes the mall window.
  if mallPanel.Visible and snapshot and not busy and not (snapshot.Supplies and snapshot.Supplies.NearMall) and not (snapshot.Courier and snapshot.Courier.NearMall) then closeMall() end
 end
end)
