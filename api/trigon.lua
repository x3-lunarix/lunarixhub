local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear any existing Trigon UI
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name == "TrigonLunaLoader" or gui.Name == "TrigonLunaMain" then
        gui:Destroy()
    end
end

-- Theme colors
local Colors = {
    Background = Color3.fromRGB(255, 255, 255),        -- white background
    PanelBg = Color3.fromRGB(245, 247, 250),           -- very light gray panel background
    TextPrimary = Color3.fromRGB(17, 24, 39),          -- dark gray for main text
    TextSecondary = Color3.fromRGB(107, 114, 128),     -- #6b7280 neutral gray
    Accent = Color3.fromRGB(79, 70, 229),              -- Indigo-600
    AccentLight = Color3.fromRGB(199, 210, 254),       -- Indigo-200 light for hover
    ShadowColor = Color3.fromRGB(200, 210, 230),       -- subtle shadow color
    ButtonBg = Color3.fromRGB(251, 253, 255),          -- almost white button bg
    ButtonHoverBg = Color3.fromRGB(229, 231, 235),     -- button hover light gray
    ButtonActiveBg = Color3.fromRGB(199, 210, 254),    -- button active indigo
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_REGULAR = Enum.Font.Gotham

local CornerRadius = UDim.new(0, 12)
local BaseZIndex = 1000

-- FUNCTION: Create rounded frame with shadow
local function CreateRoundedFrame(parent, size, position, bgColor, name, zindex)
    local frame = Instance.new("Frame")
    frame.Name = name or "RoundedFrame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = bgColor or Colors.PanelBg
    frame.AnchorPoint = Vector2.new(0,0)
    frame.ZIndex = zindex or BaseZIndex
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CornerRadius
    corner.Parent = frame

    -- subtle shadow frame
    local shadow = Instance.new("Frame")
    shadow.Name = frame.Name.."_Shadow"
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundColor3 = Colors.ShadowColor
    shadow.ZIndex = (zindex or BaseZIndex) - 1
    shadow.AnchorPoint = Vector2.new(0,0)
    shadow.BorderSizePixel = 0
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = CornerRadius
    shadowCorner.Parent = shadow

    shadow.BackgroundTransparency = 0.85

    return frame
end

-- Create Loader GUI --
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "TrigonLunaLoader"
loaderGui.ResetOnSpawn = false
loaderGui.DisplayOrder = BaseZIndex + 10
loaderGui.Parent = playerGui

local loaderFrame = CreateRoundedFrame(loaderGui,
    UDim2.new(0, 480, 0, 120),
    UDim2.new(0.5, 0, 0.5, 0),
    Colors.PanelBg,
    "LoaderFrame",
    BaseZIndex + 10
)
loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local loaderTitle = Instance.new("TextLabel")
loaderTitle.Name = "LoaderTitle"
loaderTitle.Parent = loaderFrame
loaderTitle.BackgroundTransparency = 1
loaderTitle.Position = UDim2.new(0, 0, 0.15, 0)
loaderTitle.Size = UDim2.new(1, 0, 0, 48)
loaderTitle.Font = FONT_BOLD
loaderTitle.TextSize = 36
loaderTitle.TextColor3 = Colors.TextPrimary
loaderTitle.Text = "Loading Trigon Luna UI..."
loaderTitle.TextXAlignment = Enum.TextXAlignment.Center
loaderTitle.TextYAlignment = Enum.TextYAlignment.Center

-- Loading dots animation
local dotsLabel = Instance.new("TextLabel")
dotsLabel.Name = "DotsLabel"
dotsLabel.Parent = loaderFrame
dotsLabel.BackgroundTransparency = 1
dotsLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
dotsLabel.AnchorPoint = Vector2.new(0.5, 0)
dotsLabel.Size = UDim2.new(0, 100, 0, 24)
dotsLabel.Font = FONT_BOLD
dotsLabel.TextSize = 24
dotsLabel.TextColor3 = Colors.Accent
dotsLabel.Text = ""
dotsLabel.TextXAlignment = Enum.TextXAlignment.Center

do
    local dots = ""
    local count = 0
    spawn(function()
        while loaderGui.Parent do
            if count > 3 then
                dots = ""
                count = 0
            else
                dots = dots .. "."
                count = count + 1
            end
            dotsLabel.Text = "Loading"..dots
            wait(0.5)
        end
    end)
end

-- Create Main UI --
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "TrigonLunaMain"
mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = BaseZIndex
mainGui.Parent = playerGui
mainGui.Enabled = false  -- hidden initially, until loader completes

-- Background frame (semi-transparent white)
local bgFrame = Instance.new("Frame")
bgFrame.Name = "Background"
bgFrame.AnchorPoint = Vector2.new(0, 0)
bgFrame.Position = UDim2.new(0, 0, 0, 0)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Colors.Background
bgFrame.BorderSizePixel = 0
bgFrame.Parent = mainGui

-- Main container (centered and max width 1200)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
mainContainer.Size = UDim2.new(0, 1100, 0, 650)
mainContainer.BackgroundColor3 = Colors.PanelBg
mainContainer.BorderSizePixel = 0
mainContainer.Parent = bgFrame

local mainCorner = Instance.new("UICorner", mainContainer)
mainCorner.CornerRadius = UDim.new(0, 16)

-- Shadow for container
local shadowContainer = Instance.new("Frame")
shadowContainer.Name = "ShadowContainer"
shadowContainer.Size = UDim2.new(1, 10, 1, 12)
shadowContainer.Position = UDim2.new(0, 0, 0, 0)
shadowContainer.BackgroundColor3 = Colors.ShadowColor
shadowContainer.BorderSizePixel = 0
shadowContainer.ZIndex = mainContainer.ZIndex - 1
shadowContainer.Parent = mainContainer

local shadowCorner = Instance.new("UICorner", shadowContainer)
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowContainer.BackgroundTransparency = 0.85

-- Header bar
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Colors.Background
header.Size = UDim2.new(1, 0, 0, 72)
header.Position = UDim2.new(0, 0, 0, 0)
header.BorderSizePixel = 0
header.Parent = mainContainer

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 12)

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "Title"
headerTitle.Font = FONT_BOLD
headerTitle.TextSize = 30
headerTitle.TextColor3 = Colors.TextPrimary
headerTitle.BackgroundTransparency = 1
headerTitle.Size = UDim2.new(1, 0, 1, 0)
headerTitle.Text = "Trigon Luna"
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.TextYAlignment = Enum.TextYAlignment.Center
headerTitle.Position = UDim2.new(0, 24, 0, 0)
headerTitle.Parent = header

