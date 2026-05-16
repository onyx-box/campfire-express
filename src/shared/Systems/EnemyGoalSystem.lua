local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Position = require(script.Parent.Parent.Components.Position)
local Enemy = require(script.Parent.Parent.Components.Enemy)
local Goal = require(script.Parent.Parent.Components.Goal)
local Model = require(script.Parent.Parent.Components.Model)

return function(world)
	local BaseHealthService = Knit.GetService("BaseHealthService")

	for id, position, _, goal, model in world:query(Position, Enemy, Goal, Model) do
		if position.value.X >= goal.x then
			BaseHealthService:Damage(goal.damage)

			if model.instance then
				model.instance:Destroy()
			end

			world:despawn(id)
		end
	end
end