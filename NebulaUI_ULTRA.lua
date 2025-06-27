-- NebulaUI ULTRA X 2.1 - Streamlined Window Control + Components + Notifications

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Nebula = {}
Nebula.__index = Nebula

-- Settings persistence (basic JSON file simulation)
local HttpService = game:GetService("HttpService")
local settingsFile = "NebulaSettings.json"
local settings = {}

local function SaveSettings()
    writefile(settingsFile, HttpService:JSONEncode(settings))
end

local function LoadSettings()
    if isfile(settingsFile) then
        local data = readfile(settingsFile)
        settings = HttpService:JSONDecode(data)
    end
end
LoadSettings()

function Nebula:SaveSetting(key, value)
    settings[key] = value
    SaveSettings()
end

function Nebula:LoadSetting(key, default)
    return settings[key] ~= nil and settings[key] or default
end

-- UTILS
local function createUICorner(inst, radius)
    local corner = Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

local function tweenObject(inst, props, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(inst, tweenInfo, props)
    tween:Play()
    return tween
end

-- WINDOW MANAGEMENT
function Nebula:OpenWindow(window)
    window.Visible = true
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.Size = UDim2.new(0, 0, 0, 0)
    window.BackgroundTransparency = 1
    tweenObject(window, {Size = UDim2.new(0, 450, 0, 350), BackgroundTransparency = 0}, 0.5)
end

function Nebula:CloseWindow(window)
    local tween = tweenObject(window, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
    tween.Completed:Connect(function()
        window.Visible = false
    end)
end

-- DRAGGABLE WINDOW SUPPORT
function Nebula:MakeDraggable(window, dragHandle)
    dragHandle = dragHandle or window
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- COMPONENTS
function Nebula:CreateToggle(parent, label, default, callback)
    local state = self:LoadSetting(label, default or false)

    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1

    local toggleFrame = Instance.new("Frame", container)
    toggleFrame.Size = UDim2.new(0, 30, 0, 20)
    toggleFrame.Position = UDim2.new(0, 10, 0, 5)
    toggleFrame.BackgroundColor3 = state and Color3.fromRGB(140, 80, 230) or Color3.fromRGB(70, 70, 70)
    createUICorner(toggleFrame, 8)

    local checkmark = Instance.new("Frame", toggleFrame)
    checkmark.Size = UDim2.new(0, 12, 0, 12)
    checkmark.Position = UDim2.new(state and 1 or 0, state and -12 or 0, 0.5, -6)
    checkmark.BackgroundColor3 = Color3.fromRGB(230, 230, 255)
    createUICorner(checkmark, 6)

    local labelText = Instance.new("TextLabel", container)
    labelText.Text = label
    labelText.Position = UDim2.new(0, 50, 0, 0)
    labelText.Size = UDim2.new(1, -50, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.GothamBold
    labelText.TextSize = 18
    labelText.TextColor3 = Color3.new(1,1,1)
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local function updateToggle(newState)
        state = newState
        self:SaveSetting(label, state)
        tweenObject(toggleFrame, {BackgroundColor3 = state and Color3.fromRGB(140, 80, 230) or Color3.fromRGB(70, 70, 70)}, 0.3)
        tweenObject(checkmark, {Position = UDim2.new(state and 1 or 0, state and -12 or 0, 0.5, -6)}, 0.3)
        if callback then
            callback(state)
        end
    end

    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle(not state)
        end
    end)

    return container
end

-- DROPDOWN (single select for clarity)
function Nebula:CreateDropdown(parent, label, options, default, callback)
    local selection = self:LoadSetting(label, default or nil)

    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", container)
    labelText.Text = label
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.Size = UDim2.new(1, -40, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.GothamBold
    labelText.TextSize = 18
    labelText.TextColor3 = Color3.new(1,1,1)
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton", container)
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(1, -30, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(140, 80, 230)
    button.Text = "▼"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.TextColor3 = Color3.new(1,1,1)
    button.AutoButtonColor = false
    createUICorner(button, 8)

    local dropdownList = Instance.new("Frame", container)
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 1, 4)
    dropdownList.BackgroundColor3 = Color3.fromRGB(38, 25, 58)
    dropdownList.ClipsDescendants = true
    createUICorner(dropdownList, 12)
    dropdownList.Visible = false

    local listLayout = Instance.new("UIListLayout", dropdownList)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)

    local function updateLabel()
        labelText.Text = label .. ": " .. (selection or "None")
    end
    updateLabel()

    local function toggleDropdown()
        if dropdownList.Visible then
            tweenObject(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.3, function() dropdownList.Visible = false end)
        else
            dropdownList.Visible = true
            tweenObject(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options*30, 180))}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end

    button.MouseButton1Click:Connect(toggleDropdown)

    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropdownList)
        optBtn.Size = UDim2.new(1, -12, 0, 28)
        optBtn.Position = UDim2.new(0, 6, 0, (i-1)*34 + 6)
        optBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 18
        optBtn.TextColor3 = Color3.new(1,1,1)
        optBtn.Text = option
        createUICorner(optBtn, 9)

        optBtn.MouseButton1Click:Connect(function()
            selection = option
            self:SaveSetting(label, selection)
            updateLabel()
            toggleDropdown()
            if callback then callback(selection) end
        end)
    end

    return container
end

-- NOTIFICATIONS (stacked, bottom-left, glow border)
function Nebula:Notify(parent, message, type)
    type = type or "neutral"
    local colors = {
        neutral = {bg = Color3.fromRGB(45, 45, 45), glow = Color3.fromRGB(180, 180, 180)},
        success = {bg = Color3.fromRGB(75, 160, 75), glow = Color3.fromRGB(100, 220, 100)},
        failed = {bg = Color3.fromRGB(160, 40, 40), glow = Color3.fromRGB(255, 50, 50)},
        warning = {bg = Color3.fromRGB(230, 210, 70), glow = Color3.fromRGB(255, 255, 140)},
    }

    local data = colors[type] or colors.neutral

    local notif = Instance.new("Frame", parent)
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0, 20, 1, -80)
    notif.BackgroundColor3 = data.bg
    createUICorner(notif, 12)
    notif.BorderSizePixel = 0

    local glow = Instance.new("UIStroke", notif)
    glow.Color = data.glow
    glow.Thickness = 3
    glow.Transparency = 0.3
    glow.LineJoinMode = Enum.LineJoinMode.Round

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    -- Animate In
    notif.Position = UDim2.new(0, 20, 1, 80)
    notif.BackgroundTransparency = 1
    local tweenIn = tweenObject(notif, {Position = UDim2.new(0, 20, 1, -80), BackgroundTransparency = 0}, 0.5)

    -- Auto Fade Out + Remove
    task.delay(5, function()
        local tweenOut = tweenObject(notif, {Position = UDim2.new(0, 20, 1, 80), BackgroundTransparency = 1}, 0.5)
        tweenOut.Completed:Wait()
        notif:Destroy()
    end)
end

return setmetatable(Nebula, Nebula)
