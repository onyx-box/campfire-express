local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TrainPath = require(ReplicatedStorage.Shared.Config.TrainPath)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {},
})

TrainService.Speed = 9
TrainService.CurrentWaypoint = 1
TrainService.IsMoving = true

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
		self.IsMoving = false
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

	local move = direction.Unit * self.Speed * dt

	if move.Magnitude > distance then
		move = direction
	end

	self.Wagon.Position += move

	local delta = self.Wagon.Position - oldPosition

	for _, root in ipairs(passengers) do
		root.CFrame = root.CFrame + delta
	end
end

function TrainService:KnitStart()
	self:CreateTrain()

	RunService.Heartbeat:Connect(function(dt)
		self:Move(dt)
	end)
end

return TrainService