local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lighting = game:GetService("Lighting")

local Knit = require( ReplicatedStorage.Packages.Knit )

local DayNightService = Knit.CreateService({ Name = "DayNightService", Client = {}, })

DayNightService.DayDuration = 30
DayNightService.NightDuration = 20

DayNightService.IsNight = false

function DayNightService:GetState()
	return {
		isNight = self.IsNight,
	}
end

function DayNightService.Client:GetState(player)
	return self.Server:GetState()
end

function DayNightService:SetDay()

	self.IsNight = false

	Lighting.ClockTime = 14

	print("[DayNight] Day")

end

function DayNightService:SetNight()

	self.IsNight = true

	Lighting.ClockTime = 0

	print("[DayNight] Night")

end

function DayNightService:KnitStart()

	task.spawn(function()

		while true do

			self:SetDay()

			task.wait( self.DayDuration )

			self:SetNight()

			task.wait( self.NightDuration )

		end

	end)

end

return DayNightService