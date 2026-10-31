-- hyk | Urban Reload — AIMBOT ONLY + fixed lock
-- Right Shift = toggle UI
-- Executor: Xeno (xeno.now)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local lp   = Players.LocalPlayer
local cam  = workspace.CurrentCamera
local mouse = lp:GetMouse()

local CFG = {
    Aimbot     = true,
    AimPart    = "Head",
    TeamCheck  = true,
    PredictMS  = 80,
    SwitchBias = 80,
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
Main.Name             = "Main"
Main.Size             = UDim2.new(0, 280, 0, 180)
Main.Position         = UDim2.new(0, 20, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Main.Parent           = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", Main)
ms.Color     = Color3.fromRGB(100, 50, 220)
ms.Thickness = 1.5

local TB = Instance.new("Frame")
TB.Size             = UDim2.new(1, 0, 0, 38)
TB.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
TB.BorderSizePixel  = 0
TB.Parent           = Main
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 10)
local tbfix = Instance.new("Frame")
tbfix.Size             = UDim2.new(1, 0, 0, 10)
tbfix.Position         = UDim2.new(0, 0, 1, -10)
tbfix.BackgroundColor3 = Color3.fromRGB(100, 50, 220)
tbfix.BorderSizePixel  = 0
tbfix.Parent           = TB

local TL = Instance.new("TextLabel")
TL.Size               = UDim2.new(1, -50, 1, 0)
TL.Position           = UDim2.new(0, 12, 0, 0)
TL.BackgroundTransparency = 1
TL.Text               = "⚡  hyk aimbot  •  RShift"
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
ULL.Padding   = UDim.new(0, 0)
ULL.SortOrder = Enum.SortOrder.LayoutOrder

local UP = Instance.new("UIPadding", Scroll)
UP.PaddingTop    = UDim.new(0, 6)
UP.PaddingLeft   = UDim.new(0, 10)
UP.PaddingRight  = UDim.new(0, 10)
UP.PaddingBottom = UDim.new(0, 8)

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
end

section("🎯  aimbot")
toggle("Aimbot",     "Aimbot")
toggle("Team Check", "TeamCheck")

-- drag
local dragUI, dragStart, dragOrigin = false, nil, nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragUI = true dragStart = i.Position dragOrigin = Main.Position
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
        dragOrigin.Y.Scale, dragOrigin.Y.Offset + d.Y)
end)

-- minimize
local mini = false
MinBtn.MouseButton1Click:Connect(function()
    mini = not mini
    TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
        Size = mini and UDim2.new(0,280,0,38) or UDim2.new(0,280,0,180)
    }):Play()
    MinBtn.Text = mini and "+" or "−"
end)

-- Right Shift toggle
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        local show = not Main.Visible
        if show then
            Main.Visible = true
            Main.Size    = UDim2.new(0, 280, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = mini and UDim2.new(0,280,0,38) or UDim2.new(0,280,0,180)
            }):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0,280,0,0)
            }):Play()
            task.delay(0.16, function() Main.Visible = false end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT — fixed: mouse crosshair + anti-flicker bias
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

-- วัดจาก mouse position + Z check
local function screenDist(part)
    local sp, on = cam:WorldToViewportPoint(part.Position)
    if not on or sp.Z < 0 then return math.huge end
    return math.sqrt((sp.X - mouse.X)^2 + (sp.Y - mouse.Y)^2)
end

-- predict ใน Heartbeat
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

-- getBest: bias เป้าเดิม ไม่กระโดด
local function getBest()
    local best, bd, bestP = nil, math.huge, nil

    if locked then
        local owner = Players:GetPlayerFromCharacter(locked.Parent)
        if owner and isAlive(owner) and not sameTeam(owner) then
            local d = screenDist(locked)
            if d < math.huge then
                best  = locked
                bd    = d - CFG.SwitchBias
                bestP = owner
            end
        else
            locked = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and not sameTeam(p) then
            local c    = p.Character
            local head = c and c:FindFirstChild(CFG.AimPart)
            if head then
                local d = screenDist(head)
                if d < bd then
                    best  = head
                    bd    = d
                    bestP = p
                end
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

lp.CharacterAdded:Connect(function()
    holding = false locked = nil velCache = {} predictedPos = {}
end)
Players.PlayerRemoving:Connect(function(p)
    velCache[p] = nil predictedPos[p] = nil
end)
