-- EmeraldHandler.lua
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
local Players = game:GetService("Players")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Question database (50+ questions) -- You can use module script for this but i was lazy :) -- Message from Pejman!
local questions = {
	{
		question = "What is a transformer in the context of machine learning?",
		options = {
			"A type of neural network architecture with self-attention mechanisms",
			"A hardware component that powers GPUs",
			"A data preprocessing technique",
			"A method to convert images to text"
		},
		correctAnswer = 1 -- Index of correct answer
	},
	{
		question = "What does LLM stand for?",
		options = {
			"Learning Language Model",
			"Large Language Model",
			"Linear Logic Method",
			"Linguistic Learning Machine"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of attention mechanism in transformers?",
		options = {
			"Self-attention",
			"Cross-attention",
			"Multi-head attention",
			"Recurrent attention"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary purpose of the positional encoding in transformers?",
		options = {
			"To add random noise to the input",
			"To encode the position of tokens in the sequence",
			"To normalize the input data",
			"To reduce the dimensionality of the input"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular library for implementing transformers?",
		options = {
			"TensorFlow",
			"PyTorch",
			"Hugging Face Transformers",
			"Scikit-learn"
		},
		correctAnswer = 3
	},
	{
		question = "What is the main advantage of using transfer learning in deep learning?",
		options = {
			"It reduces the need for large datasets",
			"It speeds up the training process",
			"It improves the model's generalization",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "Which of the following is NOT a type of gradient descent optimization algorithm?",
		options = {
			"Stochastic Gradient Descent (SGD)",
			"Adam",
			"RMSprop",
			"K-means"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the softmax function in neural networks?",
		options = {
			"To introduce non-linearity",
			"To normalize the output to a probability distribution",
			"To reduce overfitting",
			"To accelerate training"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a technique used in explainable AI (XAI)?",
		options = {
			"LIME",
			"SHAP",
			"Grad-CAM",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary goal of reinforcement learning?",
		options = {
			"To maximize the cumulative reward",
			"To minimize the loss function",
			"To classify data into categories",
			"To generate synthetic data"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a popular framework for building deep learning models?",
		options = {
			"Keras",
			"Caffe",
			"MXNet",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of dropout in neural networks?",
		options = {
			"To accelerate training",
			"To reduce overfitting",
			"To normalize the input data",
			"To introduce non-linearity"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of neural network?",
		options = {
			"Convolutional Neural Network (CNN)",
			"Recurrent Neural Network (RNN)",
			"Generative Adversarial Network (GAN)",
			"Support Vector Network (SVN)"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Generative Adversarial Network (GAN)?",
		options = {
			"To classify images",
			"To generate synthetic data",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular technique for dimensionality reduction?",
		options = {
			"Principal Component Analysis (PCA)",
			"t-SNE",
			"UMAP",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of batch normalization in deep learning?",
		options = {
			"To accelerate training",
			"To reduce overfitting",
			"To normalize the input data",
			"To stabilize and accelerate training"
		},
		correctAnswer = 4
	},
	{
		question = "Which of the following is a popular activation function in deep learning?",
		options = {
			"ReLU",
			"Sigmoid",
			"Tanh",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of an autoencoder?",
		options = {
			"To classify data",
			"To generate synthetic data",
			"To learn efficient codings of input data",
			"To perform regression analysis"
		},
		correctAnswer = 3
	},
	{
		question = "Which of the following is a technique used for hyperparameter tuning?",
		options = {
			"Grid Search",
			"Random Search",
			"Bayesian Optimization",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the attention mechanism in transformers?",
		options = {
			"To reduce the dimensionality of the input",
			"To weigh the importance of input elements",
			"To normalize the input data",
			"To introduce non-linearity"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of ensemble learning method?",
		options = {
			"Bagging",
			"Boosting",
			"Stacking",
			"Principal Component Analysis (PCA)"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Long Short-Term Memory (LSTM) network?",
		options = {
			"To classify images",
			"To process sequential data",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular metric for evaluating classification models?",
		options = {
			"Accuracy",
			"Precision",
			"Recall",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the learning rate in training neural networks?",
		options = {
			"To control the step size in updating weights",
			"To normalize the input data",
			"To introduce non-linearity",
			"To reduce overfitting"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a technique used for handling imbalanced datasets?",
		options = {
			"SMOTE",
			"Undersampling",
			"Oversampling",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Convolutional Neural Network (CNN)?",
		options = {
			"To process sequential data",
			"To classify images",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular loss function for binary classification?",
		options = {
			"Mean Squared Error",
			"Cross-Entropy Loss",
			"Hinge Loss",
			"Mean Absolute Error"
		},
		correctAnswer = 2
	},
	{
		question = "What is the purpose of the bias term in a neural network?",
		options = {
			"To accelerate training",
			"To allow the activation function to shift",
			"To normalize the input data",
			"To introduce non-linearity"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of unsupervised learning algorithm?",
		options = {
			"K-means clustering",
			"Principal Component Analysis (PCA)",
			"Linear Regression",
			"Association Rule Learning"
		},
		correctAnswer = 3
	},
	{
		question = "What is the primary use of a Recurrent Neural Network (RNN)?",
		options = {
			"To classify images",
			"To process sequential data",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular metric for evaluating regression models?",
		options = {
			"Mean Squared Error",
			"R-squared",
			"Mean Absolute Error",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the activation function in a neural network?",
		options = {
			"To introduce non-linearity",
			"To normalize the input data",
			"To reduce overfitting",
			"To accelerate training"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a technique used for model interpretation?",
		options = {
			"Partial Dependence Plots",
			"Individual Conditional Expectation (ICE) Plots",
			"Accumulated Local Effects (ALE) Plots",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Support Vector Machine (SVM)?",
		options = {
			"To classify data",
			"To generate synthetic data",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a popular technique for anomaly detection?",
		options = {
			"Isolation Forest",
			"Local Outlier Factor (LOF)",
			"One-Class SVM",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the embedding layer in a neural network?",
		options = {
			"To reduce the dimensionality of the input",
			"To convert categorical data into numerical data",
			"To normalize the input data",
			"To introduce non-linearity"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of reinforcement learning algorithm?",
		options = {
			"Q-Learning",
			"SARSA",
			"Deep Deterministic Policy Gradient (DDPG)",
			"K-means"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Variational Autoencoder (VAE)?",
		options = {
			"To classify data",
			"To generate synthetic data",
			"To perform regression analysis",
			"To cluster data points"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is a popular technique for feature selection?",
		options = {
			"Recursive Feature Elimination (RFE)",
			"Lasso Regression",
			"Tree-based Feature Importance",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the pooling layer in a Convolutional Neural Network (CNN)?",
		options = {
			"To reduce the dimensionality of the input",
			"To introduce non-linearity",
			"To normalize the input data",
			"To reduce overfitting"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a technique used for model evaluation?",
		options = {
			"Cross-Validation",
			"Bootstrapping",
			"Confusion Matrix",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the primary use of a Decision Tree?",
		options = {
			"To classify data",
			"To generate synthetic data",
			"To perform regression analysis",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "Which of the following is a popular technique for handling missing data?",
		options = {
			"Imputation",
			"Deletion",
			"Model-based methods",
			"All of the above"
		},
		correctAnswer = 4
	},
	{
		question = "What is the purpose of the loss function in training neural networks?",
		options = {
			"To measure the accuracy of the model",
			"To quantify the difference between predicted and actual values",
			"To normalize the input data",
			"To introduce non-linearity"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a type of clustering algorithm?",
		options = {
			"K-means",
			"Hierarchical clustering",
			"DBSCAN",
			"Linear Regression"
		},
		correctAnswer = 4
	},
	{
		question = "Which of the following is a technique used for reducing the variance of a model?",
		options = {
			"Bagging",
			"Boosting",
			"Stacking",
			"Regularization"
		},
		correctAnswer = 1
	},
	{
		question = "What is the primary purpose of the encoder in a sequence-to-sequence model?",
		options = {
			"To generate the output sequence",
			"To process the input sequence and produce a context vector",
			"To evaluate the model's performance",
			"To normalize the input data"
		},
		correctAnswer = 2
	},
	{
		question = "Which of the following is NOT a common challenge in training deep learning models?",
		options = {
			"Overfitting",
			"Underfitting",
			"Data abundance",
			"Vanishing gradients"
		},
		correctAnswer = 3
	},
	{
		question = "What is the purpose of the 'epoch' in training a neural network?",
		options = {
			"A single pass through the entire training dataset",
			"A measure of the model's accuracy",
			"A technique for reducing overfitting",
			"A method for normalizing the input data"
		},
		correctAnswer = 1
	},
	{
		question = "Which of the following is a popular framework for automated machine learning (AutoML)?",
		options = {
			"Auto-sklearn",
			"TPOT",
			"H2O.ai",
			"All of the above"
		},
		correctAnswer = 4
	}
}
-- End Questions --


-- Function to get a random question
local function getRandomQuestion()
	return questions[math.random(1, #questions)]
end

-- Setup emerald interactions
local function setupEmeralds()
	print("Setting up emerald interactions...")

	-- Setup Green Emeralds (Quiz Questions)
	local greenFolder = workspace:WaitForChild("GreenEmerald")
	for _, emerald in pairs(greenFolder:GetChildren()) do
		if emerald:IsA("BasePart") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Create prompt for better visibility
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Answer Question"
			prompt.ObjectText = "AI Quiz"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = emerald

			-- Connect to prompt triggered instead of touched
			prompt.Triggered:Connect(function(player)
				if emerald:GetAttribute("Enabled") ~= false then
					-- Disable emerald temporarily
					emerald:SetAttribute("Enabled", false)
					emerald.Transparency = 0.7
					prompt.Enabled = false

					-- Send question to player
					local randomQuestion = getRandomQuestion()
					remoteEvents.QuestionEvent:FireClient(player, randomQuestion)

					-- Re-enable after delay
					task.delay(120, function() -- 2 minutes
						emerald:SetAttribute("Enabled", true)
						emerald.Transparency = 0
						prompt.Enabled = true
					end)
				end
			end)

			-- Initialize as enabled
			emerald:SetAttribute("Enabled", true)
		end
	end

	-- Setup Yellow Emeralds (Speed Boost)
	local yellowFolder = workspace:WaitForChild("YellowEmerald")
	for _, emerald in pairs(yellowFolder:GetChildren()) do
		if emerald:IsA("BasePart") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Create prompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Collect Speed Boost"
			prompt.ObjectText = "Speed Power"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = emerald

			-- Connect to prompt triggered
			prompt.Triggered:Connect(function(player)
				if emerald:GetAttribute("Enabled") ~= false then
					local playerData = _G.playerData[player.UserId]
					if playerData and playerData.inventory.speedBoosts < 3 then
						-- Disable emerald temporarily
						emerald:SetAttribute("Enabled", false)
						emerald.Transparency = 0.7
						prompt.Enabled = false

						-- Add speed boost to inventory
						playerData.inventory.speedBoosts = playerData.inventory.speedBoosts + 1
						remoteEvents.SpeedBoost:FireClient(player, playerData.inventory.speedBoosts)

						-- Play collection sound
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://6042053626" -- Replace with actual sound ID
						sound.Parent = player.Character.HumanoidRootPart
						sound:Play()
						game.Debris:AddItem(sound, 2)

						-- Re-enable after delay
						task.delay(120, function() -- 2 minutes
							emerald:SetAttribute("Enabled", true)
							emerald.Transparency = 0
							prompt.Enabled = true
						end)
					else
						-- Notify player inventory is full
						remoteEvents.NotifyPlayer:FireClient(player, "You can't carry more than 3 speed boosts!")
					end
				end
			end)

			-- Initialize as enabled
			emerald:SetAttribute("Enabled", true)
		end
	end

	-- Setup Red Emeralds (Health Reduction)
	local redFolder = workspace:WaitForChild("RedEmerald")
	for _, emerald in pairs(redFolder:GetChildren()) do
		if emerald:IsA("BasePart") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Create a touched event instead of prompt (this is a trap)
			emerald.Touched:Connect(function(hit)
				local character = hit.Parent
				local player = Players:GetPlayerFromCharacter(character)

				if player and emerald:GetAttribute("Enabled") ~= false and character:FindFirstChild("Humanoid") then
					-- Disable emerald temporarily
					emerald:SetAttribute("Enabled", false)
					emerald.Transparency = 0.7

					-- Reduce player health
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.Health = humanoid.Health * 0.5 -- Reduce health by 50% hahahaha :)
					end

					-- Notify player
					remoteEvents.HealthChange:FireClient(player, humanoid.Health)
					remoteEvents.NotifyPlayer:FireClient(player, "Ouch! You lost 50% of your health!")

					-- Play damage sound
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://5982028003" -- Replace with actual sound ID
					sound.Parent = character.HumanoidRootPart
					sound:Play()
					game.Debris:AddItem(sound, 2)

					-- Re-enable after delay
					task.delay(120, function() -- 2 minutes
						emerald:SetAttribute("Enabled", true)
						emerald.Transparency = 0
					end)
				end
			end)

			-- Initialize as enabled
			emerald:SetAttribute("Enabled", true)
		end
	end

	-- Setup Blue Emeralds (Hint Tokens)
	local blueFolder = workspace:WaitForChild("BlueEmerald")
	for _, emerald in pairs(blueFolder:GetChildren()) do
		if emerald:IsA("BasePart") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Create prompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Collect Hint Token"
			prompt.ObjectText = "Question Hint"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = emerald

			-- Connect to prompt triggered
			prompt.Triggered:Connect(function(player)
				if emerald:GetAttribute("Enabled") ~= false then
					local playerData = _G.playerData[player.UserId]
					if playerData then
						-- Add check for maximum 3 hint tokens
						if playerData.inventory.hintTokens < 3 then
							-- Disable emerald temporarily
							emerald:SetAttribute("Enabled", false)
							emerald.Transparency = 0.7
							prompt.Enabled = false

							-- Add hint token to inventory
							playerData.inventory.hintTokens = playerData.inventory.hintTokens + 1
							remoteEvents.HintToken:FireClient(player, playerData.inventory.hintTokens)

							-- Notify player
							remoteEvents.NotifyPlayer:FireClient(player, "Hint token collected! Use it to eliminate a wrong answer.")

							-- Play collection sound
							local sound = Instance.new("Sound")
							sound.SoundId = "rbxassetid://6042053626" -- Replace with actual sound ID
							sound.Parent = player.Character.HumanoidRootPart
							sound:Play()
							game.Debris:AddItem(sound, 2)

							-- Re-enable after delay
							task.delay(120, function() -- 2 minutes
								emerald:SetAttribute("Enabled", true)
								emerald.Transparency = 0
								prompt.Enabled = true
							end)
						else
							-- Notify player inventory is full
							remoteEvents.NotifyPlayer:FireClient(player, "You can't carry more than 3 hint tokens!")
						end
					end
				end
			end)

			-- Initialize as enabled
			emerald:SetAttribute("Enabled", true)
		end
	end

	-- Setup Purple Emeralds (Map View)
	local purpleFolder = workspace:WaitForChild("PurpleEmerald")
	for _, emerald in pairs(purpleFolder:GetChildren()) do
		if emerald:IsA("BasePart") then
			-- Initialize properties
			emerald.CanCollide = false
			emerald.Anchored = true

			-- Create prompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Collect Map View"
			prompt.ObjectText = "Maze Map"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = emerald

			-- Connect to prompt triggered
			prompt.Triggered:Connect(function(player)
				if emerald:GetAttribute("Enabled") ~= false then
					local playerData = _G.playerData[player.UserId]
					if playerData and playerData.inventory.mapViews < 3 then
						-- Disable emerald temporarily
						emerald:SetAttribute("Enabled", false)
						emerald.Transparency = 0.7
						prompt.Enabled = false

						-- Add map view to inventory
						playerData.inventory.mapViews = playerData.inventory.mapViews + 1
						remoteEvents.ShowMap:FireClient(player, playerData.inventory.mapViews)

						-- Notify player
						remoteEvents.NotifyPlayer:FireClient(player, "Map view collected! Use it to see the maze layout temporarily.")

						-- Play collection sound
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://6042053626" -- Replace with actual sound ID
						sound.Parent = player.Character.HumanoidRootPart
						sound:Play()
						game.Debris:AddItem(sound, 2)

						-- Re-enable after delay
						task.delay(120, function() -- 2 minutes
							emerald:SetAttribute("Enabled", true)
							emerald.Transparency = 0
							prompt.Enabled = true
						end)
					else
						-- Notify player inventory is full
						remoteEvents.NotifyPlayer:FireClient(player, "You can't carry more than 3 map views!")
					end
				end
			end)

			-- Initialize as enabled
			emerald:SetAttribute("Enabled", true)
		end
	end

	print("All emeralds setup complete")
end

-- Initialize emerald setup when the script runs
setupEmeralds()

-- Handle question responses
remoteEvents.QuestionEvent.OnServerEvent:Connect(function(player, questionData, selectedAnswer)
	if selectedAnswer == questionData.correctAnswer then
		-- Correct answer
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local score = leaderstats:FindFirstChild("Score")
			if score then
				score.Value = score.Value + 10

				-- Notify player
				remoteEvents.NotifyPlayer:FireClient(player, "Correct! +10 points")

				-- Play success sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://5870458868" -- Replace with actual sound ID
				sound.Parent = player.Character.HumanoidRootPart
				sound:Play()
				game.Debris:AddItem(sound, 2)
			end
		end
	else
		-- Incorrect answer
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local score = leaderstats:FindFirstChild("Score")
			if score then
				score.Value = score.Value - 5

				-- Notify player
				remoteEvents.NotifyPlayer:FireClient(player, "Incorrect! -5 points")

				-- Play failure sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://6342988723" -- Replace with actual sound ID
				sound.Parent = player.Character.HumanoidRootPart
				sound:Play()
				game.Debris:AddItem(sound, 2)
			end
		end
	end
end)

-- Handle speed boost activation
remoteEvents.ActivateSpeedBoost.OnServerEvent:Connect(function(player)
	local playerData = _G.playerData[player.UserId]

	if playerData and playerData.inventory.speedBoosts > 0 then
		-- Reduce inventory count
		playerData.inventory.speedBoosts = playerData.inventory.speedBoosts - 1

		-- Update client inventory display
		remoteEvents.SpeedBoost:FireClient(player, playerData.inventory.speedBoosts)

		-- Apply speed boost to character
		local character = player.Character
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character:FindFirstChild("Humanoid")
			local normalWalkSpeed = humanoid.WalkSpeed

			-- Increase speed
			humanoid.WalkSpeed = normalWalkSpeed * 2 -- Double the speed

			-- Notify player
			remoteEvents.NotifyPlayer:FireClient(player, "Speed boost activated! 5 seconds remaining.")

			-- Play boost sound
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://1283290053" -- Replace with actual sound ID
			sound.Parent = character.HumanoidRootPart
			sound:Play()
			game.Debris:AddItem(sound, 2)

			-- Create visual effect
			local speedEffect = Instance.new("ParticleEmitter")
			speedEffect.Texture = "rbxassetid://6334457600" -- Replace with appropriate texture
			speedEffect.Rate = 25
			speedEffect.Speed = NumberRange.new(3, 5)
			speedEffect.Lifetime = NumberRange.new(0.5, 1)
			speedEffect.Parent = character.HumanoidRootPart

			-- Reset after duration
			task.delay(5, function() -- 5 seconds duration
				humanoid.WalkSpeed = normalWalkSpeed
				speedEffect:Destroy()
				remoteEvents.NotifyPlayer:FireClient(player, "Speed boost ended.")
			end)
		end
	end
end)

-- Handle hint token usage
remoteEvents.UseHintToken.OnServerEvent:Connect(function(player, questionData)
	local playerData = _G.playerData[player.UserId]

	if playerData and playerData.inventory.hintTokens > 0 then
		-- Reduce inventory count
		playerData.inventory.hintTokens = playerData.inventory.hintTokens - 1

		-- Update client inventory display
		remoteEvents.HintToken:FireClient(player, playerData.inventory.hintTokens)

		-- Find a wrong answer to eliminate
		local wrongAnswers = {}
		for i = 1, #questionData.options do
			if i ~= questionData.correctAnswer then
				table.insert(wrongAnswers, i)
			end
		end

		-- Randomly select one wrong answer to eliminate
		local randomWrongIndex = math.random(1, #wrongAnswers)
		local eliminatedOption = wrongAnswers[randomWrongIndex]

		-- Send the eliminated option back to client
		remoteEvents.EliminateOption:FireClient(player, eliminatedOption)
	end
end)

-- Handle map view activation
remoteEvents.ActivateMapView.OnServerEvent:Connect(function(player)
	local playerData = _G.playerData[player.UserId]

	if playerData and playerData.inventory.mapViews > 0 then
		-- Reduce inventory count
		playerData.inventory.mapViews = playerData.inventory.mapViews - 1

		-- Update client inventory display
		remoteEvents.ShowMap:FireClient(player, playerData.inventory.mapViews, true) -- true = activate

		-- Notify player
		remoteEvents.NotifyPlayer:FireClient(player, "Map view activated! 10 seconds remaining.")

		-- Reset after duration
		task.delay(10, function() -- 10 seconds duration
			remoteEvents.ShowMap:FireClient(player, playerData.inventory.mapViews, false) -- false = deactivate
			remoteEvents.NotifyPlayer:FireClient(player, "Map view ended.")
		end)
	end
end)

-- Print confirmation that script is running
print("EmeraldHandler script is running")