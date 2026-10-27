--[[ Aphex Menu v4 — full customization + no global blur ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local Config = {
    accent      = Color3.fromRGB(255, 255, 255),
    accent2     = Color3.fromRGB(120, 180, 255), -- для градиента
    useGradient = false,
    bgColor     = Color3.fromRGB(15, 15, 15),
    panelColor  = Color3.fromRGB(22, 22, 22),
    strokeColor = Color3.fromRGB(45, 45, 45),
    textColor   = Color3.fromRGB(235, 235, 235),
    dimColor    = Color3.fromRGB(140, 140, 140),
    menuAlpha   = 0.05,   -- BackgroundTransparency главного фрейма
    panelAlpha  = 0.25,   -- прозрачность панелей
    radius      = 10,
    width       = 540,
    height      = 380,
    font        = Enum.Font.GothamMedium,
    fontBold    = Enum.Font.GothamBold,
    menuBind    = Enum.KeyCode.RightShift,
}
local State = {
    binds = {},
    conns = {},
    open = true,
    pages = {},
    currentPage = nil,
    accentRegistry = {},
    elements = {}, -- для пересборки кастома
}
local function track(c) table.insert(State.conns, c); return c end

-- ===== ЦВЕТА (алиас на Config) =====
local C = Config

local FONT = Config.font
local FONT_B = Config.fontBold

if pg:FindFirstChild("AphexMenu") then pg.AphexMenu:Destroy() end

-- ===== КОРЕНЬ =====
local gui = Instance.new("ScreenGui")
gui.Name = "AphexMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = pg

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(Config.width, Config.height)
main.Position = UDim2.new(0.5, -Config.width/2, 0.5, -Config.height/2)
main.BackgroundColor3 = C.bgColor
main.BackgroundTransparency = C.menuAlpha
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, C.radius); corner.Parent = main
local stroke = Instance.new("UIStroke"); stroke.Color = C.strokeColor; stroke.Thickness = 1; stroke.Transparency = 0.3; stroke.Parent = main

-- ===== GLASS СЛОИ (без глобального blur) =====
local glassGlow = Instance.new("Frame")
glassGlow.Size = UDim2.new(1, 0, 0.55, 0)
glassGlow.BackgroundColor3 = Color3.fromRGB(255,255,255)
glassGlow.BackgroundTransparency = 1
glassGlow.BorderSizePixel = 0
glassGlow.ZIndex = 0
glassGlow.Parent = main
do
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.35, 0.98),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = glassGlow
end

local glassBottom = Instance.new("Frame")
glassBottom.Size = UDim2.new(1, 0, 0.4, 0)
glassBottom.Position = UDim2.new(0, 0, 0.6, 0)
glassBottom.BackgroundColor3 = Color3.fromRGB(255,255,255)
glassBottom.BackgroundTransparency = 1
glassBottom.BorderSizePixel = 0
glassBottom.ZIndex = 0
glassBottom.Parent = main
do
    local g = Instance.new("UIGradient")
    g.Rotation = -90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.94),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = glassBottom
end

local innerGlow = Instance.new("UIStroke")
innerGlow.Color = Color3.fromRGB(255,255,255)
innerGlow.Thickness = 1
innerGlow.Transparency = 0.85
innerGlow.Parent = main

-- ===== ШАПКА =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 46)
titleBar.BackgroundColor3 = C.panelColor
titleBar.BackgroundTransparency = C.panelAlpha
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3
titleBar.Parent = main
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, C.radius); tc.Parent = titleBar
local tf = Instance.new("Frame")
tf.Size = UDim2.new(1, 0, 0, 10); tf.Position = UDim2.new(0, 0, 1, -10)
tf.BackgroundColor3 = C.panelColor; tf.BackgroundTransparency = C.panelAlpha; tf.BorderSizePixel = 0; tf.ZIndex = 3; tf.Parent = titleBar

