local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "MeowlSploit", HidePremium = false, SaveConfig = true, ConfigFolder = "MurderMeowlSploit"})

local scripts = {
    '',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/'

task.spawn(function()
    for i, scriptName in ipairs(scripts) do
        local fullUrl = baseUrl .. scriptName
        
        local success, err = pcall(function()
            local code = game:HttpGet(fullUrl)
            if code then
                loadstring(code)()
            else
                warn("Не удалось получить код для: " .. scriptName)
            end
        end)
        
        if not success then
            warn("Ошибка при загрузке " .. scriptName .. ": " .. tostring(err))
        end
        
        task.wait(0.7) 
    end
end)


-------------------------Shader---------------------------

local Tab = Window:MakeTab({
	Name = "Shaders",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Shaders"
})

Tab:AddButton({
	Name = "Meowl Shaders",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/Shaders/MeowlShaders.lua'))()  
  	end    
})

-------------------------Custom Skin---------------------------

local Tab = Window:MakeTab({
	Name = "Custom Skin",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Free Skins"
})

local selectedSkin = "None" 

local SkinSelector = Tab:AddDropdown({
    Name = "Choose skin",
    Default = "None",
    Options = {"Loading..."},
    Callback = function(Value)
        selectedSkin = Value
        _G.CurrentSkinName = Value
        
        if _G.IsSkinActive and selectedSkin ~= "None" and selectedSkin ~= "Loading..." and selectedSkin ~= "Ошибка базы" then
            if _G.ApplySkin then
                _G.ApplySkin(selectedSkin)
            end
        end
    end     
})

task.spawn(function()
    local timeout = 0
    while (not _G.SkinNames or #_G.SkinNames == 0) and timeout < 10 do
        task.wait(0.5)
        timeout = timeout + 0.5
    end

    if _G.SkinNames and #_G.SkinNames > 0 then
        local options = {"None"}
        for _, name in ipairs(_G.SkinNames) do
            table.insert(options, name)
        end
        SkinSelector:Refresh(options, true)
    else
        SkinSelector:Refresh({"Error: No Skins Found"}, true)
    end
end)

Tab:AddToggle({
    Name = "Enable Skin Changer",
    Default = false,
    Callback = function(Value)
        _G.IsSkinActive = Value 
        
        if Value then
            if selectedSkin and selectedSkin ~= "None" and selectedSkin ~= "Loading..." and selectedSkin ~= "Error: No Skins Found" then
                if _G.ApplySkin then
                    _G.ApplySkin(selectedSkin)
                end
            else
                warn("Скин не выбран!")
                _G.IsSkinActive = false
            end
        else
            if _G.RestoreOriginal then
                _G.RestoreOriginal()
            end
        end
    end    
})

--------------------------------MISC-----------------------------

local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Tools"
})

Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})

Tab:AddButton({
	Name = "Destroy Gui",
	Callback = function()
    OrionLib:Destroy()
    end    
})

OrionLib:Init()
