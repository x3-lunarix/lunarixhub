--!strict -- Keep this for modern Luau features, most executors support it now.

-- Services (Executor-friendly)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait() -- Ensure LocalPlayer is available
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService") -- For potential web-based key checks (conceptual)

-- Define a global reference for the UI, common in executors
-- This allows other scripts to interact with or destroy the loader if needed.
_G.LunarixLoader = _G.LunarixLoader or {}

-- Configuration (Even more refined for premium aesthetics)
local Config = {
    -- Theme Colors (Inspired by deep space, subtle nebulae, and glowing elements)
    BackgroundDimColor = Color3.fromRGB(12, 15, 22),   -- Very dark base for container
    BorderColor = Color3.fromRGB(35, 45, 65),       -- Subtle, cool border
    TextInputColor = Color3.fromRGB(20, 26, 36),   -- Darker input field background
    PlaceholderColor = Color3.fromRGB(110, 125, 140), -- Softer, desaturated placeholder text
    PrimaryTextColor = Color3.fromRGB(235, 245, 255), -- Crisp, bright white for main text
    SecondaryTextColor = Color3.fromRGB(140, 160, 180), -- Muted blue-grey for descriptive text

    -- Accent Colors (Vibrant, high-contrast blues and purples)
    AccentBlue = Color3.fromRGB(40, 90, 220),      -- Deep, electric blue for primary action
    AccentBlueLight = Color3.fromRGB(80, 130, 255), -- Brighter blue for gradients
    AccentPurple = Color3.fromRGB(90, 50, 170),    -- Rich, mysterious purple for secondary action
    AccentPurpleLight = Color3.fromRGB(130, 80, 210), -- Lighter purple for gradients

    -- Loader Specific Colors
    LoadingBarFillStart = Color3.fromRGB(70, 130, 255), -- Dynamic loading bar gradient start
    LoadingBarFillEnd = Color3.fromRGB(140, 200, 255), -- Dynamic loading bar gradient end
    LoadingBarTrack = Color3.fromRGB(25, 33, 50),       -- Darker track for loading bar

    -- UI Dimensions & Properties
    ContainerWidth = 450, -- Slightly wider
    ContainerHeight = 340, -- Slightly taller
    ContainerCornerRadius = UDim.new(0, 20), -- Even larger radius for softer, rounded corners
    StrokeThickness = 2.5,                  -- More prominent stroke
    ContainerShadowOffset = Vector2.new(0, 8), -- Offset for subtle drop shadow
    ContainerShadowBlur = 15,                -- Blur for the shadow

    MoonIconSizeInitial = 100,
    MoonIconSizeKeyPhase = 50,
    MoonIconTextSizeInitial = 92,
    MoonIconTextSizeKeyPhase = 42,

    TitleTextSize = 34,
    SubtitleTextSize = 19,

    TextInputHeight = 50, -- Taller input field
    ButtonHeight = 46,    -- Taller buttons
    ButtonCornerRadius = UDim.new(0, 14), -- More rounded buttons

    LoadingBarHeight = 8, -- Thicker loading bar

    -- Animation Durations (Fine-tuned for smoother, impactful transitions)
    FadeInDuration = 0.9,
    ScaleInDuration = 0.8,
    MoonAppearDuration = 1.1,
    MoonBounceDuration1 = 0.28,
    MoonBounceDuration2 = 0.7,
    TextSlideInDuration = 1.0,
    LoadingBarFillDuration = 3.5, -- Slower fill for more dramatic effect
    GradientCycleDuration = 3.0,  -- Slower gradient cycle
    TransitionToKeySystemDuration = 0.8,
    KeyElementsAppearDuration = 0.7,
    ButtonHoverDuration = 0.1,
    CloseUIDuration = 0.6,
    KeyErrorFlashDuration = 0.2,

    -- Blur Effect
    BlurSize = 30, -- Even more blur

    -- ZIndex Management (Consistent and clear)
    ZIndexBase = 2,
    ZIndexOverlay = 3,
    ZIndexTop = 4,

    -- Text Content
    TitleText = "LUNARIX HUB",
    SubtitleText = "🌌 Navigate the Cosmos 🌌", -- Even more thematic
    KeyBoxPlaceholder = "ENTER YOUR ACCESS KEY",
    VerifyButtonText = "VERIFY", -- Shorter, punchier
    GetButtonText = "GET KEY",
    MoonEmoji = "🌙",

    -- Asset IDs
    CloseButtonImageId = "rbxassetid://3926305904", -- Standard Roblox Close Icon
    -- You might want to use a custom image here if you have one!
}

