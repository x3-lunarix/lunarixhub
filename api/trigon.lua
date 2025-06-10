-- 🌸 Lunix Loader with Sakura + Krnl UI + Key System (Final Refined & Nil-Safe Version)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") -- HttpService is standard, but some environments might restrict it.
local Lighting = game:GetService("Lighting")
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

-- --- Key System Logic ---
local keyFile = "lunix_key_data.txt" -- Local file to save the key
local savedKey = ""

pcall(function() -- Safely attempt to read the saved key
    if type(readfile) == "function" then -- Check if readfile exists
        savedKey = readfile(keyFile)
    else
        warn("readfile() not available, key persistence disabled.")
    end
end)

---
## Lunix Key System UI Transition
---
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
    title.Text = "✨ Lunix Hub Access ✨"
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 240, 255)
    title.BackgroundTransparency = 1
    title.ZIndex = 2

    -- Key Input Box
    local box = Instance.new("TextBox", bg)
    box.PlaceholderText = "Enter your secret key here..."
    box.Text = savedKey
    box.Size = UDim2.new(0.8, 0, 0, 45)
    box.Position = UDim2.new(0.1, 0, 0, 90)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    box.TextColor3 = Color3.fromRGB(220, 220, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 18
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.ZIndex = 2

    local boxCorner = Instance.new("UICorner", box)
    boxCorner.CornerRadius = UDim.new(0, 10)

    -- Function to create stylized buttons
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

    -- Get Key Button
    createStylishButton("Get Key", Color3.fromRGB(80, 80, 120), 0.1, function()
        if type(setclipboard) == "function" then -- Check if setclipboard exists
            setclipboard("https://lunixhub.xyz/getkey")
        else
            warn("setclipboard() not available.")
        end
        -- Attempt to make an HTTP request if `syn` is available (for certain exploit contexts)
        if _G.syn and type(_G.syn.request) == "function" then -- Check if syn.request exists
            _G.syn.request({Url="https://lunixhub.xyz/getkey", Method="GET"})
        else
            warn("syn.request() not available.")
        end
        -- Provide immediate feedback to the user
        box.Text = "Link copied!"
        box.PlaceholderColor3 = Color3.fromRGB(150, 255, 150) -- Greenish tint for success
        task.delay(2, function()
            box.Text = savedKey -- Revert text after a short delay
            box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150) -- Revert placeholder color
        end)
    end)

    -- Verify Key Button
    createStylishButton("Verify Key", Color3.fromRGB(150, 90, 255), 0.52, function()
        -- IMPORTANT: Replace "LUNIX-2025-ACCESS-KEY" with your actual valid key
        if box.Text == "LUNIX-2025-ACCESS-KEY" then
            if type(writefile) == "function" then -- Check if writefile exists
                writefile(keyFile, box.Text) -- Save key if valid
            else
                warn("writefile() not available, key will not be saved.")
            end
            -- Success animation: fade and shrink the UI
            TweenService:Create(bg, TweenInfo.new(0.6), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0), -- Shrink to disappear
                Position = UDim2.new(0.5, 0, 0.5, 0) -- Shrink to center
            }):Play()
            task.wait(0.7) -- Wait for animation to finish
            gui:Destroy() -- Clean up GUI
            blur:Destroy() -- Clean up blur effect
            if _G and type(_G.loadTrigonMainUI) == "function" then -- Check if loadTrigonMainUI exists
                pcall(_G.loadTrigonMainUI) -- Attempt to load main UI if available
            else
                warn("loadTrigonMainUI() not available or not a function.")
            end
        else
            -- Invalid Key feedback
            box.Text = ""
            box.PlaceholderText = "❌ Invalid Key! Try again."
            box.PlaceholderColor3 = Color3.fromRGB(255, 80, 80) -- Red for error
            -- Shake animation for input box
            TweenService:Create(box, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 3, true), {
                Position = box.Position:Add(UDim2.new(0, 5, 0, 0)) -- Shake horizontally
            }):Play()
            task.delay(2, function()
                box.PlaceholderText = "Enter your secret key here..." -- Revert placeholder text
                box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150) -- Revert placeholder color
            end)
        end
    end)

    -- Info text for the key system
    local keyInfo = Instance.new("TextLabel", bg)
    keyInfo.Text = "Enter your key to unlock Lunix features."
    keyInfo.Size = UDim2.new(0.9, 0, 0, 20)
    keyInfo.Position = UDim2.new(0.05, 0, 0, 205)
    keyInfo.Font = Enum.Font.Gotham
    keyInfo.TextSize = 16
    keyInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
    keyInfo.BackgroundTransparency = 1
    keyInfo.ZIndex = 2

    -- Credit text at the bottom
    local credit = Instance.new("TextLabel", bg)
    credit.Text = "Powered by Lunix Hub"
    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -30) -- Positioned relative to bottom of parent
    credit.Font = Enum.Font.Gotham
    credit.TextSize = 14
    credit.TextColor3 = Color3.fromRGB(100, 100, 120)
    credit.BackgroundTransparency = 1
    credit.ZIndex = 2
end)
