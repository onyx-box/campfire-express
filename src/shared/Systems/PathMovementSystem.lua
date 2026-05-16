local Position = require(script.Parent.Parent.Components.Position)
local Velocity = require(script.Parent.Parent.Components.Velocity)
local Path = require(script.Parent.Parent.Components.Path)
local Stopped = require(script.Parent.Parent.Components.Stopped)

return function(world, dt)

	for id, position, velocity, path in world:query(Position, Velocity, Path) do

		if world:contains(id, Stopped) then
			continue
		end

		local target = path.points[path.current]

		if not target then
			continue
		end

		local direction = target - position.value
		local distance = direction.Magnitude

		if distance < 1 then

			world:insert(
				id,
				path:patch({
					current = path.current + 1
				})
			)

			continue
		end

		local moveDir = direction.Unit

		world:insert(
			id,
			position:patch({
				value = position.value + moveDir * velocity.value.X * dt
			})
		)

	end
end