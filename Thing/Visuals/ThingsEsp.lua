-- 1. Защита от дублирования циклов
if _G.CoinEspRunning then
    _G.CoinEspRunning = false
    task.wait(0.5)
end
_G.CoinEspRunning = true

-- 2. Настройки (связываем с твоим меню)
_G.EspCoins = (_G.EspCoins ~= nil) and _G.EspCoins or false
_G.ColorCoins = _G.ColorCoins or Color3.fromRGB(255, 215, 0)

local CollectionService = game:GetService("CollectionService")
local ESP_NAME = "CoinESP_Marker"

-- 3. Функция создания маркера (твоя рабочая логика)
local function createESP(object)
    if not object or object:FindFirstChild(ESP_NAME) then return end
    
    local part = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = ESP_NAME
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.Adornee = part
    billboard.Parent = part

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = _G.ColorCoins -- Используем цвет из меню
    frame.BackgroundTransparency = 0.3
    frame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
end

-- 4. Основной цикл
task.spawn(function()
    while _G.CoinEspRunning do
        -- Если кнопка в меню ВКЛЮЧЕНА
        if _G.EspCoins then
            for _, coin in pairs(CollectionService:GetTagged("CoinVisual")) do
                local isCollected = coin:GetAttribute("Collected") or coin:GetAttribute("Delete")
                
                if not isCollected then
                    createESP(coin)
                    -- Обновляем цвет существующего маркера (если поменяли в Colorpicker)
                    local existing = coin:FindFirstChild(ESP_NAME)
                    if existing and existing:FindFirstChild("Frame") then
                        existing.Frame.BackgroundColor3 = _G.ColorCoins
                    end
                else
                    -- Если монета собрана — удаляем
                    if coin:FindFirstChild(ESP_NAME) then
                        coin[ESP_NAME]:Destroy()
                    end
                end
            end
        else
            -- Если кнопка в меню ВЫКЛЮЧЕНА — удаляем все маркеры
            for _, coin in pairs(CollectionService:GetTagged("CoinVisual")) do
                if coin:FindFirstChild(ESP_NAME) then
                    coin[ESP_NAME]:Destroy()
                end
            end
        end
        
        task.wait(1) -- Проверка каждую секунду
    end
end)

print("Coin ESP Loaded and Synced!")
