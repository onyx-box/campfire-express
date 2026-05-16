local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlantingController = Knit.CreateController({ Name = "PlantingController", })

function PlantingController:KnitStart()

	local player = Players.LocalPlayer

	local mouse = player:GetMouse()

	local PlantService = Knit.GetService("PlantService")

	UserInputService.InputBegan:Connect(
		function(input, processed)

			if processed or input.KeyCode ~= Enum.KeyCode.N then
				return
			end

			local hit = mouse.Hit

			if not hit then
				return
			end

            -- Raycast w dół żeby znaleźć punkt na ziemi, nawet jeśli kursor jest nad innym obiektem
            local origin = hit.Position + Vector3.new(0, 5, 0)
            local direction = Vector3.new(0, -10, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = { player.Character }
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local result = workspace:Raycast(origin, direction, raycastParams)

            if not result then
                return
            end

			local position = result.Position + Vector3.new(0, 0.5, 0) -- Podnieś punkt trochę nad ziemię    

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