-- Navigation Buttons Container
local navButtons = Instance.new("Frame")
navButtons.Name = "NavButtons"
navButtons.Size = UDim2.new(0, 420, 0, 48)
navButtons.Position = UDim2.new(1, -460, 0, 12)
navButtons.BackgroundTransparency = 1
navButtons.Parent = header

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = navButtons
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)

-- Utility function: Create a nav button
local function createNavButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.BackgroundColor3 = Colors.ButtonBg
    btn.TextColor3 = Colors.TextSecondary
    btn.Font = FONT_BOLD
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.BorderSizePixel = 0

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.ButtonHoverBg, TextColor3 = Colors.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.ButtonBg, TextColor3 = Colors.TextSecondary}):Play()
    end)
    btn.ZIndex = BaseZIndex + 5

    return btn
end

local execBtn = createNavButton("Execute")
execBtn.Parent = navButtons
local logBtn = createNavButton("Logs")
logBtn.Parent = navButtons
local homeBtn = createNavButton("Home")
homeBtn.Parent = navButtons
local settingsBtn = createNavButton("Settings")
settingsBtn.Parent = navButtons

-- Content panels container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -48, 1, -96)
contentContainer.Position = UDim2.new(0, 24, 0, 72)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainContainer

-- Utility: create content panel (card style)
local function createContentPanel(name)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Colors.PanelBg
    frame.Visible = false
    frame.BorderSizePixel = 0
    frame.Parent = contentContainer

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 14)

    return frame
end

-- Create panels for all main views
local execPanel = createContentPanel("ExecutePanel")
local logPanel = createContentPanel("LogPanel")
local homePanel = createContentPanel("HomePanel")
local settingsPanel = createContentPanel("SettingsPanel")

homePanel.Visible = true

-- Execute Panel contents
local execTitle = Instance.new("TextLabel")
execTitle.Parent = execPanel
execTitle.Text = "Execute Lua Code"
execTitle.Font = FONT_BOLD
execTitle.TextSize = 28
execTitle.TextColor3 = Colors.TextPrimary
execTitle.BackgroundTransparency = 1
execTitle.Size = UDim2.new(1, 0, 0, 42)
execTitle.Position = UDim2.new(0, 0, 0, 12)

-- Code text box - multi-line with border
local execTextBox = Instance.new("TextBox")
execTextBox.Parent = execPanel
execTextBox.Multiline = true
execTextBox.Size = UDim2.new(1, -24, 1, -72)
execTextBox.Position = UDim2.new(0, 12, 0, 60)
execTextBox.BackgroundColor3 = Colors.Background
execTextBox.TextColor3 = Colors.TextPrimary
execTextBox.Font = Enum.Font.SourceSans
execTextBox.TextSize = 16
execTextBox.ClearTextOnFocus = false
execTextBox.TextWrapped = true
execTextBox.PlaceholderText = "Write or paste your Lua code here..."
execTextBox.BorderSizePixel = 1
execTextBox.BorderColor3 = Colors.ButtonHoverBg
execTextBox.TextXAlignment = Enum.TextXAlignment.Left
execTextBox.TextYAlignment = Enum.TextYAlignment.Top
execTextBox.ZIndex = BaseZIndex + 10

