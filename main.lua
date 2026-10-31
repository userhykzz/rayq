-- github.com/userhykzz/scripts
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/userhykzz/scripts/main/main.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local lp               = Players.LocalPlayer
local mouse            = lp:GetMouse()

-- ── NOTIFY ───────────────────────────────────────────────────
local function notify(t, b)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=t, Text=b, Duration=3
        })
    end)
end

-- ════════════════════════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name             = "hykzz_ui"
sg.ResetOnSpawn     = false
sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset   = true
sg.Parent           = gethui and gethui() or lp:WaitForChild("PlayerGui")

-- main frame
local main = Instance.new("Frame")
main.Name            = "Main"
main.Size            = UDim2.new(0, 280, 0, 320)
main.Position        = UDim2.new(0, 40, 0, 120)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active          = true
main.Draggable       = true
main.Parent          = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color        = Color3.fromRGB(255, 60, 120)
Instance.new("UIStroke", main).Thickness    = 1.5

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 60, 120)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleFix = Instance.new("Frame")
titleFix.Size             = UDim2.new(1, 0, 0, 10)
titleFix.Position         = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(255, 60, 120)
titleFix.BorderSizePixel  = 0
titleFix.Parent           = titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size             = UDim2.new(1, -40, 1, 0)
titleLbl.Position         = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text             = "⚡ hykzz scripts"
titleLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize         = 15
titleLbl.Font             = Enum.Font.GothamBold
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.Parent           = titleBar

-- close btn
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 80)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.white
closeBtn.TextSize         = 13
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- content scroll
local content = Instance.new("ScrollingFrame")
content.Size              = UDim2.new(1, 0, 1, -40)
content.Position          = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.BorderSizePixel   = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 120)
content.CanvasSize        = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent            = main

local layout = Instance.new("UIListLayout")
layout.Padding            = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent             = content
Instance.new("UIPadding", content).PaddingTop = UDim.new(0, 8)

-- ── WIDGET BUILDERS ─────────────────────────────────────────
local function makeSection(name)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0, 256, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "── " .. name .. " ──"
    lbl.TextColor3        = Color3.fromRGB(255, 60, 120)
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = content
    return lbl
end

local function makeToggle(label, default, callback)
    local state = default

    local row = Instance.new("Frame")
    row.Size              = UDim2.new(0, 256, 0, 34)
    row.BackgroundColor3  = Color3.fromRGB(25, 25, 32)
    row.BorderSizePixel   = 0
    row.Parent            = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -56, 1, 0)
    lbl.Position          = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(220, 220, 220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, 36, 0, 20)
    pill.Position         = UDim2.new(1, -46, 0.5, -10)
    pill.BackgroundColor3 = state and Color3.fromRGB(255,60,120) or Color3.fromRGB(60,60,70)
    pill.BorderSizePixel  = 0
    pill.Parent           = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.white
    knob.BorderSizePixel  = 0
    knob.Parent           = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.Parent            = row
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, ti,
            {BackgroundColor3 = state and Color3.fromRGB(255,60,120) or Color3.fromRGB(60,60,70)}
        ):Play()
        TweenService:Create(knob, ti,
            {Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}
        ):Play()
        callback(state)
    end)

    return function() return state end
end

