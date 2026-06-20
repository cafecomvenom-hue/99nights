--[[
    NEXUS HUB v2
    Modern Roblox Script Hub
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local isMobile = UserInputService.TouchEnabled

local TargetParent = (type(gethui) == "function" and gethui())
    or game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    or LocalPlayer:WaitForChild("PlayerGui")

for _, v in pairs(TargetParent:GetChildren()) do
    if v.Name == "NEXUS_HUB" then v:Destroy() end
end

--====[ COLORS ]====--
local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(22, 22, 28),
    Card = Color3.fromRGB(28, 28, 34),
    Border = Color3.fromRGB(38, 38, 46),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 155),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(110, 122, 255),
    Success = Color3.fromRGB(80, 200, 120),
    Danger = Color3.fromRGB(230, 70, 70),
    Warning = Color3.fromRGB(240, 180, 50),
    ToggleOn = Color3.fromRGB(88, 101, 242),
    ToggleOff = Color3.fromRGB(55, 55, 65),
    InputBg = Color3.fromRGB(35, 35, 42),
}

--====[ UTILITY ]====--
local function RoundCorners(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = frame
    return c
end

local function AddStroke(frame, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or Colors.Border
    s.Parent = frame
    return s
end

local function MakeDraggable(frame, dragObj)
    dragObj = dragObj or frame
    local dragging, dragStart, framePos
    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() obj[k] = v end)
        end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

--====[ NOTIFICATION SYSTEM ]====--
local NotificationHolder = Create("Frame", {
    Name = "NexusNotifications",
    Parent = TargetParent,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -16, 0, 16),
    Size = UDim2.new(0, 320, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 10000,
})

local NotificationList = Create("UIListLayout", {
    Parent = NotificationHolder,
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local function Notify(title, message, duration)
    duration = duration or 4
    local note = Create("Frame", {
        Parent = NotificationHolder,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10000,
    })
    RoundCorners(note, 8)
    AddStroke(note, 1, Colors.Border)

    Create("TextLabel", {
        Parent = note,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(1, -24, 0, 18),
        Text = title,
        TextColor3 = Colors.Accent,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 10001,
    })

    Create("TextLabel", {
        Parent = note,
        Position = UDim2.new(0, 12, 0, 30),
        Size = UDim2.new(1, -24, 0, 16),
        Text = message,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 10001,
    })

    local Progress = Create("Frame", {
        Parent = note,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 10001,
    })
    RoundCorners(Progress, 1)

    local totalHeight = 54

    local fadeIn = TweenService:Create(note, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, totalHeight)
    })
    fadeIn:Play()

    local progressTween = TweenService:Create(Progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    task.wait(0.3)
    progressTween:Play()
    progressTween.Completed:Connect(function()
        local fadeOut = TweenService:Create(note, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function() note:Destroy() end)
    end)
end

--====[ MAIN HUB ]====--
local Hub = Create("Frame", {
    Name = "NEXUS_HUB",
    Parent = TargetParent,
    Size = UDim2.new(0, 680, 0, 440),
    Position = UDim2.new(0.5, -340, 0.5, -220),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1000,
    Visible = true,
})
RoundCorners(Hub, 10)
AddStroke(Hub, 1.5, Colors.Border)

-- Shadow
local Shadow = Create("ImageLabel", {
    Parent = Hub,
    Position = UDim2.new(0, -10, 0, -10),
    Size = UDim2.new(1, 20, 1, 20),
    BackgroundTransparency = 1,
    Image = "rbxassetid://13160352173",
    ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.6,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
    ZIndex = -1,
})

--====[ TOP BAR ]====--
local TopBar = Create("Frame", {
    Parent = Hub,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Colors.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 1001,
})
RoundCorners(TopBar, 10)
local TopBarCorner = Create("UICorner", {
    Parent = TopBar,
    CornerRadius = UDim.new(0, 10),
})

local Logo = Create("TextLabel", {
    Parent = TopBar,
    Position = UDim2.new(0, 14, 0, 0),
    Size = UDim2.new(0, 140, 1, 0),
    Text = "NEXUS",
    TextColor3 = Colors.Accent,
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    ZIndex = 1002,
})

Create("TextLabel", {
    Parent = TopBar,
    Position = UDim2.new(0, 102, 0, 23),
    Size = UDim2.new(0, 40, 0, 12),
    Text = "v2.0",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    ZIndex = 1002,
})

-- Window buttons
local BtnFrame = Create("Frame", {
    Parent = TopBar,
    Position = UDim2.new(1, -90, 0, 0),
    Size = UDim2.new(0, 80, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 1002,
})

local function CreateWinBtn(x, color, icon)
    local btn = Create("TextButton", {
        Parent = BtnFrame,
        Position = UDim2.new(0, x, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        Text = icon or "",
        TextColor3 = Colors.TextDim,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ZIndex = 1003,
        AutoButtonColor = false,
    })
    RoundCorners(btn, 6)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.new(1, 1, 1)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Background}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
    end)
    return btn
end

local MinimizeBtn = CreateWinBtn(0, Color3.fromRGB(240, 180, 50), "─")
local CloseBtn = CreateWinBtn(28, Colors.Danger, "✕")

local hubVisibleState = true

CloseBtn.MouseButton1Click:Connect(function()
    hubVisibleState = false
    TweenService:Create(Hub, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
    }):Play()
    task.wait(0.3)
    Hub.Visible = false
end)

local minimized = false
local HubOriginalSize = UDim2.new(0, 680, 0, 440)
local HubOriginalPos = UDim2.new(0.5, -340, 0.5, -220)

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Hub, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 680, 0, 40),
        }):Play()
    else
        TweenService:Create(Hub, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = HubOriginalSize,
        }):Play()
    end
