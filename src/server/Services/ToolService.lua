local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {},
})

local STARTER_TOOLS = {
	{
		id = "axe",
		name = "Axe",
	},
	{
		id = "crowbar",
		name = "Crowbar",
	},
}

function ToolService:GetTools(player)
	return {
		axe = true,
		crowbar = true,
	}
end

function ToolService.Client:GetTools(player)
	self.Server:GiveStarterTools(player)
	return self.Server:GetTools(player)
end

function ToolService:CreateTool(toolDef)

	local tool = Instance.new("Tool")
	tool.Name = toolDef.name
	tool.RequiresHandle = true

	tool:SetAttribute("ToolId", toolDef.id)

	local handle = Instance.new("Part")
	handle.Name = "Handle"

	handle.Size =
		toolDef.id == "axe"
		and Vector3.new(1, 4, 1)
		or Vector3.new(1, 3, 1)

	handle.Color =
		toolDef.id == "axe"
		and Color3.fromRGB(120, 80, 40)
		or Color3.fromRGB(70, 70, 70)

	handle.Material = Enum.Material.Wood

	handle.Parent = tool
    handle.CanCollide = false
    handle.Massless = true

	if toolDef.id == "axe" then

		local blade = Instance.new("Part")
		blade.Name = "Blade"
		blade.Size = Vector3.new(2, 1.5, 0.5)
		blade.Color = Color3.fromRGB(200, 200, 200)
		blade.Material = Enum.Material.Metal
		blade.CanCollide = false

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = blade
		weld.Parent = blade

		blade.Position =
			handle.Position + Vector3.new(1, 1, 0)

		blade.Parent = tool

	elseif toolDef.id == "crowbar" then

		handle.Material = Enum.Material.Metal

	end

	return tool
end

function ToolService:GiveStarterTools(player)
	local backpack = player:WaitForChild("Backpack")

	for _, toolDef in ipairs(STARTER_TOOLS) do
		if not self:PlayerHasTool(player, toolDef.name) then
			local tool = self:CreateTool(toolDef)
			tool.Parent = backpack
		end
	end
end

function ToolService:GetEquippedToolId(player)
	local character = player.Character
	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child:GetAttribute("ToolId")
		end
	end

	return nil
end

function ToolService:HasEquippedTool(player, toolId)
	return self:GetEquippedToolId(player) == toolId
end

function ToolService:PlayerHasTool(player, toolName)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	if backpack and backpack:FindFirstChild(toolName) then
		return true
	end

	if character and character:FindFirstChild(toolName) then
		return true
	end

	return false
end

function ToolService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		self:GiveStarterTools(player)

		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			self:GiveStarterTools(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			self:GiveStarterTools(player)
		end)
	end)
end

return ToolService