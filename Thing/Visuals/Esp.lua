local ColorInnocent = Color3.fromRGB(0, 255, 0)
local ColorSheriff = Color3.fromRGB(0, 0, 255)
local ColorMurderer = Color3.fromRGB(255, 0, 0)
local ColorHero = Color3.fromRGB(255, 255, 0)
local ColorDead = Color3.fromRGB(255, 255, 255)

_G.EspAll = false
_G.EspSheriff = false
_G.EspMurder = false

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))

local EspFolder = CoreGui:FindFirstChild("ESP_Storage") or Instance.new("Folder", CoreGui)
EspFolder.Name = "ESP_Storage"

local function GetPlayerData(player)
    local data = CurrentRoundClient.PlayerData
    if data and data[player.Name] then
        return data[player.Name]
    end
    
    for _, v in pairs(data or {}) do
        if v.Name == player.Name or v.Player == player then
            return v
        end
    end
    return nil
end

local function GetPlayerRole(player)
    local data = GetPlayerData(player)
    if data then
        if data.Dead then return "Dead" end
        return data.Role
    end

    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    
    if (char and (char:FindFirstChild("Knife") or char:FindFirstChild("Slasher"))) or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("Slasher"))) then
        return "Murderer"
    end
    
    if (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) then
        return "Sheriff"
    end
    
    return "Innocent"
end

local function UpdateESP(player)
    local character = player.Character
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")

    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        if highlight then highlight:Destroy() end
        return 
    end

    local role = GetPlayerRole(player)
    local isEnabled = false
    local targetColor = ColorInnocent

    if role == "Dead" then
        isEnabled = _G.EspAll
        targetColor = ColorDead
    elseif role == "Murderer" then
        isEnabled = _G.EspMurder
        targetColor = ColorMurderer
    elseif role == "Sheriff" then
        isEnabled = _G.EspSheriff
        targetColor = ColorSheriff
    elseif role == "Hero" then
        isEnabled = _G.EspSheriff or _G.EspAll
        targetColor = ColorHero
    else
        isEnabled = _G.EspAll
        targetColor = ColorInnocent
    end

    if isEnabled then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = player.Name .. "_ESP"
            highlight.Parent = EspFolder
        end
        highlight.Adornee = character
        highlight.FillColor = targetColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = (role == "Dead") and 0.8 or 0.5
        highlight.Enabled = true
    else
        if highlight then highlight:Destroy() end
    end
end

task.spawn(function()
    while task.wait(0.3) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                UpdateESP(player)
            end
        end
        
        for _, obj in pairs(EspFolder:GetChildren()) do
            local name = obj.Name:gsub("_ESP", "")
            if not Players:FindFirstChild(name) then
                obj:Destroy()
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")
    if highlight then highlight:Destroy() end
end)
