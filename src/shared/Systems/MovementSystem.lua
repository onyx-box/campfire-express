local Position = require(script.Parent.Parent.Components.Position)
local Velocity = require(script.Parent.Parent.Components.Velocity)

return function(world, dt)
	for id, position, velocity in world:query(Position, Velocity) do
		world:insert(
			id,
			position:patch({
				value = position.value + velocity.value * dt
			})
		)
	end
end