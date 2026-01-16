local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- NOUVEAU: Système de sauvegarde des paramètres
local SETTINGS_FILE = "AdminPanel_Settings_" .. LP.UserId .. ".json"

local Settings = {
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    NoClip = false,
    XRay = false,
    ESP = false,
    Aimbot = false,
    AimFOV = 100,
    AimSmooth = 0.5,
    AimPart = "Head",
    AutoClick = false,
    WallBang = false,
    InfJump = false,
    FlyKey = Enum.KeyCode.F,
    TeamCheck = false
}

local Connections = {}
local OriginalTransparency = {}
local ESPObjects = {}
local FocusedPlayer = nil

local AUTH_FILE = "AP_Key_" .. LP.UserId .. ".txt"
local MASTER_KEY = "iygyiegfiygeyfgyeyf7089"

-- NOUVEAU: Fonctions de sauvegarde des paramètres
local function SaveSettings()
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(Settings)
            writefile(SETTINGS_FILE, data)
        end
    end)
end

local function LoadSettings()
    pcall(function()
        if isfile and readfile and isfile(SETTINGS_FILE) then
            local data = readfile(SETTINGS_FILE)
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                Settings[k] = v
            end
        end
    end)
end

-- Key Functions
local function GetKeyTimestamp(key)
    if not key then return nil end
    local ts = key:match("%-(%d+)$")
    if ts then return tonumber(ts) end
    return nil
end

local function IsKeyValid(key)
    if not key or key == "" then return false end
    if key == MASTER_KEY then return true end
    if not key:match("^ADMIN%-.+%-%d+$") then return false end
    local ts = GetKeyTimestamp(key)
    if not ts then return false end
    local age = os.time() - ts
    if age >= 86400 or age < 0 then return false end
    return true
end

local function SaveKey(key)
    pcall(function()
        if writefile then writefile(AUTH_FILE, key) end
    end)
end

local function LoadKey()
    local key = nil
    pcall(function()
        if isfile and readfile and isfile(AUTH_FILE) then
            key = readfile(AUTH_FILE)
        end
    end)
    return key
end

local function DeleteKey()
    pcall(function()
        if delfile and isfile and isfile(AUTH_FILE) then delfile(AUTH_FILE) end
    end)
end

-- UI Helper Functions
local function Tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time), props):Play()
end

