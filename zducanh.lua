print("🔥 DUCANH HUB PRO MAX AUTO")

-- ===== ANTI KICK =====
local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall
mt.__namecall = newcclosure(function(self,...)
    if getnamecallmethod() == "Kick" then
        warn("🛡️ Chặn kick!")
        return nil
    end
    return old(self,...)
end)

-- ===== SERVICES =====
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- ===== AUTO SCAN REMOTE =====
local REMOTES = {}

for _,v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        table.insert(REMOTES, v)
        print("📡 Remote:", v:GetFullName())
    end
end

-- ===== AUTO CALL ALL (NGU VL) =====
local function spamAll()
    for _,r in pairs(REMOTES) do
        pcall(function()
            r:FireServer()
        end)
    end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1,0,1,0)
btn.Text = "AUTO ALL : TẮT"
btn.TextColor3 = Color3.new(1,1,1)
btn.BackgroundColor3 = Color3.fromRGB(20,20,20)

local on = false

btn.MouseButton1Click:Connect(function()
    on = not on
    btn.Text = "AUTO ALL : "..(on and "BẬT" or "TẮT")
end)

-- ===== LOOP =====
task.spawn(function()
    while task.wait(1) do
        if on then
            spamAll()
        end
    end
end)
