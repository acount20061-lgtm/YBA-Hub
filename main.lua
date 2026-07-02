-- ==============================================================================
-- UA KILLER HUB | YBA ULTIMATE FARMER | PRO VERSION 3.0
-- ==============================================================================
-- Цей скрипт повністю підготовлений до роботи без повернень на базу.
-- Включає систему бан-лісту координат та автоматичний продаж.
-- ==============================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "UA Killer Hub | YBA Ultimate Edition",
   LoadingTitle = "Ініціалізація систем...",
   LoadingSubtitle = "by acount20061-lgtm",
   ConfigurationSaving = { Enabled = false }
})

-- ==============================================================================
-- ГЛОБАЛЬНІ ЗМІННІ ТА КОНФІГУРАЦІЯ
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

_G.ItemFarm = false
_G.AutoSell = false
_G.ItemESP = false
_G.StepDistance = 25
_G.StepDelay = 0.03

_G.BannedCoordinates = {}
_G.ESPObjects = {}

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
-- ДОПОМІЖНІ ФУНКЦІЇ (ENGINE)
-- ==============================================================================

local function IsCoordinateBanned(pos)
    for _, bannedPos in pairs(_G.BannedCoordinates) do
        if (pos - bannedPos).Magnitude < 2.5 then
            return true
        end
    end
    return false
end

local function GetCharacterRootPart()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart
    end
    return nil
end

-- ==============================================================================
-- СИСТЕМА АВТО-ПРОДАЖУ (AUTO SELL)
-- ==============================================================================

task.spawn(function()
    while task.wait(10) do
        if _G.AutoSell then
            local merchant = Workspace:FindFirstChild("Merchant") or Workspace:FindFirstChild("Shop")
            if merchant then
                local rootPart = GetCharacterRootPart()
                if rootPart then
                    local originalCFrame = rootPart.CFrame
                    
                    -- Телепорт до продавця
                    rootPart.CFrame = merchant.CFrame
                    task.wait(1.5)
                    
                    -- Спроба клікнути по детектору
                    local clickDetector = merchant:FindFirstChildWhichIsA("ClickDetector", true)
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                    
                    task.wait(1.0)
                    -- НЕ ПОВЕРТАЄМОСЬ НАЗАД АВТОМАТИЧНО, ЯКЩО НЕ ПОТРІБНО
                    -- Якщо хочеш повернутись, розкоментуй нижній рядок:
                    -- rootPart.CFrame = originalCFrame
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
                        if not _G.ESPObjects[part] then
                            local billboard = Instance.new("BillboardGui", part)
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            
                            local label = Instance.new("TextLabel", billboard)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.Text = descendant.ObjectText
                            label.TextColor3 = Color3.fromRGB(0, 255, 255)
                            label.BackgroundTransparency = 1
                            
                            _G.ESPObjects[part] = billboard
                        end
                    end
                end
            end
        else
            for _, obj in pairs(_G.ESPObjects) do
                if obj then obj:Destroy() end
            end
            _G.ESPObjects = {}
        end
    end
end)

-- ==============================================================================
-- ОСНОВНИЙ ЦИКЛ ФАРМУ (MAIN ENGINE)
-- ==============================================================================

task.spawn(function()
    while task.wait(0.2) do
        if _G.ItemFarm then
            local rootPart = GetCharacterRootPart()
            if not rootPart then continue end
            
            local bestItem = nil
            local minDistance = math.huge
            
            -- Пошук найближчого предмету
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
            
            -- Виконання дії
            if bestItem then
                -- Телепорт до предмета (без плавного руху, щоб не було проблем)
                rootPart.CFrame = bestItem.part.CFrame
                task.wait(0.3)
                
                -- Взаємодія
                bestItem.prompt.RequiresLineOfSight = false
                fireproximityprompt(bestItem.prompt)
                task.wait(0.5)
                
                -- Логіка перевірки пастки (якщо предмет залишився - бан)
                if bestItem.part and bestItem.part.Parent and bestItem.part.Transparency < 1 then
                    table.insert(_G.BannedCoordinates, bestItem.part.Position)
                end
                
                -- ТУТ МИ НЕ РОБИМО НІЯКИХ "RETURN TO PARKING"
                -- Персонаж залишається на місці підбору
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

-- Фільтр предметів
local sorted = {}
for k in pairs(_G.SelectedItems) do table.insert(sorted, k) end
table.sort(sorted)
for _, name in pairs(sorted) do
    FarmTab:CreateToggle({Name = name, Callback = function(v) _G.SelectedItems[name] = v end})
end

MiscTab:CreateSlider({Name = "Швидкість кроку (для інших функцій)", Range = {5, 50}, CurrentValue = 25, Callback = function(v) _G.StepDistance = v end})

-- ==============================================================================
-- LOGS & TERMINATION
-- ==============================================================================

print("UA Killer Hub Loaded Successfully")
-- Цей код автоматично видаляє всі зайві прив'язки до локації
_G.BannedCoordinates = {}
