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
_[span_0](start_span)G.LunarixLoader = _G.LunarixLoader or {}[span_0](end_span)

-- Configuration (Even more refined for premium aesthetics)
local Config = {
    -- Theme Colors (Inspired by deep space, subtle nebulae, and glowing elements)
    BackgroundDimColor = Color3.fromRGB(12, 15, 22),   -- Very dark base for container
    BorderColor = Color3.fromRGB(35, 45, 65),       -- Subtle, cool border
    TextInputColor = Color3.fromRGB(20, 26, 36),   -- Darker input field background
    PlaceholderColor = Color3.fromRGB(110, 125, 140), -- Softer, desaturated placeholder text
    [span_1](start_span)PrimaryTextColor = Color3.fromRGB(235, 245, 255),[span_1](end_span) -- Crisp, bright white for main text
    SecondaryTextColor = Color3.fromRGB(140, 160, 180), -- Muted blue-grey for descriptive text

    -- Accent Colors (Vibrant, high-contrast blues and purples)
    AccentBlue = Color3.fromRGB(40, 90, 220),      -- Deep, electric blue for primary action
    AccentBlueLight = Color3.fromRGB(80, 130, 255), -- Brighter blue for gradients
    AccentPurple = Color3.fromRGB(90, 50, 170),    -- Rich, mysterious purple for secondary action
    AccentPurpleLight = Color3.fromRGB(130, 80, 210), -- Lighter purple for gradients

    -[span_2](start_span)- Loader Specific Colors[span_2](end_span)
    LoadingBarFillStart = Color3.fromRGB(70, 130, 255), -- Dynamic loading bar gradient start
    LoadingBarFillEnd = Color3.fromRGB(140, 200, 255), -- Dynamic loading bar gradient end
    LoadingBarTrack = Color3.fromRGB(25, 33, 50),       -- Darker track for loading bar

    -- UI Dimensions & Properties
    ContainerWidth = 450, -- Slightly wider
    ContainerHeight = 340, -- Slightly taller
    ContainerCornerRadius = UDim.new(0, 20), -- Even larger radius for softer, rounded corners
    [span_3](start_span)StrokeThickness = 2.5,[span_3](end_span) -- More prominent stroke
    ContainerShadowOffset = Vector2.new(0, 8), -- Offset for subtle drop shadow
    ContainerShadowBlur = 15,                -- Blur for the shadow

    MoonIconSizeInitial = 100,
    MoonIconSizeKeyPhase = 50,
    MoonIconTextSizeInitial = 92,
    MoonIconTextSizeKeyPhase = 42,

    TitleTextSize = 34,
    SubtitleTextSize = 19,

    [span_4](start_span)TextInputHeight = 50,[span_4](end_span) -- Taller input field
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

    [span_5](start_span)GradientCycleDuration = 3.0,[span_5](end_span) -- Slower gradient cycle
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
    [span_6](start_span)SubtitleText = "✦ Navigate the Cosmos ✦", -- Replaced invalid characters[span_6](end_span)
    KeyBoxPlaceholder = "ENTER YOUR ACCESS KEY",
    VerifyButtonText = "VERIFY", -- Shorter, punchier
    GetButtonText = "GET KEY",
    MoonEmoji = "🌕", -- Replaced invalid character

    -- Asset IDs
    [span_7](start_span)CloseButtonImageId = "rbxassetid://3926305904", -- Standard Roblox Close Icon[span_7](end_span)
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

    -- Instead of changing offset, we'll just slightly grow it from the center
    local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 4)
    local hoverBgColor = originalBgColor:Lerp(Color3.fromRGB(255,255,255), 0.15) -- Brighter on hover
    [span_8](start_span)local hoverTextSize = originalTextSize * 1.05 -- Text scales slightly[span_8](end_span)

    button.MouseEnter:Connect(function()
        createTween(button, TweenInfo.new(Config.ButtonHoverDuration, Enum.EasingStyle.Quad), {
            Size = hoverSize,
            BackgroundColor3 = hoverBgColor,
            TextSize = hoverTextSize
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        createTween(button, TweenInfo.new(Config.ButtonHoverDuration, Enum.EasingStyle.Quad), {
            [span_9](start_span)Size = originalSize,[span_9](end_span)
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
        [span_10](start_span)BackgroundColor3 = flashColor[span_10](end_span)
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
    [span_11](start_span)if _G.LunarixLoader.ScreenGui then[span_11](end_span)
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
    [span_12](start_span)UI.ScreenGui.Parent = LocalPlayer.PlayerGui -- Parent to PlayerGui for executor compatibility[span_12](end_span)

    [span_13](start_span)UI.Blur = Instance.new("BlurEffect")[span_13](end_span)
    UI.Blur.Size = 0 -- Start at 0 for fade-in
    UI.Blur.Parent = Lighting

    UI.Container = Instance.new("Frame")
    UI.Container.BackgroundColor3 = Config.BackgroundDimColor
    UI.Container.BackgroundTransparency = 1 -- Start transparent
    UI.Container.Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight)
    UI.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.Container.BorderSizePixel = 0
    UI.Container.ClipsDescendants = true -- Important for rounded corners
    UI.Container.Parent = UI.ScreenGui

    [span_14](start_span)UI.ContainerCorner = Instance.new("UICorner")[span_14](end_span)
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
    -- The shadow should be slightly larger than the container and positioned behind it
    UI.DropShadow.Size = UDim2.new(1, 0, 1, 0) -- Will be scaled in animation
    UI.DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    [span_15](start_span)UI.DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)[span_15](end_span)
    [span_16](start_span)UI.DropShadow.BackgroundColor3 = Color3.fromRGB(0,0,0)[span_16](end_span)
    UI.DropShadow.BackgroundTransparency = 1 -- Start transparent, will fade in
    UI.DropShadow.ZIndex = Config.ZIndexBase - 1 -- Behind the container
    UI.DropShadow.Parent = UI.ScreenGui -- Parent to ScreenGui to be behind container

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = Config.ContainerCornerRadius
    ShadowCorner.Parent = UI.DropShadow

    -- Add a subtle inner glow/overlay for depth
    [span_17](start_span)UI.InnerGlow = Instance.new("Frame")[span_17](end_span)
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
    [span_18](start_span)UIGradientInner.Transparency = NumberSequence.new(0.9, 1)[span_18](end_span)
    UIGradientInner.Parent = UI.InnerGlow
end

local function createLoadingElements()
    UI.Moon = Instance.new("TextLabel")
    UI.Moon.Text = Config.MoonEmoji
    UI.Moon.Font = Enum.Font.SourceSans
    UI.Moon.TextSize = Config.MoonIconTextSizeInitial
    UI.Moon.Size = UDim2.new(0, Config.MoonIconSizeInitial, 0, Config.MoonIconSizeInitial)
    UI.Moon.Position = UDim2.new(0.5, 0, 0.28, 0) -- Centered AnchorPoint
    UI.Moon.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.Moon.BackgroundTransparency = 1
    UI.Moon.TextTransparency = 1
    UI.Moon.ZIndex = Config.ZIndexOverlay
    UI.Moon.Parent = UI.Container

    UI.Title = Instance.new("TextLabel")
    UI.Title.Text = Config.TitleText
    [span_19](start_span)UI.Title.Font = Enum.Font.GothamBold[span_19](end_span)
    UI.Title.TextSize = Config.TitleTextSize
    UI.Title.TextColor3 = Config.PrimaryTextColor
    UI.Title.BackgroundTransparency = 1
    UI.Title.Size = UDim2.new(0.9, 0, 0, 40) -- Taller to accommodate larger text
    UI.Title.Position = UDim2.new(0.5, 0, 0.45, 0) -- Centered AnchorPoint
    UI.Title.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.Title.TextXAlignment = Enum.TextXAlignment.Center
    UI.Title.TextTransparency = 1
    UI.Title.ZIndex = Config.ZIndexOverlay

    local TitleGlow = Instance.new("UIGradient")
    TitleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.PrimaryTextColor),
        [span_20](start_span)ColorSequenceKeypoint.new(0.5, Config.AccentBlueLight:Lerp(Color3.fromRGB(255,255,255), 0.4)), -- Brighter mix[span_20](end_span)
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
    [span_21](start_span)UI.Subtitle.Position = UDim2.new(0.5, 0, 0.58, 0) -- Adjusted position, centered[span_21](end_span)
    UI.Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    UI.Subtitle.TextTransparency = 1
    UI.Subtitle.ZIndex = Config.ZIndexOverlay
    UI.Subtitle.Parent = UI.Container

    UI.LoadingBarBack = Instance.new("Frame")
    UI.LoadingBarBack.BackgroundColor3 = Config.LoadingBarTrack
    UI.LoadingBarBack.Size = UDim2.new(0.8, 0, 0, Config.LoadingBarHeight)
    UI.LoadingBarBack.Position = UDim2.new(0.5, 0, 0.82, 0) -- Centered
    UI.LoadingBarBack.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.LoadingBarBack.BorderSizePixel = 0
    UI.LoadingBarBack.ZIndex = Config.ZIndexOverlay
    UI.LoadingBarBack.Parent = UI.Container

    UI.LoadingBarCorner = Instance.new("UICorner")
    UI.LoadingBarCorner.CornerRadius = UDim.new(1, 0)
    [span_22](start_span)UI.LoadingBarCorner.Parent = UI.LoadingBarBack[span_22](end_span)

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
    [span_23](start_span)UI.LoadingBarCorner2.Parent = UI.LoadingBar[span_23](end_span)
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
    UI.KeyBox.Position = UDim2.new(0.5, 0, 0.4, 0) -- Centered
    UI.KeyBox.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.KeyBox.BackgroundColor3 = Config.TextInputColor
    UI.KeyBox.TextColor3 = Config.PrimaryTextColor
    UI.KeyBox.PlaceholderColor3 = Config.PlaceholderColor
    UI.KeyBox.Font = Enum.Font.Gotham
    [span_24](start_span)UI.KeyBox.TextSize = 18[span_24](end_span)
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
    [span_25](start_span)UI.CheckKeyButton.Text = Config.VerifyButtonText[span_25](end_span)
    UI.CheckKeyButton.Size = UDim2.new(0.7, 0, 0, Config.ButtonHeight)
    UI.CheckKeyButton.Position = UDim2.new(0.5, 0, 0.6, 0) -- Centered
    UI.CheckKeyButton.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.CheckKeyButton.BackgroundColor3 = Config.AccentBlue
    UI.CheckKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
        [span_26](start_span)ColorSequenceKeypoint.new(0, Config.AccentBlueLight),[span_26](end_span)
        ColorSequenceKeypoint.new(1, Config.AccentBlue)
    })
    UI.CheckKeyGradient.Rotation = 90
    UI.CheckKeyGradient.Parent = UI.CheckKeyButton
    UI.CheckKeyButton.Parent = UI.KeyFrame

    UI.GetKeyButton = Instance.new("TextButton")
    UI.GetKeyButton.Text = Config.GetButtonText
    UI.GetKeyButton.Size = UDim2.new(0.7, 0, 0, Config.ButtonHeight)
    UI.GetKeyButton.Position = UDim2.new(0.5, 0, 0.75, 0) -- Centered
    UI.GetKeyButton.AnchorPoint = Vector2.new(0.5, 0.5)
    UI.GetKeyButton.BackgroundColor3 = Config.AccentPurple
    UI.GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.GetKeyButton.Font = Enum.Font.GothamBold
    UI.GetKeyButton.TextSize = 17
    [span_27](start_span)UI.GetKeyButton.AutoButtonColor = false[span_27](end_span)
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
    [span_28](start_span)UI.CloseButton.Image = Config.CloseButtonImageId[span_28](end_span)
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
    [span_29](start_span)createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()[span_29](end_span)
    createTween(UI.Title, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    createTween(UI.Subtitle, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    createTween(UI.LoadingBarBack, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    createTween(UI.LoadingBar, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()

    task.wait(Config.TransitionToKeySystemDuration * 0.7)
    UI.Title.Visible = false
    UI.Subtitle.Visible = false
    UI.LoadingBarBack.Visible = false
    -- The moon will remain visible and tween, so no need to set Visible = false for it.

    -- Animate moon to top-left and shrink
    createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, Config.MoonIconSizeKeyPhase, 0, Config.MoonIconSizeKeyPhase),
        [span_30](start_span)Position = UDim2.new(0, 15, 0, 15), -- Top-left corner[span_30](end_span)
        TextSize = Config.MoonIconTextSizeKeyPhase,
        AnchorPoint = Vector2.new(0, 0) -- Change AnchorPoint for top-left positioning
    }):Play()
    createTween(UI.Moon, TweenInfo.new(Config.TransitionToKeySystemDuration * 0.5), {TextTransparency = 0}):Play() -- Fade moon back in

    -- Show key system elements with smooth cascade
    UI.KeyFrame.Visible = true
    task.wait(0.1)

    UI.KeyBox.Visible = true
    createTween(UI.KeyBox, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        BackgroundTransparency = 0,
        [span_31](start_span)Position = UDim2.new(0.5, 0, 0.4, 0) -- Ensure it's centered if anchor point is 0.5,0.5[span_31](end_span)
    }):Play()
    createTween(UI.KeyBoxStroke, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    task.wait(0.15)

    UI.CheckKeyButton.Visible = true
    createTween(UI.CheckKeyButton, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.6, 0) -- Ensure it's centered if anchor point is 0.5,0.5
    }):Play()
    task.wait(0.15)

    UI.GetKeyButton.Visible = true
    createTween(UI.GetKeyButton, TweenInfo.new(Config.KeyElementsAppearDuration, Enum.EasingStyle.Quint), {
        [span_32](start_span)TextTransparency = 0,[span_32](end_span)
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.75, 0) -- Ensure it's centered if anchor point is 0.5,0.5
    }):Play()

    -- Show close button with fade-in
    UI.CloseButton.Visible = true
    createTween(UI.CloseButton, TweenInfo.new(Config.KeyElementsAppearDuration * 0.5), {ImageTransparency = 0}):Play()
