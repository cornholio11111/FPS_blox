-- ## SERVICES ## --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- ## PLAYER ## --
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")
local CharacterAnimator = Humanoid:WaitForChild("Animator")

-- ## MODULES ## --
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local ParticleController
local CharacterAnimationsController
local AudioService
local ViewModelService
local WeaponProperties = require(ReplicatedStorage.Dictionaries.WeaponProperties)

-- ## MATH ## --
local raycastParams = RaycastParams.new()
local CFrame_Zero = CFrame.new()
local swayOffset = CFrame.new()
local multiplier = .8
local lastCameraCF = workspace.CurrentCamera.CFrame
local CurrentCamera = workspace.CurrentCamera
local DefaultFOV = CurrentCamera.FieldOfView

-- ## ASSETS ## --
local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

-- ## VARIABLES ## --
local IsAiming = false
local IsReloading = false
local IsInspecting = false
local IsShooting = false
local ShootingCooldown = false

-- ## MODULE ## --
local ViewModelController = Knit.CreateController {
	Name = "ViewModelController",
	DefaultFOV = DefaultFOV,
	Arms = nil,
	ArmsConfigFolder = nil,
	ArmsModule = nil,
	WeaponModel = nil,
	LoadedAnimations = {},
	GunAttachments = {
		Scope = nil,
		Mag = nil,
		Stock = nil,
		UnderBarrel = "FlashLight", -- "FlashLight"
		Barrel = nil,
	}
}

local function ShootingCooldownCountdown(Timer, NewValue)
	task.wait(Timer)
	ShootingCooldown = NewValue
end

function ViewModelController:RenderStepped()
	ParticleController = Knit.GetController("ParticleController")
	CharacterAnimationsController = Knit.GetController("CharacterAnimations")
	AudioService = Knit.GetService("AudioService")
	ViewModelService = Knit.GetService("ViewModelService")

	RunService.RenderStepped:Connect(function(deltaTime)
		SetArms()

		if IsAiming == false then
			CharacterAnimationsController:PlayAnimation("VM_"..self.Arms.Name.."Idle", true)
		end

		-- ## Shooting ## --

		if IsShooting == true and ShootingCooldown == false and self.ArmsConfigFolder.Ammo.Value > 0 then
			ShootingCooldown = true
			ViewModelService.WeaponFire:Fire(Character, PlayerMouse.Hit.Position, CurrentCamera.CFrame.LookVector, self.Arms.Name)
			CharacterAnimationsController:StopAllAnimationsAndPlay("VM_"..self.Arms.Name.."Fire")
			self.ArmsConfigFolder.Ammo.Value -= 1
			print(self.ArmsConfigFolder.Ammo.Value)
			coroutine.wrap(ShootingCooldownCountdown)(self.ArmsModule["FireDelay"], false)
		end
	end)
end

-- ## ARMS ## --
function SetArms()
	ViewModelController.Arms:SetPrimaryPartCFrame(CurrentCamera.CFrame)
	local rotation = workspace.CurrentCamera.CFrame:toObjectSpace(lastCameraCF)
	local x,y,z = rotation:ToOrientation()
	swayOffset = swayOffset:Lerp(CFrame.Angles(math.sin(x) * multiplier, math.sin(y) * multiplier, 0), 0.1)
	ViewModelController.Arms.PrimaryPart.CFrame *= swayOffset
	lastCameraCF = workspace.CurrentCamera.CFrame
end

function ViewModelController:SetNewWeapon(WeaponName)
	ViewModelService.SetNewWeapon:Fire(WeaponName)
	if self.Arms ~= nil then self.Arms:Destroy() end

	local Arms = Assets.Weapons:FindFirstChild(WeaponName):Clone()
	Arms.Parent = workspace.CurrentCamera
	self.Arms = Arms

	self.WeaponModel = self.Arms:FindFirstChild("Gun")
	self.ArmsConfigFolder = self.Arms.Configuration
	self.ArmsModule = WeaponProperties[Arms.Name]

	CharacterAnimationsController:SetAnimator(self.Arms.AnimationController.Animator)
	CharacterAnimationsController:ClearLoadedAnimations()
	CharacterAnimationsController:LoadAllAnimations()

	PlayerMouse.TargetFilter = self.Arms
	return
end

-- ## Mouse ## --
function ViewModelController:SetMouseIcon(ID)
	local HasString = ID:match("rbxassetid://")
	print(HasString)
	if HasString == true then
		PlayerMouse.Icon = ID
	else
		PlayerMouse.Icon = 'rbxassetid://'..ID
	end
end

function ViewModelController:MouseButton(Action, Button)
	if self.Arms == nil then return end

	if Action == "Up" then
		if Button == "Left" then
			IsShooting = false
		end

		if Button == "Right" then
			IsAiming = false
		end
	end

	if Action == "Down" then
		if Button == "Left" then
			IsShooting = true
		end

		if Button == "Right" then
			IsAiming = true
		end
	end
end

function ViewModelController:MouseButtonManager()
	-- ## LEFT MOUSE BUTTON ## --
	PlayerMouse.Button1Down:Connect(function()
		self:MouseButton("Down", "Left")
	end)

	PlayerMouse.Button1Up:Connect(function()
		self:MouseButton("Up", "Left")
	end)

	-- ## RIGHT MOUSE BUTTON ## --
	PlayerMouse.Button2Down:Connect(function()
		self:MouseButton("Down", "Right")
	end)

	PlayerMouse.Button2Up:Connect(function()
		self:MouseButton("Up", "Right")
	end)
end

function ViewModelController:KnitInit()
	self:RenderStepped()
	self:SetNewWeapon("Arms")
	self:MouseButtonManager()

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R then

		elseif input.KeyCode == Enum.KeyCode.I then
			if self.Arms.Name == "M4" then
				self:SetNewWeapon("AK")
			elseif self.Arms.Name == "AK" then
				self:SetNewWeapon("Arms")
			elseif self.Arms.Name == "Arms" then
				self:SetNewWeapon("M4")
			end
		elseif input.KeyCode == Enum.KeyCode.F then
			if self.GunAttachments.UnderBarrel == "FlashLight" then
				local Light = self.WeaponModel:FindFirstChild("Handle"):FindFirstChild("FlashlightAttachment"):FindFirstChildOfClass("SpotLight")
				local Beam = self.WeaponModel:FindFirstChild("Handle"):FindFirstChildOfClass("Beam")
				if Light then Light.Enabled = not Light.Enabled end
				if Beam then Beam.Enabled = Light.Enabled end
			end
		end
	end)
end

function ViewModelController:KnitStart()
	ViewModelController:SetMouseIcon("120192974")
	CharacterAnimationsController:SetAnimator(self.Arms.AnimationController.Animator)
	CharacterAnimationsController:LoadAllAnimations()
	
	warn('[DEBUG] Loaded Controller: ViewModelController')
end

return ViewModelController