local function makeSlider(label, min, max, default, callback)
    local val = default

    local wrap = Instance.new("Frame")
    wrap.Size             = UDim2.new(0, 256, 0, 50)
    wrap.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    wrap.BorderSizePixel  = 0
    wrap.Parent           = content
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -10, 0, 20)
    lbl.Position          = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label .. ": " .. tostring(val)
    lbl.TextColor3        = Color3.fromRGB(220,220,220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = wrap

    local track = Instance.new("Frame")
    track.Size            = UDim2.new(0, 228, 0, 6)
    track.Position        = UDim2.new(0, 14, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(50,50,60)
    track.BorderSizePixel = 0
    track.Parent          = wrap
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((val-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,60,120)
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame")
    thumb.Size            = UDim2.new(0,14,0,14)
    thumb.AnchorPoint     = Vector2.new(0.5,0.5)
    thumb.Position        = UDim2.new((val-min)/(max-min),0,0.5,0)
    thumb.BackgroundColor3 = Color3.white
    thumb.BorderSizePixel = 0
    thumb.Parent          = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function update(x)
        local abs = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local pct = math.clamp((x - abs) / w, 0, 1)
        val       = math.floor(min + (max-min)*pct)
        fill.Size = UDim2.new(pct,0,1,0)
        thumb.Position = UDim2.new(pct,0,0.5,0)
        lbl.Text  = label .. ": " .. tostring(val)
        callback(val)
    end

    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ════════════════════════════════════════════════════════════
--  BUILD UI
-- ════════════════════════════════════════════════════════════

-- FLY section
makeSection("✈  FLY")

local flyEnabled = false
local flySpeed   = 60
local bv, bg

local function enableFly()
    local char = lp.Character if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 1e4 bg.CFrame = hrp.CFrame bg.Parent = hrp
end
local function disableFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

makeToggle("Fly  [F]", false, function(s)
    flyEnabled = s
    if s then enableFly() else disableFly() end
    notify("Fly", s and "ON ✓" or "OFF")
end)

makeSlider("Speed", 10, 200, 60, function(v) flySpeed = v end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        if flyEnabled then enableFly() else disableFly() end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled then return end
    local char = lp.Character if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not bv or not bg then return end
    local cf = Camera.CFrame local vel = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then vel += cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then vel -= cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then vel -= cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then vel += cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then vel += Vector3.yAxis  end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.yAxis  end
    bv.Velocity = vel * flySpeed bg.CFrame = cf
end)

-- AIMBOT section
makeSection("🎯  AIMBOT")

local AB = { on=true, smooth=0.18, fov=120, hitpart="Head", teamcheck=true }

local circle
pcall(function()
    circle = Drawing.new("Circle")
    circle.Visible=true circle.Radius=AB.fov
    circle.Color=Color3.fromRGB(255,60,120)
    circle.Thickness=1.5 circle.Filled=false circle.Transparency=1
end)

makeToggle("Aimbot  [Q]", true, function(s)
    AB.on = s
    if circle then circle.Visible = s end
    notify("Aimbot", s and "ON ✓" or "OFF")
end)

makeToggle("Team Check", true, function(s) AB.teamcheck = s end)

makeSlider("FOV", 30, 400, 120, function(v)
    AB.fov = v
    if circle then circle.Radius = v end
end)

makeSlider("Smooth (x10)", 1, 30, 2, function(v)
    AB.smooth = v / 10
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.Q then
        AB.on = not AB.on
        if circle then circle.Visible = AB.on end
        notify("Aimbot", AB.on and "ON ✓" or "OFF")
    end
end)

local function enemy(p)
    if not AB.teamcheck then return true end
    return p.Team ~= lp.Team
end
local function alive(p)
    local c = p.Character if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end
local function getTarget(cx, cy)
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and alive(p) and enemy(p) then
            local part = p.Character:FindFirstChild(AB.hitpart)
                      or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local d = Vector2.new(sp.X-cx, sp.Y-cy).Magnitude
                    if d < AB.fov and d < bd then best,bd = part,d end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if circle then
        local vp = Camera.ViewportSize
        circle.Position = Vector2.new(vp.X/2, vp.Y/2)
    end
    if not AB.on then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local vp = Camera.ViewportSize
    local t  = getTarget(vp.X/2, vp.Y/2)
    if t then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, t.Position), AB.smooth
        )
    end
end)

-- MISC section
makeSection("⚙  MISC")

makeToggle("Anti-AFK", true, function(s)
    if s then
        local vrs = game:GetService("VirtualUser")
        lp.Idled:Connect(function() vrs:Button2Down(Vector2.zero, Camera.CFrame) task.wait(1) vrs:Button2Up(Vector2.zero, Camera.CFrame) end)
    end
    notify("Anti-AFK", s and "ON ✓" or "OFF")
end)

makeToggle("FullBright", false, function(s)
    local lighting = game:GetService("Lighting")
    lighting.Brightness    = s and 2 or 1
    lighting.ClockTime     = s and 14 or lighting.ClockTime
    lighting.FogEnd        = s and 1e6 or lighting.FogEnd
    lighting.GlobalShadows = not s
    notify("FullBright", s and "ON ✓" or "OFF")
end)

-- hide toggle [RightControl]
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

print("[userhykzz] UI loaded — RCtrl to hide")
notify("userhykzz", "UI loaded ✓  |  RCtrl = hide")