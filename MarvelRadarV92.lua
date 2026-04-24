-- [ MARVEL RADAR V92 - INTEGRATED EXECUTION ] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local BooleanService = game:GetService("TweenService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ NEW INTEGRATED GLOBALS ]]
_G.InfJump = false

-- [[ INFINITE JUMP LOGIC ]]
-- INTEGRATED FROM YOUR SNIPPET: NO TOUCHING/TWEAKING
UIS.JumpRequest:Connect(function()
    if _G.InfJump then
        LP.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- [[ CLICK SOUND SYSTEM ]]
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://12221967"
ClickSound.Volume = 0.5
ClickSound.Parent = workspace

-- [[ NEON PULSE ENGINE ]]
local function ApplyNeonPulse(stroke, glowStroke, speed, intensity)
    speed = speed or 2
    intensity = intensity or 0.25
    RunService.RenderStepped:Connect(function()
        local t = tick() * speed
        local pulse = (math.sin(t) + 1) / 2
        if stroke then
            stroke.Thickness = 2 + (pulse * 1.5)
            stroke.Transparency = 0.2 - (pulse * 0.15)
        end
        if glowStroke then
            glowStroke.Thickness = 6 + (pulse * 6)
            glowStroke.Transparency = 0.7 - (pulse * intensity)
        end
    end)
end

-- [[ UPGRADED PulseButton FUNCTION ]]
local function PulseButton(btn)
    local origSize = btn.Size
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = _G.MainColor
    flash.BackgroundTransparency = 0.7
    flash.Parent = btn
    Instance.new("UICorner", flash)
    TweenService:Create(flash, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    game:GetService("Debris"):AddItem(flash, 0.2)
    TweenService:Create(btn, TweenInfo.new(0.1), {Size = origSize + UDim2.new(0, 4, 0, 4)}):Play()
    task.delay(0.1, function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = origSize}):Play()
    end)
end

-- 1. CLEANUP & PERSISTENCE
local ParentGui = (gethui and gethui()) or CoreGui
if ParentGui:FindFirstChild("MarvelRadarV92") then ParentGui.MarvelRadarV92:Destroy() end
if workspace:FindFirstChild("ShieldPart") then workspace.ShieldPart:Destroy() end
if workspace:FindFirstChild("ShieldScanner") then workspace.ShieldScanner:Destroy() end
if workspace:FindFirstChild("ShieldRing1") then workspace.ShieldRing1:Destroy() end 
if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end

local ScreenGui = Instance.new("ScreenGui", ParentGui)
ScreenGui.Name = "MarvelRadarV92"; 
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

_G.HB = false; _G.BLHB = false; _G.Aim = false; _G.ESP = false; _G.TR = false; _G.ZeroCD = false; 
_G.Rainbow = false; _G.Labels = false; _G.TargetOnly = false; _G.Size = 15; _G.BLSize = 15; _G.KillBtn = false
_G.AutoFriend = false; _G.Noclip = false; _G.ProxShield = false; _G.Invis = false; 
_G.Fly = false; _G.FlySpeed = 50; _G.WalkSpeed = 16; _G.ViewCone = false; _G.SStyle = 1 
_G.NameBoxToggle = false; _G.MainColor = Color3.new(0, 1, 1); _G.ClickToMenu = false
_G.Blacklist = {}; _G.Whitelist = {}
_G.Luck = false; _G.LuckPercent = 0; _G.LuckMultiplier = 1

-- Floating Visibility States
_G.Float_HB = false; _G.Float_Aim = false; _G.Float_ZeroCD = false; 
_G.Float_Noclip = false; _G.Float_Invis = false; _G.Float_Fly = false; _G.Float_InfJump = false
_G.Float_Luck = false

-- [[ CONTEXT MENU SYSTEM ]]
local ContextMenu = Instance.new("Frame", ScreenGui)
ContextMenu.Size = UDim2.new(0, 140, 0, 160) -- Increased height slightly for the X button
ContextMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ContextMenu.BackgroundTransparency = 0.1
ContextMenu.Visible = false
ContextMenu.ZIndex = 100
Instance.new("UICorner", ContextMenu)
local CMS = Instance.new("UIStroke", ContextMenu); CMS.Thickness = 2; CMS.Color = _G.MainColor
local CMG = Instance.new("UIStroke", ContextMenu); CMG.Thickness = 6; CMG.Transparency = 0.7; CMG.Color = _G.MainColor
ApplyNeonPulse(CMS, CMG, 2, 0.3)

-- [[ ADDED X CLOSE BUTTON ]]
local CloseContext = Instance.new("TextButton", ContextMenu)
CloseContext.Name = "CloseContext"
CloseContext.Size = UDim2.new(0, 20, 0, 20)
CloseContext.Position = UDim2.new(1, -25, 1, -25) -- Bottom Right
CloseContext.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseContext.Text = "X"
CloseContext.TextColor3 = Color3.new(1, 0.2, 0.2)
CloseContext.Font = "GothamBold"
CloseContext.TextSize = 12
CloseContext.ZIndex = 105
Instance.new("UICorner", CloseContext).CornerRadius = UDim.new(0, 4)
CloseContext.MouseButton1Click:Connect(function()
    ContextMenu.Visible = false
    ClickSound:Play()
end)

local targetPlayer = nil
local function ContextBtn(txt, y, callback)
    local b = Instance.new("TextButton", ContextMenu)
    b.Size = UDim2.new(0.9, 0, 0, 25); b.Position = UDim2.new(0.05, 0, 0, y); b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Font = "GothamBold"; b.TextSize = 10; b.ZIndex = 101
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback() ContextMenu.Visible = false; ClickSound:Play() end)
end

ContextBtn("ADD/REM BL", 10, function() if _G.Blacklist[targetPlayer.Name] then _G.Blacklist[targetPlayer.Name] = nil else _G.Blacklist[targetPlayer.Name] = true end end)
ContextBtn("ADD/REM WL", 40, function() if _G.Whitelist[targetPlayer.Name] then _G.Whitelist[targetPlayer.Name] = nil else _G.Whitelist[targetPlayer.Name] = true end end)
ContextBtn("GHOST BLINK", 70, function() 
    if targetPlayer.Character and LP.Character then
        local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then
            local lastPos = myHRP.CFrame; local startTime = tick()
            local loop; loop = RunService.PreSimulation:Connect(function()
                if tick() - startTime > 0.4 or not tHRP.Parent then loop:Disconnect(); myHRP.CFrame = lastPos; return end
                myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2.2); myHRP.Velocity = Vector3.zero
            end)
        end
    end
end)
ContextBtn("TELEPORT", 100, function() if targetPlayer.Character then LP.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end end)

UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if (i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.Touch) and _G.ClickToMenu then
        local ray = Camera:ScreenPointToRay(i.Position.X, i.Position.Y)
        local hit = workspace:FindPartOnRay(Ray.new(ray.Origin, ray.Direction * 1000))
        if hit and hit.Parent:FindFirstChild("Humanoid") then
            targetPlayer = Players:GetPlayerFromCharacter(hit.Parent)
            if targetPlayer and targetPlayer ~= LP then
                ContextMenu.Position = UDim2.new(0, i.Position.X, 0, i.Position.Y)
                ContextMenu.Visible = true
            end
        else ContextMenu.Visible = false end
    elseif i.UserInputType == Enum.UserInputType.MouseButton1 then
        local objects = ScreenGui:GetGuiObjectsAtPosition(i.Position.X, i.Position.Y)
        local insideMenu = false
        for _, obj in pairs(objects) do if obj == ContextMenu then insideMenu = true break end end
        if not insideMenu then ContextMenu.Visible = false end
    end
end)

