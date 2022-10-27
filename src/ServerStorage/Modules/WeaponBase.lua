-- ## SERVICES ## --
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

export type WeaponProperties = {
    FiringModes: {
        Full_Automatic: boolean,
        Burst: boolean,
        Single: boolean,
        Semi_Automatic: boolean,
    },
    Range: number,
    MagSize: number,
    Attachments: {
        Scope: Model | Folder | BasePart | nil,
        Mag: Model | Folder | BasePart | nil,
        Grip: Model | Folder | BasePart | nil,
        Muzzle: Model | Folder | BasePart | nil,
        Stock: Model | Folder | BasePart | nil,
        AmmoType: StringValue | IntValue | "Normal",
        Barrel: Model | Folder | BasePart | nil,
    }
}

-- ## MODULE ## --
local WeaponBase = {}

function WeaponBase.new(Player : Player, Weapon : Model | Folder, WeaponProperties : WeaponProperties)
    
end

function WeaponBase:ChangeFiringMode(Player : Player,CurrentMode : string | StringValue, NewMode : string | StringValue)
    print("WTF")
end

return WeaponBase