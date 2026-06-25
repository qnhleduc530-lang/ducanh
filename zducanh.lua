--[[
    Script: ducanh_hub.lua
    Mô tả: Hub tự động cho The Garden Game – PRO LEVEL, chống fail tối đa.
    Hỗ trợ nhiều phương thức tương tác, teleport mượt, ưu tiên vật gần nhất.
    Menu nền đen trắng, phím tắt RightControl.
    Tác giả: DUC ANH
--]]

-- ========== DEBUG KIỂM TRA SCRIPT CHẠY ==========
print("SCRIPT START - DUC ANH HUB")

-- ========== ANTI INJECT TRÙNG ==========
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
if not LP then
    print("ERROR: LocalPlayer nil, đợi...")
    repeat task.wait() until Players.LocalPlayer
    LP = Players.LocalPlayer
end

local PlayerGui = LP:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("ducanh_hub") then
    print("DUCANH HUB đã tồn tại, thoát")
    return
end

-- ========== CẤU HÌNH ==========
local CONFIG = {
    DELAY_LOOP = 1.2,
    MAX_DIST = 150,
    USE_TELEPORT = true,
    RETRY_TIMES = 3,
    TELEPORT_OFFSET = 3,
    ZINDEX_BEHAVIOR = Enum.ZIndexBehavior.Sibling,
}

-- ========== LOADING ==========
if not game:IsLoaded() then game.Loaded:Wait() end

-- ========== BIẾN TOÀN CỤC ==========
_G.AutoPet = false
_G.AutoEvent = false
_G.AutoEgg = false
_G.AutoFarm = false
_G.AutoPetLv = false

local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- ========== HÀM LOG ==========
local function log(msg)
    print("[DUC ANH HUB] " .. msg)
end

-- ========== HÀM ĐỢI RESPAWN ==========
local function waitForCharacter()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
        log("Đợi nhân vật respawn...")
        repeat task.wait() until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        log("Nhân vật đã xuất hiện")
    end
end

