local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scope = Fusion.scoped(Fusion)

local Children = Fusion.Children

return function(props)
	local wood = props.wood
	local scrap = props.scrap
	local baseHp = props.baseHp
	local buildMode = props.buildMode
	local campfireFuel = props.campfireFuel
	local temperature = props.temperature
	local biome = props.biome

	return scope:New("ScreenGui")({
		Name = "CampfireHud",
		ResetOnSpawn = false,

		[Children] = {
			scope:New("Frame")({
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromOffset(20, 20),
				Size = UDim2.fromOffset(320, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 0.2,
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),

				[Children] = {
					scope:New("UICorner")({
						CornerRadius = UDim.new(0, 12),
					}),

					scope:New("UIListLayout")({
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					scope:New("UIPadding")({
						PaddingTop = UDim.new(0, 12),
						PaddingBottom = UDim.new(0, 12),
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 24),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 18,
						Font = Enum.Font.GothamBold,
						Text = "🔥 Campfire Express",
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(180, 220, 255),
						TextSize = 16,
						Font = Enum.Font.GothamBold,
						Text = scope:Computed(function(use)
							local currentBiome = use(biome) or {}
							return "🌍 Biome: " .. tostring(currentBiome.name or "Unknown")
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(230, 230, 230),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							return "🪵 Wood: " .. tostring(use(wood))
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(230, 230, 230),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							return "⚙️ Scrap: " .. tostring(use(scrap))
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(230, 230, 230),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							local hp = use(baseHp) or {}
							return "❤️ Base HP: " .. tostring(hp.current or 0) .. "/" .. tostring(hp.max or 0)
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 16,
						Font = Enum.Font.GothamBold,
						TextColor3 = scope:Computed(function(use)
							if use(buildMode) then
								return Color3.fromRGB(80, 255, 120)
							end

							return Color3.fromRGB(255, 180, 80)
						end),
						Text = scope:Computed(function(use)
							if use(buildMode) then
								return "🛠 Build Mode: ON"
							end

							return "🛠 Build Mode: OFF — press B"
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(255, 210, 120),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							local fuel = use(campfireFuel) or {}
							return "🔥 Fire: " .. tostring(fuel.current or 0) .. "/" .. tostring(fuel.max or 0)
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(160, 220, 255),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							local temp = use(temperature) or {}
							return "❄️ Temp: " .. tostring(temp.current or 0) .. "/" .. tostring(temp.max or 100)
						end),
					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(180, 255, 180),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						Text = scope:Computed(function(use)
							return "🌱 Seeds: " .. tostring(use(props.seed) or 0)
						end),
					}),
				},
			}),
		},
	})
end