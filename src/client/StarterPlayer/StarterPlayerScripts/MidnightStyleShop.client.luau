local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Marketplace=game:GetService("MarketplaceService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local PromptService=game:GetService("ProximityPromptService")
local ChatService=game:GetService("TextChatService")
local player=Players.LocalPlayer
local network=RS:WaitForChild("MidnightNetwork")
local shared=RS:WaitForChild("MidnightStyle")
local Catalog=require(shared.StyleCatalog)
local Config=require(shared.MonetizationConfig)
local Renderer=require(shared.StyleRenderer)
local gui=Instance.new("ScreenGui");gui.Name="MidnightStyleShop";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=30;gui.Parent=player:WaitForChild("PlayerGui")
local C={bg=Color3.fromRGB(17,30,38),panel=Color3.fromRGB(29,48,56),white=Color3.fromRGB(239,241,231),mint=Color3.fromRGB(112,232,197),gold=Color3.fromRGB(255,200,102),muted=Color3.fromRGB(163,183,184)}
local function round(p) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,12);c.Parent=p end
local function text(p,s,x,y,w,h,size,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Position=UDim2.fromOffset(x,y);l.Size=UDim2.fromOffset(w,h);l.Text=s;l.TextSize=size or 15;l.TextColor3=color or C.white;l.Font=Enum.Font.GothamBold;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=p;return l
end
local cardWidth=364
local isCompact=false
local function button(p,s,x,y,w,h,fn,color,enabled)
 if p:GetAttribute("StyleCard") and isCompact then h=56;y=244 end
 local b=Instance.new("TextButton");b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,UIS.TouchEnabled and math.max(h,48) or h);b.BackgroundColor3=enabled==false and C.panel or color or C.mint;b.TextColor3=enabled==false and C.muted or C.bg;b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;b.TextSize=14;b.Text=s;b.Active=enabled~=false;b.AutoButtonColor=b.Active;b.Parent=p;round(b);if s=="Preview" then b.BackgroundColor3=C.panel;b.TextColor3=C.muted end;b.Activated:Connect(function() if b.Active then fn() end end);return b
end
local dim=Instance.new("TextButton");dim.Name="StyleBackdrop";dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new();dim.BackgroundTransparency=.25;dim.Text="";dim.AutoButtonColor=false;dim.Active=true;dim.Visible=false;dim.Parent=gui
local panel=Instance.new("Frame");panel.Name="StylePanel";panel.Active=true;panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(980,650);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel)
local scale=Instance.new("UIScale");scale.Parent=panel
text(panel,"SHOP",20,13,330,30,24)
local balance=text(panel,"",520,17,380,28,17,C.gold)
local hint=text(panel,"Preview freely. Your collection stays with your account.",20,50,880,22,13,C.muted)
local tabsFrame=Instance.new("ScrollingFrame");tabsFrame.Name="Categories";tabsFrame.BackgroundTransparency=1;tabsFrame.BorderSizePixel=0;tabsFrame.ScrollBarThickness=3;tabsFrame.ScrollingDirection=Enum.ScrollingDirection.Y;tabsFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y;tabsFrame.CanvasSize=UDim2.new();tabsFrame.Parent=panel
local tabLayout=Instance.new("UIListLayout");tabLayout.SortOrder=Enum.SortOrder.LayoutOrder;tabLayout.FillDirection=Enum.FillDirection.Vertical;tabLayout.Padding=UDim.new(0,8);tabLayout.Parent=tabsFrame
local padding=Instance.new("UIPadding");padding.PaddingTop=UDim.new(0,4);padding.PaddingLeft=UDim.new(0,4);padding.PaddingBottom=UDim.new(0,4);padding.PaddingRight=UDim.new(0,4);padding.Parent=tabsFrame
local content=Instance.new("ScrollingFrame");content.Name="Collection";content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=5;content.ScrollBarImageColor3=C.mint;content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.CanvasSize=UDim2.new();content.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(14,14);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=content
local message=text(panel,"",20,607,930,28,13,C.gold)
local previewBar=Instance.new("Frame");previewBar.Name="PreviewControls";previewBar.AnchorPoint=Vector2.new(.5,1);previewBar.Position=UDim2.new(.5,0,1,-18);previewBar.Size=UDim2.fromOffset(640,112);previewBar.BackgroundColor3=C.bg;previewBar.BorderSizePixel=0;previewBar.Visible=false;previewBar.Parent=gui;round(previewBar)
local previewScale=Instance.new("UIScale");previewScale.Parent=previewBar
local previewTitle=text(previewBar,"PREVIEW",16,8,608,25,17,C.gold)
local previewHint=text(previewBar,"Preview only. No purchase made.",16,34,608,20,12,C.muted)
local snapshot,currentTab,busy=nil,"Themes",false
local categoryUnlockAt=0
local render,refresh,open,close,preview,restore,beginCameraControls,endCameraControls
local tabButtons={}
local categories={"Packs","Gems","Themes","Outfits","Effects","Decor"}
local showMoreStyles=false
local secondaryCategories={}
local categoryLabels={Packs="Packs",Gems="GET GEMS",Themes="Themes",Outfits="Outfits",Effects="Effects",Decor="Decor"}
local categoryAliases={Staff="Outfits",Crew="Outfits",Festivals="Themes",Classic="Themes"}
local kindTab={Theme="Themes",StaffStyle="Outfits",ShopEffect="Effects",Decoration="Decor",TeamStyle="Outfits"}
local previewState
local prices={}
local function thumbnail(parent,item,width)
 local v=Instance.new("ViewportFrame");v.Size=UDim2.fromOffset(width,112);v.Position=UDim2.fromOffset(12,12);v.BackgroundColor3=Color3.fromRGB(12,22,31);v.BorderSizePixel=0;v.Ambient=Color3.fromRGB(185,185,185);v.LightColor=Color3.fromRGB(255,231,207);v.LightDirection=Vector3.new(-1,-1,-1);v.Parent=parent;round(v)
 local world=Instance.new("WorldModel");world.Parent=v
 local model=Instance.new("Model");model.Parent=world
 local function p(name,size,pos,color)
  local a=Instance.new("Part");a.Name=name;a.Size=size;a.Position=pos;a.Color=color;a.Anchored=true;a.Parent=model;return a
 end
 local theme=item.Items and nil or item
 local slots={}
 if item.Items then for _,id in item.Items do local entry=Catalog.Find(id);if entry.Kind=="Theme" then theme=entry elseif entry.Kind=="Decoration" then slots[entry.Slot]=id end end end
 if item.Kind=="Decoration" then slots[item.Slot]=item.Id end
 p("ShopFloor",Vector3.new(32,1,20),Vector3.zero,Color3.fromRGB(115,98,77))
 p("BackWall",Vector3.new(32,12,.5),Vector3.new(0,6,10),Color3.fromRGB(28,48,51))
 p("LeftWall",Vector3.new(.5,12,20),Vector3.new(-16,6,0),Color3.fromRGB(28,48,51))
 p("CounterTop",Vector3.new(24,1,3),Vector3.new(0,3,-9),Color3.fromRGB(164,130,88))
 for i,name in ipairs({"NoodleStation","RiceStation","TeaStation"}) do p(name,Vector3.new(6,2,3),Vector3.new((i-2)*9,2,4),Color3.fromRGB(65,75,82)) end
 if theme and theme.Kind=="Theme" then Renderer.Paint(model,theme) end
 Renderer.Build(model,theme and theme.Id,slots)
 local target=Vector3.new(0,3,0);local from=Vector3.new(32,25,-35)
 if item.Kind=="StaffStyle" or item.Kind=="TeamStyle" then
  for i=-1,1 do
   local c=Color3.fromRGB(unpack(item.Color))
   p("Uniform",Vector3.new(2,2.5,1),Vector3.new(i*3,2.6,-3),c)
   local head=p("Head",Vector3.new(1.4,1.4,1.4),Vector3.new(i*3,4.5,-3),Color3.fromRGB(220,181,144));head.Shape=Enum.PartType.Ball
   p("Hat",Vector3.new(1.6,i==-1 and 1 or .35,1.6),Vector3.new(i*3,5.5,-3),i==-1 and Color3.fromRGB(240,235,218) or i==1 and Color3.fromRGB(247,192,57) or c)
   p("Apron",Vector3.new(1.5,1.6,.12),Vector3.new(i*3,2.3,-3.6),Color3.fromRGB(unpack(item.Accent)))
  end
  target=Vector3.new(0,3,-3);from=Vector3.new(10,8,-18)
 elseif item.Kind=="Decoration" then
  target=item.Slot=="Patio" and Vector3.new(30,2,1) or item.Slot=="Entrance" and Vector3.new(-19,1,-7) or Vector3.new(8,7,9)
  from=target+Vector3.new(8,6,-11)
 elseif item.Kind=="ShopEffect" then
  local icon=text(parent,item.Id=="serve_hearts" and "♥" or "★",12,15,width,100,60,Color3.fromRGB(unpack(item.Color)));icon.TextXAlignment=Enum.TextXAlignment.Center;v.Visible=false
 end
 local camera=Instance.new("Camera");camera.CFrame=CFrame.lookAt(from,target);camera.FieldOfView=48;camera.Parent=v;v.CurrentCamera=camera
