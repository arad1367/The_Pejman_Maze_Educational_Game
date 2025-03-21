-- PlayerController.lua --> put this script in StarterPlayerScripts --> This script manage each player inventory
-- It means we must use localscript

--[[
   The Pejman Maze Educational Game
   
   An educational maze game with AI quiz questions and interactive challenges.
   Developed at the University of Liechtenstein.
   
   Creator: Dr. Pejman Ebrahimi
   Email: pejman.ebrahimi@uni.li
   Department of Information Systems & Computer Science
]]--


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Make sure all required RemoteEvents exist
if not remoteEvents:FindFirstChild("MonsterQuestion") then
	local monsterQuestionEvent = Instance.new("RemoteEvent")
	monsterQuestionEvent.Name = "MonsterQuestion"
	monsterQuestionEvent.Parent = remoteEvents
end

if not remoteEvents:FindFirstChild("AnswerMonsterQuestion") then
	local answerEvent = Instance.new("RemoteEvent")
	answerEvent.Name = "AnswerMonsterQuestion"
	answerEvent.Parent = remoteEvents
end

local character = player.Character or player.CharacterAdded:Wait()
-- Player inventory
local inventory = {
	speedBoosts = 0,
	hintTokens = 0,
	mapViews = 0
}
-- Variables for timer
local timerRunning = false
local startTime = 0
-- Create current question data holder
local currentQuestion = nil
-- Create main UI
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "MazeGameUI"
mainGui.ResetOnSpawn = false
mainGui.Parent = playerGui

-- Create HUD frame
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD"
hudFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
hudFrame.Position = UDim2.new(0.01, 0, 0.01, 0)
hudFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hudFrame.BackgroundTransparency = 0.5
hudFrame.BorderSizePixel = 0
hudFrame.Parent = mainGui

-- Create timer display
local timerFrame = Instance.new("Frame")
timerFrame.Name = "TimerFrame"
timerFrame.Size = UDim2.new(1, 0, 0.2, 0)
timerFrame.BackgroundTransparency = 1
timerFrame.Parent = hudFrame

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Time: 00:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 18
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = timerFrame

-- Create score display
local scoreFrame = Instance.new("Frame")
scoreFrame.Name = "ScoreFrame"
scoreFrame.Size = UDim2.new(1, 0, 0.2, 0)
scoreFrame.Position = UDim2.new(0, 0, 0.2, 0)
scoreFrame.BackgroundTransparency = 1
scoreFrame.Parent = hudFrame

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "ScoreLabel"
scoreLabel.Size = UDim2.new(1, 0, 1, 0)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Score: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.TextSize = 18
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.Parent = scoreFrame

-- Create inventory display
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryFrame"
inventoryFrame.Size = UDim2.new(1, 0, 0.5, 0)
inventoryFrame.Position = UDim2.new(0, 0, 0.5, 0)
inventoryFrame.BackgroundTransparency = 0.5
inventoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inventoryFrame.BorderSizePixel = 0
inventoryFrame.Parent = hudFrame

local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.Name = "InventoryTitle"
inventoryTitle.Size = UDim2.new(1, 0, 0.2, 0)
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Text = "INVENTORY"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryTitle.TextSize = 14
inventoryTitle.Font = Enum.Font.GothamBold
inventoryTitle.Parent = inventoryFrame

-- Speed Boost Item
local speedBoostFrame = Instance.new("Frame")
speedBoostFrame.Name = "SpeedBoostFrame"
speedBoostFrame.Size = UDim2.new(1, 0, 0.25, 0)
speedBoostFrame.Position = UDim2.new(0, 0, 0.2, 0)
speedBoostFrame.BackgroundTransparency = 1
speedBoostFrame.Parent = inventoryFrame

local speedBoostButton = Instance.new("TextButton")
speedBoostButton.Name = "SpeedBoostButton"
speedBoostButton.Size = UDim2.new(0.7, 0, 1, 0)
speedBoostButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Yellow
speedBoostButton.BackgroundTransparency = 0.5
speedBoostButton.Text = "Speed: 0"
speedBoostButton.TextColor3 = Color3.fromRGB(0, 0, 0)
speedBoostButton.TextSize = 14
speedBoostButton.Font = Enum.Font.GothamBold
speedBoostButton.Parent = speedBoostFrame

