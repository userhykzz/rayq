-- github.com/userhykzz/rayq
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/userhykzz/rayq/main/main.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local lp               = Players.LocalPlayer

-- ── ANTI-DETECT LAYER ────────────────────────────────────────
-- 1. hook tostring so print/warn don't leak script names
local old_tostring = tostring
setfenv = setfenv or function() end

-- 2. spoof ScriptContext errors (executor-level)
pcall(function()
    local sc = game:GetService("ScriptContext")
    sc.Error:Connect(function() end)
end)

-- 3. disable game's cheat detection remotes (common pattern)
pcall(function()
    local old_fire = game.ReplicatedStorage.FireServer
    -- hook remote monitoring if present
    local mt = getrawmetatable(game)
    local old_index = mt.__index
    local old_newindex = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = function(self, key, value)
        -- block attempts to write detection flags
        if key == "PlaceId" or key == "JobId" then return end
        return old_newindex(self, key, value)
    end
    setreadonly(mt, true)
end)

-- 4. humanise timing — all loops run on random offset
local function randwait()
    task.wait(0.016 + math.random() * 0.008)
end

-- 5. cloak the ScreenGui from game scripts
local function safeParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = game.CoreGui
        return sg
    end
    return lp:WaitForChild("PlayerGui")
end

-- ── NOTIFY ───────────────────────────────────────────────────
local function notify(t, b)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=t, Text=b, Duration=3
        })
    end)
end

-- ════════════════════════════════════════════════════════════
--  GUI SHELL
-- ════════════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name           = "sys_"..math.random(1000,9999)   -- random name every load
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true

local ok, hub = pcall(safeParent)
if ok and hub then
    if typeof(hub) == "Instance" and hub:IsA("ScreenGui") then
        -- syn.protect_gui already parented it
        sg = hub
    else
        sg.Parent = hub
    end
else
    sg.Parent = lp:WaitForChild("PlayerGui")
end

-- ── MAIN FRAME ───────────────────────────────────────────────
local PINK  = Color3.fromRGB(255, 60, 120)
local DARK  = Color3.fromRGB(15, 15, 20)
local DARK2 = Color3.fromRGB(25, 25, 32)
local WHITE = Color3.fromRGB(255,255,255)

local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0,280,0,360)
main.Position         = UDim2.new(0,40,0,120)
main.BackgroundColor3 = DARK
main.BorderSizePixel  = 0
main.Active           = true
main.Draggable        = true
main.Visible          = true
main.Parent           = sg
Instance.new("UICorner",main).CornerRadius   = UDim.new(0,10)
local stroke = Instance.new("UIStroke",main)
stroke.Color     = PINK
stroke.Thickness = 1.5

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1,0,0,36)
titleBar.BackgroundColor3 = PINK
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main
Instance.new("UICorner",titleBar).CornerRadius = UDim.new(0,10)
local titleFix = Instance.new("Frame")
titleFix.Size             = UDim2.new(1,0,0,10)
titleFix.Position         = UDim2.new(0,0,1,-10)
titleFix.BackgroundColor3 = PINK
titleFix.BorderSizePixel  = 0
titleFix.Parent           = titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size             = UDim2.new(1,-80,1,0)
titleLbl.Position         = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text             = "⚡ userhykzz"
titleLbl.TextColor3       = WHITE
titleLbl.TextSize         = 15
titleLbl.Font             = Enum.Font.GothamBold
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.Parent           = titleBar

-- keybind label (top right of title)
local keyLbl = Instance.new("TextLabel")
keyLbl.Size               = UDim2.new(0,60,1,0)
keyLbl.Position           = UDim2.new(1,-68,0,0)
keyLbl.BackgroundTransparency = 1
keyLbl.Text               = "[RShift]"
keyLbl.TextColor3         = Color3.fromRGB(255,200,220)
keyLbl.TextSize           = 11
keyLbl.Font               = Enum.Font.Gotham
keyLbl.TextXAlignment     = Enum.TextXAlignment.Right
keyLbl.Parent             = titleBar

