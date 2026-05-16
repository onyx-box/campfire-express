local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CampfirePlacementController =
	Knit.CreateController({
		Name = "CampfirePlacementController",
	})

function CampfirePlacementController:KnitStart()

	local player = Players.LocalPlayer

	local mouse = player:GetMouse()

	local CampfireService = Knit.GetService("CampfireService")

	UserInputService.InputBegan:Connect(
		function(input, processed)

			if processed then
				return
			end

			if input.KeyCode ~= Enum.KeyCode.C then
				return
			end

			local hit = mouse.Hit

			if not hit then
				return
			end

			local position = hit.Position

			position = Vector3.new(position.X, 0.5, position.Z)

			CampfireService:BuildCampfire(position)
				:andThen(function(success, reason)

					if success then

						print(
							"[Campfire] Built"
						)

					else

						warn(
							"[Campfire]",
							reason
						)

					end

				end)
				:catch(warn)

		end
	)

end

return CampfirePlacementController