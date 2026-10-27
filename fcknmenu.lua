--[[ AphexLib v4 + Linoria-compat shim
     Залить как: Dirfiks3/rbmenu/main/fcknmenu.lua
     В скрипте: заменить загрузку Linoria на loadstring(этот файл), удалить ThemeManager/SaveManager в конце. ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local Config = {
    accent      = Color3.fromRGB(255, 255, 255),
    accent2     = Color3.fromRGB(120, 180, 255),
    bgColor     = Color3.fromRGB(15, 15, 15),
    panelColor  = Color3.fromRGB(22, 22, 22),
    strokeColor = Color3.fromRGB(45, 45, 45),
    textColor   = Color3.fromRGB(235, 235, 235),
    dimColor    = Color3.fromRGB(140, 140, 140),
    menuAlpha   = 0.05,
    panelAlpha  = 0.25,
    radius      = 10,
    width       = 560,
    height      = 400,
    font        = Enum.Font.GothamMedium,
    fontBold    = Enum.Font.GothamBold,
    menuBind    = Enum.KeyCode.RightShift,
}
local State = {
    binds = {}, conns = {}, open = true, pages = {},
    currentPage = nil, accentRegistry = {}, elements = {},
    options = {}, toggles = {}, keybindFrame = {Visible = true},
    watermarkObj = nil, unloaded = false,
}
local function track(c) table.insert(State.conns, c); return c end
local C = Config
local FONT, FONT_B = Config.font, Config.fontBold

if pg:FindFirstChild("AphexMenu") then pg.AphexMenu:Destroy() end

-- ===== КОРЕНЬ =====
local gui = Instance.new("ScreenGui")
gui.Name = "AphexMenu"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.DisplayOrder = 999; gui.Parent = pg

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(Config.width, Config.height)
main.Position = UDim2.new(0.5, -Config.width/2, 0.5, -Config.height/2)
main.BackgroundColor3 = C.bgColor; main.BackgroundTransparency = C.menuAlpha
main.BorderSizePixel = 0; main.Active = true; main.ClipsDescendants = true; main.Parent = gui

local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, C.radius); corner.Parent = main
local stroke = Instance.new("UIStroke"); stroke.Color = C.strokeColor; stroke.Thickness = 1; stroke.Transparency = 0.3; stroke.Parent = main

local glassGlow = Instance.new("Frame")
glassGlow.Size = UDim2.new(1, 0, 0.55, 0); glassGlow.BackgroundColor3 = Color3.fromRGB(255,255,255)
glassGlow.BackgroundTransparency = 1; glassGlow.BorderSizePixel = 0; glassGlow.ZIndex = 0; glassGlow.Parent = main
do local g = Instance.new("UIGradient"); g.Rotation = 90
   g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.92),NumberSequenceKeypoint.new(0.35,0.98),NumberSequenceKeypoint.new(1,1)})
   g.Parent = glassGlow end
local innerGlow = Instance.new("UIStroke"); innerGlow.Color = Color3.fromRGB(255,255,255)
innerGlow.Thickness = 1; innerGlow.Transparency = 0.85; innerGlow.Parent = main

-- ===== ШАПКА =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 46); titleBar.BackgroundColor3 = C.panelColor
titleBar.BackgroundTransparency = C.panelAlpha; titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3; titleBar.Parent = main
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, C.radius); tc.Parent = titleBar
local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, 0, 0, 10); tf.Position = UDim2.new(0, 0, 1, -10)
tf.BackgroundColor3 = C.panelColor; tf.BackgroundTransparency = C.panelAlpha; tf.BorderSizePixel = 0; tf.ZIndex = 3; tf.Parent = titleBar

local title = Instance.new("TextLabel")
title.Text = "APHEX"; title.Font = FONT_B; title.TextSize = 17; title.TextColor3 = C.accent
title.BackgroundTransparency = 1; title.Position = UDim2.new(0, 20, 0, 0); title.Size = UDim2.new(0.5, 0, 1, 0)
title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 4; title.Parent = titleBar

