local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Inventory = require(ReplicatedStorage.Shared.UI.Inventory)

local scope = Fusion.scoped(Fusion)

local InventoryController =
	Knit.CreateController({
		Name = "InventoryController",
	})

function InventoryController:KnitStart()

	local player = Players.LocalPlayer

	local playerGui = player:WaitForChild("PlayerGui")

	local ResourceService = Knit.GetService("ResourceService")

	local ToolService = Knit.GetService("ToolService")

	local isInventoryVisible = false
    self.visible = scope:Value(isInventoryVisible)

	self.resources = scope:Value({})
	self.tools = scope:Value({})

	local gui = Inventory({

		visible = self.visible,

		resources = self.resources,

		tools = self.tools,

	})

	gui.Parent = playerGui

	task.spawn(function()

		while true do

			ResourceService:GetResources()
                :andThen(function(resources)
                    self.resources:set(resources or {})
                end)
                :catch(warn)

			ToolService:GetTools()
                :andThen(function(tools)
                    self.tools:set(tools or {})
                end)
                :catch(warn)

			task.wait(0.5)

		end

	end)

	UserInputService.InputBegan:Connect(
		function(input, processed)

			if processed then
				return
			end

			if input.KeyCode == Enum.KeyCode.Tab then

                isInventoryVisible = not isInventoryVisible
                self.visible:set(isInventoryVisible)

			end

		end
	)

end

return InventoryController