-- Hint Token Item
local hintTokenFrame = Instance.new("Frame")
hintTokenFrame.Name = "HintTokenFrame"
hintTokenFrame.Size = UDim2.new(1, 0, 0.25, 0)
hintTokenFrame.Position = UDim2.new(0, 0, 0.45, 0)
hintTokenFrame.BackgroundTransparency = 1
hintTokenFrame.Parent = inventoryFrame

local hintTokenButton = Instance.new("TextButton")
hintTokenButton.Name = "HintTokenButton"
hintTokenButton.Size = UDim2.new(0.7, 0, 1, 0)
hintTokenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255) -- Blue
hintTokenButton.BackgroundTransparency = 0.5
hintTokenButton.Text = "Hints: 0"
hintTokenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hintTokenButton.TextSize = 14
hintTokenButton.Font = Enum.Font.GothamBold
hintTokenButton.Parent = hintTokenFrame

-- Map View Item
local mapViewFrame = Instance.new("Frame")
mapViewFrame.Name = "MapViewFrame"
mapViewFrame.Size = UDim2.new(1, 0, 0.25, 0)
mapViewFrame.Position = UDim2.new(0, 0, 0.7, 0)
mapViewFrame.BackgroundTransparency = 1
mapViewFrame.Parent = inventoryFrame

local mapViewButton = Instance.new("TextButton")
mapViewButton.Name = "MapViewButton"
mapViewButton.Size = UDim2.new(0.7, 0, 1, 0)
mapViewButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple
mapViewButton.BackgroundTransparency = 0.5
mapViewButton.Text = "Maps: 0"
mapViewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mapViewButton.TextSize = 14
mapViewButton.Font = Enum.Font.GothamBold
mapViewButton.Parent = mapViewFrame

-- Create notification system
local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0.4, 0, 0.1, 0)
notificationFrame.Position = UDim2.new(0.3, 0, 0.8, 0)
notificationFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
notificationFrame.BackgroundTransparency = 0.3
notificationFrame.BorderSizePixel = 0
notificationFrame.Visible = false
notificationFrame.Parent = mainGui

local notificationText = Instance.new("TextLabel")
notificationText.Name = "NotificationText"
notificationText.Size = UDim2.new(1, 0, 1, 0)
notificationText.BackgroundTransparency = 1
notificationText.Text = ""
notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationText.TextSize = 18
notificationText.Font = Enum.Font.GothamMedium
notificationText.Parent = notificationFrame

-- Create map hint system (replacing the map view)
local mapHintGui = Instance.new("Frame")
mapHintGui.Name = "MapHint"
mapHintGui.Size = UDim2.new(0.5, 0, 0.3, 0)
mapHintGui.Position = UDim2.new(0.25, 0, 0.35, 0)
mapHintGui.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mapHintGui.BackgroundTransparency = 0.2
mapHintGui.BorderSizePixel = 0
mapHintGui.Visible = false
mapHintGui.Parent = mainGui

local hintTitle = Instance.new("TextLabel")
hintTitle.Size = UDim2.new(1, 0, 0.2, 0)
hintTitle.Position = UDim2.new(0, 0, 0, 0)
hintTitle.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple
hintTitle.BackgroundTransparency = 0.5
hintTitle.Text = "MYSTERIOUS HINT"
hintTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hintTitle.TextSize = 20
hintTitle.Font = Enum.Font.GothamBold
hintTitle.Parent = mapHintGui

local hintText = Instance.new("TextLabel")
hintText.Size = UDim2.new(0.9, 0, 0.5, 0)
hintText.Position = UDim2.new(0.05, 0, 0.25, 0)
hintText.BackgroundTransparency = 1
hintText.Text = "Maybe go right? Or was it left..."
hintText.TextColor3 = Color3.fromRGB(255, 255, 255)
hintText.TextSize = 18
hintText.Font = Enum.Font.GothamMedium
hintText.TextWrapped = true
hintText.Parent = mapHintGui

local trustNote = Instance.new("TextLabel")
trustNote.Size = UDim2.new(0.8, 0, 0.2, 0)
trustNote.Position = UDim2.new(0.1, 0, 0.75, 0)
trustNote.BackgroundTransparency = 1
trustNote.Text = "(Do you really trust this help? 😏)"
trustNote.TextColor3 = Color3.fromRGB(255, 200, 100)
trustNote.TextSize = 14
trustNote.Font = Enum.Font.Gotham
trustNote.Parent = mapHintGui

