-- FIX: tránh lỗi khi chưa load xong player
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- FIX: chống nil PlayerGui
repeat task.wait() until LP:FindFirstChild("PlayerGui")

local function log(m)
    print("[PetHub] " .. tostring(m))
end

-- FIX: safe Character
local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

-- FIX: interact an toàn hơn
local function interact(obj)
    if not obj then return false end

    pcall(function()
        if obj:FindFirstChild("ClickDetector") then
            fireclickdetector(obj.ClickDetector)
            return true
        elseif obj.Parent and obj.Parent:FindFirstChild("ClickDetector") then
            fireclickdetector(obj.Parent.ClickDetector)
            return true
        end
    end)

    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            pcall(function()
                child:FireServer(obj)
            end)
            return true
        end
    end

    return false
end

-- FIX: btn:Fire() -> Activate (nhiều executor lỗi Fire)
local function safeClick(btn)
    pcall(function()
        if btn.Activate then
            btn:Activate()
        elseif btn.MouseButton1Click then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- ========== CREATE PET ==========
local function createPet_Method1()
    log("Method1")
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        local btn = gui:FindFirstChild("CreateButton") or gui:FindFirstChild("CreatePet")
        if btn and btn:IsA("TextButton") then
            safeClick(btn)
            return true
        end
    end
end

local function createPet_Method2()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("pet") and obj.Name:lower():find("machine") then
            interact(obj)
            return true
        end
    end
end

local function createPet_Method3()
    for _, child in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name:lower():find("create") then
            pcall(function()
                child:FireServer()
            end)
            return true
        end
    end
end

local function createPet_Method4()
    local char = getChar()
    local tool = LP.Backpack:FindFirstChild("PetCreator") or (char and char:FindFirstChild("PetCreator"))
    if tool then
        pcall(function()
            tool:Activate()
        end)
        return true
    end
end

local function createPet_Method5()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("shop") or obj.Name:lower():find("store")) then
            interact(obj)
            return true
        end
    end
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
    if method then pcall(method) end
end

-- FIX: loop an toàn (tránh crash mobile)
local function mainLoop()
    while task.wait(CFG.CHECK_INTERVAL) do
        if not LP or not getChar() then continue end

        pcall(autoCreatePet)
        pcall(autoEvent)
        pcall(autoOpenEgg)
        pcall(autoHarvestSell)
        pcall(autoUpPet)
    end
end

-- FIX: spawn -> task.spawn (ổn định hơn)
task.spawn(mainLoop)
