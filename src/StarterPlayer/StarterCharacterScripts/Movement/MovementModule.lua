-- ## SERVICES ## --
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

-- ## PLAYER ## --
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ## MODULE ## --
local MovementModule = {
    IsRunning = false,
    CanRun = true,

}

function MovementModule:_Init() 
    -- Starts everything so if we wanted to disable a movement we can do with ease
    MovementModule:SlideManager()
end

function MovementModule:SlideManager()
    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = Character.PrimaryPart

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.LeftControl and Humanoid.FloorMaterial ~= nil then
            BodyVelocity.MaxForce = Vector3.new(15000, 15000, 15000)
            BodyVelocity.Velocity = HumanoidRootPart.CFrame.lookVector * 100
            Humanoid.Sit = true

            task.wait(1)
            Humanoid.Sit = false
           BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        end
    end)

end

return MovementModule

