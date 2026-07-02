local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = loadstring(request({
	Url = "https://raw.githubusercontent.com/thatguyscousin9/personal-project2/main/YBA_UI",
	Method = "GET"
}).Body)()

local Window = Library:CreateWindow("Azero Hub")

local Info = Window:AddTab("info")
local Stand = Window:AddTab("stand")
local Items = Window:AddTab("Items")
local Fun = Window:AddTab("fun")
local Misc = Window:AddTab("misc")
local Settings = Window:AddTab("settings")

local NormalStandTargets = {}
local RibStandTargets = {}
local StopOnShinyEnabled = false
local StandFarmEnabled = false
local RibFarmEnabled = false
local PityFarmEnabled = false
local DesiredPity = 0
local PityFarmMethod = "Ribcages"
local ItemFarmEnabled = false
local ItemFarmTargets = {}
local ItemFarmMethod = "Tween"
local ActiveItemTween = nil

local ItemSpawnNotifyEnabled = false
local ItemSpawnConnection = nil
local KnownItemPrompts = {}

local PityWindow = nil
local CurrentPityLabel = nil
local WantedPityLabel = nil
local PityWindowUpdateConnection = nil

local NormalStandList = {
	"Whitesnake",
	"White Album",
	"King Crimson",
	"The World",
	"Star Platinum",
	"Crazy Diamond",
	"Gold Experience",
	"Killer Queen",
	"Magician's Red",
	"Purple Haze",
	"Sticky Fingers",
	"Mr. President",
	"Aerosmith",
	"Cream",
	"Beach Boy",
	"Red Hot Chili Pepper",
	"The Hand",
	"Anubis",
	"Stone Free",
	"Six Pistols",
	"Hermit Purple",
	"Hierophant Green",
	"Silver Chariot"
}

local RibStandList = {
	"Soft & Wet",
	"The World Alternate Universe",
	"Scary Monsters",
	"Tusk ACT 1",
	"D4C"
}


local ItemFarmList = {
	"Mysterious Arrow",
	"Rokakaka",
	"Rib Cage of The Saint's Corpse",
	"Lucky Arrow",
	"Clackers",
	"Diamond",
	"Stone Mask",
	"Caesar's Headband",
	"Pure Rokakaka",
	"Zeppeli's Hat",
	"Gold Coin",
	"Ancient Scroll",
	"Quinton's Glove",
	"Steel Ball",
	"DIO's Diary",
	"Lucky Stone Mask",
	"Christmas Present",
	"Candies",
}

local function CreateNotifier(window)
	local holder = Instance.new("Frame")
	holder.Name = "NotifyHolder"
	holder.Parent = window.Gui
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.Position = UDim2.new(1, -20, 1, -20)
	holder.Size = UDim2.new(0, 320, 0, 260)

	local layout = Instance.new("UIListLayout")
	layout.Parent = holder
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function makeCard(topText, middleText, accentColor, duration)
		local life = duration or 4

		local card = Instance.new("Frame")
		card.Parent = holder
		card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 0)
		card.BackgroundTransparency = 0
		card.ClipsDescendants = true

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Parent = card
		stroke.Color = accentColor
		stroke.Thickness = 1
		stroke.Transparency = 0.15

		local smallText = Instance.new("TextLabel")
		smallText.Parent = card
		smallText.BackgroundTransparency = 1
		smallText.Position = UDim2.new(0, 12, 0, 8)
		smallText.Size = UDim2.new(1, -24, 0, 14)
		smallText.Font = Enum.Font.Gotham
		smallText.Text = tostring(topText)
		smallText.TextSize = 10
		smallText.TextColor3 = Color3.fromRGB(150, 150, 165)
		smallText.TextXAlignment = Enum.TextXAlignment.Left
		smallText.TextTransparency = 1

		local mainText = Instance.new("TextLabel")
		mainText.Parent = card
		mainText.BackgroundTransparency = 1
		mainText.AnchorPoint = Vector2.new(0.5, 0.5)
		mainText.Position = UDim2.new(0.5, 0, 0.5, 8)
		mainText.Size = UDim2.new(1, -24, 0, 20)
		mainText.Font = Enum.Font.GothamBold
		mainText.Text = tostring(middleText)
		mainText.TextSize = 16
		mainText.TextColor3 = Color3.fromRGB(240, 240, 250)
		mainText.TextXAlignment = Enum.TextXAlignment.Center
		mainText.TextTransparency = 1

		TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 58)
		}):Play()

		TweenService:Create(smallText, TweenInfo.new(0.18), {
			TextTransparency = 0
		}):Play()

		TweenService:Create(mainText, TweenInfo.new(0.18), {
			TextTransparency = 0
		}):Play()

		task.delay(life, function()
			if not card.Parent then
				return
			end

			TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()

			TweenService:Create(smallText, TweenInfo.new(0.14), {
				TextTransparency = 1
			}):Play()

			TweenService:Create(mainText, TweenInfo.new(0.14), {
				TextTransparency = 1
			}):Play()

			task.wait(0.2)
			card:Destroy()
		end)
	end

	return {
		Notify = function(self, topText, middleText, kind, duration)
			local colors = {
				error = Color3.fromRGB(255, 95, 95),
				success = Color3.fromRGB(90, 255, 140),
				warn = Color3.fromRGB(255, 200, 90),
				info = Color3.fromRGB(90, 140, 255)
			}
			makeCard(topText, middleText, colors[kind] or colors.info, duration)
		end,
		Error = function(self, text, duration)
			makeCard("Error", text, Color3.fromRGB(255, 95, 95), duration)
		end,
		Success = function(self, text, duration)
			makeCard("Success", text, Color3.fromRGB(90, 255, 140), duration)
		end,
		Obtained = function(self, name, duration)
			makeCard("You Obtained", name, Color3.fromRGB(90, 255, 140), duration)
		end,
		ItemSpawn = function(self, name, duration)
			makeCard("An Item Has Spawn", name, Color3.fromRGB(90, 140, 255), duration)
		end
	}
