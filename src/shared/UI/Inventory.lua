local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scope = Fusion.scoped(Fusion)

local Children = Fusion.Children

return function(props)

	local visible = props.visible
	local resources = props.resources
	local tools = props.tools

	return scope:New("ScreenGui")({

		Name = "InventoryUI",

		Enabled = scope:Computed(function(use)
			return use(visible)
		end),

		ResetOnSpawn = false,

		[Children] = {

			scope:New("Frame")({

				AnchorPoint = Vector2.new(0.5, 0.5),

				Position = UDim2.fromScale(0.5, 0.5),

				Size = UDim2.fromOffset(400, 300),

				BackgroundColor3 =
					Color3.fromRGB(20, 20, 20),

				BackgroundTransparency = 0.1,

				[Children] = {

					scope:New("UICorner")({
						CornerRadius = UDim.new(0, 12),
					}),

					scope:New("UIPadding")({
						PaddingTop = UDim.new(0, 12),
						PaddingBottom = UDim.new(0, 12),
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					}),

					scope:New("UIListLayout")({
						Padding = UDim.new(0, 8),
					}),

					scope:New("TextLabel")({

						Size = UDim2.new(1, 0, 0, 30),

						BackgroundTransparency = 1,

						Text = "🎒 Inventory",

						TextSize = 24,

						Font = Enum.Font.GothamBold,

						TextColor3 =
							Color3.fromRGB(255,255,255),

					}),

					scope:New("TextLabel")({

						Size = UDim2.new(1,0,0,24),

						BackgroundTransparency = 1,

						TextXAlignment =
							Enum.TextXAlignment.Left,

						Text = scope:Computed(function(use)

							local r = use(resources)

							return
								"🪵 Wood: "
								.. tostring(r.wood or 0)

						end),

						TextSize = 18,

						Font = Enum.Font.Gotham,

						TextColor3 =
							Color3.fromRGB(230,230,230),

					}),

					scope:New("TextLabel")({

						Size = UDim2.new(1,0,0,24),

						BackgroundTransparency = 1,

						TextXAlignment =
							Enum.TextXAlignment.Left,

						Text = scope:Computed(function(use)

							local r = use(resources)

							return
								"⚙️ Scrap: "
								.. tostring(r.scrap or 0)

						end),

						TextSize = 18,

						Font = Enum.Font.Gotham,

						TextColor3 =
							Color3.fromRGB(230,230,230),

					}),

					scope:New("TextLabel")({

						Size = UDim2.new(1,0,0,30),

						BackgroundTransparency = 1,

						TextXAlignment =
							Enum.TextXAlignment.Left,

						Text = "🧰 Tools",

						TextSize = 20,

						Font = Enum.Font.GothamBold,

						TextColor3 =
							Color3.fromRGB(255,255,255),

					}),

					scope:New("TextLabel")({

						Size = UDim2.new(1,0,0,24),

						BackgroundTransparency = 1,

						TextXAlignment =
							Enum.TextXAlignment.Left,

						Text = scope:Computed(function(use)

							local t = use(tools)

							local result = ""

							for toolId, owned in pairs(t) do
								if owned then
									result ..=
										"• "
										.. toolId
										.. "\n"
								end
							end

							return result

						end),

						TextSize = 18,

						Font = Enum.Font.Gotham,

						TextColor3 =
							Color3.fromRGB(230,230,230),

						AutomaticSize =
							Enum.AutomaticSize.Y,

					}),

					scope:New("TextLabel")({
						Size = UDim2.new(1,0,0,24),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = scope:Computed(function(use)
							local r = use(resources) or {}
							return "🌱 Seeds: " .. tostring(r.seed or 0)
						end),
						TextSize = 18,
						Font = Enum.Font.Gotham,
						TextColor3 = Color3.fromRGB(180,255,180),
					}),
				},
			}),
		},
	})
end