-- Urban Reload | FULL KIT + UI
-- Executor: Synapse X / KRNL / Fluxus / Delta
-- INSERT = toggle UI

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  CONFIG (ค่าเริ่มต้น — เปลี่ยนได้ใน UI)
-- ══════════════════════════════════════════════════════════════
local CFG = {
    -- aimbot
    Aimbot      = true,
    AimPart     = "Head",
    FOV         = 9999,
    TeamCheck   = true,
    WallCheck   = false,
    PredictMS   = 80,
    -- godmode
    GodMode     = true,
    -- ammo
    InfAmmo     = true,
    NoRecoil    = true,
    NoSpread    = true,
    -- speed
    Speed       = false,
    SpeedValue  = 32,         -- default walkspeed (16 = normal)
    -- esp
    ESP         = true,
    ESPBox      = true,
    ESPName     = true,
    ESPHealth   = true,
    ESPDistance = true,
    -- colors
    BoxColor    = Color3.fromRGB(255, 60, 60),
    LockedColor = Color3.fromRGB(60, 255, 60),
    FriendColor = Color3.fromRGB(60, 150, 255),
}

-- ══════════════════════════════════════════════════════════════
--  UI BUILD
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "URKit"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder     = 999
ScreenGui.Parent           = game:GetService("CoreGui")

-- main frame
local Main = Instance.new("Frame")
Main.Name            = "Main"
Main.Size            = UDim2.new(0, 300, 0, 480)
Main.Position        = UDim2.new(0, 20, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent          = ScreenGui

-- rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent       = Main

-- stroke
local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(120, 60, 255)
stroke.Thickness = 1.5
stroke.Parent    = Main

-- title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(120, 60, 255)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent       = TitleBar

-- title fix bottom corners
local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0, 10)
TitleFix.Position         = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(120, 60, 255)
TitleFix.BorderSizePixel  = 0
TitleFix.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size            = UDim2.new(1, -50, 1, 0)
TitleLabel.Position        = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text            = "⚡  Urban Reload Kit"
TitleLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize        = 14
TitleLabel.Font            = Enum.Font.GothamBold
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.Parent          = TitleBar

