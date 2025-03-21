-- DoorScript (put this in each door - for me that is in game.workspace) -- -- from Pejman :)  email: pejamn.ebrahimi@uni.li

--[[
   The Pejman Maze Educational Game
   
   An educational maze game with AI quiz questions and interactive challenges.
   Developed at the University of Liechtenstein.
   
   Creator: Dr. Pejman Ebrahimi
   Email: pejman.ebrahimi@uni.li
   Department of Information Systems & Computer Science
]]--

local Players = game:GetService("Players")

-- Define door type (manually set different for each door)
-- For Door 1: Set this to true
-- For Door 2: Set this to false
local isSuccessDoor = true -- IMPORTANT: Set to false in the second door! -- the same script just false for another one.

-- Add debounce system to prevent multiple triggers
local touchedPlayers = {}

-- Function to handle when a player touches the door
local function handleTouch(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)

	if player and not touchedPlayers[player.UserId] then
		-- Set debounce
		touchedPlayers[player.UserId] = true

		print("Door touched by: " .. player.Name)

		if isSuccessDoor then
			-- Success door - show success
			print("Success door!")

			-- Create success GUI
			local playerGui = player:WaitForChild("PlayerGui")

			-- Check if SuccessGui already exists and remove it
			if playerGui:FindFirstChild("SuccessGui") then
				playerGui.SuccessGui:Destroy()
			end

			local successGui = Instance.new("ScreenGui")
			successGui.Name = "SuccessGui"
			successGui.ResetOnSpawn = false
			successGui.Parent = playerGui

			-- Create background
			local background = Instance.new("Frame")
			background.Size = UDim2.new(1, 0, 1, 0)
			background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			background.BackgroundTransparency = 0.5
			background.Parent = successGui

			-- Create victory text
			local victoryText = Instance.new("TextLabel")
			victoryText.Size = UDim2.new(0.8, 0, 0.2, 0)
			victoryText.Position = UDim2.new(0.1, 0, 0.2, 0)
			victoryText.BackgroundTransparency = 1
			victoryText.Text = "CONGRATULATIONS!"
			victoryText.TextColor3 = Color3.fromRGB(255, 215, 0)
			victoryText.TextSize = 48
			victoryText.Font = Enum.Font.GothamBold
			victoryText.Parent = background

			-- Create score display
			local scoreText = Instance.new("TextLabel")
			scoreText.Size = UDim2.new(0.8, 0, 0.1, 0)
			scoreText.Position = UDim2.new(0.1, 0, 0.4, 0)
			scoreText.BackgroundTransparency = 1
			scoreText.Text = "You completed the maze!"
			scoreText.TextColor3 = Color3.fromRGB(255, 255, 255)
			scoreText.TextSize = 24
			scoreText.Font = Enum.Font.GothamMedium
			scoreText.Parent = background

			-- Create play again button
			local playAgainButton = Instance.new("TextButton")
			playAgainButton.Size = UDim2.new(0.3, 0, 0.1, 0)
			playAgainButton.Position = UDim2.new(0.35, 0, 0.6, 0)
			playAgainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
			playAgainButton.Text = "Play Again"
			playAgainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			playAgainButton.TextSize = 24
			playAgainButton.Font = Enum.Font.GothamBold
			playAgainButton.Parent = background

			-- Play again click handler
			playAgainButton.MouseButton1Click:Connect(function()
				-- Remove the success GUI
				if playerGui:FindFirstChild("SuccessGui") then
					playerGui.SuccessGui:Destroy()
				end

				-- Reset player score
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats and leaderstats:FindFirstChild("Score") then
					leaderstats.Score.Value = 0
				end

				-- Teleport player back to spawn
				local spawnLocation = workspace:FindFirstChild("SpawnLocation")
				if spawnLocation and player.Character then
					player.Character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 5, 0))
				end

				-- Reset all debounces after a delay
				task.delay(1, function()
					touchedPlayers[player.UserId] = nil
				end)
			end)
		else
			-- Reset door - teleport back and reset score
			print("Reset door!")

			-- Reset player score
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats and leaderstats:FindFirstChild("Score") then
				leaderstats.Score.Value = 0
			end

			-- Teleport player back to spawn
			local spawnLocation = workspace:FindFirstChild("SpawnLocation")
			if spawnLocation and player.Character then
				player.Character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 5, 0))
			end

			-- Reset debounce after a delay
			task.delay(1, function()
				touchedPlayers[player.UserId] = nil
			end)
		end
	end
end

-- Connect Touched event to all parts in the door model
local doorModel = script.Parent
for _, part in pairs(doorModel:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(handleTouch)
	end
end

-- Clean up touchedPlayers table when players leave
Players.PlayerRemoving:Connect(function(player)
	touchedPlayers[player.UserId] = nil
end)

print("Door script initialized - Type: " .. (isSuccessDoor and "Success" or "Reset"))