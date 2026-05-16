local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local BaseHealthService = Knit.CreateService({
	Name = "BaseHealthService",
	Client = {},
})

BaseHealthService.MaxHealth = 100
BaseHealthService.CurrentHealth = 100

function BaseHealthService:GetHealth()
	return {
		current = self.CurrentHealth,
		max = self.MaxHealth,
	}
end

function BaseHealthService.Client:GetHealth(player)
	return self.Server:GetHealth()
end

function BaseHealthService:Damage(amount)
	self.CurrentHealth -= amount

	print("[Base] HP:", self.CurrentHealth, "/", self.MaxHealth)

	if self.CurrentHealth <= 0 then
		print("[Base] GAME OVER")
	end
end

return BaseHealthService