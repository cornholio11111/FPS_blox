-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

-- ## MODULES ## --
local Packages = game:GetService("ReplicatedStorage").Packages
local Knit = require(Packages.Knit)


Knit.AddServices(ServerStorage.ServerModules)

game:GetService("Players").PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		Knit.Start():andThen(function()
			warn("Server Started")
		end):catch(warn)
	end)
end)