-- Create leaderboard GUI
local leaderboardGui = Instance.new("Frame")
leaderboardGui.Name = "LeaderboardFrame"
leaderboardGui.Size = UDim2.new(0.2, 0, 0.4, 0)
leaderboardGui.Position = UDim2.new(0.79, 0, 0.01, 0)
leaderboardGui.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
leaderboardGui.BackgroundTransparency = 0.5
leaderboardGui.BorderSizePixel = 0
leaderboardGui.Parent = mainGui

local leaderboardTitle = Instance.new("TextLabel")
leaderboardTitle.Name = "LeaderboardTitle"
leaderboardTitle.Size = UDim2.new(1, 0, 0.1, 0)
leaderboardTitle.BackgroundTransparency = 1
leaderboardTitle.Text = "TOP PLAYERS"
leaderboardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
leaderboardTitle.TextSize = 14
leaderboardTitle.Font = Enum.Font.GothamBold
leaderboardTitle.Parent = leaderboardGui

local globalLeaderboard = Instance.new("ScrollingFrame")
globalLeaderboard.Name = "GlobalLeaderboard"
globalLeaderboard.Size = UDim2.new(1, 0, 0.45, 0)
globalLeaderboard.Position = UDim2.new(0, 0, 0.1, 0)
globalLeaderboard.BackgroundTransparency = 0.9
globalLeaderboard.BorderSizePixel = 0
globalLeaderboard.ScrollBarThickness = 4
globalLeaderboard.Parent = leaderboardGui

local personalTitle = Instance.new("TextLabel")
personalTitle.Name = "PersonalTitle"
personalTitle.Size = UDim2.new(1, 0, 0.1, 0)
personalTitle.Position = UDim2.new(0, 0, 0.55, 0)
personalTitle.BackgroundTransparency = 1
personalTitle.Text = "YOUR BEST"
personalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
personalTitle.TextSize = 14
personalTitle.Font = Enum.Font.GothamBold
personalTitle.Parent = leaderboardGui

local personalLeaderboard = Instance.new("ScrollingFrame")
personalLeaderboard.Name = "PersonalLeaderboard"
personalLeaderboard.Size = UDim2.new(1, 0, 0.35, 0)
personalLeaderboard.Position = UDim2.new(0, 0, 0.65, 0)
personalLeaderboard.BackgroundTransparency = 0.9
personalLeaderboard.BorderSizePixel = 0
personalLeaderboard.ScrollBarThickness = 4
personalLeaderboard.Parent = leaderboardGui

-- Function to show notifications
local function showNotification(message, duration)
	duration = duration or 3

	notificationFrame.Visible = true
	notificationText.Text = message

	-- Fade in
	notificationFrame.BackgroundTransparency = 1
	local fadeIn = TweenService:Create(notificationFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.3})
	fadeIn:Play()

	-- Schedule fade out
	delay(duration, function()
		local fadeOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			notificationFrame.Visible = false
		end)
	end)
end

-- Update score display
local function updateScoreDisplay()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Score") then
		scoreLabel.Text = "Score: " .. leaderstats.Score.Value
	end
end

