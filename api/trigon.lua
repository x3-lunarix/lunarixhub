local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear previous UI instances
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name == "TrigonLunaLoader" or gui.Name == "TrigonLunaMain" then
        gui:Destroy()
    end
end

-- Theme Colors
local Colors = {
    Background = Color3.fromRGB(255, 255, 255),        -- White background
    PanelBg = Color3.fromRGB(245, 247, 250),           -- Light gray panel background
    TextPrimary = Color3.fromRGB(17, 24, 39),          -- Dark gray text
    TextSecondary = Color3.fromRGB(107, 114, 128),     -- Neutral gray text
    Accent = Color3.fromRGB(79, 70, 229),              -- Indigo base accent
    AccentLight = Color3.fromRGB(199, 210, 254),       -- Indigo lighter accent for hover
    ShadowColor = Color3.fromRGB(200, 210, 230),       -- Soft shadow color
    ButtonBg = Color3.fromRGB(251, 253, 255),          -- Button background (almost white)
    ButtonHoverBg = Color3.fromRGB(229, 231, 235),     -- Button hover color
    ButtonActiveBg = Color3.fromRGB(79, 70, 229),      -- Button active/highlight color
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_SEMIBOLD = Enum.Font.GothamSemibold
local FONT_REGULAR = Enum.Font.Gotham

local BaseZIndex = 1000
local CornerRadius = UDim.new(0, 16)

-- Utility: Create rounded frame with subtle shadow
local function CreateRoundedFrame(parent, size, position, bgColor, name, zindex)
    local frame = Instance.new("Frame")
    frame.Name = name or "RoundedFrame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = bgColor or Colors.PanelBg
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.ZIndex = zindex or BaseZIndex
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CornerRadius
    corner.Parent = frame

    local shadow = Instance.new("Frame")
    shadow.Name = frame.Name .. "_Shadow"
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundColor3 = Colors.ShadowColor
    shadow.ZIndex = (zindex or BaseZIndex) - 1
    shadow.AnchorPoint = Vector2.new(0, 0)
    shadow.BorderSizePixel = 0
    shadow.Transparency = 0.7
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = CornerRadius
    shadowCorner.Parent = shadow

    return frame
end

-- Create Loader GUI --
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "TrigonLunaLoader"
loaderGui.ResetOnSpawn = false
loaderGui.DisplayOrder = BaseZIndex + 100
loaderGui.Parent = playerGui

local loaderFrame = CreateRoundedFrame(loaderGui,
    UDim2.new(0, 450, 0, 120),
    UDim2.new(0.5, 0, 0.5, 0),
    Colors.PanelBg,
    "LoaderFrame",
    BaseZIndex + 100
)
loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local loaderTitle = Instance.new("TextLabel")
loaderTitle.Name = "LoaderTitle"
loaderTitle.Parent = loaderFrame
loaderTitle.BackgroundTransparency = 1
loaderTitle.Position = UDim2.new(0, 0, 0.2, 0)
loaderTitle.Size = UDim2.new(1, 0, 0, 48)
loaderTitle.Font = FONT_BOLD
loaderTitle.TextSize = 34
loaderTitle.TextColor3 = Colors.TextPrimary
loaderTitle.Text = "Loading Trigon Luna UI"
loaderTitle.TextXAlignment = Enum.TextXAlignment.Center
loaderTitle.TextYAlignment = Enum.TextYAlignment.Center

-- Animated loading dots
local dotsLabel = Instance.new("TextLabel")
dotsLabel.Name = "DotsLabel"
dotsLabel.Parent = loaderFrame
dotsLabel.BackgroundTransparency = 1
dotsLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
dotsLabel.AnchorPoint = Vector2.new(0.5, 0)
dotsLabel.Size = UDim2.new(0, 120, 0, 24)
dotsLabel.Font = FONT_BOLD
dotsLabel.TextSize = 24
dotsLabel.TextColor3 = Colors.Accent
dotsLabel.Text = ""
dotsLabel.TextXAlignment = Enum.TextXAlignment.Center

do
    local dots = ""
    spawn(function()
        while loaderGui.Enabled do
            for i = 1, 4 do
                dots = string.rep(".", i)
                dotsLabel.Text = "Loading" .. dots
                wait(0.5)
            end
        end
    end)
end

-- Create Main UI --
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "TrigonLunaMain"
mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = BaseZIndex + 50
mainGui.Parent = playerGui
mainGui.Enabled = false  -- start hidden, shown after loader

-- UI Background
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Name = "Background"
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
backgroundFrame.BackgroundColor3 = Colors.Background
backgroundFrame.BorderSizePixel = 0
backgroundFrame.Parent = mainGui

-- Central container frame, max width 1100px, centered
local container = CreateRoundedFrame(backgroundFrame,
    UDim2.new(0, 1100, 0, 680),
    UDim2.new(0.5, 0, 0.5, 0),
    Colors.PanelBg,
    "MainContainer",
    BaseZIndex + 50
)
container.AnchorPoint = Vector2.new(0.5, 0.5)

-- Header bar
local headerBar = Instance.new("Frame")
headerBar.Name = "Header"
headerBar.Size = UDim2.new(1, 0, 0, 72)
headerBar.BackgroundColor3 = Colors.Background
headerBar.Parent = container

local headerCorner = Instance.new("UICorner", headerBar)
headerCorner.CornerRadius = UDim.new(0, 16)

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "HeaderTitle"
headerTitle.Font = FONT_BOLD
headerTitle.TextSize = 36
headerTitle.TextColor3 = Colors.TextPrimary
headerTitle.BackgroundTransparency = 1
headerTitle.Size = UDim2.new(0.5, 0, 1, 0)
headerTitle.Text = "Trigon Luna"
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Position = UDim2.new(0, 24, 0, 0)
headerTitle.Parent = headerBar

-- Navigation container for buttons (right aligned)
local navButtonsFrame = Instance.new("Frame")
navButtonsFrame.Name = "NavButtons"
navButtonsFrame.Size = UDim2.new(0, 420, 0, 48)
navButtonsFrame.Position = UDim2.new(1, -448, 0, 12)
navButtonsFrame.BackgroundTransparency = 1
navButtonsFrame.Parent = headerBar

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 16)
navLayout.Parent = navButtonsFrame

