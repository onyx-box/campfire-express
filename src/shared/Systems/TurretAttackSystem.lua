local Position = require(script.Parent.Parent.Components.Position)
local Turret = require(script.Parent.Parent.Components.Turret)
local Enemy = require(script.Parent.Parent.Components.Enemy)
local Health = require(script.Parent.Parent.Components.Health)
local AttackEffect = require(script.Parent.Parent.Components.AttackEffect)
local LastDamagedBy = require(script.Parent.Parent.Components.LastDamagedBy)

return function(world, dt)
	for turretId, turretPos, turret in world:query(Position, Turret) do
		local nextShot = math.max(0, turret.timeUntilNextShot - dt)

		if nextShot > 0 then
			world:insert(turretId, turret:patch({
				timeUntilNextShot = nextShot,
			}))
			continue
		end

		local closestEnemyId = nil
		local closestEnemyHealth = nil
		local closestEnemyPosition = nil
		local closestDistance = turret.range

		for enemyId, enemyPos, _, health in world:query(Position, Enemy, Health) do
			local distance = (enemyPos.value - turretPos.value).Magnitude

			if distance <= closestDistance then
				closestDistance = distance
				closestEnemyId = enemyId
				closestEnemyHealth = health
				closestEnemyPosition = enemyPos
			end
		end

		if closestEnemyId and closestEnemyHealth and closestEnemyPosition then
			world:insert(
				closestEnemyId,
				closestEnemyHealth:patch({
					current = closestEnemyHealth.current - turret.damage,
				})
			)

			world:spawn(AttackEffect({
				from = turretPos.value,
				to = closestEnemyPosition.value,
				lifetime = 0.08,
			}))

			world:insert(turretId, turret:patch({
				timeUntilNextShot = turret.cooldown,
			}))

			world:insert(
				closestEnemyId,
				LastDamagedBy({
					player = game.Players:GetPlayers()[1]
				})
			)
		else
			world:insert(turretId, turret:patch({
				timeUntilNextShot = nextShot,
			}))
		end
	end
end