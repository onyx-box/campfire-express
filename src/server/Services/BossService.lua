local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BossService = Knit.CreateService({
	Name = "BossService",
	Client = {},
})

function BossService:SpawnForestBoss()
	local EnemyService = Knit.GetService("EnemyService")

	print("[Boss] Forest boss spawned")

	return EnemyService:SpawnEnemy(
		"boss_forest",
		Vector3.new(-40, 3, -15)
	)
end

return BossService