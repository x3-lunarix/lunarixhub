-- 🌸 Combined Trigon Whitelist Checker with Lunix Loader UI
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local player = Players.LocalPlayer

-- Function to safely get gethui() or PlayerGui
local function getProperGuiParent()
    local success, coreGui = pcall(function() return gethui() end)
    if success and coreGui then
        return coreGui
    else
        warn("gethui() not available, defaulting to PlayerGui.")
        return player.PlayerGui
    end
end

local guiParent = getProperGuiParent()

-- Attempt to destroy any existing loader UI safely
pcall(function()
    if guiParent and guiParent:FindFirstChild("LunixLoader") then
        guiParent.LunixLoader:Destroy()
    end
end)

-- --- Blur Background ---
local blur = Instance.new("BlurEffect")
blur.Size = 30
blur.Name = "LunixBlur"
blur.Parent = Lighting

-- --- GUI Setup ---
local gui = Instance.new("ScreenGui")
gui.Name = "LunixLoader"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = guiParent -- Use the safely determined parent

local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 0
bg.Parent = gui

-- Elegant Logo (Central and prominent)
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 200, 0, 200)
logo.Position = UDim2.new(0.5, -100, 0.4, -100)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://15844306310"
logo.ImageColor3 = Color3.fromRGB(255, 180, 255)
logo.Name = "Logo"
logo.Parent = bg

-- --- Sakura Animation ---
task.spawn(function()
    while gui and gui.Parent do -- Keep running as long as the GUI exists
        local flower = Instance.new("TextLabel")
        flower.Text = "🌸"
        flower.Font = Enum.Font.Gotham
        flower.TextScaled = true
        flower.TextColor3 = Color3.fromRGB(255, 200, 255)
        flower.Size = UDim2.new(0, math.random(15, 25), 0, math.random(15, 25))
        flower.Position = UDim2.new(math.random(), 0, 1, 0) -- Start from random X, bottom of screen
        flower.BackgroundTransparency = 1
        flower.ZIndex = 10 -- Ensure flowers are above background
        flower.Rotation = math.random(0, 360)
        flower.Parent = gui

        local finalY = math.random(150, 250) -- Define target Y for falling
        local finalX = flower.Position.X.Scale + math.random(-3, 3) * 0.01 -- Add slight horizontal drift

        local goal = {
            Position = UDim2.new(finalX, 0, 0, finalY),
            TextTransparency = 1,
            Rotation = flower.Rotation + math.random(-60, 60),
            Size = UDim2.new(0, 0, 0, 0) -- Shrink as they fade
        }

        local tween = TweenService:Create(flower, TweenInfo.new(5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
        tween:Play()
        tween.Completed:Connect(function() flower:Destroy() end) -- Clean up flower after animation

        task.wait(0.15) -- Control spawn rate of flowers
    end
end)

-- --- Logo Pulse Animation ---
task.spawn(function()
    while gui and gui.Parent and logo and logo.Parent do -- Keep running as long as GUI and logo exist
        -- Enlarge and lighten color
        TweenService:Create(logo, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 210, 0, 210),
            ImageColor3 = Color3.fromRGB(255, 200, 255)
        }):Play()
        task.wait(2)
        -- Shrink back and revert color
        TweenService:Create(logo, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 200, 0, 200),
            ImageColor3 = Color3.fromRGB(255, 180, 255)
        }):Play()
        task.wait(2)
    end
end)

-- --- Trigon Whitelist Functions ---
local function gethwid()
    HWID = RbxAnalyticsService:GetClientId()
    return tostring(HWID)
end

local function getKeylink()
    return "https://trigonevo.fun/whitelist/?HWID=".. gethwid()
end

local function checkWhitelist()
    local hwid = gethwid()
    local url = "https://trigonevo.fun/whitelist/status.php?HWID=" .. hwid
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local success, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if success then
            if data.verified then
                return "Your HWID is verified! Expiration date: " .. tostring(data.expiration), true
            else
                return "HWID is not verified", false
            end
        else
            return "Failed to parse the response data", false
        end
    else
        return "Failed to fetch whitelist status: " .. response, false
    end
end

