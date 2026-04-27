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
_G.ColorGun = _G.ColorGun or Color3.fromRGB(170, 0, 255) -- Фиолетовый

local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local ESP_STORAGE_NAME = "MM2_Objects_Storage"
local Storage = CoreGui:FindFirstChild(ESP_STORAGE_NAME) or Instance.new("Folder", CoreGui)
Storage.Name = ESP_STORAGE_NAME

-- Универсальная функция создания подсветки
local function createHighlight(target, uniqueId, color, transparency, text)
    if not target then return end
    
    -- Сама подсветка
    local highlight = Instance.new("Highlight")
    highlight.Name = uniqueId
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = transparency
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = Storage

    -- Надпись (если передали текст)
    if text then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = uniqueId .. "_Text"
        billboard.Adornee = target
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0) -- Высота текста над пушкой
        billboard.AlwaysOnTop = true
        billboard.Parent = Storage

        local label = Instance.new("TextLabel")
        label.Parent = billboard
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = text
        label.TextColor3 = color
        label.TextStrokeTransparency = 0 -- Чтобы текст был читаемым
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
    end
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
                    if existing then 
                        -- Удаляем текст монеты, если он был (на случай если решишь добавить)
                        local textLabel = Storage:FindFirstChild(uniqueId .. "_Text")
                        if textLabel then textLabel:Destroy() end
                        existing:Destroy() 
                    end
                end
            end
        end

        --- ЛОГИКА ВЫПАВШЕГО ПИСТОЛЕТА (УЛУЧШЕННАЯ) ---
        if _G.EspGun then
            local targets = CollectionService:GetTagged("GunDrop")
            
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

                if gun.Parent ~= nil then
                    if not existing then
                        -- Создаем подсветку и текст "Gun Drop"
                        createHighlight(gun, uniqueId, _G.ColorGun, _G.GunTransparency, "Gun Drop")
                    else
                        -- Обновляем цвет и прозрачность подсветки
                        existing.FillColor = _G.ColorGun
                        existing.FillTransparency = _G.GunTransparency

                        -- Обновляем цвет текста
                        local textLabel = Storage:FindFirstChild(uniqueId .. "_Text")
                        if textLabel and textLabel:FindFirstChild("TextLabel") then
                            textLabel.TextLabel.TextColor3 = _G.ColorGun
                        end
                    end
                end
            end
        end

        --- ОБЩАЯ ОЧИСТКА ---
        for _, hl in pairs(Storage:GetChildren()) do
            -- Пропускаем сами объекты текста в этом цикле, так как мы удаляем их вместе с Highlight
            if hl:IsA("Highlight") then
                local isCoinHl = hl.Name:find("Coin_")
                local isGunHl = hl.Name:find("Gun_")
                local shouldDestroy = false

                -- Проверка условий удаления
                if (isCoinHl and not _G.EspCoins) or (isGunHl and not _G.EspGun) then
                    shouldDestroy = true
                elseif not hl.Adornee or not hl.Adornee.Parent or (isGunHl and hl.Adornee.Name ~= "GunDrop") then
                    shouldDestroy = true
                end

                if shouldDestroy then
                    -- Находим и удаляем связанный текст ПЕРЕД удалением Highlight
                    local textLabel = Storage:FindFirstChild(hl.Name .. "_Text")
                    if textLabel then 
                        textLabel:Destroy() 
                    end
                    hl:Destroy()
                end
            end
        end

        task.wait(0.5)
    end
end)

print("MM2 Objects ESP (Coins & GunDrop) Loaded!")