local menuBindLbl = Instance.new("TextLabel")
menuBindLbl.Text = "[" .. Config.menuBind.Name .. "]"
menuBindLbl.Font = FONT; menuBindLbl.TextSize = 11; menuBindLbl.TextColor3 = C.dimColor
menuBindLbl.BackgroundTransparency = 1; menuBindLbl.Position = UDim2.new(0, 96, 0, 0)
menuBindLbl.Size = UDim2.new(0, 120, 1, 0); menuBindLbl.TextXAlignment = Enum.TextXAlignment.Left
menuBindLbl.ZIndex = 4; menuBindLbl.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"; closeBtn.Font = FONT_B; closeBtn.TextSize = 14; closeBtn.TextColor3 = C.dimColor
closeBtn.BackgroundTransparency = 1; closeBtn.Size = UDim2.fromOffset(46, 46)
closeBtn.Position = UDim2.new(1, -46, 0, 0); closeBtn.ZIndex = 5; closeBtn.Parent = titleBar
track(closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.accent end))
track(closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = C.dimColor end))
track(closeBtn.MouseButton1Click:Connect(function() if Library and Library.Unload then Library:Unload() end end))

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
sidebar.Size = UDim2.new(0, 68, 1, -46); sidebar.Position = UDim2.new(0, 0, 0, 46)
sidebar.BackgroundColor3 = C.panelColor; sidebar.BackgroundTransparency = 0.35
sidebar.BorderSizePixel = 0; sidebar.ZIndex = 2; sidebar.Parent = main
local sbList = Instance.new("UIListLayout"); sbList.Padding = UDim.new(0, 6)
sbList.HorizontalAlignment = Enum.HorizontalAlignment.Center; sbList.SortOrder = Enum.SortOrder.LayoutOrder; sbList.Parent = sidebar
local sbPad = Instance.new("UIPadding"); sbPad.PaddingTop = UDim.new(0, 10); sbPad.Parent = sidebar
local sbDivider = Instance.new("Frame"); sbDivider.Size = UDim2.new(0, 1, 1, -20); sbDivider.Position = UDim2.new(1, -1, 0, 10)
sbDivider.BackgroundColor3 = C.strokeColor; sbDivider.BackgroundTransparency = 0.6; sbDivider.BorderSizePixel = 0
sbDivider.ZIndex = 2; sbDivider.Parent = sidebar

-- ===== КОНТЕНТ =====
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -68, 1, -46); contentHolder.Position = UDim2.new(0, 68, 0, 46)
contentHolder.BackgroundTransparency = 1; contentHolder.ZIndex = 2; contentHolder.Parent = main

-- ===== АКЦЕНТ =====
local function regAccent(obj, prop) table.insert(State.accentRegistry, {obj = obj, prop = prop or "BackgroundColor3"}) end
local function applyAccent(color)
    Config.accent = color
    for _, e in ipairs(State.accentRegistry) do
        if e.obj and e.obj.Parent then e.obj[e.prop] = color end
    end
    title.TextColor3 = color
    for _, page in pairs(State.pages) do if page.tabBtn then page.tabBtn.TextColor3 = color end end
    if activeIndicator then activeIndicator.BackgroundColor3 = color end
end

-- ===== ХЕЛПЕРЫ ЭЛЕМЕНТОВ =====
local function promptKey(callback)
    local overlay = Instance.new("TextLabel")
    overlay.Text = "Press any key...  (Esc = cancel)"; overlay.Font = FONT_B; overlay.TextSize = 14
    overlay.TextColor3 = Config.accent; overlay.BackgroundColor3 = Config.bgColor
    overlay.BackgroundTransparency = 0.05; overlay.BorderSizePixel = 0
    overlay.Size = UDim2.fromOffset(280, 50); overlay.Position = UDim2.new(0.5, -140, 0.5, -25)
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

