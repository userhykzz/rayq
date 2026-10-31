-- Urban Reload | HARDLOCK + GODMODE + ESP
-- Executor: Synapse X / KRNL / Fluxus / Delta
-- Paste in console or autoexec

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ── CONFIG ───────────────────────────────────────────────────────────────────
local CFG = {
    -- aimbot
    AimPart    = "Head",
    FOV        = 150,
    Smooth     = 0,
    TeamCheck  = true,
    WallCheck  = false,
    PredictMS  = 80,
    -- godmode
    GodMode    = true,
    RegenRate  = 100,          -- HP regen per second when damaged
    -- visuals
    FOVVisible  = true,
    FOVColor    = Color3.fromRGB(255, 60, 60),
    LockedColor = Color3.fromRGB(60, 255, 60),
    ESPBox      = true,
    ESPHealth   = true,
    ESPName     = true,
}
-- ─────────────────────────────────────────────────────────────────────────────

local holding = false
local locked  = nil
local velCache = {}

-- ── GODMODE ───────────────────────────────────────────────────────────────────
-- Method 1: Humanoid.Health property lock via RenderStepped
-- Method 2: block damage events coming from server via LocalScript hooks
-- Method 3: re-apply max health every frame (works on most Roblox shooters)

local godConn = nil

local function startGodMode()
    if godConn then godConn:Disconnect() end
    godConn = RunService.Heartbeat:Connect(function()
        local c = lp.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- lock health to max every heartbeat
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end

        -- re-lock MaxHealth in case server tries to reduce it
        if hum.MaxHealth < 100 then
            hum.MaxHealth = 100
        end

        -- block death state
        if hum:GetState() == Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

local function stopGodMode()
    if godConn then
        godConn:Disconnect()
        godConn = nil
    end
end

-- start on load + respawn
if CFG.GodMode then
    startGodMode()
    lp.CharacterAdded:Connect(function()
        task.wait(0.1)  -- wait one frame for humanoid to init
        startGodMode()
    end)
end

-- toggle godmode with F5
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F5 then
        CFG.GodMode = not CFG.GodMode
        if CFG.GodMode then
            startGodMode()
            print("[UR] GodMode ON")
        else
            stopGodMode()
            print("[UR] GodMode OFF")
        end
    end
end)

-- ── UTILS ─────────────────────────────────────────────────────────────────────
local function isAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function sameTeam(p)
    return CFG.TeamCheck and p.Team ~= nil and p.Team == lp.Team
end

local function visible(part)
    if not CFG.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { lp.Character, workspace.Terrain }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local res    = workspace:Raycast(origin, part.Position - origin, params)
    return not res or res.Instance:IsDescendantOf(part.Parent)
end

local function screenPos(worldPos)
    local sp, on = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

local function screenDist(part)
    local sp, on = cam:WorldToViewportPoint(part.Position)
    if not on then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - cam.ViewportSize / 2).Magnitude
end

-- ── PREDICTION ────────────────────────────────────────────────────────────────
local function getPredicted(head)
    local p   = Players:GetPlayerFromCharacter(head.Parent)
    if not p then return head.Position end
    local now = tick()
    local prev = velCache[p]
    velCache[p] = { pos = head.Position, t = now }
    if not prev then return head.Position end
    local dt = now - prev.t
    if dt <= 0 or dt > 0.5 then return head.Position end
    local vel = (head.Position - prev.pos) / dt
    return head.Position + vel * (CFG.PredictMS / 1000)
end

-- ── TARGET PICKER ─────────────────────────────────────────────────────────────
local function getBest()
    local best, bd = nil, CFG.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and not sameTeam(p) then
            local c    = p.Character
            local head = c and c:FindFirstChild(CFG.AimPart)
            if head then
                local d = screenDist(head)
                if d < bd and visible(head) then
                    best = head
                    bd   = d
                end
            end
        end
    end
    return best
end

-- ── AIMBOT LOOP ───────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    if not holding then locked = nil return end
    locked = getBest()
    if not locked then return end
    local owner = Players:GetPlayerFromCharacter(locked.Parent)
    if not owner or not isAlive(owner) then locked = nil return end
    cam.CFrame = CFrame.new(cam.CFrame.Position, getPredicted(locked))
end)

-- ── INPUT ─────────────────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
        locked  = nil
    end
end)

-- ── ESP DRAWINGS ──────────────────────────────────────────────────────────────
local espData = {}

local function newESP(p)
    local d = {}
    if CFG.ESPBox then
        d.box = Drawing.new("Square")
        d.box.Thickness  = 1.5
        d.box.Filled     = false
        d.box.Color      = Color3.fromRGB(255, 60, 60)
        d.box.Visible    = false
    end
    if CFG.ESPName then
        d.name = Drawing.new("Text")
        d.name.Size     = 13
        d.name.Center   = true
        d.name.Outline  = true
        d.name.Color    = Color3.fromRGB(255, 255, 255)
        d.name.Visible  = false
    end
    if CFG.ESPHealth then
        d.hpbg = Drawing.new("Square")
        d.hpbg.Thickness = 1
        d.hpbg.Filled    = true
        d.hpbg.Color     = Color3.fromRGB(0, 0, 0)
        d.hpbg.Visible   = false

        d.hpbar = Drawing.new("Square")
        d.hpbar.Thickness = 1
        d.hpbar.Filled    = true
        d.hpbar.Color     = Color3.fromRGB(60, 255, 60)
        d.hpbar.Visible   = false
    end
    espData[p] = d
