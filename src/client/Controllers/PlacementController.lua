local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlacementUtil = require(ReplicatedStorage.Shared.Util.PlacementUtil)

local PlacementController = Knit.CreateController({
	Name = "PlacementController",
})

function PlacementController:CreateGhost()
	local part = Instance.new("Part")
	part.Name = "TurretGhost"
	part.Size = Vector3.new(3, 5, 3)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Material = Enum.Material.ForceField
	part.Parent = workspace

	return part
end

function PlacementController:KnitStart()
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()

	local EnemyService = Knit.GetService("EnemyService")
	local HudController = Knit.GetController("HudController")

	local isBuildMode = false
	local ghost = self:CreateGhost()
	ghost.Parent = nil

	local currentSnappedPosition = nil
	local currentIsValid = false

	RunService.RenderStepped:Connect(function()
		if not isBuildMode then
			return
		end

		local hit = mouse.Hit
		if not hit then
			return
		end

		local rawPosition = hit.Position
		local isValid, snapped = PlacementUtil.IsValidTurretPosition(rawPosition)

		currentSnappedPosition = snapped
		currentIsValid = isValid

		ghost.Position = snapped
		ghost.Parent = workspace

		if isValid then
			ghost.Color = Color3.fromRGB(80, 255, 120)
		else
			ghost.Color = Color3.fromRGB(255, 80, 80)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.B then
			isBuildMode = not isBuildMode

			HudController:SetBuildMode(isBuildMode)

			if isBuildMode then
				ghost.Parent = workspace
				print("[Placement] Build mode ON")
			else
				ghost.Parent = nil
				currentSnappedPosition = nil
				currentIsValid = false
				print("[Placement] Build mode OFF")
			end

			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not isBuildMode then
				return
			end

			if not currentIsValid or not currentSnappedPosition then
				warn("Cannot place turret here")
				return
			end

			local ok, reason = EnemyService:PlaceTurret(currentSnappedPosition)

			if not ok then
				warn("Cannot place turret:", reason)
			end
		end
	end)
end

return PlacementController