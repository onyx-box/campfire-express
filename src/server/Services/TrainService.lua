local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TrainPath = require(ReplicatedStorage.Shared.Config.TrainPath)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {},
})

TrainService.Speed = 18
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
end

function TrainService:KnitStart()
	self:CreateTrain()

	RunService.Heartbeat:Connect(function(dt)
		self:Move(dt)
	end)
end

return TrainService