-- [[ KILL SWITCH LOGIC ]]
local function TriggerKillSwitch()
    _G.HB = false; _G.BLHB = false; _G.Aim = false; _G.ESP = false; _G.TR = false; _G.ZeroCD = false;
    _G.Labels = false; _G.TargetOnly = false; _G.KillBtn = false; _G.AutoFriend = false;
    _G.Noclip = false; _G.ProxShield = false; _G.Invis = false; _G.Fly = false;
    _G.ViewCone = false; _G.NameBoxToggle = false; _G.Rainbow = false; _G.InfJump = false;
    _G.Luck = false; _G.LuckPercent = 0; _G.LuckMultiplier = 1
    
    _G.Float_HB = false; _G.Float_Aim = false; _G.Float_ZeroCD = false;
    _G.Float_Noclip = false; _G.Float_Invis = false; _G.Float_Fly = false; _G.Float_InfJump = false
    _G.Float_Luck = false

    if _G.Invis == false then
        local character = LP.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if (part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart")) and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
            end
        end
        local inv = workspace:FindFirstChild("invischair")
        if inv then inv:Destroy() end
    end
    
    KBtn.Visible = false
    NameDisplay.Visible = false
    
    Notify("KILL SWITCH ACTIVATED")
end

-- [[ NOTIFICATION SYSTEM ]]
local function Notify(text)
    local NotifFrame = Instance.new("Frame", ScreenGui)
    NotifFrame.Size = UDim2.new(0, 220, 0, 45)
    NotifFrame.Position = UDim2.new(1, 30, 0.9, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    NotifFrame.BackgroundTransparency = 0.2
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)
    local NStroke = Instance.new("UIStroke", NotifFrame); NStroke.Color = _G.MainColor; NStroke.Thickness = 2
    local Glow = Instance.new("UIStroke", NotifFrame); Glow.Color = _G.MainColor; Glow.Thickness = 4; Glow.Transparency = 0.6
    ApplyNeonPulse(NStroke, Glow, 3, 0.4)
    local Label = Instance.new("TextLabel", NotifFrame)
    Label.Size = UDim2.new(1, -20, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.new(1, 1, 1); Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 0.9, 0)}):Play()
    task.delay(2.5, function()
        local out = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 30, 0.9, 0)})
        out:Play()
        out.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

-- [[ MOVABLE NAME BOX UI - INTERACTIVE ]]
local NameDisplay = Instance.new("Frame", ScreenGui)
NameDisplay.Size = UDim2.new(0, 150, 0, 40); NameDisplay.Position = UDim2.new(0.5, -75, 0.1, 0)
NameDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 10); NameDisplay.BackgroundTransparency = 0.5; NameDisplay.Visible = false
NameDisplay.Active = true 
Instance.new("UICorner", NameDisplay)
local NDStroke = Instance.new("UIStroke", NameDisplay); NDStroke.Color = _G.MainColor; NDStroke.Thickness = 2
local NDGlow = Instance.new("UIStroke", NameDisplay); NDGlow.Color = _G.MainColor; NDGlow.Thickness = 6; NDGlow.Transparency = 0.8
ApplyNeonPulse(NDStroke, NDGlow, 1.5, 0.2)

local NDInput = Instance.new("TextBox", NameDisplay)
NDInput.Size = UDim2.new(1, -10, 1, -10); NDInput.Position = UDim2.new(0, 5, 0, 5)
NDInput.BackgroundTransparency = 1; NDInput.TextColor3 = Color3.new(1, 1, 1)
NDInput.Text = "No Target"; NDInput.PlaceholderText = "Type Name..."
NDInput.TextSize = 12; NDInput.Font = Enum.Font.GothamBold; NDInput.ClipsDescendants = true
NDInput.Interactable = true 
NDInput.Active = true

-- [[ FLY LOGIC ]]
local flyBodyPos, flyBodyGyro
local function toggleFly()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if _G.Fly then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.P = 15000; flyBodyGyro.D = 500; flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9); flyBodyGyro.cframe = hrp.CFrame; flyBodyGyro.Parent = hrp
        flyBodyPos = Instance.new("BodyPosition"); flyBodyPos.P = 15000; flyBodyPos.D = 600; flyBodyPos.maxForce = Vector3.new(9e9, 9e9, 9e9); flyBodyPos.position = hrp.Position + Vector3.new(0, 5, 0); flyBodyPos.Parent = hrp
        task.spawn(function()
            while _G.Fly and char.Parent and hrp.Parent do
                local dt = RunService.RenderStepped:Wait()
                local camCF = Camera.CFrame
                flyBodyGyro.cframe = camCF
                local f = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or (UIS:IsKeyDown(Enum.KeyCode.S) and -1 or 0)
                local r = UIS:IsKeyDown(Enum.KeyCode.D) and 1 or (UIS:IsKeyDown(Enum.KeyCode.A) and -1 or 0)
                local moveDir = hum.MoveDirection; local finalDir = Vector3.zero
                if f ~= 0 or r ~= 0 then finalDir = (camCF.LookVector * f) + (camCF.RightVector * r) elseif moveDir.Magnitude > 0 then finalDir = moveDir end
                if finalDir.Magnitude > 0 then flyBodyPos.position = flyBodyPos.position + (finalDir.Unit * (_G.FlySpeed * dt)) end
                hrp.Velocity = Vector3.zero
            end
            if flyBodyGyro then flyBodyGyro:Destroy() end
            if flyBodyPos then flyBodyPos:Destroy() end
            if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp); hum.PlatformStand = false end
        end)
    else
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyPos then flyBodyPos:Destroy() end
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- [[ INVISIBILITY LOGIC ]]
local function setCharacterTransparency(transparency)
    local character = LP.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if (part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart")) and part.Name ~= "HumanoidRootPart" then
                part.Transparency = transparency
            end
        end
    end
end

local function toggleInvisibility()
    local character = LP.Character
    if not character then return end
    if _G.Invis then
        setCharacterTransparency(0.75)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local savedpos = hrp.CFrame
            task.wait(0.05); character:MoveTo(Vector3.new(-25, 400, 20000)); task.wait(0.05)
            local seat = Instance.new("Seat"); seat.Name = "invischair"; seat.Anchored = false; seat.CanCollide = false; seat.Transparency = 1; seat.Position = Vector3.new(-25, 400, 20000); seat.Parent = workspace
            local weld = Instance.new("Weld", seat); weld.Part0 = seat
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if torso then weld.Part1 = torso; seat.CFrame = savedpos else seat:Destroy() end
        end
    else
        setCharacterTransparency(0)
        local inv = workspace:FindFirstChild("invischair")
        if inv then inv:Destroy() end
    end
end

-- Cache for hero names
local heroCache = {}
local function GetHeroName(character)
    if not character then return "Unknown" end
    local possibleValues = { character:FindFirstChild("CurrentHero"), character:FindFirstChild("HeroName"), character:FindFirstChild("CharacterName"), character:FindFirstChild("Mode"), character:FindFirstChild("StandName"), character:FindFirstChildWhichIsA("StringValue") }
    for _, val in ipairs(possibleValues) do if val and val:IsA("StringValue") and val.Value ~= "" and #val.Value > 2 then return val.Value end end
    for _, obj in ipairs(character:GetChildren()) do if (obj:IsA("Model") or obj:IsA("Folder")) and obj.Name ~= "HumanoidRootPart" then local cleanName = obj.Name:gsub("Rig", ""):gsub("Dummy", ""):gsub("Avatar", ""):gsub("[vV]%d+$", ""):gsub("%b[]", ""):gsub("^%s*(.-)%s*$", "%1") if #cleanName > 3 and cleanName:match("%u") then return cleanName end end end
    local hum = character:FindFirstChild("Humanoid")
    if hum and hum.DisplayName and hum.DisplayName ~= "" and hum.DisplayName ~= character.Name then return hum.DisplayName end
    return "Hero"
end

-- [[ SHIELD ASSETS ]]
local Shield = Instance.new("Part", workspace); Shield.Name = "ShieldPart"; Shield.Shape = Enum.PartType.Ball; Shield.Size = Vector3.new(18, 18, 18); Shield.CanCollide = false; Shield.Anchored = true; Shield.CastShadow = false; Shield.Transparency = 1
local Scanner = Instance.new("Part", workspace); Scanner.Name = "ShieldScanner"; Scanner.Size = Vector3.new(0.1, 18.5, 18.5); Scanner.Shape = Enum.PartType.Cylinder; Scanner.CanCollide = false; Scanner.Anchored = true; Scanner.CastShadow = false; Scanner.Transparency = 1; Scanner.Material = Enum.Material.Neon
local Ring1 = Instance.new("Part", workspace); Ring1.Name = "ShieldRing1"; Ring1.Shape = Enum.PartType.Ball; Ring1.Size = Vector3.new(18.1, 18.1, 18.1); Ring1.CanCollide = false; Ring1.Anchored = true; Ring1.CastShadow = false; Ring1.Transparency = 1; Ring1.Material = Enum.Material.Neon

-- 2. STABLE V47 MULTI-HOOK
pcall(function()
    local mt = getrawmetatable(game); local oldindex = mt.__index; setreadonly(mt, false)
    mt.__index = newcclosure(function(t, k)
        if _G.ZeroCD and (k == "Cooldown" or k == "CD" or k == "WaitTime") then return 0 end
        return oldindex(t, k)
    end)
    local oldWait; oldWait = hookfunction(wait, function(s) if _G.ZeroCD then return oldWait(0) end return oldWait(s) end)
    setreadonly(mt, true)
end)

-- 3. NEON UI CONSTRUCTION
local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Size = UDim2.new(0, 50, 0, 50); MenuBtn.Position = UDim2.new(0, 50, 0.5, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MenuBtn.BackgroundTransparency = 0.7; MenuBtn.Text = "★"; MenuBtn.TextSize = 28; MenuBtn.TextColor3 = _G.MainColor; MenuBtn.ZIndex = 20
MenuBtn.Active = true
MenuBtn.Selectable = false
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1,0)
local BStroke = Instance.new("UIStroke", MenuBtn); BStroke.Color = _G.MainColor; BStroke.Thickness = 2.5; BStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local BGlow1 = Instance.new("UIStroke", MenuBtn); BGlow1.Color = _G.MainColor; BGlow1.Thickness = 6; BGlow1.Transparency = 0.4
ApplyNeonPulse(BStroke, BGlow1, 1.8, 0.3)

local mGrad = Instance.new("UIGradient", MenuBtn)
mGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, _G.MainColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}
mGrad.Rotation = 45

