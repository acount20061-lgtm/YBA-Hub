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
_G.FarmSpeed = 120 -- Початкова швидкість польоту

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

local function tweenTo(cframe)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - cframe.Position).Magnitude
        if distance < 2 then 
            hrp.CFrame = cframe
            return 
        end
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(distance / _G.FarmSpeed, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Налаштування швидкості польоту прямо в GUI
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
                   local itemFound = false
                   
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   -- Перевіряємо ТІЛЬКИ поверхню мапи (без заглядання всередину гравців чи стін)
                   for _, v in pairs(workspace:GetChildren()) do
                       if not _G.ItemFarm then break end
                       
                       if _G.SelectedItems[v.Name] ~= nil then
                           local shouldPickup = not anySelected or _G.SelectedItems[v.Name]
                           
                           if shouldPickup then
                               -- Шукаємо кнопку підбору СУТО всередині знайденої моделі предмета
                               local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                               if not prompt then
                                   for _, desc in pairs(v:GetDescendants()) do
                                       if desc:IsA("ProximityPrompt") then
                                           prompt = desc
                                           break
                                       end
                                   end
                               end
                               
                               local targetPart = v:IsA("BasePart") and v or v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart") or (prompt and prompt.Parent)
                               
                               if prompt and targetPart and targetPart:IsA("BasePart") then
                                   itemFound = true
                                   
                                   -- Летимо чітко на предмет
                                   tweenTo(targetPart.CFrame)
                                   task.wait(0.15)
                                   
                                   -- Обхід обмежень підбору (Bypass)
                                   prompt.RequiresLineOfSight = false
                                   prompt.MaxActivationDistance = math.huge
                                   
                                   -- Стабільна емуляція натискання кнопки "E"
                                   fireproximityprompt(prompt)
                                   task.wait(0.3)
                               end
                           end
                       end
                   end
                   
                   if not itemFound then
                       task.wait(0.5)
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
