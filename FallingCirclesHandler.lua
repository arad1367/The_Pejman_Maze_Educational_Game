-- FallingStarsHandler.lua  --> You can change this script based on your preference --> message from Pejman :)
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

-- Configuration
local MAZE_SIZE_X = 372      -- My maze width
local MAZE_SIZE_Z = 372      -- My maze length
local FALL_HEIGHT = 30       -- Height from which stars fall (above maze)

local STAR_LIFETIME = 5      -- Seconds before star disappears
local SPAWN_INTERVAL = 0.5   -- Time between star spawns
local MAX_STARS = 30         -- Maximum number of stars at once
local DAMAGE_PERCENT = 30    -- Health percentage to decrease
local PLAYER_TARGET_INTERVAL = 15  -- Seconds between targeting a player directly

-- Find spawn location (center of maze)
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if not spawnLocation then
	warn("SpawnLocation not found! Using origin as maze center.")
	spawnLocation = {Position = Vector3.new(0, 0, 0)}
end

local MAZE_CENTER_X = spawnLocation.Position.X
local MAZE_CENTER_Z = spawnLocation.Position.Z
local MAZE_TOP_Y = spawnLocation.Position.Y + 10  -- Add some height

-- Star part template
local originalStar = workspace:FindFirstChild("CirclePartFall")
if not originalStar then
	-- Create a template if it doesn't exist
	originalStar = Instance.new("Part")
	originalStar.Name = "CirclePartFall"
	originalStar.Shape = Enum.PartType.Ball
	originalStar.Size = Vector3.new(3, 3, 3)
	originalStar.BrickColor = BrickColor.new("Institutional white")  -- White for star effect
	originalStar.Material = Enum.Material.Neon
	originalStar.Anchored = true
	originalStar.CanCollide = false
	originalStar.Parent = workspace
	-- Hide the original
	originalStar.Transparency = 1
end

-- Keep track of active stars
local activeStars = {}
local lastPlayerTargetTime = 0

