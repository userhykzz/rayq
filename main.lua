-- Urban Reload | XENO FULL UI BUILD
-- Right Shift = toggle UI
-- Executor: Xeno (xeno.now)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local CFG = {
    Aimbot    = true,
    AimPart   = "Head",
    TeamCheck = true,
    PredictMS = 80,
    GodMode   = true,
    InfAmmo   = true,
    NoRecoil  = true,
    Speed     = false,
    SpeedVal  = 32,
}

-- ══════════════════════════════════════════════════════════════
--  UI
-- ══════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "g_" .. math.random(1000,9999)
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder   = 999
gui.Parent         = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Name              = "Main"
Main.Size              = UDim2.new(0, 280, 0, 440)
Main.Position          = UDim2.new(0, 20, 0.5, -220)
Main.BackgroundColor3  = Color3.fromRGB(13, 13, 18)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", Main)
ms.Color     = Color3.fromRGB(100, 50, 220)
ms.Thickness = 1.5

-- title bar
local TB = Instance.new("Frame")
TB.Size            = UDim2.new(1, 0, 0, 38)
TB.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
TB.BorderSizePixel  = 0
TB.Parent           = Main
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 10)
-- fix bottom corners of title
local tbfix = Instance.new("Frame")
tbfix.Size            = UDim2.new(1, 0, 0, 10)
tbfix.Position        = UDim2.new(0, 0, 1, -10)
tbfix.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
tbfix.BorderSizePixel  = 0
tbfix.Parent           = TB

local TL = Instance.new("TextLabel")
TL.Size               = UDim2.new(1, -50, 1, 0)
TL.Position           = UDim2.new(0, 12, 0, 0)
TL.BackgroundTransparency = 1
TL.Text               = "⚡  UR Kit  •  RShift"
TL.TextColor3         = Color3.fromRGB(255, 255, 255)
TL.TextSize           = 13
TL.Font               = Enum.Font.GothamBold
TL.TextXAlignment     = Enum.TextXAlignment.Left
TL.Parent             = TB

local MinBtn = Instance.new("TextButton")
MinBtn.Size              = UDim2.new(0, 28, 0, 28)
MinBtn.Position          = UDim2.new(1, -34, 0.5, -14)
MinBtn.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.8
MinBtn.Text              = "−"
MinBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize          = 16
MinBtn.Font              = Enum.Font.GothamBold
MinBtn.BorderSizePixel   = 0
MinBtn.Parent            = TB
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size                  = UDim2.new(1, 0, 1, -38)
Scroll.Position              = UDim2.new(0, 0, 0, 38)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel       = 0
Scroll.ScrollBarThickness    = 3
Scroll.ScrollBarImageColor3  = Color3.fromRGB(100, 50, 220)
Scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
Scroll.Parent                = Main

local ULL = Instance.new("UIListLayout", Scroll)
ULL.Padding    = UDim.new(0, 0)
ULL.SortOrder  = Enum.SortOrder.LayoutOrder

local UP = Instance.new("UIPadding", Scroll)
UP.PaddingTop    = UDim.new(0, 6)
UP.PaddingLeft   = UDim.new(0, 10)
UP.PaddingRight  = UDim.new(0, 10)
UP.PaddingBottom = UDim.new(0, 8)

-- ── UI HELPERS ────────────────────────────────────────────────
local ord = 0
local function O() ord = ord + 1 return ord end

