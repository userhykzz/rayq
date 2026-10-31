-- Urban Reload | RMB-hold fire gate + head aimlock
-- Executor: Synapse X / KRNL / Fluxus / any UNC-compliant exec
-- Place in autoexec or paste into executor console

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp            = Players.LocalPlayer
local cam           = workspace.CurrentCamera
local mouse         = lp:GetMouse()

-- ── CONFIG ──────────────────────────────────────────────────────────────────
local CFG = {
    AimPart      = "Head",          -- bone to lock onto
    AimFOV       = 120,             -- screen-radius FOV circle (px)
    AimSmooth    = 0.18,            -- lerp factor (0=instant, 1=never moves)
    TeamCheck    = true,            -- skip same-team targets
    WallCheck    = true,            -- skip occluded targets
    FireKey      = Enum.UserInputType.MouseButton1,  -- left click fires
    AimKey       = Enum.UserInputType.MouseButton2,  -- right hold = aim+gate
}
-- ────────────────────────────────────────────────────────────────────────────

local holding  = false   -- RMB state
local locked   = nil     -- current target BasePart

-- ── UTILS ───────────────────────────────────────────────────────────────────
local function getChar(p)
    return p and p.Character
end

local function getRootAndHead(p)
    local c = getChar(p)
    if not c then return nil, nil end
    return c:FindFirstChild("HumanoidRootPart"),
           c:FindFirstChild(CFG.AimPart) or c:FindFirstChild("Head")
end

local function isAlive(p)
    local c = getChar(p)
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function sameTeam(p)
    if not CFG.TeamCheck then return false end
    return p.Team and p.Team == lp.Team
end

local function visible(part)
    if not CFG.WallCheck then return true end
    local origin = cam.CFrame.Position
    local dir    = (part.Position - origin)
    local ray    = RaycastParams.new()
    ray.FilterDescendantsInstances = {getChar(lp), workspace.Terrain}
    ray.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(origin, dir, ray)
    if not res then return true end
    -- hit something belonging to target's character → visible
    local target_char = part.Parent
    return res.Instance:IsDescendantOf(target_char)
end

local function screenDist(part)
    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end
    local cx = cam.ViewportSize.X / 2
    local cy = cam.ViewportSize.Y / 2
    return math.sqrt((sp.X - cx)^2 + (sp.Y - cy)^2)
end

-- ── TARGET PICKER ────────────────────────────────────────────────────────────
local function getBestTarget()
    local best, bestDist = nil, CFG.AimFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and not sameTeam(p) then
            local _, head = getRootAndHead(p)
            if head then
                local d = screenDist(head)
                if d < bestDist and visible(head) then
                    best     = head
                    bestDist = d
                end
            end
        end
    end
    return best
end

-- ── AIMBOT LOOP ──────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    if not holding then
        locked = nil
        return
    end

    locked = getBestTarget()
    if not locked then return end

    -- validate target still alive
    local owner = Players:GetPlayerFromCharacter(locked.Parent)
    if not owner or not isAlive(owner) then
        locked = nil
        return
    end

    local targetCF = CFrame.lookAt(cam.CFrame.Position, locked.Position)
    cam.CFrame = cam.CFrame:Lerp(targetCF, CFG.AimSmooth)
end)

-- ── INPUT HANDLING ───────────────────────────────────────────────────────────
-- RMB down → start hold
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
end)

-- RMB up → release hold, clear lock
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        holding  = false
        locked   = nil
    end
end)

-- LMB → only processes if RMB is held (Roblox handles actual fire,
-- this hook can feed additional logic / autoclicker if the game gates it)
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == CFG.FireKey then
        if not holding then
            -- swallow / do nothing — fire gated behind RMB hold
            -- if the game's own fire listener is client-side you can
            -- feed a fake input here; most Roblox shooters are server-auth
            -- so the camera lock is what actually lands the hit
        end
    end
end)

-- ── OPTIONAL: FOV CIRCLE INDICATOR ──────────────────────────────────────────
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness  = 1
fovCircle.NumSides   = 64
fovCircle.Radius     = CFG.AimFOV
fovCircle.Filled     = false
fovCircle.Color      = Color3.fromRGB(255, 255, 255)
fovCircle.Visible    = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(
        cam.ViewportSize.X / 2,
        cam.ViewportSize.Y / 2
    )
    fovCircle.Visible = holding
end)

-- cleanup on character respawn
lp.CharacterAdded:Connect(function()
    holding = false
    locked  = nil
end)

print("[UR] script loaded — hold RMB to aim-lock head, LMB to fire")
