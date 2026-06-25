--[[
    Script: ducanh.lua
    Mô tả: Hub không cần key, chống band, menu anime xịn, tích hợp upload log lên pastefy.
    Tính năng: Anti-Kick, Auto Farm, Speed Hack, Teleport, Inspect, Upload Log, GUI đẹp.
    Môi trường: Roblox Luau (chạy với executor).
    Tác giả: DUCANH
--]]

-- ========== CẤU HÌNH ==========
local CFG = {
    BG_IMAGE = "rbxassetid://1234567890",  -- Thay ID ảnh anime của bạn
    PASTERFY_URL = "https://pasterfy.com/api/pastes",
    API_KEY = "",
    SPEED = 70,
    TELE_RADIUS = 120,
    FARM_DIST = 25,
}
-- ===============================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")

-- Hàm log
local function log(m)
    print("[DUCANH] " .. m)
end

-- ========== ANTI-BAND ==========
local function antiBand()
    log("Chống band kích hoạt")
    local oldKick = game.Kick
    game.Kick = function(...) log("Chặn kick!"); return nil end
    if LP.Kick then LP.Kick = function(...) return nil end end
    pcall(function()
        game:GetService("TeleportService"):SetTeleportGuiShown(false)
    end)
end
antiBand()

-- ========== CHỨC NĂNG CHÍNH ==========
local autoFarmEnabled = false
local speedEnabled = false
local logHistory = {}

local function getChar()
    return LP.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function autoFarmToggle()
    autoFarmEnabled = not autoFarmEnabled
    log(autoFarmEnabled and "Bật AutoFarm" or "Tắt AutoFarm")
    table.insert(logHistory, "AutoFarm: " .. (autoFarmEnabled and "Bật" or "Tắt"))
    if autoFarmEnabled then
        RS:BindToRenderStep("SFarm", 1000, function()
            local hrp = getHRP()
            if not hrp then return end
            local pos = hrp.Position + Vector3.new(
                math.random(-CFG.FARM_DIST, CFG.FARM_DIST),
                0,
                math.random(-CFG.FARM_DIST, CFG.FARM_DIST)
            )
            hrp.CFrame = CFrame.new(pos)
        end)
    else
        RS:UnbindFromRenderStep("SFarm")
    end
end

local function speedToggle()
    speedEnabled = not speedEnabled
    log(speedEnabled and "Bật Speed" or "Tắt Speed")
    table.insert(logHistory, "Speed: " .. (speedEnabled and "Bật" or "Tắt"))
    local char = getChar()
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = speedEnabled and CFG.SPEED or 16
            hum.JumpPower = speedEnabled and 100 or 50
        end
    end
    if speedEnabled then
        LP.CharacterAdded:Connect(function(newChar)
            wait(0.5)
            local h = newChar:FindFirstChild("Humanoid")
            if h then
                h.WalkSpeed = CFG.SPEED
                h.JumpPower = 100
            end
        end)
    end
end

local function teleportRandom()
    local hrp = getHRP()
    if not hrp then return end
    local angle = math.random() * 2 * math.pi
    local dist = math.random(10, CFG.TELE_RADIUS)
    local newPos = hrp.Position + Vector3.new(dist * math.cos(angle), 0, dist * math.sin(angle))
    hrp.CFrame = CFrame.new(newPos)
    log("Teleport đến " .. tostring(newPos))
    table.insert(logHistory, "Teleport: " .. tostring(newPos))
end

local function inspect()
    log("Quét người chơi gần nhất...")
    local nearest = nil
    local minDist = math.huge
    local myPos = getHRP() and getHRP().Position
    if not myPos then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local d = (char.HumanoidRootPart.Position - myPos).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = plr
                end
            end
        end
    end
    if nearest then
        local msg = "Gần nhất: " .. nearest.Name .. " (khoảng " .. math.floor(minDist) .. "u)"
        log(msg)
        table.insert(logHistory, msg)
    else
        log("Không tìm thấy người chơi nào")
        table.insert(logHistory, "Inspect: Không tìm thấy")
    end
end

