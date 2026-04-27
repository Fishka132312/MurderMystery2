-- 1. Защита от дублирования циклов
if _G.CoinEspRunning then
    _G.CoinEspRunning = false
    task.wait(0.5)
end
_G.CoinEspRunning = true

-- 2. Настройки (связанные с твоим меню)
_G.GunTransparency = _G.GunTransparency or 0.3
_G.EspCoins = (_G.EspCoins ~= nil) and _G.EspCoins or false
_G.ColorCoins = _G.ColorCoins or Color3.fromRGB(255, 215, 0)
_G.CoinTransparency = _G.CoinTransparency or 0.3

-- Настройки для Пистолета
_G.EspGun = (_G.EspGun ~= nil) and _G.EspGun or false
_G.ColorGun = _G.ColorGun or Color3.fromRGB(255, 150, 0) -- Оранжевый по дефолту

local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local ESP_STORAGE_NAME = "MM2_Objects_Storage"
local Storage = CoreGui:FindFirstChild(ESP_STORAGE_NAME) or Instance.new("Folder", CoreGui)
Storage.Name = ESP_STORAGE_NAME

-- Универсальная функция создания подсветки
local function createHighlight(target, uniqueId, color, transparency)
    if not target then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = uniqueId
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = transparency
    highlight.OutlineTransparency = 0 
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = Storage
end

-- Основной цикл
task.spawn(function()
    while _G.CoinEspRunning do
        --- ЛОГИКА МОНЕТ ---
        if _G.EspCoins then
            local coinContainers = CollectionService:GetTagged("CoinVisual")
            for _, container in pairs(coinContainers) do
                local isCollected = container:GetAttribute("Collected") or container:GetAttribute("Delete")
                local mainCoinPart = container:FindFirstChild("MainCoin")
                local uniqueId = "Coin_" .. container:GetDebugId(10)

                if mainCoinPart and not isCollected then
                    local existing = Storage:FindFirstChild(uniqueId)
                    if not existing then
                        createHighlight(mainCoinPart, uniqueId, _G.ColorCoins, _G.CoinTransparency)
                    else
                        existing.FillColor = _G.ColorCoins
                        existing.FillTransparency = _G.CoinTransparency
                    end
                else
                    local existing = Storage:FindFirstChild(uniqueId)
                    if existing then existing:Destroy() end
                end
            end
        end

        --- ЛОГИКА ВЫПАВШЕГО ПИСТОЛЕТА (УЛУЧШЕННАЯ) ---
        if _G.EspGun then
            -- Собираем список: сначала по тегу, потом по поиску в Workspace
            local targets = CollectionService:GetTagged("GunDrop")
            
            -- Если тегов нет, ищем вручную по имени "GunDrop" во всем Workspace
            if #targets == 0 then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" then
                        table.insert(targets, obj)
                    end
                end
            end

            for _, gun in pairs(targets) do
                local uniqueId = "Gun_" .. gun:GetDebugId(10)
                local existing = Storage:FindFirstChild(uniqueId)

                -- Проверяем, что это деталь или модель и она в игре
                if gun.Parent ~= nil then
                    if not existing then
                        createHighlight(gun, uniqueId, _G.ColorGun, _G.GunTransparency)
                    else
                        existing.FillColor = _G.ColorGun
                        existing.FillTransparency = _G.GunTransparency
                    end
                end
            end
        end

        --- ОБЩАЯ ОЧИСТКА ---
        for _, hl in pairs(Storage:GetChildren()) do
            local isCoinHl = hl.Name:find("Coin_")
            local isGunHl = hl.Name:find("Gun_")

            if (isCoinHl and not _G.EspCoins) or (isGunHl and not _G.EspGun) then
                hl:Destroy()
            elseif not hl.Adornee or not hl.Adornee.Parent or (isGunHl and hl.Adornee.Name ~= "GunDrop") then
                hl:Destroy()
            end
        end

        task.wait(0.5)
    end
end)

print("MM2 Objects ESP (Coins & GunDrop) Loaded!")
