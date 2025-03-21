-- OrangeEmeraldHandler.lua
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
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Global door code variables
_G.doorCode = {
	digits = {0, 0, 0}, -- Will store the 3 random digits
	lastGenerated = 0,   -- Timestamp when the code was last generated
	staticCode = "136"   -- Static code that always works
}

-- Per-player door attempt tracking
_G.doorAttempts = {}

-- Create needed RemoteEvents if they don't exist
if not remoteEvents:FindFirstChild("RevealCodeDigit") then
	local codeEvent = Instance.new("RemoteEvent")
	codeEvent.Name = "RevealCodeDigit"
	codeEvent.Parent = remoteEvents
end

if not remoteEvents:FindFirstChild("TryDoorCode") then
	local tryCodeEvent = Instance.new("RemoteEvent")
	tryCodeEvent.Name = "TryDoorCode"
	tryCodeEvent.Parent = remoteEvents
end

if not remoteEvents:FindFirstChild("DoorUnlocked") then
	local doorEvent = Instance.new("RemoteEvent")
	doorEvent.Name = "DoorUnlocked"
	doorEvent.Parent = remoteEvents
end

-- Function to generate random door code
local function generateDoorCode()
	_G.doorCode.digits[1] = math.random(0, 9)
	_G.doorCode.digits[2] = math.random(0, 9)
	_G.doorCode.digits[3] = math.random(0, 9)
	_G.doorCode.lastGenerated = os.time()
	print("New door code generated: " .. _G.doorCode.digits[1] .. _G.doorCode.digits[2] .. _G.doorCode.digits[3])

	-- Reset emerald visibility for all orange emeralds
	local orangeFolder = workspace:FindFirstChild("OrangeEmerald")
	if orangeFolder then
		for _, emerald in pairs(orangeFolder:GetChildren()) do
			if emerald:IsA("BasePart") and (emerald.Name == "o1" or emerald.Name == "o2" or emerald.Name == "o3") then
				emerald.Transparency = 0
				emerald:SetAttribute("Revealed", false)
			end
		end
	end
end

-- Setup orange emeralds
local function setupOrangeEmeralds()
	print("Setting up orange emerald interactions...")

	-- Setup Orange Emeralds (Code Digits)
	local orangeFolder = workspace:FindFirstChild("OrangeEmerald")
	if not orangeFolder then
		orangeFolder = Instance.new("Folder")
		orangeFolder.Name = "OrangeEmerald"
		orangeFolder.Parent = workspace

		-- Create 3 orange emeralds if they don't exist
		for i = 1, 3 do
			local emerald = Instance.new("Part")
			emerald.Name = "o" .. i
			emerald.BrickColor = BrickColor.new("Neon orange")
			emerald.Material = Enum.Material.Neon
			emerald.Size = Vector3.new(2, 2, 2)
			emerald.Position = Vector3.new(0, 10 + (i * 5), 0) -- Placeholder position
			emerald.Anchored = true
			emerald.CanCollide = false
			emerald.Parent = orangeFolder
		end
	end

	for _, emerald in pairs(orangeFolder:GetChildren()) do
		if emerald:IsA("BasePart") and (emerald.Name == "o1" or emerald.Name == "o2" or emerald.Name == "o3") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Add attribute to track if this emerald has been revealed
			if not emerald:GetAttribute("Revealed") then
				emerald:SetAttribute("Revealed", false)
			end

			-- Create prompt
			local prompt = emerald:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt")
			prompt.ActionText = "Reveal Code Digit"
			prompt.ObjectText = "Code Clue"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = emerald

			-- Connect to prompt triggered
			prompt.Triggered:Connect(function(player)
				if not emerald:GetAttribute("Revealed") then
					-- Get the digit index (1, 2, or 3)
					local digitIndex = tonumber(string.sub(emerald.Name, 2, 2))

					-- Get the code digit for this emerald
					local codeDigit = _G.doorCode.digits[digitIndex]

					-- Mark as revealed
					emerald:SetAttribute("Revealed", true)
					emerald.Transparency = 0.7

					-- Reveal code digit to player
					remoteEvents.RevealCodeDigit:FireClient(player, digitIndex, codeDigit)
					remoteEvents.NotifyPlayer:FireClient(player, "Code digit " .. digitIndex .. " is: " .. codeDigit, 5)

					-- Play sound
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6042053626" -- Replace with actual sound ID
					sound.Parent = player.Character.HumanoidRootPart
					sound:Play()
					game.Debris:AddItem(sound, 2)
				else
					-- Already revealed, just show the digit again
					local digitIndex = tonumber(string.sub(emerald.Name, 2, 2))
					local codeDigit = _G.doorCode.digits[digitIndex]
					remoteEvents.RevealCodeDigit:FireClient(player, digitIndex, codeDigit)
					remoteEvents.NotifyPlayer:FireClient(player, "Code digit " .. digitIndex .. " is: " .. codeDigit, 3)
				end
			end)
		end
	end

	print("Orange emeralds setup complete")
