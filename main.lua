local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)
local CombatTab = Window:CreateTab("Бой", 4483362615)
local TeleportTab = Window:CreateTab("Телепорти", 4483362341)

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
_G.TweenSpeed = 50

local function tweenTo(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - cframe.Position).Magnitude
        local duration = distance / _G.TweenSpeed
        
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        
        tween:Play()
        tween.Completed:Wait()
    end
end

FarmTab:CreateToggle({
   Name = "Tween Автофарм предметів",
   CurrentValue = false,
   Flag = "ItemFarmToggle",
   Callback = function(Value)
       _G.ItemFarm = Value
       if Value then
           task.spawn(function()
               while _G.ItemFarm do
                   local itemFound = false
                   for _, v in pairs(workspace:GetDescendants()) do
                       if _G.ItemFarm == false then break end
                       if (v.Name == "Mysterious Arrow" or v.Name == "Rokakaka") and v:IsA("BasePart") then
                           itemFound = true
                           tweenTo(v.CFrame * CFrame.new(0, 2, 0))
                           task.wait(0.5)
                           if v:FindFirstChildOfClass("ClickDetector") then
                               fireclickdetector(v:FindFirstChildOfClass("ClickDetector"))
                           elseif v:FindFirstChild("Hitbox") and v.Hitbox:FindFirstChildOfClass("ClickDetector") then
                               fireclickdetector(v.Hitbox:FindFirstChildOfClass("ClickDetector"))
                           end
                           task.wait(0.5)
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

FarmTab:CreateSlider({
   Name = "Швидкість Tween",
   Range = {20, 150},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(Value)
       _G.TweenSpeed = Value
   end,
})