-- Function to spawn a falling star at a random position
local function spawnFallingStar(x, z, targetPlayer)
	-- Don't spawn if we already have too many
	if #activeStars >= MAX_STARS then
		return
	end

	local startY = MAZE_TOP_Y + FALL_HEIGHT

	-- If no position is specified, generate random position
	if not x or not z then
		x = math.random(-MAZE_SIZE_X/2, MAZE_SIZE_X/2) + MAZE_CENTER_X
		z = math.random(-MAZE_SIZE_Z/2, MAZE_SIZE_Z/2) + MAZE_CENTER_Z
	end

	-- Debug print
	if targetPlayer then
		print("Spawning targeted star above player: " .. targetPlayer.Name)
	else
		print("Spawning star at:", x, startY, z)
	end

	-- Create new star
	local star = originalStar:Clone()
	star.Transparency = 0
	star.BrickColor = BrickColor.new("Institutional white")
	star.Position = Vector3.new(x, startY, z)
	star.Anchored = true
	star.CanCollide = false

	-- Add sparkles effect
	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = Color3.new(1, 1, 1)
	sparkles.Enabled = true
	sparkles.Parent = star

	-- Add point light
	local light = Instance.new("PointLight")
	light.Color = Color3.new(1, 1, 1)
	light.Brightness = 1
	light.Range = 10
	light.Parent = star

	star.Parent = workspace

	-- Add to active stars
	table.insert(activeStars, star)

	-- Create trail effect
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, -1, 0)
	attachment1.Parent = star

	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 1, 0)
	attachment2.Parent = star

	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment1
	trail.Attachment1 = attachment2
	trail.Lifetime = 0.5
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Parent = star

	-- Add warning circle on ground
	local groundY = MAZE_TOP_Y - 10  -- Estimate of ground height
	local warningCircle = Instance.new("Part")
	warningCircle.Shape = Enum.PartType.Cylinder
	warningCircle.Size = Vector3.new(0.1, 3, 3)
	warningCircle.CFrame = CFrame.new(x, groundY, z) * CFrame.Angles(0, 0, math.rad(90))
	warningCircle.Anchored = true
	warningCircle.CanCollide = false
	warningCircle.Material = Enum.Material.Neon
	warningCircle.BrickColor = BrickColor.new("Institutional white")
	warningCircle.Transparency = 0.5
	warningCircle.Parent = workspace

	-- Fall animation
	spawn(function()
		local startTime = tick()
		local targetY = groundY

		-- Flash warning
		spawn(function()
			for i = 1, 5 do
				if warningCircle and warningCircle.Parent then
					warningCircle.Transparency = 0.2
					wait(0.1)
					warningCircle.Transparency = 0.6
					wait(0.1)
				end
			end
		end)

		-- Follow player if this is a targeted star
		local followingPlayer = nil
		if targetPlayer then
			followingPlayer = targetPlayer

			-- Send warning to targeted player
			remoteEvents.NotifyPlayer:FireClient(targetPlayer, "WARNING! You are being targeted by a falling star!", 3)
		end

		while tick() - startTime < 1 and star and star.Parent do
			local elapsed = tick() - startTime
			local progress = elapsed / 1
			local newY = startY - (startY - targetY) * progress

			if star and star.Parent then
				-- Update X and Z if following a player
				if followingPlayer and followingPlayer.Character and followingPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local root = followingPlayer.Character.HumanoidRootPart
					x = root.Position.X
					z = root.Position.Z

					-- Update warning circle position too
					if warningCircle and warningCircle.Parent then
						warningCircle.CFrame = CFrame.new(x, groundY, z) * CFrame.Angles(0, 0, math.rad(90))
					end
				end

				star.Position = Vector3.new(x, newY, z)
			end

			wait()
		end

		if star and star.Parent then
			star.Position = Vector3.new(x, targetY, z)

			-- Create impact effect
			local explosion = Instance.new("Explosion")
			explosion.BlastRadius = 0  -- Visual only, no actual explosion force
			explosion.Position = star.Position
			explosion.ExplosionType = Enum.ExplosionType.NoCraters
			explosion.DestroyJointRadiusPercent = 0
			explosion.Parent = workspace

			-- Create white flash effect
			local flash = Instance.new("Part")
			flash.Shape = Enum.PartType.Ball
			flash.Size = Vector3.new(8, 8, 8)
			flash.Position = star.Position
			flash.Anchored = true
			flash.CanCollide = false
			flash.Material = Enum.Material.Neon
			flash.BrickColor = BrickColor.new("Institutional white")
			flash.Transparency = 0.3

			-- Add bright light on impact
			local impactLight = Instance.new("PointLight")
			impactLight.Color = Color3.new(1, 1, 1)
			impactLight.Brightness = 5
			impactLight.Range = 20
			impactLight.Parent = flash

			flash.Parent = workspace

			-- Remove warning circle
			if warningCircle and warningCircle.Parent then
				warningCircle:Destroy()
			end

			-- Check for player hits on impact
			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local rootPart = character.HumanoidRootPart
					local distance = (rootPart.Position - star.Position).Magnitude

					if distance <= 6 then -- Hit radius
						-- Check if player is currently answering a question
						local playerGui = player:FindFirstChild("PlayerGui")
						local isAnsweringQuestion = false

						if playerGui then
							local mazeGameUI = playerGui:FindFirstChild("MazeGameUI")
							if mazeGameUI and mazeGameUI:FindFirstChild("QuestionGui") then
								isAnsweringQuestion = true
							end
						end

						if not isAnsweringQuestion then
							-- Normal damage logic
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid then
								-- Reduce health by 30%
								local newHealth = humanoid.Health * (1 - DAMAGE_PERCENT/100)
								humanoid.Health = newHealth

								-- Notify player
								remoteEvents.NotifyPlayer:FireClient(player, "Hit by falling star! -" .. DAMAGE_PERCENT .. "% health", 3)
								remoteEvents.HealthChange:FireClient(player, humanoid.Health)

								-- Visual effect
								local sound = Instance.new("Sound")
								sound.SoundId = "rbxassetid://5982028003" -- Replace with actual sound ID
								sound.Volume = 1
								sound.Parent = rootPart
								sound:Play()
								game.Debris:AddItem(sound, 2)
							end
						else
							-- Player is answering a question - show shield effect
							local shield = Instance.new("Part")
							shield.Shape = Enum.PartType.Ball
							shield.Size = Vector3.new(10, 10, 10)
							shield.Position = rootPart.Position
							shield.Anchored = true
							shield.CanCollide = false
							shield.Material = Enum.Material.ForceField
							shield.BrickColor = BrickColor.new("Bright blue")
							shield.Transparency = 0.7
							shield.Parent = workspace

							-- Notify player they were protected
							remoteEvents.NotifyPlayer:FireClient(player, "Protected from star! (Answering question)", 2)

							-- Remove shield after brief moment
							game.Debris:AddItem(shield, 1)
						end
					end
				end
			end

			-- Fade out flash
			spawn(function()
				for i = 0, 10 do
					if flash and flash.Parent then
						flash.Transparency = 0.3 + (i/10) * 0.7
						if impactLight then
							impactLight.Brightness = 5 * (1 - i/10)
						end
					end
					wait(0.03)
				end
				if flash and flash.Parent then
					flash:Destroy()
				end
			end)

			-- Keep the star visible for a moment after impact
			wait(0.2)

			-- Fade out
			for i = 0, 10 do
				if star and star.Parent then
					star.Transparency = i/10
					if light then
						light.Brightness = 1 * (1 - i/10)
					end
				end
				wait(0.02)
			end
		end

		-- Remove from active stars and destroy
		for i, activeStar in ipairs(activeStars) do
			if activeStar == star then
				table.remove(activeStars, i)
				break
			end
		end

		if star and star.Parent then
			star:Destroy()
		end
	end)
end

-- Function to target a random player with a falling star
local function targetRandomPlayer()
	local players = Players:GetPlayers()
	if #players == 0 then return end

	-- Select a random player
	local targetPlayer = players[math.random(1, #players)]

	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local position = targetPlayer.Character.HumanoidRootPart.Position

		-- Spawn star above player's position
		spawnFallingStar(position.X, position.Z, targetPlayer)
	end
end

-- Main loop to continuously spawn stars
spawn(function()
	-- Wait 5 seconds before starting to give the game time to fully load
	wait(5)
	print("Starting falling stars spawning...")

	while true do
		-- Spawn 2-3 stars per interval
		for i = 1, math.random(2, 3) do
			spawnFallingStar()
		end

		-- Check if it's time to target a player
		if tick() - lastPlayerTargetTime >= PLAYER_TARGET_INTERVAL then
			lastPlayerTargetTime = tick()
			targetRandomPlayer()
		end

		wait(SPAWN_INTERVAL)
	end
end)

print("Falling Stars Handler initialized")