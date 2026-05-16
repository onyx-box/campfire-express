local Health = require(script.Parent.Parent.Components.Health)
local Model = require(script.Parent.Parent.Components.Model)
local Reward = require(script.Parent.Parent.Components.Reward)
local LastDamagedBy = require(script.Parent.Parent.Components.LastDamagedBy)
local Knit = require(game.ReplicatedStorage.Packages.Knit)

return function(world)
	for id, health, model, reward, damagedBy in world:query(Health, Model, Reward, LastDamagedBy) do
		if health.current <= 0 then
			if model.instance then
				
				if damagedBy.player then

					local ResourceService =
						Knit.GetService("ResourceService")

					ResourceService:Give(
						damagedBy.player,
						"wood",
						reward.wood
					)

					ResourceService:Give(
						damagedBy.player,
						"scrap",
						reward.scrap
					)

					print(
						"[Reward]",
						damagedBy.player.Name,
						reward.wood,
						reward.scrap
					)

				end

				model.instance:Destroy()
			end

			world:despawn(id)
		end
	end
end