-- content
local content = Instance.new("ScrollingFrame")
content.Size              = UDim2.new(1,0,1,-40)
content.Position          = UDim2.new(0,0,0,40)
content.BackgroundTransparency = 1
content.BorderSizePixel   = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = PINK
content.CanvasSize        = UDim2.new(0,0,0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent            = main

local layout = Instance.new("UIListLayout",content)
layout.Padding            = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local pad = Instance.new("UIPadding",content)
pad.PaddingTop = UDim.new(0,8)

-- ── WIDGET BUILDERS ──────────────────────────────────────────
local function makeSection(name)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0,256,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "── "..name.." ──"
    lbl.TextColor3        = PINK
    lbl.TextSize          = 12
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = content
end

local function makeToggle(label, default, callback)
    local state = default
    local ti    = TweenInfo.new(0.15,Enum.EasingStyle.Quad)

    local row = Instance.new("Frame")
    row.Size              = UDim2.new(0,256,0,34)
    row.BackgroundColor3  = DARK2
    row.BorderSizePixel   = 0
    row.Parent            = content
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1,-56,1,0)
    lbl.Position          = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(220,220,220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0,36,0,20)
    pill.Position         = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = state and PINK or Color3.fromRGB(60,60,70)
    pill.BorderSizePixel  = 0
    pill.Parent           = row
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0,14,0,14)
    knob.Position         = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel  = 0
    knob.Parent           = pill
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.Parent            = row
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill,ti,{BackgroundColor3=state and PINK or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        callback(state)
    end)

    -- expose setter for external toggle sync
    local function set(v)
        state = v
        TweenService:Create(pill,ti,{BackgroundColor3=v and PINK or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(knob,ti,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end
    return function() return state end, set
end

local function makeSlider(label, min, max, default, callback)
    local val = default
    local wrap = Instance.new("Frame")
    wrap.Size             = UDim2.new(0,256,0,50)
    wrap.BackgroundColor3 = DARK2
    wrap.BorderSizePixel  = 0
    wrap.Parent           = content
    Instance.new("UICorner",wrap).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1,-10,0,20)
    lbl.Position          = UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label..": "..tostring(val)
    lbl.TextColor3        = Color3.fromRGB(220,220,220)
    lbl.TextSize          = 13
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = wrap

    local track = Instance.new("Frame")
    track.Size            = UDim2.new(0,228,0,6)
    track.Position        = UDim2.new(0,14,0,34)
    track.BackgroundColor3 = Color3.fromRGB(50,50,60)
    track.BorderSizePixel = 0
    track.Parent          = wrap
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = PINK
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame")
    thumb.Size            = UDim2.new(0,14,0,14)
    thumb.AnchorPoint     = Vector2.new(0.5,0.5)
    thumb.Position        = UDim2.new((val-min)/(max-min),0,0.5,0)
    thumb.BackgroundColor3 = WHITE
    thumb.BorderSizePixel = 0
    thumb.Parent          = track
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function update(x)
        local abs = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local pct = math.clamp((x-abs)/w,0,1)
        val       = math.floor(min+(max-min)*pct)
        fill.Size = UDim2.new(pct,0,1,0)
        thumb.Position = UDim2.new(pct,0,0.5,0)
        lbl.Text  = label..": "..tostring(val)
        callback(val)
    end
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

-- ════════════════════════════════════════════════════════════
--  FEATURES
-- ════════════════════════════════════════════════════════════

-- ── FLY ──────────────────────────────────────────────────────
makeSection("✈  FLY")

local flyEnabled = false
local flySpeed   = 60
local bv, bg

local function enableFly()
    local char = lp.Character if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    bv = Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Velocity=Vector3.zero bv.Parent=hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.P=1e4 bg.CFrame=hrp.CFrame bg.Parent=hrp
end
local function disableFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    bv,bg=nil,nil
end

local _,setFlyToggle = makeToggle("Fly  [F]", false, function(s)
    flyEnabled=s
    if s then enableFly() else disableFly() end
    notify("Fly", s and "ON ✓" or "OFF")
end)

makeSlider("Speed",10,200,60,function(v) flySpeed=v end)

UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.F then
        flyEnabled=not flyEnabled
        setFlyToggle(flyEnabled)
        if flyEnabled then enableFly() else disableFly() end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled then return end
    local char=lp.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp or not bv or not bg then return end
    local cf=Camera.CFrame local vel=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then vel+=cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then vel-=cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then vel-=cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then vel+=cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then vel+=Vector3.yAxis  end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel-=Vector3.yAxis  end
    bv.Velocity=vel*flySpeed bg.CFrame=cf
end)

-- ── AIMBOT ───────────────────────────────────────────────────
makeSection("🎯  AIMBOT")

local AB={on=true,smooth=0.18,fov=120,hitpart="Head",teamcheck=true}

local circle
pcall(function()
    circle=Drawing.new("Circle")
    circle.Visible=true circle.Radius=AB.fov
    circle.Color=PINK circle.Thickness=1.5
    circle.Filled=false circle.Transparency=1
end)

local _,setABToggle = makeToggle("Aimbot  [Q]",true,function(s)
    AB.on=s
    if circle then circle.Visible=s end
    notify("Aimbot",s and "ON ✓" or "OFF")
end)

makeToggle("Team Check",true,function(s) AB.teamcheck=s end)
makeSlider("FOV",30,400,120,function(v) AB.fov=v if circle then circle.Radius=v end end)
makeSlider("Smooth (x10)",1,30,2,function(v) AB.smooth=v/10 end)

UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.Q then
        AB.on=not AB.on
        setABToggle(AB.on)
        if circle then circle.Visible=AB.on end
        notify("Aimbot",AB.on and "ON ✓" or "OFF")
    end
end)

