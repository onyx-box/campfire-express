local Position = require(script.Parent.Parent.Components.Position)
local Enemy = require(script.Parent.Parent.Components.Enemy)
local AttackCampfire = require(script.Parent.Parent.Components.AttackCampfire)
local Stopped = require(script.Parent.Parent.Components.Stopped)

local Knit = require(game.ReplicatedStorage.Packages.Knit)

return function(world, dt)
	local CampfireService = Knit.GetService("CampfireService")
	local campfirePart = workspace:FindFirstChild("Campfire")

	if not campfirePart then
		return
	end

	for id, position, _, attack in world:query(Position, Enemy, AttackCampfire) do
		local distance = (position.value - campfirePart.Position).Magnitude

		local nextAttack = math.max(0, attack.timeUntilNextAttack - dt)

		if distance <= attack.range then
			if not world:contains(id, Stopped) then
				world:insert(id, Stopped())
			end

			if nextAttack <= 0 then
				CampfireService:DamageFuel(attack.damage)

				world:insert(id, attack:patch({
					timeUntilNextAttack = attack.cooldown,
				}))
			else
				world:insert(id, attack:patch({
					timeUntilNextAttack = nextAttack,
				}))
			end
		else
			if world:contains(id, Stopped) then
				world:remove(id, Stopped)
			end

			world:insert(id, attack:patch({
				timeUntilNextAttack = nextAttack,
			}))
		end
	end
end