-- Function to update leaderboard display
local function updateLeaderboardDisplay(leaderboardData)
	-- Clear existing entries
	for _, child in pairs(globalLeaderboard:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add new entries
	for i, entry in ipairs(leaderboardData) do
		local entryFrame = Instance.new("Frame")
		entryFrame.Size = UDim2.new(1, -10, 0, 30)
		entryFrame.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
		entryFrame.BackgroundTransparency = 0.5
		entryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		entryFrame.BorderSizePixel = 0
		entryFrame.Parent = globalLeaderboard

		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0.1, 0, 1, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. i
		rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rankLabel.TextSize = 14
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.Parent = entryFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.Position = UDim2.new(0.1, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = entry.playerName
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 12
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = entryFrame

		local scoreLabel = Instance.new("TextLabel")
		scoreLabel.Size = UDim2.new(0.2, 0, 1, 0)
		scoreLabel.Position = UDim2.new(0.6, 0, 0, 0)
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.Text = entry.score
		scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		scoreLabel.TextSize = 12
		scoreLabel.Font = Enum.Font.Gotham
		scoreLabel.Parent = entryFrame

		-- Format time (seconds to MM:SS)
		local minutes = math.floor(entry.time / 60)
		local seconds = entry.time % 60
		local timeString = string.format("%02d:%02d", minutes, seconds)

		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(0.2, 0, 1, 0)
		timeLabel.Position = UDim2.new(0.8, 0, 0, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = timeString
		timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		timeLabel.TextSize = 12
		timeLabel.Font = Enum.Font.Gotham
		timeLabel.Parent = entryFrame
	end

	-- Update the canvas size
	globalLeaderboard.CanvasSize = UDim2.new(0, 0, 0, #leaderboardData * 35)
end

-- Random hints for the map view replacement
local randomHints = {
	"Go left! Or was it right? I always mix those up...",
	"The exit is definitely ahead! Or behind. One of those.",
	"Try walking in circles three times, then follow your intuition!",
	"When in doubt, just keep turning right. Or was it left?",
	"The center of the maze is where you'll find what you seek... probably.",
	"Have you tried looking up? No reason, just wondering.",
	"The wisest path is the one less traveled. Or was it more traveled?",
	"If you see a red emerald, run the other way! Trust me... or don't.",
	"A little birdie told me the exit is that way ↗️... birds aren't very reliable though.",
	"Try closing your eyes and spinning. Where you face is definitely NOT the way out.",
	"The exit moves every 5 minutes. Just kidding! Or am I?",
	"You're getting warmer! Actually, I have no idea where you are.",
	"I'd tell you where to go, but I got lost reading these instructions.",
	"Follow the yellow brick road! Wait, wrong maze.",
	"Have you tried walking backward? The maze might get confused and let you out.",
	"I'm pretty sure it's second star to the right, straight on till morning!",
	"If you see a monster, definitely run towards it. Reverse psychology works on monsters!",
	"I could tell you the way out, but where's the fun in that?",
	"Try the Konami code: up, up, down, down, left, right, left, right...",
	"You're doing great! I have no idea where you are, but positive vibes!"
}

-- Function to show a random hint
local function showRandomHint()
	local randomIndex = math.random(1, #randomHints)
	hintText.Text = randomHints[randomIndex]
	mapHintGui.Visible = true

	-- Hide after 10 seconds
	delay(10, function()
		mapHintGui.Visible = false
	end)
end

-- Function to create question UI
local function createQuestionUI(questionData)
	-- Store current question
	currentQuestion = questionData

	-- Create question GUI
	local questionGui = Instance.new("Frame")
	questionGui.Name = "QuestionGui"
	questionGui.Size = UDim2.new(0.6, 0, 0.6, 0)
	questionGui.Position = UDim2.new(0.2, 0, 0.2, 0)
	questionGui.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	questionGui.BorderSizePixel = 0
	questionGui.Parent = mainGui

	-- Create question header
	local questionHeader = Instance.new("TextLabel")
	questionHeader.Size = UDim2.new(1, 0, 0.1, 0)
	questionHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	questionHeader.BorderSizePixel = 0
	questionHeader.Text = "AI Knowledge Quiz"
	questionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
	questionHeader.TextSize = 18
	questionHeader.Font = Enum.Font.GothamBold
	questionHeader.Parent = questionGui

	-- Create question label
	local questionLabel = Instance.new("TextLabel")
	questionLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
	questionLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
	questionLabel.BackgroundTransparency = 1
	questionLabel.Text = questionData.question
	questionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	questionLabel.TextSize = 16
	questionLabel.Font = Enum.Font.Gotham
	questionLabel.TextWrapped = true
	questionLabel.Parent = questionGui

	-- Create answer buttons
	for i, option in ipairs(questionData.options) do
		local button = Instance.new("TextButton")
		button.Name = "Option" .. i
		button.Size = UDim2.new(0.8, 0, 0.12, 0)
		button.Position = UDim2.new(0.1, 0, 0.4 + (i-1) * 0.15, 0)
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.BorderSizePixel = 0
		button.Text = option
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		button.Font = Enum.Font.Gotham
		button.TextWrapped = true
		button.Parent = questionGui

		-- Add hover effect
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end)

		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end)

		-- Add click handler
		button.MouseButton1Click:Connect(function()
			remoteEvents.QuestionEvent:FireServer(questionData, i)
			questionGui:Destroy()
			currentQuestion = nil
		end)
	end

	-- Add hint button if player has hint tokens
	if inventory.hintTokens > 0 then
		local hintButton = Instance.new("TextButton")
		hintButton.Size = UDim2.new(0.3, 0, 0.08, 0)
		hintButton.Position = UDim2.new(0.35, 0, 0.09, 0)
		hintButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
		hintButton.BorderSizePixel = 0
		hintButton.Text = "Use Hint"
		hintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		hintButton.TextSize = 14
		hintButton.Font = Enum.Font.GothamBold
		hintButton.Parent = questionGui

		hintButton.MouseButton1Click:Connect(function()
			remoteEvents.UseHintToken:FireServer(questionData)
			hintButton.Visible = false
		end)
	end

	return questionGui
end

-- Eliminate wrong option in the question UI
local function eliminateWrongOption(optionIndex)
	local questionGui = mainGui:FindFirstChild("QuestionGui")
	if questionGui then
		local option = questionGui:FindFirstChild("Option" .. optionIndex)
		if option then
			option.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
			option.TextColor3 = Color3.fromRGB(150, 150, 150)
			option.Text = "✗ " .. option.Text
			option.MouseButton1Click:Connect(function()
				showNotification("This answer has been eliminated by your hint token", 2)
			end)
		end
	end
end

-- Start timer when player moves
local function startTimer()
	if not timerRunning then
		timerRunning = true
		startTime = tick()

		-- Fire event to let server know player started
		remoteEvents.GameStart:FireServer()

		-- Timer update loop
		task.spawn(function()
			while timerRunning do
				local elapsed = tick() - startTime
				local minutes = math.floor(elapsed / 60)
				local seconds = math.floor(elapsed % 60)
				local timeString = string.format("%02d:%02d", minutes, seconds)

				-- Update timer display
				timerLabel.Text = "Time: " .. timeString

				-- Update leaderstats
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats and leaderstats:FindFirstChild("Time") then
					leaderstats.Time.Value = timeString
				end

				task.wait(0.1)
			end
		end)
	end
end

-- EVENT HANDLERS

-- Handle speed boost button click
speedBoostButton.MouseButton1Click:Connect(function()
	if inventory.speedBoosts > 0 then
		remoteEvents.ActivateSpeedBoost:FireServer()
	else
		showNotification("You don't have any speed boosts!", 2)
	end
end)

-- Handle map view button click (now shows random hints)
mapViewButton.MouseButton1Click:Connect(function()
	if inventory.mapViews > 0 then
		remoteEvents.ActivateMapView:FireServer()
	else
		showNotification("You don't have any map views!", 2)
	end
end)

-- Remote event handling

-- Question event
remoteEvents.QuestionEvent.OnClientEvent:Connect(function(questionData)
	createQuestionUI(questionData)
end)

-- Speed boost update
-- This would go in the remoteEvents.SpeedBoost.OnClientEvent handler
remoteEvents.SpeedBoost.OnClientEvent:Connect(function(boostCount)
	inventory.speedBoosts = boostCount
	speedBoostButton.Text = "Speed: " .. boostCount

	-- Visually indicate if max capacity reached
	if boostCount >= 3 then
		speedBoostButton.BackgroundColor3 = Color3.fromRGB(255, 255, 100) -- Lighter yellow to indicate full
	else
		speedBoostButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Regular yellow
	end
end)

-- Hint token update
-- This would go in the remoteEvents.HintToken.OnClientEvent handler
remoteEvents.HintToken.OnClientEvent:Connect(function(tokenCount)
	inventory.hintTokens = tokenCount
	hintTokenButton.Text = "Hints: " .. tokenCount

	-- Visually indicate if max capacity reached
	if tokenCount >= 3 then
		hintTokenButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255) -- Lighter blue to indicate full
	else
		hintTokenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255) -- Regular blue
	end
end)

-- Map view update - now shows random hint messages
remoteEvents.ShowMap.OnClientEvent:Connect(function(viewCount, activate)
	inventory.mapViews = viewCount
	mapViewButton.Text = "Maps: " .. viewCount

	if activate then
		showRandomHint()
	end
end)

-- Eliminate option
remoteEvents.EliminateOption.OnClientEvent:Connect(function(optionIndex)
	eliminateWrongOption(optionIndex)
end)

-- Notification event
remoteEvents.NotifyPlayer.OnClientEvent:Connect(function(message, duration)
	showNotification(message, duration)
end)

-- Update leaderboard
remoteEvents.UpdateLeaderboard.OnClientEvent:Connect(function(leaderboardData)
	updateLeaderboardDisplay(leaderboardData)
end)

-- Game end event
remoteEvents.GameEnd.OnClientEvent:Connect(function(success)
	timerRunning = false

	if success then
		-- Create victory screen
		local victoryScreen = Instance.new("Frame")
		victoryScreen.Name = "VictoryScreen"
		victoryScreen.Size = UDim2.new(1, 0, 1, 0)
		victoryScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		victoryScreen.BackgroundTransparency = 0.5
		victoryScreen.ZIndex = 10
		victoryScreen.Parent = mainGui

		-- Congratulations text
		local congratsText = Instance.new("TextLabel")
		congratsText.Size = UDim2.new(0.8, 0, 0.2, 0)
		congratsText.Position = UDim2.new(0.1, 0, 0.2, 0)
		congratsText.BackgroundTransparency = 1
		congratsText.Text = "CONGRATULATIONS!"
		congratsText.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
		congratsText.TextSize = 48
		congratsText.Font = Enum.Font.GothamBold
		congratsText.ZIndex = 11
		congratsText.Parent = victoryScreen

		-- Score and time display
		local leaderstats = player:FindFirstChild("leaderstats")
		local scoreValue = leaderstats and leaderstats:FindFirstChild("Score") and leaderstats.Score.Value or 0
		local timeValue = leaderstats and leaderstats:FindFirstChild("Time") and leaderstats.Time.Value or "00:00"

		local statsText = Instance.new("TextLabel")
		statsText.Size = UDim2.new(0.8, 0, 0.1, 0)
		statsText.Position = UDim2.new(0.1, 0, 0.4, 0)
		statsText.BackgroundTransparency = 1
		statsText.Text = "Your Score: " .. scoreValue .. " | Time: " .. timeValue
		statsText.TextColor3 = Color3.fromRGB(255, 255, 255)
		statsText.TextSize = 24
		statsText.Font = Enum.Font.Gotham
		statsText.ZIndex = 11
		statsText.Parent = victoryScreen

		-- Play again button
		local playAgainButton = Instance.new("TextButton")
		playAgainButton.Size = UDim2.new(0.3, 0, 0.1, 0)
		playAgainButton.Position = UDim2.new(0.2, 0, 0.6, 0)
		playAgainButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
		playAgainButton.Text = "Play Again"
		playAgainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		playAgainButton.TextSize = 24
		playAgainButton.Font = Enum.Font.GothamBold
		playAgainButton.ZIndex = 11
		playAgainButton.Parent = victoryScreen

		-- Exit button
		local exitButton = Instance.new("TextButton")
		exitButton.Size = UDim2.new(0.3, 0, 0.1, 0)
		exitButton.Position = UDim2.new(0.5, 0, 0.6, 0)
		exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		exitButton.Text = "Exit Game"
		exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		exitButton.TextSize = 24
		exitButton.Font = Enum.Font.GothamBold
		exitButton.ZIndex = 11
		exitButton.Parent = victoryScreen

		-- Button functionality
		playAgainButton.MouseButton1Click:Connect(function()
			-- Remove victory screen
			victoryScreen:Destroy()

			-- Tell server to reset the player
			remoteEvents:WaitForChild("ResetPlayer"):FireServer()

			-- Reset local timer
			timerRunning = false
			startTime = 0
			timerLabel.Text = "Time: 00:00"

			-- Show notification for restart
			showNotification("Starting a new game!", 3)
		end)

		exitButton.MouseButton1Click:Connect(function()
			-- Show notification that they're leaving
			showNotification("Leaving game...", 2)

			-- Use BindableFunction to handle the teleport
			local bindable = Instance.new("BindableFunction")
			bindable.OnInvoke = function()
				-- This function is called when they confirm
				player:Kick("Thanks for playing! To play again, rejoin the game.")
			end

			-- Delay slightly to show notification
			task.delay(2, function()
				-- Force player to leave
				bindable:Invoke()
			end)
		end)
	else
		showNotification("Starting over. Better luck this time!", 3)
	end
end)

-- Input detection to start timer
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard or 
		input.UserInputType == Enum.UserInputType.MouseButton1 or
		input.UserInputType == Enum.UserInputType.Touch then
		startTimer()
	end
end)

