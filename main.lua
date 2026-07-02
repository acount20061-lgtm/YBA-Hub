local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA (Anti-Kick)",
   LoadingTitle = "Завантаження обходу...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
 })

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)

-- Налаштування стрибка
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

-- Глобальні налаштування обходу античиту
_G.ItemFarm = false
_G.StepDistance = 15  -- Довжина одного мікро-телепорту
_G.StepDelay = 0.05   -- Затримка між кроками (в секундах)

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

-- Функція покрокового переміщення для обходу античиту
local function antiKickMove(targetCFrame)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local distance = (startPos - endPos).Magnitude
    
    -- Рахуємо скільки мікро-кроків треба зробити
    local steps = math.floor(distance / _G.StepDistance)
    
    if steps > 0 then
        for i = 1, steps do
            if not _G.ItemFarm then break end
            
            local alpha = i / steps
            local nextPos = startPos:Lerp(endPos, alpha)
            
            -- Зміщуємо персонажа і скидаємо швидкість, щоб античит не думав що ми летимо
            hrp.CFrame = CFrame.new(nextPos)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            
            task.wait(_G.StepDelay) -- мікро-пауза для обману сервера
        end
    end
    
    -- Фінальний точний телепорт на предмет
    if _G.ItemFarm then
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

-- Налаштування обходу в меню
FarmTab:CreateSlider({
   Name = "Дистанція кроку (Step Distance)",
   Range = {5, 40},
   Increment = 1,
   CurrentValue = 15,
   Callback = function(Value)
       _G.StepDistance = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Затримка кроку (Step Delay)",
   Range = {0.01, 0.2},
   Increment = 0.01,
   CurrentValue = 0.05,
   Callback = function(Value)
       _G.StepDelay = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Увімкнути Автофарм (Bypass Mode)",
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
                   
                   -- Пошук найближчого легітимного предмета
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent = desc.Parent
                           if parent then
                               local model = parent:IsA("Model") and parent or parent.Parent
                               
                               -- Фільтр NPC та інших гравців
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
                   
                   -- Якщо знайшли предмет — рухаємося до нього кроками
                   if targetItem then
                       antiKickMove(targetItem.part.CFrame * CFrame.new(0, 1.5, 0))
                       task.wait(0.1)
                       
                       -- Підбір предмета
                       targetItem.prompt.RequiresLineOfSight = false
                       fireproximityprompt(targetItem.prompt)
                       task.wait(0.3) -- Пауза, щоб сервер встиг зарахувати підбір предмета
                   else
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
