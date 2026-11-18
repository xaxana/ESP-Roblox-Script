local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_ENABLED = true
local MAX_DISTANCE = 1000

local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local function setupCharacter(character)
        if espObjects[player] then
            espObjects[player]:Destroy()
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.FillColor = Color3.fromRGB(0, 255, 100)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.65
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPInfo"
        billboard.Size = UDim2.fromOffset(150, 45)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = character:WaitForChild("Head")
        billboard.Parent = character

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.Parent = billboard

        espObjects[player] = {
            highlight = highlight,
            billboard = billboard,
            label = label
        }
    end

    if player.Character then
        setupCharacter(player.Character)
    end

    player.CharacterAdded:Connect(setupCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].highlight:Destroy()
        espObjects[player].billboard:Destroy()
        espObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local myRoot = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for player, objects in pairs(espObjects) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if root and myRoot and humanoid then
            local distance = (root.Position - myRoot.Position).Magnitude

            objects.highlight.Enabled = ESP_ENABLED and distance <= MAX_DISTANCE
            objects.billboard.Enabled = ESP_ENABLED and distance <= MAX_DISTANCE

            objects.label.Text = string.format(
                "%s\nHP: %d/%d | %dm",
                player.Name,
                math.floor(humanoid.Health),
                math.floor(humanoid.MaxHealth),
                math.floor(distance)
            )

            if humanoid.Health > 60 then
                objects.label.TextColor3 = Color3.fromRGB(0, 255, 100)
            elseif humanoid.Health > 25 then
                objects.label.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                objects.label.TextColor3 = Color3.fromRGB(255, 60, 60)
            end
        else
            objects.highlight.Enabled = false
            objects.billboard.Enabled = false
        end
    end
end)
