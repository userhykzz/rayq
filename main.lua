-- Urban Reload | AimBot + Head Lock | RXMenu UI Style
-- ollie build — inject after spawn
-- Executor: Synapse X / KRNL / Fluxus

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Camera          = workspace.CurrentCamera
local LocalPlayer     = Players.LocalPlayer

-- ══════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════
local CFG = {
    Enabled    = false,
    LockHead   = true,
    FOV        = 120,
    Smoothing  = 12,   -- 1–30
    TeamCheck  = true,
    WallCheck  = true,
    AimKey     = Enum.UserInputType.MouseButton2,
}

-- ══════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible      = false
fovCircle.Radius       = CFG.FOV
fovCircle.Color        = Color3.fromRGB(220, 30, 30)
fovCircle.Thickness    = 1.2
fovCircle.Filled       = false
fovCircle.Transparency = 0.5

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius   = CFG.FOV
    fovCircle.Visible  = CFG.Enabled
end)

-- ══════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════
local function getTargetPart(char)
    return CFG.LockHead and char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function isAlive(char)
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function wallCheck(pos)
    if not CFG.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local rp     = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, pos - origin, rp)
    if result then
        local char = result.Instance:FindFirstAncestorOfClass("Model")
        return char and Players:GetPlayerFromCharacter(char) ~= nil
    end
    return true
end

local function getClosest()
    local center  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest, minDist = nil, CFG.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if CFG.TeamCheck and p.Team == LocalPlayer.Team then continue end
        local char = p.Character
        if not char or not isAlive(char) then continue end
        local part = getTargetPart(char)
        if not part then continue end
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist < minDist and wallCheck(part.Position) then
            minDist, closest = dist, part
        end
    end
    return closest
end

-- ══════════════════════════════════════
--  AIMBOT LOOP
-- ══════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not CFG.Enabled then return end
    if not UserInputService:IsMouseButtonPressed(CFG.AimKey) then return end
    local t = getClosest()
    if not t then return end
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, t.Position),
        CFG.Smoothing / 100
    )
end)

-- ══════════════════════════════════════
--  RXMENU UI
-- ══════════════════════════════════════
local DARK   = Color3.fromRGB(10, 10, 12)
local PANEL  = Color3.fromRGB(16, 16, 18)
local ROW    = Color3.fromRGB(20, 20, 23)
local ROWH   = Color3.fromRGB(25, 25, 30)
local RED    = Color3.fromRGB(210, 25, 25)
local REDON  = Color3.fromRGB(220, 30, 30)
local WHITE  = Color3.fromRGB(230, 230, 230)
local GREY   = Color3.fromRGB(110, 110, 120)
local TABSEL = Color3.fromRGB(210, 25, 25)

local gui = Instance.new("ScreenGui")
gui.Name           = "RXMenu_Ollie"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = (gethui and gethui()) or game:GetService("CoreGui")

-- ── Window ──
local win = Instance.new("Frame")
win.Size             = UDim2.new(0, 640, 0, 400)
win.Position         = UDim2.new(0.5, -320, 0.5, -200)
win.BackgroundColor3 = DARK
win.BorderSizePixel  = 0
win.Active           = true
win.Draggable        = true
win.Parent           = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 4)

-- ── Title bar ──
local titleBar = Instance.new("Frame")
titleBar.Size            = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = win
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

-- RX logo box
local logoBox = Instance.new("Frame")
logoBox.Size             = UDim2.new(0, 34, 0, 34)
logoBox.BackgroundColor3  = RED
logoBox.BorderSizePixel   = 0
logoBox.Parent            = titleBar
Instance.new("UICorner", logoBox).CornerRadius = UDim.new(0, 4)

local logoLbl = Instance.new("TextLabel")
logoLbl.Size              = UDim2.new(1, 0, 1, 0)
logoLbl.BackgroundTransparency = 1
logoLbl.Text              = "RX"
logoLbl.TextColor3        = WHITE
logoLbl.TextSize          = 13
logoLbl.Font              = Enum.Font.GothamBold
logoLbl.Parent            = logoBox

local menuLbl = Instance.new("TextLabel")
menuLbl.Size              = UDim2.new(0, 80, 1, 0)
menuLbl.Position          = UDim2.new(0, 38, 0, 0)
menuLbl.BackgroundTransparency = 1
menuLbl.Text              = "#XMENU"
menuLbl.TextColor3        = WHITE
menuLbl.TextSize          = 13
menuLbl.Font              = Enum.Font.GothamBold
menuLbl.TextXAlignment    = Enum.TextXAlignment.Left
menuLbl.Parent            = titleBar

