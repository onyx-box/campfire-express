local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ResourceNodeService = Knit.CreateService({
	Name = "ResourceNodeService",
	Client = {},
})

ResourceNodeService.Nodes = {}

local NODE_DEFS = {
	wood = {
		name = "Tree",
		size = Vector3.new(3, 10, 3),
		amountPerHit = 15,
		maxHealth = 60,
		damagePerHit = 20,
		promptText = "Chop wood",
		requiredTool = "axe",
	},

	scrap = {
		name = "ScrapPile",
		size = Vector3.new(4, 2, 4),
		amountPerHit = 10,
		maxHealth = 40,
		damagePerHit = 20,
		promptText = "Collect scrap",
		requiredTool = "crowbar",
	},
}

local function createPrompt(part, text)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = text
	prompt.ObjectText = part.Name
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.Parent = part

	return prompt
end

function ResourceNodeService:CreateNode(nodeType, position)
	local def = NODE_DEFS[nodeType]
	if not def then
		warn("Unknown node type:", nodeType)
		return
	end

	local part = Instance.new("Part")
	part.Name = def.name
	part.Size = def.size
	part.Position = position
	part.Anchored = true
	part.Parent = Workspace

	local prompt = createPrompt(part, def.promptText)

	self.Nodes[part] = {
		type = nodeType,
		health = def.maxHealth,
		maxHealth = def.maxHealth,
		amountPerHit = def.amountPerHit,
		damagePerHit = def.damagePerHit,
		prompt = prompt,
	}

	prompt.Triggered:Connect(function(player)
		self:HarvestNode(player, part)
	end)

	return part
end

function ResourceNodeService:HarvestNode(player, part)
	local node = self.Nodes[part]
	if not node then
		return
	end

	local def = NODE_DEFS[node.type]
	local ToolService = Knit.GetService("ToolService")

	if def.requiredTool and not ToolService:HasEquippedTool(player, def.requiredTool) then
		warn("[Node] Missing equipped tool:", def.requiredTool)
		return
	end

	local ResourceService = Knit.GetService("ResourceService")

	ResourceService:Give(player, node.type, node.amountPerHit)

	node.health -= node.damagePerHit

	local percent = math.max(0, node.health / node.maxHealth)
	part.Transparency = 1 - percent * 0.9

	print("[Node]", part.Name, node.health, "/", node.maxHealth)

	if node.health <= 0 then
		if node.type == "wood" then
			local dropChance = 0.5

			if math.random() <= dropChance then
				ResourceService:Give(player, "seed", 1)
				print("[Node] Seed dropped for:", player.Name)
			end
		end

		self.Nodes[part] = nil
		part:Destroy()
	end
end

function ResourceNodeService:KnitStart()
	self:CreateNode("wood", Vector3.new(-20, 5, -20))
	self:CreateNode("wood", Vector3.new(-28, 5, -10))
	self:CreateNode("wood", Vector3.new(-36, 5, 0))
	self:CreateNode("scrap", Vector3.new(-15, 1, 20))
	self:CreateNode("scrap", Vector3.new(-25, 1, 28))
end

return ResourceNodeService