-- close / minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size               = UDim2.new(0, 30, 0, 30)
MinBtn.Position           = UDim2.new(1, -38, 0, 5)
MinBtn.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.8
MinBtn.Text               = "−"
MinBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize           = 18
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.BorderSizePixel    = 0
MinBtn.Parent             = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- scroll container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size                   = UDim2.new(1, 0, 1, -40)
Scroll.Position               = UDim2.new(0, 0, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel        = 0
Scroll.ScrollBarThickness     = 3
Scroll.ScrollBarImageColor3   = Color3.fromRGB(120, 60, 255)
Scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
Scroll.Parent                 = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding          = UDim.new(0, 0)
ListLayout.SortOrder        = Enum.SortOrder.LayoutOrder
ListLayout.Parent           = Scroll

local PaddingTop = Instance.new("UIPadding")
PaddingTop.PaddingTop    = UDim.new(0, 8)
PaddingTop.PaddingLeft   = UDim.new(0, 12)
PaddingTop.PaddingRight  = UDim.new(0, 12)
PaddingTop.PaddingBottom = UDim.new(0, 8)
PaddingTop.Parent        = Scroll

-- ── UI HELPERS ────────────────────────────────────────────────
local order = 0
local function nextOrder() order = order + 1 return order end

-- section label
local function makeSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "  " .. text:upper()
    lbl.TextColor3        = Color3.fromRGB(120, 60, 255)
    lbl.TextSize          = 11
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.LayoutOrder       = nextOrder()
    lbl.Parent            = Scroll

    local sep = Instance.new("Frame")
    sep.Size              = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3  = Color3.fromRGB(120, 60, 255)
    sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel   = 0
    sep.LayoutOrder       = nextOrder()
    sep.Parent            = Scroll
end

-- toggle button
local function makeToggle(label, cfgKey, callback)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.LayoutOrder       = nextOrder()
    row.Parent            = Scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(210, 210, 220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local btn = Instance.new("Frame")
    btn.Size              = UDim2.new(0, 44, 0, 22)
    btn.Position          = UDim2.new(1, -44, 0.5, -11)
    btn.BackgroundColor3  = CFG[cfgKey] and Color3.fromRGB(120, 60, 255) or Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel   = 0
    btn.Parent            = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 16, 0, 16)
    knob.Position         = CFG[cfgKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.Parent           = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton")
    clickArea.Size              = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text              = ""
    clickArea.Parent            = row

    clickArea.MouseButton1Click:Connect(function()
        CFG[cfgKey] = not CFG[cfgKey]
        local on = CFG[cfgKey]
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(120, 60, 255) or Color3.fromRGB(50, 50, 60)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if callback then callback(on) end
    end)

    return row
end

-- slider
local function makeSlider(label, cfgKey, min, max, callback)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 52)
    row.BackgroundTransparency = 1
    row.LayoutOrder       = nextOrder()
    row.Parent            = Scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label .. ":  " .. tostring(CFG[cfgKey])
    lbl.TextColor3        = Color3.fromRGB(210, 210, 220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local track = Instance.new("Frame")
    track.Size            = UDim2.new(1, 0, 0, 6)
    track.Position        = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    track.Parent          = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((CFG[cfgKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 60, 255)
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size            = UDim2.new(0, 14, 0, 14)
    thumb.Position        = UDim2.new((CFG[cfgKey] - min) / (max - min), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex          = 2
    thumb.Parent          = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local dragging = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local trackPos  = track.AbsolutePosition
            local trackSize = track.AbsoluteSize
            local rel = math.clamp((inp.Position.X - trackPos.X) / trackSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            CFG[cfgKey] = val
            lbl.Text   = label .. ":  " .. tostring(val)
            fill.Size  = UDim2.new(rel, 0, 1, 0)
            thumb.Position = UDim2.new(rel, -7, 0.5, -7)
            if callback then callback(val) end
        end
    end)
end

-- ── BUILD UI SECTIONS ─────────────────────────────────────────
makeSection("🎯  Aimbot")
makeToggle("Aimbot", "Aimbot")
makeToggle("Team Check", "TeamCheck")
makeToggle("Wall Check", "WallCheck")

makeSection("❤️  Combat")
makeToggle("God Mode", "GodMode")
makeToggle("Infinite Ammo", "InfAmmo")
makeToggle("No Recoil", "NoRecoil")
makeToggle("No Spread", "NoSpread")

makeSection("👟  Movement")
makeToggle("Speed Hack", "Speed", function(on)
    local c = lp.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and CFG.SpeedValue or 16 end
end)
makeSlider("Walk Speed", "SpeedValue", 16, 150, function(val)
    if CFG.Speed then
        local c = lp.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

makeSection("👁️  ESP")
makeToggle("ESP", "ESP")
makeToggle("Box", "ESPBox")
makeToggle("Name", "ESPName")
makeToggle("Health Bar", "ESPHealth")
makeToggle("Distance", "ESPDistance")

-- ══════════════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════════════
local draggingUI, dragStart, startPos
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = true
        dragStart  = inp.Position
        startPos   = Main.Position
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingUI = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if draggingUI and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.2), {
        Size = minimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 480)
    }):Play()
    MinBtn.Text = minimized and "+" or "−"
end)

-- INSERT toggle
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════════════════════
local holding  = false
local locked   = nil
local velCache = {}

local function isAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function sameTeam(p)
    return CFG.TeamCheck and p.Team ~= nil and p.Team == lp.Team
end

local function screenDist(part)
    local sp, on = cam:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - cam.ViewportSize / 2).Magnitude
end

local function getPredicted(head)
    local p   = Players:GetPlayerFromCharacter(head.Parent)
    if not p then return head.Position end
    local now  = tick()
    local prev = velCache[p]
    velCache[p] = { pos = head.Position, t = now }
    if not prev then return head.Position end
    local dt = now - prev.t
    if dt <= 0 or dt > 0.5 then return head.Position end
    return head.Position + (head.Position - prev.pos) / dt * (CFG.PredictMS / 1000)
end

local function getBest()
    local best, bd = nil, CFG.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and not sameTeam(p) then
            local c    = p.Character
            local head = c and c:FindFirstChild(CFG.AimPart)
            if head then
                local d = screenDist(head)
                if d < bd then best = head bd = d end
            end
        end
    end
    return best
end

RunService:BindToRenderStep("URLock", Enum.RenderPriority.Last.Value + 9999, function()
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if not CFG.Aimbot or not holding then locked = nil return end
    locked = getBest()
    if not locked then return end
    local owner = Players:GetPlayerFromCharacter(locked.Parent)
    if not owner or not isAlive(owner) then locked = nil return end
    cam.CFrame = CFrame.new(cam.CFrame.Position, getPredicted(locked))
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false locked = nil
    end
end)

-- ══════════════════════════════════════════════════════════════
--  GODMODE
-- ══════════════════════════════════════════════════════════════
local godConn
local function startGod()
    if godConn then godConn:Disconnect() end
    godConn = RunService.Heartbeat:Connect(function()
        if not CFG.GodMode then return end
        local c = lp.Character if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
        if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        if h.MaxHealth < 100 then h.MaxHealth = 100 end
        if h:GetState() == Enum.HumanoidStateType.Dead then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end
startGod()
lp.CharacterAdded:Connect(function() task.wait(0.1) startGod() end)

-- ══════════════════════════════════════════════════════════════
--  SPEED
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.Speed then return end
    local c = lp.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    h.WalkSpeed = CFG.SpeedValue
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    if CFG.Speed then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = CFG.SpeedValue end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INFINITE AMMO
-- ══════════════════════════════════════════════════════════════
local ammoKeywords = {"ammo","magazine","mag","bullet","clip","round","chamber","loaded","reserve"}
local function isAmmoVal(name)
    local low = name:lower()
    for _, k in ipairs(ammoKeywords) do if low:find(k) then return true end end
    return false
end
local ammoConns   = {}
local watchedTools = {}

local function hookTool(tool)
    if watchedTools[tool] then return end
    watchedTools[tool] = true
    for _, v in ipairs(tool:GetDescendants()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) and isAmmoVal(v.Name) then
            local maxV = v.Value
            local c = v.Changed:Connect(function(nv)
                if not CFG.InfAmmo then return end
                if nv < maxV then task.defer(function() v.Value = maxV end)
                else maxV = nv end
            end)
            table.insert(ammoConns, c)
        end
    end
end

local function watchTools(char)
    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then hookTool(t) end end
    char.ChildAdded:Connect(function(c) if c:IsA("Tool") then task.wait(0.05) hookTool(c) end end)
    lp.Backpack.ChildAdded:Connect(function(c) if c:IsA("Tool") then task.wait(0.05) hookTool(c) end end)
end
if lp.Character then watchTools(lp.Character) end
lp.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    watchedTools = {}
    for _, c in ipairs(ammoConns) do c:Disconnect() end
    ammoConns = {}
    watchTools(char)
end)

-- ══════════════════════════════════════════════════════════════
--  NO RECOIL
-- ══════════════════════════════════════════════════════════════
local recoilFiring = false
local smoothedCF   = cam.CFrame

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        recoilFiring = true smoothedCF = cam.CFrame
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then recoilFiring = false end
end)

