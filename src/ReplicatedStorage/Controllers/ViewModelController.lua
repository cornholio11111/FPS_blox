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
local Spring = require(Packages.Knit.Spring)
local ParticleController
local CharacterAnimationsController
local AudioService
local ViewModelService
local WeaponProperties = require(ReplicatedStorage.Dictionaries.WeaponProperties)

-- ## MATH ## --
local CFrame_Zero = CFrame.new()
local ANIMATION_AIM_OFFSET = CFrame.new(-0.38, -1.05, -0.35)
local lastCameraCF = workspace.CurrentCamera.CFrame
local CurrentCamera = workspace.CurrentCamera
local DefaultFOV = CurrentCamera.FieldOfView

local swayOffset = Spring.new(0.75, 4, Vector3.new())
local swayAmount = Vector2.new(.8, .8)
local swayOffsetVec

local swayOffset_ = CFrame.new()
local multiplier_ = .3

-- ## ASSETS ## --
local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

-- ## VARIABLES ## --
local IsAiming = false
local IsReloading = false
local IsInspecting = false
local IsShooting = false
local ShootingCooldown = false

-- ## TWEEN INFO ## --
local Info = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- ## MODULE ## --
local ViewModelController = Knit.CreateController {
	Name = "ViewModelController",
	DefaultFOV = DefaultFOV,

	Arms = nil,
	Handle = nil,
	AimPart = nil,
	AimOffset = nil,
	FirePoint = nil,
	Animator = nil,
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

function ViewModelController:Aim()
	TweenService:Create(CurrentCamera, Info, {FieldOfView = 50}):Play()

	if self.WeaponModel ~= nil then
		local AimPoint = self.WeaponModel.PrimaryPart:FindFirstChild("AimPoint")

		if AimPoint then
			self.AimOffset = AimPoint.CFrame
		else
			self.AimOffset = CFrame_Zero
		end
	
		local swayCFrame = CFrame.Angles(swayOffsetVec.Y, 0, 0) * CFrame.Angles(0, -swayOffsetVec.X, 0) * CFrame.Angles(0, 0, -swayOffsetVec.X)
		local rootCFrame = CurrentCamera.CFrame * self.ArmsModule.ViewModelOffset * (swayOffset_:Lerp(CFrame.new(), 2))
		local baseCFrame = CurrentCamera.CFrame * self.AimOffset * ANIMATION_AIM_OFFSET
	
		baseCFrame *= swayCFrame:Lerp(CFrame.new(), 0.5)
	
		rootCFrame = rootCFrame:Lerp(baseCFrame, .1)
		self.Arms.PrimaryPart.CFrame = rootCFrame
	
		UserInputService.MouseIconEnabled = self.ArmsModule.WhileAimingIsCursorVisible
	end
end

function ViewModelController:RenderStepped()
	RunService.RenderStepped:Connect(function(deltaTime)
		if self.Arms == nil then return end

		SetArms(deltaTime)

		if IsAiming == false then
			if CurrentCamera.FieldOfView < 60 then
				TweenService:Create(CurrentCamera, Info, {FieldOfView = 60}):Play()
			end
			UserInputService.MouseIconEnabled = self.ArmsModule.WhileNotAimingIsCursorVisible
			CharacterAnimationsController:PlayAnimation("VM_"..self.Arms.Name.."Idle", true)
		elseif IsAiming == true then
			self:Aim()
		end

		-- ## Shooting ## --

		if IsShooting == true and ShootingCooldown == false and self.ArmsConfigFolder.Ammo.Value > 0 and self.FirePoint ~= nil then
			ShootingCooldown = true
			ViewModelService.WeaponFire:Fire(Character, self.FirePoint.CFrame.Position, CurrentCamera.CFrame.LookVector, self.Arms.Name)
			CharacterAnimationsController:StopAllAnimationsAndPlay("VM_"..self.Arms.Name.."Fire")
			self.ArmsConfigFolder.Ammo.Value -= 1
			print(self.ArmsConfigFolder.Ammo.Value)
			coroutine.wrap(ShootingCooldownCountdown)(self.ArmsModule["FireDelay"], false)
			CharacterAnimationsController:PlayAnimation("VM_"..self.Arms.Name.."Idle", true)
		end
	end)
end

-- ## ARMS ## --
function SetArms(dt)
	ViewModelController.Arms:SetPrimaryPartCFrame(CurrentCamera.CFrame)
	swayOffsetVec = swayOffset:Update(dt)
	swayOffset.g = Vector3.new(
		math.rad(math.clamp(swayAmount.X, -18, 18) / 18) * 10,
		math.rad(math.clamp(swayAmount.Y, -18, 18) / 18) * 10,
		0
	)

	local rotation = workspace.CurrentCamera.CFrame:toObjectSpace(lastCameraCF)
	local x,y,z = rotation:ToOrientation()
	swayOffset_ = swayOffset_:Lerp(CFrame.Angles(math.sin(x) * multiplier_, math.sin(y) * multiplier_, 0), 0.1)
	ViewModelController.Arms.PrimaryPart.CFrame *= swayOffset_
	lastCameraCF = workspace.CurrentCamera.CFrame
end

function ViewModelController:SetNewWeapon(WeaponName)
	if self.Arms ~= nil then self.Arms:Destroy() end

	local Arms = Assets.Weapons:FindFirstChild(WeaponName):Clone()
	Arms.Parent = workspace.CurrentCamera
	self.Arms = Arms

	ViewModelService.SetNewWeapon:Fire(WeaponName)

	local gun = Arms:FindFirstChild("Gun")

	task.wait()

	self.WeaponModel = Arms:FindFirstChild("Gun")
	self.ArmsConfigFolder = Arms.Configuration
	self.ArmsModule = WeaponProperties[Arms.Name]
	self.Animator = Arms:FindFirstChildOfClass("AnimationController"):FindFirstChildOfClass("Animator")

	if gun then  	
		self.FirePoint = gun:WaitForChild("FirePoint")
		self.AimPart = gun.PrimaryPart
		self.Handle = gun:WaitForChild("Handle")
	end

	CharacterAnimationsController:SetAnimator(self.Animator)
	CharacterAnimationsController:LoadAllAnimations()

	PlayerMouse.TargetFilter = self.Arms
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
	task.wait(.2)
	ParticleController = Knit.GetController("ParticleController")
	CharacterAnimationsController = Knit.GetController("CharacterAnimations")
	AudioService = Knit.GetService("AudioService")
	ViewModelService = Knit.GetService("ViewModelService")

	self:SetNewWeapon("Arms")
	self:RenderStepped()
	self:MouseButtonManager()

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R then

		elseif input.KeyCode == Enum.KeyCode.I then
			if self.Arms.Name == "M4" then
				self:SetNewWeapon("AK")
			elseif self.Arms.Name == "AK" then
				self:SetNewWeapon("M4")
			elseif self.Arms.Name == "Arms" then
				self:SetNewWeapon("M4")
			end
		elseif input.KeyCode == Enum.KeyCode.F then
			if self.GunAttachments.UnderBarrel == "FlashLight" then
				local Light = self.WeaponModel:FindFirstChild("Handle"):FindFirstChild("FlashlightAttachment"):FindFirstChildOfClass("SpotLight")
				local Beam = self.WeaponModel:FindFirstChild("Handle"):FindFirstChildOfClass("Beam")
				if Light then Light.Enabled = not Light.Enabled end
				if Beam then Beam.Enabled = Light.Enabled end
			elseif self.GunAttachments.UnderBarrel == "Laser" then
				warn("PEW PEW")
			end
		end
	end)
end

function ViewModelController:KnitStart()
	self:SetMouseIcon("120192974")

	warn('[DEBUG] Loaded Controller: ViewModelController')
end

return ViewModelController