local function makeToggle(parent, id, opts)
    opts = opts or {}
    local text = opts.Text or id
    local state = opts.Default or false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38); row.BackgroundColor3 = Config.panelColor
    row.BackgroundTransparency = Config.panelAlpha; row.BorderSizePixel = 0; row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local bindLbl = Instance.new("TextButton")
    bindLbl.Text = "[None]"; bindLbl.Font = FONT; bindLbl.TextSize = 10; bindLbl.TextColor3 = Config.dimColor
    bindLbl.BackgroundTransparency = 1; bindLbl.Position = UDim2.new(1, -130, 0, 0); bindLbl.Size = UDim2.new(0, 70, 1, 0)
    bindLbl.TextXAlignment = Enum.TextXAlignment.Right; bindLbl.Parent = row
    track(bindLbl.MouseEnter:Connect(function() bindLbl.TextColor3 = Config.accent end))
    track(bindLbl.MouseLeave:Connect(function() bindLbl.TextColor3 = Config.dimColor end))
    local knobBg = Instance.new("Frame")
    knobBg.Size = UDim2.fromOffset(34, 18); knobBg.Position = UDim2.new(1, -46, 0.5, -9)
    knobBg.BackgroundColor3 = state and Config.accent or Color3.fromRGB(60,60,60)
    knobBg.BorderSizePixel = 0; knobBg.Parent = row
    local kbc = Instance.new("UICorner"); kbc.CornerRadius = UDim.new(1,0); kbc.Parent = knobBg
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = state and Config.bgColor or Config.dimColor
    knob.BorderSizePixel = 0; knob.Parent = knobBg
    local knc = Instance.new("UICorner"); knc.CornerRadius = UDim.new(1,0); knc.Parent = knob
    local btn = Instance.new("TextButton"); btn.Text = ""; btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, -90, 1, 0); btn.Parent = row

    local function setState(v)
        state = v
        TweenService:Create(knobBg, TweenInfo.new(0.12), {BackgroundColor3 = state and Config.accent or Color3.fromRGB(60,60,60)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = state and Config.bgColor or Config.dimColor
        }):Play()
        State.options[id] = {Value = state, Type = "Toggle"}
        if opts.Callback then pcall(opts.Callback, state) end
    end
    State.options[id] = {Value = state, Type = "Toggle"}
    track(btn.MouseButton1Click:Connect(function() setState(not state) end))

    local toggleObj = {}
    function toggleObj:SetValue(v) setState(v) end
    function toggleObj:GetValue() return state end
    function toggleObj:AddKeyPicker(kpId, kpOpts)
        kpOpts = kpOpts or {}
        local defKey = kpOpts.Default or ""
        State.options[kpId] = {Value = defKey, Type = "KeyPicker", Mode = kpOpts.Mode or "Toggle", SyncToggleState = kpOpts.SyncToggleState}
        if not kpOpts.NoUI then bindLbl.Text = defKey ~= "" and ("["..defKey.."]") or "[None]" end
        track(bindLbl.MouseButton1Click:Connect(function()
            if kpOpts.NoUI then return end
            bindLbl.Text = "[...]"
            promptKey(function(key)
                if key then
                    State.options[kpId].Value = key.Name
                    bindLbl.Text = "[" .. key.Name .. "]"
                else
                    State.options[kpId].Value = ""
                    bindLbl.Text = "[None]"
                end
            end)
        end))
        State.binds[kpId] = {get = function() return State.options[kpId].Value end, mode = kpOpts.Mode, toggle = toggleObj, sync = kpOpts.SyncToggleState}
        return toggleObj
    end
    State.toggles[id] = toggleObj
    return toggleObj
end