-- Update score display when leaderstats changes
player:WaitForChild("leaderstats")
player.leaderstats:WaitForChild("Score").Changed:Connect(updateScoreDisplay)

-- Initial update of score display
updateScoreDisplay()

-- Add GameEnd RemoteEvent if it doesn't exist
if not remoteEvents:FindFirstChild("GameStart") then
	local gameStartEvent = Instance.new("RemoteEvent")
	gameStartEvent.Name = "GameStart"
	gameStartEvent.Parent = remoteEvents
end


--  ***************** Door Mechanism  by Pejman ***************************** --
-- Door code functionality

-- Code memory display (to show discovered digits)
local codeMemoryGui = Instance.new("Frame")
codeMemoryGui.Name = "CodeMemoryGui"
codeMemoryGui.Size = UDim2.new(0.15, 0, 0.15, 0)
codeMemoryGui.Position = UDim2.new(0.01, 0, 0.32, 0)
codeMemoryGui.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
codeMemoryGui.BackgroundTransparency = 0.5
codeMemoryGui.BorderSizePixel = 0
codeMemoryGui.Parent = mainGui

local codeMemoryTitle = Instance.new("TextLabel")
codeMemoryTitle.Size = UDim2.new(1, 0, 0.3, 0)
codeMemoryTitle.BackgroundTransparency = 1
codeMemoryTitle.Text = "CODE DIGITS"
codeMemoryTitle.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
codeMemoryTitle.TextSize = 14
codeMemoryTitle.Font = Enum.Font.GothamBold
codeMemoryTitle.Parent = codeMemoryGui

