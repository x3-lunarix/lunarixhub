-- 🌙 Luna-Themed Loader with Floating Flowers 🌸

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

pcall(function() gethui().LunaLoader:Destroy() end)

local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Name = "LunaBlur"
blur.Parent = Lighting

local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "LunaLoader"
loaderGui.IgnoreGuiInset = true
loaderGui.ResetOnSpawn = false
loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
loaderGui.Parent = gethui()

local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Parent = loaderGui

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 180, 0, 180)
logo.Position = UDim2.new(0.5, -90, 0.4, -90)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://15844306310"
logo.ImageColor3 = Color3.fromRGB(255, 200, 255)
logo.Name = "LunaLogo"
logo.Parent = bg

-- 🌸 Floating Flower Emoji Effect
task.spawn(function()
	while loaderGui and loaderGui.Parent do
		local flower = Instance.new("TextLabel")
		flower.Text = "🌸"
		flower.Font = Enum.Font.GothamBold
		flower.TextScaled = true
		flower.TextColor3 = Color3.fromRGB(255, 200, 255)
		flower.Size = UDim2.new(0, 30, 0, 30)
		flower.Position = UDim2.new(math.random(), 0, 1, 0)
		flower.BackgroundTransparency = 1
		flower.ZIndex = 10
		flower.Parent = loaderGui

		local goal = {}
		goal.Position = UDim2.new(flower.Position.X.Scale, 0, 0, math.random(50, 150))
		goal.TextTransparency = 1

		local tween = TweenService:Create(flower, TweenInfo.new(3, Enum.EasingStyle.Linear), goal)
		tween:Play()
		tween.Completed:Connect(function()
			flower:Destroy()
		end)

		wait(0.2) -- new flower every 0.2s
	end
end)

-- Logo Pulse
task.spawn(function()
	while loaderGui and loaderGui.Parent do
		TweenService:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 200, 0, 200)
		}):Play()
		wait(1)
		TweenService:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 180, 0, 180)
		}):Play()
		wait(1)
	end
end)

-- Transition to main UI
task.delay(4, function()
	TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
	TweenService:Create(logo, TweenInfo.new(1), {ImageTransparency = 1}):Play()
	wait(1.2)
	loaderGui:Destroy()
	blur:Destroy()

	if _G and loadTrigonMainUI then
		pcall(loadTrigonMainUI)
	end
end)

_G.LunaLoaderRunning = true