end

local Notifier = CreateNotifier(Window)

local function extractNumber(text)
	local number = tostring(text):match("%d+")
	return tonumber(number) or 0
end

local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
	return getCharacter():WaitForChild("Humanoid")
end

local function getRemoteFunction()
	return getCharacter():WaitForChild("RemoteFunction")
end

local function getRemoteEvent()
	return getCharacter():WaitForChild("RemoteEvent")
end

local function getPlayerStats()
	return LocalPlayer:FindFirstChild("PlayerStats")
end

local function getCurrentPity()
	local playerStats = LocalPlayer:FindFirstChild("PlayerStats")
	if playerStats then
		local pityValue = playerStats:FindFirstChild("PityCount")
		if pityValue and tonumber(pityValue.Value) then
			return tonumber(pityValue.Value)
		end
	end

	local standShop = game:GetService("ReplicatedStorage"):FindFirstChild("Objects")
	if standShop then
		standShop = standShop:FindFirstChild("HUD")
	end
	if standShop then
		standShop = standShop:FindFirstChild("Main")
	end
	if standShop then
		standShop = standShop:FindFirstChild("Frames")
	end
	if standShop then
		standShop = standShop:FindFirstChild("Store")
	end
	if standShop then
		standShop = standShop:FindFirstChild("List")
	end
	if standShop then
		standShop = standShop:FindFirstChild("StandShop")
	end

	if standShop then
		for _, obj in ipairs(standShop:GetDescendants()) do
			local lowerName = obj.Name:lower()

			if obj:IsA("IntValue") or obj:IsA("NumberValue") then
				if lowerName:find("pity") then
					return tonumber(obj.Value) or 0
				end
			elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
				local lowerText = tostring(obj.Text):lower()

				if lowerName:find("pity") or lowerText:find("pity") then
					return extractNumber(obj.Text)
				end
			elseif obj:IsA("StringValue") then
				local lowerText = tostring(obj.Value):lower()

				if lowerName:find("pity") or lowerText:find("pity") then
					return extractNumber(obj.Value)
				end
			end
		end
	end

	return 0
end

local function getCurrentStandName()
	local stats = getPlayerStats()
	if stats then
		local directStand = stats:FindFirstChild("Stand")
		if directStand and tostring(directStand.Value) ~= "" then
			return tostring(directStand.Value)
		end

		local standName = stats:FindFirstChild("StandName")
		if standName and tostring(standName.Value) ~= "" then
			return tostring(standName.Value)
		end
	end

	local character = getCharacter()
	local morph = character:FindFirstChild("StandMorph")
	if morph then
		local standName = morph:FindFirstChild("StandName")
		if standName and tostring(standName.Value) ~= "" then
			return tostring(standName.Value)
		end
	end

	return "None"
