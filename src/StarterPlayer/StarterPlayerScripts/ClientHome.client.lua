local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

Knit.AddControllers(game:GetService("ReplicatedStorage").Controllers)
Knit.Start():andThen(function()
	warn("Client Started")
end):catch(warn)-- From a LocalScript
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
Knit.Start():catch(warn):await()

local PointsService = Knit.GetService("PointsService")

local function PointsChanged(points)
    print("My points:", points)
end

-- Get points and listen for changes:
PointsService:GetPoints():andThen(PointsChanged)
PointsService.PointsChanged:Connect(PointsChanged)

-- Ask server to give points randomly:
PointsService.GiveMePoints:Fire()