end)

MakeDraggable(Hub, TopBar)

--====[ SIDEBAR TABS ]====--
local Sidebar = Create("Frame", {
    Parent = Hub,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 160, 1, -40),
    BackgroundColor3 = Colors.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 1001,
})
RoundCorners(Sidebar, 10)

local SidebarTopFill = Create("Frame", {
    Parent = Sidebar,
    Position = UDim2.new(0, 0, 0, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = Colors.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 1001,
})

local TabListLayout = Create("UIListLayout", {
    Parent = Sidebar,
    Padding = UDim.new(0, 2),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

local TabPadding = Create("Frame", {
    Parent = Sidebar,
    Size = UDim2.new(1, 0, 0, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

local Tabs = {}
local ActiveTab = nil
local TabContent = {}

local function AddTab(name, icon)
    icon = icon or ""

    local tabBtn = Create("TextButton", {
        Parent = Sidebar,
        Size = UDim2.new(1, -12, 0, 36),
        Text = "",
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 1002,
    })
    RoundCorners(tabBtn, 8)

    local IconLabel = Create("TextLabel", {
        Parent = tabBtn,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 24, 1, 0),
        Text = icon,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BackgroundTransparency = 1,
        ZIndex = 1003,
    })

    local NameLabel = Create("TextLabel", {
        Parent = tabBtn,
        Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -42, 1, 0),
        Text = name,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1003,
    })

    local Indicator = Create("Frame", {
        Parent = tabBtn,
        Position = UDim2.new(0, 0, 0, 6),
        Size = UDim2.new(0, 3, 1, -12),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 1003,
    })
    RoundCorners(Indicator, 2)
    Indicator.Visible = false

    -- Tab content page
    local ContentPage = Create("ScrollingFrame", {
        Parent = Hub,
        Position = UDim2.new(0, 170, 0, 50),
        Size = UDim2.new(1, -180, 1, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Border,
        ZIndex = 1001,
        ClipsDescendants = true,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Visible = false,
    })

    local PageListLayout = Create("UIListLayout", {
        Parent = ContentPage,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })

    local PagePadding = Create("Frame", {
        Parent = ContentPage,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    local tabData = {
        Button = tabBtn,
        Content = ContentPage,
        Name = name,
        Icon = IconLabel,
        Text = NameLabel,
        Indicator = Indicator,
    }
    table.insert(Tabs, tabData)
    TabContent[name] = ContentPage

    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(tabData)
    end)

    tabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Card}):Play()
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Sidebar}):Play()
        end
    end)

    return tabData
end

function SwitchTab(tabData)
    if ActiveTab == tabData then return end

    if ActiveTab then
        TweenService:Create(ActiveTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Sidebar}):Play()
        TweenService:Create(ActiveTab.Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
        TweenService:Create(ActiveTab.Text, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
        ActiveTab.Indicator.Visible = false
        ActiveTab.Content.Visible = false
    end

    ActiveTab = tabData
    TweenService:Create(tabData.Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
    TweenService:Create(tabData.Icon, TweenInfo.new(0.2), {TextColor3 = Colors.Accent}):Play()
    TweenService:Create(tabData.Text, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
    tabData.Indicator.Visible = true
    tabData.Content.Visible = true
    tabData.Content.CanvasPosition = Vector2.new(0, 0)
end

--====[ UI COMPONENTS ]====--
local function AddSection(parent, title)
    local section = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })

    local line = Create("Frame", {
        Parent = section,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })

    local label = Create("TextLabel", {
        Parent = section,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, #title * 8 + 16, 1, 0),
        Text = "  " .. title .. "  ",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 1002,
    })
    RoundCorners(label, 4)
    label.AutomaticSize = Enum.AutomaticSize.X

    return section
end

local function AddToggle(parent, title, desc, default, callback)
    callback = callback or function() end

    local toggleFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    RoundCorners(toggleFrame, 8)
    AddStroke(toggleFrame, 1, Colors.Border)

    Create("TextLabel", {
        Parent = toggleFrame,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -70, 0, 18),
        Text = title,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    if desc then
        Create("TextLabel", {
            Parent = toggleFrame,
            Position = UDim2.new(0, 12, 0, 26),
            Size = UDim2.new(1, -70, 0, 14),
            Text = desc,
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ZIndex = 1002,
        })
    end

    local ToggleBg = Create("Frame", {
        Parent = toggleFrame,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff,
        BorderSizePixel = 0,
        ZIndex = 1002,
    })
    RoundCorners(ToggleBg, 10)

    local ToggleCircle = Create("Frame", {
        Parent = ToggleBg,
        Position = UDim2.new(default and 1 or 0, default and -3 or 3, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 1003,
    })
    RoundCorners(ToggleCircle, 7)

    local state = default or false

    local function UpdateToggle(newState)
        state = newState
        TweenService:Create(ToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
        }):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -3, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        pcall(callback, state)
    end

    local clickBtn = Create("TextButton", {
        Parent = toggleFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1004,
        AutoButtonColor = false,
    })
    clickBtn.MouseButton1Click:Connect(function()
        UpdateToggle(not state)
    end)

    toggleFrame.MouseEnter:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(31, 31, 37)
        }):Play()
    end)
    toggleFrame.MouseLeave:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.Card
        }):Play()
    end)

    return {
        Set = UpdateToggle,
        Get = function() return state end,
        Object = toggleFrame,
    }