-- Function to create navigation buttons
local function CreateNavButton(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.BackgroundColor3 = Colors.ButtonBg
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Text = name
    btn.Font = FONT_SEMIBOLD
    btn.TextSize = 18
    btn.TextColor3 = Colors.TextSecondary
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Colors.ButtonHoverBg, TextColor3 = Colors.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Colors.ButtonBg, TextColor3 = Colors.TextSecondary}):Play()
    end)

    btn.ZIndex = BaseZIndex + 100
    btn.Parent = navButtonsFrame
    return btn
end

-- Create navigation buttons
local execBtn = CreateNavButton("Execute")
local logsBtn = CreateNavButton("Logs")
local homeBtn = CreateNavButton("Home")
local settingsBtn = CreateNavButton("Settings")

-- Content container (below header)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Position = UDim2.new(0, 24, 0, 72)
contentFrame.Size = UDim2.new(1, -48, 1, -88)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = container

-- Create a clean 'card' panel for content with consistent styling
local function CreateCardPanel(name)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Colors.PanelBg
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = contentFrame

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    return frame
end

local executePanel = CreateCardPanel("ExecutePanel")
local logsPanel = CreateCardPanel("LogsPanel")
local homePanel = CreateCardPanel("HomePanel")
local settingsPanel = CreateCardPanel("SettingsPanel")

-- Show only home panel initially
homePanel.Visible = true

-- ========== Home Panel ==========
local homeTitle = Instance.new("TextLabel")
homeTitle.Parent = homePanel
homeTitle.Text = "Welcome to Trigon Luna"
homeTitle.Font = FONT_BOLD
homeTitle.TextSize = 48
homeTitle.TextColor3 = Colors.TextPrimary
homeTitle.BackgroundTransparency = 1
homeTitle.Size = UDim2.new(1, 0, 0, 64)
homeTitle.Position = UDim2.new(0, 24, 0, 48)
homeTitle.TextXAlignment = Enum.TextXAlignment.Left

local homeSubtitle = Instance.new("TextLabel")
homeSubtitle.Parent = homePanel
homeSubtitle.Text = "A clean, modern Lua executor UI with elegant Luna theme styling."
homeSubtitle.Font = FONT_SEMIBOLD
homeSubtitle.TextSize = 18
homeSubtitle.TextColor3 = Colors.TextSecondary
homeSubtitle.BackgroundTransparency = 1
homeSubtitle.Size = UDim2.new(1, -48, 0, 48)
homeSubtitle.Position = UDim2.new(0, 24, 0, 120)
homeSubtitle.TextWrapped = true
homeSubtitle.TextXAlignment = Enum.TextXAlignment.Left

-- ========== Execute Panel ==========
local execTitle = Instance.new("TextLabel")
execTitle.Parent = executePanel
execTitle.Text = "Execute Lua Code"
execTitle.Font = FONT_BOLD
execTitle.TextSize = 40
execTitle.TextColor3 = Colors.TextPrimary
execTitle.BackgroundTransparency = 1
execTitle.Size = UDim2.new(1, 0, 0, 56)
execTitle.Position = UDim2.new(0, 24, 0, 36)
execTitle.TextXAlignment = Enum.TextXAlignment.Left

