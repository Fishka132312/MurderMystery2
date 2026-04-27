-- 1. Защита от дублирования циклов
if _G.CoinEspRunning then
    _G.CoinEspRunning = false
    task.wait(0.5)
end
_G.CoinEspRunning = true

-- 2. Настройки (связанные с твоим меню)
_G.EspCoins = (_G.EspCoins ~= nil) and _G.EspCoins or false
_G.ColorCoins = _G.ColorCoins or Color3.fromRGB(255, 215, 0)
_G.CoinTransparency = _G.CoinTransparency or 0.3 -- Добавил прозрачность на всякий случай

local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

local ESP_STORAGE_NAME = "Coin_Highlights_Storage"
local Storage = CoreGui:FindFirstChild(ESP_STORAGE_NAME) or Instance.new("Folder", CoreGui)
Storage.Name = ESP_STORAGE_NAME

-- Функция создания обводки (Highlight) на конкретной детали
local function createHighlight(coinPart, uniqueId)
    if not coinPart or not coinPart:IsA("BasePart") then return end
    if Storage:FindFirstChild(uniqueId) then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = uniqueId
    highlight.Adornee = coinPart -- Обводит ТОЛЬКО MainCoin
    highlight.FillColor = _G.ColorCoins
    highlight.OutlineColor = Color3.new(1, 1, 1) -- Белый контур
    highlight.FillTransparency = _G.CoinTransparency
    highlight.OutlineTransparency = 0 -- Контур четкий
    highlight.Parent = Storage
end

-- 4. Основной цикл
task.spawn(function()
    while _G.CoinEspRunning do
        if _G.EspCoins then
            -- Ищем все объекты с тегом "CoinVisual"
            local coinContainers = CollectionService:GetTagged("CoinVisual")
            
            for _, container in pairs(coinContainers) do
                -- Проверка: не собрана ли монета (по твоим атрибутам)
                local isCollected = container:GetAttribute("Collected") or container:GetAttribute("Delete")
                
                -- Находим деталь MainCoin внутри контейнера (как на твоем скриншоте)
                local mainCoinPart = container:FindFirstChild("MainCoin")
                
                if mainCoinPart and not isCollected then
                    -- Используем ID контейнера, чтобы подсветка не дублировалась
                    local uniqueId = container:GetDebugId(10)
                    local existing = Storage:FindFirstChild(uniqueId)

                    if not existing then
                        createHighlight(mainCoinPart, uniqueId)
                    else
                        -- Обновление настроек в реальном времени
                        existing.FillColor = _G.ColorCoins
                        existing.FillTransparency = _G.CoinTransparency
                        existing.Adornee = mainCoinPart -- На всякий случай обновляем Adornee
                    end
                else
                    -- Если монета собрана или MainCoin нет — удаляем подсветку
                    local uniqueId = container:GetDebugId(10)
                    local existing = Storage:FindFirstChild(uniqueId)
                    if existing then existing:Destroy() end
                end
            end
            
            -- Очистка "призрачных" подсветок
            for _, hl in pairs(Storage:GetChildren()) do
                if not hl.Adornee or not hl.Adornee.Parent then
                    hl:Destroy()
                end
            end
        else
            -- Если ESP выключен в меню — удаляем всё
            Storage:ClearAllChildren()
        end
        
        task.wait(0.5) -- Оптимальная частота проверки
    end
end)

print("Coin Outline ESP (Targeted MainCoin) Loaded!")