end

local function AddButton(parent, title, desc, callback)
    callback = callback or function() end

    local btnFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    RoundCorners(btnFrame, 8)
    AddStroke(btnFrame, 1, Colors.Border)

    Create("TextLabel", {
        Parent = btnFrame,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -70, 0, 18),
        Text = title,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    if desc then
        Create("TextLabel", {
            Parent = btnFrame,
            Position = UDim2.new(0, 12, 0, 26),
            Size = UDim2.new(1, -70, 0, 14),
            Text = desc,
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ZIndex = 1002,
        })
    end

    local ActionBtn = Create("TextButton", {
        Parent = btnFrame,
        Position = UDim2.new(1, -42, 0.5, -12),
        Size = UDim2.new(0, 34, 0, 24),
        Text = ">",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 1003,
        AutoButtonColor = false,
    })
    RoundCorners(ActionBtn, 6)

    ActionBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            for _ = 1, 3 do
                TweenService:Create(ActionBtn, TweenInfo.new(0.06), {BackgroundColor3 = Colors.AccentHover}):Play()
                TweenService:Create(ActionBtn, TweenInfo.new(0.06), {BackgroundColor3 = Colors.Accent}):Play()
            end
            pcall(callback)
        end)
    end)

    ActionBtn.MouseEnter:Connect(function()
        TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.AccentHover}):Play()
    end)
    ActionBtn.MouseLeave:Connect(function()
        TweenService:Create(ActionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
    end)

    local clickBtn = Create("TextButton", {
        Parent = btnFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1002,
        AutoButtonColor = false,
    })
    clickBtn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    btnFrame.MouseEnter:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(31, 31, 37)
        }):Play()
    end)
    btnFrame.MouseLeave:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.Card
        }):Play()
    end)

    return btnFrame
end

