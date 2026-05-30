local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

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

local function createHealthBar(part)
	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBar"
	gui.Size = UDim2.fromOffset(80, 12)
	gui.StudsOffset = Vector3.new(0, part.Size.Y / 2 + 1, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = false
	gui.Parent = part

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	background.BorderSizePixel = 0
	background.Parent = gui

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
	fill.BorderSizePixel = 0
	fill.Parent = background

	return gui, fill
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
	if nodeType == "wood" then
		part.Color = Color3.fromRGB(90, 140, 70)
		part.Material = Enum.Material.Wood
	elseif nodeType == "smallTree" then
		part.Color = Color3.fromRGB(110, 180, 90)
		part.Material = Enum.Material.Wood
	elseif nodeType == "sapling" then
		part.Color = Color3.fromRGB(80, 220, 90)
		part.Material = Enum.Material.Grass
	elseif nodeType == "scrap" then
		part.Color = Color3.fromRGB(110, 110, 110)
		part.Material = Enum.Material.Metal
	end
	part.Parent = Workspace

	local healthGui, healthFill = nil, nil

	if def.canHarvest then
		healthGui, healthFill = createHealthBar(part)
	end

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
		healthGui = healthGui,
		healthFill = healthFill,
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

function ResourceNodeService:FallAndDestroy(part)
	if not part or not part.Parent then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9120259393"
	sound.Volume = 0.8
	sound.Parent = part
	sound:Play()

	part.Anchored = true
	part.CanCollide = false

	local startCFrame = part.CFrame

	local fallDirection = Vector3.new(
		math.random(-100, 100) / 100,
		0,
		math.random(-100, 100) / 100
	)

	if fallDirection.Magnitude < 0.1 then
		fallDirection = Vector3.new(1, 0, 0)
	end

	fallDirection = fallDirection.Unit

	local axis = fallDirection:Cross(Vector3.yAxis).Unit
	local targetCFrame = startCFrame * CFrame.fromAxisAngle(axis, math.rad(85))

	local steps = 20

	for i = 1, steps do
		local alpha = i / steps
		part.CFrame = startCFrame:Lerp(targetCFrame, alpha)
		task.wait(0.02)
	end

	local impact = Instance.new("Sound")
	impact.SoundId = "rbxassetid://6972249696"
	impact.Volume = 1
	impact.Parent = part
	impact:Play()

	task.wait(1.5)

	for i = 1, 20 do
		local alpha = i / 20
		part.Transparency = alpha
		task.wait(0.03)
	end

	if part and part.Parent then
		part:Destroy()
	end
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

	node.health -= node.damagePerHit

	local percent = math.max(0, node.health / node.maxHealth)
	
	if node.healthGui then
		node.healthGui.Enabled = true
	end

	if node.healthFill then
		node.healthFill.Size = UDim2.fromScale(percent, 1)

		if percent <= 0.3 then
			node.healthFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		elseif percent <= 0.6 then
			node.healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
		else
			node.healthFill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
		end
	end

	print("[Node]", part.Name, node.health, "/", node.maxHealth)

	if node.health <= 0 then
		local ResourceDropService = Knit.GetService("ResourceDropService")

		if node.type == "wood" or node.type == "smallTree" then
			ResourceDropService:CreateDrop("wood", 50, part.Position)

			local dropChance = 0.5

			if math.random() <= dropChance then
				ResourceDropService:CreateDrop("seed", 2, part.Position)
				print("[Node] Seed dropped for:", player.Name)
			end

			self.Nodes[part] = nil

			task.spawn(function()
				self:FallAndDestroy(part)
			end)

		elseif node.type == "scrap" then
			ResourceDropService:CreateDrop("scrap", 25, part.Position)

			self.Nodes[part] = nil
			part:Destroy()
		end

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