local function makeSlider(parent, id, opts)
    opts = opts or {}
    local text = opts.Text or id
    local min, max = opts.Min or 0, opts.Max or 100
    local def = opts.Default or min
    local rounding = opts.Rounding or 0
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 52); row.BackgroundColor3 = Config.panelColor
    row.BackgroundTransparency = Config.panelAlpha; row.BorderSizePixel = 0; row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = string.format(text, def); lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 6); lbl.Size = UDim2.new(0.7, 0, 0, 18)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(def); valLbl.Font = FONT; valLbl.TextSize = 11; valLbl.TextColor3 = Config.accent
    valLbl.BackgroundTransparency = 1; valLbl.Position = UDim2.new(1, -60, 0, 6); valLbl.Size = UDim2.new(0, 48, 0, 18)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Parent = row; regAccent(valLbl, "TextColor3")
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6); barBg.Position = UDim2.new(0, 12, 0, 36)
    barBg.BackgroundColor3 = Color3.fromRGB(60,60,60); barBg.BorderSizePixel = 0; barBg.Parent = row
    local bbc = Instance.new("UICorner"); bbc.CornerRadius = UDim.new(1,0); bbc.Parent = barBg
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Config.accent; fill.BorderSizePixel = 0; fill.Parent = barBg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill; regAccent(fill)
    local btn = Instance.new("TextButton"); btn.Text = ""; btn.BackgroundTransparency = 1
    btn.Size = UDim2.fromScale(1,1); btn.Parent = barBg
    local val = def
    State.options[id] = {Value = def, Type = "Slider"}
    local function setVal(v)
        v = math.clamp(v, min, max)
        if rounding > 0 then local m = 10^rounding; v = math.floor(v*m+0.5)/m else v = math.floor(v) end
        val = v
        fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0)
        lbl.Text = string.format(text, v); valLbl.Text = tostring(v)
        State.options[id].Value = v
        if opts.Callback then pcall(opts.Callback, v) end
    end
    track(btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local function upd()
                local m = UserInputService:GetMouseLocation()
                local rel = math.clamp((m.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                setVal(min + rel * (max - min))
            end
            upd()
            local conn = UserInputService.InputChanged:Connect(function(i)
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
    return {SetValue = setVal, GetValue = function() return val end}
end

local function makeButton(parent, id, opts)
    opts = opts or {}
    local text = opts.Text or id
    local btn = Instance.new("TextButton")
    btn.Text = text; btn.Font = FONT; btn.TextSize = 12; btn.TextColor3 = Config.textColor
    btn.BackgroundColor3 = Config.panelColor; btn.BackgroundTransparency = Config.panelAlpha
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Size = UDim2.new(1, -6, 0, 38)
    btn.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = btn
    track(btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play() end))
    track(btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = Config.panelAlpha}):Play() end))
    track(btn.MouseButton1Click:Connect(function()
        if opts.Func then pcall(opts.Func) end
        if opts.Callback then pcall(opts.Callback) end
    end))
    return btn
end

local function makeDropdown(parent, id, opts)
    opts = opts or {}
    local text = opts.Text or id
    local values = opts.Values or {}
    local cur = opts.Default or values[1] or ""
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38); row.BackgroundColor3 = Config.panelColor
    row.BackgroundTransparency = Config.panelAlpha; row.BorderSizePixel = 0; row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -130, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local valBtn = Instance.new("TextButton")
    valBtn.Text = tostring(cur); valBtn.Font = FONT; valBtn.TextSize = 11; valBtn.TextColor3 = Config.accent
    valBtn.BackgroundTransparency = 1; valBtn.Position = UDim2.new(1, -120, 0, 0); valBtn.Size = UDim2.new(0, 110, 1, 0)
    valBtn.TextXAlignment = Enum.TextXAlignment.Right; valBtn.Parent = row; regAccent(valBtn, "TextColor3")
    State.options[id] = {Value = cur, Type = "Dropdown"}

    local dd = {}
    function dd:SetValue(v)
        cur = v; valBtn.Text = tostring(v); State.options[id].Value = v
        if opts.Callback then pcall(opts.Callback, v) end
    end
    function dd:SetValues(vals) values = vals end
    function dd:GetValue() return cur end

    -- выпадающий список
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -6, 0, 0); listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.BackgroundColor3 = Config.panelColor; listFrame.BackgroundTransparency = 0.05
    listFrame.BorderSizePixel = 0; listFrame.Visible = false; listFrame.ZIndex = 10; listFrame.Parent = parent
    local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0,6); lc.Parent = listFrame
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 2); ll.Parent = listFrame
    local lp = Instance.new("UIPadding"); lp.PaddingTop = UDim.new(0,4); lp.PaddingBottom = UDim.new(0,4); lp.Parent = listFrame

    local function rebuildList()
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, v in ipairs(values) do
            local b = Instance.new("TextButton")
            b.Text = tostring(v); b.Font = FONT; b.TextSize = 11; b.TextColor3 = Config.textColor
            b.BackgroundColor3 = Config.panelColor; b.BackgroundTransparency = 0.5
            b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Size = UDim2.new(1, -8, 0, 26)
            b.ZIndex = 11; b.Parent = listFrame
            local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = b
            track(b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.2 end))
            track(b.MouseLeave:Connect(function() b.BackgroundTransparency = 0.5 end))
            track(b.MouseButton1Click:Connect(function()
                dd:SetValue(v); listFrame.Visible = false
            end))
        end
    end

    track(valBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then rebuildList() end
    end))
    return dd
