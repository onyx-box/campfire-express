local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ToolController = Knit.CreateController({
	Name = "ToolController",
})

ToolController.LastSwing = 0
ToolController.SwingCooldown = 0.6
ToolController.AxeAnimationId = "rbxassetid://72608617488720"

function ToolController:PlayAxeAnimation(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = self.AxeAnimationId

	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()

	Debris:AddItem(animation, 2)

	return track
end

function ToolController:KnitStart()
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()

	local ResourceNodeService = Knit.GetService("ResourceNodeService")
	local connected = {}

	local function connectTool(tool)
		if connected[tool] then
			return
		end

		if not tool:IsA("Tool") then
			return
		end

		if tool:GetAttribute("ToolId") ~= "axe" then
			return
		end

		connected[tool] = true

		print("[ToolController] Connected axe:", tool.Name)

		tool.Activated:Connect(function()
			local now = tick()

			if now - self.LastSwing < self.SwingCooldown then
				return
			end

			self.LastSwing = now

			local target = mouse.Target
			print("[ToolController] Axe activated, target:", target)

			local track = self:PlayAxeAnimation(player)

			local handle = tool:FindFirstChild("Handle")
			if handle then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://12222225"
				sound.Volume = 0.6
				sound.Parent = handle
				sound:Play()
				Debris:AddItem(sound, 2)
			end

			-- moment trafienia w połowie animacji
			task.delay(0.25, function()
				if not target then
					return
				end

				ResourceNodeService:HitNode(target)
					:andThen(function(ok, reason)
						print("[ToolController] HitNode result:", ok, reason)
					end)
					:catch(warn)
			end)
		end)
	end

	local function scan(container)
		if not container then
			return
		end

		for _, child in ipairs(container:GetChildren()) do
			connectTool(child)
		end

		container.ChildAdded:Connect(connectTool)
	end

	local backpack = player:WaitForChild("Backpack")
	scan(backpack)

	if player.Character then
		scan(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		scan(character)
	end)
end

return ToolController