-- Create display for each code digit
local codeDigits = {}
for i = 1, 3 do
	local digitFrame = Instance.new("Frame")
	digitFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
	digitFrame.Position = UDim2.new(0.05 + (i-1) * 0.32, 0, 0.35, 0)
	digitFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	digitFrame.BackgroundTransparency = 0.3
	digitFrame.BorderSizePixel = 0
	digitFrame.Parent = codeMemoryGui

	local digitLabel = Instance.new("TextLabel")
	digitLabel.Size = UDim2.new(1, 0, 1, 0)
	digitLabel.BackgroundTransparency = 1
	digitLabel.Text = "?"
	digitLabel.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
	digitLabel.TextSize = 18
	digitLabel.Font = Enum.Font.Code
	digitLabel.Parent = digitFrame

	codeDigits[i] = digitLabel
end

-- Create code entry UI (initially hidden)
local codeEntryGui = Instance.new("Frame")
codeEntryGui.Name = "CodeEntryGui"
codeEntryGui.Size = UDim2.new(0.3, 0, 0.4, 0)
codeEntryGui.Position = UDim2.new(0.35, 0, 0.3, 0)
codeEntryGui.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
codeEntryGui.BorderSizePixel = 0
codeEntryGui.Visible = false
codeEntryGui.Parent = mainGui