end

local function removeESP(p)
    local d = espData[p]
    if not d then return end
    for _, v in pairs(d) do v:Remove() end
    espData[p] = nil
end

Players.PlayerAdded:Connect(function(p) newESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then newESP(p) end
end

-- ── FOV + LOCK DOT ────────────────────────────────────────────────────────────
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides  = 128
fovCircle.Radius    = 80
fovCircle.Filled    = false
fovCircle.Color     = CFG.FOVColor
fovCircle.Visible   = false

local lockDot = Drawing.new("Circle")
lockDot.Thickness = 0
lockDot.NumSides  = 32
lockDot.Radius    = 4
lockDot.Filled    = true
lockDot.Color     = CFG.LockedColor
lockDot.Visible   = false

-- ── ESP + VISUALS LOOP ────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local cx = cam.ViewportSize.X / 2
    local cy = cam.ViewportSize.Y / 2

    -- FOV circle
    fovCircle.Position = Vector2.new(cx, cy)
    fovCircle.Visible  = CFG.FOVVisible and holding
    if locked then
        fovCircle.Color = CFG.LockedColor
        local dp, on = screenPos(locked.Position)
        lockDot.Position = dp
        lockDot.Visible  = on
    else
        fovCircle.Color  = CFG.FOVColor
        lockDot.Visible  = false
    end

    -- per-player ESP
    for p, d in pairs(espData) do
        local c   = p.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local root= c and c:FindFirstChild("HumanoidRootPart")
        local head= c and c:FindFirstChild("Head")

        local isTarget = locked and locked.Parent == c
        local alive    = hum and hum.Health > 0

        if alive and root and head and not sameTeam(p) then
            -- project bounding box (root ± half player height)
            local topPos    = head.Position + Vector3.new(0, 0.7, 0)
            local botPos    = root.Position - Vector3.new(0, 2.8, 0)
            local top2d, on1 = screenPos(topPos)
            local bot2d, on2 = screenPos(botPos)

            local show = on1 or on2

            -- box
            if d.box then
                if show then
                    local h  = math.abs(bot2d.Y - top2d.Y)
                    local w  = h * 0.45
                    d.box.Size     = Vector2.new(w, h)
                    d.box.Position = Vector2.new(top2d.X - w / 2, top2d.Y)
                    d.box.Color    = isTarget and CFG.LockedColor or Color3.fromRGB(255, 60, 60)
                end
                d.box.Visible = show
            end

            -- name
            if d.name then
                d.name.Text     = p.Name
                d.name.Position = Vector2.new(top2d.X, top2d.Y - 15)
                d.name.Color    = isTarget and CFG.LockedColor or Color3.fromRGB(255, 255, 255)
                d.name.Visible  = show
            end

            -- health bar (left side of box)
            if d.hpbg and d.hpbar then
                if show then
                    local h     = math.abs(bot2d.Y - top2d.Y)
                    local w     = h * 0.45
                    local barH  = h
                    local barW  = 4
                    local barX  = top2d.X - w / 2 - barW - 2
                    local barY  = top2d.Y
                    local hpRat = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local fillH = barH * hpRat

                    -- lerp color green→yellow→red
                    local hpColor = Color3.fromRGB(
                        math.floor(255 * (1 - hpRat)),
                        math.floor(255 * hpRat),
                        0
                    )

                    d.hpbg.Size     = Vector2.new(barW, barH)
                    d.hpbg.Position = Vector2.new(barX, barY)

                    d.hpbar.Size     = Vector2.new(barW, fillH)
                    d.hpbar.Position = Vector2.new(barX, barY + (barH - fillH))
                    d.hpbar.Color    = hpColor
                end
                d.hpbg.Visible  = show
                d.hpbar.Visible = show
            end
        else
            -- hide all
            if d.box   then d.box.Visible   = false end
            if d.name  then d.name.Visible  = false end
            if d.hpbg  then d.hpbg.Visible  = false end
            if d.hpbar then d.hpbar.Visible = false end
        end
    end
end)

-- ── CLEANUP ───────────────────────────────────────────────────────────────────
lp.CharacterAdded:Connect(function()
    holding  = false
    locked   = nil
    velCache = {}
    task.wait(0.1)
    if CFG.GodMode then startGodMode() end
end)

Players.PlayerRemoving:Connect(function(p)
    velCache[p] = nil
    removeESP(p)
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(" [UR] FULL KIT LOADED")
print(" RMB hold  = instant headlock")
print(" LMB       = fire")
print(" F5        = toggle godmode")
print(" GodMode   = " .. tostring(CFG.GodMode))
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
