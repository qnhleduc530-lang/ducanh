-- LOAD SAFE
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

repeat task.wait() until LP
repeat task.wait() until LP:FindFirstChild("PlayerGui")

-- CONFIG
local CFG = {
    CHECK_INTERVAL = 1,
    FARM_DIST = 10,
    SPEED = 50,
    PET_CREATE_MODE = 1
}

local function log(m)
    print("[PetHub] " .. tostring(m))
end

local function safe(f)
    pcall(f)
end

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

-- INTERACT
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

    return false
end

local function safeClick(btn)
    pcall(function()
        if btn.Activate then
            btn:Activate()
        elseif btn.MouseButton1Click then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- CREATE PET METHODS
local function createPet_Method1()
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
        if obj:IsA("BasePart") and obj.Name:lower():find("pet") then
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
        if obj:IsA("BasePart") and obj.Name:lower():find("shop") then
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
    if method then safe(method) end
end

-- MAIN LOOP
task.spawn(function()
    while task.wait(CFG.CHECK_INTERVAL) do
        if not LP then continue end

        safe(autoCreatePet)
    end
end)

log("Script Loaded!")