end

local function makeInput(parent, id, opts)
    opts = opts or {}
    local text = opts.Text or id
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38); row.BackgroundColor3 = Config.panelColor
    row.BackgroundTransparency = Config.panelAlpha; row.BorderSizePixel = 0; row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.45, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    local box = Instance.new("TextBox")
    box.Text = opts.Default or ""; box.PlaceholderText = opts.Placeholder or ""
    box.Font = FONT; box.TextSize = 11; box.TextColor3 = Config.textColor
    box.PlaceholderColor3 = Config.dimColor
    box.BackgroundColor3 = Color3.fromRGB(35,35,35); box.BorderSizePixel = 0
    box.Position = UDim2.new(0.45, 0, 0.15, 0); box.Size = UDim2.new(0.55, -12, 0.7, 0)
    box.ClearTextOnFocus = false; box.Parent = row
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = box
    State.options[id] = {Value = box.Text, Type = "Input"}
    track(box.FocusLost:Connect(function()
        State.options[id].Value = box.Text
        if opts.Callback then pcall(opts.Callback, box.Text) end
    end))
    return box
end

local function makeLabel(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 28); holder.BackgroundTransparency = 1
    holder.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Text = text; lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.dimColor
    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = holder
    local obj = {}
    function obj:AddColorPicker(id, opts)
        opts = opts or {}
        local cp = Instance.new("Frame")
        cp.Size = UDim2.new(1, 0, 0, 90); cp.BackgroundColor3 = Config.panelColor
        cp.BackgroundTransparency = Config.panelAlpha; cp.BorderSizePixel = 0
        cp.Parent = parent
        local cpc = Instance.new("UICorner"); cpc.CornerRadius = UDim.new(0,6); cpc.Parent = cp
        local r, g, b = (opts.Default or Color3.new(1,1,1)).R*255, (opts.Default or Color3.new(1,1,1)).G*255, (opts.Default or Color3.new(1,1,1)).B*255
        State.options[id] = {Value = opts.Default or Color3.new(1,1,1), Type = "ColorPicker"}
        local function upd()
            local col = Color3.fromRGB(r, g, b)
            State.options[id].Value = col
            if opts.Callback then pcall(opts.Callback, col) end
        end
        for i, ch in ipairs({"R","G","B"}) do
            local cl = Instance.new("TextLabel")
            cl.Text = ch; cl.Font = FONT_B; cl.TextSize = 10; cl.TextColor3 = Config.dimColor
            cl.BackgroundTransparency = 1; cl.Position = UDim2.new(0, 10, 0, 8 + (i-1)*26)
            cl.Size = UDim2.new(0, 14, 0, 18); cl.Parent = cp
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -60, 0, 6); bar.Position = UDim2.new(0, 30, 0, 14 + (i-1)*26)
            bar.BackgroundColor3 = Color3.fromRGB(60,60,60); bar.BorderSizePixel = 0; bar.Parent = cp
            local bbc = Instance.new("UICorner"); bbc.CornerRadius = UDim.new(1,0); bbc.Parent = bar
            local vals = ({r,g,b})[i]
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(vals/255, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BorderSizePixel = 0; fill.Parent = bar
            local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
            local btn = Instance.new("TextButton"); btn.Text = ""; btn.BackgroundTransparency = 1
            btn.Size = UDim2.fromScale(1,1); btn.Parent = bar
            track(btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local function set2()
                        local m = UserInputService:GetMouseLocation()
                        local rel = math.clamp((m.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        local v = math.floor(rel * 255)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        if i == 1 then r = v elseif i == 2 then g = v else b = v end
                        upd()
                    end
                    set2()
                    local conn = UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then set2() end
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
        return {SetValue = function(c) r, g, b = c.R*255, c.G*255, c.B*255; upd() end}
    end
    return obj
end

-- ===== СТРАНИЦЫ / ТАБЫ =====
local function createPage(name)
    local holder = Instance.new("Frame")
    holder.Name = "Page_" .. name; holder.Size = UDim2.fromScale(1, 1)
    holder.BackgroundTransparency = 1; holder.Visible = false; holder.ZIndex = 2; holder.Parent = contentHolder

    local scrollL = Instance.new("ScrollingFrame")
    scrollL.Size = UDim2.new(0.5, -8, 1, -16); scrollL.Position = UDim2.new(0, 8, 0, 8)
    scrollL.BackgroundTransparency = 1; scrollL.BorderSizePixel = 0
    scrollL.ScrollBarThickness = 3; scrollL.ScrollBarImageColor3 = Config.strokeColor
    scrollL.CanvasSize = UDim2.new(0,0,0,0); scrollL.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollL.ZIndex = 2; scrollL.Parent = holder
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 6); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = scrollL

    local scrollR = Instance.new("ScrollingFrame")
    scrollR.Size = UDim2.new(0.5, -8, 1, -16); scrollR.Position = UDim2.new(0.5, 0, 0, 8)
    scrollR.BackgroundTransparency = 1; scrollR.BorderSizePixel = 0
    scrollR.ScrollBarThickness = 3; scrollR.ScrollBarImageColor3 = Config.strokeColor
    scrollR.CanvasSize = UDim2.new(0,0,0,0); scrollR.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollR.ZIndex = 2; scrollR.Parent = holder
    local rl = Instance.new("UIListLayout"); rl.Padding = UDim.new(0, 6); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = scrollR

    State.pages[name] = {holder = holder, scrollL = scrollL, scrollR = scrollR, tabBtn = nil, name = name}
    return {L = scrollL, R = scrollR}
end

local activeIndicator = Instance.new("Frame")
activeIndicator.Size = UDim2.new(0, 3, 0, 28); activeIndicator.BackgroundColor3 = Config.accent
activeIndicator.BorderSizePixel = 0; activeIndicator.ZIndex = 3; activeIndicator.Parent = sidebar
local aiC = Instance.new("UICorner"); aiC.CornerRadius = UDim.new(1,0); aiC.Parent = activeIndicator

local function switchPage(name)
    for n, page in pairs(State.pages) do page.holder.Visible = (n == name) end
    State.currentPage = name
    local btn = State.pages[name] and State.pages[name].tabBtn
    if btn then
        TweenService:Create(activeIndicator, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y)
        }):Play()
    end
    for n, page in pairs(State.pages) do
        if page.tabBtn then page.tabBtn.TextColor3 = (n == name) and Config.accent or Config.dimColor end
    end
end

local function makeTabObj(name)
    local s = createPage(name)
    local page = State.pages[name]

    local btn = Instance.new("TextButton")
    btn.Text = string.sub(name, 1, 1):upper(); btn.Font = FONT_B; btn.TextSize = 15
    btn.TextColor3 = Config.dimColor; btn.BackgroundColor3 = Config.panelColor
    btn.BackgroundTransparency = 0.4; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(44, 44); btn.LayoutOrder = #State.pages
    btn.ZIndex = 3; btn.Parent = sidebar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,8); bc.Parent = btn
    page.tabBtn = btn
    track(btn.MouseEnter:Connect(function()
        if State.currentPage ~= name then TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.15}):Play() end
    end))
    track(btn.MouseLeave:Connect(function()
        if State.currentPage ~= name then TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.4}):Play() end
    end))
    track(btn.MouseButton1Click:Connect(function() switchPage(name) end))

    local tabObj = {}
    local function makeGB(scroll)
        return function(gbName)
            local gb = Instance.new("Frame")
            gb.Size = UDim2.new(1, 0, 0, 28); gb.AutomaticSize = Enum.AutomaticSize.Y
            gb.BackgroundColor3 = Config.panelColor; gb.BackgroundTransparency = Config.panelAlpha
            gb.BorderSizePixel = 0; gb.Parent = scroll
            local gbc = Instance.new("UICorner"); gbc.CornerRadius = UDim.new(0,8); gbc.Parent = gb
            local gbp = Instance.new("UIPadding")
            gbp.PaddingTop = UDim.new(0, 8); gbp.PaddingBottom = UDim.new(0, 8)
            gbp.PaddingLeft = UDim.new(0, 8); gbp.PaddingRight = UDim.new(0, 8); gbp.Parent = gb
            local gbl = Instance.new("UIListLayout"); gbl.Padding = UDim.new(0, 5); gbl.SortOrder = Enum.SortOrder.LayoutOrder; gbl.Parent = gb
            local hdr = Instance.new("TextLabel")
            hdr.Text = gbName:upper(); hdr.Font = FONT_B; hdr.TextSize = 10; hdr.TextColor3 = Config.dimColor
            hdr.BackgroundTransparency = 1; hdr.Size = UDim2.new(1, 0, 0, 16)
            hdr.TextXAlignment = Enum.TextXAlignment.Left; hdr.LayoutOrder = -1; hdr.Parent = gb
            local groupObj = {}
            function groupObj:AddToggle(id, opts) return makeToggle(gb, id, opts) end
            function groupObj:AddSlider(id, opts) return makeSlider(gb, id, opts) end
            function groupObj:AddButton(id, opts) return makeButton(gb, id, opts) end
            function groupObj:AddDropdown(id, opts) return makeDropdown(gb, id, opts) end
            function groupObj:AddInput(id, opts) return makeInput(gb, id, opts) end
            function groupObj:AddLabel(text) return makeLabel(gb, text) end
            return groupObj
        end
    end
    function tabObj:AddLeftGroupbox(gbName) return makeGB(s.L)(gbName) end
    function tabObj:AddRightGroupbox(gbName) return makeGB(s.R)(gbName) end
    return tabObj
