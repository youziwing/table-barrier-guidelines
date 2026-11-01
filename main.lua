local lines = {}
for i = 1, 3 do
    local l = Drawing.new("Line")
    l.Color = Color3.fromRGB(255, 255, 255)
    l.Thickness = 3
    l.Visible = false
    lines[i] = l
end

local function draw(l, a, b)
    local s, e = nil, nil
    for i = 0, 40 do
        local q, v = WorldToScreen(a:Lerp(b, i / 40))
        if v then
            s = s or q
            e = q
        end
    end

    if s and e then
        l.From = s
        l.To = e
        l.Visible = true
    else
        l.Visible = false
    end
end

local function bounds(p)
    local best, dist = nil, math.huge
    local z = game.Workspace:FindFirstChild("TableZones")
    if z then
        for _, x in ipairs(z:GetChildren()) do
            if x.Name:find("TableBarrier") then
                local dx = x.Position.X - p.X
                local dz = x.Position.Z - p.Z
                local d = dx * dx + dz * dz
                if d < dist then
                    best = x
                    dist = d
                end
            end
        end
    end

    if not best then
        return nil
    end

    return best.Position.X - best.Size.X * 0.5 + 1.19,
        best.Position.X + best.Size.X * 0.5 - 1.19,
        best.Position.Z - best.Size.Z * 0.5 + 1.18,
        best.Position.Z + best.Size.Z * 0.5 - 1.18
end

local function wall(p, d, x1, x2, z1, z2)
    local tx = d.X > 0 and (x2 - p.X) / d.X or d.X < 0 and (x1 - p.X) / d.X or math.huge
    local tz = d.Z > 0 and (z2 - p.Z) / d.Z or d.Z < 0 and (z1 - p.Z) / d.Z or math.huge
    local a = tx > 0 and tx or math.huge
    local b = tz > 0 and tz or math.huge
    return math.min(a, b), a < b
end

game:GetService("RunService").RenderStepped:Connect(function()
    local v = game.Workspace:FindFirstChild("ClientVisuals")
    local g = v and v:FindFirstChild("Guideline")
    if not g then
        return
    end

    local o = g:FindFirstChild("ObjectStub")
    local c = g:FindFirstChild("CueStub")
    local ref = o and o.Position or c and c.Position
    local x1, x2, z1, z2
    if ref then
        x1, x2, z1, z2 = bounds(ref)
    end

    if not x1 then
        for _, l in ipairs(lines) do
            l.Visible = false
        end
        return
    end

    if o and o.Transparency < 1 and o.Position.Magnitude > 0 then
        local p = o.Position + o.CFrame.LookVector * (o.Size.Z * 0.5)
        local d = -o.CFrame.LookVector
        local t, x = wall(p, d, x1, x2, z1, z2)
        local h = p + d * t
        draw(lines[1], p, h)
        d = x and Vector3.new(-d.X, d.Y, d.Z) or Vector3.new(d.X, d.Y, -d.Z)
        local t2 = wall(h + d * 0.01, d, x1, x2, z1, z2)
        draw(lines[2], h, h + d * t2)
    else
        lines[1].Visible = false
        lines[2].Visible = false
    end

    if c and c.Transparency < 1 and c.Position.Magnitude > 0 then
        local p = c.Position + c.CFrame.LookVector * (c.Size.Z * 0.5)
        local d = -c.CFrame.LookVector
        local t = wall(p, d, x1, x2, z1, z2)
        draw(lines[3], p, p + d * t)
    else
        lines[3].Visible = false
    end
end)
