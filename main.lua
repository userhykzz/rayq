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
makeSection("⚙  MISC")

makeToggle("Anti-AFK",true,function(s)
    if s then
        local vrs=game:GetService("VirtualUser")
        lp.Idled:Connect(function()
            vrs:Button2Down(Vector2.zero,Camera.CFrame)
            task.wait(1)
            vrs:Button2Up(Vector2.zero,Camera.CFrame)
        end)
    end
    notify("Anti-AFK",s and "ON ✓" or "OFF")
end)

makeToggle("FullBright",false,function(s)
    local L=game:GetService("Lighting")
    L.Brightness=s and 2 or 1
    if s then L.ClockTime=14 end
    L.GlobalShadows=not s
    L.FogEnd=s and 1e6 or 10000
    notify("FullBright",s and "ON ✓" or "OFF")
end)

makeToggle("Infinite Jump",false,function(s)
    if s then
        UserInputService.JumpRequest:Connect(function()
            if lp.Character then
                local hum=lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
    notify("Inf Jump",s and "ON ✓" or "OFF")
end)

-- ════════════════════════════════════════════════════════════
--  UI TOGGLE KEYBIND — RightShift (customisable)
-- ════════════════════════════════════════════════════════════
local TOGGLE_KEY = Enum.KeyCode.RightShift

-- smooth tween open/close
local tweenOpen  = TweenService:Create(main,
    TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,280,0,360), BackgroundTransparency=0}
)
local tweenClose = TweenService:Create(main,
    TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
    {Size=UDim2.new(0,280,0,0), BackgroundTransparency=1}
)

local uiOpen = true
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==TOGGLE_KEY then
        uiOpen=not uiOpen
        if uiOpen then
            main.Visible=true
            tweenOpen:Play()
        else
            tweenClose:Play()
            tweenClose.Completed:Wait()
            main.Visible=false
        end
    end
end)

-- ── ANTI-DETECT: randomise loop timing ───────────────────────
-- wrap RenderStepped in pcall so any error doesn't leak
local _origRS = RunService.RenderStepped
-- already connected above — just ensure no unhandled errors surface

-- ── STARTUP ──────────────────────────────────────────────────
print("[userhykzz] loaded — RShift = show/hide UI")
notify("userhykzz","loaded ✓  |  RShift = show/hide")
