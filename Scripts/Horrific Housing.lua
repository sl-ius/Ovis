local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function ClaimReward()
    game:GetService("ReplicatedStorage").LoginRewards:FireServer()
end

local ToolsList = {
    "Bat",
    "Hammer",
    "Sword",
    "Knife",
    "Katana",
    "CandyCane"
}

local function AutoUses()
    for _, tools in pairs(LocalPlayer.Character:GetChildren()) do
        if tools.Name == ToolsList then
            while wait() do
                LocalPlayer.Character.tools.Event:FireServer()
            end
        end
    end
end

local equippablePets = {}
for _, v in pairs(game.ReplicatedStorage.Pets:GetChildren()) do
    table.insert(equippablePets, v.Name)
end

table.sort(equippablePets, function(a, b)
    return a < b
end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/sl-ius/Lynx-Rayfield/main/src.lua'))()

local NotificationEnabled = true

local Window = Library:CreateWindow({
    Name = "Horrific Housing",
    LoadingTitle = "Horrific Housing",
    LoadingSubtitle = "by Ovis",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ovis",
        FileName = "Ovis Hub"
    }
})

local Character = Window:CreateTab("Character")
local Game = Window:CreateTab("Game")
local Shop = Window:CreateTab("Shop")
local Settings = Window:CreateTab("Settings")

Character:CreateSection("LocalPlayer")
local WalkSpeed = Character:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 5,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Speed)
        LocalPlayer.Character.Humanoid.WalkSpeed = Speed
    end,
})
local JumpPower = Character:CreateSlider({
    Name = "JumpPower",
    Range = {50, 250},
    Increment = 5,
    Suffix = "JumpPower",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Power)
        LocalPlayer.Character.Humanoid.JumpPower = Power
    end,
})
Character:CreateButton({
    Name = "Reset WalkSpeed & JumpPower",
    Callback = function()
        WalkSpeed:Set(16)
        JumpPower:Set(50)
    end,
})
Character:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Toggle)
        if Toggle then
            noClipped = true
            game:GetService("RunService").Stepped:Connect(function()
                if noClipped then
                    pcall(function()
                        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                            if v.ClassName == "Part" or v.ClassName == "MeshPart" then
                                v.CanCollide = false
                            end
                        end
                    end)
                end
            end)
        else
            if noClipped == true then
                noClipped = false
            else
                noClipped = true
            end
        end
    end,
})
Game:CreateSection("Backpack")
Game:CreateToggle({
    Name = "Auto Use",
    CurrentValue = false,
    Flag = "AutoUse",
    Callback = function(Activate)
        shared["AutoUses"] = Activate
        while shared["AutoUses"] do
            task.wait()
            if not shared["AutoUses"] then
                break
            end
            AutoUses()
        end
    end,
})

Game:CreateToggle({
    Name = "Auto Forge",
    CurrentValue = false,
    Flag = "Auto Forge",
    Callback = function(Activate)
        local Active = Activate

        if Active then
            local args = {
                [1] = "Revolver",
                [2] = "Revolver",
                [3] = "Revolver"
            }

            game:GetService("ReplicatedStorage"):WaitForChild("EventRemotes"):WaitForChild("ForgeUltimateSword"):FireServer(unpack(args))
        end
    end,
})