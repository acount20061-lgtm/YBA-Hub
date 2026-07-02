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
_G.CollectionMode = "Back & Forth"
_G.CustomSafePlace = nil -- Сюди запишеться позиція, якщо натиснеш кнопку

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

FarmTab:CreateButton({
   Name = "Встановити безпечне місце (Safe Place Position)",
   Callback = function()
       local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
       if hrp then
           _G.CustomSafePlace = hrp.CFrame
           Rayfield:Notify({Title = "UA Hub", Content = "Кастомну позицію сховища збережено!", Duration = 3})
       end
   end,
})

FarmTab:CreateDropdown({
   Name = "Collection Mode",
   Options = {"Back & Forth", "Batch Collect"},
   CurrentOption = {"Back & Forth"},
   MultipleOptions = false,
   Callback = function(Option)
       _G.CollectionMode = Option[1]
   end,
})

local function instantTeleport(targetCFrame)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
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
                   local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   if not hrp then task.wait(0.5) continue end

                   -- Визначаємо безпечну точку (кастомна або автоматично +250 вгору)
                   local currentSafePlace = _G.CustomSafePlace or (hrp.CFrame * CFrame.new(0, 250, 0))

                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   local validItems = {}
                   
                   -- Повний глибокий пошук по карті
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent = desc.Parent
                           if parent then
                               local model = parent:IsA("Model") and parent or parent.Parent
                               
                               -- ЖОРСТКИЙ ФІЛЬТР: якщо це NPC або інший гравець (має Humanoid) — ігноруємо повністю!
                               if model and model:IsA("Model") and (model:FindFirstChildOfClass("Humanoid") or parent:FindFirstChildOfClass("Humanoid")) then
                                   continue
                               end
                               
                               -- Визначаємо назву ітема за трьома параметрами
                               local itemName = ""
                               if _G.SelectedItems[parent.Name] ~= nil then
                                   itemName = parent.Name
                               elseif model and _G.SelectedItems[model.Name] ~= nil then
                                   itemName = model.Name
                               elseif desc.ObjectText and _G.SelectedItems[desc.ObjectText] ~= nil then
                                   itemName = desc.ObjectText
                               end
                               
                               if itemName ~= "" then
                                   local shouldPickup = not anySelected or _G.SelectedItems[itemName]
                                   if shouldPickup then
                                       local targetPart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart") or (model and model:FindFirstChildWhichIsA("BasePart"))
                                       if targetPart then
                                           table.insert(validItems, {prompt = desc, part = targetPart})
                                       end
                                   end
                               end
                           end
                       end
                   end

                   -- Процес збору предметів
                   if #validItems > 0 then
                       if _G.CollectionMode == "Back & Forth" then
                           for _, item in ipairs(validItems) do
                               if not _G.ItemFarm then break end
                               
                               -- Телепорт до предмета
                               instantTeleport(item.part.CFrame * CFrame.new(0, 1.5, 0))
                               task.wait(0.12)
                               
                               -- Миттєвий підбір без перевірки стін (Bypass)
                               item.prompt.RequiresLineOfSight = false
                               fireproximityprompt(item.prompt)
                               task.wait(0.08)
                               
                               -- Повернення в безпечну зону
                               instantTeleport(currentSafePlace)
                               hrp.Anchored = true
                               task.wait(0.3)
                           end
                       elseif _G.CollectionMode == "Batch Collect" then
                           for _, item in ipairs(validItems) do
                               if not _G.ItemFarm then break end
                               instantTeleport(item.part.CFrame * CFrame.new(0, 1.5, 0))
                               task.wait(0.1)
                               item.prompt.RequiresLineOfSight = false
                               fireproximityprompt(item.prompt)
                               task.wait(0.05)
                           end
                           instantTeleport(currentSafePlace)
                           hrp.Anchored = true
                       end
                   else
                       -- Якщо предметів немає, сидимо заморожені в безпечній точці
                       instantTeleport(currentSafePlace)
                       hrp.Anchored = true
                       task.wait(1)
                   end
               end
               -- Розморозка після вимкнення скрипта
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