-- UI Elements (Centralized table for clean access)
local UI = {}

--- Utility Functions ---
local function createTween(instance: Instance, tweenInfo: TweenInfo, properties: {})
    return TweenService:Create(instance, tweenInfo, properties)
end

-- Advanced button hover effect with slight text scale
local function applyModernButtonEffect(button: TextButton)
    local originalSize = button.Size
    local originalBgColor = button.BackgroundColor3
    local originalTextColor = button.TextColor3
    local originalTextSize = button.TextSize

    local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 15, originalSize.Y.Scale, originalSize.Y.Offset + 6)
    local hoverBgColor = originalBgColor:Lerp(Color3.new(1,1,1), 0.15) -- Brighter on hover
    local hoverTextSize = originalTextSize * 1.05 -- Text scales slightly

    button.MouseEnter:Connect(function()
        createTween(button, TweenInfo.new(Config.ButtonHoverDuration, Enum.EasingStyle.Quad), {
            Size = hoverSize,
            BackgroundColor3 = hoverBgColor,
            TextSize = hoverTextSize
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        createTween(button, TweenInfo.new(Config.ButtonHoverDuration, Enum.EasingStyle.Quad), {
            Size = originalSize,
            BackgroundColor3 = originalBgColor,
            TextSize = originalTextSize
        }):Play()
    end)
end

-- Function to handle key verification feedback
local function showKeyFeedback(keyBox: TextBox, success: boolean, message: string?)
    local flashColor = success and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(255, 60, 60)
    local originalColor = Config.TextInputColor

    -- Flash the key box background
    createTween(keyBox, TweenInfo.new(Config.KeyErrorFlashDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 1, true), {
        BackgroundColor3 = flashColor
    }):Play()

    -- You could also briefly change placeholder text for feedback
    local originalPlaceholder = keyBox.PlaceholderText
    keyBox.PlaceholderText = message or (success and "KEY ACCEPTED!" or "INVALID KEY!")
    task.wait(Config.KeyErrorFlashDuration * 2) -- Wait for the flash animation

    keyBox.PlaceholderText = originalPlaceholder
    keyBox.Text = "" -- Clear the key box after attempt
end

--- UI Element Creation Functions ---
local function createCoreUI()
    -- Check if UI already exists from previous execution and destroy it
    if _G.LunarixLoader.ScreenGui then
        _G.LunarixLoader.ScreenGui:Destroy()
        if _G.LunarixLoader.Blur then
            _G.LunarixLoader.Blur:Destroy()
        end
        _G.LunarixLoader = {} -- Clear the global table
    end

    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "LunarixLoader"
    UI.ScreenGui.ResetOnSpawn = false
    UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.ScreenGui.Parent = LocalPlayer.PlayerGui -- Parent to PlayerGui for executor compatibility

    UI.Blur = Instance.new("BlurEffect")
    UI.Blur.Size = 0 -- Start at 0 for fade-in
    UI.Blur.Parent = Lighting

    UI.Container = Instance.new("Frame")
    UI.Container.BackgroundColor3 = Config.BackgroundDimColor
    UI.Container.BackgroundTransparency = 1 -- Start transparent
    UI.Container.Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight)
    UI.Container.Position = UDim2.new(0.5, -Config.ContainerWidth / 2, 0.5, -Config.ContainerHeight / 2)
    UI.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.Container.BorderSizePixel = 0
    UI.Container.ClipsDescendants = true -- Important for rounded corners
    UI.Container.Parent = UI.ScreenGui

    UI.ContainerCorner = Instance.new("UICorner")
    UI.ContainerCorner.CornerRadius = Config.ContainerCornerRadius
    UI.ContainerCorner.Parent = UI.Container

    UI.ContainerStroke = Instance.new("UIStroke")
    UI.ContainerStroke.Color = Config.BorderColor
    UI.ContainerStroke.Thickness = Config.StrokeThickness
    UI.ContainerStroke.Transparency = 1 -- Start transparent
    UI.ContainerStroke.Parent = UI.Container

    -- Drop Shadow (using a separate frame with UI_Gradient and blur)
    UI.DropShadow = Instance.new("Frame")
    UI.DropShadow.Name = "DropShadow"
    UI.DropShadow.Size = UDim2.new(1, Config.ContainerShadowOffset.X, 1, Config.ContainerShadowOffset.Y)
    UI.DropShadow.Position = UDim2.new(0, -Config.ContainerShadowOffset.X / 2, 0, -Config.ContainerShadowOffset.Y / 2) -- Center the shadow behind the container
    UI.DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.DropShadow.BackgroundTransparency = 1
    UI.DropShadow.ZIndex = Config.ZIndexBase - 1 -- Behind the container
    UI.DropShadow.Parent = UI.ScreenGui -- Parent to ScreenGui to be behind container

    local ShadowGradient = Instance.new("UIGradient")
    ShadowGradient.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
    ShadowGradient.Transparency = NumberSequence.new(0.6, 0.9) -- Fades out more
    ShadowGradient.Parent = UI.DropShadow

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = Config.ContainerCornerRadius
    ShadowCorner.Parent = UI.DropShadow

    local ShadowEffect = Instance.new("UIBlurEffect") -- This is not a real UI effect, just for conceptual clarity
    -- In Roblox, you would use a 'DropShadow' ImageLabel or manually draw a shadow effect.
    -- For simplicity, let's just make the DropShadow a dark, slightly offset frame.
    UI.DropShadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    UI.DropShadow.BackgroundTransparency = 0.7 -- Semi-transparent
    UI.DropShadow.Size = UDim2.new(1, 40, 1, 40) -- Larger to simulate blur
    UI.DropShadow.Position = UDim2.new(0.5, -Config.ContainerWidth / 2 - 20, 0.5, -Config.ContainerHeight / 2 - 20 + Config.ContainerShadowOffset.Y)
    UI.DropShadow.ZIndex = Config.ZIndexBase - 1
    -- Actual drop shadow is complex with pure UI elements, often uses images.
    -- For now, the BlurEffect on Lighting is the main visual effect.

    -- Add a subtle inner glow/overlay for depth
    UI.InnerGlow = Instance.new("Frame")
    UI.InnerGlow.Size = UDim2.new(1,0,1,0)
    UI.InnerGlow.BackgroundTransparency = 1
    UI.InnerGlow.ZIndex = Config.ZIndexBase + 1
    UI.InnerGlow.Parent = UI.Container

    local UIGradientInner = Instance.new("UIGradient")
    UIGradientInner.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,32,45)) -- Darker bottom for subtle depth
    })
    UIGradientInner.Rotation = 270
    UIGradientInner.Transparency = NumberSequence.new(0.9, 1)
    UIGradientInner.Parent = UI.InnerGlow