local execTextBox = Instance.new("TextBox")
execTextBox.Parent = executePanel
execTextBox.Size = UDim2.new(1, -48, 1, -140)
execTextBox.Position = UDim2.new(0, 24, 0, 100)
execTextBox.BackgroundColor3 = Colors.Background
execTextBox.TextColor3 = Colors.TextPrimary
execTextBox.BorderSizePixel = 1
execTextBox.BorderColor3 = Colors.ButtonHoverBg
execTextBox.Font = Enum.Font.Code
execTextBox.TextSize = 16
execTextBox.ClearTextOnFocus = false
execTextBox.TextWrapped = true
execTextBox.PlaceholderText = "Write or paste your Lua code here..."
execTextBox.TextXAlignment = Enum.TextXAlignment.Left
execTextBox.TextYAlignment = Enum.TextYAlignment.Top
execTextBox.MultiLine = true -- Roblox Lua allows this property on TextBox for multiline input
execTextBox.ZIndex = BaseZIndex + 200

local execButton = Instance.new("TextButton")
execButton.Parent = executePanel
execButton.Text = "Run"
execButton.Font = FONT_SEMIBOLD
execButton.TextSize = 20
execButton.BackgroundColor3 = Colors.Accent
execButton.TextColor3 = Color3.new(1,1,1)
execButton.Size = UDim2.new(0, 140, 0, 48)
execButton.Position = UDim2.new(1, -172, 1, -72)
execButton.AutoButtonColor = false
execButton.ZIndex = BaseZIndex + 210

local execButtonCorner = Instance.new("UICorner", execButton)
execButtonCorner.CornerRadius = UDim.new(0, 12)

execButton.MouseEnter:Connect(function()
    TweenService:Create(execButton, TweenInfo.new(0.25), {BackgroundColor3 = Colors.AccentLight}):Play()
end)
execButton.MouseLeave:Connect(function()
    TweenService:Create(execButton, TweenInfo.new(0.25), {BackgroundColor3 = Colors.Accent}):Play()
end)

execButton.MouseButton1Click:Connect(function()
    local code = execTextBox.Text
    local success, err = pcall(function()
        local func = assert(loadstring(code))
        return func()
    end)
    if not success then
        warn("Execution error: " .. tostring(err))
    end
end)


-- ========== Logs Panel ==========
local logsTitle = Instance.new("TextLabel")
logsTitle.Parent = logsPanel
logsTitle.Text = "Console Logs"
logsTitle.Font = FONT_BOLD
logsTitle.TextSize = 40
logsTitle.TextColor3 = Colors.TextPrimary
logsTitle.BackgroundTransparency = 1
logsTitle.Size = UDim2.new(1, 0, 0, 56)
logsTitle.Position = UDim2.new(0, 24, 0, 36)
logsTitle.TextXAlignment = Enum.TextXAlignment.Left

local logsOutputFrame = Instance.new("ScrollingFrame")
logsOutputFrame.Parent = logsPanel
logsOutputFrame.Size = UDim2.new(1, -48, 1, -140)
logsOutputFrame.Position = UDim2.new(0, 24, 0, 100)
logsOutputFrame.BackgroundColor3 = Colors.Background
logsOutputFrame.BorderSizePixel = 1
logsOutputFrame.BorderColor3 = Colors.ButtonHoverBg
logsOutputFrame.ScrollBarThickness = 10
logsOutputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logsOutputFrame.ZIndex = BaseZIndex + 200

local logTextLabel = Instance.new("TextLabel")
logTextLabel.Parent = logsOutputFrame
logTextLabel.Size = UDim2.new(1, -24, 0, 0)
logTextLabel.Position = UDim2.new(0, 12, 0, 12)
logTextLabel.BackgroundTransparency = 1
logTextLabel.Font = Enum.Font.Code
logTextLabel.TextSize = 14
logTextLabel.TextColor3 = Colors.TextPrimary
logTextLabel.TextWrapped = true
logTextLabel.RichText = true
logTextLabel.Text = ""
logTextLabel.TextXAlignment = Enum.TextXAlignment.Left
logTextLabel.TextYAlignment = Enum.TextYAlignment.Top
logTextLabel.ClipsDescendants = true

local function UpdateLogSize()
    local textHeight = logTextLabel.TextBounds.Y
    logTextLabel.Size = UDim2.new(1, -24, 0, textHeight + 24)
    logsOutputFrame.CanvasSize = UDim2.new(0, 0, 0, textHeight + 24)
    -- Scroll to bottom on update
    logsOutputFrame.CanvasPosition = Vector2.new(0, math.max(0, textHeight - logsOutputFrame.AbsoluteSize.Y + 24))
end

