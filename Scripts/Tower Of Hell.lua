local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService('TweenService')
local LocalPlayer = Players.LocalPlayer

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/sl-ius/Lynx-Rayfield/main/src.lua'))()

local NotificationEnabled = true

local function AttemptTeleport()
	if game.ReplicatedStorage.time.Value < 60 then
		if NotificationEnabled == true then
			Library:Notify({
				Title = "Ovis",
				Content = "Ovis is currently waiting for the Anti-Cheat time to pass, this might take a minute, we also have anti-afk enabled, so you won't be disconnected.",
				Duration = 4,
				Image = 4483362458,
			 })
			 wait(5)
		end
	else
	    LocalPlayer.Character.HumanoidRootPart.CFrame = game.workspace.tower.sections.finish.FinishGlow.CFrame
	end

game:GetService("Players").LocalPlayer.Idled:connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)
end

local Window = Library:CreateWindow({
	Name = "Tower Of Hell",
	LoadingTitle = "Tower Of Hell",
	LoadingSubtitle = "by Ovis",
	ConfigurationSaving = {
	   Enabled = true,
	   FolderName = "Ovis",
	   FileName = "Ovis Hub"
	}
 })

 local Character = Window:CreateTab("Character")
 local AutoFarm = Window:CreateTab("Auto Farm")
 local Shop = Window:CreateTab("Shop")
 local Settings = Window:CreateTab("Settings")


 Character:CreateSection("LocalPlayer")
 Character:CreateButton({
	Name = "Get Tools",
	Callback = function()
		for _, tools in pairs(LocalPlayer.Backpack:GetDescendants()) do
			if tools:IsA("Tool") then
				tools:Destroy()

			end
		end

		for _, gametools in pairs(game.ReplicatedStorage.Gear:GetDescendants()) do
			if gametools:IsA("Tool") then
				local GameTools = gametools:Clone()
				GameTools.Parent = game.Players.LocalPlayer.Backpack
			end
		end
	end,
 })
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
	Name = "BunnyHop",
	CurrentValue = false,
	Flag = "BunnyHop",
	Callback = function(Actviate)
		if Actviate then

			Actviate = true
			game.ReplicatedStorage.bunnyJumping.Value = true
		else
			
			Actviate = false
			game.ReplicatedStorage.bunnyJumping.Value = false
		end
	end,
 })

 Character:CreateSlider({
	Name = "Jump Amount",
	Range = {0, 150},
	Increment = 1,
	Suffix = "Amount",
	CurrentValue = 10,
	Flag = "JumpAmount",
	Callback = function(Amount)
		game.ReplicatedStorage.globalJumps.Value = Amount
	end,
 })

 AutoFarm:CreateSection("Auto Farm")

 AutoFarm:CreateToggle({
	Name = "Auto Instant Wins",
	CurrentValue = false,
	Flag = "AutoFarmTower",
	Callback = function(Actviate)
		shared["AttemptTeleport"] = Actviate
		while shared["AttemptTeleport"] do
		   task.wait()
		   if not shared["AttemptTeleport"] then
			  break
		   end
		   AttemptTeleport()
		end
	end,
 })
 
 AutoFarm:CreateSection("Tower")

 AutoFarm:CreateButton({
	Name = "Remove Kill Bricks",
	Callback = function()
		for _, parts in pairs(game:GetService("Workspace").tower:GetDescendants()) do
			if parts:IsA("BoolValue") and parts.Name == "kills" then
				parts.Parent:Destroy()
			end
		end
	end,
 })

 AutoFarm:CreateButton({
	Name = "GodMode",
	Callback = function()
		for _, killvalue in pairs(game:GetService("Workspace").tower:GetDescendants()) do
			if killvalue:IsA("BoolValue") and killvalue.Name == "kills" then
				killvalue:Destroy()
			end
		end
	end,
 })

 Shop:CreateSection("Purchases")

 Shop:CreateButton({
	Name = "Buy Box",
	Callback = function()
		local args = {
			[1] = "Regular"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("openBox"):InvokeServer(unpack(args))		
	end,
 })

 Settings:CreateToggle({
	Name = "Enable Notification",
	CurrentValue = true,
	Flag = "EnableNotify",
	Callback = function(Enable)
		NotificationEnabled = Enable
	end,
 })
