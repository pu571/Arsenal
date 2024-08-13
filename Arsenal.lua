local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "ayq", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- Aim Tab
local AimTab = Window:MakeTab({
    Name = "Aim",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimSection = AimTab:AddSection({
    Name = "Aimbot"
})

local aimbotEnabled = false

-- Add a toggle switch for Aimbot
AimSection:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
        if aimbotEnabled then
            print("Aimbot Enabled")
        else
            print("Aimbot Disabled")
        end
    end    
})

-- Variables for Aimbot
local smoothness = 0.1 -- Adjust this for smoother or more aggressive aiming
local fov = 50 -- Field of view for targeting

-- Function to find the best target within FOV
local function findBestTarget()
    local player = game.Players.LocalPlayer
    local closestPlayer = nil
    local closestDistance = math.huge
    local camera = game.Workspace.CurrentCamera
    local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local playerTeam = player.Team
            local otherPlayerTeam = otherPlayer.Team
            if playerTeam and otherPlayerTeam and playerTeam ~= otherPlayerTeam then
                local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.Head.Position).magnitude
                local screenPosition, onScreen = camera:WorldToScreenPoint(otherPlayer.Character.Head.Position)
                
                if onScreen then
                    local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - centerScreen).magnitude
                    if screenDistance < fov and distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Function to apply smooth aimbot
local function applySmoothAimbot()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPlayer = findBestTarget()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local camera = game.Workspace.CurrentCamera
            local aimPosition = targetPlayer.Character.Head.Position
            local cameraPosition = camera.CFrame.Position
            local newCFrame = CFrame.new(cameraPosition, aimPosition)
            
            camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothness) -- Adjust the interpolation factor as needed
            
            print("Aiming at:", aimPosition) -- For debugging
        end
    end
end

-- Continuously update aimbot if enabled
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        applySmoothAimbot()
    end
end)

-- Visual Tab
local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://4483346000", -- Change to your desired icon ID
    PremiumOnly = false
})

local VisualSection = VisualTab:AddSection({
    Name = "Visuals"
})

local espEnabled = false
local fulbrightEnabled = false
local rtxEnabled = false

-- Add a toggle switch for ESP
VisualSection:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        local color = BrickColor.new(50, 0, 250)
        local transparency = .8

        local Players = game:GetService("Players")
        local localPlayer = game.Players.LocalPlayer

        local function _ESP(c)
            repeat wait() until c.PrimaryPart ~= nil
            for _, p in pairs(c:GetChildren()) do
                if p.ClassName == "Part" or p.ClassName == "MeshPart" then
                    if p:FindFirstChild("shit") then p.shit:Destroy() end
                    local a = Instance.new("BoxHandleAdornment", p)
                    a.Name = "shit"
                    a.Size = p.Size
                    a.Color = color
                    a.Transparency = transparency
                    a.AlwaysOnTop = true    
                    a.Visible = true    
                    a.Adornee = p
                    a.ZIndex = true    
                end
            end
        end

        local function ESP()
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= localPlayer and v.Character and v.Team ~= localPlayer.Team then
                    _ESP(v.Character)
                end
                v.CharacterAdded:Connect(function(chr)
                    if v.Team ~= localPlayer.Team then
                        _ESP(chr)
                    end
                end)
            end
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(chr)
                    if player.Team ~= localPlayer.Team then
                        _ESP(chr)
                    end
                end)  
            end)
        end
        
        if espEnabled then
            print("ESP Enabled")
            ESP()
        else
            print("ESP Disabled")
            -- Remove ESP elements
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= localPlayer and v.Character then
                    for _, part in pairs(v.Character:GetChildren()) do
                        if part:FindFirstChild("shit") then
                            part.shit:Destroy()
                        end
                    end
                end
            end
        end
    end    
})

