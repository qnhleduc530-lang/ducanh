--[[
    Script: PetHub.lua
    Mô tả: Hub tự động với 5 chức năng tạo pet, auto sự kiện, auto mở trứng, auto hái trái bán, auto up lv pet.
    Menu GUI nền đen trắng, tối giản.
    Môi trường: Roblox Luau (chạy với executor).
    Tác giả: DUCANH
--]]

-- ========== CẤU HÌNH ==========
local CFG = {
    AUTO_EVENT = true,
    AUTO_OPEN_EGG = true,
    AUTO_HARVEST = true,
    AUTO_UP_PET = true,
    PET_CREATE_MODE = 1,  -- 1-5 tương ứng 5 cách
    CHECK_INTERVAL = 0.5,
}
-- ===============================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local function log(m)
    print("[PetHub] " .. m)
end

-- Hàm lấy nhân vật
local function getChar()
    return LP.Character
end

-- Hàm tương tác với object (click)
local function interact(obj)
    if not obj then return false end
    if obj:FindFirstChild("ClickDetector") then
        fireclickdetector(obj.ClickDetector)
        return true
    elseif obj.Parent and obj.Parent:FindFirstChild("ClickDetector") then
        fireclickdetector(obj.Parent.ClickDetector)
        return true
    end
    -- Tìm RemoteEvent
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            child:FireServer(obj)
            return true
        end
    end
    return false
end

-- ========== 5 CHỨC NĂNG TẠO PET ==========
local function createPet_Method1()
    log("Tạo pet phương pháp 1: Click vào nút Create")
    -- Tìm button Create trong GUI
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        local btn = gui:FindFirstChild("CreateButton") or gui:FindFirstChild("CreatePet")
        if btn and btn:IsA("TextButton") then
            btn:Fire()
            return true
        end
    end
    return false
end

local function createPet_Method2()
    log("Tạo pet phương pháp 2: Click vào vật thể trong workspace")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("pet") and obj.Name:lower():find("machine") then
            interact(obj)
            return true
        end
    end
    return false
end

local function createPet_Method3()
    log("Tạo pet phương pháp 3: Gửi RemoteEvent")
    for _, service in ipairs({game:GetService("ReplicatedStorage")}) do
        for _, child in ipairs(service:GetChildren()) do
            if child:IsA("RemoteEvent") and child.Name:lower():find("create") and child.Name:lower():find("pet") then
                child:FireServer()
                return true
            end
        end
    end
    return false
end

local function createPet_Method4()
    log("Tạo pet phương pháp 4: Sử dụng tool")
    local tool = LP.Backpack:FindFirstChild("PetCreator") or LP.Character:FindFirstChild("PetCreator")
    if tool then
        tool:Activate()
        return true
    end
    return false
end

local function createPet_Method5()
    log("Tạo pet phương pháp 5: Mua từ shop (click vào cửa hàng)")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("shop") or obj.Name:lower():find("store")) then
            interact(obj)
            return true
        end
    end
    return false
end

local createMethods = {
    createPet_Method1,
    createPet_Method2,
    createPet_Method3,
    createPet_Method4,
    createPet_Method5,
}

local function autoCreatePet()
    local method = createMethods[CFG.PET_CREATE_MODE]
    if method then method() end
end

-- ========== AUTO SỰ KIỆN ==========
local function autoEvent()
    if not CFG.AUTO_EVENT then return end
    log("Tìm sự kiện...")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("event") or obj.Name:lower():find("portal")) then
            interact(obj)
            return
        end
    end
    -- Tìm trong GUI
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        local btn = gui:FindFirstChild("EventButton") or gui:FindFirstChild("JoinEvent")
        if btn and btn:IsA("TextButton") then
            btn:Fire()
            return
        end
    end
end

-- ========== AUTO MỞ TRỨNG ==========
local function autoOpenEgg()
    if not CFG.AUTO_OPEN_EGG then return end
    log("Tìm trứng để mở...")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("trung")) then
            interact(obj)
            return
        end
    end
    -- Tìm trong backpack hoặc inventory
    for _, item in ipairs(LP.Backpack:GetChildren()) do
        if item.Name:lower():find("egg") then
            item:Activate()
            return
        end
    end
end

-- ========== AUTO HÁI TRÁI BÁN ==========
local function autoHarvestSell()
    if not CFG.AUTO_HARVEST then return end
    log("Tìm trái cây hái...")
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("fruit") or obj.Name:lower():find("trai") or obj.Name:lower():find("berry")) then
            interact(obj)
            return
        end
    end
    -- Bán tự động (tìm nút Sell)
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        local btn = gui:FindFirstChild("SellButton") or gui:FindFirstChild("SellAll")
        if btn and btn:IsA("TextButton") then
            btn:Fire()
            return
        end
    end
end