LogService.MessageOut:Connect(function(message, messageType)
    local color = "#6B7280"
    local prefix = "Log"
    if messageType == Enum.MessageType.MessageOutput then
        prefix = "Print"
        color = "#6B7280"
    elseif messageType == Enum.MessageType.MessageWarning then
        prefix = "Warn"
        color = "#FBBF24"
    elseif messageType == Enum.MessageType.MessageError then
        prefix = "Error"
        color = "#EF4444"
    elseif messageType == Enum.MessageType.MessageInfo then
        prefix = "Info"
        color = "#3B82F6"
    end
    local time = os.date("%X")
    logTextLabel.Text = logTextLabel.Text .. string.format('<font color="%s">[%s][%s]</font> %s\n', color, time, prefix, message)
    UpdateLogSize()
end)

-- ========== Settings Panel ==========
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsPanel
settingsTitle.Text = "Settings"
settingsTitle.Font = FONT_BOLD
settingsTitle.TextSize = 48
settingsTitle.TextColor3 = Colors.TextPrimary
settingsTitle.BackgroundTransparency = 1
settingsTitle.Size = UDim2.new(1, 0, 0, 56)
settingsTitle.Position = UDim2.new(0, 24, 0, 36)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Settings data and saving stub
local Settings = {
    autoexec = false,
    autohideui = false,
    logPrint = true,
    logWarn = true,
    logError = true,
    logInfo = true,
}

local function SaveSettings()
    -- Save logic here: writefile or datastore; stub logs for now
    print("Settings saved:", HttpService:JSONEncode(Settings))
end

-- Create a toggle setting UI item
local function CreateToggleSetting(parent, label, posY, key)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Colors.PanelBg
    frame.Size = UDim2.new(1, -48, 0, 56)
    frame.Position = UDim2.new(0, 24, 0, posY)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = frame
    textLabel.Text = label
    textLabel.Font = FONT_SEMIBOLD
    textLabel.TextSize = 20
    textLabel.TextColor3 = Colors.TextPrimary
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 20, 0, 0)
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Parent = frame
    toggleButton.Size = UDim2.new(0, 52, 0, 28)
    toggleButton.Position = UDim2.new(1, -76, 0.5, -14)
    toggleButton.BackgroundColor3 = Colors.ButtonBg
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.ZIndex = BaseZIndex + 300
    toggleButton.Name = "Toggle"

    local toggleCorner = Instance.new("UICorner", toggleButton)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Parent = toggleButton
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Colors.ButtonHoverBg
    circle.BorderSizePixel = 0

    local circleCorner = Instance.new("UICorner", circle)
    circleCorner.CornerRadius = UDim.new(1, 0)

    local function updateToggleUI(state)
        if state then
            toggleButton.BackgroundColor3 = Colors.Accent
            circle.Position = UDim2.new(1, -24, 0.5, -11)
        else
            toggleButton.BackgroundColor3 = Colors.ButtonBg
            circle.Position = UDim2.new(0, 2, 0.5, -11)
        end
    end

    updateToggleUI(Settings[key])

    toggleButton.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        updateToggleUI(Settings[key])
        SaveSettings()
    end)

    return frame
end

local toggleAutoexec = CreateToggleSetting(settingsPanel, "Enable Auto Execute", 96, "autoexec")
local toggleAutohide = CreateToggleSetting(settingsPanel, "Hide UI on Launch", 160, "autohideui")
local toggleLogPrint = CreateToggleSetting(settingsPanel, "Log Print Messages", 224, "logPrint")
local toggleLogWarn = CreateToggleSetting(settingsPanel, "Log Warnings", 288, "logWarn")
local toggleLogError = CreateToggleSetting(settingsPanel, "Log Errors", 352, "logError")
local toggleLogInfo = CreateToggleSetting(settingsPanel, "Log Info Messages", 416, "logInfo")

-- Navigation button connections to switch panels
local function SetPanelVisible(panel)
    executePanel.Visible = false
    logsPanel.Visible = false
    homePanel.Visible = false
    settingsPanel.Visible = false
    panel.Visible = true
end

execBtn.MouseButton1Click:Connect(function() SetPanelVisible(executePanel) end)
logsBtn.MouseButton1Click:Connect(function() SetPanelVisible(logsPanel) end)
homeBtn.MouseButton1Click:Connect(function() SetPanelVisible(homePanel) end)
settingsBtn.MouseButton1Click:Connect(function() SetPanelVisible(settingsPanel) end)

-- Show home panel by default
SetPanelVisible(homePanel)

-- Loader animation control: show loader for 2.7 seconds then switch to main UI
task.spawn(function()
    wait(2.7)
    loaderGui.Enabled = false
    mainGui.Enabled = true
end)

print("-----] Trigon Luna UI Loaded and Ready [-----]")
