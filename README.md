--[[
    Автофарм скрипт для Kaitun Anime Warrior 3
    Версия: 1.0 | Исполнитель: Delta X (Android)
    Совместим с Delta X, Krnl, Vega X и другими.
    Комментарии строго технические на русском языке.
]]

-- Инициализация сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Переменные локального игрока
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Конфигурация скрипта
local settings = {
    autoFarm = false,
    autoQuest = false,
    autoStats = false,
    autoBoss = false,
    farmDistance = 50,         -- дистанция поиска мобов
    attackDelay = 0.25,        -- задержка между атаками
    questDistance = 30,        -- дистанция до NPC с квестами
    bossNames = {"Boss1", "Boss2"}  -- заменить на реальные имена боссов
}

-- Создание GUI меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaitunFarmGui"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Уведомление о разработчике (появляется на 5 секунд)
local notificationFrame = Instance.new("Frame")
notificationFrame.Size = UDim2.new(0, 300, 0, 50)
notificationFrame.Position = UDim2.new(0.5, -150, 0, 10)
notificationFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notificationFrame.BackgroundTransparency = 0.5
notificationFrame.BorderSizePixel = 0
notificationFrame.Parent = ScreenGui

local notificationText = Instance.new("TextLabel")
notificationText.Size = UDim2.new(1, 0, 1, 0)
notificationText.BackgroundTransparency = 1
notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationText.Text = "The script was developed in Vietnam."
notificationText.Font = Enum.Font.SourceSansBold
notificationText.TextScaled = true
notificationText.Parent = notificationFrame

task.delay(5, function()
    notificationFrame:Destroy()
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Kaitun AW3 AutoFarm"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = MainFrame

-- Функция создания кнопок интерфейса
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 25, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextScaled = true
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Кнопки управления
local autoFarmBtn = createButton("Автофарм: Выкл", 40, function()
    settings.autoFarm = not settings.autoFarm
    autoFarmBtn.Text = "Автофарм: " .. (settings.autoFarm and "Вкл" or "Выкл")
end)
local autoQuestBtn = createButton("Автоквесты: Выкл", 80, function()
    settings.autoQuest = not settings.autoQuest
    autoQuestBtn.Text = "Автоквесты: " .. (settings.autoQuest and "Вкл" or "Выкл")
end)
local autoStatsBtn = createButton("Автостаты: Выкл", 120, function()
    settings.autoStats = not settings.autoStats
    autoStatsBtn.Text = "Автостаты: " .. (settings.autoStats and "Вкл" or "Выкл")
end)
local autoBossBtn = createButton("Автобосс: Выкл", 160, function()
    settings.autoBoss = not settings.autoBoss
    autoBossBtn.Text = "Автобосс: " .. (settings.autoBoss and "Вкл" or "Выкл")
end)

-- Поиск ближайшего врага
local function getNearestEnemy()
    local nearest = nil
    local minDist = settings.farmDistance
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= character then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- Телепортация к цели
local function tweenToTarget(targetPart)
    if not targetPart then return end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetPart.CFrame * CFrame.new(0, 0, -3)}
    local tween = TweenService:Create(rootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Логика атаки
local function attackTarget(enemy)
    if not enemy or not enemy.PrimaryPart then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                character.Humanoid:EquipTool(v)
                tool = v
                break
            end
        end
    end
    if tool then
        tool:Activate()
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- Автоматическое выполнение квестов
local function autoQuestHandler()
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:IsA("Model") and npc ~= character then
            local billboard = npc:FindFirstChildOfClass("BillboardGui")
            if billboard and billboard.Enabled then
                local textLabel = billboard:FindFirstChildOfClass("TextLabel")
                if textLabel and textLabel.Text:lower():find("квест") then
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp and (rootPart.Position - hrp.Position).Magnitude < settings.questDistance then
                        tweenToTarget(hrp)
                        task.wait(0.5)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.2)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end

-- Автоматическая прокачка статов (корректировка координат под своё разрешение)
local function autoStatsHandler()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
    task.wait(0.5)
    local buttonPosition = Vector2.new(500, 300)
    VirtualInputManager:SendMouseButtonEvent(buttonPosition.X, buttonPosition.Y, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(buttonPosition.X, buttonPosition.Y, 0, false, game, 0)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
end

-- Автофарм боссов по именам
local function autoBossHandler()
    for _, bossName in ipairs(settings.bossNames) do
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name == bossName then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    tweenToTarget(hrp)
                    repeat
                        attackTarget(obj)
                        task.wait(settings.attackDelay)
                    until not hum or hum.Health <= 0
                end
            end
        end
    end
end

-- Главный цикл фарма (Heartbeat)
RunService.Heartbeat:Connect(function()
    if not settings.autoFarm then return end
    local enemy = getNearestEnemy()
    if enemy then
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            tweenToTarget(enemyRoot)
            attackTarget(enemy)
            task.wait(settings.attackDelay)
        end
    end
end)

-- Цикл для остальных функций (каждую секунду)
task.spawn(function()
    while task.wait(1) do
        if settings.autoQuest then autoQuestHandler() end
        if settings.autoStats then autoStatsHandler() end
        if settings.autoBoss then autoBossHandler() end
    end
end)

-- Обработчик возрождения
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)
