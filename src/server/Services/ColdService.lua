local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ColdService = Knit.CreateService({
	Name = "ColdService",
	Client = {},
})

ColdService.DayLength = 240
ColdService.Time = 12

ColdService.CampfireRange = 35
ColdService.PlayerTemperature = {}

ColdService.MaxTemperature = 100
ColdService.MinTemperature = 0
ColdService.ColdDamage = 5

ColdService.CoolRate = 4
ColdService.WarmRate = 8

function ColdService.Client:GetTemperature(player)
	return self.Server:GetTemperature(player)
end

function ColdService:GetTemperature(player)
	self.PlayerTemperature[player] = self.PlayerTemperature[player] or self.MaxTemperature

	return {
		current = self.PlayerTemperature[player],
		max = self.MaxTemperature,
	}
end

function ColdService:IsPlayerWarm(player)
	local character = player.Character
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local campfire = Workspace:FindFirstChild("Campfire")
	if not campfire then
		return false
	end

	local distance = (root.Position - campfire.Position).Magnitude

	return distance <= self.CampfireRange
end

function ColdService:UpdatePlayerTemperature(player)
	local DayNightService = Knit.GetService("DayNightService")
	self.PlayerTemperature[player] = self.PlayerTemperature[player] or self.MaxTemperature

	local isWarm = self:IsPlayerWarm(player)

	if DayNightService.IsNight and not isWarm then
		self.PlayerTemperature[player] = math.max(
			self.MinTemperature,
			self.PlayerTemperature[player] - self.CoolRate
		)
	else
		self.PlayerTemperature[player] = math.min(
			self.MaxTemperature,
			self.PlayerTemperature[player] + self.WarmRate
		)
	end
end

function ColdService:DamagePlayerIfFrozen(player)
	local temp = self.PlayerTemperature[player] or self.MaxTemperature

	if temp > 0 then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid:TakeDamage(self.ColdDamage)
	print("[Cold] Frozen damage:", player.Name)
end

function ColdService:UpdateLighting()
	Lighting.ClockTime = self.Time

	local DayNightService = Knit.GetService("DayNightService")
	if DayNightService.IsNight then
		Lighting.Brightness = 1
		Lighting.OutdoorAmbient = Color3.fromRGB(60, 60, 90)
	else
		Lighting.Brightness = 3
		Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
	end
end

function ColdService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		self.PlayerTemperature[player] = self.MaxTemperature
	end

	Players.PlayerAdded:Connect(function(player)
		self.PlayerTemperature[player] = self.MaxTemperature
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.PlayerTemperature[player] = nil
	end)

	task.spawn(function()
		while true do
			self.Time += 24 / self.DayLength

			if self.Time >= 24 then
				self.Time = 0
			end

			self:UpdateLighting()

			for _, player in ipairs(Players:GetPlayers()) do
				self:UpdatePlayerTemperature(player)
				self:DamagePlayerIfFrozen(player)
			end

			task.wait(1)
		end
	end)
end

return ColdService