print("🔥 DUCANH HUB PRO REAL")

-- ===== ANTI KICK =====
local mt = getrawmetatable(game)
setreadonly(mt,false)

local old = mt.__namecall
mt.__namecall = newcclosure(function(self,...)
    if getnamecallmethod() == "Kick" then
        warn("🛡️ Block Kick")
        return nil
    end
    return old(self,...)
end)

-- ===== SERVICES =====
local RS = game:GetService("ReplicatedStorage")

-- ===== FIND REMOTE THÔNG MINH =====
local goodRemotes = {}

for _,v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local name = v.Name:lower()

        if string.find(name,"pet") 
        or string.find(name,"egg") 
        or string.find(name,"sell") 
        or string.find(name,"farm") 
        or string.find(name,"event") then

            table.insert(goodRemotes, v)
            print("🔥 Found:", v:GetFullName())
        end
    end
end

-- ===== AUTO FARM REAL =====
local function autoFarm()
    for _,r in pairs(goodRemotes) do
        pcall(function()
            print("⚡ Call:", r.Name)
            r:FireServer()
        end)
    end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui", game.CoreGui)

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,200,0,60)
btn.Position = UDim2.new(0.5,-100,0.8,0)
btn.Text = "AUTO PRO : OFF"
btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
btn.TextColor3 = Color3.new(1,1,1)

local on = false

btn.MouseButton1Click:Connect(function()
    on = not on
    btn.Text = "AUTO PRO : "..(on and "ON" or "OFF")
end)

-- ===== LOOP =====
task.spawn(function()
    while task.wait(1.5) do
        if on then
            autoFarm()
        end
    end
end)
