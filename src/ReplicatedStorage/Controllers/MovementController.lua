-- IndieFlare / cornholio11111

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local WalkSpeed = Character:WaitForChild("Humanoid").WalkSpeed 

local MovementSettings = {
	NormalWalkSpeed = WalkSpeed,
	RunWalkSpeed = WalkSpeed * 2 - WalkSpeed / 3 - 2,

	NormalJumpPower = 50,
	RunningJumpPower = 45,
}

local Keybinds = {
	InputBegan = {
		[Enum.KeyCode.LeftShift] = {Action = "Run", valueString = "WalkSpeed"},
		[Enum.KeyCode.RightShift] = {Action = "Run", valueString = "WalkSpeed"},
	},

	InputEnded = {
		[Enum.KeyCode.LeftShift] = {Action = "Normal", valueString = "WalkSpeed"},
		[Enum.KeyCode.RightShift] = {Action = "Normal", valueString = "WalkSpeed"},
	}
}

local MovementController = Knit.CreateController({Name = "MovementController"})

function slide()
	
end

function crouch()
	
end


function InputBegan(InputKey)
	if Keybinds.InputBegan[InputKey.KeyCode] then
		local TableFromKeyCode = Keybinds.InputBegan[InputKey.KeyCode]
		local Action = TableFromKeyCode.Action
		if Action ~= "Slide" and Action ~= "Crouch" then
			local valueString = TableFromKeyCode.valueString
			local Value = MovementSettings[Action..valueString]

			Character:WaitForChild("Humanoid")[valueString] = Value
		elseif Action == "Slide" and Action ~= "Crouch" then
			slide()
		elseif Action ~= "Slide" and Action == "Crouch" then
			crouch()
		end
	end
end

function InputEnded(InputKey)
	if Keybinds.InputEnded[InputKey.KeyCode] then
		local TableFromKeyCode = Keybinds.InputEnded[InputKey.KeyCode]
		local Action = TableFromKeyCode.Action
		local valueString = TableFromKeyCode.valueString
		local Value = MovementSettings[Action..valueString]

		Character:WaitForChild("Humanoid")[valueString] = Value
	end
end

function MovementController:KnitStart()
	
end

function MovementController:KnitInit()
	UserInputService.InputBegan:Connect(InputBegan)
	UserInputService.InputEnded:Connect(InputEnded)
	warn('[DEBUG] Loaded Controller: MovementController')
end

return MovementController