end

-- ===== NOTIFY =====
local notifyHolder = Instance.new("Frame")
notifyHolder.Name = "NotifyHolder"
notifyHolder.Size = UDim2.new(0, 280, 1, -100); notifyHolder.Position = UDim2.new(1, -300, 0, 50)
notifyHolder.BackgroundTransparency = 1; notifyHolder.ZIndex = 100; notifyHolder.Parent = gui
local nl = Instance.new("UIListLayout"); nl.Padding = UDim.new(0, 6); nl.VerticalAlignment = Enum.VerticalAlignment.Top; nl.Parent = notifyHolder

local function notify(msg, duration)
    duration = duration or 3
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 40); n.BackgroundColor3 = Config.panelColor
    n.BackgroundTransparency = 0.05; n.BorderSizePixel = 0; n.ZIndex = 101; n.Parent = notifyHolder
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,6); nc.Parent = n
    local ns = Instance.new("UIStroke"); ns.Color = Config.accent; ns.Thickness = 1; ns.Parent = n
    local lbl = Instance.new("TextLabel")
    lbl.Text = tostring(msg); lbl.Font = FONT; lbl.TextSize = 12; lbl.TextColor3 = Config.textColor
    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.Parent = n
    task.delay(duration, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            task.wait(0.2); n:Destroy()
        end
    end)
