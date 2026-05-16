local Matter = require(game.ReplicatedStorage.Packages.Matter)

return Matter.component("AttackEffect", {
	from = Vector3.zero,
	to = Vector3.zero,
	lifetime = 0.1,
})