local codeTitle = Instance.new("TextLabel")
codeTitle.Size = UDim2.new(1, 0, 0.15, 0)
codeTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
codeTitle.Text = "Enter Door Code"
codeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
codeTitle.TextSize = 18
codeTitle.Font = Enum.Font.GothamBold
codeTitle.Parent = codeEntryGui

local codeDisplay = Instance.new("TextLabel")
codeDisplay.Size = UDim2.new(0.8, 0, 0.1, 0)
codeDisplay.Position = UDim2.new(0.1, 0, 0.2, 0)
codeDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
codeDisplay.Text = "___"
codeDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
codeDisplay.TextSize = 24
codeDisplay.Font = Enum.Font.Code
codeDisplay.Parent = codeEntryGui

-- Create number buttons (0-9)
local buttonSize = UDim2.new(0.2, 0, 0.1, 0)
local currentCode = ""

for i = 0, 9 do
	local button = Instance.new("TextButton")
	button.Size = buttonSize

	-- Calculate position (0 goes at bottom center, 1-9 in grid)
	local row = math.floor((i-1) / 3) + 1
	local col = (i-1) % 3 + 1
	if i == 0 then
		button.Position = UDim2.new(0.4, 0, 0.7, 0)
	else
		button.Position = UDim2.new(0.2 + (col-1) * 0.25, 0, 0.3 + (row-1) * 0.15, 0)
	end

	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.Text = tostring(i)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 20
	button.Font = Enum.Font.GothamBold
	button.Parent = codeEntryGui

	-- Add click handler
	button.MouseButton1Click:Connect(function()
		if #currentCode < 3 then
			currentCode = currentCode .. i
			codeDisplay.Text = currentCode
			if #currentCode == 3 then
				-- Auto-submit after 3 digits
				task.delay(0.5, function()
					local doorName = codeEntryGui:GetAttribute("DoorName")
					if doorName then
						remoteEvents.TryDoorCode:FireServer(doorName, currentCode)
					end
					currentCode = ""
					codeDisplay.Text = "___"
					codeEntryGui.Visible = false
				end)
			end
		end
	end)
