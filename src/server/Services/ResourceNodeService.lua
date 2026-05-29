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
		canHarvest = true,
	},

	scrap = {
		name = "ScrapPile",
		size = Vector3.new(4, 2, 4),
		amountPerHit = 10,
		maxHealth = 40,
		damagePerHit = 20,
		promptText = "Collect scrap",
		requiredTool = "crowbar",
		canHarvest = true,
	},

	sapling = {
		name = "Sapling",
		size = Vector3.new(1, 2, 1),
		amountPerHit = 0,
		maxHealth = 20,
		damagePerHit = 10,
		promptText = "Growing...",
		requiredTool = nil,
		canHarvest = false,
		growsInto = "smallTree",
		growTime = 20,
	},

	smallTree = {
		name = "SmallTree",
		size = Vector3.new(2, 5, 2),
		amountPerHit = 8,
		maxHealth = 30,
		damagePerHit = 10,
		promptText = "Chop small tree",
		requiredTool = "axe",
		canHarvest = true,
		growsInto = "wood",
		growTime = 30,
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

function ResourceNodeService.Client:HitNode(
	player,
	nodePart
)
	return self.Server:HitNode(
		player,
		nodePart
	)
end

function ResourceNodeService:HitNode(player, part)
	local node = self.Nodes[part]

	if not node then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local distance = (root.Position - part.Position).Magnitude

	print( "[Node Distance]", math.floor(distance) )

	if distance > 25 then
		return false, "too_far"
	end

	return self:HarvestNode(player, part)
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

	local prompt = nil

	if nodeType == "scrap" then
		prompt = createPrompt(part, def.promptText)

		prompt.Triggered:Connect(function(player)
			self:HarvestNode(player, part)
		end)
	end

	self.Nodes[part] = {
		type = nodeType,
		health = def.maxHealth,
		maxHealth = def.maxHealth,
		amountPerHit = def.amountPerHit,
		damagePerHit = def.damagePerHit,
		prompt = prompt,
	}

	if def.growsInto and def.growTime then
		task.delay(def.growTime, function()
			if not self.Nodes[part] then
				return
			end

			local oldPosition = part.Position

			self.Nodes[part] = nil
			part:Destroy()

			self:CreateNode(def.growsInto, oldPosition)
		end)
	end

	return part
end

function ResourceNodeService:HarvestNode(player, part)
	local node = self.Nodes[part]
	if not node then
		return
	end

	local def = NODE_DEFS[node.type]
	if def.canHarvest == false then
		return
	end
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
				ResourceService:Give(player, "seed", 2)
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