RunService:BindToRenderStep("URRecoil", Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.NoRecoil or not recoilFiring then smoothedCF = cam.CFrame return end
    local cur    = cam.CFrame
    local dPitch = math.asin(math.clamp(cur.LookVector.Y, -1, 1)) -
                   math.asin(math.clamp(smoothedCF.LookVector.Y, -1, 1))
    if dPitch > 0.002 then
        cam.CFrame = CFrame.new(cur.Position) *
            CFrame.Angles(-(dPitch), 0, 0) * cur
    end
    smoothedCF = cam.CFrame
end)

-- ══════════════════════════════════════════════════════════════
--  ESP DRAWINGS
-- ══════════════════════════════════════════════════════════════
local espObjects = {}

local function newDraw(kind, props)
    local d = Drawing.new(kind)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function makeESP(p)
    espObjects[p] = {
        box  = newDraw("Square", {Thickness=1.5, Filled=false, Color=CFG.BoxColor, Visible=false}),
        name = newDraw("Text",   {Size=13, Center=true, Outline=true,
                                  Color=Color3.fromRGB(255,255,255), Visible=false}),
        hpbg = newDraw("Square", {Thickness=1, Filled=true,
                                  Color=Color3.fromRGB(0,0,0), Visible=false}),
        hp   = newDraw("Square", {Thickness=1, Filled=true,
                                  Color=Color3.fromRGB(60,255,60), Visible=false}),
        dist = newDraw("Text",   {Size=11, Center=true, Outline=true,
                                  Color=Color3.fromRGB(180,180,180), Visible=false}),
    }