end

-- ===== WATERMARK =====
local wm = Instance.new("TextLabel")
wm.Name = "Watermark"; wm.Visible = false
wm.Font = FONT_B; wm.TextSize = 14; wm.TextColor3 = Config.textColor
wm.BackgroundTransparency = 1; wm.TextStrokeTransparency = 0
wm.AnchorPoint = Vector2.new(1, 0); wm.Position = UDim2.new(1, -12, 0, 8)
wm.Size = UDim2.new(0, 300, 0, 20); wm.TextXAlignment = Enum.TextXAlignment.Right
wm.ZIndex = 200; wm.Parent = gui
local wmConn
local function setWatermark(text)
    wm.Text = tostring(text) .. "  |  " .. math.floor(1/RunService.RenderStepped:Wait() or 60) .. " FPS"
end

-- ===== МЕНЮ-ВИДИМОСТЬ =====
local function setMenuVisible(visible)
    State.open = visible
    if visible then
        main.Visible = true
        main.Size = UDim2.fromOffset(Config.width, Config.height)
        main.BackgroundTransparency = Config.menuAlpha
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(Config.width, Config.height),
        }):Play()
    else
        local t = TweenService:Create(main, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(Config.width * 0.92, Config.height * 0.9),
            BackgroundTransparency = 1,
        })
        t:Play()
        t.Completed:Connect(function() if not State.open then main.Visible = false end end)
    end
