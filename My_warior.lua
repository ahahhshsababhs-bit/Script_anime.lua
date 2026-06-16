print("Script da kich hoat thanh cong!")
game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
--[[
    ОШИБКА: Вы запускаете Lua-скрипт в Python (Pydroid).
    Данный код предназначен ТОЛЬКО для выполнения внутри Roblox с помощью
    Lua-исполнителя (executor): Synapse X, Krnl, Fluxus, Vega X и др.
    Установите Roblox-инжектор и вставьте этот скрипт в его окно.
    Ниже исправленная версия с дополнительной проверкой окружения.
]]

-- Проверка, выполняется ли код в Roblox (защита от запуска вне Lua-рантайма)
if not pcall(function() return game:GetService("Players") end) then
    -- Эта часть выполнится только в НЕ-Roblox среде (например, в Python вызовет ошибку)
    -- В настоящем Lua-исполнителе эта строка недостижима.
    error("Данный скрипт можно запускать только в Roblox-исполнителе.")
end

-- Полный автофарм скрипт для Kaitun Anime Warrior 3 [Roblox]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    autoFarm = false,
    autoQuest = false,
    autoStats = false,
    autoBoss = false,
    farmDistance = 50,
    attackDelay = 0.2,
    questDistance = 30,
    bossNames = {"Boss1", "Boss2"} -- замените на реальные имена боссов
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaitunFarmGui"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

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

local function tweenToTarget(targetPart)
    if not targetPart then return end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetPart.CFrame * CFrame.new(0, 0, -3)}
    local tween = TweenService:Create(rootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

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

local function autoStatsHandler()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
    task.wait(0.5)
    local buttonPosition = Vector2.new(500, 300) -- подгоните координаты
    VirtualInputManager:SendMouseButtonEvent(buttonPosition.X, buttonPosition.Y, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(buttonPosition.X, buttonPosition.Y, 0, false, game, 0)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
end

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

task.spawn(function()
    while task.wait(1) do
        if settings.autoQuest then autoQuestHandler() end
        if settings.autoStats then autoStatsHandler() end
        if settings.autoBoss then autoBossHandler() end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)