local function section(txt)
    local f = Instance.new("Frame")
    f.Size              = UDim2.new(1, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.LayoutOrder       = O()
    f.Parent            = Scroll

    local l = Instance.new("TextLabel", f)
    l.Size              = UDim2.new(1, 0, 0, 18)
    l.Position          = UDim2.new(0, 0, 0, 8)
    l.BackgroundTransparency = 1
    l.Text              = txt:upper()
    l.TextColor3        = Color3.fromRGB(100, 50, 220)
    l.TextSize          = 10
    l.Font              = Enum.Font.GothamBold
    l.TextXAlignment    = Enum.TextXAlignment.Left

    local sep = Instance.new("Frame", f)
    sep.Size            = UDim2.new(1, 0, 0, 1)
    sep.Position        = UDim2.new(0, 0, 1, -1)
    sep.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
end

local function toggle(label, cfgKey, cb)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.LayoutOrder       = O()
    row.Parent            = Scroll

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(1, -56, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(200, 200, 210)
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size            = UDim2.new(0, 42, 0, 20)
    track.Position        = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = CFG[cfgKey]
        and Color3.fromRGB(100, 50, 220)
        or  Color3.fromRGB(45, 45, 55)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = CFG[cfgKey]
        and UDim2.new(1, -17, 0.5, -7)
        or  UDim2.new(0, 3,   0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.Size              = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""

    btn.MouseButton1Click:Connect(function()
        CFG[cfgKey] = not CFG[cfgKey]
        local on = CFG[cfgKey]
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = on
                and Color3.fromRGB(100, 50, 220)
                or  Color3.fromRGB(45, 45, 55)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = on
                and UDim2.new(1, -17, 0.5, -7)
                or  UDim2.new(0, 3,   0.5, -7)
        }):Play()
        if cb then cb(on) end
    end)

    return track, knob
end

local function slider(label, cfgKey, min, max, cb)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 50)
    row.BackgroundTransparency = 1
    row.LayoutOrder       = O()
    row.Parent            = Scroll

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label .. ":  " .. CFG[cfgKey]
    lbl.TextColor3        = Color3.fromRGB(200, 200, 210)
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size            = UDim2.new(1, 0, 0, 5)
    track.Position        = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((CFG[cfgKey]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size            = UDim2.new(0, 12, 0, 12)
    thumb.Position        = UDim2.new((CFG[cfgKey]-min)/(max-min), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex          = 2
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local drag = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local rel = math.clamp(
            (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(min + rel * (max - min))
        CFG[cfgKey]    = val
        lbl.Text       = label .. ":  " .. val
        fill.Size      = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -6, 0.5, -6)
        if cb then cb(val) end
    end)
end

-- ── BUILD SECTIONS ────────────────────────────────────────────
section("🎯  aimbot")
toggle("Aimbot", "Aimbot")
toggle("Team Check", "TeamCheck")

section("❤️  combat")
toggle("God Mode", "GodMode")
toggle("Infinite Ammo", "InfAmmo")
toggle("No Recoil", "NoRecoil")

section("👟  movement")
toggle("Speed Hack", "Speed", function(on)
    local c = lp.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = on and CFG.SpeedVal or 16 end
end)
slider("Walk Speed", "SpeedVal", 16, 150, function(val)
    if CFG.Speed then
        local c = lp.Character if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = val end
    end
end)

-- ── DRAG ──────────────────────────────────────────────────────
local dragUI, dragStart, dragOrigin = false, nil, nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragUI     = true
        dragStart  = i.Position
        dragOrigin = Main.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragUI = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragUI then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = i.Position - dragStart
    Main.Position = UDim2.new(
        dragOrigin.X.Scale, dragOrigin.X.Offset + d.X,
        dragOrigin.Y.Scale, dragOrigin.Y.Offset + d.Y
    )
end)

-- ── MINIMIZE ──────────────────────────────────────────────────
local mini = false
MinBtn.MouseButton1Click:Connect(function()
    mini = not mini
    TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
        Size = mini
            and UDim2.new(0, 280, 0, 38)
            or  UDim2.new(0, 280, 0, 440)
    }):Play()
    MinBtn.Text = mini and "+" or "−"
end)

-- ── RIGHT SHIFT TOGGLE ────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        local show = not Main.Visible
        if show then
            Main.Visible = true
            Main.Size    = UDim2.new(0, 280, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = mini
                    and UDim2.new(0, 280, 0, 38)
                    or  UDim2.new(0, 280, 0, 440)
            }):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, 280, 0, 0)
            }):Play()
            task.delay(0.16, function() Main.Visible = false end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  GODMODE — Xeno layers
-- ══════════════════════════════════════════════════════════════
local lastPos = Vector3.new(0, 10, 0)
local godConn

local function startGod(char)
    if godConn then godConn:Disconnect() end
    local hum  = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not hum or not root then return end

    pcall(function()
        local mt = getrawmetatable(hum)
        setreadonly(mt, false)
        local old_ni = rawget(mt, "__newindex")
        mt.__newindex = function(t, k, v)
            if t == hum and k == "Health" and
               type(v) == "number" and v < hum.MaxHealth then
                return
            end
            if old_ni then old_ni(t, k, v) else rawset(t, k, v) end
        end
        setreadonly(mt, true)
    end)

    godConn = RunService.Heartbeat:Connect(function()
        if not CFG.GodMode then return end
        if not hum or not hum.Parent then return end
        if hum.MaxHealth < 100 then hum.MaxHealth = 100 end
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        if hum:GetState() == Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hum.Health > 0 and root.Parent then
            lastPos = root.Position
        end
    end)
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.15)
    startGod(char)
    task.wait(0.05)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0)) end
end)
if lp.Character then task.spawn(function() startGod(lp.Character) end) end

-- ══════════════════════════════════════════════════════════════
--  INFINITE AMMO
-- ══════════════════════════════════════════════════════════════
local ammoKW = {
    "ammo","magazine","mag","bullet","clip","round",
    "chamber","loaded","reserve","currentammo","shots","capacity"
}
local function isAmmoVal(n)
    local l = n:lower()
    for _, k in ipairs(ammoKW) do if l:find(k) then return true end end
    return false
