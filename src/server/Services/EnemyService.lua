local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Matter = require(ReplicatedStorage.Packages.Matter)

local Position = require(ReplicatedStorage.Shared.Components.Position)
local Velocity = require(ReplicatedStorage.Shared.Components.Velocity)
local Enemy = require(ReplicatedStorage.Shared.Components.Enemy)
local Model = require(ReplicatedStorage.Shared.Components.Model)
local Health = require(ReplicatedStorage.Shared.Components.Health)
local EnemyType = require(ReplicatedStorage.Shared.Components.EnemyType)

local EnemyDefinitions = require(ReplicatedStorage.Shared.Config.EnemyDefinitions)

local ModelSyncSystem = require(ReplicatedStorage.Shared.Systems.ModelSyncSystem)
local DeathSystem = require(ReplicatedStorage.Shared.Systems.DeathSystem)

local Turret = require(ReplicatedStorage.Shared.Components.Turret)
local TurretAttackSystem = require(ReplicatedStorage.Shared.Systems.TurretAttackSystem)

local AttackEffectSystem = require(ReplicatedStorage.Shared.Systems.AttackEffectSystem)

local Goal = require(ReplicatedStorage.Shared.Components.Goal)
local EnemyGoalSystem = require(ReplicatedStorage.Shared.Systems.EnemyGoalSystem)

local Path = require(ReplicatedStorage.Shared.Components.Path)
local Paths = require(ReplicatedStorage.Shared.Config.Paths)

local PathMovementSystem = require(ReplicatedStorage.Shared.Systems.PathMovementSystem)

local PlacementUtil = require(ReplicatedStorage.Shared.Util.PlacementUtil)

local TurretDefinitions = require(ReplicatedStorage.Shared.Config.TurretDefinitions)

local AttackCampfire = require(ReplicatedStorage.Shared.Components.AttackCampfire)
local EnemyCampfireAttackSystem = require(ReplicatedStorage.Shared.Systems.EnemyCampfireAttackSystem)

local Reward = require(ReplicatedStorage.Shared.Components.Reward)

local Boss = require(ReplicatedStorage.Shared.Components.Boss)

local EnemyService = Knit.CreateService({
	Name = "EnemyService",
	Client = {},
})

function EnemyService.Client:PlaceTurret(player, position)

	if typeof(position) ~= "Vector3" then
		return false, "invalid_position"
	end

	local isValid, snapped, reason =
		PlacementUtil.IsValidTurretPosition(position)

	if not isValid then
		return false, reason
	end

	local ResourceService = Knit.GetService("ResourceService")

	local turretDef = TurretDefinitions.basic

	for resource, amount in pairs(turretDef.cost) do

		if not ResourceService:Has(player, resource, amount) then
			return false, "not_enough_resources"
		end

	end

	for resource, amount in pairs(turretDef.cost) do
		ResourceService:Take(player, resource, amount)
	end

	self.Server:PlaceTurret(snapped)

	return true, nil
end

function EnemyService:SpawnEnemy(enemyTypeId, position)
	local def = EnemyDefinitions[enemyTypeId]
	if not def then
		warn("Unknown enemy type:", enemyTypeId)
		return
	end

	local part = Instance.new("Part")
	part.Name = "Enemy_" .. enemyTypeId
	part.Size = def.size
	part.Position = Paths.MainPath[1]
	part.Anchored = true
	part.Color = def.color or Color3.fromRGB(180, 80, 80)
	part.Material = enemyTypeId == "boss_forest" and Enum.Material.Neon or Enum.Material.SmoothPlastic
	part.Parent = Workspace

	local components = {
		Enemy(),
		EnemyType({ id = enemyTypeId }),
		Model({ instance = part }),
		Position({ value = part.Position }),
		Velocity({ value = Vector3.new(def.speed, 0, 0) }),
		Health({ current = def.health, max = def.health }),
		Reward({
			wood = def.reward and def.reward.wood or 0,
			scrap = def.reward and def.reward.scrap or 0,
		}),
		Path({
			points = Paths.MainPath,
			current = 1,
		}),
		Goal({
			x = 80,
			damage = 10,
		}),
		AttackCampfire({
			range = 8,
			damage = 5,
			cooldown = 1.5,
			timeUntilNextAttack = 0,
		}),
	}

	if enemyTypeId == "boss_forest" then
		table.insert(components, Boss({
			id = "forest_boss",
			dropsKey = "forest_train_key",
		}))
	end

	local enemyId = self.world:spawn(table.unpack(components))

	print("Enemy spawned:", enemyId, enemyTypeId)

	return enemyId
end

function EnemyService:SpawnTurret(position)
	local part = Instance.new("Part")
	part.Name = "Turret"
	part.Size = Vector3.new(3, 5, 3)
	part.Position = position
	part.Anchored = true
	part.Color = Color3.fromRGB(80, 160, 255)
	part.Material = Enum.Material.Metal
	part.Parent = Workspace

	local turretId = self.world:spawn(
		Model({
			instance = part,
		}),
		Position({
			value = part.Position,
		}),
		Turret({
			range = 35,
			damage = 25,
			cooldown = 0.7,
			timeUntilNextShot = 0,
		})
	)

	print("Turret spawned:", turretId)

	return turretId
end

function EnemyService:PlaceTurret(position)
	return self:SpawnTurret(position)
end

function EnemyService:KnitStart()
	self.world = Matter.World.new()

	--self:SpawnTurret(Vector3.new(20, 3, 0))

	task.delay(5, function()
		for id, health in self.world:query(Health) do
			self.world:insert(
				id,
				health:patch({
					current = 0,
				})
			)
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		PathMovementSystem(self.world, dt)
		-- EnemyGoalSystem(self.world)
		EnemyCampfireAttackSystem(self.world, dt)
		TurretAttackSystem(self.world, dt)
		AttackEffectSystem(self.world, dt)
		ModelSyncSystem(self.world)
		DeathSystem(self.world)
	end)

	local goalPart = Instance.new("Part")
	goalPart.Name = "BaseGoal"
	goalPart.Size = Vector3.new(4, 10, 40)
	goalPart.Position = Vector3.new(80, 5, 0)
	goalPart.Anchored = true
	goalPart.CanCollide = false
	goalPart.Transparency = 0.5
	goalPart.Parent = Workspace
end

return EnemyService