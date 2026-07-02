local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA (Anti-Trap)",
   LoadingTitle = "Завантаження захисту від пасток...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)

local JP_Value = 50
task.spawn(function()
    while task.wait(0.1) do
        local p = game.Players.LocalPlayer
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.JumpPower = JP_Value
        end
    end
end)

MainTab:CreateSlider({
   Name = "Висота стрибка (JumpPower)",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
       JP_Value = Value
   end,
})

_G.ItemFarm = false
_G.ItemESP = false
_G.StepDistance = 25  
_G.StepDelay = 0.04   

local itemFails = {}
local blacklistedItems = {}
local espObjects = {}
local lastPickedCFrame = nil 

_G.SelectedItems = {
    ["Ancient Scroll"] = false,
    ["Blue Candy"] = false,
    ["Caesar's Headband"] = false,
    ["Christmas Present"] = false,
    ["Clackers"] = false,
    ["Diamond"] = false,
    ["Dio's Diary"] = false,
    ["Gold Coin"] = false,
    ["Gold Umbrella"] = false,
    ["Green Candy"] = false,
    ["Lucky Arrow"] = false,
    ["Lucky Stone Mask"] = false,
    ["Mysterious Arrow"] = false,
    ["Pure Rokakaka"] = false,
    ["Quinton's Glove"] = false,
    ["Red Candy"] = false,
    ["Rib Cage of The Saint's Corpse"] = false,
    ["Rokakaka"] = false,
    ["Steel Ball"] = false,
    ["Stone Mask"] = false,
    ["Yellow Candy"] = false,
    ["Zepellin's Headband"] = false,
    ["Zeppeli's Hat"] = false
}

-- Розумний ESP (малює тільки якщо є реальна деталь)
local function applyESP(parent, name)
    if espObjects[parent] then return end
    local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
    
    -- ЗАХИСТ: якщо деталі немає або вона повністю прозора/невидима — це фейк розробників
    if not part or part.Transparency == 1 or blacklistedItems[parent] then return end

    local bgui = Instance.new("BillboardGui")
    bgui.Name = "YBA_Item_ESP"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 120, 0, 30)
    bgui.Adornee = part

    local text = Instance.new("TextLabel")
    text.Parent = bgui
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Text = name
    text.TextColor3 = Color3.fromRGB(0, 255, 255) 
    text.TextSize = 14
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0 

    bgui.Parent = part
    espObjects[parent] = bgui
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.ItemESP then
            for _, desc in pairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Parent then
                    local parent = desc.Parent
                    local model = parent:IsA("Model") and parent or parent.Parent
                    
                    local itemName = ""
                    if _G.SelectedItems[parent.Name] ~= nil then itemName = parent.Name
                    elseif model and _G.SelectedItems[model.Name] ~= nil then itemName = model.Name
                    elseif desc.ObjectText and _G.SelectedItems[desc.ObjectText] ~= nil then itemName = desc.ObjectText end

                    if itemName ~= "" then
                        applyESP(parent, itemName)
                    end
                end
            end
        else
            for parent, gui in pairs(espObjects) do
                if gui then gui:Destroy() end
            end
            table.clear(espObjects)
        end
    end
end)

local function antiKickMove(targetCFrame)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local distance = (startPos - endPos).Magnitude
    local steps = math.floor(distance / _G.StepDistance)
    
    if steps > 0 then
        for i = 1, steps do
            if not _G.ItemFarm then break end
            local alpha = i / steps
            local nextPos = startPos:Lerp(endPos, alpha)
            
            hrp.CFrame = CFrame.new(nextPos)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            task.wait(_G.StepDelay)
        end
    end
    
    if _G.ItemFarm then
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

