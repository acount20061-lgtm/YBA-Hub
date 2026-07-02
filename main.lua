local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)

-- Налаштування висоти стрибка
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

-- Логіка автофарму
_G.ItemFarm = false
_G.FarmSpeed = 120 -- Швидкість польоту за замовчуванням

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

-- Функція плавного переміщення до предмета
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

-- Слайдер швидкості польоту
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
                   
                   -- Перевірка фільтрів предметів
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   -- Глибокий пошук по карті з фільтрацією
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent = desc.Parent
                           if parent then
                               local model = parent:IsA("Model") and parent or parent.Parent
                               
                               -- ФІЛЬТР NPC ТА ГРАВЦІВ: якщо є Humanoid — це не предмет, пропускаємо!
                               if model and model:IsA("Model") and (model:FindFirstChildOfClass("Humanoid") or parent:FindFirstChildOfClass("Humanoid")) then
                                   continue
                               end
                               
                               -- Визначаємо назву предмета
                               local itemName = ""
                               if _G.SelectedItems[parent.Name] ~= nil then
                                   itemName = parent.Name
                               elseif model and _G.SelectedItems[model.Name] ~= nil then
                                   itemName = model.Name
                               elseif desc.ObjectText and _G.SelectedItems[desc.ObjectText] ~= nil then
                                   itemName = desc.ObjectText
                               end
                               
                               -- Якщо предмет підходить під критерії
                               if itemName ~= "" then
                                   local shouldPickup = not anySelected or _G.SelectedItems[itemName]
                                   
                                   if shouldPickup then
                                       local targetPart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart") or (model and model:FindFirstChildWhichIsA("BasePart"))
                                       
                                       if targetPart then
                                           itemFound = true
                                           
                                           -- Летимо безпосередньо до предмета
                                           tweenTo(targetPart.CFrame * CFrame.new(0, 1.5, 0))
                                           task.wait(0.1)
                                           
                                           -- Підбираємо
                                           desc.RequiresLineOfSight = false
                                           fireproximityprompt(desc)
                                           task.wait(0.2) -- невелика затримка, щоб предмет зник з карти
                                       end
                                   end
                               end
                           end
                       end
                   end
                   
                   -- Якщо на карті нічого немає, просто чекаємо на спавн
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