RunService.RenderStepped:Connect(function() if mGrad then mGrad.Rotation = (tick() * 40) % 360 end end)
MenuBtn.MouseEnter:Connect(function() TweenService:Create(MenuBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, Size = UDim2.new(0, 55, 0, 55)}):Play() end)
MenuBtn.MouseLeave:Connect(function() TweenService:Create(MenuBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, Size = UDim2.new(0, 50, 0, 50)}):Play() end)

-- [[ UPDATED SKULL RESET BUTTON ]]
local KBtn = Instance.new("TextButton", ScreenGui)
KBtn.Size = UDim2.new(0, 45, 0, 45); KBtn.Position = UDim2.new(0, 50, 0.6, 0)
KBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); KBtn.BackgroundTransparency = 0.7; KBtn.Text = "︎︎⚠"; KBtn.TextSize = 28; KBtn.TextColor3 = Color3.fromRGB(255, 0, 0); KBtn.Visible = false; KBtn.ZIndex = 25
Instance.new("UICorner", KBtn).CornerRadius = UDim.new(1,0)
local KStroke = Instance.new("UIStroke", KBtn); KStroke.Color = Color3.fromRGB(255, 0, 0); KStroke.Thickness = 2.5; KStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local KGlow = Instance.new("UIStroke", KBtn); KGlow.Color = Color3.fromRGB(255, 0, 0); KGlow.Thickness = 6; KGlow.Transparency = 0.4
ApplyNeonPulse(KStroke, KGlow, 1.8, 0.3)

RunService.RenderStepped:Connect(function()
    local pulse = (math.sin(tick() * 1.8) + 1) / 2
    local transparency = 0.1 + (pulse * 0.1)
    if KBtn then
        KBtn.BackgroundTransparency = transparency
    end
end)

-- [[ FLOATING TOGGLE HELPER ]]
local floatStrokes = {}
local function CreateFloatingToggle(txt, pos, var, callback)
    local b = Instance.new("TextButton", ScreenGui)
    b.Size = UDim2.new(0, 40, 0, 40); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(0, 0, 0); b.BackgroundTransparency = 0.7; b.Text = txt; b.TextSize = 10; b.TextColor3 = Color3.new(1,1,1); b.ZIndex = 20; b.Visible = false
    b.Active = true
    b.Selectable = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    local s = Instance.new("UIStroke", b); s.Color = _G.MainColor; s.Thickness = 2; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local g = Instance.new("UIStroke", b); g.Color = _G.MainColor; g.Thickness = 8; g.Transparency = 0.75
    ApplyNeonPulse(s, g, 2, 0.25)
    table.insert(floatStrokes, {stroke = s, glow = g, variable = var, btn = b, floatVar = "Float_"..var})
    local dragging = false; local dStart, sPos, moved, dragInput
    b.InputBegan:Connect(function(i)
        if not dragInput and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = true
            dragInput = i
            moved = false
            dStart = i.Position
            sPos = b.Position
            if i.UserInputType == Enum.UserInputType.Touch then
                i:Capture()
            end
        end
    end)
    UIS.InputChanged:Connect(function(i) 
        if dragging and i == dragInput then 
            local delta = i.Position - dStart 
            if delta.Magnitude > 3 then 
                moved = true; 
                b.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) 
            end 
        end 
    end)
    UIS.InputEnded:Connect(function(i) 
        if i == dragInput then
            dragging = false 
            dragInput = nil
        end
    end)
    b.MouseButton1Click:Connect(function() if not moved then _G[var] = not _G[var] local state = _G[var] and "Activated" or "Deactivated" local cleanName = txt:gsub("GHOST", "Invisibility"):gsub("CLIP", "Noclip"):gsub("JUMP", "Inf Jump") Notify(cleanName .. " " .. state) PulseButton(b) ClickSound:Play() if callback then callback() end end end)
    return b
end

local FloatJump = CreateFloatingToggle("INF JUMP", UDim2.new(0, 110, 0.34, 0), "InfJump")
local FloatHB = CreateFloatingToggle("P HITBOX", UDim2.new(0, 110, 0.4, 0), "HB")
local FloatAim = CreateFloatingToggle("AIM", UDim2.new(0, 110, 0.46, 0), "Aim")
local FloatCD = CreateFloatingToggle("CD", UDim2.new(0, 110, 0.52, 0), "ZeroCD")
local FloatNoclip = CreateFloatingToggle("CLIP", UDim2.new(0, 110, 0.58, 0), "Noclip")
local FloatInvis = CreateFloatingToggle("GHOST", UDim2.new(0, 110, 0.64, 0), "Invis", function() toggleInvisibility() end)
local FloatFly = CreateFloatingToggle("FLY", UDim2.new(0, 110, 0.7, 0), "Fly", function() toggleFly() end)
local FloatLuck = CreateFloatingToggle("LUCK", UDim2.new(0, 110, 0.76, 0), "Luck")

-- [[ FLOATING KILL SWITCH ]]
local FloatKill = CreateFloatingToggle("KILL", UDim2.new(0, 110, 0.82, 0), "KillSwitch_Float")
FloatKill.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
FloatKill.MouseButton1Click:Connect(function()
    TriggerKillSwitch()
    PulseButton(FloatKill)
    ClickSound:Play()
end)

local Main = Instance.new("Frame", ScreenGui)
Main.AnchorPoint = Vector2.new(0, 0.5) 
Main.Size = UDim2.new(0, 180, 0, 260); Main.Visible = false; Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BackgroundTransparency = 0.6; Main.BorderSizePixel = 0
Main.ClipsDescendants = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MStroke = Instance.new("UIStroke", Main); MStroke.Color = _G.MainColor; MStroke.Thickness = 2; MStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local MGlow1 = Instance.new("UIStroke", Main); MGlow1.Color = _G.MainColor; MGlow1.Thickness = 14; MGlow1.Transparency = 0.8
ApplyNeonPulse(MStroke, MGlow1, 1.5, 0.2)

local basePos = Main.Position
RunService.RenderStepped:Connect(function() local offset = math.sin(tick()*1.5) * 2 Main.Position = basePos + UDim2.new(0, 0, 0, offset) end)
local function AlignMenu() basePos = UDim2.new(0, MenuBtn.AbsolutePosition.X + 60, 0, MenuBtn.AbsolutePosition.Y + 25) Main.Position = basePos end

local TabFrame = Instance.new("Frame", Main); TabFrame.Size = UDim2.new(1, 0, 0, 30); TabFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); TabFrame.BackgroundTransparency = 0.6; Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 8)
local Pages = {Combat = Instance.new("ScrollingFrame", Main), Visuals = Instance.new("ScrollingFrame", Main), Settings = Instance.new("ScrollingFrame", Main), Leader = Instance.new("ScrollingFrame", Main)}
for name, p in pairs(Pages) do p.Size = UDim2.new(1, -12, 1, -40); p.Position = UDim2.new(0, 6, 0, 35); p.Visible = (name == "Combat"); p.BackgroundTransparency = 1; p.CanvasSize = UDim2.new(0,0,3.5,0); p.ScrollBarThickness = 0 end

local function MakeTab(name, x, width)
    local t = Instance.new("TextButton", TabFrame); t.Size = UDim2.new(width, 0, 1, 0); t.Position = UDim2.new(x, 0, 0, 0); t.Text = name:upper(); t.TextSize = 7; t.Font = Enum.Font.GothamBold; t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    t.Active = true
    t.Selectable = false
    t.MouseButton1Click:Connect(function() for n, p in pairs(Pages) do p.Visible = false end Pages[name].Visible = true ClickSound:Play() end)
