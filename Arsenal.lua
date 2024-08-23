-- Shorten the URL loading process
local function loadScript(url)
    return loadstring(game:HttpGet(url))()
end

-- Example usage for OrionLib
local OrionLib = loadScript('https://raw.githubusercontent.com/shlexware/Orion/main/source')
local function loadScript(url)
    return loadstring(game:HttpGet(url))()
end

local OrionLib = loadScript('https://raw.githubusercontent.com/shlexware/Orion/main/source')
local Window = OrionLib:MakeWindow({Name = "ayq", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- Services and Variables
local Players, Lighting, RunService, UserInputService, LocalPlayer, Camera = 
    game:GetService("Players"), 
    game:GetService("Lighting"), 
    game:GetService("RunService"), 
    game:GetService("UserInputService"), 
    game.Players.LocalPlayer, 
    workspace.CurrentCamera

local aimbotEnabled, espEnabled, fulbrightEnabled, rtxEnabled, flyEnabled = 
    false, false, false, false, false
local smoothness, fov, flySpeed, flyHeight = 0.1, 50, 10, 5

-- Helper Functions
local function setLighting(ambient, brightness, outdoorAmbient)
    Lighting.Ambient = ambient
    Lighting.Brightness = brightness
    Lighting.OutdoorAmbient = outdoorAmbient
end

local function createESP(part, color, transparency)
    if part:FindFirstChild("esp") then return end
    local esp = Instance.new("BoxHandleAdornment", part)
    esp.Name = "esp"
    esp.Size = part.Size
    esp.Color = color
    esp.Transparency = transparency
    esp.AlwaysOnTop = true
    esp.Visible = true
    esp.Adornee = part
end

local function applySmoothAimbot()
    local target = findBestTarget()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local aimPosition = target.Character.Head.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPosition), smoothness)
    end
end

local function handleFly(state)
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if state and humanoidRootPart then
        local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, flyHeight, 0)

        local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
        bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyGyro.CFrame = humanoidRootPart.CFrame

        RunService.RenderStepped:Connect(function()
            if state then
                local moveDirection = Vector3.new()
                local forward, right, up = Camera.CFrame.LookVector, Camera.CFrame.RightVector, Camera.CFrame.UpVector
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (forward * flySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (forward * flySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (right * flySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (right * flySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + (up * flySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - (up * flySpeed) end

                bodyVelocity.Velocity = moveDirection
                bodyGyro.CFrame = Camera.CFrame
            else
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
            end
        end)
    elseif not state and humanoidRootPart then
        humanoidRootPart:FindFirstChild("BodyVelocity"):Destroy()
        humanoidRootPart:FindFirstChild("BodyGyro"):Destroy()
    end
end

-- UI Setup
local AimTab = Window:MakeTab({Name = "Aim", Icon = "rbxassetid://4483345998"})
AimTab:AddSection({Name = "Aimbot"}):AddToggle({
    Name = "Aimbot", Default = false, Callback = function(state)
        aimbotEnabled = state
        print(aimbotEnabled and "Aimbot Enabled" or "Aimbot Disabled")
    end
})

local VisualTab = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://4483346000"})
local VisualSection = VisualTab:AddSection({Name = "Visuals"})

VisualSection:AddToggle({
    Name = "ESP", Default = false, Callback = function(state)
        espEnabled = state
        if espEnabled then
            print("ESP Enabled")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then createESP(part, BrickColor.new(50, 0, 250), 0.8) end
                    end
                end
            end
        else
            print("ESP Disabled")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:FindFirstChild("esp") then part.esp:Destroy() end
                    end
                end
            end
        end
    end
})

VisualSection:AddToggle({
    Name = "Fulbright", Default = false, Callback = function(state)
        fulbrightEnabled = state
        setLighting(
            fulbrightEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128),
            fulbrightEnabled and 2 or 1,
            fulbrightEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
        )
        print(fulbrightEnabled and "Fulbright Enabled" or "Fulbright Disabled")
    end
})

VisualSection:AddToggle({
    Name = "RTX", Default = false, Callback = function(state)
        rtxEnabled = state
        if rtxEnabled then
            print("RTX Enabled")
            setLighting(Color3.fromRGB(255, 255, 255), 2, Color3.fromRGB(255, 255, 255))
            local bloom = Instance.new("BloomEffect", Lighting)
            bloom.Name = "RTXBloom"
            bloom.Intensity = 0.5
            bloom.Size = 24
            bloom.Threshold = 0.8

            local colorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
            colorCorrection.Name = "RTXColorCorrection"
            colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
            colorCorrection.Saturation = 1.5
        else
            print("RTX Disabled")
            setLighting(Color3.fromRGB(128, 128, 128), 1, Color3.fromRGB(128, 128, 128))
            Lighting:FindFirstChild("RTXBloom"):Destroy()
            Lighting:FindFirstChild("RTXColorCorrection"):Destroy()
        end
    end
})

local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483346000"})
PlayerTab:AddSection({Name = "Player Actions"}):AddToggle({
    Name = "Fly", Default = false, Callback = handleFly
})

-- Continuously update aimbot if enabled
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        applySmoothAimbot()
    end
end)
