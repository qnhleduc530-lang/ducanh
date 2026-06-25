print("🔥 DUCANH HUB (VIỆT) KHỞI ĐỘNG")

-- ===== ANTI KICK =====
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if tostring(method) == "Kick" then
        warn("🛡️ Anti Kick chặn!")
        return nil
    end

    return oldNamecall(self, ...)
end)

-- ===== DỊCH VỤ =====
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- ===== GUI (HIỆN 100%) =====
local parentGui = game:FindFirstChild("CoreGui") or LP:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "DucAnhHub"
gui.Parent = parentGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 320)
frame.Position = UDim2.new(0.5, -160, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Parent = gui

Instance.new("UIStroke", frame).Color = Color3.fromRGB(255,255,255)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.Text = "🔥 DUCANH HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

-- ===== TRẠNG THÁI =====
local toggle = {
    pet = false,
    event = false,
    egg = false,
    farm = false,
    up = false
}

-- ===== TẠO NÚT =====
local function taoNut(text, y, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text.." : TẮT"
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        toggle[key] = not toggle[key]
        btn.Text = text.." : "..(toggle[key] and "BẬT" or "TẮT")
    end)
end

-- ===== 5 CHỨC NĂNG =====
taoNut("Tạo Pet", 50, "pet")
taoNut("Làm Sự Kiện", 100, "event")
taoNut("Mở Trứng", 150, "egg")
taoNut("Farm + Bán", 200, "farm")
taoNut("Up Pet", 250, "up")

-- ===== GỌI REMOTE =====
local function goi(remoteName)
    local r = RS:FindFirstChild(remoteName)
    if r then
        print("✅ Gọi:", remoteName)
        pcall(function()
            r:FireServer()
        end)
    else
        warn("❌ Không có remote:", remoteName)
    end
end

-- ===== LOOP CHÍNH =====
task.spawn(function()
    while task.wait(2) do
        if toggle.pet then goi("CreatePet") end
        if toggle.event then goi("Event") end
        if toggle.egg then goi("OpenEgg") end

        if toggle.farm then
            goi("Harvest")
            goi("Sell")
        end

        if toggle.up then goi("UpgradePet") end
    end
end)
