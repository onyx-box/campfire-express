local Matter = require(game.ReplicatedStorage.Packages.Matter)

return Matter.component("Turret", {
	range = 25,
	damage = 25,
	cooldown = 1,
	timeUntilNextShot = 0,
})