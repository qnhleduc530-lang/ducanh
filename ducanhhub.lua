-- 🔥 FIX LOAD
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

print("✅ SCRIPT DA BAT DAU CHAY")

-- ANTI LOAD LỖI
if not LP then
    warn("❌ KHONG TIM THAY PLAYER")
    return
end

-- CHỜ GUI
repeat task.wait() until LP:FindFirstChild("PlayerGui")

print("✅ DA LOAD PLAYER & GUI")

-- ================= CONFIG =================
local CFG = {
    AUTO_EVENT = true,
    AUTO_OPEN_EGG = true,
    AUTO_HARVEST = true,
    AUTO_UP_PET = true,
    PET_CREATE_MODE = 1,
    CHECK_INTERVAL = 0.5,
}

local UIS = game:GetService("UserInputService")

local function log(m)
    print("[PetHub] " .. m)
end

local function safe(f)
    if typeof(f) == "function" then
        local ok, err = pcall(f)
        if not ok then
            warn("❌ ERROR:", err)
        end
    end
end

-- ================= LOADING UI =================
local function showLoadingUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "LoadingGUI"
    sg.Parent = LP.PlayerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,300,0,50)
    label.Position = UDim2.new(0.5,-150,0.5,-25)
    label.Text = "⏳ Loading Script..."
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = sg

    return sg
end

-- ================= MAIN GUI =================
function createMenuGUI()
    if LP.PlayerGui:FindFirstChild("PetHubGUI") then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "PetHubGUI"
    sg.Parent = LP.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.Text = "🔥 PET HUB (FIXED)"
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,0,1,-40)
    status.Position = UDim2.new(0,0,0,40)
    status.Text = "✅ Script đang chạy!"
    status.TextScaled = true
    status.TextColor3 = Color3.new(0,1,0)
    status.BackgroundTransparency = 1
    status.Parent = frame
end

-- ================= NOTIFY =================
local function notify()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Pet Hub",
            Text = "Script đã bật!",
            Duration = 5
        })
    end)
end

-- ================= AUTO =================
function autoCreatePet() end
function autoEvent() end
function autoOpenEgg() end
function autoHarvestSell() end
function autoUpPet() end

-- ================= LOOP =================
local function mainLoop()
    log("Loop started")

    while task.wait(CFG.CHECK_INTERVAL) do
        if not LP.Character then continue end

        safe(autoCreatePet)
        safe(autoEvent)
        safe(autoOpenEgg)
        safe(autoHarvestSell)
        safe(autoUpPet)
    end
end

-- ================= INIT =================
local function init()
    log("Init...")

    local loading = showLoadingUI()
    task.wait(1.5)

    if loading then
        loading:Destroy()
    end

    createMenuGUI()
    notify()

    task.spawn(mainLoop)

    log("✅ LOADED OK")
end

init()

-- ================= HOTKEY =================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        local gui = LP.PlayerGui:FindFirstChild("PetHubGUI")

        if gui then
            gui:Destroy()
        else
            createMenuGUI()
        end
    end
end)
