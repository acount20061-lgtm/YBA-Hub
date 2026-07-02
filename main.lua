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

local Blacklist = {}
local MaxRetries = 3

local function tweenTo(cframe)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - cframe.Position).Magnitude
        if distance < 4 then 
            hrp.CFrame = cframe
            return 
        end
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(distance / 75, Enum.EasingStyle.Linear)
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
                   
                   local anySelected = false
                   for _, isSelected in pairs(_G.SelectedItems) do
                       if isSelected then anySelected = true; break end
                   end
                   
                   -- Шукаємо всі кнопки взаємодії у грі (це дозволяє знайти предмети у будь-яких папках)
                   for _, desc in pairs(workspace:GetDescendants()) do
                       if not _G.ItemFarm then break end
                       
                       if desc:IsA("ProximityPrompt") then
                           local parent1 = desc.Parent
                           local parent2 = parent1 and parent1.Parent
                           
                           local itemNode = parent1
                           local itemName = ""
                           
                           -- Визначаємо назву предмета (через текст підказки або назву моделі)
                           if desc.ObjectText and _G.SelectedItems[desc.ObjectText] ~= nil then
                               itemName = desc.ObjectText
                           elseif parent1 and _G.SelectedItems[parent1.Name] ~= nil then
                               itemName = parent1.Name
                           elseif parent2 and _G.SelectedItems[parent2.Name] ~= nil then
                               itemName = parent2.Name
                               itemNode = parent2
                           end
                           
                           -- Якщо знайшли підходящий предмет, який ще не збирали
                           if itemName ~= "" and itemNode and not Blacklist[itemNode] then
                               local shouldPickup = not anySelected or _G.SelectedItems[itemName]
                               
                               if shouldPickup then
                                   local targetPart = parent1:IsA("BasePart") and parent1 or itemNode:FindFirstChildWhichIsA("BasePart")
                                   if targetPart then
                                       itemFound = true
                                       local retries = 0
                                       
                                       -- Спроба підібрати предмет
                                       while itemNode.Parent and retries < MaxRetries and _G.ItemFarm do
                                           tweenTo(targetPart.CFrame * CFrame.new(0, 1.8, 0))
                                           task.wait(0.2)
                                           fireproximityprompt(desc)
                                           task.wait(0.3)
                                           retries = retries + 1
                                       end
                                       
                                       -- Додаємо в чорний список, щоб не зациклюватися, якщо предмет зник
                                       if itemNode.Parent then
                                           Blacklist[itemNode] = true
                                       end
                                       task.wait(0.4) -- Безпечна пауза перед наступним предметом
                                   end
                               end
                           end
                       end
                   end
                   
                   -- Якщо на мапі наразі немає жодного предмета
                   if not itemFound then
                       task.wait(1.5)
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