-- Close btn
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 22, 0, 22)
closeBtn.Position         = UDim2.new(1, -28, 0, 6)
closeBtn.BackgroundColor3  = Color3.fromRGB(40, 40, 45)
closeBtn.Text             = "×"
closeBtn.TextColor3       = GREY
closeBtn.TextSize         = 16
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() fovCircle:Remove() end)

-- ── Top tab bar ──
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, 32)
tabBar.Position         = UDim2.new(0, 0, 0, 34)
tabBar.BackgroundColor3  = Color3.fromRGB(12, 12, 15)
tabBar.BorderSizePixel   = 0
tabBar.Parent            = win

local tabList = Instance.new("UIListLayout", tabBar)
tabList.FillDirection    = Enum.FillDirection.Horizontal
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
tabList.Padding          = UDim.new(0, 0)

local TAB_NAMES = {"Combat", "Visuals", "World", "Player", "Misc", "Playerlist", "Configs", "Settings"}
local tabBtns   = {}
local activeTab = "Combat"

local function makeTopTab(name)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 72, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text             = name
    btn.TextColor3       = name == activeTab and WHITE or GREY
    btn.TextSize         = 11
    btn.Font             = Enum.Font.Gotham
    btn.BorderSizePixel  = 0
    btn.Parent           = tabBar

    -- underline
    local ul = Instance.new("Frame")
    ul.Size             = UDim2.new(1, 0, 0, 2)
    ul.Position         = UDim2.new(0, 0, 1, -2)
    ul.BackgroundColor3  = RED
    ul.BorderSizePixel   = 0
    ul.Visible          = name == activeTab
    ul.Parent           = btn

    tabBtns[name] = {btn = btn, ul = ul}

    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabBtns) do
            local sel = (n == name)
            t.btn.TextColor3 = sel and WHITE or GREY
            t.ul.Visible     = sel
        end
        activeTab = name
    end)
end

for _, n in ipairs(TAB_NAMES) do makeTopTab(n) end

-- ── Sub-tab bar (ESP / Skeleton style) ──
local subBar = Instance.new("Frame")
subBar.Size             = UDim2.new(1, 0, 0, 28)
subBar.Position         = UDim2.new(0, 0, 0, 66)
subBar.BackgroundColor3  = PANEL
subBar.BorderSizePixel   = 0
subBar.Parent            = win

local subList = Instance.new("UIListLayout", subBar)
subList.FillDirection    = Enum.FillDirection.Horizontal
subList.VerticalAlignment = Enum.VerticalAlignment.Center
subList.Padding          = UDim.new(0, 2)

Instance.new("UIPadding", subBar).PaddingLeft = UDim.new(0, 8)

local SUB_NAMES = {"Aimbot", "Visuals", "Misc"}
local subBtns   = {}
local activeSub = "Aimbot"

local function makeSubTab(name)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 72, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Text             = name
    btn.TextColor3       = name == activeSub and WHITE or GREY
    btn.TextSize         = 11
    btn.Font             = Enum.Font.Gotham
    btn.BorderSizePixel  = 0
    btn.Parent           = subBar

    local ul = Instance.new("Frame")
    ul.Size             = UDim2.new(1, 0, 0, 2)
    ul.Position         = UDim2.new(0, 0, 1, -1)
    ul.BackgroundColor3  = RED
    ul.BorderSizePixel   = 0
    ul.Visible          = name == activeSub
    ul.Parent           = btn

    subBtns[name] = {btn = btn, ul = ul}
    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(subBtns) do
            local sel = (n == name)
            t.btn.TextColor3 = sel and WHITE or GREY
            t.ul.Visible     = sel
        end
        activeSub = name
    end)
end

for _, n in ipairs(SUB_NAMES) do makeSubTab(n) end

-- ── Separator line ──
local sep = Instance.new("Frame")
sep.Size             = UDim2.new(1, 0, 0, 1)
sep.Position         = UDim2.new(0, 0, 0, 94)
sep.BackgroundColor3  = Color3.fromRGB(30, 30, 35)
sep.BorderSizePixel   = 0
sep.Parent           = win

-- ── Scroll content area ──
local scroll = Instance.new("ScrollingFrame")
scroll.Size             = UDim2.new(1, 0, 1, -96)
scroll.Position         = UDim2.new(0, 0, 0, 96)
scroll.BackgroundColor3  = PANEL
scroll.BorderSizePixel   = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = RED
scroll.CanvasSize        = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent            = win

local contentList = Instance.new("UIListLayout", scroll)
contentList.Padding      = UDim.new(0, 1)
contentList.SortOrder    = Enum.SortOrder.LayoutOrder

-- ══════════════════════════════════════
--  ROW BUILDERS
-- ══════════════════════════════════════
local rowOrder = 0

