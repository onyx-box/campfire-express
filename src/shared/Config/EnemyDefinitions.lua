return {
	basic = {
		name = "Basic Enemy",
		health = 100,
		speed = 5,
		size = Vector3.new(3, 3, 3),
		color = Color3.fromRGB(180, 80, 80),
		reward = {
			wood = 20,
			scrap = 5,
		},
	},

	fast = {
		name = "Fast Enemy",
		health = 60,
		speed = 10,
		size = Vector3.new(2, 2, 2),
		color = Color3.fromRGB(255, 180, 60),
		reward = {
			wood = 60,
			scrap = 5,
		},
	},

	tank = {
		name = "Tank Enemy",
		health = 300,
		speed = 2,
		size = Vector3.new(4, 4, 4),
		color = Color3.fromRGB(120, 80, 180),
		reward = {
			wood = 50,
			scrap = 20,
		},
	},
	boss_forest = {
		name = "Forest Boss",
		health = 800,
		speed = 2,
		size = Vector3.new(7, 8, 7),
		color = Color3.fromRGB(255, 50, 50),
		reward = {
			wood = 100,
			scrap = 50,
		},
	},
}