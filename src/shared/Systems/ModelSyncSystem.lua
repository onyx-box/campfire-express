local Position = require(script.Parent.Parent.Components.Position)
local Model = require(script.Parent.Parent.Components.Model)

return function(world)
	for id, position, model in world:query(Position, Model) do
		if model.instance and model.instance.Parent then
			model.instance.Position = position.value
		end
	end
end