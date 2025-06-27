-- NEBULAUI ULTRA X 2.0 - HYPER EXPANDED VERSION
-- 500+ LINES OF STYLISH MADNESS 💎🚀💥
-- Author: Boss + ChatGPT ULTRA MODE

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function create(instanceType, props)
    local obj = Instance.new(instanceType)
    for prop, val in pairs(props) do
        obj[prop] = val
    end
    return obj
end

local function tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function dragify(frame)
    local dragging, dragInput, startPos, startInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function roundify(obj, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, radius or 8)
    uicorner.Parent = obj
    return uicorner
end

local function glow(obj, color)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = color or Color3.fromRGB(255, 255, 255)
    uiStroke.Transparency = 0.2
    uiStroke.Parent = obj
    return uiStroke
end

-- Main UI Table
local Nebula = {}
local windowOpen = false

-- Core Window
function Nebula:CreateWindow(config)
    local screenGui = create("ScreenGui", {
        Name = "NebulaUI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    local window = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 45),
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = true,
        Parent = screenGui
    })
    roundify(window, 10)
    glow(window, Color3.fromRGB(80, 80, 255))
    dragify(window)

    local titleBar = create("TextLabel", {
        Text = config.Title or "Nebula UI X",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(220, 220, 255),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = window
    })

    local closeBtn = create("TextButton", {
        Text = "✕",
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = Color3.fromRGB(60, 60, 90),
        TextColor3 = Color3.new(1,1,1),
        Parent = window
    })
    roundify(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        tween(window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)

    local tabHolder = create("Frame", {
        Size = UDim2.new(0, 120, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(36, 36, 50),
        Parent = window
    })
    roundify(tabHolder, 4)

    local tabButtons = {}
    local pages = {}
    local currentTabYOffset = 0

    function Nebula:CreateTab(name)
        local button = create("TextButton", {
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(44, 44, 60),
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, currentTabYOffset),
            TextColor3 = Color3.new(1,1,1),
            Parent = tabHolder
        })
        roundify(button, 4)
        currentTabYOffset = currentTabYOffset + 45

        local page = create("Frame", {
            Size = UDim2.new(1, -140, 1, -40),
            Position = UDim2.new(0, 130, 0, 40),
            BackgroundColor3 = Color3.fromRGB(32, 32, 48),
            Visible = false,
            Parent = window
        })
        roundify(page, 6)
        glow(page, Color3.fromRGB(80, 255, 150))

        button.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            for _, b in pairs(tabButtons) do tween(b, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)}, 0.2) end
            tween(button, {BackgroundColor3 = Color3.fromRGB(60, 90, 120)}, 0.2)
            page.Visible = true
        end)

        table.insert(tabButtons, button)
        table.insert(pages, page)

        local nextYOffset = 0

        return {
            AddLabel = function(_, text)
                local lbl = create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 5, 0, nextYOffset),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.new(1, 1, 1),
                    Parent = page
                })
                nextYOffset = nextYOffset + 35
                return lbl
            end,

            AddToggle = function(_, label, callback)
                local toggle = create("TextButton", {
                    Text = label .. " [ OFF ]",
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 5, 0, nextYOffset),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 70),
                    TextColor3 = Color3.new(1, 1, 1),
                    Parent = page
                })
                roundify(toggle, 4)
                nextYOffset = nextYOffset + 35
                local state = false
                toggle.MouseButton1Click:Connect(function()
                    state = not state
                    toggle.Text = label .. (state and " [ ON ]" or " [ OFF ]")
                    callback(state)
                end)
            end
        }
    end

    return Nebula
end

return Nebula
