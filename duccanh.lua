-- 🔥 FIX LOAD (THÊM)
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
print("SCRIPT DA CHAY")

--[[
    Script: PetHub_Fixed.lua
    (GIỮ NGUYÊN)
--]]

-- ========== CẤU HÌNH ==========
local CFG = {
    AUTO_EVENT = true,
    AUTO_OPEN_EGG = true,
    AUTO_HARVEST = true,
    AUTO_UP_PET = true,
    PET_CREATE_MODE = 1,
    CHECK_INTERVAL = 0.5,
}
-- ===============================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- 🔥 FIX PlayerGui
repeat task.wait() until LP and LP:FindFirstChild("PlayerGui")

local function log(m)
    print("[PetHub] " .. m)
end

-- 🔥 SAFE WRAPPER
local function safe(f)
    pcall(f)
end

-- ========== LOADING UI ==========
local function showLoadingUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "LoadingGUI"
    sg.ResetOnSpawn = false
    sg.Parent = LP.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = sg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 50)
    label.Position = UDim2.new(0.5, -150, 0.5, -25)
    label.Text = "⏳ Đang tải Pet Hub..."
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.Bold
    label.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 200, 0, 10)
    barBg.Position = UDim2.new(0.5, -100, 0.5, 30)
    barBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    barBg.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.new(1, 1, 1)
    bar.Parent = barBg

    -- 🔥 FIX spawn → task.spawn
    task.spawn(function()
        local t = 0
        while sg.Parent do
            t += 0.02
            bar.Size = UDim2.new(math.min(t / 2, 1), 0, 1, 0)
            if t >= 2 then break end
            task.wait(0.02)
        end
    end)

    return sg
end

-- ========== NOTIFY ==========
local function showSuccessNotification()
    local sg = Instance.new("ScreenGui")
    sg.Name = "NotifyGUI"
    sg.Parent = LP.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 60)
    frame.Position = UDim2.new(0.5, -200, 0.1, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.Parent = sg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "✅ Pet Hub đã kích hoạt!"
    label.TextColor3 = Color3.new(0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Parent = frame

    task.delay(5, function()
        if sg then sg:Destroy() end
    end)
end

-- 🔥 FIX CLICK (rất quan trọng)
local function safeClick(btn)
    pcall(function()
        if btn.Activate then
            btn:Activate()
        elseif btn.MouseButton1Click then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- 🔥 PATCH toàn bộ btn.Fire
-- (GIỮ NGUYÊN LOGIC, chỉ thay cách click)

-- ========== LOOP ==========
local function mainLoop()
    while task.wait(CFG.CHECK_INTERVAL) do
        if not LP or not LP.Character then continue end

        safe(autoCreatePet)
        safe(autoEvent)
        safe(autoOpenEgg)
        safe(autoHarvestSell)
        safe(autoUpPet)
    end
end

-- ========== INIT ==========
local function init()
    log("Init...")

    local loadingUI = showLoadingUI()

    task.wait(0.5)

    if loadingUI then loadingUI:Destroy() end

    createMenuGUI()
    showSuccessNotification()

    -- 🔥 FIX spawn
    task.spawn(mainLoop)

    log("LOADED OK")
end

pcall(init)

-- 🔥 FIX INPUT (tránh lỗi mobile)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        local gui = LP.PlayerGui
        local hub = gui:FindFirstChild("PetHubGUI")
        if hub then hub:Destroy() else createMenuGUI() end
    end
end)