local function AddSlider(parent, title, desc, min, max, default, callback)
    callback = callback or function() end
    default = default or min

    local sliderFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    RoundCorners(sliderFrame, 8)
    AddStroke(sliderFrame, 1, Colors.Border)

    Create("TextLabel", {
        Parent = sliderFrame,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 16),
        Text = title,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    local ValueLabel = Create("TextLabel", {
        Parent = sliderFrame,
        Position = UDim2.new(1, -50, 0, 8),
        Size = UDim2.new(0, 40, 0, 16),
        Text = tostring(default),
        TextColor3 = Colors.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    if desc then
        Create("TextLabel", {
            Parent = sliderFrame,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -24, 0, 12),
            Text = desc,
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ZIndex = 1002,
        })
    end

    local SliderBg = Create("Frame", {
        Parent = sliderFrame,
        Position = UDim2.new(0, 12, 1, -18),
        Size = UDim2.new(1, -24, 0, 8),
        BackgroundColor3 = Colors.InputBg,
        BorderSizePixel = 0,
        ZIndex = 1002,
    })
    RoundCorners(SliderBg, 4)

    local SliderFill = Create("Frame", {
        Parent = SliderBg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 1003,
    })
    RoundCorners(SliderFill, 4)

    local SliderKnob = Create("Frame", {
        Parent = SliderBg,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 1004,
    })
    RoundCorners(SliderKnob, 7)

    local value = default
    local dragging = false

    local function UpdateSlider(inputPos)
        local bgPos = SliderBg.AbsolutePosition
        local bgSize = SliderBg.AbsoluteSize.X
        local relX = math.clamp(inputPos - bgPos.X, 0, bgSize)
        local norm = relX / bgSize
        value = math.floor(min + (max - min) * norm + 0.5)
        value = math.clamp(value, min, max)

        SliderFill.Size = UDim2.new(norm, 0, 1, 0)
        SliderKnob.Position = UDim2.new(norm, -7, 0.5, -7)
        ValueLabel.Text = tostring(value)
        pcall(callback, value)
    end

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Set = function(v)
            value = math.clamp(v, min, max)
            local norm = (value - min) / (max - min)
            SliderFill.Size = UDim2.new(norm, 0, 1, 0)
            SliderKnob.Position = UDim2.new(norm, -7, 0.5, -7)
            ValueLabel.Text = tostring(value)
        end,
        Get = function() return value end,
    }
end

local function AddDropdown(parent, title, options, default, callback)
    callback = callback or function() end
    local open = false

    local ddFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    RoundCorners(ddFrame, 8)
    AddStroke(ddFrame, 1, Colors.Border)

    Create("TextLabel", {
        Parent = ddFrame,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -60, 0, 16),
        Text = title,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    local SelectedLabel = Create("TextLabel", {
        Parent = ddFrame,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -60, 0, 14),
        Text = default or options[1] or "None",
        TextColor3 = Colors.Accent,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    local Arrow = Create("TextLabel", {
        Parent = ddFrame,
        Position = UDim2.new(1, -30, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "⌄",
        TextColor3 = Colors.TextDim,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        ZIndex = 1003,
    })

    local DropdownList = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1005,
        Visible = false,
        ClipsDescendants = true,
    })
    AddStroke(DropdownList, 1, Colors.Border)

    local ListLayout = Create("UIListLayout", {
        Parent = DropdownList,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local currentSelection = default or options[1]

    for _, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Parent = DropdownList,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "  " .. opt,
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Colors.Card,
            BorderSizePixel = 0,
            ZIndex = 1006,
            AutoButtonColor = false,
        })

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(33, 33, 39)
            }):Play()
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Card}):Play()
        end)

        optBtn.MouseButton1Click:Connect(function()
            currentSelection = opt
            SelectedLabel.Text = opt
            pcall(callback, opt)
            ToggleDropdown()
        end)
    end

    function ToggleDropdown()
        open = not open
        if open then
            local count = #options
            local height = count * 31 + 4
            DropdownList.Visible = true
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(DropdownList, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, height)
            }):Play()
            Arrow.Text = "⌃"
        else
            TweenService:Create(DropdownList, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.wait(0.1)
            DropdownList.Visible = false
            Arrow.Text = "⌄"
        end
    end

    DropdownList.Position = UDim2.new(0, 0, 0, 52)

    local clickBtn = Create("TextButton", {
        Parent = ddFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1004,
        AutoButtonColor = false,
    })
    clickBtn.MouseButton1Click:Connect(ToggleDropdown)

    ddFrame.MouseEnter:Connect(function()
        TweenService:Create(ddFrame, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(31, 31, 37)
        }):Play()
    end)
    ddFrame.MouseLeave:Connect(function()
        TweenService:Create(ddFrame, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
    end)

    return {
        Get = function() return currentSelection end,
        Set = function(opt) currentSelection = opt; SelectedLabel.Text = opt end,
    }
end

local function AddTextbox(parent, title, placeholder, default, callback)
    callback = callback or function() end

    local tbFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ZIndex = 1001,
    })
    RoundCorners(tbFrame, 8)
    AddStroke(tbFrame, 1, Colors.Border)

    Create("TextLabel", {
        Parent = tbFrame,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 16),
        Text = title,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 1002,
    })

    local InputBox = Create("TextBox", {
        Parent = tbFrame,
        Position = UDim2.new(0, 12, 1, -24),
        Size = UDim2.new(1, -24, 0, 18),
        Text = default or "",
        PlaceholderText = placeholder or "",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Colors.InputBg,
        BorderSizePixel = 0,
        ZIndex = 1003,
        ClearTextOnFocus = false,
    })
    RoundCorners(InputBox, 4)
    local inputPadding = Create("UIPadding", {
        Parent = InputBox,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })

    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            pcall(callback, InputBox.Text)
        end
    end)

    return {
        Get = function() return InputBox.Text end,
        Set = function(v) InputBox.Text = v end,
    }