end
MakeTab("Combat", 0, 0.25); MakeTab("Visuals", 0.25, 0.25); MakeTab("Settings", 0.5, 0.25); MakeTab("Leader", 0.75, 0.25)

local allButtons = {}; local allMini = {}
local function QuickBtn(txt, y, var, parent, width, hasFloat)
    local w = width or 1
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(w, 0, 0, 28); b.Position = UDim2.new(0, 0, 0, y)
    b.Text = txt; b.Font = Enum.Font.GothamSemibold; b.TextSize = 8; b.BackgroundColor3 = Color3.fromRGB(5, 5, 5); b.BackgroundTransparency = 0.1; b.TextColor3 = Color3.new(1,1,1); b.ClipsDescendants = true 
    b.Active = true
    b.Selectable = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", b); s.Thickness = 1.2; s.Color = Color3.fromRGB(70,70,70)
    allButtons[var] = {btn = b, stroke = s}
    if hasFloat then
        local mini = Instance.new("TextButton", b); mini.Size = UDim2.new(0, 20, 0, 20); mini.Position = UDim2.new(1, -24, 0.5, -10); mini.BackgroundColor3 = Color3.fromRGB(0,0,0); mini.BackgroundTransparency = 0.5; mini.Text = "○"; mini.TextSize = 10; mini.TextColor3 = Color3.new(1,1,1); mini.ZIndex = 5
        mini.Active = true
        mini.Selectable = false
        Instance.new("UICorner", mini).CornerRadius = UDim.new(1,0)
        local mStroke = Instance.new("UIStroke", mini); mStroke.Color = Color3.fromRGB(70,70,70); mStroke.Thickness = 1.5
        allMini["Float_"..var] = {btn = mini, stroke = mStroke}
        mini.MouseButton1Click:Connect(function() local floatVar = "Float_"..var _G[floatVar] = not _G[floatVar] Notify("Floating " .. txt .. " " .. (_G[floatVar] and "Visible" or "Hidden")) PulseButton(mini) ClickSound:Play() end)
    end
    b.MouseButton1Click:Connect(function() 
        _G[var] = not _G[var] 
        Notify(txt:gsub("P HITBOX", "Player Hitbox"):gsub("AERIAL FLY MODE", "Fly Mode") .. " " .. (_G[var] and "Activated" or "Deactivated"))
        PulseButton(b); ClickSound:Play()
        if var == "KillBtn" then KBtn.Visible = _G.KillBtn end 
        if var == "Invis" then toggleInvisibility() end
        if var == "Fly" then toggleFly() end
        if var == "NameBoxToggle" then NameDisplay.Visible = _G.NameBoxToggle end
    end)
    return b
end

QuickBtn("P HITBOX", 0, "HB", Pages.Combat, 0.48, true)
local SzBox = Instance.new("TextBox", Pages.Combat); SzBox.Size = UDim2.new(0.35, -10, 0, 28); SzBox.Position = UDim2.new(0.5, 0, 0, 0); SzBox.Text = "15"; SzBox.BackgroundColor3 = Color3.fromRGB(5,5,5); SzBox.BackgroundTransparency = 0.1; SzBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SzBox); SzBox.ClipsDescendants = true
local SzBtn = Instance.new("TextButton", Pages.Combat); SzBtn.Size = UDim2.new(0.15, 0, 0, 28); SzBtn.Position = UDim2.new(0.85, 0, 0, 0); SzBtn.Text = "SET"; SzBtn.BackgroundColor3 = Color3.fromRGB(5,5,5); SzBtn.BackgroundTransparency = 0.1; SzBtn.TextColor3 = _G.MainColor; Instance.new("UICorner", SzBtn); local SzStr = Instance.new("UIStroke", SzBtn); SzStr.Color = _G.MainColor; SzStr.Thickness = 1.2
SzBtn.Active = true
SzBtn.Selectable = false
SzBtn.MouseButton1Click:Connect(function() _G.Size = tonumber(SzBox.Text) or 15 PulseButton(SzBtn) ClickSound:Play() Notify("Hitbox Size set to: ".._G.Size) end)

QuickBtn("BL HITBOX", 32, "BLHB", Pages.Combat, 0.48)
local BLSzBox = Instance.new("TextBox", Pages.Combat); BLSzBox.Size = UDim2.new(0.35, -10, 0, 28); BLSzBox.Position = UDim2.new(0.5, 0, 0, 32); BLSzBox.Text = "15"; BLSzBox.BackgroundColor3 = Color3.fromRGB(5,5,5); BLSzBox.BackgroundTransparency = 0.1; BLSzBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", BLSzBox); BLSzBox.ClipsDescendants = true
local BLSzBtn = Instance.new("TextButton", Pages.Combat); BLSzBtn.Size = UDim2.new(0.15, 0, 0, 28); BLSzBtn.Position = UDim2.new(0.85, 0, 0, 32); BLSzBtn.Text = "SET"; BLSzBtn.BackgroundColor3 = Color3.fromRGB(5,5,5); BLSzBtn.BackgroundTransparency = 0.1; BLSzBtn.TextColor3 = _G.MainColor; Instance.new("UICorner", BLSzBtn); local BLSzStr = Instance.new("UIStroke", BLSzBtn); BLSzStr.Color = _G.MainColor; BLSzStr.Thickness = 1.2
BLSzBtn.Active = true
BLSzBtn.Selectable = false
BLSzBtn.MouseButton1Click:Connect(function() _G.BLSize = tonumber(BLSzBox.Text) or 15 PulseButton(BLSzBtn) ClickSound:Play() Notify("Blacklist Hitbox Size set to: ".._G.BLSize) end)

QuickBtn("SMOOTH AIMBOT", 64, "Aim", Pages.Combat, 1, true)
QuickBtn("INSTANT COOLDOWN", 96, "ZeroCD", Pages.Combat, 1, true)
QuickBtn("INF JUMP MODE", 128, "InfJump", Pages.Combat, 1, true)
QuickBtn("AUTO-RESET BTN", 160, "KillBtn", Pages.Combat)
QuickBtn("NOCLIP (WALK THRU)", 192, "Noclip", Pages.Combat, 1, true) 
QuickBtn("GHOST INVISIBILITY", 224, "Invis", Pages.Combat, 1, true)
QuickBtn("AERIAL FLY MODE", 256, "Fly", Pages.Combat, 1, true)

-- [[ LUCK BOOST SYSTEM ]]
QuickBtn("LUCK BOOST", 288, "Luck", Pages.Combat, 1, true)

-- Luck % Label
local LuckLabel = Instance.new("TextLabel", Pages.Combat)
LuckLabel.Size = UDim2.new(1, 0, 0, 16); LuckLabel.Position = UDim2.new(0, 0, 0, 318)
LuckLabel.BackgroundTransparency = 1; LuckLabel.TextColor3 = _G.MainColor
LuckLabel.Text = "LUCK: 0% (1x)"; LuckLabel.Font = Enum.Font.GothamBold; LuckLabel.TextSize = 8

-- Luck Slider Background
local LuckSliderBG = Instance.new("Frame", Pages.Combat)
LuckSliderBG.Size = UDim2.new(1, 0, 0, 20); LuckSliderBG.Position = UDim2.new(0, 0, 0, 336)
LuckSliderBG.BackgroundColor3 = Color3.fromRGB(5, 5, 5); LuckSliderBG.BackgroundTransparency = 0.1
Instance.new("UICorner", LuckSliderBG).CornerRadius = UDim.new(0, 6)
local LuckSliderStroke = Instance.new("UIStroke", LuckSliderBG); LuckSliderStroke.Thickness = 1.2; LuckSliderStroke.Color = Color3.fromRGB(70, 70, 70)

-- Luck Slider Fill
local LuckSliderFill = Instance.new("Frame", LuckSliderBG)
LuckSliderFill.Size = UDim2.new(0, 0, 1, 0); LuckSliderFill.BackgroundColor3 = _G.MainColor
LuckSliderFill.BackgroundTransparency = 0.3
Instance.new("UICorner", LuckSliderFill).CornerRadius = UDim.new(0, 6)

-- Luck Slider Knob
local LuckKnob = Instance.new("Frame", LuckSliderBG)
LuckKnob.Size = UDim2.new(0, 14, 0, 14); LuckKnob.Position = UDim2.new(0, -7, 0.5, -7)
LuckKnob.BackgroundColor3 = Color3.new(1, 1, 1); LuckKnob.ZIndex = 10
Instance.new("UICorner", LuckKnob).CornerRadius = UDim.new(1, 0)
local LuckKnobStroke = Instance.new("UIStroke", LuckKnob); LuckKnobStroke.Thickness = 2; LuckKnobStroke.Color = _G.MainColor