-- Add a toggle switch for Fulbright
VisualSection:AddToggle({
    Name = "Fulbright",
    Default = false,
    Callback = function(state)
        fulbrightEnabled = state
        local lighting = game:GetService("Lighting")
        if fulbrightEnabled then
            print("Fulbright Enabled")
            lighting.Ambient = Color3.fromRGB(255, 255, 255) -- Full brightness ambient light
            lighting.Brightness = 2 -- Increase brightness
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) -- Full brightness outdoor ambient light
        else
            print("Fulbright Disabled")
            lighting.Ambient = Color3.fromRGB(128, 128, 128) -- Default ambient light
            lighting.Brightness = 1 -- Default brightness
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128) -- Default outdoor ambient light
        end
    end    
})

-- Add a toggle switch for RTX
VisualSection:AddToggle({
    Name = "RTX",
    Default = false,
    Callback = function(state)
        rtxEnabled = state
        local lighting = game:GetService("Lighting")
        if rtxEnabled then
            print("RTX Enabled")
            lighting.Ambient = Color3.fromRGB(255, 255, 255) -- Bright ambient light
            lighting.Brightness = 2 -- Increased brightness
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) -- Bright outdoor ambient light

            -- Add Bloom effect
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "RTXBloom"
            bloom.Intensity = 0.5
            bloom.Size = 24
            bloom.Threshold = 0.8
            bloom.Parent = lighting

            -- Add ColorCorrection effect
            local colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Name = "RTXColorCorrection"
            colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
            colorCorrection.Saturation = 1.5
            colorCorrection.Parent = lighting
        else
            print("RTX Disabled")
            lighting.Ambient = Color3.fromRGB(128, 128, 128) -- Default ambient light
            lighting.Brightness = 1 -- Default brightness
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128) -- Default outdoor ambient light

            -- Remove RTX effects
            local bloom = lighting:FindFirstChild("RTXBloom")
            if bloom then
                bloom:Destroy()
            end

            local colorCorrection = lighting:FindFirstChild("RTXColorCorrection")
            if colorCorrection then
                colorCorrection:Destroy()
            end
        end
    end    
})

-- Player Tab
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483346000", -- Change to your desired icon ID
    PremiumOnly = false
})

local PlayerSection = PlayerTab:AddSection({
    Name = "Player Actions"
})

local flyEnabled = false

-- Add a toggle switch for Fly
PlayerSection:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        flyEnabled = state
        if flyEnabled then
            print("Fly Enabled")
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                local flying = true
                local flySpeed = 10 -- Adjust this for slower speed
                local flyHeight = 5 -- Adjust this for height

                local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, flyHeight, 0)

                local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
                bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
                bodyGyro.CFrame = humanoidRootPart.CFrame

                -- Controls
                local uis = game:GetService("UserInputService")
                local rs = game:GetService("RunService")

                local moveDirection = Vector3.new()
                local flyDirection = Vector3.new()

                rs.RenderStepped:Connect(function()
                    if flyEnabled then
                        -- Adjust fly speed and direction
                        local camera = game.Workspace.CurrentCamera
                        local forward = camera.CFrame.LookVector
                        local right = camera.CFrame.RightVector
                        local up = camera.CFrame.UpVector

                        moveDirection = Vector3.new() -- Reset move direction

                        if uis:IsKeyDown(Enum.KeyCode.W) then
                            moveDirection = moveDirection + (forward * flySpeed)
                        end
                        if uis:IsKeyDown(Enum.KeyCode.S) then
                            moveDirection = moveDirection - (forward * flySpeed)
                        end
                        if uis:IsKeyDown(Enum.KeyCode.A) then
                            moveDirection = moveDirection - (right * flySpeed)
                        end
                        if uis:IsKeyDown(Enum.KeyCode.D) then
                            moveDirection = moveDirection + (right * flySpeed)
                        end
                        if uis:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + (up * flySpeed)
                        end
                        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then
                            moveDirection = moveDirection - (up * flySpeed)
                        end

                        bodyVelocity.Velocity = moveDirection
                        bodyGyro.CFrame = game.Workspace.CurrentCamera.CFrame
                    else
                        -- Cleanup
                        if humanoidRootPart then
                            bodyVelocity:Destroy()
                            bodyGyro:Destroy()
                        end
                    end
                end)
            end
        else
            print("Fly Disabled")
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                -- Cleanup
                local bodyVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")
                local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro")
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
            end
        end
    end
})
