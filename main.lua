local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA Final Edition",
   LoadingTitle = "Завантаження повного функціоналу...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Автофарм", 4483362534)

_G.ItemFarm = false
_G.AutoSell = false
_G.StepDistance = 25
_G.StepDelay = 0.04

local bannedCoordinates = {}
local espObjects = {}

_G.SelectedItems = {
    ["Ancient Scroll"] = false, ["Blue Candy"] = false, ["Caesar's Headband"] = false,
    ["Christmas Present"] = false, ["Clackers"] = false, ["Diamond"] = false,
    ["Dio's Diary"] = false, ["Gold Coin"] = false, ["Gold Umbrella"] = false,
    ["Green Candy"] = false, ["Lucky Arrow"] = false, ["Lucky Stone Mask"] = false,
    ["Mysterious Arrow"] = false, ["Pure Rokakaka"] = false, ["Quinton's Glove"] = false,
    ["Red Candy"] = false, ["Rib Cage of The Saint's Corpse"] = false,
    ["Rokakaka"] = false, ["Steel Ball"] = false, ["Stone Mask"] = false,
    ["Yellow Candy"] = false, ["Zepellin's Headband"] = false, ["Zeppeli's Hat"] = false
}

-- Функція продажу
task.spawn(function()
    while true do
        task.wait(10)
        if _G.AutoSell then
            local shop = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Shop")
            if shop then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldPos = hrp.CFrame
                    hrp.CFrame = shop.CFrame
                    task.wait(1)
                    local cd = shop:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd then fireclickdetector(cd) end
                    task.wait(0.5)
                    hrp.CFrame = oldPos
                end
            end
        end
    end
end)

-- Розумний ESP (сканує все)
task.spawn(function()
    while true do
        task.wait(1)
        if _G.ItemFarm then
            for _, desc in pairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Parent then
                    local part = desc.Parent:IsA("BasePart") and desc.Parent or desc.Parent:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 then
                        local isBanned = false
                        for _, v in pairs(bannedCoordinates) do if (part.Position - v).Magnitude < 2 then isBanned = true break end end
                        if not isBanned and not espObjects[part] then
                            local bg = Instance.new("BillboardGui", part)
                            bg.AlwaysOnTop = true; bg.Size = UDim2.new(0,100,0,50)
                            local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,1,0); t.Text = desc.ObjectText
                            espObjects[part] = bg
                        end
                    end
                end
            end
        end
    end
end)

-- Основний фарм без повернення
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.ItemFarm then
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local target = nil
            local dist = math.huge
            
            for _, desc in pairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Parent then
                    local part = desc.Parent:IsA("BasePart") and desc.Parent or desc.Parent:FindFirstChildWhichIsA("BasePart")
                    if part and _G.SelectedItems[desc.ObjectText] then
                        local isBanned = false
                        for _, v in pairs(bannedCoordinates) do if (part.Position - v).Magnitude < 3 then isBanned = true break end end
                        if not isBanned then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < dist then dist = d; target = {p = part, prompt = desc} end
                        end
                    end
                end
            end
            
            if target then
                -- Рух
                hrp.CFrame = target.p.CFrame
                task.wait(0.2)
                fireproximityprompt(target.prompt)
                task.wait(0.2)
                -- Перевірка чи предмет зник
                if target.p and target.p.Parent and target.p.Transparency < 1 then
                    table.insert(bannedCoordinates, target.p.Position)
                end
            end
        end
    end
end)

-- UI
FarmTab:CreateToggle({Name = "Автофарм (без повернення)", Callback = function(v) _G.ItemFarm = v end})
FarmTab:CreateToggle({Name = "Автопродаж (кожні 10с)", Callback = function(v) _G.AutoSell = v end})

local sortedItems = {}
for k in pairs(_G.SelectedItems) do table.insert(sortedItems, k) end
table.sort(sortedItems)
for _, name in pairs(sortedItems) do
    FarmTab:CreateToggle({Name = name, Callback = function(v) _G.SelectedItems[name] = v end})
end