local title = Instance.new("TextLabel")
title.Text = "APHEX"
title.Font = FONT_B
title.TextSize = 17
title.TextColor3 = C.accent
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 20, 0, 0)
title.Size = UDim2.new(0.5, 0, 1, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = titleBar

local menuBindLbl = Instance.new("TextLabel")
menuBindLbl.Text = "[" .. Config.menuBind.Name .. "]"
menuBindLbl.Font = FONT
menuBindLbl.TextSize = 11
menuBindLbl.TextColor3 = C.dimColor
menuBindLbl.BackgroundTransparency = 1
menuBindLbl.Position = UDim2.new(0, 96, 0, 0)
menuBindLbl.Size = UDim2.new(0, 120, 1, 0)
menuBindLbl.TextXAlignment = Enum.TextXAlignment.Left
menuBindLbl.ZIndex = 4
menuBindLbl.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"; closeBtn.Font = FONT_B; closeBtn.TextSize = 14
closeBtn.TextColor3 = C.dimColor; closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.fromOffset(46, 46)
closeBtn.Position = UDim2.new(1, -46, 0, 0)
closeBtn.ZIndex = 5; closeBtn.Parent = titleBar
track(closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.accent end))
track(closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = C.dimColor end))
track(closeBtn.MouseButton1Click:Connect(function() unload() end))

-- драг
local dragging, dragStart, startPos
track(titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))

-- ===== САЙДБАР =====
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 68, 1, -46)
sidebar.Position = UDim2.new(0, 0, 0, 46)
sidebar.BackgroundColor3 = C.panelColor
sidebar.BackgroundTransparency = 0.35
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = main

local sbList = Instance.new("UIListLayout")
sbList.Padding = UDim.new(0, 6)
sbList.HorizontalAlignment = Enum.HorizontalAlignment.Center
sbList.SortOrder = Enum.SortOrder.LayoutOrder
sbList.Parent = sidebar

local sbPad = Instance.new("UIPadding"); sbPad.PaddingTop = UDim.new(0, 10); sbPad.Parent = sidebar

local sbDivider = Instance.new("Frame")
sbDivider.Size = UDim2.new(0, 1, 1, -20); sbDivider.Position = UDim2.new(1, -1, 0, 10)
sbDivider.BackgroundColor3 = C.strokeColor; sbDivider.BackgroundTransparency = 0.6
sbDivider.BorderSizePixel = 0; sbDivider.ZIndex = 2; sbDivider.Parent = sidebar

-- ===== КОНТЕНТ =====
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -68, 1, -46)
contentHolder.Position = UDim2.new(0, 68, 0, 46)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 2
contentHolder.Parent = main

-- ===== РЕЕСТР АКЦЕНТА =====
local function regAccent(obj, prop)
    table.insert(State.accentRegistry, {obj = obj, prop = prop or "BackgroundColor3"})
end

local function applyAccent(color)
    Config.accent = color
    for _, e in ipairs(State.accentRegistry) do
        if e.obj and e.obj.Parent then
            if e.obj:IsA("UIStroke") or e.obj:IsA("TextLabel") or e.obj:IsA("TextButton") then
                e.obj[e.prop] = color
            else
                e.obj[e.prop] = color
            end
        end
    end
    title.TextColor3 = color
    for _, page in pairs(State.pages) do
        if page.tabBtn then page.tabBtn.TextColor3 = color end
    end
    if activeIndicator then activeIndicator.BackgroundColor3 = color end
    if gradientAccent then
        gradientAccent.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Config.accent2),
        })
    end
end

-- ===== ПЕРЕСОБОРКА ЦВЕТОВ (при смене темы) =====
local function rebuildColors()
    main.BackgroundColor3 = Config.bgColor
    main.BackgroundTransparency = Config.menuAlpha
    stroke.Color = Config.strokeColor
    titleBar.BackgroundColor3 = Config.panelColor
    titleBar.BackgroundTransparency = Config.panelAlpha
    tf.BackgroundColor3 = Config.panelColor
    tf.BackgroundTransparency = Config.panelAlpha
    sidebar.BackgroundColor3 = Config.panelColor
    sbDivider.BackgroundColor3 = Config.strokeColor
    title.TextColor3 = Config.accent
    menuBindLbl.TextColor3 = Config.dimColor
    closeBtn.TextColor3 = Config.dimColor
    -- перекрашиваем панели элементов
    for _, el in ipairs(State.elements) do
        if el.panel and el.panel.Parent then
            el.panel.BackgroundColor3 = Config.panelColor
            el.panel.BackgroundTransparency = Config.panelAlpha
        end
        if el.label and el.label.Parent then
            el.label.TextColor3 = Config.textColor
        end
    end
end

-- ===== СТРАНИЦЫ =====
local pages = State.pages
local currentPage = nil
local activeIndicator = nil
local gradientAccent = nil

