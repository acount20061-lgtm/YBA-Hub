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

-- Список предметів
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

-- Функція плавного переміщення (Tween)
local function tweenTo(cframe)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - cframe.Position).Magnitude
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(distance / 60, Enum.EasingStyle.Linear) -- 60 це швидкість польоту
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        tween:Play()
        tween.Completed:Wait()
    end
end

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
                   
                   -- Перевіряємо, чи ввімкнено хоча б один предмет
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   -- Шукаємо ProximityPrompt (Кнопку E) замість ClickDetector
                   for _, prompt in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if prompt:IsA("ProximityPrompt") then
                           local targetPart = prompt.Parent
                           local targetModel = targetPart.Parent
                           local itemName = targetModel and targetModel.Name or targetPart.Name
                           
                           -- Перевірка імені предмета всередині моделі
                           if _G.SelectedItems[targetPart.Name] ~= nil then
                               itemName = targetPart.Name
                           end
                           
                           local shouldPickup = false
                           if _G.SelectedItems[itemName] ~= nil then
                               if not anySelected then
                                   shouldPickup = true -- Якщо нічого не вибрано, беремо все
                               else
                                   shouldPickup = _G.SelectedItems[itemName] -- Якщо вибрано, перевіряємо чи увімкнено
                               end
                           end
                           
                           if shouldPickup and targetPart:IsA("BasePart") then
                               itemFound = true
                               
                               -- Твінимося до предмета (висота +1.5 щоб зручно підняти)
                               tweenTo(targetPart.CFrame * CFrame.new(0, 1.5, 0))
                               task.wait(0.2)
                               
                               -- Імітуємо затискання кнопки підбору
                               fireproximityprompt(prompt)
                               task.wait(0.5)
                           end
                       end
                   end
                   
                   if not itemFound then
                       task.wait(0.5) -- Чекаємо, якщо предметів поки немає
                   end
               end
           end)
       end
   end,
})

FarmTab:CreateLabel("Фільтр предметів (залиш пустим щоб брати все):")

-- Сортуємо список предметів за алфавітом, щоб меню виглядало акуратно
local sortedItems = {}
for k, _ in pairs(_G.SelectedItems) do table.insert(sortedItems, k) end
table.sort(sortedItems)

-- Створюємо тогли для кожного предмета
for _, itemName in ipairs(sortedItems) do
    FarmTab:CreateToggle({
       Name = itemName,
       CurrentValue = false,
       Callback = function(Value)
           _G.SelectedItems[itemName] = Value
       end,
    })
end
