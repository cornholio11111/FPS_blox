-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local Debris = game:GetService("Debris")

-- ## MODULES ## --
local Knit = require(ReplicatedStorage.Packages.Knit)
local FastCast = require(ReplicatedStorage.Dictionaries.FastCast)
local WeaponProperties = require(ReplicatedStorage.Dictionaries.WeaponProperties)

-- ## ASSETS ## --
local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

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
		PlayAnimation = Knit.CreateSignal(),
		StopAllAnimationsAndPlay = Knit.CreateSignal(),
	}
}

local LoadedAnimation = {}

function JoinParts(RightHand, Weapon, HumanoidRootPart)
	local motor = Assets.Weapons.Requirements.Handle:Clone()

	local weaponMotor = motor
	weaponMotor.Part0 = RightHand
	weaponMotor.Parent = RightHand
	weaponMotor.Part1 = Weapon.PrimaryPart

	return weaponMotor
end

function ViewModelService:KnitInit()
	self.Client.WeaponFire:Connect(function(Player, Character, Origin, LookVector, WeaponName)

		local function pew()
			Knit.GetService("AudioService"):PlaySound(Player, Assets.Audio.Shoot, true, Origin)
		end

		coroutine.wrap(pew)()

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
				Part.Anchored = true
				Part.CanCollide = false
				Part.Orientation = LookVector
				Part.Color = Color3.new(0.658823, 0.521568, 0.223529)
				Part.Material = Enum.Material.Metal
				Part.Parent = workspace.Raycast_Ignore

				-- local Decal = Instance.new("Decal")
				-- Decal.Texture = "rbxassetid://10147449500"
				-- Decal.Face = Enum.NormalId.Front
				-- Decal.Parent = Part
				
				local function IsBreakable()
					if string.lower(result.Instance.Name) == "_glass" then
						result.Instance:Destroy()
						Knit.GetService("AudioService"):PlaySound(Player, Assets.Audio.GlassBreak, true, result.Position)
					end
				end

				coroutine.wrap(IsBreakable)()

				local Model = result.Instance:FindFirstAncestorOfClass("Model")
				if Model then
					local Humanoid = Model:FindFirstChildOfClass("Humanoid")
					if Humanoid then
						if result.Instance.Name == "Head" then
							Humanoid:TakeDamage(WeaponProperties[WeaponName]["HeadShotDefaultDamage"])
						else
							Humanoid:TakeDamage(WeaponProperties[WeaponName]["DefaultDamage"])
						end
					end
				end

				Debris:AddItem(Part, 5)
			end)
		end
	end)

	self.Client.SetNewWeapon:Connect(function(Player, Character, WeaponName)
		print(Player.Name.." Has A "..WeaponName)
		if WeaponName == "Arms" then return end
		if Character:FindFirstChild("PlayerWeapon") then Character:FindFirstChild("PlayerWeapon"):Destroy() end

		local Weapon = Assets.Weapons.Character:FindFirstChild(WeaponName):Clone()
		Weapon.Name = "PlayerWeapon"
		JoinParts(Character.RightHand, Weapon, Character.HumanoidRootPart)
		Weapon.Parent = Character
	end)

	self.Client.PlayAnimation:Connect(function(Player, Character, animationName, Looped)
		local Humanoid = Character:WaitForChild("Humanoid")
		if Humanoid then
			local Animator = Humanoid:WaitForChild("Animator")
			local Animation = Animations.Character:FindFirstChild(animationName, true)
			if Animator and Animation then
				local Table = LoadedAnimation[Player.Name]

				if not Table then 
					LoadedAnimation[Player.Name] = {} 
					Table = LoadedAnimation[Player.Name] 
				end

				local FoundAnimation = false

				for i, v in pairs(Table) do
					if i == animationName or v == animationName then
						FoundAnimation = true
					end
				end

				if FoundAnimation == false then
					Table[animationName] = Animator:LoadAnimation(Animation)
					Table[animationName].Looped = Looped
					Table[animationName]:Play()
				else
					Table[animationName].Looped = Looped
					Table[animationName]:Play()
				end
			end
		end
	end)

	self.Client.StopAllAnimationsAndPlay:Connect(function(Player, Character, animationName, Looped)
		local Humanoid = Character:WaitForChild("Humanoid")
		if Humanoid then
			local Animator = Humanoid:WaitForChild("Animator")
			local Animation = Animations.Character:FindFirstChild(animationName, true)
			if Animator and Animation then
				local Table = LoadedAnimation[Player.Name]

				if not Table then 
					LoadedAnimation[Player.Name] = {} 
					Table = LoadedAnimation[Player.Name] 
				end

				for _, Animation in pairs(Table) do
					Animation:Stop()
				end

				local FoundAnimation = false

				for i, v in pairs(Table) do
					if i == animationName or v == animationName then
						FoundAnimation = true
					end
				end

				if FoundAnimation == false then
					Table[animationName] = Animator:LoadAnimation(Animation)
					Table[animationName].Looped = Looped
					Table[animationName]:Play()
				elseif FoundAnimation == true then
					Table[animationName].Looped = Looped
					Table[animationName]:Play()
				end
			end
		end
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