end

local ammoConns = {}
local watched   = {}

local function hookTool(tool)
    if watched[tool] then return end
    watched[tool] = true
    local function tryH(v)
        if not (v:IsA("IntValue") or v:IsA("NumberValue")) then return end
        if not isAmmoVal(v.Name) then return end
        local mx = math.max(v.Value, 1)
        table.insert(ammoConns, v.Changed:Connect(function(nv)
            if not CFG.InfAmmo then return end
            if nv < mx then task.defer(function()
                if v and v.Parent then v.Value = mx end
            end)
            elseif nv > mx then mx = nv end
        end))
    end
    for _, v in ipairs(tool:GetDescendants()) do tryH(v) end
    table.insert(ammoConns, tool.DescendantAdded:Connect(function(v)
        task.wait(0.05) tryH(v)
    end))
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local nm = v.Name:lower()
            if nm:find("reload") or nm:find("ammo") or nm:find("refill") then
                task.spawn(function()
                    while tool and tool.Parent and CFG.InfAmmo do
                        pcall(function() v:FireServer() end)
                        task.wait(3)
                    end
                end)
            end
        end
    end
end

local function watchTools(char)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then hookTool(t) end
    end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then task.wait(0.05) hookTool(c) end
    end)
    lp.Backpack.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then task.wait(0.05) hookTool(c) end
    end)
end
if lp.Character then watchTools(lp.Character) end
lp.CharacterAdded:Connect(function(char)
    task.wait(0.15) watched = {}
    for _, c in ipairs(ammoConns) do c:Disconnect() end
    ammoConns = {} watchTools(char)
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════════════════════
local holding      = false
local locked       = nil
local velCache     = {}
local predictedPos = {}

local function isAlive(p)
    local c = p.Character if not c then return false end
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

RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        local c    = p.Character
        local head = c and c:FindFirstChild(CFG.AimPart)
        if not head then predictedPos[p] = nil continue end
        local now  = tick()
        local prev = velCache[p]
        velCache[p] = { pos = head.Position, t = now }
        if prev then
            local dt = now - prev.t
            if dt > 0 and dt < 0.5 then
                predictedPos[p] = head.Position +
                    (head.Position - prev.pos) / dt * (CFG.PredictMS / 1000)
            else
                predictedPos[p] = head.Position
            end
        else
            predictedPos[p] = head.Position
        end
    end
end)

local function getBest()
    local best, bd, bestP = nil, 9999, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and not sameTeam(p) then
            local c    = p.Character
            local head = c and c:FindFirstChild(CFG.AimPart)
            if head then
                local d = screenDist(head)
                if d < bd then best = head bd = d bestP = p end
            end
        end
    end
    return best, bestP
end

local bn = "x_" .. math.random(10000, 99999)
RunService:BindToRenderStep(bn, Enum.RenderPriority.Last.Value + 9999, function()
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if not CFG.Aimbot or not holding then locked = nil return end
    local head, owner = getBest()
    if not head or not owner or not isAlive(owner) then locked = nil return end
    locked = head
    cam.CFrame = CFrame.new(cam.CFrame.Position, predictedPos[owner] or head.Position)
end)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false locked = nil
    end
end)

-- ══════════════════════════════════════════════════════════════
--  NO RECOIL
-- ══════════════════════════════════════════════════════════════
local rfiring  = false
local smoothCF = cam.CFrame
local rb       = "r_" .. math.random(10000, 99999)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        rfiring  = true
        smoothCF = cam.CFrame
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then rfiring = false end
end)

RunService:BindToRenderStep(rb, Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.NoRecoil or not rfiring then smoothCF = cam.CFrame return end
    local cur    = cam.CFrame
    local dP     = math.asin(math.clamp(cur.LookVector.Y, -1, 1)) -
                   math.asin(math.clamp(smoothCF.LookVector.Y, -1, 1))
    if dP > 0.002 then
        cam.CFrame = CFrame.new(cur.Position) * CFrame.Angles(-dP, 0, 0) * cur
    end
    smoothCF = cam.CFrame
end)

-- ══════════════════════════════════════════════════════════════
--  SPEED
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.Speed then return end
    local c = lp.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    if h.WalkSpeed ~= CFG.SpeedVal then h.WalkSpeed = CFG.SpeedVal end
end)

-- ══════════════════════════════════════════════════════════════
--  CLEANUP
-- ══════════════════════════════════════════════════════════════
lp.CharacterAdded:Connect(function()
    holding = false locked = nil velCache = {} predictedPos = {}
end)
Players.PlayerRemoving:Connect(function(p)
    velCache[p] = nil predictedPos[p] = nil
end)