local function createPage(name)
    local holder = Instance.new("Frame")
    holder.Name = "Page_" .. name
    holder.Size = UDim2.fromScale(1, 1)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.ZIndex = 2
    holder.Parent = contentHolder

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -20)
    scroll.Position = UDim2.new(0, 16, 0, 12)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Config.strokeColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 2
    scroll.Parent = holder
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll

    pages[name] = {holder = holder, content = scroll, tabBtn = nil}
    return scroll
end

local pageScroll = {}
pageScroll.General = createPage("General")
pageScroll.Player  = createPage("Player")
pageScroll.Binds   = createPage("Binds")
pageScroll.Misc    = createPage("Misc")
pageScroll.Custom  = createPage("Custom")

activeIndicator = Instance.new("Frame")
activeIndicator.Size = UDim2.new(0, 3, 0, 28)
activeIndicator.BackgroundColor3 = Config.accent
activeIndicator.BorderSizePixel = 0
activeIndicator.ZIndex = 3
activeIndicator.Parent = sidebar
local aiC = Instance.new("UICorner"); aiC.CornerRadius = UDim.new(1,0); aiC.Parent = activeIndicator

local function switchPage(name)
    for n, page in pairs(pages) do
        page.holder.Visible = (n == name)
    end
    currentPage = name
    local btn = pages[name] and pages[name].tabBtn
    if btn then
        TweenService:Create(activeIndicator, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y)
        }):Play()
    end
    for n, page in pairs(pages) do
        if page.tabBtn then
            page.tabBtn.TextColor3 = (n == name) and Config.accent or Config.dimColor
        end
    end
end

local icons = {General="G", Player="P", Binds="B", Misc="M", Custom="C"}
local order = {"General","Player","Binds","Misc","Custom"}
for i, name in ipairs(order) do
    local btn = Instance.new("TextButton")
    btn.Text = icons[name]; btn.Font = FONT_B; btn.TextSize = 16
    btn.TextColor3 = Config.dimColor
    btn.BackgroundColor3 = Config.panelColor
    btn.BackgroundTransparency = 0.4
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(44, 44); btn.LayoutOrder = i
    btn.ZIndex = 3; btn.Parent = sidebar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,8); bc.Parent = btn
    pages[name].tabBtn = btn
    track(btn.MouseEnter:Connect(function()
        if currentPage ~= name then TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.15}):Play() end
    end))
    track(btn.MouseLeave:Connect(function()
        if currentPage ~= name then TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.4}):Play() end
    end))
    track(btn.MouseButton1Click:Connect(function() switchPage(name) end))
end

-- ===== ХЕЛПЕРЫ =====
local function promptKey(callback)
    local overlay = Instance.new("TextLabel")
    overlay.Text = "Press any key...  (Esc = cancel)"
    overlay.Font = FONT_B; overlay.TextSize = 14
    overlay.TextColor3 = Config.accent
    overlay.BackgroundColor3 = Config.bgColor
    overlay.BackgroundTransparency = 0.05
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.fromOffset(280, 50)
    overlay.Position = UDim2.new(0.5, -140, 0.5, -25)
    overlay.ZIndex = 50; overlay.Parent = gui
    local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0,6); oc.Parent = overlay
    local os = Instance.new("UIStroke"); os.Color = Config.accent; os.Thickness = 1; os.Parent = overlay
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            conn:Disconnect(); overlay:Destroy()
            callback(input.KeyCode == Enum.KeyCode.Escape and nil or input.KeyCode)
        end
    end)
end

