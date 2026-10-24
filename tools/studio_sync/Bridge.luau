-- Development plugin only. Never insert this module into the published game.
return function(plugin, config)
 local Http=game:GetService("HttpService")
 local Run=game:GetService("RunService")
 local Editor=game:GetService("ScriptEditorService")
 if game.PlaceId~=config.placeId or game.GameId~=config.gameId then return end
 local control={Stopped=false,Paused=false,SceneDirty=false,State="waiting",Connections={}}
 local toolbar=plugin:CreateToolbar("Midnight Development")
 local button=toolbar:CreateButton("MidnightSyncStatus","Pause / resume repository script sync","")
 local stopButton=toolbar:CreateButton("StopMidnightSync","Stop sync and restore prior HTTP setting","")
 button.ClickableWhenViewportHidden=true
 local function state(value,message)
  if control.State~=value then print("[Midnight Sync] "..value..(message and (": "..message) or "")) end
  control.State=value;plugin:SetAttribute("SyncState",value)
  button:SetActive(value=="synced")
 end
 local function resolve(parts)
  local node=game
  for _,name in parts do node=node:FindFirstChild(name);if not node then return end end
  return node
 end
 local known={}
 local function readSource(object)
  local ok,value=pcall(function()return Editor:GetEditorSource(object)end)
  return ok and value or object.Source
 end
 local function dirty()
  if not Run:IsRunning() then control.SceneDirty=true end
 end
 local function watch(node)
  if node:IsA("LuaSourceContainer") then return end
  table.insert(control.Connections,node.Changed:Connect(dirty))
  table.insert(control.Connections,node.AttributeChanged:Connect(dirty))
 end
 for _,entry in config.scripts do
  local object=resolve(entry.parts);if object then known[object]=true end
 end
 for _,entry in config.assets do
  local object=resolve(entry.parts)
  if object then
   watch(object)
   if not entry.shallow then
    for _,child in object:GetDescendants() do watch(child) end
    table.insert(control.Connections,object.DescendantAdded:Connect(function(child)dirty();watch(child)end))
    table.insert(control.Connections,object.DescendantRemoving:Connect(dirty))
   end
  end
 end
 function control.Stop()
  if control.Stopped then return end;control.Stopped=true
  for _,connection in control.Connections do connection:Disconnect() end
  state("stopped")
 end
 table.insert(control.Connections,plugin.Unloading:Connect(control.Stop))
 table.insert(control.Connections,stopButton.Click:Connect(control.Stop))
 table.insert(control.Connections,button.Click:Connect(function()
  control.Paused=not control.Paused;state(control.Paused and "paused" or "waiting")
 end))
 local function normalize(value)
  local text=value:gsub("\r\n","\n"):gsub("\r","\n")
  return (text:gsub("\n+$","")).."\n"
 end
 function control.Step()
  if control.Stopped then return end
  if game.PlaceId~=config.placeId or game.GameId~=config.gameId then control.Stop();return end
  if control.Paused then state("paused");return end
  local running=Run:IsRunning()
  local request={placeId=game.PlaceId,gameId=game.GameId,running=running,sceneDirty=control.SceneDirty,audit=control.Audit or 0,scripts={}}
  if not running then
   for index,entry in config.scripts do
    local object=resolve(entry.parts)
    if object and object.ClassName==entry.class then known[object]=true end
    request.scripts[tostring(index-1)]={class=object and object.ClassName or "Missing",source=object and readSource(object) or ""}
   end
   local roots={game.ServerScriptService,game.StarterPlayer.StarterPlayerScripts,game.ReplicatedStorage.MidnightStyle}
   for _,root in roots do for _,object in root:GetDescendants() do
    if object:IsA("LuaSourceContainer") and not known[object] then
     state("inventory-changed","Add the new script to the manifest before syncing.");return
    end
   end end
  end
  -- The MCP bootstrap may lack a normal installed plugin's HTTP identity.
  -- Restore the setting immediately after each request, including network failures.
  local beforeHttp=Http.HttpEnabled
  if not beforeHttp then Http.HttpEnabled=true end
  local sent,response=pcall(function()
   return Http:RequestAsync({Url="http://127.0.0.1:"..config.port.."/sync",Method="POST",
    Headers={["Content-Type"]="application/json",["X-Midnight-Sync"]=config.token},Body=Http:JSONEncode(request)})
  end)
  if not beforeHttp then Http.HttpEnabled=false end
  if not sent then error(response) end
  if not response.Success then state("error",response.Body);return end
  local result=Http:JSONDecode(response.Body)
  control.Audit=result.audit or 0
  if result.state=="conflict" then state("conflict",table.concat(result.conflicts or {},", "));return end
  for _,update in result.updates or {} do
   if Run:IsRunning() or control.Stopped then return end
   local entry=config.scripts[tonumber(update.id)+1];local object=resolve(entry.parts)
   if not object or object.ClassName~=entry.class then state("conflict","Script moved or changed class");return end
   -- Recheck in the editor's atomic callback; a new edit must never be replaced.
   local applied=false
   Editor:UpdateSourceAsync(object,function(current)
    if normalize(current)==normalize(update.base) then applied=true;return update.source end
    if normalize(current)==normalize(update.source) then applied=true end
    return current
   end)
   if not applied then state("conflict","Studio changed while applying "..entry.file);return end
  end
  state(result.state,control.SceneDirty and "Scene edits require a separate asset export" or nil)
 end
 task.spawn(function()
  while not control.Stopped do
   local ok,errorMessage=pcall(control.Step)
   if not ok then state("offline",tostring(errorMessage)) end
   task.wait(config.interval or 2)
  end
 end)
 return control
end