end

-- ===== UNLOAD =====
local function unload()
    if State.unloaded then return end
    State.unloaded = true
    if Library.OnUnload then pcall(Library.OnUnload) end
    for _, c in ipairs(State.conns) do pcall(function() c:Disconnect() end) end
    State.conns = {}
    if wmConn then pcall(function() wmConn:Disconnect() end) end
    local t = TweenService:Create(main, TweenInfo.new(0.25), {
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
    if input.KeyCode == Config.menuBind then setMenuVisible(not State.open); return end
    for _, b in pairs(State.binds) do
        if b.get and b.get() ~= "" and input.KeyCode.Name == b.get() then
            if b.mode == "Toggle" and b.toggle then
                b.toggle:SetValue(not b.toggle:GetValue())
            elseif b.mode == "Press" then
                if b.toggle then b.toggle:SetValue(not b.toggle:GetValue()) end
            end
        end
    end
    for _, b in pairs(State.binds) do
        if b.key and input.KeyCode == b.key and b.cb then pcall(b.cb) end
    end
end))

-- ===== СТАРТ =====
do
    local origPos = main.Position
    main.Size = UDim2.fromOffset(Config.width * 0.92, Config.height * 0.9)
    main.BackgroundTransparency = 1
    main.Position = origPos + UDim2.fromOffset(0, 12)
    task.wait(0.05)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.fromOffset(Config.width, Config.height),
        BackgroundTransparency = Config.menuAlpha,
        Position = origPos,
    }):Play()
end

-- ===== LINORIA-СОВМЕСТИМЫЙ API =====
local Library = {}
Library.__index = Library
Library.ToggleKeybind = {Value = "RightShift"}
Library.KeybindFrame = {Visible = true}
Library.OnUnload = nil

function Library:CreateWindow(opts)
    opts = opts or {}
    if opts.Title and opts.Title ~= "" then title.Text = opts.Title:upper() end
    local WindowObj = {}
    function WindowObj:AddTab(name) return makeTabObj(name) end
    return WindowObj
end

function Library:Notify(msg, dur)
    notify(msg, dur or 3)
end

function Library:SetWatermark(text)
    wm.Visible = true
    wm.Text = tostring(text) .. "  |  Aphex"
    -- не обновляем FPS чтобы не грузить
end

function Library:Unload()
    unload()
end

-- ===== ЭКСПОРТ =====
if not getgenv().Options then getgenv().Options = {} end
if not getgenv().Toggles then getgenv().Toggles = {} end

-- при создании тоггла кладём в getgenv()
local origMakeToggle = makeToggle
makeToggle = function(parent, id, opts)
    local t = origMakeToggle(parent, id, opts)
    getgenv().Toggles[id] = t
    return t
end

-- все options будут синхронизироваться через State.options
local realOptions = State.options
State.options = setmetatable({}, {
    __index = function(_, k) return realOptions[k] end,
    __newindex = function(_, k, v) realOptions[k] = v; getgenv().Options[k] = v end,
})

-- переключаем страницу по умолчанию
if next(State.pages) then
    local firstName = next(State.pages)
    switchPage(firstName)
end

-- ===== ФИНАЛ =====
getgenv().Library = Library
return Library