local function addToggle(parentScroll, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = Config.panelColor
    row.BackgroundTransparency = Config.panelAlpha
    row.BorderSizePixel = 0; row.Parent = parentScroll
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 13; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

    local bindLbl = Instance.new("TextButton")
    bindLbl.Text = "[None]"; bindLbl.Font = FONT; bindLbl.TextSize = 11; bindLbl.TextColor3 = Config.dimColor
    bindLbl.BackgroundTransparency = 1
    bindLbl.Position = UDim2.new(1, -130, 0, 0); bindLbl.Size = UDim2.new(0, 70, 1, 0)
    bindLbl.TextXAlignment = Enum.TextXAlignment.Right; bindLbl.Parent = row
    track(bindLbl.MouseEnter:Connect(function() bindLbl.TextColor3 = Config.accent end))
    track(bindLbl.MouseLeave:Connect(function() bindLbl.TextColor3 = Config.dimColor end))

    local state = default or false
    local knobBg = Instance.new("Frame")
    knobBg.Size = UDim2.fromOffset(34, 18)
    knobBg.Position = UDim2.new(1, -46, 0.5, -9)
    knobBg.BackgroundColor3 = state and Config.accent or Color3.fromRGB(60,60,60)
    knobBg.BorderSizePixel = 0; knobBg.Parent = row
    local kbc = Instance.new("UICorner"); kbc.CornerRadius = UDim.new(1,0); kbc.Parent = knobBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = state and Config.bgColor or Config.dimColor
    knob.BorderSizePixel = 0; knob.Parent = knobBg
    local knc = Instance.new("UICorner"); knc.CornerRadius = UDim.new(1,0); knc.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Text = ""; btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1, -90, 1, 0); btn.Parent = row

    local function setState(v)
        state = v
        TweenService:Create(knobBg, TweenInfo.new(0.12), {BackgroundColor3 = state and Config.accent or Color3.fromRGB(60,60,60)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = state and Config.bgColor or Config.dimColor
        }):Play()
        if callback then pcall(callback, state) end
    end
    track(btn.MouseButton1Click:Connect(function() setState(not state) end))
    track(bindLbl.MouseButton1Click:Connect(function()
        bindLbl.Text = "[...]"
        promptKey(function(key)
            if key then
                State.binds[text] = {key = key, cb = function() setState(not state) end}
                bindLbl.Text = "[" .. key.Name .. "]"
            else
                State.binds[text] = nil
                bindLbl.Text = "[None]"
            end
        end)
    end))

    table.insert(State.accentRegistry, {obj = knobBg, prop = "BackgroundColor3"})
    table.insert(State.elements, {panel = row, label = lbl})
    return row
end

local function addButton(parentScroll, text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text; btn.Font = FONT; btn.TextSize = 13; btn.TextColor3 = Config.textColor
    btn.BackgroundColor3 = Config.panelColor; btn.BackgroundTransparency = Config.panelAlpha
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, -6, 0, 38)
    btn.Parent = parentScroll
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = btn
    track(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play()
    end))
    track(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = Config.panelAlpha}):Play()
    end))
    track(btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end))
    table.insert(State.elements, {panel = btn, label = btn})
    return btn
end

local function addSlider(parentScroll, text, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 52)
    row.BackgroundColor3 = Config.panelColor; row.BackgroundTransparency = Config.panelAlpha
    row.BorderSizePixel = 0; row.Parent = parentScroll
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 13; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 6); lbl.Size = UDim2.new(0.7, 0, 0, 18)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(default); valLbl.Font = FONT; valLbl.TextSize = 12
    valLbl.TextColor3 = Config.accent; valLbl.BackgroundTransparency = 1
    valLbl.Position = UDim2.new(1, -60, 0, 6); valLbl.Size = UDim2.new(0, 48, 0, 18)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Parent = row
    regAccent(valLbl, "TextColor3")

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6); barBg.Position = UDim2.new(0, 12, 0, 36)
    barBg.BackgroundColor3 = Color3.fromRGB(60,60,60); barBg.BorderSizePixel = 0; barBg.Parent = row
    local bbc = Instance.new("UICorner"); bbc.CornerRadius = UDim.new(1,0); bbc.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Config.accent; fill.BorderSizePixel = 0; fill.Parent = barBg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    regAccent(fill)

    local btn = Instance.new("TextButton")
    btn.Text = ""; btn.BackgroundTransparency = 1; btn.Size = UDim2.fromScale(1,1); btn.Parent = barBg

    local function setVal(v)
        v = math.clamp(v, min, max)
        fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0)
        valLbl.Text = tostring(math.floor(v))
        if callback then pcall(callback, v) end
    end

    track(btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local function upd()
                local m = UserInputService:GetMouseLocation()
                local abs = barBg.AbsolutePosition
                local sz = barBg.AbsoluteSize
                local rel = (m.X - abs.X) / sz.X
                setVal(min + rel * (max - min))
            end
            upd()
            local conn
            conn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then upd() end
            end)
            track(conn)
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if conn then conn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
            track(endConn)
        end
    end))
    table.insert(State.elements, {panel = row, label = lbl})
    return {row = row, setVal = setVal}
end

