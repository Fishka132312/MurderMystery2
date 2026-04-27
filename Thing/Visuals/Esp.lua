-- 1. Защита от дублирования циклов
if _G.EspRunning then
    _G.EspRunning = false
    task.wait(0.5)
end
_G.EspRunning = true

-- 2. Глобальные настройки (сохраняются при перезапуске)
_G.ColorInnocent = _G.ColorInnocent or Color3.fromRGB(0, 255, 0)
_G.ColorSheriff = _G.ColorSheriff or Color3.fromRGB(0, 0, 255)
_G.ColorMurderer = _G.ColorMurderer or Color3.fromRGB(255, 0, 0)
_G.ColorHero = _G.ColorHero or Color3.fromRGB(255, 255, 0)
_G.ColorDead = _G.ColorDead or Color3.fromRGB(255, 255, 255)
_G.ColorCoins = _G.ColorCoins or Color3.fromRGB(255, 215, 0)

_G.EspAll = (_G.EspAll ~= nil) and _G.EspAll or false
_G.EspSheriff = (_G.EspSheriff ~= nil) and _G.EspSheriff or false
_G.EspMurder = (_G.EspMurder ~= nil) and _G.EspMurder or false
_G.EspCoins = (_G.EspCoins ~= nil) and _G.EspCoins or false

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))

-- Очистка старой папки
if CoreGui:FindFirstChild("ESP_Storage") then
    CoreGui.ESP_Storage:Destroy()
end

local EspFolder = Instance.new("Folder", CoreGui)
EspFolder.Name = "ESP_Storage"

-- ФУНКЦИИ ОПРЕДЕЛЕНИЯ РОЛЕЙ
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

-- ОБНОВЛЕНИЕ ESP ИГРОКОВ
local function UpdatePlayerESP(player)
    local character = player.Character
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")

    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        if highlight then highlight:Destroy() end
        return 
    end

    local role = GetPlayerRole(player)
    local isEnabled = false
    local targetColor = _G.ColorInnocent

    if role == "Dead" then
        isEnabled = _G.EspAll
        targetColor = _G.ColorDead
    elseif role == "Murderer" then
        isEnabled = _G.EspMurder
        targetColor = _G.ColorMurderer
    elseif role == "Sheriff" then
        isEnabled = _G.EspSheriff
        targetColor = _G.ColorSheriff
    elseif role == "Hero" then
        isEnabled = _G.EspSheriff
        targetColor = _G.ColorHero
    else
        isEnabled = _G.EspAll
        targetColor = _G.ColorInnocent
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

-- ОБНОВЛЕНИЕ ESP МОНЕТ
local function UpdateCoinESP()
    if not _G.EspCoins then
        for _, obj in pairs(EspFolder:GetChildren()) do
            if obj.Name:find("Coin_") then obj:Destroy() end
        end
        return
    end

    for _, coin in pairs(CollectionService:GetTagged("CoinVisual")) do
        local coinID = coin:GetAttribute("CoinID") or coin.Name
        local coinKey = "Coin_" .. tostring(coinID)
        local highlight = EspFolder:FindFirstChild(coinKey)
        
        -- Проверяем: не собрана ли она и не исчезла ли (прозрачность)
        local isCollected = coin:GetAttribute("Collected") or coin:GetAttribute("Delete")
        local isVisible = coin.Transparency < 0.9 -- Если прозрачность большая, значит монетка собрана

        if isVisible and not isCollected and coin.Parent ~= nil then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = coinKey
                highlight.Parent = EspFolder
            end
            highlight.Adornee = coin
            highlight.FillColor = _G.ColorCoins
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.4
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
        else
            if highlight then highlight:Destroy() end
        end
    end
end

-- ГЛАВНЫЙ ЦИКЛ
task.spawn(function()
    while _G.EspRunning do
        -- Обновляем игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                UpdatePlayerESP(player)
            end
        end
        
        -- Обновляем монеты
        UpdateCoinESP()
        
        -- Очистка мусора (удаленные игроки)
        for _, obj in pairs(EspFolder:GetChildren()) do
            if not obj.Name:find("Coin_") then
                local name = obj.Name:gsub("_ESP", "")
                if not Players:FindFirstChild(name) then
                    obj:Destroy()
                end
            end
        end
        task.wait(0.3)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local highlight = EspFolder:FindFirstChild(player.Name .. "_ESP")
    if highlight then highlight:Destroy() end
end)
