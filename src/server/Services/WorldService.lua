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

function WorldService:GenerateCurrentBiome()
	local biome = Knit.GetService("BiomeService"):GetCurrentBiome()

	self.TreeCount = biome.treeCount
	self.ScrapCount = biome.scrapCount
	self.WorldRadius = biome.worldRadius or 250

		for _, resourceDef in pairs(
		biome.resources
	) do

		for i = 1, resourceDef.count do

			local position = self:GetRandomPosition()

			Knit.GetService(
				"ResourceNodeService"
			):CreateNode(
				resourceDef.nodeType,
				position
			)

		end
	end

	print(
		"[World] Generated biome:",
		biome.name
	)
end

function WorldService:ClearWorld()

	local ResourceNodeService =
		Knit.GetService(
			"ResourceNodeService"
		)

	for part, _ in pairs(
		ResourceNodeService.Nodes
	) do

		if part and part.Parent then
			part:Destroy()
		end

	end

	ResourceNodeService.Nodes = {}

end

function WorldService:KnitStart()

	task.wait(1)
	self:GenerateCurrentBiome()

end

return WorldService