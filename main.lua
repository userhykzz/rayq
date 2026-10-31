-- github.com/userhykzz/rayq
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/userhykzz/rayq/main/main.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local lp               = Players.LocalPlayer

local function notify(t,b)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=b,Duration=3})
    end)
end

-- ── ANTI-DETECT ──────────────────────────────────────────────
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt,false)
    local old_ni = mt.__newindex
    mt.__newindex = function(self,key,value)
        if key=="PlaceId" or key=="JobId" then return end
        return old_ni(self,key,value)
    end
    setreadonly(mt,true)
end)
pcall(function()
    game:GetService("ScriptContext").Error:Connect(function() end)
end)

-- ── SAFE PARENT ──────────────────────────────────────────────
local function safeParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local sg=Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent=game.CoreGui
        return sg
    end
    return lp:WaitForChild("PlayerGui")
end

-- ════════════════════════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════════════════════════
local PINK  = Color3.fromRGB(255,60,120)
local DARK  = Color3.fromRGB(15,15,20)
local DARK2 = Color3.fromRGB(25,25,32)
local WHITE = Color3.white

local sg = Instance.new("ScreenGui")
sg.Name="sys_"..math.random(1000,9999)
sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset=true
local ok,hub=pcall(safeParent)
if ok and hub then
    if typeof(hub)=="Instance" and hub:IsA("ScreenGui") then sg=hub
    else sg.Parent=hub end
else sg.Parent=lp:WaitForChild("PlayerGui") end

local main=Instance.new("Frame")
main.Name="Main"
main.Size=UDim2.new(0,290,0,420)
main.Position=UDim2.new(0,40,0,100)
main.BackgroundColor3=DARK
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
main.Visible=true
main.Parent=sg
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",main)
stroke.Color=PINK stroke.Thickness=1.5

-- titlebar
local tb=Instance.new("Frame")
tb.Size=UDim2.new(1,0,0,36)
tb.BackgroundColor3=PINK
tb.BorderSizePixel=0
tb.Parent=main
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,10)
local tbfix=Instance.new("Frame")
tbfix.Size=UDim2.new(1,0,0,10)
tbfix.Position=UDim2.new(0,0,1,-10)
tbfix.BackgroundColor3=PINK
tbfix.BorderSizePixel=0
tbfix.Parent=tb

local tlbl=Instance.new("TextLabel")
tlbl.Size=UDim2.new(1,-80,1,0)
tlbl.Position=UDim2.new(0,12,0,0)
tlbl.BackgroundTransparency=1
tlbl.Text="⚡ userhykzz"
tlbl.TextColor3=WHITE
tlbl.TextSize=15
tlbl.Font=Enum.Font.GothamBold
tlbl.TextXAlignment=Enum.TextXAlignment.Left
tlbl.Parent=tb

local klbl=Instance.new("TextLabel")
klbl.Size=UDim2.new(0,70,1,0)
klbl.Position=UDim2.new(1,-76,0,0)
klbl.BackgroundTransparency=1
klbl.Text="[RShift]"
klbl.TextColor3=Color3.fromRGB(255,200,220)
klbl.TextSize=11
klbl.Font=Enum.Font.Gotham
klbl.TextXAlignment=Enum.TextXAlignment.Right
klbl.Parent=tb

-- content
local content=Instance.new("ScrollingFrame")
content.Size=UDim2.new(1,0,1,-40)
content.Position=UDim2.new(0,0,0,40)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.ScrollBarImageColor3=PINK
content.CanvasSize=UDim2.new(0,0,0,0)
content.AutomaticCanvasSize=Enum.AutomaticSize.Y
content.Parent=main
local layout=Instance.new("UIListLayout",content)
layout.Padding=UDim.new(0,6)
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local pad=Instance.new("UIPadding",content)
pad.PaddingTop=UDim.new(0,8)

-- ── WIDGETS ──────────────────────────────────────────────────
local function makeSection(name)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0,266,0,20)
    l.BackgroundTransparency=1
    l.Text="── "..name.." ──"
    l.TextColor3=PINK l.TextSize=12
    l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=content
end

