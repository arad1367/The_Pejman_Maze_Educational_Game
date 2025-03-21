-- GameManager.lua
-- Place this in ServerScriptService

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
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Create a data store for your game -- I need to check it again! 
local mazeDataStore = DataStoreService:GetDataStore("MazeGameData")

-- Create folder for remote events if it doesn't exist
if not ReplicatedStorage:FindFirstChild("RemoteEvents") then
	local remoteEvents = Instance.new("Folder")
	remoteEvents.Name = "RemoteEvents"
	remoteEvents.Parent = ReplicatedStorage

	-- Create all necessary remote events
	local events = {
		"QuestionEvent",
		"ScoreUpdate",
		"SpeedBoost",
		"HealthChange",
		"ShowMap",
		"HintToken",
		"GameEnd",
		"NotifyPlayer",
		"ActivateSpeedBoost",
		"UseHintToken",
		"ActivateMapView",
		"EliminateOption",
		"UpdateLeaderboard",
		"GameStart",
		"ResetPlayer"
	}

	for _, eventName in ipairs(events) do
		local event = Instance.new("RemoteEvent")
		event.Name = eventName
		event.Parent = remoteEvents
	end

	print("Created RemoteEvents folder and all events")
else
	-- Ensure all events exist, even if folder already exists
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	local requiredEvents = {
		"QuestionEvent", "ScoreUpdate", "SpeedBoost", "HealthChange", 
		"ShowMap", "HintToken", "GameEnd", "NotifyPlayer",
		"ActivateSpeedBoost", "UseHintToken", "ActivateMapView", 
		"EliminateOption", "UpdateLeaderboard", "GameStart", "ResetPlayer"
	}

	for _, eventName in ipairs(requiredEvents) do
		if not remoteEvents:FindFirstChild(eventName) then
			local event = Instance.new("RemoteEvent")
			event.Name = eventName
			event.Parent = remoteEvents
			print("Created missing event: " .. eventName)
		end
	end

	print("RemoteEvents folder already exists, checked for missing events")
end

-- Global player data store
_G.playerData = {}

-- Leaderboard data
local globalLeaderboard = {
	-- Format: {playerName = string, score = number, time = number}
}

-- Initialize player
local function initializePlayer(player)
	_G.playerData[player.UserId] = {
		score = 0,
		startTime = 0,
		isPlaying = false,
		inventory = {
			speedBoosts = 0,
			hintTokens = 0,
			mapViews = 0
		},
		personalBest = {}
	}

	-- Load player's previous records using DataStore
	local success, result = pcall(function()
		return mazeDataStore:GetAsync("Player_" .. player.UserId)
	end)

	if success and result then
		_G.playerData[player.UserId].personalBest = result
		print("Loaded saved data for player: " .. player.Name)
	end

	-- Send current leaderboard to player
	task.delay(2, function()
		ReplicatedStorage.RemoteEvents.UpdateLeaderboard:FireClient(player, globalLeaderboard)
	end)
end

-- Player added event
Players.PlayerAdded:Connect(function(player)
	print("Player joined: " .. player.Name)
	initializePlayer(player)

	-- Create leaderboard values
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Value = 0
	score.Parent = leaderstats

	local timer = Instance.new("StringValue")
	timer.Name = "Time"
	timer.Value = "00:00"
	timer.Parent = leaderstats

	-- Listen for score changes
	score.Changed:Connect(function(newValue)
		_G.playerData[player.UserId].score = newValue
	end)
end)

-- Player removing event
Players.PlayerRemoving:Connect(function(player)
	print("Player leaving: " .. player.Name)

	-- Check if the player's score qualifies for leaderboard
	if _G.playerData[player.UserId] and _G.playerData[player.UserId].isPlaying then
		local playerScore = _G.playerData[player.UserId].score
		local playerTime = os.time() - _G.playerData[player.UserId].startTime

		-- Add to player's personal best if qualifies
		table.insert(_G.playerData[player.UserId].personalBest, {
			score = playerScore,
			time = playerTime
		})

		-- Sort personal best (highest score, then fastest time)
		table.sort(_G.playerData[player.UserId].personalBest, function(a, b)
			if a.score == b.score then
				return a.time < b.time
			end
			return a.score > b.score
		end)

		-- Keep only top 3
		while #_G.playerData[player.UserId].personalBest > 3 do
			table.remove(_G.playerData[player.UserId].personalBest)
		end

		-- Save player data to DataStore
		local success, errorMessage = pcall(function()
			mazeDataStore:SetAsync("Player_" .. player.UserId, _G.playerData[player.UserId].personalBest)
		end)

		if success then
			print("Successfully saved data for player: " .. player.Name)
		else
			warn("Failed to save data for player " .. player.Name .. ": " .. errorMessage)
		end

		-- Check if qualifies for global leaderboard
		local entry = {
			playerName = player.Name,
			score = playerScore,
			time = playerTime
		}

		-- Add to global leaderboard
		table.insert(globalLeaderboard, entry)

		-- Sort global leaderboard
		table.sort(globalLeaderboard, function(a, b)
			if a.score == b.score then
				return a.time < b.time
			end
			return a.score > b.score
		end)

		-- Keep only top 5
		while #globalLeaderboard > 5 do
			table.remove(globalLeaderboard)
		end

		-- Update leaderboard for all players
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			ReplicatedStorage.RemoteEvents.UpdateLeaderboard:FireClient(otherPlayer, globalLeaderboard)
		end
	end

	-- Clear player data
	_G.playerData[player.UserId] = nil
end)

