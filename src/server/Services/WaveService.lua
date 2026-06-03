local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WaveConfig = require(ReplicatedStorage.Shared.Config.WaveConfig)

local WaveService = Knit.CreateService({
	Name = "WaveService",
	Client = {}
})

WaveService.CurrentWave = 1

function WaveService:KnitStart()

	local DayNightService = Knit.GetService( "DayNightService" )

	DayNightService.NightStarted.Event:Connect(
		function()

			self:StartWaveNight()

		end
	)

end

function WaveService:StartWaveNight()
	if WaveConfig[self.CurrentWave] then
		self:StartWave(self.CurrentWave)
		self.CurrentWave += 1
		return
	end

	local BossService = Knit.GetService("BossService")
	BossService:SpawnCurrentBiomeBoss()

	self.CurrentWave = 1
end

function WaveService:StartWave(waveNumber)

	local EnemyService = Knit.GetService("EnemyService")

	local wave = WaveConfig[waveNumber]

	if not wave then
		warn("Wave not found:", waveNumber)
		return
	end

	local biome = Knit.GetService( "BiomeService" ):GetCurrentBiome()

	print("Starting wave:", waveNumber)

	task.spawn(function()

		for _, group in ipairs(wave.enemies) do

			for i = 1, group.count do
				local enemyType = group.type

				if enemyType == "biome_random" then
					enemyType = biome.enemyPool[math.random(#biome.enemyPool)]
				end
				EnemyService:SpawnEnemy(
					enemyType,
					Vector3.new(0, 3, math.random(-20, 20))
				)

				task.wait(group.delay)
			end
		end

		print("Wave finished:", waveNumber)

	end)
end

return WaveService