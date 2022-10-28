-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

-- ## MODULES ## --
local Knit = require(ReplicatedStorage.Packages.Knit)
local FastCast = require(ReplicatedStorage.Packages.Knit)

-- ## MODULE ## --
local ViewModelService = Knit.CreateService {
	Name = "ViewModelService", 
	Client = {
		Raycast = Knit.CreateSignal(),
		SetNewWeapon = Knit.CreateSignal(),
	}
}

function ViewModelService:KnitStart()
	self.Client.Raycast:Connect(function(Player, Origin, LookVector)
		
	end)

	self.Client.SetNewWeapon:Connect(function(Player, WeaponName)
		print(WeaponName)
	end)

	warn('[DEBUG] Loaded Service: ViewModelService')
end

return ViewModelService