end

local function createLoadingElements()
    UI.Moon = Instance.new("TextLabel")
    UI.Moon.Text = Config.MoonEmoji
    UI.Moon.Font = Enum.Font.SourceSans
    UI.Moon.TextSize = Config.MoonIconTextSizeInitial
    UI.Moon.Size = UDim2.new(0, Config.MoonIconSizeInitial, 0, Config.MoonIconSizeInitial)
    UI.Moon.Position = UDim2.new(0.5, -Config.MoonIconSizeInitial / 2, 0.28, -Config.MoonIconSizeInitial / 2) -- Slightly higher
    UI.Moon.BackgroundTransparency = 1
    UI.Moon.TextTransparency = 1
    UI.Moon.ZIndex = Config.ZIndexOverlay
    UI.Moon.Parent = UI.Container

    UI.Title = Instance.new("TextLabel")
    UI.Title.Text = Config.TitleText
    UI.Title.Font = Enum.Font.GothamBold
    UI.Title.TextSize = Config.TitleTextSize
    UI.Title.TextColor3 = Config.PrimaryTextColor
    UI.Title.BackgroundTransparency = 1
    UI.Title.Size = UDim2.new(0.9, 0, 0, 40) -- Taller to accommodate larger text
    UI.Title.Position = UDim2.new(0.05, 0, 0.45, 0)
    UI.Title.TextXAlignment = Enum.TextXAlignment.Center
    UI.Title.TextTransparency = 1
    UI.Title.ZIndex = Config.ZIndexOverlay

    local TitleGlow = Instance.new("UIGradient")
    TitleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.PrimaryTextColor),
        ColorSequenceKeypoint.new(0.5, Config.AccentBlueLight:Lerp(Color3.new(1,1,1), 0.4)), -- Brighter mix
        ColorSequenceKeypoint.new(1, Config.PrimaryTextColor)
    })
    TitleGlow.Rotation = 0
    TitleGlow.Transparency = NumberSequence.new(0.7, 0.9, 0.7) -- Fades in from ends to middle
    TitleGlow.Parent = UI.Title
    UI.Title.Parent = UI.Container

    UI.Subtitle = Instance.new("TextLabel")
    UI.Subtitle.Text = Config.SubtitleText
    UI.Subtitle.Font = Enum.Font.GothamMedium
    UI.Subtitle.TextSize = Config.SubtitleTextSize
    UI.Subtitle.TextColor3 = Config.SecondaryTextColor
    UI.Subtitle.BackgroundTransparency = 1
    UI.Subtitle.Size = UDim2.new(0.9, 0, 0, 30) -- Taller for multi-line or decorative text
    UI.Subtitle.Position = UDim2.new(0.05, 0, 0.58, 0) -- Adjusted position
    UI.Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    UI.Subtitle.TextTransparency = 1
    UI.Subtitle.ZIndex = Config.ZIndexOverlay
    UI.Subtitle.Parent = UI.Container

    UI.LoadingBarBack = Instance.new("Frame")
    UI.LoadingBarBack.BackgroundColor3 = Config.LoadingBarTrack
    UI.LoadingBarBack.Size = UDim2.new(0.8, 0, 0, Config.LoadingBarHeight)
    UI.LoadingBarBack.Position = UDim2.new(0.1, 0, 0.82, 0) -- Centered
    UI.LoadingBarBack.BorderSizePixel = 0
    UI.LoadingBarBack.ZIndex = Config.ZIndexOverlay
    UI.LoadingBarBack.Parent = UI.Container

    UI.LoadingBarCorner = Instance.new("UICorner")
    UI.LoadingBarCorner.CornerRadius = UDim.new(1, 0)
    UI.LoadingBarCorner.Parent = UI.LoadingBarBack

    UI.LoadingBar = Instance.new("Frame")
    UI.LoadingBar.BackgroundColor3 = Config.LoadingBarFillStart
    UI.LoadingBar.Size = UDim2.new(0, 0, 1, 0)
    UI.LoadingBar.BorderSizePixel = 0
    UI.LoadingBar.ZIndex = Config.ZIndexTop
    UI.LoadingBar.Parent = UI.LoadingBarBack

    UI.LoadingBarGradient = Instance.new("UIGradient")
    UI.LoadingBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.LoadingBarFillStart),
        ColorSequenceKeypoint.new(1, Config.LoadingBarFillEnd)
    })
    UI.LoadingBarGradient.Rotation = 0
    UI.LoadingBarGradient.Parent = UI.LoadingBar

    UI.LoadingBarCorner2 = Instance.new("UICorner")
    UI.LoadingBarCorner2.CornerRadius = UDim.new(1, 0)
    UI.LoadingBarCorner2.Parent = UI.LoadingBar