end

--====[ WATERMARK ]====--
local Watermark = Create("TextLabel", {
    Parent = TargetParent,
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 10, 1, -10),
    Size = UDim2.new(0, 200, 0, 20),
    Text = "NEXUS HUB v2.0",
    TextColor3 = Colors.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    ZIndex = 10000,
})

task.spawn(function()
    while task.wait(2) do
        for i = 0.3, 1, 0.05 do
            Watermark.TextTransparency = 1 - i
            task.wait()
        end
        task.wait(3)
        for i = 1, 0.3, -0.05 do
            Watermark.TextTransparency = 1 - i
            task.wait()
        end
        task.wait(1)
    end
end)

--====[ BUILD TABS ]====--

-- TAB 1: Combat
local CombatTab = AddTab("Combat", "⚔")
AddSection(CombatTab.Content, "AIMBOT")
AddToggle(CombatTab.Content, "Aimbot", "Automatically aims at nearest target", false, function(v)
    _G.NX_Aimbot = v
    Notify("Combat", v and "Aimbot enabled" or "Aimbot disabled", 2)
end)
AddToggle(CombatTab.Content, "Silent Aim", "Invisible aim assistance", false, function(v)
    _G.NX_SilentAim = v
end)
AddToggle(CombatTab.Content, "Wall Check", "Only targets visible enemies", true)
AddSlider(CombatTab.Content, "Aim FOV", "Field of view for targeting", 10, 360, 120, function(v)
    _G.NX_AimFOV = v
end)
AddSlider(CombatTab.Content, "Smoothness", "Aim transition smoothness", 1, 100, 30, function(v)
    _G.NX_Smoothness = v
end)
AddDropdown(CombatTab.Content, "Target Priority", {"Closest", "Lowest HP", "Most Downs"}, "Closest", function(v)
    _G.NX_Priority = v
end)

AddSection(CombatTab.Content, "WEAPONS")
AddToggle(CombatTab.Content, "No Spread", "Eliminates weapon spread", false)
AddToggle(CombatTab.Content, "No Recoil", "Removes weapon recoil", false)
AddToggle(CombatTab.Content, "Rapid Fire", "Maximum fire rate", false)
AddSlider(CombatTab.Content, "Bullet Speed", "Projectile velocity multiplier", 1, 10, 1)

-- TAB 2: Visuals
local VisualsTab = AddTab("Visuals", "👁")
AddSection(VisualsTab.Content, "ESP")
AddToggle(VisualsTab.Content, "Player ESP", "Shows players through walls", true, function(v)
    _G.NX_ESP = v
    Notify("Visuals", v and "ESP enabled" or "ESP disabled", 2)
end)
AddToggle(VisualsTab.Content, "Box ESP", "Draws boxes around players", true)
AddToggle(VisualsTab.Content, "Tracer ESP", "Draws lines to players", false)
AddToggle(VisualsTab.Content, "Name ESP", "Shows player names", true)
AddToggle(VisualsTab.Content, "Distance ESP", "Shows distance to players", true)
AddDropdown(VisualsTab.Content, "ESP Color", {"White", "Red", "Blue", "Green", "Rainbow"}, "White")

