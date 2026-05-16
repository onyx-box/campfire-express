local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WorldService = Knit.CreateService({ Name = "WorldService", Client = {}, })

WorldService.WorldRadius = 250

WorldService.TreeCount = 80
WorldService.ScrapCount = 35

function WorldService:GetRandomPosition()

	local radius = self.WorldRadius

	local x = math.random(-radius, radius)

	local z = math.random(-radius, radius)

	return Vector3.new( x, 2, z )

end

function WorldService:GenerateTrees()

	local ResourceNodeService = Knit.GetService("ResourceNodeService")

	for i = 1, self.TreeCount do

		local position = self:GetRandomPosition()

		ResourceNodeService:CreateNode(
			"wood",
			position
		)

	end

	print("[World] Trees generated")

end

function WorldService:GenerateScrap()

	local ResourceNodeService = Knit.GetService("ResourceNodeService")

	for i = 1, self.ScrapCount do

		local position = self:GetRandomPosition()

		ResourceNodeService:CreateNode(
			"scrap",
			position
		)

	end

	print("[World] Scrap generated")

end

function WorldService:KnitStart()

	task.wait(1)

	self:GenerateTrees()
	self:GenerateScrap()

end

return WorldService