end

local function removeESP(p)
    if not espObjects[p] then return end
    for _, d in pairs(espObjects[p]) do d:Remove() end
    espObjects[p] = nil
end

Players.PlayerAdded:Connect(function(p) makeESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then makeESP(p) end end

-- FOV circle
local fovCircle = newDraw("Circle", {Thickness=1.5, NumSides=128, Radius=80,
                                      Filled=false, Color=CFG.FOVColor, Visible=false})
local lockDot   = newDraw("Circle", {Thickness=0, NumSides=32, Radius=5,
                                      Filled=true, Color=CFG.LockedColor, Visible=false})

-- ══════════════════════════════════════════════════════════════
--  MASTER RENDER LOOP (ESP + FOV)
-- ══════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- FOV
    fovCircle.Position = cam.ViewportSize / 2
    fovCircle.Visible  = holding
    fovCircle.Color    = locked and CFG.LockedColor or CFG.BoxColor

    if locked then
        local sp, on = cam:WorldToViewportPoint(locked.Position)
        lockDot.Position = Vector2.new(sp.X, sp.Y)
        lockDot.Visible  = on
    else
        lockDot.Visible = false
    end

    -- ESP
    for p, d in pairs(espObjects) do
        local c    = p.Character
        local hum  = c and c:FindFirstChildOfClass("Humanoid")
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local head = c and c:FindFirstChild("Head")
        local alive = hum and hum.Health > 0
        local isTarget = locked and locked.Parent == c
        local enemy = not sameTeam(p)

        if CFG.ESP and alive and root and head and enemy then
            local topV  = head.Position + Vector3.new(0, 0.7, 0)
            local botV  = root.Position - Vector3.new(0, 2.8, 0)
            local top2, on1 = cam:WorldToViewportPoint(topV)
            local bot2, on2 = cam:WorldToViewportPoint(botV)
            local show = (on1 or on2) and top2.Z > 0

            local boxColor = isTarget and CFG.LockedColor or CFG.BoxColor

            if show then
                local h = math.abs(bot2.Y - top2.Y)
                local w = h * 0.45
                local x = top2.X - w / 2
                local y = top2.Y

                -- box
                if CFG.ESPBox then
                    d.box.Size     = Vector2.new(w, h)
                    d.box.Position = Vector2.new(x, y)
                    d.box.Color    = boxColor
                end
                d.box.Visible = CFG.ESPBox and show

                -- name
                if CFG.ESPName then
                    d.name.Text     = p.Name
                    d.name.Position = Vector2.new(top2.X, y - 16)
                    d.name.Color    = boxColor
                end
                d.name.Visible = CFG.ESPName and show

                -- distance
                if CFG.ESPDistance then
                    local dist = math.floor((cam.CFrame.Position -
                                  root.Position).Magnitude)
                    d.dist.Text     = dist .. "m"
                    d.dist.Position = Vector2.new(top2.X, y + h + 3)
                end
                d.dist.Visible = CFG.ESPDistance and show

                -- health bar
                if CFG.ESPHealth and hum then
                    local barW  = 4
                    local barX  = x - barW - 2
                    local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local fillH = h * ratio
                    local hpColor = Color3.fromRGB(
                        math.floor(255 * (1 - ratio)),
                        math.floor(255 * ratio), 0)

                    d.hpbg.Size     = Vector2.new(barW, h)
                    d.hpbg.Position = Vector2.new(barX, y)
                    d.hp.Size       = Vector2.new(barW, fillH)
                    d.hp.Position   = Vector2.new(barX, y + h - fillH)
                    d.hp.Color      = hpColor
                end
                d.hpbg.Visible = CFG.ESPHealth and show
                d.hp.Visible   = CFG.ESPHealth and show
            else
                for _, dr in pairs(d) do dr.Visible = false end
            end
        else
            for _, dr in pairs(d) do dr.Visible = false end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  CLEANUP
-- ══════════════════════════════════════════════════════════════
lp.CharacterAdded:Connect(function()
    holding = false locked = nil velCache = {}
end)
Players.PlayerRemoving:Connect(function(p)
    velCache[p] = nil removeESP(p)
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(" ⚡ Urban Reload Full Kit — LOADED")
print(" INSERT   = toggle UI")
print(" RMB hold = aimlock")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