end

local function hasStand()
	return getCurrentStandName() ~= "None"
end

local function isShinyStand()
	local character = getCharacter()
	local morph = character:FindFirstChild("StandMorph")
	if not morph then
		return false
	end

	local standSkin = morph:FindFirstChild("StandSkin")
	return standSkin and standSkin.Value ~= ""
end

local function countToolsByName(itemName)
	local total = 0
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	local character = getCharacter()

	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name == itemName then
				total = total + 1
			end
		end
	end

	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") and item.Name == itemName then
			total = total + 1
		end
	end

	return total
end

local function unequipAllTools()
	pcall(function()
		getHumanoid():UnequipTools()
	end)
end

local function holdOneTool(itemName)
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	local character = getCharacter()
	if not backpack then
		return nil
	end

	unequipAllTools()
	task.wait(0.1)

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name == itemName then
			item.Parent = character
			task.wait(0.1)
			return item
		end
	end

	return character:FindFirstChild(itemName)
end

local function toggleStand()
	pcall(function()
		getRemoteFunction():InvokeServer("ToggleStand", "Toggle")
	end)
end

local function desummonStand()
	pcall(function()
		toggleStand()
	end)
	task.wait(0.4)
end

local function acceptDialogue(npcName, dialogueName, optionName)
	pcall(function()
		getRemoteEvent():FireServer("EndDialogue", {
			Option = optionName,
			Dialogue = dialogueName,
			NPC = npcName
		})
	end)
end

local function getWorthiness()
	local tree = LocalPlayer:FindFirstChild("CharacterSkillTree")
	if not tree then
		return nil
	end

	return tree:FindFirstChild("Worthiness")
end

local function ensureWorthiness()
	local worthiness = getWorthiness()
	if not worthiness then
		return false
	end

	if worthiness.Value == true then
		return true
	end

	pcall(function()
		getRemoteFunction():InvokeServer("LearnSkill", {
			Skill = "Worthiness",
			SkillTreeType = "Character"
		})
	end)

	task.wait(0.35)
	return worthiness.Value == true
end

local function waitForStandResult(timeout)
	local started = tick()

	repeat
		task.wait(0.2)

		if StopOnShinyEnabled and isShinyStand() then
			return "Shiny"
		end

		local currentStand = getCurrentStandName()
		if currentStand ~= "None" then
			return currentStand
		end
	until tick() - started > (timeout or 6)

	return "None"
end

local function useArrow()
	local itemName = "Mysterious Arrow"
	if countToolsByName(itemName) <= 0 then
		return false
	end

	if hasStand() then
		desummonStand()
	end

	local arrow = holdOneTool(itemName)
	if not arrow then
		return false
	end

	pcall(function()
		arrow:Activate()
	end)

	task.wait(0.15)
	acceptDialogue(itemName, "Dialogue2", "Option1")
	task.wait(0.35)

	return true
end

local function useRokakaka()
	local itemName = "Rokakaka"
	if countToolsByName(itemName) <= 0 then
		return false
	end

	if hasStand() then
		desummonStand()
	end

	local roka = holdOneTool(itemName)
	if not roka then
		return false
	end

	pcall(function()
		roka:Activate()
	end)

	task.wait(0.15)
	acceptDialogue(itemName, "Dialogue2", "Option1")

	local started = tick()
	repeat
		task.wait(0.2)
	until getCurrentStandName() == "None" or tick() - started > 4

	unequipAllTools()
	return getCurrentStandName() == "None"
end

local function useRibcage()
	local itemName = "Rib Cage of The Saint's Corpse"
	local beforeCount = countToolsByName(itemName)
	if beforeCount <= 0 then
		return false
	end

	if hasStand() then
		desummonStand()
	end

	local rib = holdOneTool(itemName)
	if not rib then
		return false
	end

	pcall(function()
		rib:Activate()
	end)

	task.wait(0.15)
	acceptDialogue(itemName, "Dialogue2", "Option1")

	local started = tick()
	repeat
		task.wait(0.2)
	until countToolsByName(itemName) < beforeCount or tick() - started > 4

	unequipAllTools()
	task.wait(0.2)
	desummonStand()

	return true
end

local function hasAnySelected(tbl)
	return next(tbl) ~= nil
end

local function targetHit(tbl)
	return tbl[getCurrentStandName()] == true
end

