local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlantingController = Knit.CreateController({ Name = "PlantingController", })

function PlantingController:KnitStart()

	local player = Players.LocalPlayer

	local mouse = player:GetMouse()

	local PlantService =
		Knit.GetService("PlantService")

	UserInputService.InputBegan:Connect(
		function(input, processed)

			if processed then
				return
			end

			if input.KeyCode ~= Enum.KeyCode.N then
				return
			end

			local hit = mouse.Hit

			if not hit then
				return
			end

			local position =
				hit.Position

			position =
				Vector3.new(
					position.X,
					5,
					position.Z
				)

			PlantService:PlantTree(position)
				:andThen(function(success)

					if success then
						print("[Plant] Tree planted")
					end

				end)
				:catch(warn)

		end
	)

end

return PlantingController