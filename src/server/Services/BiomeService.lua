local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Biomes = require(ReplicatedStorage.Shared.Config.Biomes)

local BiomeService = Knit.CreateService({ Name = "BiomeService", Client = {}, })

BiomeService.CurrentBiomeIndex = 1

function BiomeService:GetCurrentBiome()
	return Biomes[
		self.CurrentBiomeIndex
	]
end

function BiomeService.Client:GetCurrentBiome(player)
	return self.Server:GetCurrentBiome()
end

function BiomeService:NextBiome()

	self.CurrentBiomeIndex += 1

	if self.CurrentBiomeIndex > #Biomes then
		self.CurrentBiomeIndex = #Biomes
	end

	local biome = self:GetCurrentBiome()

	print( "[Biome] Changed to:", biome.name )

	local WorldService = Knit.GetService("WorldService")
	WorldService:GenerateCurrentBiome()

	return biome
end

return BiomeService