-- Large number suffix formatter
local function FormatLuckMultiplier(val)
    local suffixes = {
        {1e36, "Undecillion"}, {1e33, "Decillion"}, {1e30, "Nonillion"},
        {1e27, "Octillion"}, {1e24, "Septillion"}, {1e21, "Sextillion"},
        {1e18, "Quintillion"}, {1e15, "Quadrillion"}, {1e12, "Trillion"},
        {1e9, "Billion"}, {1e6, "Million"}, {1e3, "Thousand"}
    }
    for _, s in ipairs(suffixes) do
        if val >= s[1] then
            return string.format("%.1f %s", val / s[1], s[2])
        end
    end
    return string.format("%.0fx", val)
end

-- Luck slider drag logic
local luckDragging = false
local function UpdateLuckSlider(inputX)
    local absPos = LuckSliderBG.AbsolutePosition.X
    local absSize = LuckSliderBG.AbsoluteSize.X
    local relative = math.clamp((inputX - absPos) / absSize, 0, 1)
    _G.LuckPercent = math.floor(relative * 100)
    _G.LuckMultiplier = 10 ^ (relative * 36)
    LuckSliderFill.Size = UDim2.new(relative, 0, 1, 0)
    LuckKnob.Position = UDim2.new(relative, -7, 0.5, -7)
    LuckLabel.Text = "LUCK: " .. _G.LuckPercent .. "% (" .. FormatLuckMultiplier(_G.LuckMultiplier) .. ")"
end

LuckSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        luckDragging = true
        UpdateLuckSlider(input.Position.X)
    end
end)
UIS.InputChanged:Connect(function(input)
    if luckDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateLuckSlider(input.Position.X)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        luckDragging = false
    end
end)

QuickBtn("PLAYER ESP", 0, "ESP", Pages.Visuals)
QuickBtn("SNAP TRACERS", 32, "TR", Pages.Visuals)
QuickBtn("HERO LABELS", 64, "Labels", Pages.Visuals)
QuickBtn("PROX SHIELD", 96, "ProxShield", Pages.Visuals, 0.48)
local SStyleBtn = Instance.new("TextButton", Pages.Visuals); SStyleBtn.Size = UDim2.new(0.48, 0, 0, 28); SStyleBtn.Position = UDim2.new(0.52, 0, 0, 96); SStyleBtn.Text = "STYLE: HEX"; SStyleBtn.Font = Enum.Font.GothamSemibold; SStyleBtn.TextSize = 8; SStyleBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5); SStyleBtn.TextColor3 = _G.MainColor; Instance.new("UICorner", SStyleBtn); local SStyleStr = Instance.new("UIStroke", SStyleBtn); SStyleStr.Thickness = 1.2; SStyleStr.Color = _G.MainColor
SStyleBtn.Active = true
SStyleBtn.Selectable = false
SStyleBtn.MouseButton1Click:Connect(function() _G.SStyle = (_G.SStyle % 4) + 1 PulseButton(SStyleBtn) ClickSound:Play() local st = {"HEX", "PULSE", "VORTEX", "GLASS"} SStyleBtn.Text = "STYLE: "..st[_G.SStyle] Notify("Shield Style: "..st[_G.SStyle]) end)

-- [[ 50 COLOR ARRAY ]]
local presetColors = {
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 165, 0), Color3.fromRGB(128, 0, 128),
    Color3.fromRGB(40, 40, 40), Color3.fromRGB(0, 0, 0), 
    Color3.fromRGB(255, 105, 180), Color3.fromRGB(135, 206, 235), Color3.fromRGB(0, 128, 128), Color3.fromRGB(255, 215, 0),
    Color3.fromRGB(173, 255, 47), Color3.fromRGB(75, 0, 130), Color3.fromRGB(220, 20, 60), Color3.fromRGB(30, 144, 255),
    Color3.fromRGB(0, 250, 154), Color3.fromRGB(255, 69, 0), Color3.fromRGB(218, 112, 214), Color3.fromRGB(240, 230, 140),
    Color3.fromRGB(127, 255, 212), Color3.fromRGB(250, 128, 114), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 0, 127),
    Color3.fromRGB(154, 205, 50), Color3.fromRGB(100, 149, 237), Color3.fromRGB(255, 127, 80), Color3.fromRGB(32, 178, 170),
    Color3.fromRGB(238, 130, 238), Color3.fromRGB(106, 90, 205), Color3.fromRGB(144, 238, 144), Color3.fromRGB(255, 160, 122),
    Color3.fromRGB(138, 43, 226), Color3.fromRGB(95, 158, 160), Color3.fromRGB(210, 105, 30), Color3.fromRGB(188, 143, 143),
    Color3.fromRGB(244, 164, 96), Color3.fromRGB(123, 104, 238), Color3.fromRGB(60, 179, 113), Color3.fromRGB(72, 61, 139),
    Color3.fromRGB(255, 192, 203), Color3.fromRGB(0, 255, 127), Color3.fromRGB(176, 196, 222), Color3.fromRGB(255, 228, 196),
    Color3.fromRGB(255, 99, 71), Color3.fromRGB(186, 85, 211), Color3.fromRGB(143, 188, 143), Color3.fromRGB(175, 238, 238)
}

local ColorIndex = 1
local CycleBtn = Instance.new("TextButton", Pages.Visuals); CycleBtn.Size = UDim2.new(1, 0, 0, 28); CycleBtn.Position = UDim2.new(0, 0, 0, 128); CycleBtn.Text = "THEME COLOR [ 1 ]"; CycleBtn.BackgroundColor3 = Color3.fromRGB(5,5,5); CycleBtn.BackgroundTransparency = 0.1; CycleBtn.TextColor3 = _G.MainColor; Instance.new("UICorner", CycleBtn); local CyStr = Instance.new("UIStroke", CycleBtn); CyStr.Color = _G.MainColor; CyStr.Thickness = 1.2
CycleBtn.Active = true
CycleBtn.Selectable = false
CycleBtn.MouseButton1Click:Connect(function() 
    ColorIndex = (ColorIndex % #presetColors) + 1
    _G.MainColor = presetColors[ColorIndex]
    CycleBtn.Text = "THEME COLOR [ " .. tostring(ColorIndex) .. " ]"
    PulseButton(CycleBtn); ClickSound:Play()
    Notify("Theme Color Updated to #" .. tostring(ColorIndex))
end)

QuickBtn("NEON RAINBOW", 160, "Rainbow", Pages.Visuals)
QuickBtn("VIEW CONE (FOV)", 192, "ViewCone", Pages.Visuals)

local ListIn = Instance.new("TextBox", Pages.Settings); ListIn.Size = UDim2.new(0.5, 0, 0, 28); ListIn.Position = UDim2.new(0, 0, 0, 0); ListIn.PlaceholderText = "Target..."; ListIn.BackgroundColor3 = Color3.fromRGB(5,5,5); ListIn.BackgroundTransparency = 0.1; ListIn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ListIn); ListIn.ClipsDescendants = true
QuickBtn("BL TARGET", 0, "TargetOnly", Pages.Settings, 0.48); allButtons["TargetOnly"].btn.Position = UDim2.new(0.52, 0, 0, 0)
QuickBtn("NAME BOX TOGGLE", 32, "NameBoxToggle", Pages.Settings) 