-- --- Key System Transition ---
task.delay(4.5, function() -- Delay before transitioning to key system UI
    -- Clean up initial elements smoothly
    if logo and logo.Parent then -- Check if logo still exists
        TweenService:Create(logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        task.delay(0.5, function() logo:Destroy() end) -- Destroy after fade
    end

    for _, child in pairs(gui:GetChildren()) do
        if child:IsA("TextLabel") and child.Text == "🌸" then
            TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.delay(0.5, function() child:Destroy() end) -- Destroy after fade
        end
    end

    -- Resize and reposition background frame for key system
    local targetSize = UDim2.new(0, 450, 0, 320)
    local targetPosition = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2)

    TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPosition,
        BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    }):Play()

    local corner = Instance.new("UICorner", bg) -- Rounded corners for the main frame
    corner.CornerRadius = UDim.new(0, 12)

    task.wait(0.8) -- Wait for background transition to complete

    -- --- Key System Elements ---

    -- Title
    local title = Instance.new("TextLabel", bg)
    title.Text = "✨ Trigon Whitelist ✨"
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 240, 255)
    title.BackgroundTransparency = 1
    title.ZIndex = 2

    -- Status text
    local statusText = Instance.new("TextLabel", bg)
    statusText.Text = "Checking whitelist status..."
    statusText.Size = UDim2.new(0.9, 0, 0, 60)
    statusText.Position = UDim2.new(0.05, 0, 0, 80)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 16
    statusText.TextColor3 = Color3.fromRGB(180, 180, 200)
    statusText.BackgroundTransparency = 1
    statusText.TextWrapped = true
    statusText.ZIndex = 2

    -- Function to update status text with animation
    local function updateStatus(text, isSuccess)
        statusText.Text = text
        if isSuccess then
            statusText.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            statusText.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
        -- Pulse animation
        TweenService:Create(statusText, TweenInfo.new(0.2), {TextSize = 18}):Play()
        task.wait(0.2)
        TweenService:Create(statusText, TweenInfo.new(0.2), {TextSize = 16}):Play()
    end

    -- Copy HWID Button
    local function createStylishButton(text, color, posX, callback)
        local btn = Instance.new("TextButton", bg)
        btn.Text = text
        btn.Size = UDim2.new(0.38, 0, 0, 40)
        btn.Position = UDim2.new(posX, 0, 0, 155)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 17
        btn.AutoButtonColor = false -- Disable default hover effect for custom
        btn.ZIndex = 2

        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 10)

        -- Custom hover effect: lighten color on mouse enter
        local defaultColor = color
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor:Lerp(Color3.fromRGB(255,255,255), 0.2)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play()
        end)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Copy Whitelist Link Button
    createStylishButton("Copy Link", Color3.fromRGB(80, 80, 120), 0.1, function()
        if type(setclipboard) == "function" then
            setclipboard(getKeylink())
            updateStatus("Whitelist link copied to clipboard!", true)
        else
            updateStatus("Couldn't copy to clipboard", false)
        end
    end)

    -- Check Whitelist Button
    local checkBtn = createStylishButton("Check Now", Color3.fromRGB(150, 90, 255), 0.52, function()
        local status, verified = checkWhitelist()
        updateStatus(status, verified)
        if verified then
            -- Success animation: fade and shrink the UI
            TweenService:Create(bg, TweenInfo.new(0.6), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0), -- Shrink to disappear
                Position = UDim2.new(0.5, 0, 0.5, 0) -- Shrink to center
            }):Play()
            task.wait(0.7) -- Wait for animation to finish
            gui:Destroy() -- Clean up GUI
            blur:Destroy() -- Clean up blur effect
            loadstring(game:HttpGet("https://raw.githubusercontent.com/relbaldski/bald/main/beta",true))()
        end
    end)

    -- Info text
    local keyInfo = Instance.new("TextLabel", bg)
    keyInfo.Text = "Your HWID: " .. gethwid()
    keyInfo.Size = UDim2.new(0.9, 0, 0, 20)
    keyInfo.Position = UDim2.new(0.05, 0, 0, 205)
    keyInfo.Font = Enum.Font.Gotham
    keyInfo.TextSize = 16
    keyInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
    keyInfo.BackgroundTransparency = 1
    keyInfo.ZIndex = 2

    -- Credit text at the bottom
    local credit = Instance.new("TextLabel", bg)
    credit.Text = "Powered by Trigon Evo"
    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -30) -- Positioned relative to bottom of parent
    credit.Font = Enum.Font.Gotham
    credit.TextSize = 14
    credit.TextColor3 = Color3.fromRGB(100, 100, 120)
    credit.BackgroundTransparency = 1
    credit.ZIndex = 2

    -- Automatic whitelist checking every 7 seconds
    task.spawn(function()
        while gui and gui.Parent do
            local status, verified = checkWhitelist()
            updateStatus(status, verified)
            if verified then
                -- Success animation: fade and shrink the UI
                TweenService:Create(bg, TweenInfo.new(0.6), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0), -- Shrink to disappear
                    Position = UDim2.new(0.5, 0, 0.5, 0) -- Shrink to center
                }):Play()
                task.wait(0.7) -- Wait for animation to finish
                gui:Destroy() -- Clean up GUI
                blur:Destroy() -- Clean up blur effect
                loadstring(game:HttpGet("https://raw.githubusercontent.com/relbaldski/bald/main/beta",true))()
                break
            end
            task.wait(7) -- Wait 7 seconds before checking again
        end
    end)
end)