local function stopIfTargetOrShiny(tbl)
	if StopOnShinyEnabled and isShinyStand() then
		Notifier:Obtained("Shiny " .. getCurrentStandName(), 5)
		return true
	end

	if targetHit(tbl) then
		Notifier:Obtained(getCurrentStandName(), 5)
		return true
	end

	return false
end

local function farmNormalStand()
	if StandFarmEnabled == false then
		return
	end

	if not hasAnySelected(NormalStandTargets) then
		Notifier:Error("Select a stand first", 4)
		StandFarmEnabled = false
		return
	end

	while StandFarmEnabled do
		if stopIfTargetOrShiny(NormalStandTargets) then
			StandFarmEnabled = false
			break
		end

		if not ensureWorthiness() then
			Notifier:Error("Worthiness failed", 4)
			StandFarmEnabled = false
			break
		end

		if getCurrentPity() >= DesiredPity and DesiredPity > 0 then
			Notifier:Success("Desired pity reached", 4)
			StandFarmEnabled = false
			break
		end

		if getCurrentStandName() == "None" then
			if not useArrow() then
				Notifier:Error("No arrows left", 4)
				StandFarmEnabled = false
				break
			end

			local result = waitForStandResult(6)
			if result == "Shiny" then
				Notifier:Obtained("Shiny " .. getCurrentStandName(), 5)
				StandFarmEnabled = false
				break
			end

			if targetHit(NormalStandTargets) then
				Notifier:Obtained(getCurrentStandName(), 5)
				StandFarmEnabled = false
				break
			end
		else
			if not useRokakaka() then
				Notifier:Error("No rokakaka left", 4)
				StandFarmEnabled = false
				break
			end
		end

		task.wait(0.25)
	end
end

local function farmRibStand()
	if RibFarmEnabled == false then
		return
	end

	if not hasAnySelected(RibStandTargets) then
		Notifier:Error("Select a rib stand first", 4)
		RibFarmEnabled = false
		return
	end

	while RibFarmEnabled do
		if stopIfTargetOrShiny(RibStandTargets) then
			RibFarmEnabled = false
			break
		end

		if not ensureWorthiness() then
			Notifier:Error("Worthiness failed", 4)
			RibFarmEnabled = false
			break
		end

		if not useRibcage() then
			Notifier:Error("No rib cages left", 4)
			RibFarmEnabled = false
			break
		end

		local result = waitForStandResult(6)
		if result == "Shiny" then
			Notifier:Obtained("Shiny " .. getCurrentStandName(), 5)
			RibFarmEnabled = false
			break
		end

		if targetHit(RibStandTargets) then
			Notifier:Obtained(getCurrentStandName(), 5)
			RibFarmEnabled = false
			break
		end

		if not useRokakaka() then
			Notifier:Error("No rokakaka left", 4)
			RibFarmEnabled = false
			break
		end

		task.wait(0.25)
	end
end

local function farmPity()
	if PityFarmEnabled == false then
		return
	end

	if DesiredPity <= 0 then
		Notifier:Error("Set desired pity first", 4)
		PityFarmEnabled = false
		return
	end

	local usingRibcages = PityFarmMethod == "Ribcages"
	local pityTargets = usingRibcages and RibStandTargets or NormalStandTargets

	while PityFarmEnabled do
		local currentPity = getCurrentPity()
		if currentPity >= DesiredPity then
			Notifier:Success("Desired pity reached: " .. tostring(currentPity), 4)
			PityFarmEnabled = false
			break
		end

		if StopOnShinyEnabled and isShinyStand() then
			Notifier:Obtained("Shiny " .. getCurrentStandName(), 5)
			PityFarmEnabled = false
			break
		end

		if targetHit(pityTargets) then
			Notifier:Obtained(getCurrentStandName(), 5)
			PityFarmEnabled = false
			break
		end

		if not ensureWorthiness() then
			Notifier:Error("Worthiness failed", 4)
			PityFarmEnabled = false
			break
		end

		if getCurrentStandName() == "None" then
			local usedItem = false

			if usingRibcages then
				usedItem = useRibcage()
				if not usedItem then
					Notifier:Error("No rib cages left", 4)
					PityFarmEnabled = false
					break
				end
			else
				usedItem = useArrow()
				if not usedItem then
					Notifier:Error("No arrows left", 4)
					PityFarmEnabled = false
					break
				end
			end

			waitForStandResult(6)

			if getCurrentPity() >= DesiredPity then
				Notifier:Success("Desired pity reached: " .. tostring(getCurrentPity()), 4)
				PityFarmEnabled = false
				break
			end

			if StopOnShinyEnabled and isShinyStand() then
				Notifier:Obtained("Shiny " .. getCurrentStandName(), 5)
				PityFarmEnabled = false
				break
			end

			if targetHit(pityTargets) then
				Notifier:Obtained(getCurrentStandName(), 5)
				PityFarmEnabled = false
				break
			end
		else
			if not useRokakaka() then
				Notifier:Error("No rokakaka left", 4)
				PityFarmEnabled = false
				break
			end
		end

		task.wait(0.25)
	end
