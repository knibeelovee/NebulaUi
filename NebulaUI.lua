-- NebulaUI ULTRA X 2.0 – BLACKOUT MODE
-- v2.0: 11 components, dark mode by default, auto layout & animated

local TweenService = game:GetService("TweenService")
local NebulaUI = {}
NebulaUI.Themes = {
    Dark = {
        Main = Color3.fromRGB(18, 18, 18),
        Section = Color3.fromRGB(24, 24, 24),
        Button = Color3.fromRGB(36, 36, 36),
        Hover = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(0, 255, 255),
        Border = Color3.fromRGB(80, 80, 80),
        Text = Color3.fromRGB(230, 230, 230),
        Toggle = Color3.fromRGB(0, 200, 200),
        Notification = Color3.fromRGB(0, 255, 120),
    }
}

function NebulaUI:CreateWindow(opts)
    opts = opts or {}
    local theme = self.Themes[opts.Theme] or opts.Theme or self.Themes.Dark
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = opts.Name or "NebulaUI"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, opts.Width or 600, 0, opts.Height or 400)
    Main.Position = opts.Position or UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = theme.Main
    Main.BorderColor3 = theme.Border

    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.BackgroundTransparency = 1
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1

    local tabList, currentTab = {}, nil

    function NebulaUI:AddTab(name)
        local idx = #tabList + 1
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.Position = UDim2.new(0, (idx-1)*100, 0, 0)
        btn.Text = name
        btn.BackgroundColor3 = theme.Section
        btn.TextColor3 = theme.Text
        table.insert(tabList, btn)

        local frame = Instance.new("ScrollingFrame", Content)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.CanvasSize = UDim2.new(0,0,2,0)
        frame.ScrollBarThickness = 4
        frame.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", frame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            if currentTab then currentTab.frame.Visible = false end
            frame.Visible = true
            currentTab = {btn=btn, frame=frame}
        end)

        frame.Visible = (#tabList == 1)
        currentTab = currentTab or {btn=btn, frame=frame}

        -- Add component factory
        local comp = {}

        function comp:Button(text, cb)
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.new(0, 200, 0, 30)
            b.BackgroundColor3 = theme.Button
            b.Text = text
            b.TextColor3 = theme.Text
            b.BorderColor3 = theme.Border
            b.AutoButtonColor = false
            b.ClipsDescendants = true

            b.MouseEnter:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = theme.Hover}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = theme.Button}):Play()
            end)
            b.MouseButton1Click:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = theme.Hover}):Play():Play()
                cb()
            end)
            return b
        end

        function comp:Toggle(text, def, cb)
            local f = Instance.new("Frame", frame); f.Size=UDim2.new(0,200,0,30); f.BackgroundTransparency=1
            local l = Instance.new("TextLabel", f); l.Text=text; l.Size=UDim2.new(0.7,0,1,0); l.TextColor3=theme.Text; l.BackgroundTransparency=1
            local b = Instance.new("TextButton", f); b.Size=UDim2.new(0,30,0,30); b.Position=UDim2.new(1,-30,0,0)
            b.BackgroundColor3 = def and theme.Toggle or theme.Button
            b.BorderColor3=theme.Border
            b.AutoButtonColor=false
            local v = def
            b.MouseButton1Click:Connect(function()
                v = not v
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = v and theme.Toggle or theme.Button}):Play()
                cb(v)
            end)
            return f
        end

        function comp:Slider(min, max, def, cb)
            local f = Instance.new("Frame", frame)
            f.Size = UDim2.new(0,200,0,40); f.BackgroundTransparency=1
            local l = Instance.new("TextLabel", f); l.Size=UDim2.new(1,0,0,20); l.TextColor3=theme.Text; l.BackgroundTransparency=1
            local b = Instance.new("TextButton", f); b.Position=UDim2.new(0,0,0,20); b.Size=UDim2.new(1,0,0,20)
            b.BackgroundColor3 = theme.Button; b.BorderColor3 = theme.Border; b.AutoButtonColor=false
            local fill = Instance.new("Frame", b); fill.Size=UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3=theme.Toggle
            fill.BorderSizePixel=0
            local dragging = false
            b.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true end
            end)
            b.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
            b.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local x = math.clamp((i.Position.X - b.AbsolutePosition.X)/b.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(x,0,1,0)
                    local val = min + (max-min)*x
                    l.Text = string.format("%s: %.2f", text or "Value", val)
                    cb(val)
                end
            end)
            l.Text = string.format("%s: %.2f", text or "Value", def)
            return f
        end

        function comp:Dropdown(opts, cb)
            local f = Instance.new("Frame", frame)
            f.Size=UDim2.new(0,200,0,30); f.BackgroundTransparency=1
            local selected = Instance.new("TextButton", f)
            selected.Size=UDim2.new(1,0,1,0); selected.TextColor3=theme.Text
            selected.BackgroundColor3 = theme.Button; selected.BorderColor3=theme.Border
            selected.Text = opts[1]
            local open = false
            local list
            selected.MouseButton1Click:Connect(function()
                if open then
                    list:Destroy(); open=false
                else
                    list=Instance.new("Frame", f); list.Size=UDim2.new(1,0,0,#opts*30); list.Position=UDim2.new(0,0,1,0)
                    list.BackgroundColor3 = theme.Section
                    for i,v in ipairs(opts) do
                        local it = Instance.new("TextButton", list)
                        it.Size=UDim2.new(1,0,0,30); it.Position=UDim2.new(0,0,(i-1)*30,0)
                        it.Text=v; it.TextColor3=theme.Text; it.BackgroundColor3=theme.Button; it.BorderColor3=theme.Border
                        it.MouseButton1Click:Connect(function()
                            selected.Text=v; cb(v); list:Destroy(); open=false
                        end)
                    end
                    open = true
                end
            end)
            return f
        end

        function comp:Input(placeholder, cb)
            local t = Instance.new("TextBox", frame)
            t.Size=UDim2.new(0,200,0,30)
            t.PlaceholderText = placeholder or ""
            t.BackgroundColor3 = theme.Button
            t.TextColor3 = theme.Text
            t.BorderColor3 = theme.Border
            t.FocusLost:Connect(function(enter)
                if enter then cb(t.Text) end
            end)
            return t
        end

        function comp:Keybind(key, cb)
            local f = Instance.new("TextButton", frame)
            f.Size=UDim2.new(0,200,0,30)
            f.Text = "Keybind ["..key.."]"
            f.BackgroundColor3 = theme.Button
            f.TextColor3 = theme.Text
            f.BorderColor3 = theme.Border
            local capturing = false
            f.MouseButton1Click:Connect(function() capturing = true; f.Text = "Press Key..."; end)
            game:GetService("UserInputService").InputBegan:Connect(function(i)
                if capturing and i.UserInputType==Enum.UserInputType.Keyboard then
                    key = i.KeyCode.Name
                    f.Text = "Keybind ["..key.."]"
                    capturing = false
                    cb(key)
                end
            end)
            return f
        end

        function comp:Label(txt)
            local l = Instance.new("TextLabel", frame)
            l.Size = UDim2.new(0,200,0,20); l.Text = txt
            l.TextColor3 = theme.Text; l.BackgroundTransparency = 1
            return l
        end

        function comp:Separator()
            local l = Instance.new("Frame", frame)
            l.Size = UDim2.new(0,200,0,2); l.BackgroundColor3 = theme.Border
            return l
        end

        function comp:ColorPicker(default, cb)
            local f = Instance.new("Frame", frame)
            f.Size=UDim2.new(0,200,0,30); f.BackgroundTransparency=1
            local btn = Instance.new("TextButton", f)
            btn.Size=UDim2.new(1,0,1,0); btn.Text="Pick Color"; btn.TextColor3=theme.Text
            btn.BackgroundColor3=default; btn.BorderColor3=theme.Border
            btn.MouseButton1Click:Connect(function()
                -- quick color rotate
                local col = Color3.fromHSV(tick()%5/5,1,1)
                btn.BackgroundColor3=col
                cb(col)
            end)
            return f
        end

        function comp:Notification(msg)
            local f = Instance.new("Frame", ScreenGui)
            f.Size=UDim2.new(0,200,0,50); f.Position=UDim2.new(0.5,-100,0,50)
            f.BackgroundColor3=theme.Notification; f.BorderColor3=theme.Border
            local l = Instance.new("TextLabel", f)
            l.Size=UDim2.new(1,0,1,0); l.Text = msg; l.TextColor3 = theme.Main; l.BackgroundTransparency = 1
            f:TweenPosition(UDim2.new(0.5,-100,0,10), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true, function()
                wait(2)
                f:TweenPosition(UDim2.new(0.5,-100,0,50), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function() f:Destroy() end)
            end)
        end

        return comp
    end

    return NebulaUI
end

return NebulaUI
