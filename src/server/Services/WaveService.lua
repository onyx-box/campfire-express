local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WaveConfig = require(ReplicatedStorage.Shared.Config.WaveConfig)

local WaveService = Knit.CreateService({
	Name = "WaveService",
	Client = {}
})

function WaveService:KnitStart()

	task.wait(2)

	self:StartWave(1)

	task.wait(15)

	self:StartWave(2)

	task.wait(20)

	self:StartWave(3)

	task.wait(5)

	local BossService = Knit.GetService("BossService")
	BossService:SpawnForestBoss()

end

function WaveService:StartWave(waveNumber)

	local EnemyService = Knit.GetService("EnemyService")

	local wave = WaveConfig[waveNumber]

	if not wave then
		warn("Wave not found:", waveNumber)
		return
	end

	print("Starting wave:", waveNumber)

	task.spawn(function()

		for _, group in ipairs(wave.enemies) do

			for i = 1, group.count do

				EnemyService:SpawnEnemy(
					group.type,
					Vector3.new(0, 3, math.random(-20, 20))
				)

				task.wait(group.delay)
			end
		end

		print("Wave finished:", waveNumber)

	end)
end

return WaveService