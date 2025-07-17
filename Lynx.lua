--[ Bens Menu 1.0 ]--
--[ Based Off ZaHa ]--

--[ Config ]--
local hacks = {"Fly", "Noclip", "TP To", "Change Speed", "Change Jump Height", "Kick Player", "Make Announcement", "Invincible"}
local hacksEnabled = {}

local version = 0.2

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

-- Add UI for Announcement Menu
local announceMenu = Instance.new("Frame")
announceMenu.Size = UDim2.new(0, 300, 0, 100)
announceMenu.Position = UDim2.new(0, 430, 0, 10)
announceMenu.Parent = sg
announceMenu.Visible = false
announceMenu.BackgroundTransparency = 0.5
announceMenu.BackgroundColor3 = Color3.new(0, 0, 0)

local announceLabel = Instance.new("TextLabel")
announceLabel.Size = UDim2.new(0, 300, 0, 20)
announceLabel.Position = UDim2.new(0, 0, 0, 0)
announceLabel.Text = "Enter Announcement Message"
announceLabel.TextColor3 = Color3.new(1, 1, 1)
announceLabel.BackgroundTransparency = 1
announceLabel.Parent = announceMenu

local announceBox = Instance.new("TextBox")
announceBox.Size = UDim2.new(0, 300, 0, 30)
announceBox.Position = UDim2.new(0, 0, 0, 30)
announceBox.PlaceholderText = "Type your message here..."
announceBox.Text = ""
announceBox.TextColor3 = Color3.new(1, 1, 1)
announceBox.BackgroundTransparency = 0.5
announceBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
announceBox.Parent = announceMenu

local announceButton = Instance.new("TextButton")
announceButton.Size = UDim2.new(0, 300, 0, 30)
announceButton.Position = UDim2.new(0, 0, 0, 70)
announceButton.Text = "Announce"
announceButton.TextColor3 = Color3.new(1, 1, 1)
announceButton.BackgroundTransparency = 0.5
announceButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
announceButton.Parent = announceMenu

-- Function to send an announcement
local function sendAnnouncement(message)
	for _, player in pairs(Players:GetPlayers()) do
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			local announcementLabel = Instance.new("TextLabel")
			announcementLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
			announcementLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
			announcementLabel.Text = message
			announcementLabel.TextColor3 = Color3.new(1, 1, 1)
			announcementLabel.BackgroundTransparency = 0.5
			announcementLabel.BackgroundColor3 = Color3.new(0, 0, 0)
			announcementLabel.Font = Enum.Font.LuckiestGuy
			announcementLabel.TextScaled = true
			announcementLabel.Parent = playerGui

			-- Fade out after 5 seconds
			local TweenService = game:GetService("TweenService")
			local fadeInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local fadeGoal = {TextTransparency = 1, BackgroundTransparency = 1}
			local fadeTween = TweenService:Create(announcementLabel, fadeInfo, fadeGoal)

			task.delay(5, function()
				fadeTween:Play()
				fadeTween.Completed:Connect(function()
					announcementLabel:Destroy()
				end)
			end)
		end
	end
end

-- Handle Announce Button Click
announceButton.MouseButton1Click:Connect(function()
	if announceBox.Text ~= "" then
		sendAnnouncement(announceBox.Text)
		announceBox.Text = "" -- Clear the text box
	else
		print("No message entered.")
	end
end)

-- Handle visibility for the Announcement Menu
local toggleAnnounceMenu = function(toggle)
	announceMenu.Visible = toggle
end

-- Invincible Logic
local invincibleConnection = nil

local function enableInvincible()
	local humanoid = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		invincibleConnection = humanoid.HealthChanged:Connect(function()
			if humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	end
end

local function disableInvincible()
	if invincibleConnection then
		invincibleConnection:Disconnect()
		invincibleConnection = nil
	end
end

-- UI for the Hack Menu
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

				if v == "Make Announcement" then
					toggleAnnounceMenu(true)
				elseif v == "Invincible" then
					enableInvincible()
				end
			else
				print(v .. " disabled")
				hack.BackgroundColor3 = Color3.new(0, 0, 0.498039)

				if v == "Make Announcement" then
					toggleAnnounceMenu(false)
				elseif v == "Invincible" then
					disableInvincible()
				end
			end
		end)
	end
end

listHacks()

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, isProcessed)
	if not isProcessed and input.KeyCode == Enum.KeyCode.Z then
		sg.Enabled = not sg.Enabled -- Toggle visibility
	end
end)


