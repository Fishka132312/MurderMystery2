local ColorInnocent = Color3.fromRGB(0, 255, 0)
local ColorSheriff = Color3.fromRGB(0, 0, 255)
local ColorMurderer = Color3.fromRGB(255, 0, 0)

_G.EspAll = false
_G.EspSheriff = false
_G.EspMurder = false

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))

local EspFolder = CoreGui:FindFirstChild("ESP_Storage") or Instance.new("Folder", CoreGui)
EspFolder.Name = "ESP_Storage"

local function GetRoleFromModule(player)
    local data = CurrentRoundClient.PlayerData
    if data and data[player.Name] then
        return data[player.Name].Role
    end
    
    for _, v in pairs(data or {}) do
        if v.Name == player.Name or v.Player == player then
            return v.Role
        end
    end
    return nil
end

local function GetPlayerRole(player)
    local moduleRole = GetRoleFromModule(player)
    if moduleRole then return moduleRole end

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
    if player == Players.LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        local old = EspFolder:FindFirstChild(player.Name .. "_ESP")
        if old then old:Destroy() end
        return 
    end

    local role = GetPlayerRole(player)
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")

    local isEnabled = false
    local targetColor = ColorInnocent

    if role == "Murderer" then
        isEnabled = _G.EspMurder
        targetColor = ColorMurderer
    elseif role == "Sheriff" then
        isEnabled = _G.EspSheriff
        targetColor = ColorSheriff
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
        highlight.FillTransparency = 0.5
        highlight.Enabled = true
    else
        if highlight then highlight:Destroy() end
    end
end

task.spawn(function()
    while task.wait(0.3) do
        for _, player in pairs(Players:GetPlayers()) do
            UpdateESP(player)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")
    if highlight then highlight:Destroy() end
end)