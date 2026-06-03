local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lighting = game:GetService("Lighting")

local Knit = require( ReplicatedStorage.Packages.Knit )

local DayNightService = Knit.CreateService({ Name = "DayNightService", Client = {}, })

DayNightService.DayDuration = 30
DayNightService.NightDuration = 20

DayNightService.IsNight = false

DayNightService.NightStarted = Instance.new("BindableEvent")
DayNightService.DayStarted = Instance.new("BindableEvent")

DayNightService.DayNumber = 1

function DayNightService:GetState()
	return {
		isNight = self.IsNight,
        dayNumber = self.DayNumber,
	}
end

function DayNightService.Client:GetState(player)
	return self.Server:GetState()
end

function DayNightService:SetDay()

	self.IsNight = false

	Lighting.ClockTime = 14

    self.DayStarted:Fire()
    
	print("[DayNight] Day", self.DayNumber)

end

function DayNightService:SetNight()

	self.IsNight = true

	Lighting.ClockTime = 0

    self.NightStarted:Fire()

	print("[DayNight] Night", self.DayNumber)

end

function DayNightService:KnitStart()

	task.spawn(function()

		while true do

			self:SetDay()

			task.wait( self.DayDuration )

			self:SetNight()

			task.wait( self.NightDuration )

            self.DayNumber += 1
		end

	end)

end

return DayNightService