local execButton = Instance.new("TextButton")
execButton.Parent = execPanel
execButton.Text = "Run"
execButton.Font = FONT_BOLD
execButton.TextSize = 18
execButton.BackgroundColor3 = Colors.Accent
execButton.TextColor3 = Color3.new(1,1,1)
execButton.Size = UDim2.new(0, 100, 0, 40)
execButton.Position = UDim2.new(1, -112, 1, -48)
execButton.AutoButtonColor = false

local execBtnCorner = Instance.new("UICorner", execButton)
execBtnCorner.CornerRadius = UDim.new(0, 10)

execButton.MouseEnter:Connect(function()
    TweenService:Create(execButton, TweenInfo.new(0.25), {BackgroundColor3 = Colors.AccentLight}):Play()
end)
execButton.MouseLeave:Connect(function()
    TweenService:Create(execButton, TweenInfo.new(0.25), {BackgroundColor3 = Colors.Accent}):Play()
end)

execButton.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        loadstring(execTextBox.Text)()
    end)
    if not success then
        warn("Execution error: "..tostring(err))
    end
end)

-- Logs Panel contents
local logTitle = Instance.new("TextLabel")
logTitle.Parent = logPanel
logTitle.Text = "Console Logs"
logTitle.Font = FONT_BOLD
logTitle.TextSize = 28
logTitle.TextColor3 = Colors.TextPrimary
logTitle.BackgroundTransparency = 1
logTitle.Size = UDim2.new(1, 0, 0, 42)
logTitle.Position = UDim2.new(0, 0, 0, 12)

local logOutput = Instance.new("ScrollingFrame")
logOutput.Parent = logPanel
logOutput.Size = UDim2.new(1, -24, 1, -72)
logOutput.Position = UDim2.new(0, 12, 0, 60)
logOutput.BackgroundColor3 = Colors.Background
logOutput.BorderSizePixel = 1
logOutput.BorderColor3 = Colors.ButtonHoverBg
logOutput.CanvasSize = UDim2.new(0, 0, 5, 0)
logOutput.ScrollBarThickness = 10
logOutput.AutomaticCanvasSize = Enum.AutomaticSize.Y
logOutput.ZIndex = BaseZIndex + 10

local logText = Instance.new("TextLabel")
logText.Parent = logOutput
logText.Size = UDim2.new(1, -10, 0, 0)
logText.BackgroundTransparency = 1
logText.Font = Enum.Font.Code
logText.TextSize = 14
logText.TextColor3 = Colors.TextPrimary
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.ClipsDescendants = true
logText.RichText = true
logText.Text = ""
logText.Position = UDim2.new(0, 5, 0, 0)

logOutput.CanvasPosition = Vector2.new(0,0)

local function updateCanvasSize()
    local sizeY = logText.TextBounds.Y + 5
    logText.Size = UDim2.new(1, -10, 0, sizeY)
    logOutput.CanvasSize = UDim2.new(0, 0, 0, sizeY)
    logOutput.CanvasPosition = Vector2.new(0, sizeY)
end

-- Connect Roblox LogService to append to logText
local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(message, messageType)
    local color
    local prefix
    if messageType == Enum.MessageType.MessageOutput then
        color = "#6B7280"
        prefix = "Print"
    elseif messageType == Enum.MessageType.MessageWarning then
        color = "#FBBF24"
        prefix = "Warn"
    elseif messageType == Enum.MessageType.MessageError then
        color = "#EF4444"
        prefix = "Error"
    elseif messageType == Enum.MessageType.MessageInfo then
        color = "#3B82F6"
        prefix = "Info"
    else
        color = "#6B7280"
        prefix = "Log"
    end
    -- Format message as rich text with timestamp
    local time = os.date("%X")
    logText.Text = logText.Text .. string.format('<font color="%s">[%s][%s]</font> %s\n', color, time, prefix, message)
    updateCanvasSize()
end)

-- Home Panel contents
local homeTitle = Instance.new("TextLabel")
homeTitle.Parent = homePanel
homeTitle.Text = "Welcome to Trigon Luna"
homeTitle.Font = FONT_BOLD
homeTitle.TextSize = 36
homeTitle.TextColor3 = Colors.TextPrimary
homeTitle.BackgroundTransparency = 1
homeTitle.Size = UDim2.new(1, 0, 0, 54)
homeTitle.Position = UDim2.new(0, 0, 0, 24)

