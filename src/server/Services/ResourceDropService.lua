local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ResourceDropService = Knit.CreateService({
	Name = "ResourceDropService",
	Client = {},
})

function ResourceDropService:CreateDrop(resourceType, amount, position)
	local drop = Instance.new("Part")
	drop.Name = resourceType .. "Drop"
	drop.Size = Vector3.new(1.5, 1.5, 1.5)
	drop.Position = position + Vector3.new(
		math.random(-3, 3),
		2,
		math.random(-3, 3)
	)
	drop.Anchored = false
	drop.CanCollide = true
	drop.Parent = Workspace

	if resourceType == "wood" then
		drop.Material = Enum.Material.Wood
		drop.Color = Color3.fromRGB(120, 80, 45)
	elseif resourceType == "seed" then
		drop.Material = Enum.Material.Grass
		drop.Color = Color3.fromRGB(80, 220, 80)
	elseif resourceType == "forest_train_key" then
		drop.Material = Enum.Material.Neon
		drop.Color = Color3.fromRGB(255, 220, 60)
		drop.Size = Vector3.new(2, 2, 2)
	else
		drop.Material = Enum.Material.Metal
		drop.Color = Color3.fromRGB(120, 120, 120)
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = resourceType .. " +" .. tostring(amount)
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.Parent = drop

	prompt.Triggered:Connect(function(player)
		local ResourceService = Knit.GetService("ResourceService")
		ResourceService:Give(player, resourceType, amount)

		drop:Destroy()
	end)

	Debris:AddItem(drop, 60)

	return drop
end

return ResourceDropService