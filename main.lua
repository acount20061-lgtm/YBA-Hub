local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)

-- Слайдер стрибка
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

-- Налаштування фарму
_G.ItemFarm = false
_G.CollectionMode = "Back & Forth" -- Дефолтний режим зі скриншоту
_G.SafePlaceCFrame = CFrame.new(0, 500, 0) -- Початкова точка високо в небі

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

-- Кнопка для встановлення Safe Place
FarmTab:CreateButton({
   Name = "Встановити безпечне місце (Safe Place Position)",
   Callback = function()
       local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
       if hrp then
           _G.SafePlaceCFrame = hrp.CFrame
           Rayfield:Notify({Title = "Успішно!", Content = "Позицію для сховища збережено!", Duration = 3})
       end
   end,
})

-- Вибір режиму як на скриншоті "Знімок екрана 2026-07-02 164344.png"
FarmTab:CreateDropdown({
   Name = "Collection Mode",
   Options = {"Back & Forth", "Batch Collect"},
   CurrentOption = {"Back & Forth"},
   MultipleOptions = false,
   Callback = function(Option)
       _G.CollectionMode = Option[1]
   end,
})

-- Основна функція миттєвого телепорту
local function instantTeleport(targetCFrame)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

FarmTab:CreateToggle({
   Name = "Увімкнути Автофарм (Safe Mode)",
   CurrentValue = false,
   Flag = "ItemFarmToggle",
   Callback = function(Value)
       _G.ItemFarm = Value
       if Value then
           task.spawn(function()
               while _G.ItemFarm do
                   local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   if not hrp then task.wait(1) continue end

                   -- Перевіряємо фільтри
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   -- Збираємо список предметів на карті
                   local validItems = {}
                   for _, v in pairs(workspace:GetChildren()) do
                       if _G.SelectedItems[v.Name] ~= nil then
                           local shouldPickup = not anySelected or _G.SelectedItems[v.Name]
                           if shouldPickup then
                               local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChild("Handle") and v.Handle:FindFirstChildOfClass("ProximityPrompt")
                               if not prompt then
                                   for _, desc in pairs(v:GetDescendants()) do
                                       if desc:IsA("ProximityPrompt") then prompt = desc; break end
                                   end
                               end
                               local targetPart = v:IsA("BasePart") and v or v:FindFirstChild("Handle") or (prompt and prompt.Parent)
                               if prompt and targetPart then
                                   table.insert(validItems, {prompt = prompt, part = targetPart})
                               end
                           end
                       end
                   end

                   -- Логіка збору предметів
                   if #validItems > 0 then
                       if _G.CollectionMode == "Back & Forth" then
                           for _, item in ipairs(validItems) do
                               if not _G.ItemFarm then break end
                               
                               -- ТП до ітема
                               instantTeleport(item.part.CFrame * CFrame.new(0, 1.5, 0))
                               task.wait(0.15)
                               
                               -- Підбір
                               item.prompt.RequiresLineOfSight = false
                               fireproximityprompt(item.prompt)
                               task.wait(0.1)
                               
                               -- Повернення в безпечну зону
                               instantTeleport(_G.SafePlaceCFrame)
                               hrp.Anchored = true
                               task.wait(0.4) -- Кулдаун для безпеки
                           end
                       elseif _G.CollectionMode == "Batch Collect" then
                           -- Швидкий проліт по всіх ітемах за раз
                           for _, item in ipairs(validItems) do
                               if not _G.ItemFarm then break end
                               instantTeleport(item.part.CFrame * CFrame.new(0, 1.5, 0))
                               task.wait(0.1)
                               item.prompt.RequiresLineOfSight = false
                               fireproximityprompt(item.prompt)
                               task.wait(0.05)
                           end
                           -- Повернення після пачки
                           instantTeleport(_G.SafePlaceCFrame)
                           hrp.Anchored = true
                       end
                   else
                       -- Якщо предметів немає, сидимо в сейф-зоні заморожені
                       instantTeleport(_G.SafePlaceCFrame)
                       hrp.Anchored = true
                       task.wait(1)
                   end
               end
               -- Якщо вимкнули фарм — розморожуємо персонажа
               local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
               if hrp then hrp.Anchored = false end
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
