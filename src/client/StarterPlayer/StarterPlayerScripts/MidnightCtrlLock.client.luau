-- Shift lock uses the default Roblox camera for mouse look.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Gui=game:GetService("GuiService")
local player=Players.LocalPlayer
local requested=false
local focused=true
local controlled,oldRotate,oldOffset
local active=false
local savedIcon=true
local overlay=Instance.new("ScreenGui")
overlay.Name="MidnightCtrlLock";overlay.ResetOnSpawn=false;overlay.IgnoreGuiInset=true
overlay.ScreenInsets=Enum.ScreenInsets.None;overlay.DisplayOrder=5;overlay.Parent=player:WaitForChild("PlayerGui")
local dot=Instance.new("Frame");dot.Name="AimDot";dot.AnchorPoint=Vector2.new(.5,.5)
dot.Position=UDim2.fromScale(.5,.5);dot.Size=UDim2.fromOffset(5,5)
dot.BackgroundColor3=Color3.fromRGB(255,221,155);dot.BorderSizePixel=0;dot.Visible=false;dot.Parent=overlay
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=dot
local outline=Instance.new("UIStroke");outline.Color=Color3.fromRGB(24,35,40);outline.Thickness=1;outline.Parent=dot
local function visiblePanel(name,child)
 local screen=player.PlayerGui:FindFirstChild(name)
 local panel=screen and screen:FindFirstChild(child)
 return screen and screen.Enabled and panel and panel.Visible
end
local function blocked()
 local hud=player.PlayerGui:FindFirstChild("MidnightHUD")
 return not focused or Gui.MenuIsOpen or Input:GetFocusedTextBox()~=nil
  or visiblePanel("MidnightManagement","KitchenPanel")
  or visiblePanel("MidnightStyleShop","StylePanel")
  or visiblePanel("MidnightStyleShop","PreviewControls")
  or hud and not hud.Enabled
end
local function release()
 if controlled and controlled.Parent then
  controlled.AutoRotate=oldRotate;controlled.CameraOffset=oldOffset
 end
 controlled=nil
 if active then Input.MouseBehavior=Enum.MouseBehavior.Default;Input.MouseIconEnabled=savedIcon end
 active=false;dot.Visible=false;player:SetAttribute("CtrlLockActive",false)
end
Input.InputBegan:Connect(function(key,processed)
 if processed or Input:GetFocusedTextBox() then return end
 if (key.KeyCode==Enum.KeyCode.LeftShift or key.KeyCode==Enum.KeyCode.RightShift) and Input.KeyboardEnabled and Input.MouseEnabled then
  requested=not requested;player:SetAttribute("CtrlLockRequested",requested)
  if not requested then release() end
 end
end)
Input.WindowFocusReleased:Connect(function() focused=false;release() end)
Input.WindowFocused:Connect(function() focused=true end)
player.CharacterRemoving:Connect(release)
player:SetAttribute("CtrlLockRequested",false)
player:SetAttribute("CtrlLockActive",false)
Run:BindToRenderStep("MidnightCtrlLock",Enum.RenderPriority.Camera.Value+1,function()
 local camera=workspace.CurrentCamera
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not requested or not camera or camera.CameraType~=Enum.CameraType.Custom or blocked()
  or not humanoid or humanoid.Health<=0 or humanoid.Sit or not root then release();return end
 if controlled~=humanoid then
  release();controlled=humanoid;oldRotate=humanoid.AutoRotate;oldOffset=humanoid.CameraOffset
 end
 if not active then savedIcon=Input.MouseIconEnabled end
 active=true;humanoid.AutoRotate=false
 humanoid.CameraOffset=oldOffset+Vector3.new(1.5,0,0)
 local look=camera.CFrame.LookVector;local flat=Vector3.new(look.X,0,look.Z)
 if flat.Magnitude>.001 then root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit) end
 Input.MouseBehavior=Enum.MouseBehavior.LockCenter;Input.MouseIconEnabled=false
 dot.Visible=true;player:SetAttribute("CtrlLockActive",true)
end)
script.Destroying:Connect(function() Run:UnbindFromRenderStep("MidnightCtrlLock");release();overlay:Destroy() end)