local function addKeybind(parentScroll, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = Config.panelColor; row.BackgroundTransparency = Config.panelAlpha
    row.BorderSizePixel = 0; row.Parent = parentScroll
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 13; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local bindBtn = Instance.new("TextButton")
    bindBtn.Text = "[None]"; bindBtn.Font = FONT; bindBtn.TextSize = 11
    bindBtn.TextColor3 = Config.dimColor; bindBtn.BackgroundTransparency = 1
    bindBtn.Position = UDim2.new(1, -100, 0, 0); bindBtn.Size = UDim2.new(0, 90, 1, 0)
    bindBtn.TextXAlignment = Enum.TextXAlignment.Right; bindBtn.Parent = row
    track(bindBtn.MouseEnter:Connect(function() bindBtn.TextColor3 = Config.accent end))
    track(bindBtn.MouseLeave:Connect(function() bindBtn.TextColor3 = Config.dimColor end))
    track(bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text = "[...]"
        promptKey(function(key)
            if key then
                State.binds[text] = {key = key, cb = callback}
                bindBtn.Text = "[" .. key.Name .. "]"
            else
                State.binds[text] = nil
                bindBtn.Text = "[None]"
            end
        end)
    end))
    table.insert(State.elements, {panel = row, label = lbl})
    return row
end

local function addSection(parentScroll, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text:upper(); lbl.Font = FONT_B; lbl.TextSize = 10; lbl.TextColor3 = Config.dimColor
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -6, 0, 20)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = parentScroll
    table.insert(State.elements, {label = lbl})
    return lbl
end

-- ===== КАСТОМ-КОНТРОЛЫ =====
local function addColorPicker(parentScroll, label, default, callback)
    -- simple: preset-кнопки + RGB слайдеры
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 110)
    holder.BackgroundColor3 = Config.panelColor; holder.BackgroundTransparency = Config.panelAlpha
    holder.BorderSizePixel = 0; holder.Parent = parentScroll
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = holder
    table.insert(State.elements, {panel = holder})

    local lbl = Instance.new("TextLabel")
    lbl.Text = label; lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 6); lbl.Size = UDim2.new(0.6, 0, 0, 16)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = holder

    local preview = Instance.new("Frame")
    preview.Size = UDim2.fromOffset(24, 24); preview.Position = UDim2.new(1, -38, 0, 6)
    preview.BackgroundColor3 = default; preview.BorderSizePixel = 0; preview.Parent = holder
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,4); pc.Parent = preview

    local r, g, b = default.R * 255, default.G * 255, default.B * 255
    local labels = {"R", "G", "B"}
    local vals = {r, g, b}
    local fills = {}
    local valLabels = {}

    local function updateAll()
        local col = Color3.fromRGB(vals[1], vals[2], vals[3])
        preview.BackgroundColor3 = col
        if callback then pcall(callback, col) end
    end

    for i = 1, 3 do
        local y = 32 + (i-1) * 24
        local ch = Instance.new("TextLabel")
        ch.Text = labels[i]; ch.Font = FONT_B; ch.TextSize = 10; ch.TextColor3 = Config.dimColor
        ch.BackgroundTransparency = 1
        ch.Position = UDim2.new(0, 12, 0, y); ch.Size = UDim2.new(0, 14, 0, 18)
        ch.TextXAlignment = Enum.TextXAlignment.Left; ch.Parent = holder

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -90, 0, 6); barBg.Position = UDim2.new(0, 32, 0, y + 6)
        barBg.BackgroundColor3 = Color3.fromRGB(60,60,60); barBg.BorderSizePixel = 0; barBg.Parent = holder
        local bbc = Instance.new("UICorner"); bbc.CornerRadius = UDim.new(1,0); bbc.Parent = barBg

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(vals[i]/255, 0, 1, 0)
        fill.BackgroundColor3 = (i==1 and Color3.fromRGB(255,60,60)) or (i==2 and Color3.fromRGB(60,255,60)) or Color3.fromRGB(60,60,255)
        fill.BorderSizePixel = 0; fill.Parent = barBg
        local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
        fills[i] = fill

        local vl = Instance.new("TextLabel")
        vl.Text = tostring(vals[i]); vl.Font = FONT; vl.TextSize = 10; vl.TextColor3 = Config.textColor
        vl.BackgroundTransparency = 1
        vl.Position = UDim2.new(1, -54, 0, y); vl.Size = UDim2.new(0, 40, 0, 18)
        vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = holder
        valLabels[i] = vl

        local btn = Instance.new("TextButton")
        btn.Text = ""; btn.BackgroundTransparency = 1; btn.Size = UDim2.fromScale(1,1); btn.Parent = barBg

        track(btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local function upd()
                    local m = UserInputService:GetMouseLocation()
                    local abs = barBg.AbsolutePosition
                    local sz = barBg.AbsoluteSize
                    local rel = math.clamp((m.X - abs.X) / sz.X, 0, 1)
                    vals[i] = math.floor(rel * 255)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    vl.Text = tostring(vals[i])
                    updateAll()
                end
                upd()
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then upd() end
                end)
                track(conn)
                local endConn
                endConn = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        if conn then conn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
                track(endConn)
            end
        end))
    end