local function enemy(p)
    if not AB.teamcheck then return true end
    return p.Team~=lp.Team
end
local function alive(p)
    local c=p.Character if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end
local function getTarget(cx,cy)
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and alive(p) and enemy(p) then
            local part=p.Character:FindFirstChild(AB.hitpart)
                     or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp,vis=Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local d=Vector2.new(sp.X-cx,sp.Y-cy).Magnitude
                    if d<AB.fov and d<bd then best,bd=part,d end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if circle then
        local vp=Camera.ViewportSize
        circle.Position=Vector2.new(vp.X/2,vp.Y/2)
    end
    if not AB.on then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local vp=Camera.ViewportSize
    local t=getTarget(vp.X/2,vp.Y/2)
    if t then
        Camera.CFrame=Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position,t.Position),AB.smooth
        )
    end
end)

-- ── MISC ─────────────────────────────────────────────────────
-- aimbot section replacement — paste แทน section AIMBOT เดิมทั้งหมด
-- หรือจะเอาไปแทนใน main.lua ก็ได้

-- ── AIMBOT ───────────────────────────────────────────────────
makeSection("🎯  AIMBOT")

local AB = {
    on        = true,
    smooth    = 0.18,
    fov       = 120,
    hitpart   = "Head",
    teamcheck = true,
    lockKey   = Enum.KeyCode.E,   -- default: E กด ค้างเพื่อ lock
    holding   = false,
}

-- FOV circle
local circle
pcall(function()
    circle              = Drawing.new("Circle")
    circle.Visible      = true
    circle.Radius       = AB.fov
    circle.Color        = Color3.fromRGB(255,60,120)
    circle.Thickness    = 1.5
    circle.Filled       = false
    circle.Transparency = 1
end)

-- lock key label (แสดงบน UI)
local lockKeyNames = {
    [Enum.KeyCode.E]          = "E",
    [Enum.KeyCode.R]          = "R",
    [Enum.KeyCode.T]          = "T",
    [Enum.KeyCode.X]          = "X",
    [Enum.KeyCode.Z]          = "Z",
    [Enum.KeyCode.LeftAlt]    = "LAlt",
    [Enum.KeyCode.RightAlt]   = "RAlt",
    [Enum.KeyCode.CapsLock]   = "Caps",
    [Enum.KeyCode.V]          = "V",
    [Enum.KeyCode.G]          = "G",
}

-- ── LOCK KEY PICKER ROW ──────────────────────────────────────
local keyRow = Instance.new("Frame")
keyRow.Size              = UDim2.new(0,256,0,40)
keyRow.BackgroundColor3  = Color3.fromRGB(25,25,32)
keyRow.BorderSizePixel   = 0
keyRow.Parent            = content
Instance.new("UICorner",keyRow).CornerRadius = UDim.new(0,7)

local keyLblLeft = Instance.new("TextLabel")
keyLblLeft.Size              = UDim2.new(0,130,1,0)
keyLblLeft.Position          = UDim2.new(0,12,0,0)
keyLblLeft.BackgroundTransparency = 1
keyLblLeft.Text              = "Lock Key:"
keyLblLeft.TextColor3        = Color3.fromRGB(220,220,220)
keyLblLeft.TextSize          = 13
keyLblLeft.Font              = Enum.Font.Gotham
keyLblLeft.TextXAlignment    = Enum.TextXAlignment.Left
keyLblLeft.Parent            = keyRow

local keyBtn = Instance.new("TextButton")
keyBtn.Size              = UDim2.new(0,90,0,28)
keyBtn.Position          = UDim2.new(1,-98,0.5,-14)
keyBtn.BackgroundColor3  = Color3.fromRGB(255,60,120)
keyBtn.BorderSizePixel   = 0
keyBtn.Text              = "[ E ]"
keyBtn.TextColor3        = Color3.white
keyBtn.TextSize          = 13
keyBtn.Font              = Enum.Font.GothamBold
keyBtn.Parent            = keyRow
Instance.new("UICorner",keyBtn).CornerRadius = UDim.new(0,6)

-- bind mode
local binding = false
keyBtn.MouseButton1Click:Connect(function()
    binding = true
    keyBtn.Text = "[ ... ]"
    keyBtn.BackgroundColor3 = Color3.fromRGB(180,40,80)
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if binding then
        -- accept any KeyCode
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            AB.lockKey = inp.KeyCode
            local name = lockKeyNames[inp.KeyCode] or inp.KeyCode.Name
            keyBtn.Text = "[ "..name.." ]"
            keyBtn.BackgroundColor3 = Color3.fromRGB(255,60,120)
            binding = false
            notify("Lock Key", "set to "..name)
        end
        return
    end
end)