local homeSubtitle = Instance.new("TextLabel")
homeSubtitle.Parent = homePanel
homeSubtitle.Text = "A sleek, modern Lua executor interface for Roblox with Luna Theme."
homeSubtitle.Font = FONT_REGULAR
homeSubtitle.TextSize = 18
homeSubtitle.TextColor3 = Colors.TextSecondary
homeSubtitle.BackgroundTransparency = 1
homeSubtitle.Size = UDim2.new(1, -48, 0, 48)
homeSubtitle.Position = UDim2.new(0, 24, 0, 84)
homeSubtitle.TextWrapped = true

-- Settings Panel contents
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsPanel
settingsTitle.Text = "Settings"
settingsTitle.Font = FONT_BOLD
settingsTitle.TextSize = 36
settingsTitle.TextColor3 = Colors.TextPrimary
settingsTitle.BackgroundTransparency = 1
settingsTitle.Size = UDim2.new(1, 0, 0, 54)
settingsTitle.Position = UDim2.new(0, 0, 0, 24)

local function createToggleSetting(parent, name, positionY, propertyName)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundColor3 = Colors.PanelBg
    container.Position = UDim2.new(0, 24, 0, positionY)
    container.Size = UDim2.new(1, -48, 0, 48)
    container.BorderSizePixel = 0
    container.ZIndex = BaseZIndex + 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Text = name
    label.Font = FONT_BOLD
    label.TextSize = 18
    label.TextColor3 = Colors.TextPrimary
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = container
    toggleBtn.Size = UDim2.new(0, 60, 0, 26)
    toggleBtn.Position = UDim2.new(1, -72, 0.5, -13)
    toggleBtn.BackgroundColor3 = Colors.ButtonBg
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.BorderSizePixel = 0

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    -- Inner circle
    local circle = Instance.new("Frame")
    circle.Name = "ToggleCircle"
    circle.Parent = toggleBtn
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Colors.ButtonHoverBg
    circle.BorderSizePixel = 0

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    -- Update function for toggle state
    local function updateToggle(state)
        if state then
            toggleBtn.BackgroundColor3 = Colors.Accent
            circle.Position = UDim2.new(1, -24, 0.5, -11)
        else
            toggleBtn.BackgroundColor3 = Colors.ButtonBg
            circle.Position = UDim2.new(0, 2, 0.5, -11)
        end
    end

    -- Initial update
    updateToggle(Settings[propertyName] == true)

    -- Toggle behavior on click
    toggleBtn.MouseButton1Click:Connect(function()
        Settings[propertyName] = not Settings[propertyName]
        updateToggle(Settings[propertyName])
        pcall(saveSettings)  -- Save settings function (assumed existing)
    end)

    return container
end

-- Assume Settings table exists and saveSettings function from original code
Settings = Settings or {
    autoexec = false,
    autohideui = false,
    logPrint = true,
    logWarn = true,
    logError = true,
    logInfo = true,
}

local toggleAutoexec = createToggleSetting(settingsPanel, "Enable Auto Execute", 96, "autoexec")
local toggleAutohideUI = createToggleSetting(settingsPanel, "Hide UI on Launch", 160, "autohideui")
local toggleLogPrint = createToggleSetting(settingsPanel, "Log Print Messages", 224, "logPrint")
local toggleLogWarn = createToggleSetting(settingsPanel, "Log Warnings", 288, "logWarn")
local toggleLogError = createToggleSetting(settingsPanel, "Log Errors", 352, "logError")
local toggleLogInfo = createToggleSetting(settingsPanel, "Log Info Messages", 416, "logInfo")

-- Function to switch content panels
local function switchPanel(showPanel)
    execPanel.Visible = false
    logPanel.Visible = false
    homePanel.Visible = false
    settingsPanel.Visible = false
    showPanel.Visible = true
end

-- Connect nav button clicks
execBtn.MouseButton1Click:Connect(function() switchPanel(execPanel) end)
logBtn.MouseButton1Click:Connect(function() switchPanel(logPanel) end)
homeBtn.MouseButton1Click:Connect(function() switchPanel(homePanel) end)
settingsBtn.MouseButton1Click:Connect(function() switchPanel(settingsPanel) end)

-- Show home initially
switchPanel(homePanel)

-- Loader sequence: show loader for ~2.5 seconds then show UI
task.spawn(function()
    wait(2.5)
    loaderGui.Enabled = false
    mainGui.Enabled = true
end)

-- SaveSettings function (stub for completeness)
function saveSettings()
    -- Try saving Settings with Roblox file system or custom persistence
    -- Here we simply print settings to console for stub
    print("Settings saved:", HttpService:JSONEncode(Settings))
end

-- Initialize toggle UI with current Settings
local function initializeSettingsUI()
    -- Just call the click handler with current values to update UI toggle states
    toggleAutoexec.MouseButton1Click:Wait()  -- dummy wait to let connections set up
    -- Toggles already initialized on toggles creation
end
task.spawn(initializeSettingsUI)

print("-----] Trigon Luna UI Loaded [-----]")
