local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlantService =
	Knit.CreateService({
		Name = "PlantService",
		Client = {},
	})

function PlantService:PlantTree(player, position)

	local ResourceService = Knit.GetService("ResourceService")

	local ResourceNodeService = Knit.GetService("ResourceNodeService")

	if not ResourceService:Take(player, "seed", 1) then

		return false, "no_seed"

	end

	ResourceNodeService:CreateNode(
        "sapling",
        position
    )

	print(
		"[Plant]",
		player.Name,
		position
	)

	return true

end

function PlantService.Client:PlantTree(
	player,
	position
)
	return self.Server:PlantTree(
		player,
		position
	)
end

return PlantService