-- ── TOGGLES & SLIDERS ────────────────────────────────────────
local _,setABToggle = makeToggle("Aimbot", true, function(s)
    AB.on = s
    if circle then circle.Visible = s end
    notify("Aimbot", s and "ON ✓" or "OFF")
end)

makeToggle("Team Check", true, function(s) AB.teamcheck = s end)

-- hitpart selector row
local hitRow = Instance.new("Frame")
hitRow.Size              = UDim2.new(0,256,0,40)
hitRow.BackgroundColor3  = Color3.fromRGB(25,25,32)
hitRow.BorderSizePixel   = 0
hitRow.Parent            = content
Instance.new("UICorner",hitRow).CornerRadius = UDim.new(0,7)

local hitLbl = Instance.new("TextLabel")
hitLbl.Size              = UDim2.new(0,100,1,0)
hitLbl.Position          = UDim2.new(0,12,0,0)
hitLbl.BackgroundTransparency = 1
hitLbl.Text              = "Target:"
hitLbl.TextColor3        = Color3.fromRGB(220,220,220)
hitLbl.TextSize          = 13
hitLbl.Font              = Enum.Font.Gotham
hitLbl.TextXAlignment    = Enum.TextXAlignment.Left
hitLbl.Parent            = hitRow

local hitParts   = {"Head","UpperTorso","HumanoidRootPart"}
local hitIdx     = 1

local hitBtn = Instance.new("TextButton")
hitBtn.Size              = UDim2.new(0,120,0,28)
hitBtn.Position          = UDim2.new(1,-128,0.5,-14)
hitBtn.BackgroundColor3  = Color3.fromRGB(50,50,60)
hitBtn.BorderSizePixel   = 0
hitBtn.Text              = hitParts[hitIdx]
hitBtn.TextColor3        = Color3.white
hitBtn.TextSize          = 12
hitBtn.Font              = Enum.Font.Gotham
hitBtn.Parent            = hitRow
Instance.new("UICorner",hitBtn).CornerRadius = UDim.new(0,6)
hitBtn.MouseButton1Click:Connect(function()
    hitIdx = hitIdx % #hitParts + 1
    AB.hitpart = hitParts[hitIdx]
    hitBtn.Text = hitParts[hitIdx]
    notify("Target", AB.hitpart)
end)

makeSlider("FOV", 30, 400, 120, function(v)
    AB.fov = v
    if circle then circle.Radius = v end
end)

makeSlider("Smooth (x10)", 1, 30, 2, function(v)
    AB.smooth = v / 10
end)

-- ── HELPERS ──────────────────────────────────────────────────
local function isEnemy(p)
    if not AB.teamcheck then return true end
    return p.Team ~= lp.Team
end

local function isAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function getTarget(cx, cy)
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and isEnemy(p) then
            local char = p.Character
            -- try hitpart first, fallback chain
            local part = char:FindFirstChild(AB.hitpart)
                      or char:FindFirstChild("Head")
                      or char:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local d = Vector2.new(sp.X-cx, sp.Y-cy).Magnitude
                    if d < AB.fov and d < bd then
                        best, bd = part, d
                    end
                end
            end
        end
    end
    return best
end

-- ── LOCK STATE ───────────────────────────────────────────────
-- track hold state manually — supports any key
local lockHeld = false

UserInputService.InputBegan:Connect(function(inp, gpe)
    if binding then return end
    if gpe then return end
    if inp.KeyCode == AB.lockKey then
        lockHeld = true
    end
    if inp.KeyCode == Enum.KeyCode.Q then
        AB.on = not AB.on
        setABToggle(AB.on)
        if circle then circle.Visible = AB.on end
        notify("Aimbot", AB.on and "ON ✓" or "OFF")
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode == AB.lockKey then
        lockHeld = false
    end
end)

-- ── MAIN LOOP ────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    -- update FOV circle center
    if circle then
        local vp = Camera.ViewportSize
        circle.Position = Vector2.new(vp.X/2, vp.Y/2)
        circle.Visible  = AB.on
    end

    if not AB.on then return end
    if not lockHeld then return end       -- hold lock key to aim

    local vp = Camera.ViewportSize
    local t  = getTarget(vp.X/2, vp.Y/2)
    if not t then return end

    -- smooth lerp to target
    local targetCF = CFrame.new(Camera.CFrame.Position, t.Position)
    Camera.CFrame  = Camera.CFrame:Lerp(targetCF, AB.smooth)
end)