end

local function closeUI()
    -- Fade out all active elements within the container
    createTween(UI.KeyBox, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    [span_33](start_span)createTween(UI.KeyBoxStroke, TweenInfo.new(Config.CloseUIDuration * 0.5), {Transparency = 1}):Play()[span_33](end_span)
    createTween(UI.CheckKeyButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    createTween(UI.GetKeyButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    createTween(UI.Moon, TweenInfo.new(Config.CloseUIDuration * 0.5), {TextTransparency = 1}):Play()
    createTween(UI.CloseButton, TweenInfo.new(Config.CloseUIDuration * 0.5), {ImageTransparency = 1}):Play()
    createTween(UI.ContainerStroke, TweenInfo.new(Config.CloseUIDuration * 0.5), {Transparency = 1}):Play()

    -- Animate container collapse and fade out background
    createTween(UI.Container, TweenInfo.new(Config.CloseUIDuration, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 0, 0, 0),
        [span_34](start_span)Position = UDim2.new(0.5, 0, 0.5, 0), -- Remain centered as it collapses[span_34](end_span)
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
    _[span_35](start_span)G.LunarixLoader = {}[span_35](end_span)
end

-- Main animation sequence
local function animateLoader()
    -- Initial blur fade-in
    createTween(UI.Blur, TweenInfo.new(Config.FadeInDuration), {Size = Config.BlurSize}):Play()

    -- Container fade-in and scale-in (with shadow following)
    UI.Container.BackgroundTransparency = 1
    UI.ContainerStroke.Transparency = 1
    UI.Container.Size = UDim2.new(0, Config.ContainerWidth * 0.8, 0, Config.ContainerHeight * 0.8)
    -- UI.Container.Position is already UDim2.new(0.5, 0, 0.5, 0) with AnchorPoint 0.5,0.5 for centering

    local containerTween = createTween(UI.Container, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, Config.ContainerWidth, 0, Config.ContainerHeight),
        -[span_36](start_span)- Position remains centered as AnchorPoint is 0.5,0.5[span_36](end_span)
        BackgroundTransparency = 0.05
    })
    containerTween:Play()

    -- Shadow animation (must follow the container's position and scale appropriately)
    -- Make shadow slightly larger than container
    UI.DropShadow.Size = UDim2.new(0, Config.ContainerWidth * 0.8 + 40, 0, Config.ContainerHeight * 0.8 + 40)
    -- Position it directly behind the container, offset for shadow effect
    UI.DropShadow.Position = UDim2.new(0.5, Config.ContainerShadowOffset.X / 2, 0.5, Config.ContainerShadowOffset.Y / 2)
    UI.DropShadow.BackgroundTransparency = 1 -- Start transparent

    local shadowTween = createTween(UI.DropShadow, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.Back), {
        [span_37](start_span)Size = UDim2.new(0, Config.ContainerWidth + 40, 0, Config.ContainerHeight + 40),[span_37](end_span) -- Larger to simulate blur
        BackgroundTransparency = 0.5 -- Fade in shadow
    })
    shadowTween:Play()

    createTween(UI.ContainerStroke, TweenInfo.new(Config.ScaleInDuration, Enum.EasingStyle.Quad), {Transparency = 0}):Play()

    task.wait(Config.ScaleInDuration * 0.6)

    -- Moon emoji appear with subtle zoom and then bounce
    UI.Moon.TextTransparency = 1
    -- UI.Moon.Scale is not a direct property, animate Size instead
    UI.Moon.Size = UDim2.new(0, Config.MoonIconSizeInitial * 0.8, 0, Config.MoonIconSizeInitial * 0.8)
    createTween(UI.Moon, TweenInfo.new(Config.MoonAppearDuration, Enum.EasingStyle.Quint), {
        [span_38](start_span)TextTransparency = 0,[span_38](end_span)
        Size = UDim2.new(0, Config.MoonIconSizeInitial, 0, Config.MoonIconSizeInitial)
    }):Play()

    task.wait(Config.MoonAppearDuration * 0.8)

    -- Moon bounce animation
    local moonBounce1 = createTween(UI.Moon, TweenInfo.new(Config.MoonBounceDuration1, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, Config.MoonIconSizeInitial + 10, 0, Config.MoonIconSizeInitial + 10),
        Position = UDim2.new(0.5, 0, 0.28, 0) -- Remains centered
    })
    local moonBounce2 = createTween(UI.Moon, TweenInfo.new(Config.MoonBounceDuration2, Enum.EasingStyle.Elastic), {
        [span_39](start_span)Size = UDim2.new(0, Config.MoonIconSizeInitial, 0, Config.MoonIconSizeInitial),[span_39](end_span)
        Position = UDim2.new(0.5, 0, 0.28, 0) -- Remains centered
    })

    moonBounce1:Play()
    task.wait(Config.MoonBounceDuration1)
    moonBounce2:Play()
    task.wait(Config.MoonBounceDuration2)

    -- Show title with fade and slight upward movement
    -- Ensure initial position for slide-in is slightly lower
    UI.Title.Position = UDim2.new(0.5, 0, 0.47, 0) -- Start slightly lower
    createTween(UI.Title, TweenInfo.new(Config.TextSlideInDuration, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.45, 0) -- Slide up to final position
    }):Play()

    task.wait(Config.TextSlideInDuration * 0.3)

    -[span_40](start_span)- Show subtitle with fade[span_40](end_span)
    createTween(UI.Subtitle, TweenInfo.new(Config.TextSlideInDuration, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

    -- Animate loading bar fill
    createTween(UI.LoadingBar, TweenInfo.new(Config.LoadingBarFillDuration, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 1, 0)}):Play()

    -- Animate gradient for loading bar (continuous loop)
    local gradientTweenInfo = TweenInfo.new(Config.GradientCycleDuration, Enum.EasingStyle.Linear)
    local gradientProperties = {Offset = Vector2.new(1, 0)}

    task.spawn(function()
        while UI.LoadingBar and UI.LoadingBar.Parent do -- Check for existence before accessing .Parent
            UI.LoadingBarGradient.Offset = Vector2.new(-1, 0)
            [span_41](start_span)createTween(UI.LoadingBarGradient, gradientTweenInfo, gradientProperties):Play()[span_41](end_span)
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
    _[span_42](start_span)G.LunarixLoader.ScreenGui = UI.ScreenGui[span_42](end_span)
    _G.LunarixLoader.Blur = UI.Blur

    applyModernButtonEffect(UI.CheckKeyButton)
    applyModernButtonEffect(UI.GetKeyButton)

    -- Button Connections
    UI.CheckKeyButton.MouseButton1Click:Connect(function()
        local enteredKey = UI.KeyBox.Text:lower()
        if string.len(enteredKey) > 0 then
            -- Replace with your actual key verification logic
            -- This could involve a server-side check via HttpService if you have a custom web API,
            -[span_43](start_span)- or a simple client-side check if you want to keep it contained.[span_43](end_span)
            -- IMPORTANT: Client-side key checks are insecure for real systems!
            [span_44](start_span)if enteredKey == "testkey" then[span_44](end_span)
                showKeyFeedback(UI.KeyBox, true, "ACCESS GRANTED")
                -- Optional: Give time for feedback animation before closing
                task.wait(1.5)
                closeUI()
            [span_45](start_span)elseif enteredKey == "admin" then -- Example for another special key[span_45](end_span)
                showKeyFeedback(UI.KeyBox, true, "ADMIN ACCESS!")
                task.wait(1.5)
                closeUI()
            else
                showKeyFeedback(UI.KeyBox, false, "INVALID KEY")
            end
        [span_46](start_span)else[span_46](end_span)
            showKeyFeedback(UI.KeyBox, false, "KEY REQUIRED")
        end
    end)

    UI.GetKeyButton.MouseButton1Click:Connect(function()
        print("Redirecting to get key (Executor Context)...")
        -- In an executor, you often have more control.
        -- You might try to open a URL directly, or print it to console.
        -[span_47](start_span)- Example for a common executor function (might vary):[span_47](end_span)
        if shared and shared.openurl then
            shared.openurl("https://yourwebsite.com/getkey") -- Replace with your actual key website
        else
            -- Fallback for executors without 'openurl' or if not in shared.
            [span_48](start_span)print("Please open this URL in your browser: https://yourwebsite.com/getkey")[span_48](end_span)
        end
    end)

    UI.CloseButton.MouseButton1Click:Connect(closeUI)

    -- Input handling for KeyBox (Enter to verify)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and UI.KeyBox.Visible and UI.KeyBox:IsFocused() then
            [span_49](start_span)if input.KeyCode == Enum.KeyCode.Return then[span_49](end_span)
                UI.CheckKeyButton.MouseButton1Click:Fire()
            end
        end
    end)

    -- Start the main animation sequence
    animateLoader()
end

-- Run the loader initialization
initLoader()
