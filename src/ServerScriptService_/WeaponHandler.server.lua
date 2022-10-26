-- ## SERVICES ## --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

-- ## REMOTES ## --
local WeaponRemote = game.ReplicatedStorage.Remotes.WeaponRemote

-- ## MODULES ## --
local WeaponBase = require(ServerStorage.Modules.WeaponBase)

WeaponRemote.OnServerEvent:Connect(function(Player : Player, WeaponFunction : string, Info : table)
    if WeaponFunction == "ChangeFiringMode" or WeaponFunction == "FiringMode" then
        WeaponBase:ChangeFiringMode(Player, Info.CurrentMode, Info.NewMode)
    end
end)