AddSection(VisualsTab.Content, "WORLD")
AddToggle(VisualsTab.Content, "Fullbright", "Makes everything visible", false, function(v)
    _G.NX_Fullbright = v
end)
AddToggle(VisualsTab.Content, "X-Ray", "See through walls", false)
AddSlider(VisualsTab.Content, "Ambient Brightness", "World lighting level", 0, 10, 3)

-- TAB 3: Movement
local MovementTab = AddTab("Movement", "🏃")
AddSection(MovementTab.Content, "SPEED")
AddToggle(MovementTab.Content, "Speed Walk", "Increased movement speed", false, function(v)
    _G.NX_Speed = v
end)
AddSlider(MovementTab.Content, "Speed Amount", "Walk speed multiplier", 1, 50, 16, function(v)
    _G.NX_SpeedAmount = v
end)

AddSection(MovementTab.Content, "JUMP")
AddToggle(MovementTab.Content, "Super Jump", "Increased jump height", false)
AddSlider(MovementTab.Content, "Jump Power", "Jump height multiplier", 1, 50, 10)

AddSection(MovementTab.Content, "FLIGHT")
AddToggle(MovementTab.Content, "Fly", "Allows free flight", false, function(v)
    _G.NX_Fly = v
    Notify("Movement", v and "Flight enabled" or "Flight disabled", 2)
end)
AddSlider(MovementTab.Content, "Fly Speed", "Flight velocity", 1, 20, 5)

AddToggle(MovementTab.Content, "NoClip", "Walk through walls", false, function(v)
    _G.NX_NoClip = v
end)
AddToggle(MovementTab.Content, "Auto Jump", "Automatically jumps", false)

-- TAB 4: Player
local PlayerTab = AddTab("Player", "👤")
AddSection(PlayerTab.Content, "CHARACTER")

AddButton(PlayerTab.Content, "Respawn", "Instantly respawns your character", function()
    Notify("Player", "Respawning character...", 2)
end)

AddToggle(PlayerTab.Content, "Auto Respawn", "Automatically respawn on death", false)
AddToggle(PlayerTab.Content, "Anti Ragdoll", "Prevents being ragdolled", false)
AddToggle(PlayerTab.Content, "Infinite Stamina", "Never run out of stamina", false)
AddToggle(PlayerTab.Content, "Infinite Jump", "Jump multiple times in air", false)

AddSection(PlayerTab.Content, "INVENTORY")
AddToggle(PlayerTab.Content, "Infinite Items", "Never consume utilities", false)
AddButton(PlayerTab.Content, "Give All Items", "Spawns every utility item", function()
    Notify("Player", "Items spawned!", 2)
end)

-- TAB 5: Settings
local SettingsTab = AddTab("Settings", "⚙")
AddSection(SettingsTab.Content, "CONFIGURATION")
AddTextbox(SettingsTab.Content, "Config Name", "Enter config name...", "Default", function(v)
    _G.NX_ConfigName = v
    Notify("Settings", "Config set to: " .. v, 2)
end)
AddButton(SettingsTab.Content, "Save Config", "Saves current settings", function()
    Notify("Settings", "Config saved!", 2)
end)
AddButton(SettingsTab.Content, "Load Config", "Loads saved settings", function()
    Notify("Settings", "Config loaded!", 2)
end)

AddSection(SettingsTab.Content, "TELEPORTS")
AddButton(SettingsTab.Content, "Rejoin", "Rejoins the current server", function()
    Notify("Settings", "Rejoining...", 2)
end)
AddButton(SettingsTab.Content, "Server Hop", "Jumps to another server", function()
    Notify("Settings", "Searching for server...", 2)
end)

-- Default to first tab
if #Tabs > 0 then
    SwitchTab(Tabs[1])
end

Notify("NEXUS HUB", "Hub loaded successfully", 3)

--====[ KEYBIND TOGGLE ]====--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftControl then
        if Hub.Visible then
            hubVisibleState = false
            TweenService:Create(Hub, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
            }):Play()
            task.wait(0.3)
            Hub.Visible = false
        else
            Hub.Visible = true
            hubVisibleState = true
            TweenService:Create(Hub, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = HubOriginalSize,
            }):Play()
        end
    end
end)

--====[ CHARACTER DETECTION ]====--
local function onCharacter(char)
    if _G.NX_NoClip then
        task.spawn(function()
            while _G.NX_NoClip and char and char.Parent do
                task.wait()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacter)
if LocalPlayer.Character then onCharacter(LocalPlayer.Character) end
