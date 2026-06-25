print("🔥 DUCANH HUB REAL FIX")

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

-- ===== SCAN REMOTE =====
local remotes = {}

for _,v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        table.insert(remotes, v)
        print("📡", v:GetFullName())
    end
end

-- ===== FILTER THÔNG MINH =====
local function getGood()
    local list = {}

    for _,r in pairs(remotes) do
        local n = r.Name:lower()

        if n:find("pet") or n:find("egg") or n:find("sell") or n:find("farm") then
            table.insert(list, r)
        end
    end

    return list
end

local good = getGood()

-- ===== AUTO =====
local function run()
    for _,r in pairs(good) do
        pcall(function()
            print("⚡ thử:", r.Name)
            r:FireServer()
        end)
    end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui", game.CoreGui)

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,200,0,60)
btn.Position = UDim2.new(0.5,-100,0.8,0)
btn.Text = "AUTO REAL : OFF"
btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
btn.TextColor3 = Color3.new(1,1,1)

local on = false

btn.MouseButton1Click:Connect(function()
    on = not on
    btn.Text = "AUTO REAL : "..(on and "ON" or "OFF")
end)

-- ===== LOOP =====
task.spawn(function()
    while task.wait(1) do
        if on then
            run()
        end
    end
end)
