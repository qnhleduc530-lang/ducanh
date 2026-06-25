-- 🔥 FIX LOAD
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

print("✅ SCRIPT DA BAT DAU CHAY")

if not LP then
warn("❌ KHONG TIM THAY PLAYER")
return
end

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
status.Positio

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

-- ================= AUTO REAL =================
function autoCreatePet()
local rs = game:GetService("ReplicatedStorage")
local remote = rs:FindFirstChild("CreatePet") or rs:FindFirstChild("BuyPet")
if remote then
remote:FireServer()
log("🐶 Create Pet")
end
end

function autoEvent()
local rs = game:GetService("ReplicatedStorage")
local remote = rs:FindFirstChild("Event") or rs:FindFirstChild("ClaimEvent")
if remote then
remote:FireServer()
log("🎯 Event")
end
end

function autoOpenEgg()
local rs = game:GetService("ReplicatedStorage")
local remote = rs:FindFirstChild("OpenEgg") or rs:FindFirstChild("BuyEgg")
if remote then
remote:FireServer()
log("🥚 Open Egg")
end
end

function autoHarvestSell()
local rs = game:GetService("ReplicatedStorage")
local remote = rs:FindFirstChild("Sell") or rs:FindFirstChild("Harvest")
if remote then
remote:FireServer()
log("💰 Sell/Harvest")
end
end

function autoUpPet()
local rs = game:GetService("ReplicatedStorage")
local remote = rs:FindFirstChild("UpgradePet") or rs:FindFirstChild("LevelUpPet")
if remote then
remote:FireServer()
log("⬆️ Upgrade Pet")
end
end

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
-- FIX MENU HIỆN
local gui = Instance.new("ScreenGui")
gui.Name = "DucAnhMenu"
gui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(gui)
    gui.Parent = game.CoreGui
else
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 0, 50)
text.Text = "MENU ĐANG CHẠY"
text.TextColor3 = Color3.fromRGB(0, 255, 0)
text.BackgroundTransparency = 1
text.Parent = frame

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
