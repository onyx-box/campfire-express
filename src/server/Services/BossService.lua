local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BossService = Knit.CreateService({
	Name = "BossService",
	Client = {},
})

function BossService:SpawnCurrentBiomeBoss()
	local EnemyService = Knit.GetService("EnemyService")
	local biome = Knit.GetService( "BiomeService" ):GetCurrentBiome()

	print("[Boss] Spawned:", biome.boss)

	return EnemyService:SpawnEnemy(
		biome.boss,
		Vector3.new(-40, 3, -15)
	)
end

return BossService