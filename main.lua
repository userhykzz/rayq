-- Urban Reload | LOCK ONLY — stealth build, no ESP, no CoreGui
-- Executor: Synapse X / KRNL / Fluxus / Delta

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

local CFG = {
    AimPart   = "Head",
    TeamCheck = true,
    PredictMS = 80,
    GodMode   = true,
    InfAmmo   = true,
    NoRecoil  = true,
}

local holding  = false
local locked   = nil
local velCache = {}

-- ── UTILS ─────────────────────────────────────────────────────
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
    local best, bd = nil, 9999
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

-- ── AIMBOT — randomised bind name (anti-detect) ───────────────
local bindName = "cb_" .. tostring(math.random(100000, 999999))

RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value + 1, function()
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if not holding then locked = nil return end
    locked = getBest()
    if not locked then return end
    local owner = Players:GetPlayerFromCharacter(locked.Parent)
    if not owner or not isAlive(owner) then locked = nil return end
    cam.CFrame = CFrame.new(cam.CFrame.Position, getPredicted(locked))
end)

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

-- ── GODMODE ───────────────────────────────────────────────────
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

-- ── INFINITE AMMO ─────────────────────────────────────────────
local ammoKeywords = {"ammo","magazine","mag","bullet","clip","round","chamber","loaded"}
local function isAmmoVal(name)
    local low = name:lower()
    for _, k in ipairs(ammoKeywords) do if low:find(k) then return true end end
    return false
end

local ammoConns    = {}
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
    task.wait(0.1)
    watchedTools = {}
    for _, c in ipairs(ammoConns) do c:Disconnect() end
    ammoConns = {}
    watchTools(char)
end)

-- ── NO RECOIL ─────────────────────────────────────────────────
local recoilFiring = false
local smoothedCF   = cam.CFrame
local recoilBind   = "rc_" .. tostring(math.random(100000, 999999))

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

RunService:BindToRenderStep(recoilBind, Enum.RenderPriority.Camera.Value + 1, function()
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
    holding = false
    locked  = nil
    velCache = {}
end)
Players.PlayerRemoving:Connect(function(p)
    velCache[p] = nil
end)

-- ── RIGHT SHIFT TOGGLE GODMODE (no UI, no drawings) ──────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        CFG.GodMode = not CFG.GodMode
        -- silent toggle, no print (print ก็ detect ได้)
    end
end)
