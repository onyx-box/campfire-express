local AttackEffect = require(script.Parent.Parent.Components.AttackEffect)

local function createLaser(from, to)
	local distance = (to - from).Magnitude
	local midpoint = (from + to) / 2

	local part = Instance.new("Part")
	part.Name = "AttackLaser"
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(0.2, 0.2, distance)
	part.CFrame = CFrame.lookAt(midpoint, to)
	part.Parent = workspace

	return part
end

return function(world, dt)
	for id, effect in world:query(AttackEffect) do
		local laser = createLaser(effect.from, effect.to)

		task.delay(effect.lifetime, function()
			if laser then
				laser:Destroy()
			end
		end)

		world:despawn(id)
	end
end