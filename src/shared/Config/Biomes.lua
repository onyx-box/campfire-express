return {
	{
		id = "forest",
		name = "Forest",

		treeCount = 80,
		scrapCount = 30,
        worldRadius = 250,

		enemyPool = {
			"basic",
			"fast",
		},

		boss = "boss_forest",

		ambientColor = Color3.fromRGB(
			120,
			180,
			120
		),
	},

	{
		id = "desert",
		name = "Desert",

		treeCount = 10,
		scrapCount = 50,
        worldRadius = 250,
        
		enemyPool = {
			"fast",
			"tank",
		},

		boss = "boss_desert",

		ambientColor = Color3.fromRGB(
			240,
			210,
			120
		),
	},
}