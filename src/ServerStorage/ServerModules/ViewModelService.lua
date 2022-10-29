-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

-- ## MODULES ## --
local Knit = require(ReplicatedStorage.Packages.Knit)
local FastCast = require(ReplicatedStorage.Dictionaries.FastCast)
local WeaponProperties = require(ReplicatedStorage.Dictionaries.WeaponProperties)

-- ## VARIABLES ## --
local BULLET_GRAVITY = Vector3.new(0, -workspace.Gravity / 15, 0)
local BULLET_SPEED = 100
local BULLET_SIZE = .05

-- ## DEBUGGING VARIABLES ## --
FastCast.DebugLogging = false
FastCast.VisualizeCasts = false

-- ## MODULE ## --
local ViewModelService = Knit.CreateService {
	Name = "ViewModelService", 
	Client = {
		WeaponFire = Knit.CreateSignal(),
		SetNewWeapon = Knit.CreateSignal(),
	}
}

function ViewModelService:KnitInit()
	self.Client.WeaponFire:Connect(function(Player, Character, Origin, LookVector, WeaponName)
		local Caster = FastCast.new()
		local modifiedBulletSpeed = (LookVector * BULLET_SPEED)
		-- ## Raycast Params ## --
		local CastParams = RaycastParams.new()
		CastParams.IgnoreWater = true
		CastParams.FilterType = Enum.RaycastFilterType.Blacklist
		CastParams.FilterDescendantsInstances = {Character:GetChildren(), workspace.Raycast_Ignore:GetChildren()}

		-- ## FastCast ## --
		local CastBehavior = FastCast.newBehavior()
		CastBehavior.RaycastParams = CastParams
		CastBehavior.MaxDistance = 1000
		CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default
		CastBehavior.Acceleration = BULLET_GRAVITY

		local simBullet = Caster:Fire(Origin, LookVector, modifiedBulletSpeed, CastBehavior)

		if simBullet then
			simBullet.Caster.RayHit:Connect(function(cast, result, velocity, bullet)
				local Part = Instance.new("Part")
				Part.Size = Vector3.new(BULLET_SIZE, BULLET_SIZE, BULLET_SIZE)
				Part.Position = result.Position
				--Part.CFrame = CFrame.lookAt(result.Position, result.Position + result.Normal)
				Part.Anchored = true
				Part.Orientation = LookVector
				Part.Color = Color3.new(0.658823, 0.521568, 0.223529)
				--Part.Transparency = 1
				Part.Material = Enum.Material.Metal

				-- local Decal = Instance.new("Decal")
				-- Decal.Texture = "rbxassetid://10147449500"
				-- Decal.Face = Enum.NormalId.Front
				-- Decal.Parent = Part

				Part.Parent = workspace.Raycast_Ignore
				
				if result.Instance.Parent:IsA("Model") then
					local Model = result.Instance:FindFirstAncestorOfClass("Model")
					if Model then
						local Humanoid = Model:FindFirstChildOfClass("Humanoid")
						if Humanoid then
								Humanoid:TakeDamage(WeaponProperties[WeaponName]["DefaultDamage"])
						end
					end
				end

			end)
		end
	end)

	self.Client.SetNewWeapon:Connect(function(Player, WeaponName)
		print(Player.Name.." Has A "..WeaponName)
	end)
end

function ViewModelService:KnitStart()
	warn('[DEBUG] Loaded Service: ViewModelService')
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(Message)
		local LowerMessage = Message:lower()
		if LowerMessage == "/debug" then
			FastCast.DebugLogging = not FastCast.DebugLogging
			FastCast.VisualizeCasts = not FastCast.VisualizeCasts

			if FastCast.VisualizeCasts == false then
				workspace.Terrain:WaitForChild("FastCastVisualizationObjects"):ClearAllChildren()
			end
		end
	end)
end)

return ViewModelService