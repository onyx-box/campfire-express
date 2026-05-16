local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ResourceService = Knit.CreateService({
	Name = "ResourceService",
	Client = {}
})

ResourceService.PlayerResources = {}

function ResourceService:InitPlayer(player)
	if self.PlayerResources[player] then
		return
	end

	self.PlayerResources[player] = {
		wood = 500,
		scrap = 100,
	}

	print("[ResourceService] Init player:", player.Name)
end

function ResourceService.Client:GetResources(player)
	return self.Server:Get(player)
end

function ResourceService:Give(player, resource, amount)
	self:InitPlayer(player)

	local data = self.PlayerResources[player]
	data[resource] = (data[resource] or 0) + amount

	print(player.Name, resource, data[resource])
end

function ResourceService:Has(player, resource, amount)
	self:InitPlayer(player)

	local data = self.PlayerResources[player]
	return (data[resource] or 0) >= amount
end

function ResourceService:Take(player, resource, amount)
	self:InitPlayer(player)

	if not self:Has(player, resource, amount) then
		return false
	end

	self.PlayerResources[player][resource] -= amount
	return true
end

function ResourceService:Get(player)
	self:InitPlayer(player)
	return self.PlayerResources[player]
end

function ResourceService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		self:InitPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:InitPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.PlayerResources[player] = nil
	end)
end

return ResourceService