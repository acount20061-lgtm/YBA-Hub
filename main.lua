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

local function tweenTo(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - cframe.Position).Magnitude
        local duration = distance / 75
        
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        
        tween:Play()
        tween.Completed:Wait()
    end
end

FarmTab:CreateToggle({
   Name = "Enable Farming (Tween)",
   CurrentValue = false,
   Flag = "ItemFarmToggle",
   Callback = function(Value)
       _G.ItemFarm = Value
       if Value then
           task.spawn(function()
               while _G.ItemFarm do
                   local itemFound = false
                   
                   local anySelected = false
                   for _, selected in pairs(_G.SelectedItems) do
                       if selected then anySelected = true; break end
                   end
                   
                   for _, v in pairs(workspace:GetDescendants()) do
                       if _G.ItemFarm == false then break end
                       
                       local shouldPickup = false
                       if not anySelected then
                           if _G.SelectedItems[v.Name] ~= nil then shouldPickup = true end
                       else
                           if _G.SelectedItems[v.Name] == true then shouldPickup = true end
                       end
                       
                       if shouldPickup and v:IsA("BasePart") then
                           itemFound = true
                           tweenTo(v.CFrame * CFrame.new(0, 2, 0))
                           task.wait(0.3)
                           if v:FindFirstChildOfClass("ClickDetector") then
                               fireclickdetector(v:FindFirstChildOfClass("ClickDetector"))
                           elseif v:FindFirstChild("Hitbox") and v.Hitbox:FindFirstChildOfClass("ClickDetector") then
                               fireclickdetector(v.Hitbox:FindFirstChildOfClass("ClickDetector"))
                           end
                           task.wait(0.3)
                       end
                   end
                   if not itemFound then
                       task.wait(1)
                   end
               end
           end)
       end
   end,
})

for itemName, _ in pairs(_G.SelectedItems) do
    FarmTab:CreateToggle({
       Name = "Підбирати: " .. itemName,
       CurrentValue = false,
       Callback = function(Value)
           _G.SelectedItems[itemName] = Value
       end,
    })
end
