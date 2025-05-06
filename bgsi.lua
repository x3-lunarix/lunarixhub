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
}

local autoBubbleEnabled = false

local function AutoBubble()
	local args = { "BlowBubble" }
	game:GetService("ReplicatedStorage")
		.Shared.Framework.Network.Remote.Event:FireServer(unpack(args))
end

Tabs.Main:Section({Title = 'Main Section'})

Tabs.Main:Toggle({
	Title = 'Auto Bubbles',
	Desc = 'Auto Bubbles',
	Image = 'toggle-right',
	Value = false,
	Callback = function(v)
		autoBubbleEnabled = v
	end,
})

task.spawn(function()
	while task.wait(0.5) do 
		if autoBubbleEnabled then
			pcall(AutoBubble)
		end
	end
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local autoSellEnabled = false
local savedPosition = hrp.CFrame

local sellCFrame = CFrame.new(76.5057144, 9.86133862, -110.931541)

Tabs.Main:Toggle({
	Title = 'Auto Sell',
	Desc = 'Auto Sell Bubbles',
	Image = 'toggle-right',
	Value = false,
	Callback = function(v)
		autoSellEnabled = v
	end,
})

task.spawn(function()
	while task.wait(5) do 
		if autoSellEnabled then
			pcall(function()
				hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = sellCFrame
					task.wait(1.5)
					hrp.CFrame = savedPosition
				end
			end)
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	hrp = char:WaitForChild("HumanoidRootPart")
	if autoSellEnabled then
		savedPosition = hrp.CFrame
	end
end)

Tabs.Main:Button({
	Title = 'Set Auto Sell Position',
	Desc = 'Set Default Position to comeback',
	Image = 'fingerprint',
	Callback = function()
		if hrp then
			savedPosition = hrp.CFrame
		end
	end,
})

Tabs.Main:Button({
	Title = 'Reset Position Auto Sell',
	Desc = 'Reset Default Position to comeback',
	Image = 'fingerprint',
	Callback = function()
		if hrp then
			savedPosition = hrp.CFrame
		end
	end,
})

Tabs.Main:Section({Title = 'Egg Section'})

local eggNames = {}
for _, egg in pairs(game:GetService("ReplicatedStorage").Assets.Eggs:GetChildren()) do
	table.insert(eggNames, egg.Name)
end

local EggName = nil
local Eggmm = "1"

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

local function HatchEgg()
	if EggName and Eggmm then
		local args = { "HatchEgg", EggName, Eggmm }
		game:GetService("ReplicatedStorage")
			.Shared.Framework.Network.Remote.Event:FireServer(unpack(args))
	end
end

local autoHatchEnabled = false

Tabs.Main:Toggle({
	Title = 'Auto Open Egg',
	Desc = 'Auto Egg',
	Image = 'toggle-right',
	Value = false,
	Callback = function(v)
		autoHatchEnabled = v
	end,
})

task.spawn(function()
	while task.wait(1) do 
		if autoHatchEnabled then
			pcall(HatchEgg)
		end
	end
end)
