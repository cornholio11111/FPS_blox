-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Promise = require(Packages.Promise)
local ReplicaService = require(Packages.ReplicaService)
local ProfileService = require(Packages.ProfileService)

local SaveStructure = {
	
	TotalKills = 0;
	Playtime = 0;
	
	Currency = {
		Credits = 150,
	},

	Weapons = {
		Guns = {};
		Melee = {};
		Equipment = {};
	}
}

local Profiles = {}
local Replicas = {}
local PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerData")
local ProfileStore = ProfileService.GetProfileStore("PlayerData", SaveStructure)

local DataService = Knit.CreateService {
	Name = "DataService", 
	Client = {
		DataLoaded = Knit.CreateSignal(),
		SaveData = Knit.CreateSignal(),
		LoadData = Knit.CreateSignal(),
	}
}

function DataService:GetReplica(Player : Player)	
	return Promise.new(function(Resolve, Reject)
		assert(typeof(Player) == "Instance" and Player:IsDescendantOf(Players), "Value passed is not a valid player")

		if not Profiles[Player] and not Replicas[Player] then
			repeat 
				if Player then
					task.wait()
				else
					Reject("Player left the game")
				end
			until Profiles[Player] and Replicas[Player]
		end

		local Profile = Profiles[Player]
		local Replica = Replicas[Player]
		if Profile and Profile:IsActive() then
			if Replica and Replica:IsActive() then
				Resolve(Replica)
			else
				Reject("Replica did not exist or wasn't active")

			end
		else
			Reject("Profile did not exist or wasn't active")
		end
	end)
end

local function PlayerAdded(Player: Player)
	local StartTime = tick()
	local Profile = ProfileStore:LoadProfileAsync("Player_" .. Player.UserId)

	if Profile then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			Profiles[Player] = nil
			Replicas[Player]:Destroy()
			Replicas[Player]= nil
			Player:Kick("Profile was released")

		end)

		if Player:IsDescendantOf(Players) == true then
			Profiles[Player] = Profile
			local Replica = ReplicaService.NewReplica({
				ClassToken = PlayerProfileClassToken,
				Tags = {["Player"] = Player},
				Data = Profile.Data,
				Replication = "All"
			})

			Replicas[Player] = Replica
			print(Replica.Data)
			warn(Player.Name.. "'s profile has been loaded. ".."("..string.sub(tostring(tick()-StartTime),1,5)..")")
		else
			Profile:Release()
		end
	else
		Player:Kick("Profile == nil") 
	end
end

function DataService:KnitInit()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	Players.PlayerRemoving:Connect(function(Player)
		if Profiles[Player] then
			Profiles[Player]:Release()
		end
	end)
end


function DataService:KnitStart()
	print('DataService Loaded!')
end

return DataService