-- Upload log lên pastefy
local function uploadLog()
    log("Đang upload log lên pastefy...")
    local content = table.concat(logHistory, "\n")
    if content == "" then content = "Chưa có hoạt động nào" end
    local payload = {
        title = "ducanh_log_" .. os.time(),
        content = content,
        expire = "1d",
        public = true
    }
    local json = Http:JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}
    if CFG.API_KEY ~= "" then
        headers["Authorization"] = "Bearer " .. CFG.API_KEY
    end
    local ok, resp = pcall(function()
        return Http:RequestAsync({
            Url = CFG.PASTERFY_URL,
            Method = "POST",
            Headers = headers,
            Body = json
        })
    end)
    if ok and resp and resp.StatusCode == 201 then
        local data = Http:JSONDecode(resp.Body)
        if data and data.url then
            log("Upload thành công: " .. data.url)
            table.insert(logHistory, "Upload: " .. data.url)
            return data.url
        end
    else
        log("Upload thất bại, mã: " .. (resp and resp.StatusCode or "none"))
        table.insert(logHistory, "Upload thất bại")
    end
    return nil
end

-- ========== TẠO GUI MENU HÌNH NỀN ANIME ==========
local function createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "DUCANH_HUB"
    sg.Parent = LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 420, 0, 580)
    main.Position = UDim2.new(0.5, -210, 0.5, -290)
    main.BackgroundColor3 = Color3.new(0, 0, 0)
    main.BackgroundTransparency = 0.4
    main.BorderSizePixel = 0
    main.Parent = sg

    -- Ảnh nền anime
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Image = CFG.BG_IMAGE
    bg.BackgroundTransparency = 1
    bg.ScaleType = Enum.ScaleType.Fit
    bg.Parent = main

    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🔥 DUCANH HUB 🔥"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.Bold
    title.Parent = main

    local function makeBtn(text, y, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = UDim2.new(0.1, 0, 0, y)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.4)
        btn.BorderSizePixel = 0
        btn.Parent = main
        btn.MouseButton1Click:Connect(cb)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.6)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.4)
        end)
        return btn
    end

    local y = 60
    -- Anti-Band (luôn bật)
    makeBtn("🛡️ Anti-Band (Bật)", y, function()
        log("Anti-Band đang hoạt động")
    end)
    y = y + 50

    local btnAF = makeBtn("⚔️ AutoFarm", y, function()
        autoFarmToggle()
        btnAF.Text = autoFarmEnabled and "⚔️ AutoFarm (ON)" or "⚔️ AutoFarm (OFF)"
    end)
    y = y + 50

    local btnSH = makeBtn("💨 Speed", y, function()
        speedToggle()
        btnSH.Text = speedEnabled and "💨 Speed (ON)" or "💨 Speed (OFF)"
    end)
    y = y + 50

    makeBtn("🌀 Teleport Ngẫu", y, teleportRandom)
    y = y + 50

    makeBtn("🔍 Inspect", y, inspect)
    y = y + 50

    makeBtn("📤 Upload Log", y, function()
        local url = uploadLog()
        if url then
            log("URL: " .. url)
        end
    end)
    y = y + 50

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.2, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.8, 0, 0, y + 10)
    closeBtn.Text = "Đóng"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = main
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
        log("Đã đóng GUI")
    end)

    return sg
end

-- Tạo GUI khi nhân vật xuất hiện
LP.CharacterAdded:Connect(function()
    wait(1)
    if not LP:FindFirstChild("PlayerGui"):FindFirstChild("DUCANH_HUB") then
        createGUI()
    end
end)

if LP.Character then
    wait(1)
    if not LP:FindFirstChild("PlayerGui"):FindFirstChild("DUCANH_HUB") then
        createGUI()
    end
end

-- Phím tắt Insert để bật/tắt GUI
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        local gui = LP:FindFirstChild("PlayerGui"):FindFirstChild("DUCANH_HUB")
        if gui then gui:Destroy() else createGUI() end
    end
end)

log("Script DUCANH HUB đã sẵn sàng – nhấn Insert để mở menu")
