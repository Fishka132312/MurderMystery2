-- Защита от дублирования
if _G.CoinEspRunning then
    _G.CoinEspRunning = false
    task.wait(0.5)
end
_G.CoinEspRunning = true

-- Синхронизация с твоими переменными
_G.EspCoins = (_G.EspCoins ~= nil) and _G.EspCoins or false
_G.ColorCoins = _G.ColorCoins or Color3.fromRGB(255, 215, 0)

local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local ESP_NAME_SUFFIX = "_CoinHighlight"

-- Папка для хранения подсветок
local CoinEspFolder = CoreGui:FindFirstChild("Coin_ESP_Storage") or Instance.new("Folder", CoreGui)
CoinEspFolder.Name = "Coin_ESP_Storage"

local function applyHighlight(object)
    local espName = object:GetDebugId(10) .. ESP_NAME_SUFFIX
    local highlight = CoinEspFolder:FindFirstChild(espName)

    -- Если выключено или монета собрана (проверка атрибутов)
    local isCollected = object:GetAttribute("Collected") == true or object:GetAttribute("Delete") == true
    
    if not _G.EspCoins or isCollected then
        if highlight then highlight:Destroy() end
        return
    end

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = espName
        highlight.Adornee = object
        highlight.Parent = CoinEspFolder
        print("Создана подсветка для: " .. object.Name) -- Удали потом, если мешает
    end

    highlight.FillColor = _G.ColorCoins
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Enabled = true
end

task.spawn(function()
    print("Coin ESP запущен, жду включения кнопки...")
    while _G.CoinEspRunning do
        if _G.EspCoins then
            -- 1. Ищем по тегу (как в твоем исходнике)
            for _, coin in pairs(CollectionService:GetTagged("CoinVisual")) do
                applyHighlight(coin)
            end
            
            -- 2. Дополнительный поиск: если теги не работают, ищем в Workspace по имени
            -- В MM2 монеты часто лежат в папке "Normal" или называются "CoinContainer"
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "CoinVisual" or obj.Name == "CoinContainer" then
                    applyHighlight(obj)
                end
            end
        else
            -- Если кнопка выключена — чистим всё
            CoinEspFolder:ClearAllChildren()
        end

        -- Очистка "мертвых" ссылок
        for _, v in pairs(CoinEspFolder:GetChildren()) do
            if not v.Adornee or not v.Adornee.Parent then
                v:Destroy()
            end
        end

        task.wait(1)
    end
end)
