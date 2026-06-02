local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Hud = require(ReplicatedStorage.Shared.UI.Hud)

local scope = Fusion.scoped(Fusion)

local HudController = Knit.CreateController({
	Name = "HudController",
})

function HudController:KnitStart()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local ResourceService = Knit.GetService("ResourceService")
	local BaseHealthService = Knit.GetService("BaseHealthService")

	local CampfireService = Knit.GetService("CampfireService")
	local ColdService = Knit.GetService("ColdService")

	local BiomeService = Knit.GetService("BiomeService")
	local DayNightService = Knit.GetService( "DayNightService" )

	self.wood = scope:Value(0)
	self.scrap = scope:Value(0)
	self.seed = scope:Value(0)
	self.baseHp = scope:Value({
		current = 0,
		max = 0,
	})
	self.buildMode = scope:Value(false)

	self.campfireFuel = scope:Value({
		current = 0,
		max = 0,
	})

	self.temperature = scope:Value({
		current = 100,
		max = 100,
	})

	self.biome = scope:Value({
		id = "unknown",
		name = "Unknown",
	})

	self.night = scope:Value(false)

	local gui = Hud({
		wood = self.wood,
		scrap = self.scrap,
		baseHp = self.baseHp,
		buildMode = self.buildMode,
		campfireFuel = self.campfireFuel,
		temperature = self.temperature,
		seed = self.seed,
		biome = self.biome,
		night = self.night,
	})

	gui.Parent = playerGui

	task.spawn(function()
		while true do

			BiomeService:GetCurrentBiome()
				:andThen(function(biome)
					self.biome:set({
						id = biome.id or "unknown",
						name = biome.name or "Unknown",
					})
				end)
				:catch(warn)

			DayNightService:GetState()
				:andThen(function(state)
					self.night:set(state.isNight == true)
				end)
				:catch(warn)

			ResourceService:GetResources()
				:andThen(function(resources)
					resources = resources or {}

					self.wood:set(resources.wood or 0)
					self.scrap:set(resources.scrap or 0)
					self.seed:set(resources.seed or 0)
				end)
				:catch(warn)

			BaseHealthService:GetHealth()
				:andThen(function(hp)
					hp = hp or {}

					self.baseHp:set({
						current = hp.current or 0,
						max = hp.max or 0,
					})
				end)
				:catch(warn)
			
			CampfireService:GetFuel()
				:andThen(function(fuel)
					fuel = fuel or {}

					self.campfireFuel:set({
						current = fuel.current or 0,
						max = fuel.max or 0,
					})
				end)
				:catch(warn)
			
			ColdService:GetTemperature()
				:andThen(function(temp)
					temp = temp or {}

					self.temperature:set({
						current = temp.current or 0,
						max = temp.max or 100,
					})
				end)
				:catch(warn)
				
			task.wait(0.25)
		end
	end)
end

function HudController:SetBuildMode(value)
	self.buildMode:set(value)
end

return HudController