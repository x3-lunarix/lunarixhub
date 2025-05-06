

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/x3-lunarix/lunarixhub/refs/heads/main/dummyui.lua'))()

local Window = Library:Window({
	Title = 'Lunarix V2',
	Desc = '🎲 Bubble Gum Simulator INFINITY',
	Icon = 'moon-star',
	Theme = 'Dark',
	Config = {
		Keybind = Enum.KeyCode.RightControl,
		Size = UDim2.new(0, 530,0, 400)
	},
	CloseUIButton = {
		Enabled = true,
		Text = 'Close UI'
	}
})

Window:SelectTab(1)

local Tabs = {
	Main = Window:Tab({Title = 'Main', Icon = 'dumbbell'}),
	MainSec = Window:Tab({Title = 'Main 2', Icon = 'dumbbell'}),
	Settings = Window:Tab({Title = 'Settings', Icon = 'settings'})
}


local function AutoBubble()
    local args = {
        [1] = "BlowBubble"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))    
end


Tabs.Main:Section({Title = 'Main Section'})

Tabs.Main:Toggle({
    Title = 'Auto Bubbles',
    Desc = 'Auto Bubbles',
    Image = 'toggle-right',
    Value = false,
    Callback = function(v)
        AutoBubble = v
    end,
})

spawn(function()
    while task.wait()do
        if AutoBubble then
            pcall(function()
                AutoBubble()
            end)
        end
    end
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

Tabs.Main:Toggle({
    Title = 'Auto Sell',
    Desc = 'Auto Sell Bubbles',
    Image = 'toggle-right',
    Value = false,
    Callback = function(v)
        AutoSell = v
    end,
})

spawn(function()
    while task.wait()do
        if AutoSell then
            pcall(function()
                wait(3)
                game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(76.5057144, 9.86133862, -110.931541, 0.976196885, -3.09718928e-07, 0.216886282, 2.59595424e-07, 1, 2.59595481e-07, -0.216886282, -1.97113593e-07, 0.976196885)
                wait(3)
            end)
        end
    end
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local savedPosition = hrp.CFrame

function resetpos()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = player.Character.HumanoidRootPart.CFrame
    end
end

task.spawn(function()
    while true do
        wait(1)
        if AutoSell then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = savedPosition
            end
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    hrp = char:WaitForChild("HumanoidRootPart")
    if AutoSell then
        savedPosition = hrp.CFrame
    end
end)

Tabs.Main:Button({
    Title = 'Set Auto Sell Position',
    Desc = 'Set Default Position to comeback',
    Image = 'fingerprint',
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            savedPosition = player.Character.HumanoidRootPart.CFrame
        end
    end,
})

Tabs.Main:Button({
    Title = 'Reset Position Auto Sell',
    Desc = 'Reset Default Position to comeback',
    Image = 'fingerprint',
    Callback = function()
        resetpos()
    end,
})


Tabs.Main:Section({Title = 'Egg Section'})

local EggList = game:GetService("ReplicatedStorage").Assets.Eggs:GetChildren()

local eggNames = {}
for _, egg in pairs(EggList) do
    table.insert(eggNames, egg.Name)
end


local function HatchEgg()
    local args = {
        [1] = "HatchEgg",
        [2] = EggName,
        [3] = Eggmm
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))    
end

Tabs.Main:Dropdown({
    Title = 'Egg List',
    Desc = 'Egg List',
    Image = 'chevron-down',
    List = eggNames,
    Value = nil,
    Callback = function(v)
        EggName = v
    end,
})

Tabs.Main:Dropdown({
    Title = 'Select Egg Mode',
    Desc = 'Select Egg Mode',
    Image = 'chevron-down',
    List = {"1","3"},
    Value = '1',
    Callback = function(v)
        Eggmm = v
    end,
})

Tabs.Main:Toggle({
    Title = 'Auto Open Egg',
    Desc = 'Auto Egg',
    Image = 'toggle-right',
    Value = false,
    Callback = function(v)
        AutoOpenEgg = v
    end,
})

spawn(function()
    while task.wait do
        if AutoOpenEgg then
            pcall(function()
                HatchEgg()
            end)
        end
    end
end)
