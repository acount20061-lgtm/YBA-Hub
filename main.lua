local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "UA Killer Hub | Debug Mode",
    LoadingTitle = "Запуск...",
    ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Фарм", 4483362534)

_G.ItemFarm = false
_G.AutoSell = false
_G.SelectedItems = {["Rokakaka"] = true, ["Mysterious Arrow"] = true, ["Gold Coin"] = true}

-- AUTO SELL
task.spawn(function()
    while task.wait(10) do
        if _G.AutoSell then
            local shop = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("Shop")
            if shop then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    print("AutoSell: Знайдено NPC, телепорт...")
                    hrp.CFrame = shop.CFrame
                    task.wait(1)
                    local cd = shop:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd then fireclickdetector(cd) end
                end
            else
                print("AutoSell: Не знайдено Merchant/Shop у Workspace!")
            end
        end
    end
end)

-- FARM
task.spawn(function()
    while task.wait(0.5) do
        if _G.ItemFarm then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local closestItem = nil
            local minDistance = math.huge
            
            -- Пошук предметів
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and _G.SelectedItems[v.ObjectText] then
                    local part = v.Parent:IsA("BasePart") and v.Parent or v.Parent.Parent
                    if part:IsA("BasePart") then
                        local d = (hrp.Position - part.Position).Magnitude
                        if d < minDistance then
                            minDistance = d
                            closestItem = {part = part, prompt = v}
                        end
                    end
                end
            end
            
            if closestItem then
                print("Farm: Знайдено предмет, дистанція: " .. math.floor(minDistance))
                hrp.CFrame = closestItem.part.CFrame
                task.wait(0.3)
                fireproximityprompt(closestItem.prompt)
                task.wait(0.5)
                -- Нічого не повертаємо, стоїмо на місці
            else
                print("Farm: Предметів у списку не знайдено.")
            end
        end
    end
end)

-- UI
FarmTab:CreateToggle({Name = "Автофарм (активний)", Callback = function(v) _G.ItemFarm = v end})
FarmTab:CreateToggle({Name = "Автопродаж (10с)", Callback = function(v) _G.AutoSell = v end})