end

local function AddTextBox(tab, title, defaultValue, callback)
	local page = tab.Page

	local card = Instance.new("Frame")
	card.Name = title .. "_Card"
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 0, 58)
	card.Parent = page

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(42, 42, 56)
	stroke.Transparency = 0.2
	stroke.Parent = card

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 6)
	label.Size = UDim2.new(1, -24, 0, 16)
	label.Font = Enum.Font.GothamSemibold
	label.Text = title
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local box = Instance.new("TextBox")
	box.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	box.BorderSizePixel = 0
	box.Position = UDim2.new(0, 12, 0, 28)
	box.Size = UDim2.new(1, -24, 0, 22)
	box.Font = Enum.Font.Gotham
	box.PlaceholderText = "0"
	box.Text = tostring(defaultValue or "")
	box.TextSize = 12
	box.TextColor3 = Color3.fromRGB(220, 220, 235)
	box.ClearTextOnFocus = false
	box.Parent = card

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 8)
	boxCorner.Parent = box

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if callback then
			callback(box.Text)
		end
	end)

	box.FocusLost:Connect(function()
		if callback then
			callback(box.Text)
		end
	end)

	return box
end

local function getPromptItemName(prompt)
	local objectText = tostring(prompt.ObjectText or "")
	if objectText == "" then
		return nil
	end
	return objectText
end

local function itemMatchesTarget(itemName)
	itemName = tostring(itemName or "")
	if itemName == "" then
		return false
	end

	if ItemFarmTargets[itemName] == true then
		return true
	end

	if ItemFarmTargets["Candies"] then
		local lowerName = itemName:lower()

		if lowerName:find("candy") then
			if lowerName:find("red") or lowerName:find("yellow") or lowerName:find("green") or lowerName:find("blue") then
				return true
			end
		end
	end

	return false
end

local function stopItemSpawnWatcher()
	if ItemSpawnConnection then
		ItemSpawnConnection:Disconnect()
		ItemSpawnConnection = nil
	end

	KnownItemPrompts = {}
end

local function startItemSpawnWatcher()
	stopItemSpawnWatcher()

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			KnownItemPrompts[obj] = true
		end
	end

	ItemSpawnConnection = workspace.DescendantAdded:Connect(function(obj)
		if not ItemSpawnNotifyEnabled then
			return
		end

		if not obj:IsA("ProximityPrompt") then
			return
		end

		if KnownItemPrompts[obj] then
			return
		end

		KnownItemPrompts[obj] = true

		task.defer(function()
			if not obj.Parent then
				return
			end

			local itemName = getPromptItemName(obj)
			if itemName and itemName ~= "" then
				Notifier:ItemSpawn(itemName, 4)
			end
		end)
	end)
end

local function getRootPart()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

local function stopItemTween()
	if ActiveItemTween then
		pcall(function()
			ActiveItemTween:Cancel()
		end)
		ActiveItemTween = nil
	end
end

local function getPromptPosition(prompt)
	local current = prompt

	while current and current ~= workspace do
		if current:IsA("BasePart") then
			return current.Position
		end

		if current:IsA("Attachment") and current.Parent and current.Parent:IsA("BasePart") then
			return current.Parent.Position
		end

		if current:IsA("Model") then
			local mainPart = current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true)
			if mainPart then
				return mainPart.Position
			end
		end

		current = current.Parent
	end

	return nil
end

local function moveToItemPosition(position)
	local rootPart = getRootPart()
	local targetCFrame = CFrame.new(position + Vector3.new(0, 3, 0))

	if ItemFarmMethod == "Instant Teleport" then
		rootPart.CFrame = targetCFrame
		return true
	end

	local distance = (rootPart.Position - targetCFrame.Position).Magnitude
	local tweenTime = math.clamp(distance / 120, 0.05, 3)

	stopItemTween()
	ActiveItemTween = TweenService:Create(rootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {
		CFrame = targetCFrame
	})
	ActiveItemTween:Play()
	ActiveItemTween.Completed:Wait()
	ActiveItemTween = nil

	return true
