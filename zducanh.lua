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

-- ================= MAIN GUI =================
function createMenuGUI()
if game.CoreGui:FindFirstChild("PetHubGUI") or LP.PlayerGui:FindFirstChild("PetHubGUI") then return end

local sg = Instance.new("ScreenGui")
sg.Name = "PetHubGUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true

if syn and syn.protect_gui then
syn.protect_gui(sg)
sg.Parent = game.CoreGui
else
sg.Parent = LP.PlayerGui
end

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
status.Text = "MENU ĐANG CHẠY"
status.TextScaled = true
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(0,255,0)
status.Parent = frame

end
-- ================= AUTO =================
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
-- ================= INIT =================
createMenuGUI()
notify()
task.spawn(mainLoop)
-- ================= HOTKEY =================
UIS.InputBegan:Connect(function(input, gp)
if gp then return end

if input.KeyCode == Enum.KeyCode.Insert then
local gui = game.CoreGui:FindFirstChild("PetHubGUI") or LP.PlayerGui:FindFirstChild("PetHubGUI")

if gui then
gui:Destroy()
else
createMenuGUI()
end

end

end)