end

-- Handle door code attempts
remoteEvents.TryDoorCode.OnServerEvent:Connect(function(player, doorName, codeAttempt)
	local doorPart = workspace:FindFirstChild(doorName)
	if not doorPart or not doorPart:IsA("BasePart") then
		remoteEvents.NotifyPlayer:FireClient(player, "Door not found!", 3)
		return
	end

	-- Get correct dynamic code as string
	local correctDynamicCode = tostring(_G.doorCode.digits[1]) .. tostring(_G.doorCode.digits[2]) .. tostring(_G.doorCode.digits[3])
	local correctStaticCode = _G.doorCode.staticCode

	-- Check if player has attempts left
	if not _G.doorAttempts[player.UserId] then
		_G.doorAttempts[player.UserId] = {}
	end

	if not _G.doorAttempts[player.UserId][doorName] then
		_G.doorAttempts[player.UserId][doorName] = 0
	end

	if _G.doorAttempts[player.UserId][doorName] >= 3 then
		remoteEvents.NotifyPlayer:FireClient(player, "This door is locked for you! Too many failed attempts.", 5)
		return
	end

	-- Check if code is correct (either dynamic or static)
	if tostring(codeAttempt) == correctDynamicCode or tostring(codeAttempt) == correctStaticCode then
		-- Correct code!
		remoteEvents.NotifyPlayer:FireClient(player, "Code correct! Door unlocked for 100 seconds.", 5)

		-- Tell client to handle door unlocking
		remoteEvents.DoorUnlocked:FireClient(player, doorName)

		-- Reset attempts for this door for this player
		_G.doorAttempts[player.UserId][doorName] = 0
	else
		-- Wrong code
		_G.doorAttempts[player.UserId][doorName] = _G.doorAttempts[player.UserId][doorName] + 1
		local attemptsLeft = 3 - _G.doorAttempts[player.UserId][doorName]

		if attemptsLeft > 0 then
			remoteEvents.NotifyPlayer:FireClient(player, "Wrong code! " .. attemptsLeft .. " attempts left.", 3)
		else
			remoteEvents.NotifyPlayer:FireClient(player, "Door locked! You've used all your attempts.", 5)
		end
	end
end)

-- Initialize on player join
Players.PlayerAdded:Connect(function(player)
	-- Initialize door attempts for this player
	if not _G.doorAttempts[player.UserId] then
		_G.doorAttempts[player.UserId] = {}
	end

	-- Check if we need to generate a new door code (first player or code expired)
	if os.time() - _G.doorCode.lastGenerated > 1200 then -- 20 minutes = 1200 seconds
		generateDoorCode()
	end
end)

-- Timer to regenerate the door code every 20 minutes
spawn(function()
	while true do
		wait(60) -- Check every minute
		if os.time() - _G.doorCode.lastGenerated >= 1200 then -- 20 minutes
			generateDoorCode()

			-- Announce code change to all players
			for _, player in pairs(game.Players:GetPlayers()) do
				remoteEvents.NotifyPlayer:FireClient(player, "The door codes have changed! Find the orange emeralds for new clues.", 5)
			end

			-- Reset all door attempts
			_G.doorAttempts = {}
		end
	end
end)

-- Initialize on script start
generateDoorCode()
setupOrangeEmeralds()
print("OrangeEmeraldHandler script initialized")