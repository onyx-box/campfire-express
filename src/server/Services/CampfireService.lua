local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CampfireService = Knit.CreateService({
	Name = "CampfireService",
	Client = {},
})

CampfireService.MaxFuel = 100
CampfireService.CurrentFuel = 80
CampfireService.BurnRate = 1
CampfireService.WoodToFuel = 10
CampfireService.HasCampfire = false

function CampfireService:DamageFuel(amount)
	self.CurrentFuel = math.max(0, self.CurrentFuel - amount)

	print("[Campfire] Damaged:", amount, "Fuel:", self.CurrentFuel, "/", self.MaxFuel)

	return self.CurrentFuel
end

function CampfireService:GetFuel()
	return {
		current = self.CurrentFuel,
		max = self.MaxFuel,
	}
end

function CampfireService.Client:GetFuel(player)
	return self.Server:GetFuel()
end

function CampfireService:AddFuel(player)
	local ResourceService = Knit.GetService("ResourceService")

	if not ResourceService:Take(player, "wood", 25) then
		return false, "not_enough_wood"
	end

	self.CurrentFuel = math.min(self.MaxFuel, self.CurrentFuel + self.WoodToFuel)

	print("[Campfire] Fuel:", self.CurrentFuel, "/", self.MaxFuel)

	return true
end

function CampfireService.Client:AddFuel(player)
	return self.Server:AddFuel(player)
end

function CampfireService:CreateCampfire(position)
	local part = Instance.new("Part")
	part.Name = "Campfire"
	part.Size = Vector3.new(5, 1, 5)
	part.Position = position
	part.Anchored = true
	part.CanQuery = true
	part.Color = Color3.fromRGB(80, 45, 25)
	part.Material = Enum.Material.Slate	
	part.Parent = Workspace

	local promptPart = Instance.new("Part")
	promptPart.Name = "CampfirePrompt"
	promptPart.Size = Vector3.new(2, 2, 2)
	promptPart.Position = part.Position + Vector3.new(0, 3, 0)
	promptPart.Anchored = true
	promptPart.Transparency = 1
	promptPart.CanCollide = false
	promptPart.CanTouch = false
	promptPart.CanQuery = true
	promptPart.Parent = Workspace

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Add wood"
	prompt.ObjectText = "Campfire"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.Parent = promptPart

	local fire = Instance.new("Fire")
	fire.Size = 8
	fire.Heat = 10
	fire.Parent = part

	prompt.Triggered:Connect(function(player)
		self:AddFuel(player)
	end)

	self.Fire = fire

	local radius = Instance.new("Part")
	radius.Name = "CampfireRadius"
	radius.Shape = Enum.PartType.Cylinder
	radius.Size = Vector3.new(1, 70, 70)
	radius.Position = part.Position - Vector3.new(0, 0.45, 0)
	radius.Orientation = Vector3.new(0, 0, 90)
	radius.Anchored = true
	radius.CanCollide = false
	radius.CanQuery = false
	radius.CanTouch = false
	radius.CastShadow = false
	radius.Material = Enum.Material.Neon
	radius.Color = Color3.fromRGB(255, 170, 80)
	radius.Transparency = 0.8
	radius.Parent = Workspace

	self.RadiusPart = radius

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 180, 100)
	light.Range = 40
	light.Brightness = 3
	light.Parent = part

	self.Light = light
end

function CampfireService:BuildCampfire(player, position)

	if self.HasCampfire then
		return false, "campfire_exists"
	end

	local ResourceService =
		Knit.GetService("ResourceService")

	if not ResourceService:Take(
		player,
		"wood",
		100
	) then

		return false, "not_enough_wood"

	end

	self:CreateCampfire(position)

	self.HasCampfire = true

	print(
		"[Campfire] Built by",
		player.Name
	)

	return true

end

function CampfireService.Client:BuildCampfire(player, position)

	return self.Server:BuildCampfire(
		player,
		position
	)

end

function CampfireService:KnitStart()

	task.spawn(function()
		while true do
			self.CurrentFuel = math.max(0, self.CurrentFuel - self.BurnRate)

			local percent = self.CurrentFuel / self.MaxFuel

			if self.Fire then
				self.Fire.Size = 2 + (self.CurrentFuel / self.MaxFuel) * 8
				self.Fire.Heat = 2 + (self.CurrentFuel / self.MaxFuel) * 10
			end

			if self.RadiusPart then

				local radiusSize = 20 + percent * 50

				self.RadiusPart.Size = Vector3.new(1, radiusSize, radiusSize)

				self.RadiusPart.Transparency = 0.9 - percent * 0.25

				if self.Light then
					self.Light.Range = 10 + percent * 35
					self.Light.Brightness = 1 + percent * 4
				end
			end

			if self.CurrentFuel <= 0 then
				print("[Campfire] OUT!")
			end

			task.wait(1)
		end
	end)
end

return CampfireService