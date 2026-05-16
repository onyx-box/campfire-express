local Matter = require(game.ReplicatedStorage.Packages.Matter)

return Matter.component("AttackCampfire", {
	range = 8,
	damage = 5,
	cooldown = 1.5,
	timeUntilNextAttack = 0,
})