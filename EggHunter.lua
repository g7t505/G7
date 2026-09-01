-- EggHunter V99 - Complete Script
if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    ToggleKey = Enum.KeyCode.F,
    Speed = 120,
    CollectRadius = 80,
    EggValueUpdate = 5,
    OnlyRareEggs = true,
    FrogQuestActive = false,
}

local isActive = false
local eggList = {}
local currentTarget = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "🥚 صائد البيض V99"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 45)
toggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
toggleButton.Text = "🔴 إيقاف التشغيل"
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton
toggleButton.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.28, 0)
statusLabel.Text = "الحالة: 🟢 نشط"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local eggPriceLabel = Instance.new("TextLabel")
eggPriceLabel.Size = UDim2.new(1, 0, 0, 30)
eggPriceLabel.Position = UDim2.new(0, 0, 0.35, 0)
eggPriceLabel.Text = "💰 السعر: جارٍ التحديث..."
eggPriceLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
eggPriceLabel.BackgroundTransparency = 1
eggPriceLabel.Font = Enum.Font.Gotham
eggPriceLabel.TextSize = 15
eggPriceLabel.Parent = mainFrame

local frogButton = Instance.new("TextButton")
frogButton.Size = UDim2.new(0.8, 0, 0, 45)
frogButton.Position = UDim2.new(0.1, 0, 0.48, 0)
frogButton.Text = "🐸 تفعيل مهمة الضفدع"
frogButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
frogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
frogButton.Font = Enum.Font.GothamBold
frogButton.TextSize = 18
local frogCorner = Instance.new("UICorner")
frogCorner.CornerRadius = UDim.new(0, 8)
frogCorner.Parent = frogButton
frogButton.Parent = mainFrame

local frogCollectButton = Instance.new("TextButton")
frogCollectButton.Size = UDim2.new(0.8, 0, 0, 40)
frogCollectButton.Position = UDim2.new(0.1, 0, 0.68, 0)
frogCollectButton.Text = "🍃 جمع بيض الضفدع"
frogCollectButton.BackgroundColor3 = Color3.fromRGB(200, 180, 50)
frogCollectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
frogCollectButton.Font = Enum.Font.GothamBold
frogCollectButton.TextSize = 16
frogCollectButton.Visible = false
local frogCollectCorner = Instance.new("UICorner")
frogCollectCorner.CornerRadius = UDim.new(0, 8)
frogCollectCorner.Parent = frogCollectButton
frogCollectButton.Parent = mainFrame

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, 0, 0, 30)
countLabel.Position = UDim2.new(0, 0, 0.82, 0)
countLabel.Text = "📦 البيض المجموع: 0"
countLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.Gotham
countLabel.TextSize = 15
countLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Parent = mainFrame

local function updateEggPrice()
    local price = math.random(50, 500)
    eggPriceLabel.Text = "💰 السعر: $" .. price .. " (متغير)"
end

local function getRareEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Egg") then
            local isRare = obj:FindFirstChild("Rare") or obj:FindFirstChild("Legendary")
            if settings.OnlyRareEggs and isRare then
                table.insert(eggs, obj)
            elseif not settings.OnlyRareEggs then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

local function moveTo(target)
    if not target then return end
    local targetPart = target:FindFirstChild("PrimaryPart") or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    local direction = (targetPos - rootPart.Position).Unit
    local newPos = rootPart.Position + direction * settings.Speed * 0.1
    rootPart.CFrame = CFrame.new(newPos)
end

local function collectEgg(egg)
    if not egg or not egg.Parent then return false end
    local success = pcall(function()
        local clickDetector = egg:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
        else
            egg:Destroy()
        end
    end)
    return success
end

local function collectFrogEggs()
    local frogEggsFound = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("FrogEgg") then
            table.insert(frogEggsFound, obj)
        end
    end
    
    for _, egg in pairs(frogEggsFound) do
        collectEgg(egg)
        task.wait(0.1)
    end
    countLabel.Text = "🐸 بيض الضفدع: " .. tostring(#frogEggsFound)
end

local function mainLoop()
    while isActive and task.wait(0.05) do
        eggList = getRareEggs()
        
        if #eggList > 0 then
            local nearest = nil
            local nearestDist = math.huge
            for _, egg in pairs(eggList) do
                local eggPos = egg:FindFirstChild("PrimaryPart") or egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("Head")
                if eggPos then
                    local dist = (rootPart.Position - eggPos.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = egg
                    end
                end
            end
            
            if nearest and nearestDist < settings.CollectRadius then
                currentTarget = nearest
                moveTo(nearest)
                
                if nearestDist < 10 then
                    collectEgg(nearest)
                    countLabel.Text = "📦 البيض المجموع: " .. tostring(#eggList)
                    updateEggPrice()
                end
            else
                if nearest then moveTo(nearest) end
            end
        else
            task.wait(0.5)
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    isActive = not isActive
    if isActive then
        toggleButton.Text = "🟢 تشغيل"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        statusLabel.Text = "الحالة: 🟢 نشط"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        task.spawn(mainLoop)
    else
        toggleButton.Text = "🔴 إيقاف التشغيل"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "الحالة: 🔴 متوقف"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        currentTarget = nil
    end
end)

frogButton.MouseButton1Click:Connect(function()
    settings.FrogQuestActive = not settings.FrogQuestActive
    if settings.FrogQuestActive then
        frogButton.Text = "🐸 إلغاء مهمة الضفدع"
        frogButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        frogCollectButton.Visible = true
        statusLabel.Text = "الحالة: 🐸 مهمة الضفدع مفعلة"
    else
        frogButton.Text = "🐸 تفعيل مهمة الضفدع"
        frogButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        frogCollectButton.Visible = false
        statusLabel.Text = "الحالة: 🟢 نشط"
    end
end)

frogCollectButton.MouseButton1Click:Connect(function()
    if settings.FrogQuestActive then
        task.spawn(collectFrogEggs)
        statusLabel.Text = "🍃 جاري جمع بيض الضفدع..."
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    isActive = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == settings.ToggleKey then
        toggleButton.MouseButton1Click:Fire()
    end
end)

humanoid.WalkSpeed = settings.Speed

task.spawn(function()
    while true do
        task.wait(settings.EggValueUpdate)
        updateEggPrice()
    end
end)

print("🥚 EggHunter V99 - Shadow Mode Active")