local function makeToggle(label,default,cb)
    local state=default
    local ti=TweenInfo.new(0.15,Enum.EasingStyle.Quad)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(0,266,0,34)
    row.BackgroundColor3=DARK2
    row.BorderSizePixel=0 row.Parent=content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-56,1,0) l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1 l.Text=label
    l.TextColor3=Color3.fromRGB(220,220,220) l.TextSize=13
    l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,36,0,20)
    pill.Position=UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3=state and PINK or Color3.fromRGB(60,60,70)
    pill.BorderSizePixel=0 pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=WHITE knob.BorderSizePixel=0 knob.Parent=pill
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1
    btn.Text="" btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,ti,{BackgroundColor3=state and PINK or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        cb(state)
    end)
    local function set(v)
        state=v
        TweenService:Create(pill,ti,{BackgroundColor3=v and PINK or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(knob,ti,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end
    return function() return state end, set
end

local function makeSlider(label,min,max,default,cb)
    local val=default
    local wrap=Instance.new("Frame")
    wrap.Size=UDim2.new(0,266,0,50)
    wrap.BackgroundColor3=DARK2 wrap.BorderSizePixel=0 wrap.Parent=content
    Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-10,0,20) l.Position=UDim2.new(0,12,0,4)
    l.BackgroundTransparency=1 l.Text=label..": "..val
    l.TextColor3=Color3.fromRGB(220,220,220) l.TextSize=13
    l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=wrap
    local track=Instance.new("Frame")
    track.Size=UDim2.new(0,238,0,6) track.Position=UDim2.new(0,14,0,34)
    track.BackgroundColor3=Color3.fromRGB(50,50,60)
    track.BorderSizePixel=0 track.Parent=wrap
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3=PINK fill.BorderSizePixel=0 fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame")
    thumb.Size=UDim2.new(0,14,0,14) thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new((val-min)/(max-min),0,0.5,0)
    thumb.BackgroundColor3=WHITE thumb.BorderSizePixel=0 thumb.Parent=track
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local dragging=false
    local function update(x)
        local pct=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        val=math.floor(min+(max-min)*pct)
        fill.Size=UDim2.new(pct,0,1,0)
        thumb.Position=UDim2.new(pct,0,0.5,0)
        l.Text=label..": "..val cb(val)
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

local function makeCycleBtn(label, options, default, cb)
    local idx = default or 1
    local row=Instance.new("Frame")
    row.Size=UDim2.new(0,266,0,38)
    row.BackgroundColor3=DARK2
    row.BorderSizePixel=0 row.Parent=content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0,110,1,0) l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1 l.Text=label
    l.TextColor3=Color3.fromRGB(220,220,220) l.TextSize=13
    l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=row
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,130,0,26)
    btn.Position=UDim2.new(1,-138,0.5,-13)
    btn.BackgroundColor3=Color3.fromRGB(50,50,60)
    btn.BorderSizePixel=0
    btn.Text=options[idx]
    btn.TextColor3=WHITE btn.TextSize=12
    btn.Font=Enum.Font.Gotham
    btn.Parent=row
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        idx=idx%#options+1
        btn.Text=options[idx]
        cb(options[idx],idx)
    end)
    return btn
end

-- ════════════════════════════════════════════════════════════
--  FLY
-- ════════════════════════════════════════════════════════════
makeSection("✈  FLY")
local flyOn=false local flySpeed=60 local bv,bg
local function enableFly()
    local c=lp.Character if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart") if not h then return end
    bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Velocity=Vector3.zero bv.Parent=h
    bg=Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.P=1e4 bg.CFrame=h.CFrame bg.Parent=h
end
local function disableFly()
    if bv then bv:Destroy() end if bg then bg:Destroy() end bv,bg=nil,nil
end
local _,setFly=makeToggle("Fly  [F]",false,function(s)
    flyOn=s if s then enableFly() else disableFly() end
    notify("Fly",s and "ON ✓" or "OFF")
end)
makeSlider("Speed",10,200,60,function(v) flySpeed=v end)
UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.F then
        flyOn=not flyOn setFly(flyOn)
        if flyOn then enableFly() else disableFly() end
    end
end)
RunService.RenderStepped:Connect(function()
    if not flyOn then return end
    local c=lp.Character if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    if not h or not bv or not bg then return end
    local cf=Camera.CFrame local v=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then v+=cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then v-=cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then v-=cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then v+=cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then v+=Vector3.yAxis  end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v-=Vector3.yAxis  end
    bv.Velocity=v*flySpeed bg.CFrame=cf
end)

-- ════════════════════════════════════════════════════════════
--  AIMBOT
-- ════════════════════════════════════════════════════════════
makeSection("🎯  AIMBOT")

local AB={
    on=true,
    smooth=0.18,
    fov=120,
    hitpart="Head",
    teamcheck=true,
    lockKey=Enum.KeyCode.E,
    pitchOffset=0,      -- ขยับขึ้นลง หน่วย studs
}
local lockHeld=false
local binding=false

-- FOV circle
local circle
pcall(function()
    circle=Drawing.new("Circle")
    circle.Visible=true circle.Radius=AB.fov
    circle.Color=PINK circle.Thickness=1.5
    circle.Filled=false circle.Transparency=1
end)

-- ── aimbot toggle ────────────────────────────────────────────
local _,setAB=makeToggle("Aimbot  [Q]",true,function(s)
    AB.on=s
    if circle then circle.Visible=s end
    notify("Aimbot",s and "ON ✓" or "OFF")
end)

makeToggle("Team Check",true,function(s) AB.teamcheck=s end)

-- ── target part cycle ────────────────────────────────────────
makeCycleBtn("Target Part",{"Head","UpperTorso","HumanoidRootPart"},1,function(v)
    AB.hitpart=v
    notify("Target",v)
end)

-- ── pitch offset (ขยับจุดเล็งขึ้น/ลง) ───────────────────────
makeSlider("Head Offset",  -5, 5, 0, function(v)
    AB.pitchOffset = v
end)

makeSlider("FOV",30,400,120,function(v)
    AB.fov=v if circle then circle.Radius=v end
end)