end
local function classicItem(id)
 if not snapshot then return nil end
 for _,list in {snapshot.Items or {},snapshot.Premium or {}} do for _,item in list do if item.Id==id then
  local copy=table.clone(item);copy.Color=copy.Color or {255,200,102};copy.Accent=copy.Color;return copy
 end end end
 return nil
end
local function getShop(id)
 return workspace.MidnightShops:FindFirstChild("Shop"..tostring(id or player:GetAttribute("ShopId") or 1)) or workspace.MidnightShops:FindFirstChild("Shop1")
end
local function isNpcLabel(instance)
 if not instance:IsA("BillboardGui") then return false end
 local node=instance.Parent
 while node and node~=workspace do
  if node:IsA("Model") and (node.Name=="Customer" or node:GetAttribute("CustomerId")~=nil or (node.Parent and (node.Parent.Name=="Employees" or node.Parent.Name=="Citizens"))) then return true end
  node=node.Parent
 end
 return false
end
local function hideNpcLabel(state,instance)
 if not isNpcLabel(instance) or state.npcLabels[instance]~=nil then return end
 state.npcLabels[instance]=instance.Enabled
 instance.Enabled=false
 local connection=instance:GetPropertyChangedSignal("Enabled"):Connect(function()
  if previewState==state and instance.Enabled then state.npcLabels[instance]=true;instance.Enabled=false end
 end)
 table.insert(state.connections,connection)
end
local function hideHud(state)
 for _,g in player.PlayerGui:GetChildren() do if g:IsA("ScreenGui") and g~=gui and state.hidden[g]==nil then state.hidden[g]=g.Enabled;g.Enabled=false end end
