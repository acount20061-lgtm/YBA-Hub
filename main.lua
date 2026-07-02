local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA",
   LoadingTitle = "Завантаження скрипта...",
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
_G.FarmSpeed = 120 

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

-- Функція ідеально плавного польоту без тряски та провалювання під карту
local function smoothTween(targetCFrame)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid then
        -- Вимикаємо фізику гуманоїда, щоб прибрати дьоргання
        local oldPlatformStand = humanoid.PlatformStand
        humanoid.PlatformStand = true
        hrp.Anchored = true
        
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(distance / _G.FarmSpeed, Enum.EasingStyle.Linear)
        
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
        
        -- Повертаємо фізику назад після прильоту
        hrp.Anchored = false
        humanoid.PlatformStand = oldPlatformStand
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

FarmTab:CreateSlider({
   Name = "Швидкість польоту (Tween Speed)",
   Range = {50, 300},
   Increment = 10,
   CurrentValue = 120,
   Callback = function(Value)
       _G.FarmSpeed = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Увімкнути Автофарм",
   CurrentValue = false,
   Flag = "ItemFarmToggle",
   Callback = function(Value)
       _G.ItemFarm = Value
       if Value then
           task.spawn(function()
               while _G.ItemFarm do
                   local char = game.Players.LocalPlayer.Character
                   local hrp = char and char:FindFirstChild("HumanoidRootPart")
                   if not hrp then task.wait(0.5) continue end
                   
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   local targetItem = nil
                   local shortestDistance = math.huge
                   
                   -- Пошук найближчого предмету (один цикл = один точковий політ)
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent = desc.Parent
                           if parent then
                               local model = parent:IsA("Model") and parent or parent.Parent
                               
                               -- Фільтр живих гравців та NPC
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
                                       if targetPart then
                                           local dist = (hrp.Position - targetPart.Position).Magnitude
                                           if dist < shortestDistance then
                                               shortestDistance = dist
                                               targetItem = {prompt = desc, part = targetPart}
                                           end
                                       end
                                   end
                               end
                           end
                       end
                   end
                   
                   -- Якщо знайшли найближчу ціль — летимо суто до неї
                   if targetItem then
                       smoothTween(targetItem.part.CFrame * CFrame.new(0, 1.5, 0))
                       task.wait(0.1)
                       
                       targetItem.prompt.RequiresLineOfSight = false
                       fireproximityprompt(targetItem.prompt)
                       task.wait(0.25) -- Час на те, щоб предмет зник з карти
                   else
                       task.wait(0.5) -- Якщо предметів немає, просто чекаємо спавну
                   end
               end
           end)
       end
   end,
})

FarmTab:CreateLabel("Фільтр предметів (залиш пустим щоб брати все):")

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
