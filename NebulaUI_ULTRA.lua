--[[
    NebulaUI - ULTRA MODE 🚀 by Boss
    🔘 Toggle ✅ Dropdown 💬 Notification 💾 JSON Save
]]--

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local NebulaUI = {}
NebulaUI.__index = NebulaUI

local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(100, 149, 237)
    }
}

local SettingsStore = {}

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Notification
local function Notify(parent, msg, theme)
    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(0, 200, 0, 30)
    note.Text = msg
    note.TextColor3 = theme.Foreground
    note.BackgroundColor3 = theme.Accent
    note.Font = Enum.Font.Gotham
    note.TextSize = 14
    note.Position = UDim2.new(1, 20, 0, math.random(10, 150))
    note.Parent = parent
    tween(note, {Position = UDim2.new(1, -210, 0, note.Position.Y.Offset)}, 0.3)
    task.delay(4, function()
        tween(note, {TextTransparency = 1, BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        note:Destroy()
    end)
end

-- Toggle
local function CreateToggle(parent, text, default, callback, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = theme.Foreground
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, -10, 1, -4)
    toggle.Position = UDim2.new(0.7, 10, 0, 2)
    toggle.Text = default and "ON" or "OFF"
    toggle.BackgroundColor3 = default and theme.Accent or Color3.fromRGB(60, 60, 60)
    toggle.TextColor3 = theme.Foreground
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.BorderSizePixel = 0
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        tween(toggle, {BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60, 60, 60)})
        callback(state)
    end)
end

-- Dropdown
local function CreateDropdown(parent, labelText, options, callback, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30 + (#options * 24))
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = labelText
    label.TextColor3 = theme.Foreground
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    for i, v in ipairs(options) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 24)
        opt.Position = UDim2.new(0, 0, 0, 30 + ((i - 1) * 24))
        opt.Text = v
        opt.BackgroundColor3 = theme.Background
        opt.TextColor3 = theme.Foreground
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 13
        opt.BorderSizePixel = 0
        opt.Parent = frame

        opt.MouseButton1Click:Connect(function()
            callback(v)
        end)
    end
end

-- JSON Save
function NebulaUI:SaveSettings(fileName)
    writefile(fileName, HttpService:JSONEncode(SettingsStore))
end

function NebulaUI:LoadSettings(fileName)
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        for k, v in pairs(data) do
            SettingsStore[k] = v
        end
    end
end

-- Create Window
function NebulaUI:CreateWindow(config)
    local theme = Themes["Dark"]
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "NebulaUI"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.BackgroundColor3 = theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Nebula 🔭"
    Title.TextColor3 = theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local api = {}

    function api:CreateButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 30)
        btn.Text = name
        btn.TextColor3 = theme.Foreground
        btn.BackgroundColor3 = theme.Accent
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = Container
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    function api:CreateToggle(name, default, callback)
        CreateToggle(Container, name, default, function(val)
            SettingsStore[name] = val
            callback(val)
        end, theme)
    end

    function api:CreateDropdown(name, list, callback)
        CreateDropdown(Container, name, list, callback, theme)
    end

    function api:Notify(text)
        Notify(Main, text, theme)
    end

    function api:Save(name)
        NebulaUI:SaveSettings(name)
    end

    function api:Load(name)
        NebulaUI:LoadSettings(name)
    end

    return api
end

return NebulaUI
