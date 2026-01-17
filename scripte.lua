local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
    AimPart = "Head",
    AutoClick = false,
    WallBang = false,
    InfJump = false,
    FlyKey = Enum.KeyCode.F,
    Spectating = false,
    SpectateTarget = nil,
    OrbitTP = false,
    OrbitTarget = nil,
    OrbitDistance = 5,
    OrbitSpeed = 10
}

local Connections = {}
local OriginalTransparency = {}
local ESPObjects = {}
local FocusedPlayer = nil

local AUTH_FILE = "AP_Key_" .. LP.UserId .. ".txt"
local MASTER_KEY = "iygyiegfiygeyfgyeyf7089"

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

-- RED COLORS
local Colors = {
    Background = Color3.fromRGB(20, 0, 0),
    Secondary = Color3.fromRGB(40, 5, 5),
    Accent = Color3.fromRGB(150, 0, 0),
    AccentBright = Color3.fromRGB(200, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200),
    Toggle = Color3.fromRGB(100, 0, 0),
    ToggleOn = Color3.fromRGB(200, 50, 50),
    Stroke = Color3.fromRGB(255, 0, 0)
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
        Size = UDim2.new(0, 320, 0, 200),
        Position = UDim2.new(0.5, -160, 0.5, -100),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    Create("UIStroke", LoginFrame, {Color = Colors.Stroke, Thickness = 2})
    
    Create("TextLabel", LoginFrame, {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Text = "ADMIN PANEL",
        TextColor3 = Colors.Stroke,
        TextSize = 22,
        Font = Enum.Font.GothamBold
    })
    
    local KeyInput = Create("TextBox", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 35),
        Position = UDim2.new(0.05, 0, 0, 50),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    })
    
    local LoginBtn = Create("TextButton", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 35),
        Position = UDim2.new(0.05, 0, 0, 95),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Text = "LOGIN",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    
    local GetKeyBtn = Create("TextButton", LoginFrame, {
        Size = UDim2.new(0.9, 0, 0, 35),
        Position = UDim2.new(0.05, 0, 0, 140),
        BackgroundColor3 = Colors.AccentBright,
        BorderSizePixel = 0,
        Text = "GET KEY",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", GUI, {
        Name = "Main",
        Size = UDim2.new(0, 350, 0, 550),
        Position = UDim2.new(0, 20, 0.5, -275),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false
    })
    Create("UIStroke", MainFrame, {Color = Colors.Stroke, Thickness = 2})
    
    -- Header
    local Header = Create("Frame", MainFrame, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0
    })
    
    Create("TextLabel", Header, {
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = "ADMIN PANEL",
        TextColor3 = Colors.Stroke,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TimerLabel = Create("TextLabel", Header, {
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Position = UDim2.new(0, 10, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "Key: --:--:--",
        TextColor3 = Colors.ToggleOn,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local MinimizeBtn = Create("TextButton", Header, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundColor3 = Colors.AccentBright,
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = Colors.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold
    })
    
    -- Content
    local Content = Create("ScrollingFrame", MainFrame, {
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Stroke,
        CanvasSize = UDim2.new(0, 0, 0, 1800),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", Content, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    
    -- Mini Button
    local MiniBtn = Create("TextButton", GUI, {
        Name = "Mini",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Text = "+",
        TextColor3 = Colors.Text,
        TextSize = 24,
        Visible = false
    })
    Create("UIStroke", MiniBtn, {Color = Colors.Stroke, Thickness = 2})
    
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
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order
    })
    Create("TextLabel", frame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.Stroke,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return frame
end

local function CreateToggle(parent, title, order, callback, default)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order
    })
    
    Create("TextLabel", frame, {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleBtn = Create("TextButton", frame, {
        Size = UDim2.new(0, 50, 0, 22),
        Position = UDim2.new(1, -60, 0.5, -11),
        BackgroundColor3 = default and Colors.ToggleOn or Colors.Toggle,
        BorderSizePixel = 0,
        Text = ""
    })
    
    local circle = Create("Frame", toggleBtn, {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    
    local enabled = default or false
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Tween(circle, 0.15, {Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        Tween(toggleBtn, 0.15, {BackgroundColor3 = enabled and Colors.ToggleOn or Colors.Toggle})
        if callback then callback(enabled) end
    end)
    
    return frame
end

local function CreateSlider(parent, title, min, max, default, order, callback)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order
    })
    
    Create("TextLabel", frame, {
        Size = UDim2.new(0.7, 0, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", frame, {
        Size = UDim2.new(0.3, -10, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Colors.Stroke,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBG = Create("Frame", frame, {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundColor3 = Colors.Toggle,
        BorderSizePixel = 0
    })
    
    local sliderFill = Create("Frame", sliderBG, {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Stroke,
        BorderSizePixel = 0
    })
    
    local sliderKnob = Create("Frame", sliderBG, {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
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
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        LayoutOrder = order
    })
    
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.1, {BackgroundColor3 = Colors.AccentBright})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.1, {BackgroundColor3 = Colors.Accent})
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

local function CreateDropdown(parent, title, order)
    local frame = Create("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ClipsDescendants = true
    })
    
    local headerBtn = Create("TextButton", frame, {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "  " .. title .. " >",
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local innerContent = Create("Frame", frame, {
        Name = "Inner",
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1
    })
    local innerLayout = Create("UIListLayout", innerContent, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)})
    
    local open = false
    headerBtn.MouseButton1Click:Connect(function()
        open = not open
        headerBtn.Text = open and ("  " .. title .. " v") or ("  " .. title .. " >")
        local contentHeight = innerLayout.AbsoluteContentSize.Y
        Tween(frame, 0.2, {Size = open and UDim2.new(1, 0, 0, 35 + contentHeight + 10) or UDim2.new(1, 0, 0, 30)})
    end)
    
    local function updateSize()
        if open then
            local contentHeight = innerLayout.AbsoluteContentSize.Y
            frame.Size = UDim2.new(1, 0, 0, 35 + contentHeight + 10)
        end
    end
    
    return frame, innerContent, updateSize
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
        local bodyGyro = Create("BodyGyro", hrp, {Name = "FlyGyro", MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 9e4, CFrame = hrp.CFrame})
        local bodyVel = Create("BodyVelocity", hrp, {Name = "FlyVelocity", MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero})
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
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
        if hum then hum.UseJumpPower = true hum.JumpPower = value end
    end
end

local function EnableXRay(enabled)
    Settings.XRay = enabled
    if enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character or {}) then
                if not Players:GetPlayerFromCharacter(obj.Parent) and not Players:GetPlayerFromCharacter(obj.Parent and obj.Parent.Parent) then
                    if not OriginalTransparency[obj] then
                        OriginalTransparency[obj] = obj.Transparency
                    end
                    obj.Transparency = 0.7
                end
            end
        end
    else
        for obj, trans in pairs(OriginalTransparency) do
            if obj and obj.Parent then
                obj.Transparency = trans
            end
        end
        OriginalTransparency = {}
    end
end

-- ESP Functions
local function CreateESP(player)
    if player == LP then return end
    
    local function AddESP()
        if not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if ESPObjects[player] then
            for _, v in pairs(ESPObjects[player]) do
                if v then pcall(function() v:Destroy() end) end
            end
            ESPObjects[player] = nil
        end
        
        local esp = {}
        
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4, 6, 4)
        box.Transparency = 0.3
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Parent = game:GetService("CoreGui")
        esp.box = box
        
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = game:GetService("CoreGui")
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.4, 0)
        distLabel.Position = UDim2.new(0, 0, 0.6, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextStrokeTransparency = 0
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 12
        distLabel.Parent = billboard
        
        esp.billboard = billboard
        
        esp.connection = RunService.RenderStepped:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and hrp then
                local dist = math.floor((LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                distLabel.Text = "[" .. dist .. "m]"
            end
        end)
        
        ESPObjects[player] = esp
    end
    
    AddESP()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.ESP then AddESP() end
    end)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, v in pairs(ESPObjects[player]) do
            if typeof(v) == "RBXScriptConnection" then
                v:Disconnect()
            elseif v then
                pcall(function() v:Destroy() end)
            end
        end
        ESPObjects[player] = nil
    end
end

local function EnableESP(enabled)
    Settings.ESP = enabled
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
        Connections.ESPAdded = Players.PlayerAdded:Connect(function(player)
            task.wait(1)
            if Settings.ESP then CreateESP(player) end
        end)
        Connections.ESPRemoved = Players.PlayerRemoving:Connect(function(player)
            RemoveESP(player)
        end)
    else
        if Connections.ESPAdded then Connections.ESPAdded:Disconnect() Connections.ESPAdded = nil end
        if Connections.ESPRemoved then Connections.ESPRemoved:Disconnect() Connections.ESPRemoved = nil end
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
        ESPObjects = {}
    end
end

-- Player Functions
local function TeleportTo(player)
    if not player or player == LP then return end
    local myChar = LP.Character
    local theirChar = player.Character
    if not myChar or not theirChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local theirHRP = theirChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not theirHRP then return end
    myHRP.CFrame = theirHRP.CFrame * CFrame.new(3, 0, 0)
end

local function Spectate(player)
    if Settings.Spectating and Settings.SpectateTarget == player then
        Settings.Spectating = false
        Settings.SpectateTarget = nil
        Camera.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        return
    end
    if not player or player == LP then return end
    local theirChar = player.Character
    if not theirChar then return end
    local theirHum = theirChar:FindFirstChildOfClass("Humanoid")
    if not theirHum then return end
    Settings.Spectating = true
    Settings.SpectateTarget = player
    Camera.CameraSubject = theirHum
end

local function StopSpectate()
    Settings.Spectating = false
    Settings.SpectateTarget = nil
    Camera.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

local function Fling(player)
    if not player or player == LP then return end
    local myChar = LP.Character
    local theirChar = player.Character
    if not myChar or not theirChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local theirHRP = theirChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not theirHRP then return end
    
    local originalPos = myHRP.CFrame
    local angVel = Create("BodyAngularVelocity", myHRP, {
        Name = "FlingVel",
        MaxTorque = Vector3.new(1e9, 1e9, 1e9),
        AngularVelocity = Vector3.new(0, 9999, 0)
    })
    
    for _, p in pairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    
    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 1.5 then
            conn:Disconnect()
            if angVel then angVel:Destroy() end
            if myHRP then myHRP.CFrame = originalPos end
            for _, p in pairs(myChar:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
            return
        end
        if theirHRP and myHRP then
            myHRP.CFrame = theirHRP.CFrame
        end
    end)
end

-- Orbit TP Functions
local OrbitAngle = 0

local function EnableOrbitTP(enabled)
    Settings.OrbitTP = enabled
    if enabled then
        Connections.OrbitTP = RunService.RenderStepped:Connect(function()
            if not Settings.OrbitTP or not Settings.OrbitTarget then return end
            
            local targetChar = Settings.OrbitTarget.Character
            if not targetChar then return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end
            
            local myChar = LP.Character
            if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            
            -- Increment angle based on speed
            OrbitAngle = OrbitAngle + (Settings.OrbitSpeed / 10)
            if OrbitAngle >= 360 then OrbitAngle = 0 end
            
            -- Calculate orbit position
            local rad = math.rad(OrbitAngle)
            local offsetX = math.cos(rad) * Settings.OrbitDistance
            local offsetZ = math.sin(rad) * Settings.OrbitDistance
            
            local targetPos = targetHRP.Position
            local newPos = Vector3.new(targetPos.X + offsetX, targetPos.Y, targetPos.Z + offsetZ)
            
            -- Teleport and face target
            myHRP.CFrame = CFrame.new(newPos, targetPos)
        end)
    else
        if Connections.OrbitTP then Connections.OrbitTP:Disconnect() Connections.OrbitTP = nil end
    end
end

local function SetOrbitTarget(player)
    Settings.OrbitTarget = player
end

local function StopOrbitTP()
    Settings.OrbitTP = false
    Settings.OrbitTarget = nil
    if Connections.OrbitTP then Connections.OrbitTP:Disconnect() Connections.OrbitTP = nil end
end

-- Aimbot Functions
local function GetClosestPlayer()
    local closestTarget = nil
    local closestDistance = math.huge
    
    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local myPos = myHRP.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
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
        if result.Instance:IsDescendantOf(target.Parent) then return true end
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
                        local deltaX = (screenPos.X - mousePos.X) * 0.5
                        local deltaY = (screenPos.Y - mousePos.Y) * 0.5
                        
                        if mousemoverel then
                            mousemoverel(deltaX, deltaY)
                        end
                        
                        if Settings.AutoClick then
                            if Settings.WallBang or HasLineOfSight(target) then
                                if mouse1click then mouse1click() end
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
    pcall(function()
        if Drawing then
            local circle = Drawing.new("Circle")
            circle.Visible = false
            circle.Radius = Settings.AimFOV
            circle.Color = Color3.fromRGB(255, 0, 0)
            circle.Thickness = 2
            circle.Transparency = 1
            circle.Filled = false
            
            Connections.FOVCircle = RunService.RenderStepped:Connect(function()
                circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                circle.Radius = Settings.AimFOV
                circle.Visible = Settings.Aimbot and Settings.AimFOV > 0
                circle.Color = FocusedPlayer and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 0, 0)
            end)
        end
    end)
end

-- Initialize
local function Init()
    local UI = CreateUI()
    local CurrentKey = nil
    local TimerConnection = nil
    
    local function StartKeyTimer()
        if TimerConnection then TimerConnection:Disconnect() end
        if not CurrentKey or CurrentKey == MASTER_KEY then
            UI.TimerLabel.Text = "Key: UNLIMITED"
            UI.TimerLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            return
        end
        local ts = GetKeyTimestamp(CurrentKey)
        if not ts then return end
        
        TimerConnection = RunService.Heartbeat:Connect(function()
            local now = os.time()
            local left = 86400 - (now - ts)
            if left <= 0 then
                UI.TimerLabel.Text = "KEY EXPIRED!"
                UI.TimerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
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
            UI.TimerLabel.Text = string.format("Key: %02d:%02d:%02d", h, m, s)
            if left < 300 then
                UI.TimerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            elseif left < 3600 then
                UI.TimerLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            else
                UI.TimerLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end
    
    local function ShowMainPanel(key)
        CurrentKey = key
        UI.LoginFrame.Visible = false
        UI.MainFrame.Visible = true
        UI.MainFrame.Position = UDim2.new(0, -400, 0.5, -275)
        Tween(UI.MainFrame, 0.5, {Position = UDim2.new(0, 20, 0.5, -275)})
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
                UI.KeyInput.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                UI.KeyInput.Text = "INVALID KEY"
                wait(1)
                UI.KeyInput.BackgroundColor3 = Colors.Secondary
                UI.KeyInput.Text = ""
            end
        end)
        
        UI.GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard("https://your-site.com/page1.html") end
            UI.GetKeyBtn.Text = "Link Copied!"
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
    
    -- MOVEMENT
    CreateSection(UI.Content, "MOVEMENT", order) order = order + 1
    CreateToggle(UI.Content, "Fly", order, EnableFly) order = order + 1
    
    local flyKeyFrame = Create("Frame", UI.Content, {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order
    })
    Create("TextLabel", flyKeyFrame, {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Fly Key",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local flyKeyBtn = Create("TextButton", flyKeyFrame, {
        Size = UDim2.new(0.35, 0, 0, 25),
        Position = UDim2.new(0.6, 0, 0.5, -12.5),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Text = "F",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    local waitingForKey = false
    flyKeyBtn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        flyKeyBtn.Text = "..."
        flyKeyBtn.BackgroundColor3 = Colors.AccentBright
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.FlyKey = input.KeyCode
                flyKeyBtn.Text = input.KeyCode.Name
                flyKeyBtn.BackgroundColor3 = Colors.Accent
                waitingForKey = false
                conn:Disconnect()
            end
        end)
    end)
    order = order + 1
    
    Connections.FlyKeyToggle = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Settings.FlyKey then
            Settings.Fly = not Settings.Fly
            EnableFly(Settings.Fly)
        end
    end)
    
    CreateSlider(UI.Content, "Fly Speed", 10, 500, 50, order, function(v) Settings.FlySpeed = v end) order = order + 1
    CreateSlider(UI.Content, "Walk Speed", 16, 500, 16, order, SetWalkSpeed) order = order + 1
    CreateSlider(UI.Content, "Jump Power", 50, 500, 50, order, SetJumpPower) order = order + 1
    CreateToggle(UI.Content, "Infinite Jump", order, EnableInfJump) order = order + 1
    CreateToggle(UI.Content, "NoClip", order, EnableNoClip) order = order + 1
    
    -- VISION
    CreateSection(UI.Content, "VISION", order) order = order + 1
    CreateToggle(UI.Content, "X-Ray", order, EnableXRay) order = order + 1
    CreateToggle(UI.Content, "ESP", order, EnableESP) order = order + 1
    
    -- AIMBOT
    CreateSection(UI.Content, "AIMBOT", order) order = order + 1
    CreateToggle(UI.Content, "Aimbot", order, EnableAimbot) order = order + 1
    CreateToggle(UI.Content, "Auto-Click", order, function(v) Settings.AutoClick = v end) order = order + 1
    CreateToggle(UI.Content, "WallBang", order, function(v) Settings.WallBang = v end) order = order + 1
    CreateSlider(UI.Content, "FOV (0=Infinite)", 0, 500, 100, order, function(v) Settings.AimFOV = v end) order = order + 1
    
    local aimPartDrop, aimPartContent, aimPartUpdate = CreateDropdown(UI.Content, "Aim Part", order)
    order = order + 1
    for _, part in pairs({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}) do
        CreateButton(aimPartContent, part, 0, function() Settings.AimPart = part end)
    end
    task.wait(0.1)
    aimPartUpdate()
    
    -- ORBIT TP
    CreateSection(UI.Content, "ORBIT TP", order) order = order + 1
    CreateToggle(UI.Content, "Orbit TP", order, EnableOrbitTP) order = order + 1
    CreateSlider(UI.Content, "Distance", 1, 20, 5, order, function(v) Settings.OrbitDistance = v end) order = order + 1
    CreateSlider(UI.Content, "Speed", 1, 50, 10, order, function(v) Settings.OrbitSpeed = v end) order = order + 1
    
    local orbitSearchBox = Create("TextBox", UI.Content, {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        PlaceholderText = "Search target for Orbit...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        LayoutOrder = order
    })
    order = order + 1
    
    local orbitSearchResults = Create("Frame", UI.Content, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ClipsDescendants = true
    })
    Create("UIListLayout", orbitSearchResults, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    order = order + 1
    
    local orbitTargetLabel = Create("TextLabel", UI.Content, {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Text = "Target: None",
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        LayoutOrder = order
    })
    order = order + 1
    
    local function UpdateOrbitSearch(query)
        for _, c in pairs(orbitSearchResults:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        if query == "" then
            orbitSearchResults.Size = UDim2.new(1, 0, 0, 0)
            return
        end
        local results = {}
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LP and string.lower(pl.Name):find(string.lower(query)) then
                table.insert(results, pl)
            end
        end
        local count = 0
        for _, pl in pairs(results) do
            if count >= 5 then break end
            local btn = CreateButton(orbitSearchResults, pl.Name, count, function()
                SetOrbitTarget(pl)
                orbitTargetLabel.Text = "Target: " .. pl.Name
                orbitTargetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                orbitSearchBox.Text = ""
                orbitSearchResults.Size = UDim2.new(1, 0, 0, 0)
            end)
            count = count + 1
        end
        orbitSearchResults.Size = UDim2.new(1, 0, 0, count * 32)
    end
    orbitSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateOrbitSearch(orbitSearchBox.Text)
    end)
    
    CreateButton(UI.Content, "Stop Orbit TP", order, function()
        StopOrbitTP()
        orbitTargetLabel.Text = "Target: None"
        orbitTargetLabel.TextColor3 = Colors.Text
    end)
    order = order + 1
    
    -- PLAYERS
    CreateSection(UI.Content, "PLAYERS", order) order = order + 1
    
    local searchBox = Create("TextBox", UI.Content, {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        PlaceholderText = "Search player...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        LayoutOrder = order
    })
    order = order + 1
    
    local searchResults = Create("Frame", UI.Content, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ClipsDescendants = true
    })
    Create("UIListLayout", searchResults, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    order = order + 1
    
    local function UpdateSearch(query)
        for _, c in pairs(searchResults:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        if query == "" then
            searchResults.Size = UDim2.new(1, 0, 0, 0)
            return
        end
        local results = {}
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LP and string.lower(pl.Name):find(string.lower(query)) then
                table.insert(results, pl)
            end
        end
        local count = 0
        for _, pl in pairs(results) do
            if count >= 5 then break end
            local btn = CreateButton(searchResults, pl.Name, count, function()
                TeleportTo(pl)
                searchBox.Text = ""
                searchResults.Size = UDim2.new(1, 0, 0, 0)
            end)
            count = count + 1
        end
        searchResults.Size = UDim2.new(1, 0, 0, count * 32)
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSearch(searchBox.Text)
    end)
    
    local tpDrop, tpContent, tpUpdate = CreateDropdown(UI.Content, "Teleport To", order)
    order = order + 1
    local specDrop, specContent, specUpdate = CreateDropdown(UI.Content, "Spectate", order)
    order = order + 1
    local flingDrop, flingContent, flingUpdate = CreateDropdown(UI.Content, "Fling", order)
    order = order + 1
    
    CreateButton(UI.Content, "Stop Spectate", order, StopSpectate)
    order = order + 1
    
    local function UpdatePlayerLists()
        for _, c in pairs(tpContent:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, c in pairs(specContent:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, c in pairs(flingContent:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        local i = 0
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LP then
                CreateButton(tpContent, pl.Name, i, function() TeleportTo(pl) end)
                CreateButton(specContent, pl.Name, i, function() Spectate(pl) end)
                CreateButton(flingContent, pl.Name, i, function() Fling(pl) end)
                i = i + 1
            end
        end
        task.wait(0.1)
        tpUpdate()
        specUpdate()
        flingUpdate()
    end
    UpdatePlayerLists()
    Players.PlayerAdded:Connect(UpdatePlayerLists)
    Players.PlayerRemoving:Connect(UpdatePlayerLists)
    
    -- INFO
    CreateSection(UI.Content, "INFO", order) order = order + 1
    Create("TextLabel", UI.Content, {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Text = "Fly: Press F (customizable)\nAimbot: Hold Right Click\nKey expires in 24 hours",
        TextColor3 = Colors.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        LayoutOrder = order
    })
    
    DrawFOVCircle()
    
    LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end
        wait(0.5)
        if Settings.WalkSpeed ~= 16 then SetWalkSpeed(Settings.WalkSpeed) end
        if Settings.JumpPower ~= 50 then SetJumpPower(Settings.JumpPower) end
        if Settings.Fly then EnableFly(true) end
        if Settings.NoClip then EnableNoClip(true) end
    end)
end

Init()