makeSlider("Smooth (x10)",1,30,2,function(v) AB.smooth=v/10 end)

-- ── lock key binder ──────────────────────────────────────────
local keyRow=Instance.new("Frame")
keyRow.Size=UDim2.new(0,266,0,40)
keyRow.BackgroundColor3=DARK2
keyRow.BorderSizePixel=0 keyRow.Parent=content
Instance.new("UICorner",keyRow).CornerRadius=UDim.new(0,7)

local kl=Instance.new("TextLabel")
kl.Size=UDim2.new(0,130,1,0) kl.Position=UDim2.new(0,12,0,0)
kl.BackgroundTransparency=1 kl.Text="Lock Key (hold):"
kl.TextColor3=Color3.fromRGB(220,220,220) kl.TextSize=12
kl.Font=Enum.Font.Gotham kl.TextXAlignment=Enum.TextXAlignment.Left
kl.Parent=keyRow

local keyBindBtn=Instance.new("TextButton")
keyBindBtn.Size=UDim2.new(0,100,0,28)
keyBindBtn.Position=UDim2.new(1,-108,0.5,-14)
keyBindBtn.BackgroundColor3=PINK
keyBindBtn.BorderSizePixel=0
keyBindBtn.Text="[ E ]"
keyBindBtn.TextColor3=WHITE keyBindBtn.TextSize=13
keyBindBtn.Font=Enum.Font.GothamBold
keyBindBtn.Parent=keyRow
Instance.new("UICorner",keyBindBtn).CornerRadius=UDim.new(0,6)

keyBindBtn.MouseButton1Click:Connect(function()
    binding=true
    keyBindBtn.Text="[ ??? ]"
    keyBindBtn.BackgroundColor3=Color3.fromRGB(180,40,80)
    notify("Lock Key","กดปุ่มที่ต้องการ...")
end)

-- ── helpers ──────────────────────────────────────────────────
local function isEnemy(p)
    if not AB.teamcheck then return true end
    return p.Team~=lp.Team
end
local function isAlive(p)
    local c=p.Character if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end
local function getTarget(cx,cy)
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and isAlive(p) and isEnemy(p) then
            local char=p.Character
            local part=char:FindFirstChild(AB.hitpart)
                     or char:FindFirstChild("Head")
                     or char:FindFirstChild("HumanoidRootPart")
            if part then
                -- apply pitch offset — ยกตำแหน่งขึ้นตาม offset
                local aimPos=part.Position+Vector3.new(0,AB.pitchOffset,0)
                local sp,vis=Camera:WorldToViewportPoint(aimPos)
                if vis then
                    local d=Vector2.new(sp.X-cx,sp.Y-cy).Magnitude
                    if d<AB.fov and d<bd then best,bd=part,d end
                end
            end
        end
    end
    return best
end

-- ── input ────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(i,g)
    -- key binder ก่อน
    if binding then
        if i.UserInputType==Enum.UserInputType.Keyboard then
            AB.lockKey=i.KeyCode
            local n=i.KeyCode.Name
            keyBindBtn.Text="[ "..n.." ]"
            keyBindBtn.BackgroundColor3=PINK
            binding=false
            notify("Lock Key","set → "..n)
        end
        return
    end
    if g then return end
    if i.KeyCode==AB.lockKey then lockHeld=true end
    if i.KeyCode==Enum.KeyCode.Q then
        AB.on=not AB.on setAB(AB.on)
        if circle then circle.Visible=AB.on end
        notify("Aimbot",AB.on and "ON ✓" or "OFF")
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode==AB.lockKey then lockHeld=false end
end)

-- ── aim loop ─────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    if circle then
        local vp=Camera.ViewportSize
        circle.Position=Vector2.new(vp.X/2,vp.Y/2)
        circle.Visible=AB.on
    end
    if not AB.on or not lockHeld then return end
    local vp=Camera.ViewportSize
    local t=getTarget(vp.X/2,vp.Y/2)
    if not t then return end
    local aimPos=t.Position+Vector3.new(0,AB.pitchOffset,0)
    local targetCF=CFrame.new(Camera.CFrame.Position,aimPos)
    Camera.CFrame=Camera.CFrame:Lerp(targetCF,AB.smooth)
end)

-- ════════════════════════════════════════════════════════════
--  MISC
-- ════════════════════════════════════════════════════════════
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
                local h=lp.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
    notify("Inf Jump",s and "ON ✓" or "OFF")
end)

-- ── UI toggle RightShift ──────────────────────────────────────
local uiOpen=true
local twOpen=TweenService:Create(main,TweenInfo.new(0.2,Enum.EasingStyle.Quad),
    {Size=UDim2.new(0,290,0,420)})
local twClose=TweenService:Create(main,TweenInfo.new(0.15,Enum.EasingStyle.Quad),
    {Size=UDim2.new(0,290,0,0)})

UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        uiOpen=not uiOpen
        if uiOpen then
            main.Visible=true twOpen:Play()
        else
            twClose:Play()
            twClose.Completed:Wait()
            main.Visible=false
        end
    end
end)

notify("userhykzz","loaded ✓  |  RShift = show/hide")
print("[userhykzz] ready")
