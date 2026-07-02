local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Головна", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362534)

_G.ItemFarm = false
_G.TargetItem = nil

local ItemList = {
    "Ancient Scroll", "Blue Candy", "Caesar's Headband", "Christmas Present", "Clackers",
    "Diamond", "Dio's Diary", "Gold Coin", "Gold Umbrella", "Green Candy", "Lucky Arrow",
    "Lucky Stone Mask", "Mysterious Arrow", "Pure Rokakaka", "Quinton's Glove",
    "Red Candy", "Rib Cage of The Saint's Corpse", "Rokakaka", "Steel Ball",
    "Stone Mask", "Yellow Candy", "Zepellin's Headband", "Zeppeli's Hat"
}

local function tweenTo(target)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local tweenService = game:GetService("TweenService")
        local tween = tweenService:Create(hrp, TweenInfo.new((hrp.Position - target.Position).Magnitude / 100, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

FarmTab:CreateDropdown({
    Name = "Select Item to Farm",
    Options = ItemList,
    CurrentOption = {"--"},
    MultipleOptions = false,
    Flag = "ItemDropdown",
    Callback = function(Option)
        _G.TargetItem = (Option[1] == "--") and nil or Option[1]
    end,
})

FarmTab:CreateToggle({
    Name = "Enable Farming",
    CurrentValue = false,
    Callback = function(Value)
        _G.ItemFarm = Value
        if Value then
            task.spawn(function()
                while _G.ItemFarm do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if not _G.ItemFarm then break end
                        if v:IsA("ClickDetector") and (not _G.TargetItem or v.Parent.Name == _G.TargetItem or (v.Parent.Parent and v.Parent.Parent.Name == _G.TargetItem)) then
                            local target = v.Parent:IsA("Model") and v.Parent.PrimaryPart or v.Parent
                            if target:IsA("BasePart") then
                                tweenTo(target)
                                fireclickdetector(v)
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})