-- ========== HÀM DI CHUYỂN (LERP) ==========
local function moveToObject(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    waitForCharacter()
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return false end

    local targetPos = obj.Position + Vector3.new(0, CONFIG.TELEPORT_OFFSET, 0)
    local dist = (hrp.Position - obj.Position).Magnitude
    if dist <= 12 then return true end

    if CONFIG.USE_TELEPORT then
        local targetCF = CFrame.new(targetPos)
        local startCF = hrp.CFrame
        for i = 1, 3 do
            hrp.CFrame = startCF:Lerp(targetCF, i / 3)
            task.wait(0.05)
        end
        hrp.CFrame = targetCF
        log("Teleport mượt đến " .. obj.Name)
        task.wait(0.1)
        return true
    else
        log("Di chuyển đến " .. obj.Name)
        hum:MoveTo(targetPos)
        local timeout = 0
        while (hrp.Position - obj.Position).Magnitude > 12 and timeout < 4 do
            task.wait(0.2)
            timeout = timeout + 0.2
        end
        if (hrp.Position - obj.Position).Magnitude > 12 then
            log("Bị kẹt, teleport lên cao")
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
            task.wait(0.1)
        end
        return (hrp.Position - obj.Position).Magnitude <= 12
    end
end

-- ========== HÀM TƯƠNG TÁC ==========
local function interactWithObject(obj)
    if not obj then return false end

    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        pcall(function() obj:Activate() end)
        return true
    end

    if obj:IsA("BasePart") then
        moveToObject(obj)
        task.wait(0.2)
    end

    local success = false
    local attempts = {
        function()
            local cd = obj:FindFirstChild("ClickDetector") or (obj.Parent and obj.Parent:FindFirstChild("ClickDetector"))
            if cd then
                fireclickdetector(cd)
                return true
            end
        end,
        function()
            local pp = obj:FindFirstChild("ProximityPrompt") or (obj.Parent and obj.Parent:FindFirstChild("ProximityPrompt"))
            if pp and pp:IsA("ProximityPrompt") then
                pp:Prompt(LP)
                return true
            end
        end,
        function()
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("RemoteEvent") then
                    task.wait(0.1)
                    child:FireServer()
                    return true
                end
            end
        end,
        function()
            for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
                if ev:IsA("RemoteEvent") and (ev.Name:lower():find("click") or ev.Name:lower():find("interact") or ev.Name:lower():find("use") or ev.Name:lower():find("action")) then
                    task.wait(0.1)
                    ev:FireServer(obj)
                    return true
                end
            end
        end,
        function()
            for _, ev in ipairs(workspace:GetDescendants()) do
                if ev:IsA("RemoteEvent") and (ev.Name:lower():find("click") or ev.Name:lower():find("interact")) then
                    task.wait(0.1)
                    ev:FireServer(obj)
                    return true
                end
            end
        end,
        function()
            for _, rf in ipairs(ReplicatedStorage:GetDescendants()) do
                if rf:IsA("RemoteFunction") and (rf.Name:lower():find("click") or rf.Name:lower():find("interact")) then
                    rf:InvokeServer(obj)
                    return true
                end
            end
        end,
    }

    for _, fn in ipairs(attempts) do
        local ok, result = pcall(fn)
        if ok and result then
            success = true
            break
        end
    end

    if not success then
        log("Không thể tương tác với " .. obj.Name)
    end
    return success
end

-- ========== TÌM OBJECT GẦN NHẤT ==========
local function findClosestObject(patterns, searchAreas, maxDist)
    patterns = type(patterns) == "table" and patterns or {patterns}
    searchAreas = searchAreas or {workspace, LP.PlayerGui, LP.Backpack, LP.Character}
    maxDist = maxDist or CONFIG.MAX_DIST

    waitForCharacter()
    local charPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
    if not charPos then return nil end

    local closest = nil
    local minDist = maxDist

    for _, area in ipairs(searchAreas) do
        if area then
            for _, obj in ipairs(area:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local nameLower = obj.Name:lower()
                    local match = false
                    for _, pattern in ipairs(patterns) do
                        if nameLower:find(pattern) then
                            match = true
                            break
                        end
                    end
                    if match then
                        if obj:IsA("BasePart") then
                            local dist = (charPos - obj.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closest = obj
                            end
                        else
                            return obj
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ========== CÁC HÀM CHỨC NĂNG ==========
local function doWithRetry(actionName, actionFunc, retries)
    retries = retries or CONFIG.RETRY_TIMES
    for i = 1, retries do
        if actionFunc() then
            log(actionName .. " thành công")
            return true
        end
        task.wait(0.5)
    end
    log(actionName .. " thất bại sau " .. retries .. " lần thử")
    return false
end

local function createPet()
    return doWithRetry("Tạo pet", function()
        local obj = findClosestObject({"pet", "machine", "create", "hatch", "generate"}, {workspace, LP.PlayerGui})
        if obj then return interactWithObject(obj) end
        for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
            if ev:IsA("RemoteEvent") and (ev.Name:lower():find("create") or ev.Name:lower():find("hatch") or ev.Name:lower():find("generate")) then
                task.wait(0.1); ev:FireServer(); return true
            end
        end
        return false
    end)
end

local function doEvent()
    return doWithRetry("Tham gia sự kiện", function()
        local obj = findClosestObject({"portal", "event", "campfire", "join"}, {workspace, LP.PlayerGui})
        if obj then return interactWithObject(obj) end
        for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
            if ev:IsA("RemoteEvent") and (ev.Name:lower():find("event") or ev.Name:lower():find("join") or ev.Name:lower():find("campfire")) then
                task.wait(0.1); ev:FireServer(); return true
            end
        end
        return false
    end)
end

local function openEgg()
    return doWithRetry("Mở trứng", function()
        local obj = findClosestObject({"egg", "trung", "open", "hatch"}, {workspace, LP.PlayerGui, LP.Backpack})
        if obj then return interactWithObject(obj) end
        for _, item in ipairs(LP.Backpack:GetChildren()) do
            if item.Name:lower():find("egg") then
                pcall(item.Activate, item); return true
            end
        end
        for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
            if ev:IsA("RemoteEvent") and (ev.Name:lower():find("open") or ev.Name:lower():find("egg")) then
                task.wait(0.1); ev:FireServer(); return true
            end
        end
        return false
    end)
end

local function harvestAndSell()
    return doWithRetry("Hái trái và bán", function()
        local fruit = findClosestObject({"fruit", "berry", "trai", "crop", "harvest"}, {workspace})
        if fruit then
            interactWithObject(fruit)
            task.wait(0.3)
        end
        local sellObj = findClosestObject({"sell", "market", "shop", "bán"}, {workspace, LP.PlayerGui})
        if sellObj then return interactWithObject(sellObj) end
        local btn = findClosestObject({"sell", "market"}, {LP.PlayerGui})
        if btn then pcall(btn.Activate, btn); return true end
        return false
    end)
end

local function upPetLevel()
    return doWithRetry("Nâng cấp pet", function()
        local obj = findClosestObject({"upgrade", "level", "evolve", "nang cap"}, {workspace, LP.PlayerGui})
        if obj then return interactWithObject(obj) end
        for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
            if ev:IsA("RemoteEvent") and (ev.Name:lower():find("upgrade") or ev.Name:lower():find("level") or ev.Name:lower():find("evolve")) then
                task.wait(0.1); ev:FireServer(); return true
            end
        end
        return false
    end)
end

-- ========== VÒNG LẶP CHÍNH ==========
local function mainLoop()
    while task.wait(CONFIG.DELAY_LOOP) do
        local ok, err = pcall(function()
            if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
                repeat task.wait() until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            end
            if _G.AutoPet then createPet() end
            if _G.AutoEvent then doEvent() end
            if _G.AutoEgg then openEgg() end
            if _G.AutoFarm then harvestAndSell() end
            if _G.AutoPetLv then upPetLevel() end
        end)
        if not ok then
            log("Lỗi vòng lặp: " .. tostring(err))
        end
    end
end

-- ========== TẠO GUI MENU (CÓ FALLBACK) ==========
local function createGUI()
    log("Bắt đầu tạo GUI...")
    local targetGui = PlayerGui
    local success, err = pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "ducanh_hub"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = CONFIG.ZINDEX_BEHAVIOR
        ScreenGui.Parent = targetGui

        local Frame = Instance.new("Frame")
        Frame.Parent = ScreenGui
        Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        Frame.BackgroundTransparency = 0.08
        Frame.BorderColor3 = Color3.fromRGB(255,255,255)
        Frame.BorderSizePixel = 2
        Frame.Position = UDim2.new(0.05,0,0.15,0)
        Frame.Size = UDim2.new(0,240,0,360)
        Frame.ClipsDescendants = true

        local Title = Instance.new("TextLabel")
        Title.Parent = Frame
        Title.Size = UDim2.new(1,0,0,35)
        Title.BackgroundTransparency = 1
        Title.Text = "🔥 DUC ANH HUB 🔥"
        Title.TextColor3 = Color3.fromRGB(255,255,255)
        Title.TextScaled = true
        Title.Font = Enum.Font.Bold
        Title.LayoutOrder = 0

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = Frame
        UIListLayout.Padding = UDim.new(0,4)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function createToggle(name, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = Frame
            btn.Size = UDim2.new(0.92,0,0,36)
            btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
            btn.BorderColor3 = Color3.fromRGB(255,255,255)
            btn.BorderSizePixel = 1
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Text = name .. " : TẮT"
            btn.Font = Enum.Font.SourceSansBold
            btn.TextScaled = true

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = name .. " : " .. (state and "BẬT" or "TẮT")
                btn.BackgroundColor3 = state and Color3.fromRGB(0,70,0) or Color3.fromRGB(25,25,25)
                callback(state)
                log(name .. " => " .. (state and "ON" or "OFF"))
            end)
            return btn
        end

        createToggle("🐾 Tạo Pet", function(v) _G.AutoPet = v end)
        createToggle("🎯 Auto Sự kiện", function(v) _G.AutoEvent = v end)
        createToggle("🥚 Auto Mở trứng", function(v) _G.AutoEgg = v end)
        createToggle("🍓 Auto Hái + Bán", function(v) _G.AutoFarm = v end)
        createToggle("⬆️ Auto Up Pet", function(v) _G.AutoPetLv = v end)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = Frame
        closeBtn.Size = UDim2.new(0.4,0,0,32)
        closeBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
        closeBtn.BorderColor3 = Color3.fromRGB(255,255,255)
        closeBtn.BorderSizePixel = 1
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Text = "ĐÓNG"
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextScaled = true
        closeBtn.LayoutOrder = 99
        closeBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
            log("Đã đóng GUI")
        end)

        log("GUI đã được tạo thành công!")
    end)

    if not success then
        log("Lỗi tạo GUI: " .. tostring(err))
        log("Thử fallback với CoreGui...")
        pcall(function()
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "ducanh_hub"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.ZIndexBehavior = CONFIG.ZINDEX_BEHAVIOR
            ScreenGui.Parent = CoreGui

            -- Tạo lại toàn bộ UI trong fallback (giống như trên)
            local Frame = Instance.new("Frame")
            Frame.Parent = ScreenGui
            Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
            Frame.BackgroundTransparency = 0.08
            Frame.BorderColor3 = Color3.fromRGB(255,255,255)
            Frame.BorderSizePixel = 2
            Frame.Position = UDim2.new(0.05,0,0.15,0)
            Frame.Size = UDim2.new(0,240,0,360)
            Frame.ClipsDescendants = true

            local Title = Instance.new("TextLabel")
            Title.Parent = Frame
            Title.Size = UDim2.new(1,0,0,35)
            Title.BackgroundTransparency = 1
            Title.Text = "🔥 DUC ANH HUB 🔥"
            Title.TextColor3 = Color3.fromRGB(255,255,255)
            Title.TextScaled = true
            Title.Font = Enum.Font.Bold
            Title.LayoutOrder = 0

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = Frame
            UIListLayout.Padding = UDim.new(0,4)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local function createToggle(name, callback)
                local btn = Instance.new("TextButton")
                btn.Parent = Frame
                btn.Size = UDim2.new(0.92,0,0,36)
                btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
                btn.BorderColor3 = Color3.fromRGB(255,255,255)
                btn.BorderSizePixel = 1
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.Text = name .. " : TẮT"
                btn.Font = Enum.Font.SourceSansBold
                btn.TextScaled = true

                local state = false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = name .. " : " .. (state and "BẬT" or "TẮT")
                    btn.BackgroundColor3 = state and Color3.fromRGB(0,70,0) or Color3.fromRGB(25,25,25)
                    callback(state)
                    log(name .. " => " .. (state and "ON" or "OFF"))
                end)
                return btn
            end

            createToggle("🐾 Tạo Pet", function(v) _G.AutoPet = v end)
            createToggle("🎯 Auto Sự kiện", function(v) _G.AutoEvent = v end)
            createToggle("🥚 Auto Mở trứng", function(v) _G.AutoEgg = v end)
            createToggle("🍓 Auto Hái + Bán", function(v) _G.AutoFarm = v end)
            createToggle("⬆️ Auto Up Pet", function(v) _G.AutoPetLv = v end)

            local closeBtn = Instance.new("TextButton")
            closeBtn.Parent = Frame
            closeBtn.Size = UDim2.new(0.4,0,0,32)
            closeBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
            closeBtn.BorderColor3 = Color3.fromRGB(255,255,255)
            closeBtn.BorderSizePixel = 1
            closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
            closeBtn.Text = "ĐÓNG"
            closeBtn.Font = Enum.Font.SourceSansBold
            closeBtn.TextScaled = true
            closeBtn.LayoutOrder = 99
            closeBtn.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                log("Đã đóng GUI")
            end)

            log("Fallback GUI đã tạo tại CoreGui")
        end)
    end
end

-- ========== KHỞI CHẠY ==========
local function init()
    log("Đang khởi động DUC ANH HUB (PRO LEVEL)...")
    createGUI()          -- FIX 1: gọi hàm tạo GUI
    task.spawn(mainLoop)
    log("✅ DUC ANH HUB đã sẵn sàng! (Nhấn RightControl để ẩn/hiện menu)")

    task.delay(2, function()
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "🔥 DUC ANH HUB",
                Text = "Script đã chạy thành công!",
                Duration = 5
            })
        end)
    end)
end

-- ========== GỌI INIT (BỌC PCALL) ==========
local ok, err = pcall(init)
if not ok then
    print("LỖI INIT: " .. tostring(err))
    task.wait(1)
    pcall(init)
end

-- ========== HOTKEY (SỬA LỖI Enum.KeyCode) ==========
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then  -- FIX: đúng tên
        local gui = PlayerGui:FindFirstChild("ducanh_hub")
        if gui then
            gui.Enabled = not gui.Enabled
        else
            gui = CoreGui:FindFirstChild("ducanh_hub")
            if gui then gui.Enabled = not gui.Enabled end
        end
    end
  end