local function makeToggleRow(label, cfgKey)
    rowOrder = rowOrder + 1
    local row = Instance.new("Frame")
    row.Name             = label
    row.Size             = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3  = PANEL
    row.BorderSizePixel   = 0
    row.LayoutOrder       = rowOrder
    row.Parent            = scroll

    -- hover tween
    local hoverBtn = Instance.new("TextButton")
    hoverBtn.Size             = UDim2.new(1, 0, 1, 0)
    hoverBtn.BackgroundTransparency = 1
    hoverBtn.Text             = ""
    hoverBtn.Parent           = row

    hoverBtn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = ROWH}):Play()
    end)
    hoverBtn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = PANEL}):Play()
    end)

    -- label
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -70, 1, 0)
    lbl.Position          = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = WHITE
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    -- pill
    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, 38, 0, 20)
    pill.Position         = UDim2.new(1, -52, 0.5, -10)
    pill.BackgroundColor3  = CFG[cfgKey] and RED or Color3.fromRGB(40, 40, 45)
    pill.BorderSizePixel   = 0
    pill.Parent            = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = CFG[cfgKey]
        and UDim2.new(1, -17, 0.5, -7)
        or  UDim2.new(0, 3,   0.5, -7)
    knob.BackgroundColor3  = WHITE
    knob.BorderSizePixel   = 0
    knob.Parent            = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    hoverBtn.MouseButton1Click:Connect(function()
        CFG[cfgKey] = not CFG[cfgKey]
        local on = CFG[cfgKey]
        TweenService:Create(pill,  TweenInfo.new(0.15), {BackgroundColor3 = on and RED or Color3.fromRGB(40,40,45)}):Play()
        TweenService:Create(knob,  TweenInfo.new(0.15), {Position = on
            and UDim2.new(1, -17, 0.5, -7)
            or  UDim2.new(0, 3,   0.5, -7)}):Play()
    end)

    -- bottom divider
    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -16, 0, 1)
    div.Position         = UDim2.new(0, 8, 1, -1)
    div.BackgroundColor3  = Color3.fromRGB(25, 25, 30)
    div.BorderSizePixel   = 0
    div.Parent           = row
end

local function makeSliderRow(label, cfgKey, min, max, suffix)
    suffix = suffix or ""
    rowOrder = rowOrder + 1

    local row = Instance.new("Frame")
    row.Name             = label
    row.Size             = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3  = PANEL
    row.BorderSizePixel   = 0
    row.LayoutOrder       = rowOrder
    row.Parent            = scroll

    -- label
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -80, 0, 22)
    lbl.Position          = UDim2.new(0, 16, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = GREY
    lbl.TextSize          = 11
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    -- value
    local valLbl = Instance.new("TextLabel")
    valLbl.Size            = UDim2.new(0, 60, 0, 22)
    valLbl.Position        = UDim2.new(1, -70, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text            = tostring(CFG[cfgKey]) .. suffix
    valLbl.TextColor3      = WHITE
    valLbl.TextSize        = 11
    valLbl.Font            = Enum.Font.GothamBold
    valLbl.TextXAlignment  = Enum.TextXAlignment.Right
    valLbl.Parent          = row

    -- track bg
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -32, 0, 3)
    track.Position         = UDim2.new(0, 16, 0, 36)
    track.BackgroundColor3  = Color3.fromRGB(35, 35, 40)
    track.BorderSizePixel   = 0
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- track fill
    local pct0 = (CFG[cfgKey] - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3  = RED
    fill.BorderSizePixel   = 0
    fill.Parent            = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- knob dot
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 10, 0, 10)
    dot.Position         = UDim2.new(pct0, -5, 0.5, -5)
    dot.BackgroundColor3  = WHITE
    dot.BorderSizePixel   = 0
    dot.ZIndex           = 3
    dot.Parent           = track
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = track.AbsolutePosition
            local sz  = track.AbsoluteSize
            local p   = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(min + p * (max - min))
            CFG[cfgKey] = val
            fill.Size    = UDim2.new(p, 0, 1, 0)
            dot.Position = UDim2.new(p, -5, 0.5, -5)
            valLbl.Text  = tostring(val) .. suffix
        end
    end)

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -16, 0, 1)
    div.Position         = UDim2.new(0, 8, 1, -1)
    div.BackgroundColor3  = Color3.fromRGB(25, 25, 30)
    div.BorderSizePixel   = 0
    div.Parent           = row
end

-- ══════════════════════════════════════
--  POPULATE ROWS
-- ══════════════════════════════════════
makeToggleRow("Aimbot",      "Enabled")
makeToggleRow("Head Lock",   "LockHead")
makeToggleRow("Team Check",  "TeamCheck")
makeToggleRow("Wall Check",  "WallCheck")
makeSliderRow("FOV",         "FOV",       20,  400, " px")
makeSliderRow("Smoothing",   "Smoothing", 1,   30,  "")