end

-- ===== СТРАНИЦЫ НАПОЛНЕНИЕ =====
do
    local s = pageScroll.General
    addSection(s, "Combat")
    addToggle(s, "Aimbot", false, function(v) print("aimbot:", v) end)
    addToggle(s, "Silent Aim", false, function(v) print("silent:", v) end)
    addSlider(s, "FOV", 10, 360, 90, function(v) print("fov:", v) end)
end

do
    local s = pageScroll.Player
    addSection(s, "Movement")
    addToggle(s, "Speed Hack", false, function(v) print("speed:", v) end)
    addSlider(s, "WalkSpeed", 16, 300, 16, function(v) print("ws:", v) end)
    addToggle(s, "Fly", false, function(v) print("fly:", v) end)
end

do
    local s = pageScroll.Binds
    addSection(s, "Global Binds")
    addKeybind(s, "Teleport Spawn", function() print("tp spawn") end)
    addKeybind(s, "Reset Character", function() print("reset") end)
    addKeybind(s, "Panic (unload)", function() unload() end)
end

do
    local s = pageScroll.Misc
    addSection(s, "Menu")
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = Config.panelColor; row.BackgroundTransparency = Config.panelAlpha
    row.BorderSizePixel = 0; row.Parent = s
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = "Toggle Menu Key"; lbl.Font = FONT; lbl.TextSize = 13; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local bindBtn = Instance.new("TextButton")
    bindBtn.Text = "[" .. Config.menuBind.Name .. "]"
    bindBtn.Font = FONT; bindBtn.TextSize = 11; bindBtn.TextColor3 = Config.accent
    bindBtn.BackgroundTransparency = 1
    bindBtn.Position = UDim2.new(1, -110, 0, 0); bindBtn.Size = UDim2.new(0, 100, 1, 0)
    bindBtn.TextXAlignment = Enum.TextXAlignment.Right; bindBtn.Parent = row
    regAccent(bindBtn, "TextColor3")
    track(bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text = "[...]"
        promptKey(function(key)
            if key then
                Config.menuBind = key
                bindBtn.Text = "[" .. key.Name .. "]"
                menuBindLbl.Text = "[" .. key.Name .. "]"
            else
                bindBtn.Text = "[" .. Config.menuBind.Name .. "]"
            end
        end)
    end))
    table.insert(State.elements, {panel = row, label = lbl})

    addSection(s, "Actions")
    addButton(s, "Reset Config", function() print("reset cfg") end)
    addButton(s, "Unload Script", function() unload() end)
end

