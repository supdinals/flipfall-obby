-- FLIPFALL client: F key + on-screen FLIP button, HUD timer, win banner.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flipEvent = ReplicatedStorage:WaitForChild("FlipEvent")
local gameEvent = ReplicatedStorage:WaitForChild("GameEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "FlipGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local flipButton = Instance.new("TextButton")
flipButton.Name = "FlipButton"
flipButton.Size = UDim2.fromOffset(120, 60)
flipButton.Position = UDim2.new(1, -140, 1, -90)
flipButton.Text = "FLIP!"
flipButton.TextScaled = true
flipButton.Font = Enum.Font.GothamBold
flipButton.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
flipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flipButton.Parent = gui
flipButton.Activated:Connect(function()
	flipEvent:FireServer()
end)

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.fromOffset(300, 44)
timerLabel.Position = UDim2.new(0.5, -150, 0, 12)
timerLabel.BackgroundTransparency = 0.4
timerLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
timerLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "Reach checkpoint 1 to start your run!"
timerLabel.Parent = gui

local banner = Instance.new("TextLabel")
banner.Name = "WinBanner"
banner.Size = UDim2.fromOffset(560, 90)
banner.Position = UDim2.new(0.5, -280, 0.35, 0)
banner.BackgroundTransparency = 0.25
banner.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
banner.TextColor3 = Color3.fromRGB(255, 215, 0)
banner.TextScaled = true
banner.Font = Enum.Font.GothamBold
banner.Visible = false
banner.Parent = gui

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		flipEvent:FireServer()
	end
end)

gameEvent.OnClientEvent:Connect(function(kind, elapsed)
	if kind == "win" then
		banner.Text = string.format("YOU BEAT FLIPFALL!\nTime: %.1f seconds", elapsed)
		banner.Visible = true
		task.wait(6)
		banner.Visible = false
	end
end)

RunService.RenderStepped:Connect(function()
	local start = player:GetAttribute("RunStart")
	if start then
		local elapsed = workspace:GetServerTimeNow() - start
		timerLabel.Text = string.format("TIME  %.1f", elapsed)
	end
end)