end
restore=function()
 local state=previewState;if not state then return end
 if endCameraControls then endCameraControls() end
 for _,connection in state.connections do connection:Disconnect() end
 for label,enabled in pairs(state.npcLabels) do if label.Parent then label.Enabled=enabled end end
 if state.bubbleConfig and state.bubbleConfig.Parent then state.bubbleConfig.Enabled=state.bubbleEnabled end
 PromptService.Enabled=state.promptsEnabled
 if state.scene then state.scene:Destroy() end
 if state.shop:GetAttribute("AppliedStyleRevision")==state.revision then
  for p,color in pairs(state.colors) do if p.Parent then p.Color=color end end
 else
  for p in pairs(state.colors) do if p.Parent and p.Parent==state.shop and p:GetAttribute("StyleBaseColor") then p.Color=p:GetAttribute("StyleBaseColor") end end
  Renderer.Paint(state.shop,Catalog.Find(state.shop:GetAttribute("AppliedStyleTheme")))
 end
 for p,value in pairs(state.localAlpha) do if p.Parent then p.LocalTransparencyModifier=value end end
 for g,enabled in pairs(state.hidden) do if g.Parent then g.Enabled=enabled end end
 workspace.CurrentCamera.CameraType=state.cameraType
 workspace.CurrentCamera.CameraSubject=state.cameraSubject
 workspace.CurrentCamera.CFrame=state.camera
 previewState=nil;previewBar.Visible=false
end
local cameraKeys={}
local function clampFocus(s)
 local delta=s.focus-s.homeFocus
 s.focus=s.homeFocus+Vector3.new(math.clamp(delta.X,-50,50),math.clamp(delta.Y,-3,30),math.clamp(delta.Z,-50,50))
end
local function cameraAngle()
 local s=previewState;if not s then return end
 s.distance=math.clamp(s.distance,8,90);s.pitch=math.clamp(s.pitch,-10,80);clampFocus(s)
 local yaw,pitch=math.rad(s.angle),math.rad(s.pitch)
 local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),-math.cos(yaw)*math.cos(pitch))*s.distance
 workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
 workspace.CurrentCamera.CFrame=CFrame.lookAt(s.focus+offset,s.focus)
 gui:SetAttribute("PhotoDistance",s.distance);gui:SetAttribute("PhotoPitch",s.pitch);gui:SetAttribute("PhotoFocus",s.focus)
end
local function resetCamera()
 local s=previewState;if not s then return end
 s.angle=30;s.pitch=23;s.distance=38;s.focus=s.homeFocus;cameraAngle()
end
local function orbit(dx,dy)
 local s=previewState;if not s then return end
 s.angle-=dx*.3;s.pitch+=dy*.25;cameraAngle()
end
local function pan(dx,dy)
 local s=previewState;if not s then return end
 local cf=workspace.CurrentCamera.CFrame
 s.focus+=(-cf.RightVector*dx+cf.UpVector*dy)*(s.distance*.002)
 cameraAngle()
end
beginCameraControls=function()
 cameraKeys={}
 CAS:BindActionAtPriority("MidnightPhotoCamera",function(_,inputState,input)
  if not previewState then return Enum.ContextActionResult.Pass end
  cameraKeys[input.KeyCode]=inputState==Enum.UserInputState.Begin or inputState==Enum.UserInputState.Change
  if input.KeyCode==Enum.KeyCode.R and inputState==Enum.UserInputState.Begin then resetCamera() end
  return Enum.ContextActionResult.Sink
 end,false,3000,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Q,Enum.KeyCode.E,Enum.KeyCode.Left,Enum.KeyCode.Right,Enum.KeyCode.Up,Enum.KeyCode.Down,Enum.KeyCode.R)
end
endCameraControls=function()
 CAS:UnbindAction("MidnightPhotoCamera");cameraKeys={}