-- ========== AUTO UP LEVEL PET ==========
local function autoUpPet()
    if not CFG.AUTO_UP_PET then return end
    log("Tìm nút nâng cấp pet...")
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        local btn = gui:FindFirstChild("UpgradePet") or gui:FindFirstChild("LevelUp") or gui:FindFirstChild("Evolve")
        if btn and btn:IsA("TextButton") then
            btn:Fire()
            return
        end
    end
    -- Tìm trong workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("upgrade") or obj.Name:lower():find("level")) then
            interact(obj)
            return
        end
    end
end

-- ========== VÒNG LẶP CHÍNH ==========
local function mainLoop()
    while wait(CFG.CHECK_INTERVAL) do
        if not LP or not LP.Character then continue end
        autoCreatePet()
        autoEvent()
        autoOpenEgg()
        autoHarvestSell()
        autoUpPet()
    end
end

-- ========== TẠO GUI MENU NỀN ĐEN TRẮNG ==========
local function createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PetHubGUI"
    sg.Parent = LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 360, 0, 480)
    main.Position = UDim2.new(0.5, -180, 0.5, -240)
    main.BackgroundColor3 = Color3.new(0, 0, 0)  -- nền đen
    main.BackgroundTransparency = 0.15
    main.BorderColor3 = Color3.new(1, 1, 1)      -- viền trắng
    main.BorderSizePixel = 2
    main.Parent = sg

    -- Tiêu đề trắng
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "⚫ PET HUB ⚪"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.Bold
    title.Parent = main

    local function makeBtn(text, y, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.85, 0, 0, 30)
        btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  -- xám đen
        btn.BorderColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 1
        btn.Parent = main
        btn.MouseButton1Click:Connect(cb)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        end)
        return btn
    end

    local y = 50

    -- 5 chế độ tạo pet
    makeBtn("🐾 Tạo pet (Phương pháp 1)", y, function()
        CFG.PET_CREATE_MODE = 1
        log("Đã chọn phương pháp 1")
    end)
    y = y + 38
    makeBtn("🐾 Tạo pet (Phương pháp 2)", y, function()
        CFG.PET_CREATE_MODE = 2
        log("Đã chọn phương pháp 2")
    end)
    y = y + 38
    makeBtn("🐾 Tạo pet (Phương pháp 3)", y, function()
        CFG.PET_CREATE_MODE = 3
        log("Đã chọn phương pháp 3")
    end)
    y = y + 38
    makeBtn("🐾 Tạo pet (Phương pháp 4)", y, function()
        CFG.PET_CREATE_MODE = 4
        log("Đã chọn phương pháp 4")
    end)
    y = y + 38
    makeBtn("🐾 Tạo pet (Phương pháp 5)", y, function()
        CFG.PET_CREATE_MODE = 5
        log("Đã chọn phương pháp 5")
    end)
    y = y + 45

    -- Các auto toggle
    local btnEvent = makeBtn("🎯 Auto sự kiện (Bật)", y, function()
        CFG.AUTO_EVENT = not CFG.AUTO_EVENT
        btnEvent.Text = CFG.AUTO_EVENT and "🎯 Auto sự kiện (Bật)" or "🎯 Auto sự kiện (Tắt)"
    end)
    y = y + 38

    local btnEgg = makeBtn("🥚 Auto mở trứng (Bật)", y, function()
        CFG.AUTO_OPEN_EGG = not CFG.AUTO_OPEN_EGG
        btnEgg.Text = CFG.AUTO_OPEN_EGG and "🥚 Auto mở trứng (Bật)" or "🥚 Auto mở trứng (Tắt)"
    end)
    y = y + 38

    local btnHarvest = makeBtn("🍓 Auto hái bán (Bật)", y, function()
        CFG.AUTO_HARVEST = not CFG.AUTO_HARVEST
        btnHarvest.Text = CFG.AUTO_HARVEST and "🍓 Auto hái bán (Bật)" or "🍓 Auto hái bán (Tắt)"
    end)
    y = y + 38

    local btnUp = makeBtn("⬆️ Auto up lv pet (Bật)", y, function()
        CFG.AUTO_UP_PET = not CFG.AUTO_UP_PET
        btnUp.Text = CFG.AUTO_UP_PET and "⬆️ Auto up lv pet (Bật)" or "⬆️ Auto up lv pet (Tắt)"
    end)
    y = y + 45

    -- Nút đóng
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.3, 0, 0, 35)
    closeBtn.Position = UDim2.new(0.35, 0, 0, y + 10)
    closeBtn.Text = "Đóng"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    closeBtn.BorderColor3 = Color3.new(1, 1, 1)
    closeBtn.BorderSizePixel = 1
    closeBtn.Parent = main
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    return sg
end

-- Khởi tạo
log("Pet Hub khởi động")
createGUI()
spawn(mainLoop)

-- Phím Insert mở/tắt menu
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        local gui = LP:FindFirstChild("PlayerGui"):FindFirstChild("PetHubGUI")
        if gui then gui:Destroy() else createGUI() end
    end
end)

log("Sẵn sàng – nhấn Insert để mở menu")
