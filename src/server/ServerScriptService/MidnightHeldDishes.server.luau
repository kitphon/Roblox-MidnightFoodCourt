local Players=game:GetService("Players")
local icons=game.ReplicatedStorage:WaitForChild("MidnightIcons")
local function watch(player)
 local connections={};local watchedState;local watchedChar;local current
 local function clear()
  if current then current:Destroy();current=nil end
 end
 local function refresh()
  local char=player.Character
  local root=char and char:FindFirstChild("HumanoidRootPart")
  local humanoid=char and char:FindFirstChildOfClass("Humanoid")
  local state=player:FindFirstChild("MidnightState")
  local food=state and state:GetAttribute("Held") or ""
  if not root or not humanoid or humanoid.Health<=0 then clear();return end
  if current and current.Parent==char and current:GetAttribute("FoodId")==food then return end
  clear()
  local template=food~="" and icons:FindFirstChild(food)
  if not template then return end
  local model=template:Clone();model.Name="MidnightHeldDish";model:SetAttribute("FoodId",food)
  model:PivotTo(root.CFrame*CFrame.new(0,.1,-2))
  local parts={}
  if model:IsA("BasePart") then table.insert(parts,model) end
  for _,part in model:GetDescendants() do if part:IsA("BasePart") then table.insert(parts,part) end end
  for _,part in parts do
   part.Anchored=false;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true
   local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=part;weld.Parent=part
  end
  current=model;model.Parent=char
 end
 local function bindState(state)
  if watchedState==state then return end;watchedState=state
  table.insert(connections,state:GetAttributeChangedSignal("Held"):Connect(refresh));refresh()
 end
 local function bindCharacter(char)
  watchedChar=char;clear()
  table.insert(connections,char.ChildAdded:Connect(refresh))
  local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",10)
  if hum then table.insert(connections,hum.Died:Connect(clear)) end
  if player.Character==char then refresh() end
 end
 table.insert(connections,player.ChildAdded:Connect(function(child) if child.Name=="MidnightState" then bindState(child) end end))
 table.insert(connections,player.CharacterAdded:Connect(bindCharacter))
 table.insert(connections,player.CharacterRemoving:Connect(clear))
 table.insert(connections,player.AncestryChanged:Connect(function()
  if player.Parent~=Players then clear();for _,connection in connections do connection:Disconnect() end end
 end))
 local state=player:FindFirstChild("MidnightState");if state then bindState(state) end
 if player.Character then task.spawn(bindCharacter,player.Character) end
end
Players.PlayerAdded:Connect(watch)
for _,player in Players:GetPlayers() do watch(player) end