end
UIS.InputBegan:Connect(function(input,processed)
 local s=previewState;if not s or processed then return end
 local kind=input.UserInputType
 if kind==Enum.UserInputType.MouseButton1 or kind==Enum.UserInputType.MouseButton2 or kind==Enum.UserInputType.MouseButton3 then
  s.dragMode=(kind==Enum.UserInputType.MouseButton3 or UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and "Pan" or "Orbit"
 elseif kind==Enum.UserInputType.Touch then
  s.touches[input]=Vector2.new(input.Position.X,input.Position.Y)
 end
end)
UIS.InputEnded:Connect(function(input)
 local s=previewState;if not s then return end
 if input.UserInputType==Enum.UserInputType.Touch then s.touches[input]=nil
 elseif input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 or input.UserInputType==Enum.UserInputType.MouseButton3 then s.dragMode=nil end
end)
UIS.InputChanged:Connect(function(input,processed)
 local s=previewState;if not s then return end
 if input.UserInputType==Enum.UserInputType.MouseWheel and not processed then
  s.distance*=math.exp(-input.Position.Z*.12);cameraAngle()
 elseif input.UserInputType==Enum.UserInputType.MouseMovement and s.dragMode then
  if s.dragMode=="Pan" then pan(input.Delta.X,input.Delta.Y) else orbit(input.Delta.X,input.Delta.Y) end
 elseif input.UserInputType==Enum.UserInputType.Touch and s.touches[input] then
  local count=0;for _ in s.touches do count+=1 end
  local nextPos=Vector2.new(input.Position.X,input.Position.Y);local old=s.touches[input];s.touches[input]=nextPos
  if count==1 then local delta=nextPos-old;orbit(delta.X,delta.Y) end
 end
end)
UIS.TouchPinch:Connect(function(positions,scaleValue,_,inputState,processed)
 local s=previewState;if not s or processed or #positions<2 then return end
 local center=(positions[1]+positions[2])/2
 if inputState==Enum.UserInputState.Begin then s.pinchDistance=s.distance;s.pinchCenter=center
 elseif inputState==Enum.UserInputState.Change and s.pinchDistance then
  s.distance=s.pinchDistance/math.max(.1,scaleValue)
  local delta=center-(s.pinchCenter or center);s.pinchCenter=center;pan(delta.X,delta.Y)
 else s.pinchDistance=nil;s.pinchCenter=nil end
end)
UIS.WindowFocusReleased:Connect(function() if previewState then previewState.dragMode=nil;previewState.touches={} end;cameraKeys={} end)
Run.RenderStepped:Connect(function(dt)
 local s=previewState;if not s then return end
 local cf=workspace.CurrentCamera.CFrame
 local forward=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
 if forward.Magnitude>.01 then forward=forward.Unit end
 local side=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z).Unit
 local move=Vector3.zero
 if cameraKeys[Enum.KeyCode.W] then move+=forward end
 if cameraKeys[Enum.KeyCode.S] then move-=forward end
 if cameraKeys[Enum.KeyCode.D] then move+=side end
 if cameraKeys[Enum.KeyCode.A] then move-=side end
 if cameraKeys[Enum.KeyCode.E] then move+=Vector3.yAxis end
 if cameraKeys[Enum.KeyCode.Q] then move-=Vector3.yAxis end
 if move.Magnitude>0 then s.focus+=move.Unit*math.min(dt,.1)*math.max(6,s.distance*.35) end
 if cameraKeys[Enum.KeyCode.Left] then s.angle-=dt*50 end
 if cameraKeys[Enum.KeyCode.Right] then s.angle+=dt*50 end
 if cameraKeys[Enum.KeyCode.Up] then s.pitch+=dt*35 end
 if cameraKeys[Enum.KeyCode.Down] then s.pitch-=dt*35 end
 cameraAngle()
end)
preview=function(item,photoId)
 restore()
 local shop=getShop(photoId)
 if not shop then return end
 local camera=workspace.CurrentCamera
 local s={shop=shop,colors={},localAlpha={},hidden={},cameraType=camera.CameraType,cameraSubject=camera.CameraSubject,camera=camera.CFrame,angle=30,pitch=23,distance=38,homeFocus=shop.ShopFloor.Position+Vector3.new(0,4,0),focus=shop.ShopFloor.Position+Vector3.new(0,4,0),npcLabels={},connections={},touches={},promptsEnabled=PromptService.Enabled,revision=shop:GetAttribute("AppliedStyleRevision")}
 previewState=s
 beginCameraControls()
 PromptService.Enabled=false
 if not item then
  for _,instance in workspace:GetDescendants() do if instance:IsA("BillboardGui") then hideNpcLabel(s,instance) end end
  table.insert(s.connections,workspace.DescendantAdded:Connect(function(instance)
   if instance:IsA("BillboardGui") then task.defer(function() if previewState==s and instance.Parent then hideNpcLabel(s,instance) end end) end
  end))
  local bubbles=ChatService:FindFirstChildOfClass("BubbleChatConfiguration")
  if bubbles then s.bubbleConfig=bubbles;s.bubbleEnabled=bubbles.Enabled;bubbles.Enabled=false end
 end
 hideHud(s)
 local themeId=snapshot and snapshot.Equipped.Theme or ""
 local slots={}
 if snapshot then for key,value in pairs(snapshot.Style.DecorSlots or {}) do slots[key]=value end end
 local staff
 local previewTheme
 if item then
  local entries=item.Items or {item.Id}
  for _,id in entries do local entry=Catalog.Find(id) or classicItem(id)
   if not entry then continue end
   if entry.Kind=="Theme" then themeId=id;previewTheme=entry elseif entry.Kind=="Decoration" then slots[entry.Slot]=id elseif entry.Kind=="StaffStyle" or entry.Kind=="TeamStyle" then staff=entry end
  end
  for _,p in shop:GetChildren() do if p:IsA("BasePart") then s.colors[p]=p.Color end end
  local old=shop:FindFirstChild("ShopStyle")
  if old then for _,p in old:GetDescendants() do if p:IsA("BasePart") then s.localAlpha[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end end end
  for _,stationName in {"NoodleStation","RiceStation","TeaStation"} do
   local legacy=shop:FindFirstChild("StationIcon_"..stationName)
   if legacy then for _,p in legacy:GetDescendants() do if p:IsA("BasePart") then s.localAlpha[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end end end
  end
  Renderer.Paint(shop,previewTheme or Catalog.Find(themeId))
  s.scene=Renderer.Build(shop,themeId,slots,shop,"LocalStylePreview")
  local employees=shop:FindFirstChild("Employees")
  if staff and employees then for _,p in employees:GetDescendants() do if p:IsA("BasePart") and (p.Name=="Body" or p.Name:find("Apron") or p.Name:find("Arm")) then s.colors[p]=p.Color;p.Color=Color3.fromRGB(unpack(staff.Color)) end end end
  if staff then
   for i=-1,1 do
    local dummy=Instance.new("Part");dummy.Name="PreviewUniform";dummy.Anchored=true;dummy.CanCollide=false;dummy.CanQuery=false;dummy.Size=Vector3.new(1.8,2.4,.9);dummy.Position=shop.ShopFloor.Position+Vector3.new(i*3,2.9,-2);dummy.Color=Color3.fromRGB(unpack(staff.Color));dummy.Parent=s.scene
    local head=Instance.new("Part");head.Shape=Enum.PartType.Ball;head.Size=Vector3.new(1.3,1.3,1.3);head.Anchored=true;head.CanCollide=false;head.CanQuery=false;head.Position=dummy.Position+Vector3.new(0,1.9,0);head.Color=Color3.fromRGB(220,183,146);head.Parent=s.scene
   end
  end
  if item.Kind=="ShopEffect" then
   local anchor=Instance.new("Part");anchor.Size=Vector3.new(.1,.1,.1);anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.Position=shop.CounterTop.Position+Vector3.new(0,2,0);anchor.Parent=s.scene
   local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(180,55);g.AlwaysOnTop=true;g.Parent=anchor
   local l=text(g,item.Id=="serve_hearts" and "♥  ♥  ♥" or "★  ★  ★",0,0,180,55,36,Color3.fromRGB(unpack(item.Color)));l.TextXAlignment=Enum.TextXAlignment.Center
  end
 end
 previewTitle.Text=item and ("PREVIEW · "..item.Name) or "PHOTO MODE"
 previewHint.Text=item and "Only you see this preview. Nothing has been purchased." or "Drag orbit · Shift+drag pan · Wheel zoom · WASD/QE move · R reset"
 panel.Visible=false;dim.Visible=false;previewBar.Visible=true
 cameraAngle()
end
local cameraButtons={}
local function cameraButton(name,label,fn)
 local b=button(previewBar,label,0,0,116,36,fn);b.Name=name;table.insert(cameraButtons,b);return b
end
cameraButton("OrbitLeft","Orbit left",function() if previewState then previewState.angle-=15;cameraAngle() end end)
cameraButton("OrbitRight","Orbit right",function() if previewState then previewState.angle+=15;cameraAngle() end end)
cameraButton("TiltUp","Tilt up",function() if previewState then previewState.pitch+=8;cameraAngle() end end)
cameraButton("TiltDown","Tilt down",function() if previewState then previewState.pitch-=8;cameraAngle() end end)
cameraButton("ZoomIn","Zoom in",function() if previewState then previewState.distance*=.85;cameraAngle() end end)
cameraButton("ZoomOut","Zoom out",function() if previewState then previewState.distance/=.85;cameraAngle() end end)
cameraButton("PanLeft","Pan left",function() pan(65,0) end)
cameraButton("PanRight","Pan right",function() pan(-65,0) end)
cameraButton("RaiseFocus","Move up",function() if previewState then previewState.focus+=Vector3.new(0,2,0);cameraAngle() end end)
cameraButton("LowerFocus","Move down",function() if previewState then previewState.focus-=Vector3.new(0,2,0);cameraAngle() end end)
cameraButton("ResetCamera","Reset",resetCamera)
cameraButton("Back","Back",function() restore();open(currentTab) end)
local hideUi=button(previewBar,"Hide UI (5s)",608,10,160,34,function()
 local state=previewState;previewBar.Visible=false
 task.delay(5,function() if previewState==state and state then previewBar.Visible=true end end)
end,C.gold);hideUi.Name="HideUI"
close=function() restore();panel.Visible=false;dim.Visible=false end
local function command(action,id)
 if busy then return end;busy=true;message.Text="Working…"
 local ok,result=pcall(function() return network.Command:InvokeServer(action,id) end)
 message.Text=ok and result.Message or "Connection interrupted. Try again."
 task.wait(.2);busy=false;refresh()
end
local function itemState(frame,action,owned,equipped,cost)
 local badge=Instance.new("TextLabel");badge.Name="OwnershipBadge";badge.Size=UDim2.fromOffset(112,26);badge.Position=UDim2.fromOffset(cardWidth-124,14)
 badge.Font=Enum.Font.GothamBold;badge.TextSize=11;badge.BorderSizePixel=0
 badge.BackgroundColor3=equipped and Color3.fromRGB(29,105,76) or owned and Color3.fromRGB(38,64,85) or Color3.fromRGB(82,61,27)
 badge.TextColor3=C.white;badge.Text=equipped and "✓ EQUIPPED" or owned and "OWNED" or cost and (tostring(cost).." GEMS") or "PREMIUM PACK";badge.Parent=frame;round(badge)
 if action then
  action:SetAttribute("ItemState",equipped and "Equipped" or owned and "Owned" or "Unowned")
  if action.Active then
   action.BackgroundColor3=equipped and Color3.fromRGB(147,58,66) or owned and C.mint or C.gold
   action.TextColor3=equipped and C.white or C.bg
  end
 end
end
local function priceButton(parent,item,x,y,w,pack)
 local id=pack and item.PassId or item.ProductId
 local configured=snapshot and not snapshot.Sandbox and id and id>0
 local owned=pack and snapshot.Style.PacksOwned[item.Id]
 local testing=Run:IsStudio() and Config.EnableStudioTesting and snapshot.Sandbox
 local label=owned and "Owned" or testing and "Test unlock (free)" or configured and (prices[item.Id] and "Buy · "..prices[item.Id] or "Loading price…") or "Coming soon"
 local b=button(parent,label,x,y,w,40,function() command(testing and (pack and "StyleTestPack" or "StyleTestGems") or (pack and "StylePack" or "Topup"),item.Id) end,C.gold,(configured or testing) and not owned)
 if configured and not prices[item.Id] then
  task.spawn(function()
   local ok,info=pcall(function() return Marketplace:GetProductInfoAsync(id,pack and Enum.InfoType.GamePass or Enum.InfoType.Product) end)
   if ok and info.IsForSale and info.PriceInRobux then prices[item.Id]=tostring(info.PriceInRobux).." Robux";if b.Parent then b.Text="Buy · "..prices[item.Id] end
   elseif b.Parent then b.Text="Unavailable";b.Active=false end
  end)
 end
end
local function card(item)
 local f=Instance.new("Frame");f.Name=item.Id;f:SetAttribute("StyleCard",true);f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.Parent=content;round(f)
 thumbnail(f,item,cardWidth-24)
 text(f,item.Name,12,134,cardWidth-24,28,18)
 local prefix=item.CharacterItem and "Your character · " or item.Kind=="StaffStyle" and "NPC staff · " or item.Kind=="TeamStyle" and "Player crew · " or item.Season and "Festival theme · " or ""
 text(f,prefix..(item.Description or ""),12,165,cardWidth-24,62,isCompact and 16 or 14,C.muted)
 return f
end
local function renderClassicItems()
  local items={}
  for _,item in snapshot.Items or {} do table.insert(items,item) end
  for _,item in snapshot.Premium or {} do if true then table.insert(items,item) end end
  for _,item in items do
   local group=item.Kind=="Theme" and "Themes" or item.Kind=="Uniform" and "Outfits" or "Effects"
   if currentTab~="Classic" and group~=currentTab then continue end
   local thumb=table.clone(item);thumb.CharacterItem=item.Kind=="Uniform" or item.Kind=="Effect" or item.Kind=="Emote"
   thumb.Color=thumb.Color or {255,200,102};thumb.Accent=thumb.Color
   thumb.Kind=item.Kind=="Uniform" and "StaffStyle" or (item.Kind=="Effect" or item.Kind=="Emote") and "ShopEffect" or item.Kind
   local f=card(thumb)
   local owned=snapshot.Owned[item.Id]
   local equipped=snapshot.Equipped[item.Kind]==item.Id
   local isTheme=item.Kind=="Theme"
   local half=(cardWidth-36)/2
   if isTheme then button(f,"Preview",12,238,half,40,function() preview(classicItem(item.Id)) end) end
   local price=item.Gems or item.Price or 0
   local currency=item.Gems and "Gems" or "Coins"
   local canAfford=(snapshot[currency] or 0)>=price
   local canEquip=not isTheme or snapshot.Owner
   local enabled=owned and canEquip or not owned and (canAfford or item.Gems~=nil)
   local label=owned and (equipped and "Unequip" or "Equip") or "Buy · "..tostring(price).." "..currency
   if owned and not canEquip then label="Owner only" elseif not owned and not canAfford then label=item.Gems and "Get Gems" or "Need "..price.." "..currency end
   local b=button(f,label,isTheme and 24+half or 12,238,isTheme and half or cardWidth-24,40,function() if not owned and item.Gems and not canAfford then currentTab="Gems";content.CanvasPosition=Vector2.zero;render() else command(owned and "Equip" or "Buy",item.Id) end end,C.gold,enabled==true)
   b.Name="ClassicAction";itemState(f,b,owned,equipped,item.Gems)
   if not owned and item.Gems and not canAfford then b.BackgroundColor3=Color3.fromRGB(155,119,229) end
  end

end
render=function()
 if not snapshot or not snapshot.Style then return end
 local scroll=content.CanvasPosition
 for _,f in content:GetChildren() do if f:IsA("GuiObject") then f:Destroy() end end
 hint.Text=snapshot.Sandbox and "Studio test: no Robux charged. Test purchases reset after Stop." or "Preview freely. Your collection stays with your account."
 balance.Text=tostring(snapshot.Gems).." Gems   ·   "..tostring(snapshot.Coins).." Coins"
 for name,b in pairs(tabButtons) do
  local selected=name==currentTab
  b.Visible=not secondaryCategories[name] or showMoreStyles or selected
  b.Text=categoryLabels[name] or name
  if name=="More" then b.Text=showMoreStyles and "Fewer styles" or "More styles" end
  b:SetAttribute("Selected",selected);b.BackgroundColor3=name=="Gems" and Color3.fromRGB(100,66,162) or selected and Color3.fromRGB(39,85,77) or name=="Packs" and Color3.fromRGB(94,70,31) or C.panel;b.TextColor3=selected and C.gold or C.white
  b.SelectionBar.Visible=selected;b.SelectionOutline.Transparency=selected and .15 or 1
 end
 local own=snapshot.Style.Owned;local eq=snapshot.Style.Equipped
 if currentTab=="Classic" then
  renderClassicItems()
 elseif currentTab=="Packs" then
  for _,pack in Catalog.Packs do
   local f=card(pack)
   button(f,"Preview",12,238,(cardWidth-36)/2,40,function() preview(pack) end)
   if snapshot.Style.PacksOwned[pack.Id] then
    local active=true
    for _,id in pack.Items do local entry=Catalog.Find(id)
     if entry.Kind=="Decoration" then if snapshot.Style.DecorSlots[entry.Slot]~=id then active=false end
     elseif eq[entry.Kind]~=id then active=false end
    end
    local b=button(f,active and "✓ Equipped" or "Apply pack",24+(cardWidth-36)/2,238,(cardWidth-36)/2,40,function() command("StyleApplyPack",pack.Id) end,C.mint,snapshot.Owner and not active)
    itemState(f,b,true,active)
   else priceButton(f,pack,24+(cardWidth-36)/2,238,(cardWidth-36)/2,true);itemState(f,nil,false,false) end
  end
 elseif currentTab=="Gems" then
  for _,product in snapshot.Products do
   local f=card({Id=product.Id,Name=product.Name,Kind="ShopEffect",Color={184,160,246},Description="Choose exactly what you want. Gems buy cosmetic items."})
   priceButton(f,product,12,238,cardWidth-24,false)
  end
 elseif currentTab=="Visit" then
  for _,shop in snapshot.Shops do if shop.Owner~="" then
   local f=card({Id="visit_"..shop.Id,Name=shop.Owner.."'s Kitchen",Description="Visit without joining or leaving your crew.",Kind="Theme",Color={39,72,85},Accent={112,232,197}})
   button(f,"Visit",12,238,(cardWidth-36)/2,40,function() command("StyleVisit",shop.Id);close() end)
   button(f,"Photo mode",24+(cardWidth-36)/2,238,(cardWidth-36)/2,40,function() preview(nil,shop.Id) end,C.gold)
  end end
 else
  for _,item in Catalog.Items do
   local category=kindTab[item.Kind]
   if category~=currentTab then continue end
   local f=card(item)
   local equipped=item.Kind=="Decoration" and snapshot.Style.DecorSlots[item.Slot]==item.Id or eq[item.Kind]==item.Id
   button(f,"Preview",12,238,(cardWidth-36)/2,40,function() preview(item) end)
   local label=own[item.Id] and (equipped and (item.Kind=="Decoration" and "Remove" or "Unequip") or item.Kind=="Decoration" and "Place · "..item.Slot or "Equip") or snapshot.Gems<item.Gems and "Get Gems" or "Buy · "..tostring(item.Gems).." Gems"
   local enabled=(not own[item.Id] or snapshot.Owner)==true
   local b=button(f,label,24+(cardWidth-36)/2,238,(cardWidth-36)/2,40,function()
    if not own[item.Id] and snapshot.Gems<item.Gems then currentTab="Gems";content.CanvasPosition=Vector2.zero;render()
    elseif not own[item.Id] then command("StyleBuy",item.Id)
    elseif item.Kind=="Decoration" and equipped then command("StylePlace",item.Slot..":")
    else command("StyleEquip",item.Id) end
   end,C.gold,enabled)
   itemState(f,b,own[item.Id],equipped,item.Gems)
   b.Name="ItemAction_"..item.Id
   if own[item.Id] and not snapshot.Owner then b.Text="Owned · owner only"
   elseif not own[item.Id] and snapshot.Gems<item.Gems then b.BackgroundColor3=Color3.fromRGB(155,119,229);b.TextColor3=C.bg end
  end
  if currentTab=="Outfits" then
   local f=card({Id="crew_option",Name="Your crew outfit",Description="Choose whether to wear the shop owner's team uniform.",Kind="ShopEffect",Color={112,232,197}})
   button(f,snapshot.Style.UseTeamStyle and "Team outfit: ON" or "Team outfit: OFF",12,238,cardWidth-24,40,function() command("StyleTeamOpt") end)
  end
  renderClassicItems()
 end
 content.CanvasPosition=scroll
end
local styleCache,styleCacheAt=nil,0
refresh=function(attempt)
 -- Static style catalog is cached; request it on first load and once a minute.
 local wantFull=styleCache==nil or os.clock()-styleCacheAt>60
 local ok,result=pcall(function() return network.Snapshot:InvokeServer(wantFull) end)
 if ok and result.Ready then
  local topKeys={"Items","Premium","Products","UpgradeCatalog","WorkerCatalog"}
  if result.Full and result.Style then
   styleCache={Style={Items=result.Style.Items,Packs=result.Style.Packs,Slots=result.Style.Slots},Top={}};styleCacheAt=os.clock()
   for _,k in topKeys do styleCache.Top[k]=result[k] end
  elseif styleCache and result.Style then
   for k,v in styleCache.Style do result.Style[k]=v end
   for k,v in styleCache.Top do result[k]=v end
  end
  snapshot=result;render();return
 end
 -- Server rate-limited this request: try again shortly instead of leaving the panel on "Loading".
 attempt=attempt or 0
 if ok and result.Retry and attempt<8 then task.delay(.25,function() if panel.Visible then refresh(attempt+1) end end);return end
 message.Text="Loading your collection…"
end
open=function(tab)
 local manage=player.PlayerGui:FindFirstChild("MidnightManagement")
 if manage then
  local root=manage:FindFirstChild("KitchenPanel");if root then root.Visible=false end
  local backdrop=manage:FindFirstChild("ManagementBackdrop");if backdrop then backdrop.Visible=false end
 end
 categoryUnlockAt=os.clock()+.3
 restore();tab=categoryAliases[tab] or tab;currentTab=table.find(categories,tab) and tab or "Packs";content.CanvasPosition=Vector2.zero
 panel.Visible=true;dim.Visible=true;refresh()
end
for i,name in ipairs(categories) do
 local category=name
 local b=button(tabsFrame,categoryLabels[name] or name,0,0,100,44,function()
 if os.clock()<categoryUnlockAt then return end
 if category=="More" then showMoreStyles=not showMoreStyles;render();return end
 currentTab=category;content.CanvasPosition=Vector2.zero;message.Text="";render()
 end,C.panel)
 b.Name="Category_"..category;b.LayoutOrder=i;b.TextColor3=C.white;b.TextXAlignment=Enum.TextXAlignment.Left
 local inset=Instance.new("UIPadding");inset.PaddingLeft=UDim.new(0,12);inset.Parent=b
 local bar=Instance.new("Frame");bar.Name="SelectionBar";bar.AnchorPoint=Vector2.new(0,.5);bar.Position=UDim2.new(0,-11,.5,0);bar.Size=UDim2.fromOffset(4,28);bar.BackgroundColor3=C.gold;bar.BorderSizePixel=0;bar.Visible=false;bar.Parent=b;round(bar)
 local outline=Instance.new("UIStroke");outline.Name="SelectionOutline";outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;outline.Color=C.gold;outline.Thickness=1.5;outline.Transparency=1;outline.Parent=b
 tabButtons[name]=b
end
local closeButton=button(panel,"×",926,14,38,38,close,C.panel);closeButton.TextColor3=C.white;closeButton.TextSize=24
local backManageButton=button(panel,"Back to Manage",20,598,170,40,function()
 close()
 local event=player.PlayerGui:FindFirstChild("OpenMidnightManagement")
 if event then event:Fire("Overview") end
end,C.panel)
backManageButton.Name="BackToManage";backManageButton.TextColor3=C.white
local photoButton=button(panel,"Photo mode",790,598,170,40,function() preview(nil) end)
photoButton.Visible=false
local function resize()
 local size=workspace.CurrentCamera.ViewportSize
 local touchLandscape=UIS.TouchEnabled and size.X>size.Y and size.Y<600
 if touchLandscape then
  isCompact=true
  local w,h=size.X-24,size.Y-24;panel.Size=UDim2.fromOffset(w,h);scale.Scale=1
  balance.Position=UDim2.fromOffset(w-290,16);balance.Size=UDim2.fromOffset(220,28);hint.Visible=false
  tabsFrame.Position=UDim2.fromOffset(12,64);tabsFrame.Size=UDim2.fromOffset(136,h-132)
  for _,b in pairs(tabButtons) do b.Size=UDim2.fromOffset(128,48) end
  content.Position=UDim2.fromOffset(160,64);content.Size=UDim2.fromOffset(w-176,h-132)
  cardWidth=w-188;grid.CellSize=UDim2.fromOffset(cardWidth,300)
  closeButton.Position=UDim2.fromOffset(w-52,6);closeButton.Size=UDim2.fromOffset(44,44)
  message.Position=UDim2.fromOffset(160,h-66);message.Size=UDim2.fromOffset(w-176,18)
  backManageButton.Position=UDim2.fromOffset(12,h-52);backManageButton.Size=UDim2.fromOffset(172,44)
  photoButton.Position=UDim2.fromOffset(w-184,h-52);photoButton.Size=UDim2.fromOffset(172,44)
  if snapshot then render() end
  return
 end
 local compact=size.X<720
 isCompact=compact
 local w=compact and 450 or 980;local h=compact and math.clamp(450*size.Y/math.max(size.X,1)-24,650,900) or 650
 panel.Size=UDim2.fromOffset(w,h);scale.Scale=math.min(1,(size.X-24)/w,(size.Y-24)/h)
 balance.Position=compact and UDim2.fromOffset(20,50) or UDim2.fromOffset(520,17);balance.Size=UDim2.fromOffset(compact and 400 or 380,28)
 hint.Visible=not compact
 tabsFrame.Position=UDim2.fromOffset(compact and 12 or 16,96);tabsFrame.Size=UDim2.fromOffset(compact and 112 or 182,h-(compact and 210 or 166))
 content.Position=UDim2.fromOffset(compact and 136 or 210,96);content.Size=UDim2.fromOffset(compact and 298 or 752,h-(compact and 210 or 166))
 cardWidth=compact and 286 or 364;grid.CellSize=UDim2.fromOffset(cardWidth,compact and 314 or 292)
 for _,b in pairs(tabButtons) do b.Size=UDim2.fromOffset(compact and 104 or 170,compact and 56 or 44) end
 closeButton.Position=UDim2.fromOffset(w-(compact and 70 or 54),14)
 closeButton.Size=UDim2.fromOffset(compact and 54 or 38,compact and 54 or 38)
 if compact then balance.Size=UDim2.fromOffset(330,28) end
 message.Position=compact and UDim2.fromOffset(136,h-106) or UDim2.fromOffset(210,h-57)
 message.Size=UDim2.fromOffset(compact and 298 or w-410,compact and 34 or 45)
 backManageButton.Position=UDim2.fromOffset(compact and 16 or 20,h-(compact and 68 or 52))
 backManageButton.Size=UDim2.fromOffset(compact and 206 or 170,compact and 56 or 40)
 photoButton.Position=UDim2.fromOffset(w-(compact and 222 or 190),h-(compact and 68 or 52))
 photoButton.Size=UDim2.fromOffset(compact and 206 or 170,compact and 56 or 40)
 previewBar.Size=UDim2.fromOffset(compact and 450 or 780,compact and 344 or 168)
 previewScale.Scale=math.min(1,(size.X-24)/(compact and 450 or 780))
 previewTitle.Size=UDim2.fromOffset(compact and 260 or 570,25)
 previewHint.Size=UDim2.fromOffset(compact and 418 or 748,compact and 38 or 28)
 previewHint.TextSize=compact and 14 or 12
 hideUi.Position=UDim2.fromOffset(compact and 286 or 608,8)
 hideUi.Size=UDim2.fromOffset(compact and 148 or 160,compact and 32 or 34)
 local columns=compact and 3 or 6
 local gap=8;local bw=((compact and 450 or 780)-24-(columns-1)*gap)/columns
 for i,b in ipairs(cameraButtons) do
  b.Position=UDim2.fromOffset(12+((i-1)%columns)*(bw+gap),(compact and 84 or 76)+math.floor((i-1)/columns)*(compact and 64 or 44))
  b.Size=UDim2.fromOffset(bw,compact and 56 or 36)
 end
 if snapshot then render() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);resize()
-- Backdrop clicks intentionally keep the menu open.
UIS.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.Escape then if previewState then restore();open(currentTab) else close() end end end)
local event=Instance.new("BindableEvent");event.Name="OpenStyleShop";event.Parent=player.PlayerGui;event.Event:Connect(open)
local closeEvent=Instance.new("BindableEvent");closeEvent.Name="CloseStyleShop";closeEvent.Parent=player.PlayerGui;closeEvent.Event:Connect(close)
local photoEvent=Instance.new("BindableEvent");photoEvent.Name="OpenKitchenPhoto";photoEvent.Parent=player.PlayerGui;photoEvent.Event:Connect(function(id) preview(nil,id) end)
player:GetAttributeChangedSignal("ShopId"):Connect(function() if previewState then restore() end end)
player.CharacterAdded:Connect(restore)
network.Notice.OnClientEvent:Connect(function(value) if panel.Visible then message.Text=value;task.delay(.3,refresh) end end)
local ding=game:GetService("SoundService"):WaitForChild("MK_Ding"):Clone();ding.Name="LocalStyleBell";ding.Volume=.22;ding.Parent=game:GetService("SoundService")
RS.MidnightFeedback.OnClientEvent:Connect(function(cue)
 if type(cue)=="string" and cue:sub(1,6)=="Style:" then
  local muted=false;local hud=player.PlayerGui:FindFirstChild("MidnightCityHUD")
  if hud then for _,b in hud:GetDescendants() do if b:IsA("TextButton") and b.Text:find("OFF",1,true) then muted=true end end end
  if not muted then ding.PlaybackSpeed=cue=="Style:serve_gold" and .9 or cue=="Style:serve_hearts" and 1.3 or 1.6;ding:Play() end
 end
end)