-- ===== CUSTOM PAGE =====
do
    local s = pageScroll.Custom

    addSection(s, "Theme")
    -- пресеты фона
    local presets = {
        {name = "Dark",     bg = Color3.fromRGB(15,15,15),  panel = Color3.fromRGB(22,22,22),  stroke = Color3.fromRGB(45,45,45)},
        {name = "Midnight", bg = Color3.fromRGB(10,12,20),  panel = Color3.fromRGB(18,20,30),  stroke = Color3.fromRGB(40,45,60)},
        {name = "Carbon",   bg = Color3.fromRGB(20,20,20),  panel = Color3.fromRGB(30,30,30),  stroke = Color3.fromRGB(55,55,55)},
        {name = "Glass",    bg = Color3.fromRGB(40,45,55),  panel = Color3.fromRGB(60,65,75),  stroke = Color3.fromRGB(90,95,105)},
        {name = "Blood",    bg = Color3.fromRGB(20,8,8),    panel = Color3.fromRGB(30,12,12),  stroke = Color3.fromRGB(60,25,25)},
    }
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 46)
    row.BackgroundColor3 = Config.panelColor; row.BackgroundTransparency = Config.panelAlpha
    row.BorderSizePixel = 0; row.Parent = s
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(0, 8, 0, 8)
    holder.Size = UDim2.new(1, -16, 0, 30)
    holder.Parent = row
    local hl = Instance.new("UIListLayout")
    hl.FillDirection = Enum.FillDirection.Horizontal
    hl.Padding = UDim.new(0, 6); hl.VerticalAlignment = Enum.VerticalAlignment.Center
    hl.Parent = holder
    for _, t in ipairs(presets) do
        local b = Instance.new("TextButton")
        b.Text = t.name; b.Font = FONT; b.TextSize = 11; b.TextColor3 = Config.textColor
        b.BackgroundColor3 = t.bg; b.BorderSizePixel = 0; b.AutoButtonColor = false
        b.Size = UDim2.fromOffset(70, 28); b.Parent = holder
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = b
        local st = Instance.new("UIStroke"); st.Color = t.stroke; st.Thickness = 1; st.Parent = b
        track(b.MouseButton1Click:Connect(function()
            Config.bgColor = t.bg
            Config.panelColor = t.panel
            Config.strokeColor = t.stroke
            rebuildColors()
        end))
    end

    addSection(s, "Accent")
    addColorPicker(s, "Accent Color", Config.accent, function(col)
        applyAccent(col)
    end)

    addSection(s, "Menu Appearance")
    addSlider(s, "Menu Transparency", 0, 1, 1 - Config.menuAlpha, function(v)
        Config.menuAlpha = 1 - v
        main.BackgroundTransparency = Config.menuAlpha
    end)
    addSlider(s, "Panel Transparency", 0, 1, 1 - Config.panelAlpha, function(v)
        Config.panelAlpha = 1 - v
        rebuildColors()
    end)
    addSlider(s, "Corner Radius", 0, 24, Config.radius, function(v)
        Config.radius = math.floor(v)
        corner.CornerRadius = UDim.new(0, Config.radius)
        tc.CornerRadius = UDim.new(0, Config.radius)
    end)
    addSlider(s, "Width", 400, 800, Config.width, function(v)
        Config.width = math.floor(v)
        main.Size = UDim2.fromOffset(Config.width, Config.height)
        main.Position = UDim2.new(0.5, -Config.width/2, main.Position.Y.Scale, main.Position.Y.Offset)
    end)
    addSlider(s, "Height", 280, 700, Config.height, function(v)
        Config.height = math.floor(v)
        main.Size = UDim2.fromOffset(Config.width, Config.height)
        main.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, 0.5, -Config.height/2)
    end)
end

-- ===== МЕНЮ ВИДИМОСТЬ =====
local function setMenuVisible(visible)
    State.open = visible
    if visible then
        main.Visible = true
        main.Size = UDim2.fromOffset(Config.width, Config.height)
        main.BackgroundTransparency = Config.menuAlpha
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(Config.width, Config.height),
        }):Play()
    else
        local t = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(Config.width * 0.92, Config.height * 0.9),
            BackgroundTransparency = 1,
        })
        t:Play()
        t.Completed:Connect(function() if not State.open then main.Visible = false end end)
    end
end

-- ===== UNLOAD =====
function unload()
    for _, c in ipairs(State.conns) do pcall(function() c:Disconnect() end) end
    State.conns = {}
    local t = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(Config.width * 0.7, Config.height * 0.7),
        BackgroundTransparency = 1,
    })
    t:Play()
    t.Completed:Connect(function() gui:Destroy() end)
    task.delay(0.5, function() if gui and gui.Parent then gui:Destroy() end end)
end

-- ===== ГЛОБАЛЬНЫЕ БИНДЫ =====
track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == Config.menuBind then
        setMenuVisible(not State.open)
        return
    end
    for _, b in pairs(State.binds) do
        if b.key == input.KeyCode then pcall(b.cb) end
    end
end))

-- ===== СТАРТ =====
do
    local originalPos = main.Position
    main.Size = UDim2.fromOffset(Config.width * 0.92, Config.height * 0.9)
    main.BackgroundTransparency = 1
    main.Position = originalPos + UDim2.fromOffset(0, 12)
    switchPage("General")
    task.wait(0.05)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(Config.width, Config.height),
        BackgroundTransparency = Config.menuAlpha,
        Position = originalPos,
    }):Play()
end

applyAccent(Config.accent)