end

local function createKeySystemElements()
    UI.KeyFrame = Instance.new("Frame")
    UI.KeyFrame.BackgroundTransparency = 1
    UI.KeyFrame.Size = UDim2.new(1, 0, 1, 0)
    UI.KeyFrame.Visible = false
    UI.KeyFrame.Parent = UI.Container

    UI.KeyBox = Instance.new("TextBox")
    UI.KeyBox.PlaceholderText = Config.KeyBoxPlaceholder
    UI.KeyBox.Size = UDim2.new(0.7, 0, 0, Config.TextInputHeight)
    UI.KeyBox.Position = UDim2.new(0.5, -UI.KeyBox.Size.X.Offset / 2, 0.4, 0)
    UI.KeyBox.BackgroundColor3 = Config.TextInputColor
    UI.KeyBox.TextColor3 = Config.PrimaryTextColor
    UI.KeyBox.PlaceholderColor3 = Config.PlaceholderColor
    UI.KeyBox.Font = Enum.Font.Gotham
    UI.KeyBox.TextSize = 18
    UI.KeyBox.Text = ""
    UI.KeyBox.ClearTextOnFocus = false
    UI.KeyBox.Visible = false
    UI.KeyBox.TextTransparency = 1
    UI.KeyBox.BackgroundTransparency = 1

    UI.KeyBoxCorner = Instance.new("UICorner")
    UI.KeyBoxCorner.CornerRadius = Config.ButtonCornerRadius
    UI.KeyBoxCorner.Parent = UI.KeyBox

    UI.KeyBoxStroke = Instance.new("UIStroke")
    UI.KeyBoxStroke.Color = Config.BorderColor
    UI.KeyBoxStroke.Thickness = 1.5
    UI.KeyBoxStroke.Transparency = 1
    UI.KeyBoxStroke.Parent = UI.KeyBox
    UI.KeyBox.Parent = UI.KeyFrame

    UI.CheckKeyButton = Instance.new("TextButton")
    UI.CheckKeyButton.Text = Config.VerifyButtonText
    UI.CheckKeyButton.Size = UDim2.new(0.7, 0, 0, Config.ButtonHeight)
    UI.CheckKeyButton.Position = UDim2.new(0.5, -UI.CheckKeyButton.Size.X.Offset / 2, 0.6, 0)
    UI.CheckKeyButton.BackgroundColor3 = Config.AccentBlue
    UI.CheckKeyButton.TextColor3 = Color3.new(1, 1, 1)
    UI.CheckKeyButton.Font = Enum.Font.GothamBold
    UI.CheckKeyButton.TextSize = 17
    UI.CheckKeyButton.AutoButtonColor = false
    UI.CheckKeyButton.Visible = false
    UI.CheckKeyButton.TextTransparency = 1
    UI.CheckKeyButton.BackgroundTransparency = 1

    UI.CheckKeyCorner = Instance.new("UICorner")
    UI.CheckKeyCorner.CornerRadius = Config.ButtonCornerRadius
    UI.CheckKeyCorner.Parent = UI.CheckKeyButton

    UI.CheckKeyGradient = Instance.new("UIGradient")
    UI.CheckKeyGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.AccentBlueLight),
        ColorSequenceKeypoint.new(1, Config.AccentBlue)
    })
    UI.CheckKeyGradient.Rotation = 90
    UI.CheckKeyGradient.Parent = UI.CheckKeyButton
    UI.CheckKeyButton.Parent = UI.KeyFrame

    UI.GetKeyButton = Instance.new("TextButton")
    UI.GetKeyButton.Text = Config.GetButtonText
    UI.GetKeyButton.Size = UDim2.new(0.7, 0, 0, Config.ButtonHeight)
    UI.GetKeyButton.Position = UDim2.new(0.5, -UI.GetKeyButton.Size.X.Offset / 2, 0.75, 0)
    UI.GetKeyButton.BackgroundColor3 = Config.AccentPurple
    UI.GetKeyButton.TextColor3 = Color3.new(1, 1, 1)
    UI.GetKeyButton.Font = Enum.Font.GothamBold
    UI.GetKeyButton.TextSize = 17
    UI.GetKeyButton.AutoButtonColor = false
    UI.GetKeyButton.Visible = false
    UI.GetKeyButton.TextTransparency = 1
    UI.GetKeyButton.BackgroundTransparency = 1

    UI.GetKeyCorner = Instance.new("UICorner")
    UI.GetKeyCorner.CornerRadius = Config.ButtonCornerRadius
    UI.GetKeyCorner.Parent = UI.GetKeyButton

    UI.GetKeyGradient = Instance.new("UIGradient")
    UI.GetKeyGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.AccentPurpleLight),
        ColorSequenceKeypoint.new(1, Config.AccentPurple)
    })
    UI.GetKeyGradient.Rotation = 90
    UI.GetKeyGradient.Parent = UI.GetKeyButton
    UI.GetKeyButton.Parent = UI.KeyFrame

    UI.CloseButton = Instance.new("ImageButton")
    UI.CloseButton.Image = Config.CloseButtonImageId
    UI.CloseButton.ImageRectOffset = Vector2.new(284, 4)
    UI.CloseButton.ImageRectSize = Vector2.new(24, 24)
    UI.CloseButton.Size = UDim2.new(0, 32, 0, 32) -- Slightly larger for easier clicking
    UI.CloseButton.Position = UDim2.new(1, -40, 0, 15) -- More padding
    UI.CloseButton.BackgroundTransparency = 1
    UI.CloseButton.Visible = false
    UI.CloseButton.ImageTransparency = 1
    UI.CloseButton.ZIndex = Config.ZIndexTop
    UI.CloseButton.Parent = UI.Container
