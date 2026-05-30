return {
	{
		id = "forest",
		name = "Forest",

		worldRadius = 250,

		resources = {
			wood = {
				nodeType = "wood",
				count = 80,
			},

			scrap = {
				nodeType = "scrap",
				count = 30,
			},
		},

		enemyPool = {
			"basic",
			"fast",
		},

		boss = "boss_forest",
		bossKey = "forest_train_key",
		nextBiomeKey = "forest_train_key",

		ambientColor = Color3.fromRGB(120, 180, 120),
	},

	{
		id = "desert",
		name = "Desert",

		worldRadius = 280,

		resources = {
			cactus = {
				nodeType = "cactus",
				count = 35,
			},

			scrap = {
				nodeType = "scrap",
				count = 55,
			},
		},

		enemyPool = {
			"fast",
			"tank",
		},

		boss = "boss_desert",
		bossKey = "desert_train_key",
		nextBiomeKey = "desert_train_key",

		ambientColor = Color3.fromRGB(235, 205, 120),
	},
}