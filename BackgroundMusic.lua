-- BackgroundMusic.lua
-- Place this in ServerScriptService

--[[
   The Pejman Maze Educational Game
   
   An educational maze game with AI quiz questions and interactive challenges.
   Developed at the University of Liechtenstein.
   
   Creator: Dr. Pejman Ebrahimi
   Email: pejman.ebrahimi@uni.li
   Department of Information Systems & Computer Science
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a Sound instance in the Workspace
local backgroundMusic = Instance.new("Sound")
backgroundMusic.Name = "BackgroundMusic"
backgroundMusic.SoundId = "rbxassetid://9042971614"  -- Your specified sound ID - Not necessary!
backgroundMusic.Volume = 0.5  -- Adjust volume as needed
backgroundMusic.Looped = true  -- Music will loop continuously
backgroundMusic.Parent = workspace

-- Play the music as soon as the game starts (server-side)
backgroundMusic:Play()

print("Background music started")