local function Create(class, parent, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local function AddCorner(parent, radius)
    return Create("UICorner", parent, {CornerRadius = UDim.new(0, radius or 8)})
end

-- NOUVEAU: Palette de couleurs moderne (Violet/Cyan)
local Colors = {
    Background = Color3.fromRGB(15, 15, 25),
    Secondary = Color3.fromRGB(25, 25, 40),
    Accent = Color3.fromRGB(138, 43, 226),  -- Violet
    AccentLight = Color3.fromRGB(180, 100, 255),
    Success = Color3.fromRGB(0, 230, 180),  -- Cyan
    Warning = Color3.fromRGB(255, 170, 0),
    Danger = Color3.fromRGB(255, 70, 100),
    Text = Color3.fromRGB(245, 245, 255),
    TextDim = Color3.fromRGB(160, 160, 180),
    Border = Color3.fromRGB(100, 60, 180)
}

-- Create Main UI
local function CreateUI()
    if game:GetService("CoreGui"):FindFirstChild("AdminPanel") then
        game:GetService("CoreGui").AdminPanel:Destroy()
    end
    
    local GUI = Create("ScreenGui", game:GetService("CoreGui"), {Name = "AdminPanel", ResetOnSpawn = false})
    
    -- Login Frame
    local LoginFrame = Create("Frame", GUI, {
        Name = "Login",
        Size = UDim2.new(0, 340, 0, 220),
        Position = UDim2.new(0.5, -170, 0.5, -110),
        BackgroundColor3 = Colors.Background
    })
    AddCorner(LoginFrame, 12)
    Create("UIStroke", LoginFrame, {Color = Colors.Border, Thickness = 2})
    
    Create("TextLabel", LoginFrame, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = "🔐 ADMIN PANEL",
        TextColor3 = Colors.AccentLight,
        TextSize = 22,
        Font = Enum.Font.GothamBold
    })
    
    local KeyInput = Create("TextBox", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 38),
        Position = UDim2.new(0.05, 0, 0, 60),
        BackgroundColor3 = Colors.Secondary,
        PlaceholderText = "🔑 Enter your key...",
        PlaceholderColor3 = Colors.TextDim,
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    })
    AddCorner(KeyInput, 8)
    
    local LoginBtn = Create("TextButton", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 38),
        Position = UDim2.new(0.05, 0, 0, 110),
        BackgroundColor3 = Colors.Accent,
        Text = "LOGIN",
        TextColor3 = Colors.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold
    })
    AddCorner(LoginBtn, 8)
    
    local GetKeyBtn = Create("TextButton", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 38),
        Position = UDim2.new(0.05, 0, 0, 160),
        BackgroundColor3 = Colors.Success,
        Text = "GET KEY",
        TextColor3 = Colors.Background,
        TextSize = 15,
        Font = Enum.Font.GothamBold
    })
    AddCorner(GetKeyBtn, 8)
    
    -- Main Frame
    local MainFrame = Create("Frame", GUI, {
        Name = "Main",
        Size = UDim2.new(0, 370, 0, 520),
        Position = UDim2.new(0, 20, 0.5, -260),
        BackgroundColor3 = Colors.Background,
        Visible = false
    })
    AddCorner(MainFrame, 14)
    Create("UIStroke", MainFrame, {Color = Colors.Border, Thickness = 2})
    
    -- Header
    local Header = Create("Frame", MainFrame, {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Colors.Secondary
    })
    AddCorner(Header, 14)
    
    Create("TextLabel", Header, {
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Position = UDim2.new(0, 15, 0, 5),
        BackgroundTransparency = 1,
        Text = "⚡ ADMIN PANEL",
        TextColor3 = Colors.AccentLight,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TimerLabel = Create("TextLabel", Header, {
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Position = UDim2.new(0, 15, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "⏰ Key: --:--:--",
        TextColor3 = Colors.Success,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local MinimizeBtn = Create("TextButton", Header, {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -42, 0, 11),
        BackgroundColor3 = Colors.Danger,
        Text = "—",
        TextColor3 = Colors.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold
    })
    AddCorner(MinimizeBtn, 8)
    
    -- Content
    local Content = Create("ScrollingFrame", MainFrame, {
        Size = UDim2.new(1, -20, 1, -65),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 1600),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", Content, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    
    -- Mini Button
    local MiniBtn = Create("TextButton", GUI, {
        Name = "Mini",
        Size = UDim2.new(0, 55, 0, 55),
        Position = UDim2.new(0, 20, 0.5, -27),
        BackgroundColor3 = Colors.Accent,
        Text = "⚡",
        TextColor3 = Colors.Text,
        TextSize = 28,
        Visible = false
    })
    AddCorner(MiniBtn, 12)
    Create("UIStroke", MiniBtn, {Color = Colors.Border, Thickness = 2})
    
    return {
        GUI = GUI,
        LoginFrame = LoginFrame,
        KeyInput = KeyInput,
        LoginBtn = LoginBtn,
        GetKeyBtn = GetKeyBtn,
        MainFrame = MainFrame,
        Header = Header,
        Content = Content,
        MinimizeBtn = MinimizeBtn,
        MiniBtn = MiniBtn,
        TimerLabel = TimerLabel
    }
end

-- UI Components
local function CreateSection(parent, title, order)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Secondary,
        LayoutOrder = order
    })
    AddCorner(frame, 8)
    Create("TextLabel", frame, {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.AccentLight,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return frame
end

local function CreateToggle(parent, title, order, callback, default)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Secondary,
        LayoutOrder = order
    })
    AddCorner(frame, 8)
    
    Create("TextLabel", frame, {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleBtn = Create("TextButton", frame, {
        Size = UDim2.new(0, 52, 0, 26),
        Position = UDim2.new(1, -62, 0.5, -13),
        BackgroundColor3 = default and Colors.Success or Color3.fromRGB(50, 50, 70),
        Text = ""
    })
    AddCorner(toggleBtn, 13)
    
    local circle = Create("Frame", toggleBtn, {
        Size = UDim2.new(0, 22, 0, 22),
        Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
        BackgroundColor3 = Colors.Text
    })
    AddCorner(circle, 11)
    
    local enabled = default or false
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Tween(circle, 0.2, {Position = enabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)})
        Tween(toggleBtn, 0.2, {BackgroundColor3 = enabled and Colors.Success or Color3.fromRGB(50, 50, 70)})
        if callback then callback(enabled) end
        SaveSettings() -- NOUVEAU: Sauvegarde automatique
    end)
    
    return frame
end

local function CreateSlider(parent, title, min, max, default, order, callback)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Colors.Secondary,
        LayoutOrder = order
    })
    AddCorner(frame, 8)
    
    Create("TextLabel", frame, {
        Size = UDim2.new(0.7, 0, 0, 26),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", frame, {
        Size = UDim2.new(0.3, -10, 0, 26),
        Position = UDim2.new(0.7, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Colors.AccentLight,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBG = Create("Frame", frame, {
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    })
    AddCorner(sliderBG, 4)
    
    local sliderFill = Create("Frame", sliderBG, {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent
    })
    AddCorner(sliderFill, 4)
    
    local sliderKnob = Create("Frame", sliderBG, {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9),
        BackgroundColor3 = Colors.Text
    })
    AddCorner(sliderKnob, 9)
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
        SaveSettings() -- NOUVEAU: Sauvegarde automatique
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

local function CreateButton(parent, title, order, callback)
    local btn = Create("TextButton", parent, {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Colors.Accent,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        LayoutOrder = order
    })
    AddCorner(btn, 8)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

-- Feature Functions
local function EnableFly(enabled)
    Settings.Fly = enabled
    local char = LP.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    if enabled then
        local bodyGyro = Create("BodyGyro", hrp, {
            Name = "FlyGyro",
            MaxTorque = Vector3.new(1e9, 1e9, 1e9),
            P = 9e4,
            CFrame = hrp.CFrame
        })
        local bodyVel = Create("BodyVelocity", hrp, {
            Name = "FlyVelocity",
            MaxForce = Vector3.new(1e9, 1e9, 1e9),
            Velocity = Vector3.zero
        })
        humanoid.PlatformStand = true
        
        Connections.Fly = RunService.RenderStepped:Connect(function()
            if not Settings.Fly then return end
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
            bodyVel.Velocity = direction.Magnitude > 0 and direction.Unit * Settings.FlySpeed or Vector3.zero
            bodyGyro.CFrame = Camera.CFrame
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
        local bg = hrp:FindFirstChild("FlyGyro")
        local bv = hrp:FindFirstChild("FlyVelocity")
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        humanoid.PlatformStand = false
    end
end

local function EnableNoClip(enabled)
    Settings.NoClip = enabled
    if enabled then
        Connections.NoClip = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.NoClip then Connections.NoClip:Disconnect() Connections.NoClip = nil end
        local char = LP.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function EnableInfJump(enabled)
    Settings.InfJump = enabled
    if enabled then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
    end
end

local function SetWalkSpeed(value)
    Settings.WalkSpeed = value
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = value end
    end
end

local function SetJumpPower(value)
    Settings.JumpPower = value
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = value
        end
    end
end

-- AIMBOT
local function GetClosestPlayer()
    local closestTarget = nil
    local closestDistance = math.huge
    
    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local myPos = myHRP.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LP then
        else
            local skipPlayer = false
            if Settings.TeamCheck then
                if LP.Team and player.Team and LP.Team == player.Team then
                    skipPlayer = true
                end
            end
            
            if not skipPlayer and player.Character then
                local targetPart = player.Character:FindFirstChild(Settings.AimPart)
                if not targetPart then
                    targetPart = player.Character:FindFirstChild("Head")
                end
                
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if targetPart and humanoid and humanoid.Health > 0 then
                    local distance = (targetPart.Position - myPos).Magnitude
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                    
                    local inFOV = false
                    if Settings.AimFOV == 0 then
                        inFOV = true
                    elseif onScreen then
                        local centerX = Camera.ViewportSize.X / 2
                        local centerY = Camera.ViewportSize.Y / 2
                        local distFromCenter = math.sqrt((screenPos.X - centerX)^2 + (screenPos.Y - centerY)^2)
                        if distFromCenter <= Settings.AimFOV then
                            inFOV = true
                        end
                    end
                    
                    if inFOV and distance < closestDistance then
                        closestTarget = targetPart
                        closestDistance = distance
                    end
                end
            end
        end
    end
    
    if closestTarget then
        FocusedPlayer = Players:GetPlayerFromCharacter(closestTarget.Parent)
    else
        FocusedPlayer = nil
    end
    
    return closestTarget
end

local function HasLineOfSight(target)
    local char = LP.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head or not target then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}
    
    local direction = (target.Position - head.Position).Unit * 500
    local result = workspace:Raycast(head.Position, direction, rayParams)
    
    if result then
        if result.Instance:IsDescendantOf(target.Parent) then
            return true
        end
        return false
    end
    return true
end

local function EnableAimbot(enabled)
    Settings.Aimbot = enabled
    if enabled then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            if not Settings.Aimbot then return end
            
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = GetClosestPlayer()
                if target then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local delta = (targetPos - mousePos) * Settings.AimSmooth
                        
                        if mousemoverel then
                            mousemoverel(delta.X, delta.Y)
                        end
                        
                        if Settings.AutoClick then
                            if Settings.WallBang or HasLineOfSight(target) then
                                if mouse1click then
                                    mouse1click()
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if Connections.Aimbot then Connections.Aimbot:Disconnect() Connections.Aimbot = nil end
    end
end

local function DrawFOVCircle()
    local circle = nil
    pcall(function()
        if Drawing then
            circle = Drawing.new("Circle")
            circle.Visible = false
            circle.Radius = Settings.AimFOV
            circle.Color = Color3.fromRGB(138, 43, 226)
            circle.Thickness = 2
            circle.Transparency = 1
            circle.Filled = false
            
            Connections.FOVCircle = RunService.RenderStepped:Connect(function()
                circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                circle.Radius = Settings.AimFOV
                circle.Visible = Settings.Aimbot and Settings.AimFOV > 0
                if FocusedPlayer then
                    circle.Color = Color3.fromRGB(0, 230, 180)
                else
                    circle.Color = Color3.fromRGB(138, 43, 226)
                end
            end)
        end
    end)
end

-- Initialize
local function Init()
    -- NOUVEAU: Charger les paramètres sauvegardés
    LoadSettings()
    
    local UI = CreateUI()
    local CurrentKey = nil
    local TimerConnection = nil
    
    local function StartKeyTimer()
        if TimerConnection then TimerConnection:Disconnect() end
        if not CurrentKey or CurrentKey == MASTER_KEY then
            UI.TimerLabel.Text = "⏰ Key: UNLIMITED"
            UI.TimerLabel.TextColor3 = Colors.Success
            return
        end
        local ts = GetKeyTimestamp(CurrentKey)
        if not ts then return end
        
        TimerConnection = RunService.Heartbeat:Connect(function()
            local now = os.time()
            local left = 86400 - (now - ts)
            if left <= 0 then
                UI.TimerLabel.Text = "❌ KEY EXPIRED!"
                UI.TimerLabel.TextColor3 = Colors.Danger
                TimerConnection:Disconnect()
                DeleteKey()
                wait(2)
                UI.MainFrame.Visible = false
                UI.LoginFrame.Visible = true
                return
            end
            local h = math.floor(left / 3600)
            local m = math.floor((left % 3600) / 60)
            local s = left % 60
            UI.TimerLabel.Text = string.format("⏰ Key: %02d:%02d:%02d", h, m, s)
            if left < 300 then
                UI.TimerLabel.TextColor3 = Colors.Danger
            elseif left < 3600 then
                UI.TimerLabel.TextColor3 = Colors.Warning
            else
                UI.TimerLabel.TextColor3 = Colors.Success
            end
        end)
    end
    
    local function ShowMainPanel(key)
        CurrentKey = key
        UI.LoginFrame.Visible = false
        UI.MainFrame.Visible = true
        UI.MainFrame.Position = UDim2.new(0, -400, 0.5, -260)
        Tween(UI.MainFrame, 0.5, {Position = UDim2.new(0, 20, 0.5, -260)})
        StartKeyTimer()
    end
    
    -- Check saved key
    local savedKey = LoadKey()
    if savedKey and IsKeyValid(savedKey) then
        ShowMainPanel(savedKey)
    else
        if savedKey then DeleteKey() end
        
        UI.LoginBtn.MouseButton1Click:Connect(function()
            local key = UI.KeyInput.Text
            if IsKeyValid(key) then
                SaveKey(key)
                ShowMainPanel(key)
            else
                UI.KeyInput.BackgroundColor3 = Colors.Danger
                UI.KeyInput.Text = "❌ INVALID KEY"
                wait(1)
                UI.KeyInput.BackgroundColor3 = Colors.Secondary
                UI.KeyInput.Text = ""
            end
        end)
        
        UI.GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard("https://your-site.com/page1.html") end
            UI.GetKeyBtn.Text = "✓ Link Copied!"
            wait(2)
            UI.GetKeyBtn.Text = "GET KEY"
        end)
    end
    
    -- Minimize/Maximize
    UI.MinimizeBtn.MouseButton1Click:Connect(function()
        UI.MainFrame.Visible = false
        UI.MiniBtn.Visible = true
    end)
    
    UI.MiniBtn.MouseButton1Click:Connect(function()
        UI.MiniBtn.Visible = false
        UI.MainFrame.Visible = true
    end)
    
    -- Draggable
    local dragging, dragStart, startPos
    UI.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = UI.MainFrame.Position
        end
    end)
    UI.Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            UI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Build UI
    local order = 0
    
    CreateSection(UI.Content, "⚡ MOVEMENT", order) order = order + 1
    CreateToggle(UI.Content, "✈️ Fly", order, EnableFly, Settings.Fly) order = order + 1
    
    -- Fly Key
    local flyKeyFrame = Create("Frame", UI.Content, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Colors.Secondary,
        LayoutOrder = order
    })
    AddCorner(flyKeyFrame, 8)
    Create("TextLabel", flyKeyFrame, {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔑 Fly Key",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local flyKeyBtn = Create("TextButton", flyKeyFrame, {
        Size = UDim2.new(0.35, 0, 0, 30),
        Position = UDim2.new(0.6, 0, 0.5, -15),
        BackgroundColor3 = Colors.Accent,
        Text = Settings.FlyKey.Name,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    AddCorner(flyKeyBtn, 8)
    
    local waitingForKey = false
    flyKeyBtn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        flyKeyBtn.Text = "..."
        flyKeyBtn.BackgroundColor3 = Colors.Warning
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.FlyKey = input.KeyCode
                flyKeyBtn.Text = input.KeyCode.Name
                flyKeyBtn.BackgroundColor3 = Colors.Accent
                waitingForKey = false
                conn:Disconnect()
                SaveSettings()
            end
        end)
    end)
    order = order + 1
    
    -- Fly Key Toggle
    Connections.FlyKeyToggle = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Settings.FlyKey then
            Settings.Fly = not Settings.Fly
            EnableFly(Settings.Fly)
        end
    end)
    
    CreateSlider(UI.Content, "🚀 Fly Speed", 10, 500, Settings.FlySpeed, order, function(v) Settings.FlySpeed = v end) order = order + 1
    CreateSlider(UI.Content, "🏃 Walk Speed", 16, 500, Settings.WalkSpeed, order, SetWalkSpeed) order = order + 1
    CreateSlider(UI.Content, "⬆️ Jump Power", 50, 500, Settings.JumpPower, order, SetJumpPower) order = order + 1
    CreateToggle(UI.Content, "♾️ Infinite Jump", order, EnableInfJump, Settings.InfJump) order = order + 1
    CreateToggle(UI.Content, "👻 NoClip", order, EnableNoClip, Settings.NoClip) order = order + 1
    
    CreateSection(UI.Content, "🎯 AIMBOT", order) order = order + 1
    CreateToggle(UI.Content, "🎯 Aimbot", order, EnableAimbot, Settings.Aimbot) order = order + 1
    CreateToggle(UI.Content, "👥 Team Check", order, function(v) Settings.TeamCheck = v SaveSettings() end, Settings.TeamCheck) order = order + 1
    CreateToggle(UI.Content, "🖱️ Auto-Click", order, function(v) Settings.AutoClick = v SaveSettings() end, Settings.AutoClick) order = order + 1
    CreateToggle(UI.Content, "💥 WallBang", order, function(v) Settings.WallBang = v SaveSettings() end, Settings.WallBang) order = order + 1
    CreateSlider(UI.Content, "⭕ FOV (0=Infinite)", 0, 500, Settings.AimFOV, order, function(v) Settings.AimFOV = v end) order = order + 1
    CreateSlider(UI.Content, "🎚️ Smoothness", 1, 100, Settings.AimSmooth * 100, order, function(v) Settings.AimSmooth = v / 100 end) order = order + 1
    
    CreateSection(UI.Content, "ℹ️ INFO", order) order = order + 1
    local infoLabel = Create("TextLabel", UI.Content, {
        Size = UDim2.new(1, 0, 0, 95),
        BackgroundColor3 = Colors.Secondary,
        Text = "✨ Paramètres sauvegardés automatiquement\n\n✈️ Fly: Appuie sur " .. Settings.FlyKey.Name .. "\n🎯 Aimbot: Maintiens Clic Droit\n👥 Team Check OFF = vise tout le monde\n👥 Team Check ON = ignore les coéquipiers",
        TextColor3 = Colors.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = order
    })
    AddCorner(infoLabel, 8)
    Create("UIPadding", infoLabel, {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
    
    -- Draw FOV Circle
    DrawFOVCircle()
    
    -- Character respawn handler - NOUVEAU: Réapplique les paramètres sauvegardés
    LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end
        wait(0.5)
        if Settings.WalkSpeed ~= 16 then SetWalkSpeed(Settings.WalkSpeed) end
        if Settings.JumpPower ~= 50 then SetJumpPower(Settings.JumpPower) end
        if Settings.Fly then EnableFly(true) end
        if Settings.NoClip then EnableNoClip(true) end
        if Settings.InfJump then EnableInfJump(true) end
        if Settings.Aimbot then EnableAimbot(true) end
    end)
end

Init()