FarmTab:CreateSlider({
   Name = "Дистанція кроку (Step Distance)",
   Range = {5, 40},
   Increment = 1,
   CurrentValue = 25,
   Callback = function(Value)
       _G.StepDistance = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Затримка кроку (Step Delay)",
   Range = {0.01, 0.2},
   Increment = 0.01,
   CurrentValue = 0.04,
   Callback = function(Value)
       _G.StepDelay = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Увімкнути Item ESP (Підсвітка)",
   CurrentValue = false,
   Callback = function(Value)
       _G.ItemESP = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Увімкнути Автофарм (Anti-Trap)",
   CurrentValue = false,
   Flag = "ItemFarmToggle",
   Callback = function(Value)
       _G.ItemFarm = Value
       if Value then
           task.spawn(function()
               local char = game.Players.LocalPlayer.Character
               local hrp = char and char:FindFirstChild("HumanoidRootPart")
               if hrp then lastPickedCFrame = hrp.CFrame end 
               
               while _G.ItemFarm do
                   char = game.Players.LocalPlayer.Character
                   hrp = char and char:FindFirstChild("HumanoidRootPart")
                   if not hrp then task.wait(0.5) continue end
                   
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   local targetItem = nil
                   local shortestDistance = math.huge
                   
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       if blacklistedItems[desc] then continue end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent = desc.Parent
                           if parent and not blacklistedItems[parent] then
                               local model = parent:IsA("Model") and parent or parent.Parent
                               
                               if model and model:IsA("Model") and (model:FindFirstChildOfClass("Humanoid") or parent:FindFirstChildOfClass("Humanoid")) then
                                   continue
                               end
                               
                               local itemName = ""
                               if _G.SelectedItems[parent.Name] ~= nil then itemName = parent.Name
                               elseif model and _G.SelectedItems[model.Name] ~= nil then itemName = model.Name
                               elseif desc.ObjectText and _G.SelectedItems[desc.ObjectText] ~= nil then itemName = desc.ObjectText end
                               
                               if itemName ~= "" then
                                   local shouldPickup = not anySelected or _G.SelectedItems[itemName]
                                   
                                   if shouldPickup then
                                       local targetPart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart") or (model and model:FindFirstChildWhichIsA("BasePart"))
                                       
                                       -- ДОДАТКОВА ПЕРЕВІРКА НА ПАСТКУ: перевіряємо прозорість та наявність фізичної деталі
                                       if targetPart and targetPart.Transparency < 1 then
                                           local dist = (hrp.Position - targetPart.Position).Magnitude
                                           if dist < shortestDistance then
                                               shortestDistance = dist
                                               targetItem = {prompt = desc, part = targetPart, parent = parent}
                                           end
                                       else
                                           -- Якщо це фейковий напис без фізичного предмета — блеклістимо його одразу
                                           blacklistedItems[desc] = true
                                           blacklistedItems[parent] = true
                                       end
                                   end
                               end
                           end
                       end
                   end
                   
                   if targetItem then
                       local targetCFrame = targetItem.part.CFrame * CFrame.new(0, 0.5, 0)
                       antiKickMove(targetCFrame)
                       task.wait(0.1)
                       
                       targetItem.prompt.RequiresLineOfSight = false
                       fireproximityprompt(targetItem.prompt)
                       task.wait(0.3) 
                       
                       lastPickedCFrame = targetCFrame
                       
                       -- Якщо після спроби підбору напис все ще висить — кидаємо в бан
                       if targetItem.prompt and targetItem.prompt:IsDescendantOf(workspace) then
                           itemFails[targetItem.prompt] = (itemFails[targetItem.prompt] or 0) + 1
                           if itemFails[targetItem.prompt] >= 2 then
                               blacklistedItems[targetItem.prompt] = true
                               blacklistedItems[targetItem.parent] = true
                               if espObjects[targetItem.parent] then
                                   espObjects[targetItem.parent]:Destroy()
                                   espObjects[targetItem.parent] = nil
                               end
                               task.delay(30, function()
                                   blacklistedItems[targetItem.prompt] = nil
                                   blacklistedItems[targetItem.parent] = nil
                                   itemFails[targetItem.prompt] = 0
                               end)
                           end
                       end
                   else
                       if lastPickedCFrame then
                           local distToLast = (hrp.Position - lastPickedCFrame.Position).Magnitude
                           if distToLast > 5 then
                               antiKickMove(lastPickedCFrame)
                           end
                       end
                       task.wait(0.5) 
                   end
               end
           end)
       end
   end,
})

FarmTab:CreateLabel("Фільтр предметів:")

local sortedItems = {}
for k, _ in pairs(_G.SelectedItems) do table.insert(sortedItems, k) end
table.sort(sortedItems)

for _, itemName in ipairs(sortedItems) do
    FarmTab:CreateToggle({
       Name = itemName,
       CurrentValue = false,
       Callback = function(Value)
           _G.SelectedItems[itemName] = Value
       end,
    })
end