end

--- Animation Sequences ---
local function showKeySystem()
    -- Animate out loading elements with fade and slight scale down
    createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    createTween(UI.Title, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    createTween(UI.Subtitle, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    createTween(UI.LoadingBarBack, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    createTween(UI.LoadingBar, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()

    task.wait(Config.TransitionToKeySystemDuration * 0.7)
    UI.Title.Visible = false
    UI.Subtitle.Visible = false
    UI.LoadingBarBack.Visible = false

    -- Animate moon to top-left and shrink
    createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, Config.MoonIconSizeKeyPhase, 0, Config.MoonIconSizeKeyPhase),
        Position = UDim2.new(0, 15, 0, 15),
        TextSize = Config.MoonIconTextSizeKeyPhase
    }):Play()
    createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.5), {TextTransparency = 0}):Play() -- Fade moon back in

    -- Show key system elements with smooth cascade
    UI.KeyFrame.Visible = true
    task.wait(0.1)

    UI.KeyBox.Visible = true
    createTween(UI.KeyBox, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -UI.KeyBox.Size.X.Offset / 2, 0.4, 0)
    }):Play()
    createTween(UI.KeyBoxStroke, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    task.wait(0.15)

    UI.CheckKeyButton.Visible = true
    createTween(UI.CheckKeyButton, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -UI.CheckKeyButton.Size.X.Offset / 2, 0.6, 0)
    }):Play()
    task.wait(0.15)

    UI.GetKeyButton.Visible = true
    createTween(UI.GetKeyButton, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -UI.GetKeyButton.Size.X.Offset / 2, 0.75, 0)
    }):Play()

    -- Show close button with fade-in
    UI.CloseButton.Visible = true
    createTween(UI.CloseButton, TweenInfo.new(Config.KeyElementsAppearDuration * 0.5), {ImageTransparency = 0}):Play()
