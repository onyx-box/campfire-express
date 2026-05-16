local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

Knit.AddControllers(script.Parent.Controllers)

Knit.Start()
    :andThen(function()
        print("[Client] Knit started")
    end)
    :catch(warn)