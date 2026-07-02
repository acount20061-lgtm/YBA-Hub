-- ==============================================================================
-- UA KILLER HUB | YBA ULTIMATE FARMER | VERSION 2.0.4
-- ==============================================================================
-- Розробник: acount20061-lgtm
-- Призначення: Автоматичний збір предметів в YBA з системою анти-пасток
-- ==============================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | Ultimate YBA Farm",
   LoadingTitle = "Ініціалізація систем безпеки...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

-- ==============================================================================
-- ТАБЛИЦІ ТА ГЛОБАЛЬНІ ЗМІННІ
-- ==============================================================================

_G.ItemFarm = false
_G.AutoSell = false
_G.ItemESP = false
_G.StepDistance = 25
_G.StepDelay = 0.03

local BannedCoordinates = {}
local ESPObjects = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

_G.SelectedItems = {
    ["Ancient Scroll"] = false, ["Blue Candy"] = false, ["Caesar's Headband"] = false,
    ["Christmas Present"] = false, ["Clackers"] = false, ["Diamond"] = false,
    ["Dio's Diary"] = false, ["Gold Coin"] = false, ["Gold Umbrella"] = false,
    ["Green Candy"] = false, ["Lucky Arrow"] = false, ["Lucky Stone Mask"] = false,
    ["Mysterious Arrow"] = false, ["Pure Rokakaka"] = false, ["Quinton's Glove"] = false,
    ["Red Candy"] = false, ["Rib Cage of The Saint's Corpse"] = false, ["Rokakaka"] = false,
    ["Steel Ball"] = false, ["Stone Mask"] = false, ["Yellow Candy"] = false,
    ["Zepellin's Headband"] = false, ["Zeppeli's Hat"] = false
}

-- ==============================================================================
-- СИСТЕМА ПЕРЕВІРКИ БАНУ КООРДИНАТ (ANTI-TRAP)
-- ==============================================================================

local function IsCoordinateBanned(position)
    for _, bannedPos in pairs(BannedCoordinates) do
        if (position - bannedPos).Magnitude < 2.5 then
            return true
        end
    end
    return false
end

-- ==============================================================================
-- СИСТЕМА АВТО-ПРОДАЖУ (AUTO SELL)
-- ==============================================================================

task.spawn(function()
    while task.wait(10) do
        if _G.AutoSell then
            local merchant = Workspace:FindFirstChild("Merchant") or Workspace:FindFirstChild("Shop")
            if merchant then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local previousCFrame = rootPart.CFrame
                    
                    rootPart.CFrame = merchant.CFrame
                    task.wait(1.5)
                    
                    local clickDetector = merchant:FindFirstChildWhichIsA("ClickDetector", true)
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                    
                    task.wait(0.5)
                    rootPart.CFrame = previousCFrame
                end
            end
        end
    end
end)

-- ==============================================================================
-- СИСТЕМА ESP (VISUALIZATION)
-- ==============================================================================

task.spawn(function()
    while task.wait(1) do
        if _G.ItemESP then
            for _, descendant in pairs(Workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Parent then
                    local part = descendant.Parent:IsA("BasePart") and descendant.Parent or descendant.Parent:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 and not IsCoordinateBanned(part.Position) then
                        if not ESPObjects[part] then
                            local billboard = Instance.new("BillboardGui", part)
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            
                            local label = Instance.new("TextLabel", billboard)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.Text = descendant.ObjectText
                            label.TextColor3 = Color3.fromRGB(0, 255, 255)
                            
                            ESPObjects[part] = billboard
                        end
                    end
                end
            end
        else
            for _, obj in pairs(ESPObjects) do
                if obj then obj:Destroy() end
            end
            ESPObjects = {}
        end
    end
end)

-- ==============================================================================
-- ОСНОВНА ЛОГІКА ФАРМУ (MAIN LOOP)
-- ==============================================================================

task.spawn(function()
    while task.wait(0.2) do
        if _G.ItemFarm then
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
            local rootPart = character.HumanoidRootPart
            
            local bestItem = nil
            local minDistance = math.huge
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and _G.SelectedItems[obj.ObjectText] then
                    local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                    if parentPart and not IsCoordinateBanned(parentPart.Position) then
                        local distance = (rootPart.Position - parentPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            bestItem = {part = parentPart, prompt = obj}
                        end
                    end
                end
            end
            
            if bestItem then
                rootPart.CFrame = bestItem.part.CFrame
                task.wait(0.3)
                fireproximityprompt(bestItem.prompt)
                task.wait(0.5)
                
                -- Перевірка пастки
                if bestItem.part and bestItem.part.Parent and bestItem.part.Transparency < 1 then
                    table.insert(BannedCoordinates, bestItem.part.Position)
                end
            end
        end
    end
end)

-- ==============================================================================
-- СТВОРЕННЯ UI (INTERFACE)
-- ==============================================================================

local FarmTab = Window:CreateTab("Автофарм", 4483362534)
local MiscTab = Window:CreateTab("Налаштування", 4483362628)

FarmTab:CreateToggle({Name = "Увімкнути Автофарм", Callback = function(v) _G.ItemFarm = v end})
FarmTab:CreateToggle({Name = "Увімкнути Автопродаж", Callback = function(v) _G.AutoSell = v end})
FarmTab:CreateToggle({Name = "Увімкнути ESP", Callback = function(v) _G.ItemESP = v end})

local sorted = {}
for k in pairs(_G.SelectedItems) do table.insert(sorted, k) end
table.sort(sorted)
for _, name in pairs(sorted) do
    FarmTab:CreateToggle({Name = name, Callback = function(v) _G.SelectedItems[name] = v end})
end

MiscTab:CreateSlider({Name = "Швидкість кроку", Range = {5, 50}, CurrentValue = 25, Callback = function(v) _G.StepDistance = v end})

-- ==============================================================================
-- КІНЕЦЬ СКРИПТУ
-- ==============================================================================
