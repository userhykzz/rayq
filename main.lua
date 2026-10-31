-- Urban Reload | FULL FIX — stealth, no ESP, no UI, no print
-- Executor: Synapse X / KRNL / Fluxus / Delta

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

local CFG = {
    AimPart   = "Head",
    TeamCheck = true,
    PredictMS = 80,
    GodMode   = true,
    InfAmmo   = true,
    NoRecoil  = true,
    Speed     = false,
    SpeedVal  = 32,
}

local holding  = false
local locked   = nil
local velCache = {}

-- ══════════════════════════════════════════════════════════════
--  GODMODE — 4 layers
-- ══════════════════════════════════════════════════════════════
local lastPos  = Vector3.new(0, 10, 0)
local godConn

local function startGod(char)
    if godConn then godConn:Disconnect() end

    local hum  = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not hum or not root then return end

    -- Layer 1: metatable __newindex block Health reduction
    local ok, mt = pcall(getrawmetatable, hum)
    if ok and mt then
        local ok2 = pcall(setreadonly, mt, false)
        if ok2 then
            local old_ni = rawget(mt, "__newindex")
            mt.__newindex = function(t, k, v)
                if t == hum and k == "Health" then
                    -- allow increase, block decrease
                    if type(v) == "number" and v < hum.MaxHealth then
                        return
                    end
                end
                if old_ni then return old_ni(t, k, v)
                else rawset(t, k, v) end
            end
            pcall(setreadonly, mt, true)
        end
    end

    -- Layer 2: TakeDamage hook
    local ok3, oldTD = pcall(function()
        return hookfunction(hum.TakeDamage, function() return end)
    end)
    -- (only fires if exec supports hookfunction)

    -- Layer 3: Heartbeat force HP
    godConn = RunService.Heartbeat:Connect(function()
        if not CFG.GodMode then return end
        if not hum or not hum.Parent then return end
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        if hum.MaxHealth < 100 then hum.MaxHealth = 100 end
        -- block dead state
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        -- Layer 4: track last alive pos for teleport fallback
        if hum.Health > 0 then
            lastPos = root.Position
        end
    end)
end

-- Layer 4: respawn teleport กลับจุดเดิม
lp.CharacterAdded:Connect(function(char)
    task.wait(0.15)
    startGod(char)
    -- teleport กลับทันทีหลัง respawn
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0))
    end
end)

if lp.Character then
    task.spawn(function() startGod(lp.Character) end)
end

-- ══════════════════════════════════════════════════════════════
--  INFINITE AMMO — remote intercept + value hook
-- ══════════════════════════════════════════════════════════════
local ammoKeywords = {
    "ammo","magazine","mag","bullet","clip",
    "round","chamber","loaded","reserve","currentammo",
    "shots","capacity"
}

local function isAmmoVal(name)
    local low = name:lower()
    for _, k in ipairs(ammoKeywords) do
        if low:find(k) then return true end
    end
    return false
end

local ammoConns    = {}
local watchedTools = {}

local function hookTool(tool)
    if watchedTools[tool] then return end
    watchedTools[tool] = true

    -- hook existing values
    local function tryHook(v)
        if not (v:IsA("IntValue") or v:IsA("NumberValue")) then return end
        if not isAmmoVal(v.Name) then return end
        local maxV = math.max(v.Value, 1)
        local c = v.Changed:Connect(function(nv)
            if not CFG.InfAmmo then return end
            if nv < maxV then
                task.defer(function()
                    if v and v.Parent then v.Value = maxV end
                end)
            elseif nv > maxV then
                maxV = nv
            end
        end)
        table.insert(ammoConns, c)
    end

    for _, v in ipairs(tool:GetDescendants()) do tryHook(v) end

    -- watch late-added values
    local dc = tool.DescendantAdded:Connect(function(v)
        task.wait(0.05)
        tryHook(v)
    end)
    table.insert(ammoConns, dc)

    -- also try RemoteEvent intercept for server-side ammo
    -- hook FireServer on any remote inside tool
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local nm = v.Name:lower()
            if nm:find("reload") or nm:find("ammo") or nm:find("refill") then
                -- auto-fire reload remote every 3s
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
    task.wait(0.15)
    watchedTools = {}
    for _, c in ipairs(ammoConns) do c:Disconnect() end
    ammoConns = {}
    watchTools(char)
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT — fix stutter (แยก lock กับ predict ออกจากกัน)
-- ══════════════════════════════════════════════════════════════
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

-- predict แยกออกมา — อัพเดท velCache ใน Heartbeat
-- ไม่ให้ prediction ดึง frame ใน RenderStepped
local predictedPos = {}

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
                local vel = (head.Position - prev.pos) / dt
                predictedPos[p] = head.Position + vel * (CFG.PredictMS / 1000)
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

local bindName = "x_" .. tostring(math.random(10000,99999))

RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value + 9999, function()
    -- force cam type ทุก frame
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end

    if not holding then locked = nil return end

    local head, owner = getBest()
    if not head or not owner then locked = nil return end
    if not isAlive(owner) then locked = nil return end

    locked = head

    -- ใช้ predictedPos ที่คำนวณใน Heartbeat แทน — ไม่ stutter
    local aimPos = predictedPos[owner] or head.Position

    -- snap ตรง ไม่มี lerp
    cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos)
end)

-- ── INPUT ─────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
    -- Right Shift toggle godmode
    if inp.KeyCode == Enum.KeyCode.RightShift then
        CFG.GodMode = not CFG.GodMode
    end
    -- F7 toggle speed
    if inp.KeyCode == Enum.KeyCode.F7 then
        CFG.Speed = not CFG.Speed
        if not CFG.Speed then
            local c = lp.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 16 end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
        locked  = nil
    end
end)

-- ── SPEED ──────────────────────────────────────────────────────
-- ใช้ Heartbeat set WalkSpeed — ไม่ค้าง ไม่ stutter
RunService.Heartbeat:Connect(function()
    if not CFG.Speed then return end
    local c = lp.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    -- เซ็ต WalkSpeed เฉพาะเมื่อค่าเปลี่ยน — ลด server call
    if h.WalkSpeed ~= CFG.SpeedVal then
        h.WalkSpeed = CFG.SpeedVal
    end
end)

-- ── NO RECOIL ─────────────────────────────────────────────────
local recoilFiring = false
local smoothedCF   = cam.CFrame
local rcBind       = "r_" .. tostring(math.random(10000,99999))

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        recoilFiring = true
        smoothedCF   = cam.CFrame
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        recoilFiring = false
    end
end)

RunService:BindToRenderStep(rcBind, Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.NoRecoil or not recoilFiring then
        smoothedCF = cam.CFrame return
    end
    local cur    = cam.CFrame
    local dPitch = math.asin(math.clamp(cur.LookVector.Y, -1, 1)) -
                   math.asin(math.clamp(smoothedCF.LookVector.Y, -1, 1))
    if dPitch > 0.002 then
        cam.CFrame = CFrame.new(cur.Position) *
            CFrame.Angles(-dPitch, 0, 0) * cur
    end
    smoothedCF = cam.CFrame
end)

-- ── CLEANUP ───────────────────────────────────────────────────
lp.CharacterAdded:Connect(function()
    holding    = false
    locked     = nil
    velCache   = {}
    predictedPos = {}
end)
Players.PlayerRemoving:Connect(function(p)
    velCache[p]     = nil
    predictedPos[p] = nil
end)