end

local function closeUI()
    -- Fade out all active elements within the container
    createTween(UI.KeyBox, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    createTween(UI.KeyBoxStroke, TweenInfo.new(Config.CloseUIDuration * 0.5), {Transparency = 1}):Play()
    createTween(UI.CheckKeyButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    createTween(UI.GetKeyButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    createTween(UI.Moon, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1}):Play()
    createTween(UI.CloseButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {ImageTransparency = 1}):Play()
    createTween(UI.ContainerStroke, TweenInfo.new(Config.CloseUIDuration * 0.5), {Transparency = 1}):Play()

    -- Animate container collapse and fade out background
    createTween(UI.Container, TweenInfo.new(Config.CloseUIDuration, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()

    -- Fade out blur
    createTween(UI.Blur, TweenInfo.new(Config.CloseUIDuration), {Size = 0}):Play()

    -- Also fade out/hide the drop shadow
    if UI.DropShadow then
        createTween(UI.DropShadow, TweenInfo.new(Config.CloseUIDuration * 0.5), {BackgroundTransparency = 1}):Play()
    end

    task.wait(Config.CloseUIDuration + 0.1)
    if UI.ScreenGui then UI.ScreenGui:Destroy() end
    if UI.Blur then UI.Blur:Destroy() end
    if UI.DropShadow then UI.DropShadow:Destroy() end

    -- Clear global reference
    _G.LunarixLoader = {}
end

-- Main animation sequence
local function animateLoader()
    -- Initial blur fade-in
    createTween(UI.Blur, TweenInfo.new(Config.FadeInDuration), {Size = Config.BlurSize}):Play()

    -- Container fade-in and scale-in (with shadow following)
    UI.Container.BackgroundTransparency = 1
    UI.ContainerStroke.Transparency = 1
    UI.Container.Size = UDim2.new(0, Config.ContainerWidth * 0.8, 0, Config.ContainerHeight * 0.8)
    UI.Container.Position = UDim2.new(0.5, -(Config.ContainerWidth * 0.8) / 2, 0.5, -(Config.ContainerHeight * 0.8) / 2)

    local containerTween = createTween(UI.Container, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.OutBack), {
        Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight),
        Position = UDim2.new(0.5, -Config.ContainerWidth / 2, 0.5, -Config.ContainerHeight / 2),
        BackgroundTransparency = 0.05
    })
    containerTween:Play()

    -- Shadow animation (must follow the container's position)
    UI.DropShadow.Size = UDim2.new(1, Config.ContainerWidth * 0.8 * 0.1, 1, Config.ContainerHeight * 0.8 * 0.1)
    UI.DropShadow.Position = UDim2.new(0.5, -(Config.ContainerWidth * 0.8) / 2 - 20, 0.5, -(Config.ContainerHeight * 0.8) / 2 - 20 + Config.ContainerShadowOffset.Y)

    local shadowTween = createTween(UI.DropShadow, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.OutBack), {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, -Config.ContainerWidth / 2 - 20, 0.5, -Config.ContainerHeight / 2 - 20 + Config.ContainerShadowOffset.Y),
        BackgroundTransparency = 0.5 -- Fade in shadow
    })
    shadowTween:Play()

    createTween(UI.ContainerStroke, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.Quad), {Transparency = 0}):Play()

    task.wait(Config.ScaleInDuration * 0.6)

    -- Moon emoji appear with subtle zoom and then bounce
    UI.Moon.TextTransparency = 1
    UI.Moon.Scale = 0.8
    createTween(UI.Moon, TweenInfo.new(Config.MoonAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        Scale = 1
    }):Play()

    task.wait(Config.MoonAppearDuration * 0.8)

    -- Moon bounce animation
    local moonBounce1 = createTween(UI.Moon, TweenInfo.new(Config.MoonBounceDuration1, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, Config.MoonIconSizeInitial + 10, 0, Config.MoonIconSizeInitial + 10),
        Position = UDim2.new(0.5, -(Config.MoonIconSizeInitial + 10) / 2, 0.28, -(Config.MoonIconSizeInitial + 10) / 2)
    })
    local moonBounce2 = createTween(UI.Moon, TweenInfo.new(Config.MoonBounceDuration2, Enum.EasingStyle.Elastic), {
        Size = UDim2.new(0, Config.MoonIconSizeInitial, 0, Config.MoonIconSizeInitial),
        Position = UDim2.new(0.5, -Config.MoonIconSizeInitial / 2, 0.28, -Config.MoonIconSizeInitial / 2)
    })

    moonBounce1:Play()
    task.wait(Config.MoonBounceDuration1)
    moonBounce2:Play()
    task.wait(Config.MoonBounceDuration2)

    -- Show title with fade and slight upward movement
    createTween(UI.Title, TweenInfo.new(Config.TextSlideInDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        Position = UDim2.new(0.05, 0, 0.45, 0)
    }):Play()

    task.wait(Config.TextSlideInDuration * 0.3)

    -- Show subtitle with fade
    createTween(UI.Subtitle, TweenInfo.new(Config.TextSlideInDuration, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    -- Animate loading bar fill
    createTween(UI.LoadingBar, TweenInfo.new(Config.LoadingBarFillDuration, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 1, 0)}):Play()

    -- Animate gradient for loading bar (continuous loop)
    local gradientTweenInfo = TweenInfo.new(Config.GradientCycleDuration, Enum.EasingStyle.Linear)
    local gradientProperties = {Offset = Vector2.new(1, 0)}

    task.spawn(function()
        while UI.LoadingBar.Parent do
            UI.LoadingBarGradient.Offset = Vector2.new(-1, 0)
            createTween(UI.LoadingBarGradient, gradientTweenInfo, gradientProperties):Play()
            task.wait(Config.GradientCycleDuration)
        end
    end)

    task.wait(Config.LoadingBarFillDuration + 0.5)
    showKeySystem()
end

--- Initialize UI and Connect Events ---
local function initLoader()
    -- Store UI references in the global table for external access/cleanup
    _G.LunarixLoader.UI = UI

    createCoreUI()
    createLoadingElements()
    createKeySystemElements()

    -- Parent the UI table to _G.LunarixLoader
    _G.LunarixLoader.ScreenGui = UI.ScreenGui
    _G.LunarixLoader.Blur = UI.Blur

    applyModernButtonEffect(UI.CheckKeyButton)
    applyModernButtonEffect(UI.GetKeyButton)

    -- Button Connections
    UI.CheckKeyButton.MouseButton1Click:Connect(function()
        local enteredKey = UI.KeyBox.Text:lower()
        if string.len(enteredKey) > 0 then
            -- Replace with your actual key verification logic
            -- This could involve a server-side check via HttpService if you have a custom web API,
            -- or a simple client-side check if you want to keep it contained.
            -- IMPORTANT: Client-side key checks are insecure for real systems!

            if enteredKey == "testkey" then
                showKeyFeedback(UI.KeyBox, true, "ACCESS GRANTED")
                -- Optional: Give time for feedback animation before closing
                task.wait(1.5)
                closeUI()
            elseif enteredKey == "admin" then -- Example for another special key
                showKeyFeedback(UI.KeyBox, true, "ADMIN ACCESS!")
                task.wait(1.5)
                closeUI()
            else
                showKeyFeedback(UI.KeyBox, false, "INVALID KEY")
            end
        else
            showKeyFeedback(UI.KeyBox, false, "KEY REQUIRED")
        end
    end)

    UI.GetKeyButton.MouseButton1Click:Connect(function()
        print("Redirecting to get key (Executor Context)...")
        -- In an executor, you often have more control.
        -- You might try to open a URL directly, or print it to console.
        -- Example for a common executor function (might vary):
        if shared and shared.openurl then
            shared.openurl("https://yourwebsite.com/getkey") -- Replace with your actual key website
        else
            -- Fallback for executors without 'openurl' or if not in shared.
            LocalPlayer:SendMessage("Visit https://yourwebsite.com/getkey to obtain a key.")
            print("Please open this URL in your browser: https://yourwebsite.com/getkey")
        end
    end)

    UI.CloseButton.MouseButton1Click:Connect(closeUI)

    -- Input handling for KeyBox (Enter to verify)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and UI.KeyBox.Visible and UI.KeyBox:IsFocused() then
            if input.KeyCode == Enum.KeyCode.Return then
                UI.CheckKeyButton.MouseButton1Click:Fire()
            end
        end
    end)

    -- Start the main animation sequence
    animateLoader()
end

-- Run the loader initialization
initLoader()
