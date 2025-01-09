--[ Bens Menu 0.1 ]--
--[ Based Off ZaHa ]--

--[ Config ]--
local hacks = {"Fly", "Noclip", "TP To", "Change Speed", "Change Jump Height"}
local hacksEnabled = {}

local version = 0.1

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local p = Players.LocalPlayer
local g = p:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.Parent = g

local hacklist = Instance.new("ScrollingFrame")
hacklist.Size = UDim2.new(0, 200, 0, 200)
hacklist.Position = UDim2.new(0, 10, 0, 10)
hacklist.Parent = sg
hacklist.BackgroundTransparency = 0.5
hacklist.BackgroundColor3 = Color3.new(0.666667, 0, 1)
hacklist.ScrollBarThickness = 10

local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- Flying Variables
local flying = false
local speed = 50
local bodyVelocity
local bodyGyro

local TweenService = game:GetService("TweenService")

-- Create the title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 50) -- Adjust size as needed
titleLabel.Position = UDim2.new(0.5, -150, 0, 10) -- Centered at the top, adjust as needed
titleLabel.Text = "Ben's Mod Menu"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 0.5
titleLabel.BackgroundColor3 = Color3.new(0, 0, 0.498039)
titleLabel.Font = Enum.Font.LuckiestGuy
titleLabel.TextScaled = true
titleLabel.Parent = sg

-- Define the fade-out tween
local tweenInfo = TweenInfo.new(
	2, -- Duration (2 seconds)
	Enum.EasingStyle.Quad, -- Smooth easing style
	Enum.EasingDirection.Out -- Fade out direction
)

local fadeOutGoal = {
	TextTransparency = 1, -- Fully transparent text
	BackgroundTransparency = 1 -- Fully transparent background
}

-- Create and play the tween
local fadeOutTween = TweenService:Create(titleLabel, tweenInfo, fadeOutGoal)
task.delay(2, function() -- Wait for 2 seconds before fading out
	fadeOutTween:Play()
end)



-- Start Flying
local function startFlying()
	flying = true

	local character = p.Character or p.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")

	bodyVelocity = Instance.new("BodyVelocity", rootPart)
	bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
	bodyVelocity.Velocity = Vector3.zero

	bodyGyro = Instance.new("BodyGyro", rootPart)
	bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	bodyGyro.CFrame = rootPart.CFrame
end

-- Stop Flying
local function stopFlying()
	flying = false

	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
end

-- Handle Movement
RunService.RenderStepped:Connect(function()
	if hacksEnabled["Fly"] and flying then
		local moveDirection = Vector3.zero
		local UIS = game:GetService("UserInputService")

		-- Get input for movement
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end

		-- Normalize direction and apply speed
		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * speed
		else
			bodyVelocity.Velocity = Vector3.zero
		end

		-- Stabilize rotation to match camera's look direction
		bodyGyro.CFrame = CFrame.new(bodyGyro.CFrame.Position, bodyGyro.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector)
	elseif not hacksEnabled["Fly"] and flying then
		stopFlying()
	end
end)

-- UI for inputting values
local function createInputMenu(title, defaultValue, callback)
	local inputMenu = Instance.new("Frame")
	inputMenu.Size = UDim2.new(0, 200, 0, 80)
	inputMenu.Position = UDim2.new(0, 430, 0, 10)
	inputMenu.Parent = sg
	inputMenu.Visible = false
	inputMenu.BackgroundTransparency = 0.5
	inputMenu.BackgroundColor3 = Color3.new(0, 0, 0)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 200, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Text = title
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Parent = inputMenu

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 200, 0, 20)
	textBox.Position = UDim2.new(0, 0, 0, 30)
	textBox.Text = tostring(defaultValue)
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.BackgroundTransparency = 0.5
	textBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	textBox.Parent = inputMenu

	local confirmButton = Instance.new("TextButton")
	confirmButton.Size = UDim2.new(0, 200, 0, 20)
	confirmButton.Position = UDim2.new(0, 0, 0, 55)
	confirmButton.Text = "Confirm"
	confirmButton.TextColor3 = Color3.new(1, 1, 1)
	confirmButton.BackgroundTransparency = 0.5
	confirmButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	confirmButton.Parent = inputMenu

	confirmButton.MouseButton1Click:Connect(function()
		local value = tonumber(textBox.Text)
		if value then
			callback(value)
			inputMenu.Visible = false
		end
	end)

	return function(toggle)
		inputMenu.Visible = toggle
	end
end

local toggleSpeedMenu = createInputMenu("Change Speed", defaultWalkSpeed, function(value)
	if p.Character and p.Character:FindFirstChild("Humanoid") then
		p.Character.Humanoid.WalkSpeed = value
		print("Walk Speed set to " .. value)
	end
end)

local toggleJumpMenu = createInputMenu("Change Jump Height", defaultJumpPower, function(value)
	if p.Character and p.Character:FindFirstChild("Humanoid") then
		p.Character.Humanoid.UseJumpPower = true
		p.Character.Humanoid.JumpPower = value
		print("Jump Height set to " .. value)
	end
end)

-- List Hacks
function listHacks()
	for i, v in pairs(hacks) do
		local hack = Instance.new("TextButton")
		hack.Size = UDim2.new(0, 200, 0, 20)
		hack.Position = UDim2.new(0, 0, 0, 20 * (i - 1))
		hack.Parent = hacklist
		hack.Text = v
		hack.Name = v
		hack.BackgroundColor3 = Color3.new(0, 0, 0.498039)
		hack.TextColor3 = Color3.new(1, 1, 1)
		hack.Font = Enum.Font.LuckiestGuy
		hack.TextScaled = true
		hacksEnabled[v] = false

		hack.MouseButton1Click:Connect(function()
			hacksEnabled[v] = not hacksEnabled[v]
			if hacksEnabled[v] then
				print(v .. " enabled")
				hack.BackgroundColor3 = Color3.new(1, 0, 0)

				if v == "Fly" then
					startFlying()
				elseif v == "Change Speed" then
					toggleSpeedMenu(true)
				elseif v == "Change Jump Height" then
					toggleJumpMenu(true)
				end
			else
				print(v .. " disabled")
				hack.BackgroundColor3 = Color3.new(0, 0, 0.498039)

				if v == "Fly" then
					stopFlying()
				elseif v == "Change Speed" then
					toggleSpeedMenu(false)
				elseif v == "Change Jump Height" then
					toggleJumpMenu(false)
				end
			end
		end)
	end
end

function setNoclip(enabled)
	if not p.Character then
		return
	end
	for _, part in pairs(p.Character:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = not enabled
		end
	end
end


listHacks()

RunService.RenderStepped:Connect(function()
	setNoclip(hacksEnabled["Noclip"])
end)

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, isProcessed)
	if not isProcessed and input.KeyCode == Enum.KeyCode.Z then
		sg.Enabled = not sg.Enabled -- Toggle visibility
	end
end)