local AddB = Instance.new("TextButton", Pages.Settings); AddB.Size = UDim2.new(0.48, 0, 0, 28); AddB.Position = UDim2.new(0, 0, 0, 64); AddB.Text = "ADD BL"; AddB.BackgroundColor3 = Color3.fromRGB(30,5,30); AddB.BackgroundTransparency = 0.2; AddB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", AddB)
AddB.Active = true
AddB.Selectable = false
local RemB = Instance.new("TextButton", Pages.Settings); RemB.Size = UDim2.new(0.48, 0, 0, 28); RemB.Position = UDim2.new(0.52, 0, 0, 64); RemB.Text = "REM BL"; RemB.BackgroundColor3 = Color3.fromRGB(40,10,40); RemB.BackgroundTransparency = 0.2; RemB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RemB)
RemB.Active = true
RemB.Selectable = false
local AddW = Instance.new("TextButton", Pages.Settings); AddW.Size = UDim2.new(0.48, 0, 0, 28); AddW.Position = UDim2.new(0, 0, 0, 96); AddW.Text = "ADD WL"; AddW.BackgroundColor3 = Color3.fromRGB(5,30,30); AddW.BackgroundTransparency = 0.2; AddW.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", AddW)
AddW.Active = true
AddW.Selectable = false
local RemW = Instance.new("TextButton", Pages.Settings); RemW.Size = UDim2.new(0.48, 0, 0, 28); RemW.Position = UDim2.new(0.52, 0, 0, 96); RemW.Text = "REM WL"; RemW.BackgroundColor3 = Color3.fromRGB(10,40,40); RemW.BackgroundTransparency = 0.2; RemW.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RemW)
RemW.Active = true
RemW.Selectable = false
local TPB = Instance.new("TextButton", Pages.Settings); TPB.Size = UDim2.new(1, 0, 0, 28); TPB.Position = UDim2.new(0, 0, 0, 128); TPB.Text = "TELEPORT"; TPB.BackgroundColor3 = Color3.fromRGB(5,30,5); TPB.BackgroundTransparency = 0.2; TPB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TPB)
TPB.Active = true
TPB.Selectable = false
local ClrB = Instance.new("TextButton", Pages.Settings); ClrB.Size = UDim2.new(1, 0, 0, 28); ClrB.Position = UDim2.new(0, 0, 0, 160); ClrB.Text = "CLEAR ALL LISTS"; ClrB.BackgroundColor3 = Color3.fromRGB(30,5,5); ClrB.BackgroundTransparency = 0.2; ClrB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ClrB)
ClrB.Active = true
ClrB.Selectable = false

local FlySpdBox = Instance.new("TextBox", Pages.Settings); FlySpdBox.Size = UDim2.new(1, 0, 0, 28); FlySpdBox.Position = UDim2.new(0, 0, 0, 192); FlySpdBox.Text = "FLY SPEED: 50"; FlySpdBox.BackgroundColor3 = Color3.fromRGB(10,10,10); FlySpdBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FlySpdBox); FlySpdBox.FocusLost:Connect(function() local val = tonumber(FlySpdBox.Text:match("%d+")) if val then _G.FlySpeed = math.clamp(val, 10, 250) FlySpdBox.Text = "FLY SPEED: ".._G.FlySpeed Notify("Fly Speed set to ".._G.FlySpeed) end end)
local WalkSpdBox = Instance.new("TextBox", Pages.Settings); WalkSpdBox.Size = UDim2.new(1, 0, 0, 28); WalkSpdBox.Position = UDim2.new(0, 0, 0, 224); WalkSpdBox.Text = "WALK SPEED: 16"; WalkSpdBox.BackgroundColor3 = Color3.fromRGB(10,10,10); WalkSpdBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", WalkSpdBox); WalkSpdBox.FocusLost:Connect(function() local val = tonumber(WalkSpdBox.Text:match("%d+")) if val then _G.WalkSpeed = math.clamp(val, 16, 250) WalkSpdBox.Text = "WALK SPEED: ".._G.WalkSpeed Notify("Walk Speed set to ".._G.WalkSpeed) end end)

QuickBtn("AUTO-FRIEND WL", 256, "AutoFriend", Pages.Settings)
local GhostBtn = Instance.new("TextButton", Pages.Settings); GhostBtn.Size = UDim2.new(1, 0, 0, 32); GhostBtn.Position = UDim2.new(0, 0, 0, 288); GhostBtn.Text = "GHOST BLINK (0.4S)"; GhostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 50); GhostBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", GhostBtn); local isAttacking = false
GhostBtn.Active = true
GhostBtn.Selectable = false
local function GetTarget() local t = ListIn.Text:lower() if #t > 0 then for _, p in pairs(Players:GetPlayers()) do if p.Name:lower():sub(1,#t) == t or p.DisplayName:lower():sub(1,#t) == t then return p end end end return nil end

-- [[ FLOATING NAME BOX - LINK LOGIC ]]
NDInput.FocusLost:Connect(function() 
    ListIn.Text = NDInput.Text 
end); 
ListIn:GetPropertyChangedSignal("Text"):Connect(function() 
    NDInput.Text = ListIn.Text 
end)

-- [[ MENU KILL SWITCH BUTTON ]]
local MenuKillBtn = Instance.new("TextButton", Pages.Settings); MenuKillBtn.Size = UDim2.new(1, 0, 0, 32); MenuKillBtn.Position = UDim2.new(0, 0, 0, 325); MenuKillBtn.Text = "KILL SWITCH"; MenuKillBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0); MenuKillBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MenuKillBtn)
MenuKillBtn.Active = true
MenuKillBtn.Selectable = false
MenuKillBtn.MouseButton1Click:Connect(function()
    TriggerKillSwitch()
    PulseButton(MenuKillBtn)
    ClickSound:Play()
end)

QuickBtn("CLICK TO MENU", 357, "ClickToMenu", Pages.Settings)

GhostBtn.MouseButton1Click:Connect(function()
    if isAttacking then return end
    PulseButton(GhostBtn); ClickSound:Play()
    local p = GetTarget()
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Executing Ghost Blink on " .. p.Name)
        isAttacking = true; local myHRP = LP.Character.HumanoidRootPart; local targetHRP = p.Character.HumanoidRootPart; local lastPos = myHRP.CFrame; local startTime = tick(); local killLoop
        killLoop = RunService.PreSimulation:Connect(function()
            if tick() - startTime > 0.4 or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then killLoop:Disconnect(); myHRP.CFrame = lastPos; isAttacking = false; return end
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0.5, 2.2); myHRP.Velocity = Vector3.new(0, 0, 0)
            local tool = LP.Character:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")
            if tool then if tool.Parent ~= LP.Character then tool.Parent = LP.Character end game:GetService("ReplicatedStorage").Events.UseTool:FireServer(tool.Name) end
        end)
    else Notify("No Valid Target for Ghost Blink") end
end)

AddB.MouseButton1Click:Connect(function() PulseButton(AddB); ClickSound:Play() local p = GetTarget() if p then _G.Blacklist[p.Name] = true Notify("Blacklisted: " .. p.Name) end end)
RemB.MouseButton1Click:Connect(function() PulseButton(RemB); ClickSound:Play() local p = GetTarget() if p then _G.Blacklist[p.Name] = nil Notify("Unblacklisted: " .. p.Name) end end)
AddW.MouseButton1Click:Connect(function() PulseButton(AddW); ClickSound:Play() local p = GetTarget() if p then _G.Whitelist[p.Name] = true Notify("Whitelisted: " .. p.Name) end end)
RemW.MouseButton1Click:Connect(function() PulseButton(RemW); ClickSound:Play() local p = GetTarget() if p then _G.Whitelist[p.Name] = nil Notify("Unwhitelisted: " .. p.Name) end end)
TPB.MouseButton1Click:Connect(function() PulseButton(TPB); ClickSound:Play() local p = GetTarget() if p and p.Character then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) Notify("Teleported to "..p.Name) end end)
ClrB.MouseButton1Click:Connect(function() PulseButton(ClrB); ClickSound:Play() _G.Blacklist = {}; _G.Whitelist = {} Notify("All Lists Cleared") end)

-- [[ INTEGRATED LEADERBOARD LOGIC ]]
local scroll = Pages.Leader
scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

local function clearList()
    for _, v in ipairs(scroll:GetChildren()) do
        if v:IsA("GuiObject") and not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end
end

local function getPlayerValue(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat:IsA("NumberValue") or stat:IsA("IntValue") then
                return stat.Value
            end
        end
    end
    return 0
end

local function updateLeaderboard()
    clearList()
    local playersList = Players:GetPlayers()
    table.sort(playersList, function(a, b)
        return getPlayerValue(a) > getPlayerValue(b)
    end)
    for _, player in ipairs(playersList) do
        local value = getPlayerValue(player)
        local btn = Instance.new("TextButton")
        btn.Name = player.Name
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Text = player.Name .. " - " .. tostring(value)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            targetPlayer = player
            ContextMenu.Position = UDim2.new(0, btn.AbsolutePosition.X + btn.AbsoluteSize.X + 5, 0, btn.AbsolutePosition.Y)
            ContextMenu.Visible = true
            ClickSound:Play()
            PulseButton(btn)
        end)
    end
    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(function() task.wait(0.2) updateLeaderboard() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) updateLeaderboard() end)
updateLeaderboard()