end

local function triggerPrompt(prompt)
	if not prompt or not prompt.Parent then
		return false
	end

	if fireproximityprompt then
		local ok = pcall(function()
			fireproximityprompt(prompt)
		end)
		return ok
	end

	return false
end

local function getNearestTargetPrompt()
	local rootPart = getRootPart()
	local nearestPrompt = nil
	local nearestDistance = math.huge

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			local objectText = tostring(obj.ObjectText or "")
			if objectText ~= "" and itemMatchesTarget(objectText) then
				local promptPosition = getPromptPosition(obj)
				if promptPosition then
					local distance = (rootPart.Position - promptPosition).Magnitude
					if distance < nearestDistance then
						nearestDistance = distance
						nearestPrompt = obj
					end
				end
			end
		end
	end

	return nearestPrompt, nearestDistance
end

local function farmItems()
	if ItemFarmEnabled == false then
		return
	end

	if next(ItemFarmTargets) == nil then
		Notifier:Error("Select an item first", 4)
		ItemFarmEnabled = false
		return
	end

	Notifier:Notify("Items", "Item farm started", "info", 3)

	while ItemFarmEnabled do
		local prompt, distance = getNearestTargetPrompt()

		if prompt and prompt.Parent then
			local itemName = tostring(prompt.ObjectText or "Item")
			local promptPosition = getPromptPosition(prompt)

			if promptPosition then
				moveToItemPosition(promptPosition)
				task.wait(0.1)

				triggerPrompt(prompt)
				task.wait(0.35)

				if not prompt.Parent then
					Notifier:Success("Collected " .. itemName, 3)
				end
			end
		else
			task.wait(0.3)
		end

		task.wait(0.1)
	end

	stopItemTween()
end

local function CreatePityWindow()
	if PityWindow then
		return
	end

	PityWindow = Instance.new("Frame")
	PityWindow.Name = "PityWindow"
	PityWindow.Parent = Window.Gui
	PityWindow.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	PityWindow.BorderSizePixel = 0
	PityWindow.Position = UDim2.new(0, 20, 0, 120)
	PityWindow.Size = UDim2.new(0, 180, 0, 100)
	PityWindow.Active = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = PityWindow

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(42, 42, 56)
	stroke.Transparency = 0.15
	stroke.Parent = PityWindow

	local topbar = Instance.new("Frame")
	topbar.Parent = PityWindow
	topbar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 24)

	local topbarCorner = Instance.new("UICorner")
	topbarCorner.CornerRadius = UDim.new(0, 10)
	topbarCorner.Parent = topbar

	local title = Instance.new("TextLabel")
	title.Parent = topbar
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 1, 0)
	title.Font = Enum.Font.GothamSemibold
	title.Text = "Pity"
	title.TextSize = 12
	title.TextColor3 = Color3.fromRGB(240, 240, 250)

	CurrentPityLabel = Instance.new("TextLabel")
	CurrentPityLabel.Parent = PityWindow
	CurrentPityLabel.BackgroundTransparency = 1
	CurrentPityLabel.Position = UDim2.new(0, 10, 0, 35)
	CurrentPityLabel.Size = UDim2.new(1, -20, 0, 20)
	CurrentPityLabel.Font = Enum.Font.GothamBold
	CurrentPityLabel.Text = "Current: 0"
	CurrentPityLabel.TextSize = 14
	CurrentPityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	CurrentPityLabel.TextXAlignment = Enum.TextXAlignment.Left

	WantedPityLabel = Instance.new("TextLabel")
	WantedPityLabel.Parent = PityWindow
	WantedPityLabel.BackgroundTransparency = 1
	WantedPityLabel.Position = UDim2.new(0, 10, 0, 60)
	WantedPityLabel.Size = UDim2.new(1, -20, 0, 20)
	WantedPityLabel.Font = Enum.Font.Gotham
	WantedPityLabel.Text = "Wanted: 0"
	WantedPityLabel.TextSize = 13
	WantedPityLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
	WantedPityLabel.TextXAlignment = Enum.TextXAlignment.Left

	local dragging = false
	local dragStart = nil
	local startPos = nil

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = PityWindow.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			PityWindow.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function ShowPityWindow(state)
	CreatePityWindow()
	PityWindow.Visible = state

	if state then
		if PityWindowUpdateConnection then
			PityWindowUpdateConnection:Disconnect()
		end

		CurrentPityLabel.Text = "Current: " .. tostring(getCurrentPity())
		WantedPityLabel.Text = "Wanted: " .. tostring(DesiredPity)

		PityWindowUpdateConnection = RunService.Heartbeat:Connect(function()
			if CurrentPityLabel then
				CurrentPityLabel.Text = "Current: " .. tostring(getCurrentPity())
			end

			if WantedPityLabel then
				WantedPityLabel.Text = "Wanted: " .. tostring(DesiredPity)
			end
		end)
	else
		if PityWindowUpdateConnection then
			PityWindowUpdateConnection:Disconnect()
			PityWindowUpdateConnection = nil
		end
	end