-- Handle game end event
ReplicatedStorage.RemoteEvents.GameEnd.OnServerEvent:Connect(function(player, success)
	local playerData = _G.playerData[player.UserId]

	if playerData and playerData.isPlaying then
		if success then
			-- Record the successful completion
			local playerScore = playerData.score
			local playerTime = os.time() - playerData.startTime

			-- Format time for display
			local minutes = math.floor(playerTime / 60)
			local seconds = playerTime % 60
			local timeString = string.format("%02d:%02d", minutes, seconds)

			-- Update player's time value
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats and leaderstats:FindFirstChild("Time") then
				leaderstats.Time.Value = timeString
			end

			-- Add to player's personal best
			table.insert(playerData.personalBest, {
				score = playerScore,
				time = playerTime
			})

			-- Sort personal best
			table.sort(playerData.personalBest, function(a, b)
				if a.score == b.score then
					return a.time < b.time
				end
				return a.score > b.score
			end)

			-- Keep only top 3
			while #playerData.personalBest > 3 do
				table.remove(playerData.personalBest)
			end

			-- Save player data on successful completion
			local success, errorMessage = pcall(function()
				mazeDataStore:SetAsync("Player_" .. player.UserId, playerData.personalBest)
			end)

			if success then
				print("Successfully saved data for player after completion: " .. player.Name)
			else
				warn("Failed to save data for player " .. player.Name .. ": " .. errorMessage)
			end

			-- Check if qualifies for global leaderboard
			local entry = {
				playerName = player.Name,
				score = playerScore,
				time = playerTime
			}

			-- Add to global leaderboard
			table.insert(globalLeaderboard, entry)

			-- Sort global leaderboard
			table.sort(globalLeaderboard, function(a, b)
				if a.score == b.score then
					return a.time < b.time
				end
				return a.score > b.score
			end)

			-- Keep only top 5
			while #globalLeaderboard > 5 do
				table.remove(globalLeaderboard)
			end

			-- Update leaderboard for all players
			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				ReplicatedStorage.RemoteEvents.UpdateLeaderboard:FireClient(otherPlayer, globalLeaderboard)
			end

			-- Notify player of success
			ReplicatedStorage.RemoteEvents.NotifyPlayer:FireClient(player, "Maze completed! Score: " .. playerScore .. " Time: " .. timeString)
		end

		-- Reset player for new game
		playerData.isPlaying = false
		playerData.score = 0
		playerData.startTime = 0
		playerData.inventory = {
			speedBoosts = 0,
			hintTokens = 0,
			mapViews = 0
		}

		-- Reset leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			if leaderstats:FindFirstChild("Score") then
				leaderstats.Score.Value = 0
			end
		end
	end
end)

-- Handle player death and respawn
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			-- Player died, show continue options
			ReplicatedStorage.RemoteEvents.NotifyPlayer:FireClient(player, "You died! Choose to continue or leave.")

			-- In a full implementation, you would add UI for this choice
			-- For simplicity, we'll just respawn them automatically after a delay
			task.delay(3, function()
				-- Reset player for new game
				local playerData = _G.playerData[player.UserId]
				if playerData then
					playerData.isPlaying = false
					playerData.score = 0
					playerData.startTime = 0
					playerData.inventory = {
						speedBoosts = 0,
						hintTokens = 0,
						mapViews = 0
					}
				end

				-- Reset leaderstats
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats and leaderstats:FindFirstChild("Score") then
					leaderstats.Score.Value = 0
				end

				-- Respawn player
				player:LoadCharacter()
			end)
		end)
	end)
end)

-- Record when player starts playing
ReplicatedStorage.RemoteEvents.GameStart.OnServerEvent:Connect(function(player)
	local playerData = _G.playerData[player.UserId]

	if playerData and not playerData.isPlaying then
		playerData.isPlaying = true
		playerData.startTime = os.time()
	end
end)

-- Check if ResetPlayer event exists, create if not
if not ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("ResetPlayer") then
	local resetEvent = Instance.new("RemoteEvent")
	resetEvent.Name = "ResetPlayer"
	resetEvent.Parent = ReplicatedStorage:FindFirstChild("RemoteEvents")
end

-- Handle reset player event
ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("ResetPlayer").OnServerEvent:Connect(function(player)
	-- Reset the player state
	local playerData = _G.playerData[player.UserId]
	if playerData then
		playerData.isPlaying = false
		playerData.score = 0
		playerData.startTime = 0
		playerData.inventory = {
			speedBoosts = 0,
			hintTokens = 0,
			mapViews = 0
		}
	end

	-- Reset leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Score") then
		leaderstats.Score.Value = 0
	end

	-- Reset player position
	local character = player.Character
	if character then
		local spawnLocation = workspace:FindFirstChild("SpawnLocation")
		if spawnLocation then
			character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 5, 0))
		end
	end
end)

print("GameManager script initialized")