-- [[ CORE LOOP ]]
local SharedResizeHandle = nil
local currentAlpha = 0 
RunService.Stepped:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = _G.WalkSpeed end
    -- [[ LUCK BOOST LOGIC ]]
    if _G.Luck and LP.Character then
        local leaderstats = LP:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in ipairs(leaderstats:GetChildren()) do
                local statName = stat.Name:lower()
                if (statName == "luck" or statName == "luckboost" or statName == "luck boost" or statName == "luckvalue") and (stat:IsA("NumberValue") or stat:IsA("IntValue")) then
                    stat.Value = stat.Value * _G.LuckMultiplier
                end
            end
        end
        local playerGui = LP:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("NumberValue") or gui:IsA("IntValue") then
                    local gName = gui.Name:lower()
                    if gName == "luck" or gName == "luckboost" or gName == "luck multiplier" or gName == "luckvalue" then
                        gui.Value = gui.Value * _G.LuckMultiplier
                    end
                end
            end
        end
    end
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LP.Character.HumanoidRootPart
        if _G.ProxShield then 
            Shield.CFrame = HRP.CFrame; Scanner.CFrame = HRP.CFrame; Ring1.CFrame = HRP.CFrame; local minDist = 999; for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d = (p.Character.HumanoidRootPart.Position - HRP.Position).Magnitude if d < 200 and not _G.Whitelist[p.Name] and not (LP:IsFriendsWith(p.UserId) and _G.AutoFriend) then if d < minDist then minDist = d end end end end local sCol = _G.MainColor; local pulseSpd = 4; local act = (minDist < 200) if minDist <= 85 then sCol = Color3.new(1,0,0); pulseSpd = 25 elseif minDist <= 130 then sCol = Color3.fromRGB(255,140,0); pulseSpd = 12 elseif minDist <= 200 then sCol = Color3.new(1,1,0); pulseSpd = 5 end Shield.Color = sCol; Scanner.Color = sCol; Ring1.Color = sCol; local targetAlpha = act and 0.75 or 0.15 currentAlpha = math.lerp(currentAlpha, targetAlpha, 0.08) local finalTrans = 0.85 - currentAlpha 
            if _G.SStyle == 1 then Shield.Material = Enum.Material.ForceField; Shield.Transparency = finalTrans; Shield.Size = Vector3.new(18, 18, 18); Scanner.Size = Vector3.new(0.1, 18.5, 18.5); Scanner.Shape = Enum.PartType.Cylinder; Ring1.Transparency = 1; Scanner.Transparency = (finalTrans - 0.2) + (math.sin(tick() * 15) * 0.05); Scanner.CFrame = HRP.CFrame * CFrame.new(0, math.sin(tick() * (pulseSpd/2)) * 8, 0) * CFrame.Angles(0, 0, math.rad(90)) elseif _G.SStyle == 2 then Shield.Material = Enum.Material.ForceField; Shield.Size = Vector3.new(18, 18, 18); Ring1.Material = Enum.Material.Neon; Ring1.Size = Vector3.new(18.05, 18.05, 18.05); Scanner.Transparency = 1; local f = (0.3 + math.sin(tick() * pulseSpd) * 0.2) Shield.Transparency = finalTrans + f; Ring1.Transparency = finalTrans + (f * 2) elseif _G.SStyle == 3 then Shield.Material = Enum.Material.ForceField; Shield.Transparency = finalTrans; Ring1.Transparency = 1; local breathingSize = 17.5 + (math.sin(tick() * (pulseSpd * 0.5)) * 1.0) Shield.Size = Vector3.new(breathingSize, breathingSize, breathingSize); Scanner.Shape = Enum.PartType.Ball; Scanner.Material = Enum.Material.Neon; Scanner.Size = Vector3.new(breathingSize * 0.8, breathingSize * 0.8, breathingSize * 0.8); Scanner.Transparency = (finalTrans - 0.1) + (0.4 + math.sin(tick()*pulseSpd)*0.2); Scanner.CFrame = HRP.CFrame * CFrame.Angles(0, tick()*(pulseSpd/4), 0) elseif _G.SStyle == 4 then Shield.Material = Enum.Material.Glass; Shield.Transparency = finalTrans; Shield.Size = Vector3.new(18.2, 18.2, 18.2); Scanner.Transparency = 1; Ring1.Transparency = 1 end 
        else Shield.Transparency = 1; Scanner.Transparency = 1; Ring1.Transparency = 1; currentAlpha = 0 end
        if _G.Noclip then for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end HRP.Velocity = Vector3.new(0, 0.01, 0); HRP.CFrame = HRP.CFrame * CFrame.new(0, 0.001, 0) else if HRP.CanCollide == false then for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = true end end HRP.CanCollide = true end end
    end
end)

-- [[ HIGHLIGHT ESP ENGINE ]]
-- INTEGRATED FROM YOUR SNIPPET: NO TOUCHING/TWEAKING
task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChild("EliteESP")
                if _G.ESP then
                    if not h then h = Instance.new("Highlight", p.Character); h.Name = "EliteESP"; h.FillColor = Color3.fromRGB(0, 255, 150) end
                elseif h then h:Destroy() end
            end
        end
    end
end)

-- [[ SKELETON ESP HELPER ]]
local function CreateESPLine()
    local l = Instance.new("Frame")
    l.BorderSizePixel = 0
    l.ZIndex = 5
    return l
end