end

Stand:AddDropdown("StandSelect", {
	Title = "Stand Select",
	Multi = true,
	Values = NormalStandList,
	Callback = function(value)
		NormalStandTargets = value
	end
})

Stand:AddDropdown("RibStandSelect", {
	Title = "Rib Stand Select",
	Multi = true,
	Values = RibStandList,
	Callback = function(value)
		RibStandTargets = value
	end
})

Stand:AddToggle("StopOnShiny", {
	Title = "Stop On Shiny",
	Default = false,
	Callback = function(state)
		StopOnShinyEnabled = state
	end
})

Stand:AddToggle("StandFarm", {
	Title = "Stand Farm",
	Default = false,
	Callback = function(state)
		StandFarmEnabled = state

		if state then
			RibFarmEnabled = false
			PityFarmEnabled = false

			task.spawn(function()
				farmNormalStand()
			end)
		end
	end
})

Stand:AddToggle("RibFarm", {
	Title = "Ribcage Farm",
	Default = false,
	Callback = function(state)
		RibFarmEnabled = state

		if state then
			StandFarmEnabled = false
			PityFarmEnabled = false

			task.spawn(function()
				farmRibStand()
			end)
		end
	end
})

Stand:AddDropdown("PityFarmMethod", {
	Title = "Pity Farm Method",
	Multi = false,
	Values = {"Ribcages", "Arrows"},
	Default = "Ribcages",
	Callback = function(value)
		PityFarmMethod = tostring(value or "Ribcages")
	end
})

AddTextBox(Stand, "Desired Pity", DesiredPity, function(text)
	DesiredPity = tonumber(text) or 0

	if WantedPityLabel then
		WantedPityLabel.Text = "Wanted: " .. tostring(DesiredPity)
	end
end)

Stand:AddToggle("PityFarm", {
	Title = "Pity Farm",
	Default = false,
	Callback = function(state)
		PityFarmEnabled = state

		if state then
			StandFarmEnabled = false
			RibFarmEnabled = false

			task.spawn(function()
				farmPity()
			end)
		end
	end
})

Items:AddToggle("ItemSpawnNotifications", {
	Title = "Item Spawn Notifications",
	Default = false,
	Callback = function(state)
		ItemSpawnNotifyEnabled = state

		if state then
			startItemSpawnWatcher()
			Notifier:Notify("Items", "Spawn notifications enabled", "info", 3)
		else
			stopItemSpawnWatcher()
			Notifier:Notify("Items", "Spawn notifications disabled", "warn", 3)
		end
	end
})


Items:AddDropdown("ItemFarmSelect", {
	Title = "Item Select",
	Multi = true,
	Values = ItemFarmList,
	Callback = function(value)
		ItemFarmTargets = value
	end
})

Items:AddDropdown("ItemFarmMethod", {
	Title = "Item Farm Method",
	Multi = false,
	Values = {"Tween", "Instant Teleport"},
	Default = "Tween",
	Callback = function(value)
		ItemFarmMethod = tostring(value or "Tween")
	end
})

Items:AddToggle("ItemFarm", {
	Title = "Item Farm",
	Default = false,
	Callback = function(state)
		ItemFarmEnabled = state

		if state then
			task.spawn(function()
				farmItems()
			end)
		else
			stopItemTween()
		end
	end
})

Misc:AddToggle("ShowPity", {
	Title = "Show pity",
	Default = false,
	Callback = function(state)
		ShowPityWindow(state)
	end
})