end

-- Clear button
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.3, 0, 0.1, 0)
clearButton.Position = UDim2.new(0.15, 0, 0.85, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
clearButton.Text = "Clear"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextSize = 16
clearButton.Font = Enum.Font.GothamBold
clearButton.Parent = codeEntryGui

clearButton.MouseButton1Click:Connect(function()
	currentCode = ""
	codeDisplay.Text = "___"
end)

-- Cancel button
local cancelButton = Instance.new("TextButton")
cancelButton.Size = UDim2.new(0.3, 0, 0.1, 0)
cancelButton.Position = UDim2.new(0.55, 0, 0.85, 0)
cancelButton.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
cancelButton.Text = "Cancel"
cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelButton.TextSize = 16
cancelButton.Font = Enum.Font.GothamBold
cancelButton.Parent = codeEntryGui

cancelButton.MouseButton1Click:Connect(function()
	currentCode = ""
	codeDisplay.Text = "___"
	codeEntryGui.Visible = false
end)

-- Reveal code digit event handler
remoteEvents.RevealCodeDigit.OnClientEvent:Connect(function(position, digit)
	-- Update the code memory display
	if codeDigits[position] then
		codeDigits[position].Text = tostring(digit)
	end

	-- Play a sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6042053626" -- Replace with actual sound ID
	sound.Parent = player.Character.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)

	-- Highlight the digit briefly
	codeDigits[position].TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
	task.delay(1, function()
		codeDigits[position].TextColor3 = Color3.fromRGB(255, 165, 0) -- Back to orange
	end)
end)

-- Handle door unlocking
remoteEvents.DoorUnlocked.OnClientEvent:Connect(function(doorName)
	local door = workspace:FindFirstChild(doorName)
	if door and door:IsA("BasePart") then
		-- Save the door's original CanCollide state
		local originalCanCollide = door.CanCollide

		-- Make door non-collidable - THIS IS THE KEY CHANGE
		door.CanCollide = false

		-- Create a temporary transparent part at the same location to show it's unlocked
		local ghostDoor = door:Clone()
		ghostDoor.Name = doorName .. "_Ghost"
		ghostDoor.CanCollide = false
		ghostDoor.Transparency = 0.8
		ghostDoor.Material = Enum.Material.Neon
		ghostDoor.BrickColor = BrickColor.new("Bright green")
		ghostDoor.Parent = workspace

		-- Make the real door visually transparent
		local originalTransparency = door.Transparency
		door.Transparency = 0.9

		-- After 100 seconds, restore door
		task.delay(100, function()
			if door and door:IsA("BasePart") then
				door.CanCollide = originalCanCollide
				door.Transparency = originalTransparency
			end

			if ghostDoor then
				ghostDoor:Destroy()
			end

			showNotification("Door has been locked again!", 3)
		end)
	end
end)

-- Function to setup door proximity prompts
local function setupDoorPrompts()
	-- Look for all PartDoor instances in the workspace
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "PartDoor" then
			local prompt = obj:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt")
			prompt.ActionText = "Enter Code"
			prompt.ObjectText = "Door Lock"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = obj

			prompt.Triggered:Connect(function()
				-- Show code entry UI
				codeEntryGui:SetAttribute("DoorName", obj.Name)
				codeDisplay.Text = "___"
				currentCode = ""
				codeTitle.Text = "Enter Door Code"
				codeEntryGui.Visible = true
			end)
		end
	end
end

-- Set up door prompts when the game starts
setupDoorPrompts()

-- Also set up prompts when workspace changes (in case doors are added later)
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "PartDoor" and not obj:FindFirstChild("ProximityPrompt") then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Enter Code"
		prompt.ObjectText = "Door Lock"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0.5
		prompt.Parent = obj

		prompt.Triggered:Connect(function()
			-- Show code entry UI
			codeEntryGui:SetAttribute("DoorName", obj.Name)
			codeDisplay.Text = "___"
			currentCode = ""
			codeTitle.Text = "Enter Door Code"
			codeEntryGui.Visible = true
		end)
	end
end)

-- End Door mechanism --


print("PlayerController script initialized")