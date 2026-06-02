local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TrainPath = require(ReplicatedStorage.Shared.Config.TrainPath)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {},
})

TrainService.MaxHealth = 1000
TrainService.CurrentHealth = 1000
TrainService.BaseSpeed = 20
TrainService.CurrentWaypoint = 1
TrainService.IsMoving = false

function TrainService:Damage(amount)

	self.CurrentHealth = math.max( 0, self.CurrentHealth - amount )

	print( "[Train]", self.CurrentHealth, "/", self.MaxHealth )

	if self.CurrentHealth <= 0 then

		self.IsMoving = false

		print( "[Train] Destroyed" )

	end

end

function TrainService:Repair(amount)

	self.CurrentHealth = math.min( self.MaxHealth, self.CurrentHealth + amount )

	print( "[Train] Repaired:", self.CurrentHealth, "/", self.MaxHealth )

end

function TrainService:CreateTrain()
	local wagon = Instance.new("Part")
	wagon.Name = "TrainWagon"
	wagon.Size = Vector3.new(24, 2, 14)
	wagon.Position = TrainPath[1]
	wagon.Anchored = true
	wagon.Color = Color3.fromRGB(70, 70, 80)
	wagon.Material = Enum.Material.Metal
	wagon.Parent = Workspace

	self.Wagon = wagon

	local prompt = Instance.new("ProximityPrompt")

	prompt.ActionText = "Start Train"
	prompt.ObjectText = "Locomotive"

	prompt.MaxActivationDistance = 10

	prompt.Parent = self.Wagon

	prompt.Triggered:Connect(function(player)

		local ResourceService = Knit.GetService( "ResourceService" )

		local biome = Knit.GetService( "BiomeService" ):GetCurrentBiome()

		local key = biome.nextBiomeKey

		if not ResourceService:Has( player, key, 1 ) then

			warn( "[Train] Missing key:", key )

			return
		end

		ResourceService:Take( player, key, 1 )

		self:StartTrain()

	end)

	local repairPrompt = Instance.new( "ProximityPrompt" )
	repairPrompt.ActionText = "Repair Train"
	repairPrompt.ObjectText = "Train"
	repairPrompt.Parent = self.Wagon

	repairPrompt.Triggered:Connect(
		function(player)

			local ResourceService = Knit.GetService( "ResourceService" )

			if not ResourceService:Has( player, "scrap", 25 ) then
				return
			end
			if not ResourceService:Has( player, "wood", 25 ) then
				return
			end

			ResourceService:Take( player, "scrap", 25 )
			ResourceService:Take( player, "wood", 25 )

			self:Repair(100)

		end
	)
end

function TrainService:StartTrain()
	if self.IsMoving then
		return
	end

	self.IsMoving = true

	print("[Train] Departing...")
end

function TrainService:GetPlayersOnTrain()
	local playersOnTrain = {}

	if not self.Wagon then
		return playersOnTrain
	end

	local wagon = self.Wagon
	local wagonSize = wagon.Size
	local wagonPosition = wagon.Position

	for _, player in ipairs(game.Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end

		local relative = wagon.CFrame:PointToObjectSpace(root.Position)

		local isOnTop =
			math.abs(relative.X) <= wagonSize.X / 2
			and math.abs(relative.Z) <= wagonSize.Z / 2
			and relative.Y >= wagonSize.Y / 2
			and relative.Y <= wagonSize.Y / 2 + 8

		if isOnTop then
			table.insert(playersOnTrain, root)
		end
	end

	return playersOnTrain
end

function TrainService:Move(dt)
	if not self.IsMoving or not self.Wagon then
		return
	end

	local nextWaypoint = TrainPath[self.CurrentWaypoint + 1]

	if not nextWaypoint then
		local BiomeService = Knit.GetService( "BiomeService" )

		BiomeService:NextBiome()

		self.IsMoving = false
		self.CurrentWaypoint = 1
		self.Wagon.Position = TrainPath[1]
		print("[Train] Arrived at final station")
		return
	end
	local passengers = self:GetPlayersOnTrain()
	local oldPosition = self.Wagon.Position

	local currentPosition = self.Wagon.Position
	local direction = nextWaypoint - currentPosition
	local distance = direction.Magnitude

	if distance < 0.5 then
		self.CurrentWaypoint += 1
		print("[Train] Reached waypoint:", self.CurrentWaypoint)
		return
	end

	local hpPercent = self.CurrentHealth / self.MaxHealth

	local speedMultiplier = math.clamp( hpPercent, 0.25, 1 )

	local move = direction.Unit * self.BaseSpeed * speedMultiplier * dt

	if move.Magnitude > distance then
		move = direction
	end

	self.Wagon.Position += move

	local delta = self.Wagon.Position - oldPosition

	for _, turret in ipairs(self:GetTurretsOnTrain()) do
		if turret:IsA("BasePart") then
			turret.Position += delta
		end
	end

	for _, root in ipairs(passengers) do
		local character = root.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.MoveDirection.Magnitude < 0.1 then
			root.CFrame = root.CFrame + delta
		end
	end
end

function TrainService:GetTurretsOnTrain()
	local turrets = {}

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:GetAttribute("OnTrain") then
			table.insert(turrets, obj)
		end
	end

	return turrets
end

function TrainService:KnitStart()
	self:CreateTrain()

	RunService.Heartbeat:Connect(function(dt)
		self:Move(dt)
	end)
end

return TrainService