RunService.RenderStepped:Connect(function()
    if _G.Rainbow then _G.MainColor = Color3.fromHSV(tick()%5/5, 0.7, 1) end
    BStroke.Color = _G.MainColor; BGlow1.Color = _G.MainColor; MStroke.Color = _G.MainColor; MGlow1.Color = _G.MainColor
    MenuBtn.TextColor3 = _G.MainColor; CycleBtn.TextColor3 = _G.MainColor; SzBtn.TextColor3 = _G.MainColor; CyStr.Color = _G.MainColor; SzStr.Color = _G.MainColor; SStyleBtn.TextColor3 = _G.MainColor; SStyleStr.Color = _G.MainColor; NDStroke.Color = _G.MainColor; NDGlow.Color = _G.MainColor
    CMS.Color = _G.MainColor; CMG.Color = _G.MainColor
    LuckLabel.TextColor3 = _G.MainColor; LuckSliderFill.BackgroundColor3 = _G.MainColor; LuckKnobStroke.Color = _G.MainColor
    if SharedResizeHandle then SharedResizeHandle.TextColor3 = _G.MainColor end
    local glowPulse = (math.sin(tick()*2)+1)/2
    for _, data in pairs(floatStrokes) do local active = _G[data.variable]; local visible = _G[data.floatVar] data.stroke.Color = _G.MainColor; data.glow.Color = _G.MainColor; data.btn.TextColor3 = active and _G.MainColor or Color3.new(1,1,1); data.btn.Visible = visible; data.stroke.Thickness = active and (2 + math.sin(tick()*5)*0.5) or 1.2; data.btn.BackgroundTransparency = 0.1 + (glowPulse * 0.05) end
    for mVar, data in pairs(allMini) do local active = _G[mVar] data.stroke.Color = active and _G.MainColor or Color3.fromRGB(70,70,70); data.btn.TextColor3 = active and _G.MainColor or Color3.new(1,1,1); data.btn.Text = active and "★" or "○"; data.btn.BackgroundTransparency = 0.1 + (glowPulse * 0.05) end
    for var, data in pairs(allButtons) do local isActive = _G[var] data.btn.TextColor3 = isActive and _G.MainColor or Color3.new(1,1,1); data.stroke.Thickness = isActive and (2 + math.sin(tick()*5)*0.5) or 1.2; data.stroke.Color = isActive and _G.MainColor or Color3.fromRGB(70,70,70); data.btn.BackgroundTransparency = 0.1 + (glowPulse * 0.05) end
    for _, v in pairs(ScreenGui:GetChildren()) do if v.Name == "V" then v:Destroy() end end
    local sortedPlayers = {}; local myPos = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and LP.Character.HumanoidRootPart.Position or Vector3.zero
    for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(sortedPlayers, {p = p, d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude}) end end
    table.sort(sortedPlayers, function(a, b) return a.d < b.d end)
    local now = tick()
    for i, data in ipairs(sortedPlayers) do
        local p, d, hrp = data.p, data.d, data.p.Character.HumanoidRootPart; local hum = p.Character:FindFirstChild("Humanoid"); local isBL = _G.Blacklist[p.Name]; local isWL = _G.Whitelist[p.Name]; local isFriend = (_G.AutoFriend and LP:IsFriendsWith(p.UserId) and not isBL)
        local charName; local cacheEntry = heroCache[p] if cacheEntry and cacheEntry.lastTick > now - 4 then charName = cacheEntry.name else charName = GetHeroName(p.Character) heroCache[p] = {name = charName, lastTick = now} end
        local finalCol = _G.MainColor; local espBorder = Color3.new(1,1,1) if isWL then finalCol = Color3.new(1,1,1); espBorder = Color3.new(1,1,1) elseif isFriend then finalCol = Color3.fromRGB(0, 255, 0); espBorder = finalCol elseif isBL then finalCol = Color3.new(1,0,1); espBorder = finalCol elseif i == 1 then finalCol = Color3.new(0,0,0); espBorder = Color3.new(0,0,0) elseif i == 2 then finalCol = Color3.fromRGB(128,0,32); espBorder = finalCol end
        if not isBL and not isWL and not isFriend and i > 2 then if d < 160 then espBorder = Color3.new(1,0,0) elseif d < 390 then espBorder = Color3.fromRGB(255, 140, 0) elseif d < 620 then espBorder = Color3.new(1,1,0) end end
        
        -- [[ HITBOX LOGIC - WHITELIST CHECK ]]
        if not (isWL or isFriend) then
            if isBL and _G.BLHB then
                hrp.Size = Vector3.new(_G.BLSize, _G.BLSize, _G.BLSize)
                hrp.Transparency = 0.8; hrp.Color = Color3.new(1,0,1); hrp.Material = "Neon"; hrp.CanCollide = false
            elseif _G.HB then
                hrp.Size = Vector3.new(_G.Size, _G.Size, _G.Size)
                hrp.Transparency = 0.8; hrp.Color = finalCol; hrp.Material = "Neon"; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
            end
        else
            -- Ensure WL/Friends always have normal hitboxes
            hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
        end
        
        local sP, on = Camera:WorldToViewportPoint(hrp.Position)
        if on then
            local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0)); local bottom = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -4.5, 0)); local h = math.abs(top.Y - bottom.Y); local w = h * 0.6
            -- Original skeleton ESP disabled if Highlight ESP is prioritized or integrated
            if _G.Labels or (_G.TargetOnly and isBL) or isWL or isFriend then local l = Instance.new("TextLabel", ScreenGui); l.Name="V"; l.Size=UDim2.new(0,100,0,20); l.Position=UDim2.new(0,sP.X-50,0,sP.Y-h/2-25); l.BackgroundTransparency=1; l.TextColor3=finalCol; l.TextSize=8; l.Font="Code" local tag = (isWL or isFriend) and "[FRIEND]\n" or (isBL and "[TARGET]\n" or ""); l.Text = tag.."["..charName.."] "..p.Name.."\n"..math.floor(hum and hum.Health or 0).." HP | "..math.floor(d).." STUDS" Instance.new("UIStroke",l).Color = Color3.new(0,0,0) end
            if (_G.TR and not (isWL or isFriend)) or (_G.TargetOnly and isBL) then local t = Instance.new("Frame", ScreenGui); t.Name="V"; t.AnchorPoint=Vector2.new(0.5,0.5); local start = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) t.Size = UDim2.new(0, (isBL or i <= 2) and 2.5 or 1.2, 0, (start - Vector2.new(sP.X, sP.Y)).Magnitude) t.Position = UDim2.new(0, (start.X + sP.X)/2, 0, (start.Y + sP.Y)/2); t.Rotation = math.deg(math.atan2(sP.Y - start.Y, sP.X - start.X)) - 90; t.BackgroundColor3 = finalCol; t.BorderSizePixel = 0 if isBL or i <= 2 then Instance.new("UIStroke", t).Color = finalCol end end
            if _G.ViewCone and p.Character:FindFirstChild("HumanoidRootPart") then local p_hrp = p.Character.HumanoidRootPart local footPos = p_hrp.Position - Vector3.new(0, 3, 0) local lookDir = p_hrp.CFrame.LookVector local directionToMe = (Camera.CFrame.Position - p_hrp.Position).Unit local dot = lookDir:Dot(directionToMe) local arrowCol = _G.MainColor if dot > 0.8 then arrowCol = Color3.fromRGB(150, 0, 0) elseif dot > 0.4 then arrowCol = Color3.fromRGB(180, 80, 0) elseif dot > 0 then arrowCol = Color3.fromRGB(160, 140, 0) end local startP, startOn = Camera:WorldToViewportPoint(footPos) local endP, endOn = Camera:WorldToViewportPoint(footPos + (lookDir * 5.5)) if startOn and endOn then local startV, endV = Vector2.new(startP.X, startP.Y), Vector2.new(endP.X, endP.Y) local p_dist = (startV - endV).Magnitude local angle = math.atan2(endV.Y - startV.Y, endV.X - startV.X) local line = Instance.new("Frame", ScreenGui); line.Name = "V"; line.AnchorPoint = Vector2.new(0, 0.5) line.Size = UDim2.new(0, p_dist, 0, 1.5); line.Position = UDim2.new(0, startV.X, 0, startV.Y); line.Rotation = math.deg(angle); line.BackgroundColor3 = arrowCol; line.BorderSizePixel = 0; line.BackgroundTransparency = 0.2 end end
        end
    end
    local targetValid = sortedPlayers[1] and not _G.Whitelist[sortedPlayers[1].p.Name] and not (_G.AutoFriend and LP:IsFriendsWith(sortedPlayers[1].p.UserId) and not _G.Blacklist[sortedPlayers[1].p.Name])
    if _G.Aim and targetValid and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, sortedPlayers[1].p.Character.HumanoidRootPart.Position), 0.15) end
end)

local function MakeDraggable(gui)
    local drag, dStart, sPos, moved, dragInput = false, nil, nil, false, nil
    gui.InputBegan:Connect(function(i) if not dragInput and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then drag = true; dragInput = i; moved = false; dStart = i.Position; sPos = gui.Position end end)
    UIS.InputChanged:Connect(function(i) if drag and i == dragInput then local delta = i.Position - dStart; if delta.Magnitude > 2 then moved = true; gui.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) if gui == MenuBtn and Main.Visible then AlignMenu() end end end end)
    UIS.InputEnded:Connect(function(i) if i == dragInput then drag = false; dragInput = nil end end)
    return function() return moved end
end

local function MakeResizable(gui, minSize)
    local resizeHandle = Instance.new("TextButton", gui); resizeHandle.Size = UDim2.new(0, 30, 0, 30); resizeHandle.Position = UDim2.new(1, -30, 1, -30); resizeHandle.BackgroundTransparency = 1; resizeHandle.Text = "◢"; resizeHandle.TextColor3 = _G.MainColor; resizeHandle.Text = "◢"; resizeHandle.TextSize = 14; resizeHandle.ZIndex = 40; SharedResizeHandle = resizeHandle; local resizing = false; local startPos, startSize, resizeInput
    resizeHandle.InputBegan:Connect(function(input) if not resizeInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then resizing = true; resizeInput = input; startPos = input.Position; startSize = gui.AbsoluteSize end end)
    UIS.InputChanged:Connect(function(resInput) if resizing and resInput == resizeInput then local delta = resInput.Position - startPos; local newWidth = math.max(minSize.X, startSize.X + delta.X); local newHeight = math.max(minSize.Y, startSize.Y + delta.Y) gui.Size = UDim2.new(0, newWidth, 0, newHeight) end end)
    UIS.InputEnded:Connect(function(endInput) if endInput == resizeInput then resizing = false; resizeInput = nil end end)
end

local menuMoved = MakeDraggable(MenuBtn); local killMoved = MakeDraggable(KBtn); MakeDraggable(NameDisplay); MakeDraggable(FloatKill); MakeResizable(Main, Vector2.new(80, 65)) 

MenuBtn.MouseButton1Click:Connect(function()
    if not menuMoved() then
        if not Main.Visible then
            AlignMenu(); Main.Visible = true; Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, 260)}):Play()
        else
            local cl = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            cl:Play(); cl.Completed:Connect(function() Main.Visible = false end)
        end
        PulseButton(MenuBtn); ClickSound:Play()
    end
end)

KBtn.MouseButton1Click:Connect(function() if not killMoved() and LP.Character and LP.Character:FindFirstChild("Humanoid") then PulseButton(KBtn); ClickSound:Play(); LP.Character.Humanoid.Health = 0 end end)

-- [[ FINAL INITIALIZATION WRAPPER ]]
local function FinalStart()
    Notify("Marvel Radar V92 Loaded Successfully")
    print("Marvel Radar V92: Core initialized.")
end

local success, errorMessage = pcall(function()
    FinalStart()
end)

if not success then
    warn("Marvel Radar V92: Execution Failed!")
    warn("Error: " .. tostring(errorMessage))
end