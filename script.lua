--[[

    Ovis is a free & open-source univeral script.
    Sius - Programming + Designing

    Trust me, I don't code this bad anymore ;-;

    discord: discord.gg/d3fKHPTafg

    Sius is currently working on a better one, please check out our Discord

--]]

local currentversion = "Alpha 1.0"
local OVIS_LOADED = false

local OvisUI = {
    HomeOpen = true,
    Closed = true,
    Hidden = false,
    Hovering = false,
    Debounce = false,
    HomeDebounce = false,
    ButtonDebounce = false
}

local OvisSettings = {
    StartupSoundVolume = 5,
    StartupSound = "rbxassetid://"..1862048961,
    NotifcationSoundVolume = 1,
    NotifcationSound = "rbxassetid://"..8183296024,
    HoverSoundVolume = 0.8,
    HoverSound = "rbxassetid://"..10066931761,
    ClickSoundVolume = 0.8,
    ClickSound = "rbxassetid://"..6972137633,
    UnhideKeybind = T
}

--> Getting Service <--
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Camera = game.workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Ovis = game:GetObjects("rbxassetid://14337620278")[1] -- Ovis interface
Ovis.Enabled = true
OVIS_LOADED = true

-- protecting Ovis
if gethui then -- get_hidden_gui
    Ovis.Parent = gethui()
elseif syn.protectgui then
    syn.protectgui(Ovis)
else
    game.CoreGui:FindFirstChild("RobloxGui")
    Ovis.Parent = CoreGui.RobloxGui  
end

local Sidebar = Ovis.Sidebar
local Notification = Ovis.Notification
local Home = Ovis.Home
local Exit = Ovis.Exit
local NotInTabScreen = Ovis.NotInTabScreen

Notification.Template.Visible = false

local frames = 0

wait(0.1)
RunService.RenderStepped:Connect(function()
    frames = frames + 1
end)

local Blur = (function()
    local module = {}

    do
        local function IsNotNaN(x)
            return x == x
        end
        local continued = IsNotNaN(Camera:ScreenPointToRay(0,0).Origin.x)
        while not continued do
            RunService.RenderStepped:wait()
            continued = IsNotNaN(Camera:ScreenPointToRay(0,0).Origin.x)
        end
    end
    local RootParent = Camera


    local binds = {}
    local root = Instance.new('Folder', RootParent)
    root.Name = 'neon'


    local GenUid; do
        local id = 0
        function GenUid()
            id = id + 1
            return 'neon::'..tostring(id)
        end
    end

    local DrawQuad; do
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local sz = 0.2

        function DrawTriangle(v1, v2, v3, p0, p1)
            local s1 = (v1 - v2).magnitude
            local s2 = (v2 - v3).magnitude
            local s3 = (v3 - v1).magnitude
            local smax = max(s1, s2, s3)
            local A, B, C
            if s1 == smax then
                A, B, C = v1, v2, v3
            elseif s2 == smax then
                A, B, C = v2, v3, v1
            elseif s3 == smax then
                A, B, C = v3, v1, v2
            end

            local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
            local perp = sqrt((C-A).magnitude^2 - para*para)
            local dif_para = (A - B).magnitude - para

            local st = CFrame.new(B, A)
            local za = CFrame.Angles(pi/2,0,0)

            local cf0 = st

            local Top_Look = (cf0 * za).lookVector
            local Mid_Point = A + CFrame.new(A, B).LookVector * para
            local Needed_Look = CFrame.new(Mid_Point, C).LookVector
            local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

            local ac = CFrame.Angles(0, 0, acos(dot))

            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

            local cf1 = st * ac * CFrame.Angles(0, pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
            end
            cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

            if not p0 then
                p0 = Instance.new('Part')
                p0.FormFactor = 'Custom'
                p0.TopSurface = 0
                p0.BottomSurface = 0
                p0.Anchored = true
                p0.CanCollide = false
                p0.Material = 'Glass'
                p0.Size = Vector3.new(sz, sz, sz)
                local mesh = Instance.new('SpecialMesh', p0)
                mesh.MeshType = 2
                mesh.Name = 'WedgeMesh'
            end
            p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
            p0.CFrame = cf0

            if not p1 then
                p1 = p0:clone()
            end
            p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
            p1.CFrame = cf1

            return p0, p1
        end

        function DrawQuad(v1, v2, v3, v4, parts)
            parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
            parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
        end
    end

    function module:BindFrame(frame, properties)
        if RootParent == nil then return end
        if binds[frame] then
            return binds[frame].parts
        end

        local uid = GenUid()
        local parts = {}
        local f = Instance.new('Folder', root)
        f.Name = frame.Name

        local parents = {}
        do
            local function add(child)
                if child:IsA'GuiObject' then
                    parents[#parents + 1] = child
                    add(child.Parent)
                end
            end
            add(frame)
        end

        local function UpdateOrientation(fetchProps)
            local zIndex = 1 - 0.05*frame.ZIndex
            local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
            local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
            do
                local rot = 0;
                for _, v in ipairs(parents) do
                    rot = rot + v.Rotation
                end
                if rot ~= 0 and rot%180 ~= 0 then
                    local mid = tl:lerp(br, 0.5)
                    local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
                    local vec = tl
                    tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
                    tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
                    bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
                    br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
                end
            end
            DrawQuad(
                Camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
                Camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
                Camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
                Camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
                parts
            )
            if fetchProps then
                for _, pt in pairs(parts) do
                    pt.Parent = f
                end
                for propName, propValue in pairs(properties) do
                    for _, pt in pairs(parts) do
                        pt[propName] = propValue
                    end
                end
            end
        end

        UpdateOrientation(true)
        RunService:BindToRenderStep(uid, 2000, UpdateOrientation)

        binds[frame] = {
            uid = uid;
            parts = parts;
        }
        return binds[frame].parts
    end

    function module:Modify(frame, properties)
        local parts = module:GetBoundParts(frame)
        if parts then
            for propName, propValue in pairs(properties) do
                for _, pt in pairs(parts) do
                    pt[propName] = propValue
                end
            end
        end
    end

    function module:UnbindFrame(frame)
        if RootParent == nil then return end
        local cb = binds[frame]
        if cb then
            RunService:UnbindFromRenderStep(cb.uid)
            for _, v in pairs(cb.parts) do
                v:Destroy()
            end
            binds[frame] = nil
        end
    end

    function module:HasBinding(frame)
        return binds[frame] ~= nil
    end

    function module:GetBoundParts(frame)
        return binds[frame] and binds[frame].parts
    end


    return module

end)()

function DestroyCurrentOvis()
    local RemoveInstances = 0
    if game.Lighting:FindFirstChild("OvisBlur") then
		game.Lighting:FindFirstChild("OvisBlur"):Destroy()
    end

    for _, ovis in ipairs(game.CoreGui:GetChildren()) do
        if ovis.Name == "Ovis" and ovis ~= Ovis then
            ovis:Destroy()
            ovis.Enabled = false
            ovis.Name = "Destroying Ovis..."
            RemoveInstances = RemoveInstances + 1
        end
    end

    if gethui() then
        for _, ovis in ipairs(gethui():GetChildren()) do
            if ovis.Name == "Ovis" and ovis ~= Ovis then
                ovis.Enabled = false
                ovis.Name = "Destroying Ovis..."
                ovis:Destroy()
                RemoveInstances = RemoveInstances + 1
            end
        end
    end
end

do
    task.spawn(function()
        while wait() do
            local t = tick()
            local minutes = math.floor((t / 60) % 60)
            local hours = math.floor((t / 3600) % 24)

            if string.len(minutes) < 2 then
                minutes = "0" .. tostring(minutes)
            end

            if string.len(hours) < 2 then
                hours = "0" .. tostring(hours)
            end

            Sidebar.Time.Text = hours .. minutes
        end
    end)
end

function EditErrorGui(Title, Content, Button)
    local finderrorgui = game.CoreGui:FindFirstChild("RobloxPromptGui")
    if finderrorgui then
        game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = Title
        game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = Content
        game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ButtonArea.LeaveButton.ButtonText.Text = Button
    else
        warn("Failed to fetch item 'RobloxPromptGui'")
    end
end

function OvisUI:Notify(NotificationSettings)
    spawn(function()
        local CreateTemplate = Notification.Template:Clone()
        local TemplateIcon = CreateTemplate.Icon
        local TemplateTitle = CreateTemplate.Title
        local TemplateContent = CreateTemplate.Content

        local TemplateSound = Instance.new("Sound")
        TemplateSound.Parent = Ovis
        TemplateSound.Volume = OvisSettings.NotifcationSoundVolume
        TemplateSound.PlayOnRemove = true
        TemplateSound.SoundId = OvisSettings.NotifcationSound or tostring("rbxassetid://"..NotificationSettings.Sound)
        TemplateSound:Destroy()

        CreateTemplate.Parent = Notification
        CreateTemplate.Visible = true
        CreateTemplate.Size = UDim2.new(1, 0, -0.31, 110)
        CreateTemplate.ClipsDescendants = true
        TemplateIcon.ImageTransparency = 1
        TemplateTitle.TextTransparency = 1
        TemplateContent.TextTransparency = 1

        TemplateTitle.Text = NotificationSettings.Title or "No title has written"
        TemplateContent.Text = NotificationSettings.Content or "No content has written"

        local blurlight = nil
        blurlight = Instance.new("DepthOfFieldEffect",game:GetService("Lighting"))
        blurlight.Enabled = true
        blurlight.FarIntensity = 0
        blurlight.FocusDistance = 51.6
        blurlight.InFocusRadius = 50
        blurlight.NearIntensity = 1
        game:GetService("Debris"):AddItem(script,0)

        Blur:BindFrame(CreateTemplate.BlurFrame, {
            Transparency = 0.98;
            BrickColor = BrickColor.new("Black");
        })


        TweenService:Create(CreateTemplate, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, -0.038, 110)}):Play()
        wait(0.9)
        TweenService:Create(TemplateIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        task.wait(0.1)
        TweenService:Create(TemplateTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(0.1)
        TweenService:Create(TemplateContent, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()

        wait(NotificationSettings.Duration or 5)

        TweenService:Create(TemplateContent, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        task.wait(0.1)
        TweenService:Create(TemplateTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        wait(0.1)
        TweenService:Create(TemplateIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        wait(0.4)
        Blur:UnbindFrame(CreateTemplate.BlurFrame)
        blurlight:Destroy()
        wait(0.03)
        TweenService:Create(CreateTemplate, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0.916, 0, -0.061, 110)}):Play()
        TweenService:Create(CreateTemplate, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()

        wait(0.8)
        CreateTemplate:Destroy()
    end)
end

function BootOvis()

    DestroyCurrentOvis()

    local Blur = Instance.new("BlurEffect")
    Blur.Name = "OvisBlur"
    Blur.Parent = game.Lighting
    Blur.Size = 0
    
    if Ovis.Enabled == false then
        warn("Ovis enable failed")
        wait(0.4)
        Ovis:Destroy()
        return
    end

    Sidebar.BackgroundTransparency = 1
    Sidebar.Size = UDim2.new(0, 40, 0, 330)
    Sidebar.Position = UDim2.new(0, -50, 0.5, 0)
    Sidebar.UIStroke.Transparency = 1
    Sidebar.Buttons.Position = UDim2.new(0, -50, 0, 0)

    Sidebar.Buttons.Home.Position = UDim2.new(0.5, -50, 0, 70)
    Sidebar.Buttons.Home.BackgroundTransparency = 1
    Sidebar.Buttons.Home.UIStroke.Transparency = 1
    Sidebar.Buttons.Home.Icon.ImageTransparency = 1

    Sidebar.Buttons.Character.Position = UDim2.new(0.5, -50, 0, 111)
    Sidebar.Buttons.Character.BackgroundTransparency = 1
    Sidebar.Buttons.Character.UIStroke.Transparency = 1
    Sidebar.Buttons.Character.Icon.ImageTransparency = 1

    Sidebar.Buttons.Scripting.Position = UDim2.new(0.5, -50, 0, 151)
    Sidebar.Buttons.Scripting.BackgroundTransparency = 1
    Sidebar.Buttons.Scripting.UIStroke.Transparency = 1
    Sidebar.Buttons.Scripting.Icon.ImageTransparency = 1

    Sidebar.Buttons.Settings.Position = UDim2.new(0.5, -50, 0, 191)
    Sidebar.Buttons.Settings.BackgroundTransparency = 1
    Sidebar.Buttons.Settings.UIStroke.Transparency = 1
    Sidebar.Buttons.Settings.Icon.ImageTransparency = 1

    Sidebar.Toggle.ImageTransparency = 1
    Sidebar.Time.TextTransparency = 1
    Sidebar.ClipsDescendants = true


    if game:IsLoaded() or OVIS_LOADED == true then
        local GetSidebarSound = Instance.new("Sound")
        GetSidebarSound.Parent = Ovis
        GetSidebarSound.SoundId = OvisSettings.StartupSound
        GetSidebarSound.Volume = OvisSettings.StartupSoundVolume
        GetSidebarSound.PlayOnRemove = true
        GetSidebarSound:Destroy()

        TweenService:Create(Sidebar, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Sidebar, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 20, 0.5, 0)}):Play()
        TweenService:Create(Sidebar, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 60, 0, 350)}):Play()
        TweenService:Create(Sidebar.Buttons, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.6)
        TweenService:Create(Sidebar.Time, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        wait(0.4)
        TweenService:Create(Sidebar.Buttons.Home, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 70)}):Play()
        TweenService:Create(Sidebar.Buttons.Home, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Home.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Home.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.25)
        TweenService:Create(Sidebar.Buttons.Character, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 111)}):Play()
        TweenService:Create(Sidebar.Buttons.Character, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Character.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Character.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.15)
        TweenService:Create(Sidebar.Buttons.Scripting, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 151)}):Play()
        TweenService:Create(Sidebar.Buttons.Scripting, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Scripting.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Scripting.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.15)
        TweenService:Create(Sidebar.Buttons.Settings, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 191)}):Play()
        TweenService:Create(Sidebar.Buttons.Settings, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Settings.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
        TweenService:Create(Sidebar.Buttons.Settings.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.25)
        TweenService:Create(Sidebar.Toggle, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    end

    -- All of the sidebar button function will be inside

    Sidebar.Toggle.MouseEnter:Connect(function()
        TweenService:Create(Sidebar.Toggle, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Rotation = 360}):Play()
    end)

    Sidebar.Toggle.MouseLeave:Connect(function()
        TweenService:Create(Sidebar.Toggle, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Rotation = 0}):Play()
    end)

    for _, buttons in pairs(Sidebar.Buttons:GetDescendants()) do
        if buttons.ClassName == "Frame" then
            buttons.Interact.MouseEnter:Connect(function()
                Hovering = true

                TweenService:Create(buttons, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 32, 0, 32)}):Play()
                TweenService:Create(buttons.UIGradient, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
                TweenService:Create(buttons.UIStroke, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
            end)

            buttons.Interact.MouseLeave:Connect(function()
                Hovering = false

                TweenService:Create(buttons, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 33, 0, 33)}):Play()
                TweenService:Create(buttons.UIGradient, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Rotation = 55}):Play()
                TweenService:Create(buttons.UIStroke, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
            end)
        end
    end

    for _, buttons in pairs(Sidebar.Buttons:GetDescendants()) do
        if buttons.ClassName == "Frame" then
            buttons.Interact.MouseButton1Click:Connect(function()
                ButtonDebounce = true
                if not Hovering == true then
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 30, 0, 30)}):Play()
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
                    TweenService:Create(buttons.UIStroke, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
                    wait(0.1)
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 33, 0, 33)}):Play()
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 21, 0, 21)}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
                    TweenService:Create(buttons.UIStroke, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
                else
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 29, 0, 29)}):Play()
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
                    wait(0.1)
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 32, 0, 32)}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
                    TweenService:Create(buttons.Icon, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 21, 0, 21)}):Play()
                    TweenService:Create(buttons, TweenInfo.new(0.23, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
                end
                ButtonDebounce = false
            end)
        end

    end
end

function OpenHome()
    if not HomeDebounce then
        HomeOpen = true
        HomeDebounce = true
    end

    Home.BackgroundTransparency = 1
    Home.Visible = true
    -- Intrduce
    Home.Introduce.Position = UDim2.new(1, 0, 0, 26)
    Home.Introduce.BackgroundTransparency = 1
    Home.Introduce.Logo.ImageTransparency = 1
    Home.Introduce.Subtitle.TextTransparency = 1
    Home.Introduce.Title.TextTransparency = 1
    -- Introduce Settings
    Home.Introduce.Subtitle.Text = "Howdy, "..game.Players.LocalPlayer.DisplayName
    -- Discord
    Home.Discord.Title.TextTransparency = 1
    Home.Discord.BackgroundTransparency = 1
    Home.Discord.Description.TextTransparency = 1
    Home.Discord.Join.ImageTransparency = 1
    Home.Discord.Position = UDim2.new(1, 0, 0, 26)
    -- Discord Settings
    Home.Discord.Join.MouseButton1Click:Connect(function()
        local InviteLink = "https://discord.gg/RYbTrcvcHQ"
        local Split = string.split(InviteLink, ".gg/")
        local InviteCode = Split[2]

        local http_request = http_request or request or (syn and syn.request) or (http and http.request)
        http_request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = game:GetService("HttpService"):JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {
                    code = InviteCode
                },
                nonce = game:GetService("HttpService"):GenerateGUID(false)
            }),
        })
        OvisUI:Notify({Title = "Joining Discord...", Content = "Open up your Discord and click the join button, welcome to Ovis.", Duration = 6})
    end)
    Home.Discord.Join.MouseEnter:Connect(function()
        TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0.3}):Play()
        TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 269, 0, 119)}):Play()
    end)
    Home.Discord.Join.MouseLeave:Connect(function()
        TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 282, 0, 126)}):Play()
    end)
    -- Gane
    Home.Game.Position = UDim2.new(1, 0, 0, 102)
    Home.Game.BackgroundTransparency = 1
    Home.Game.Thumbnail.ImageTransparency = 1
    Home.Game.GameTitle.TextTransparency = 1
    Home.Game.Player.TextTransparency = 1
    Home.Game.FPS.TextTransparency = 1
    Home.Game.Latency.TextTransparency = 1
    -- Game Settings
    Home.Game.GameTitle.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    Home.Game.Thumbnail.Image = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=".. game.PlaceId .."&fmt=png&wd=420&ht=420"
    -- User
    Home.User.Position = UDim2.new(1, 0, 0, 256)
    Home.User.Profile.ImageTransparency = 1
    Home.User.Profile.BackgroundTransparency = 1
    Home.User.Displayname.TextTransparency = 1
    Home.User.Username.TextTransparency = 1
    Home.User.BackgroundTransparency = 1
    -- User Settings
    Home.User.Displayname.Text = game.Players.LocalPlayer.DisplayName
    Home.User.Username.Text = game.Players.LocalPlayer.Name
    Home.User.Profile.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    -- Execute
    Home.Execute.Position = UDim2.new(1, 0, 0, 338)
    Home.Execute.BackgroundTransparency = 1
    Home.Execute.Executor.TextTransparency = 1
    Home.Execute.Description.TextTransparency = 1
    -- Execute Settings
    Home.Execute.Executor.Text = identifyexecutor()
    if Home.Execute.Executor.Text == "Synapse X" or Home.Execute.Executor.Text == "ScriptWare" or Home.Execute.Executor.Text == "Krnl" then
        Home.Execute.Description.Text = identifyexecutor().." is verified as our supported executor"
    else
        Home.Execute.Description.Text = "Ovis does not verified "..identifyexecutor().." as our supported executor."
    end

    TweenService:Create(Home, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(game.Lighting:FindFirstChildOfClass("BlurEffect"), TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Size = 24}):Play()

    wait(0.3)
    TweenService:Create(Home.Discord, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Home.Discord, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, -685, 0, 26)}):Play()

    wait(0.22)
    TweenService:Create(Home.Introduce, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Home.Introduce, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, -350, 0, 26)}):Play()

    wait(0.2)
    TweenService:Create(Home.Game, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Home.Game, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, -350, 0, 103)}):Play()

    wait(0.15)
    TweenService:Create(Home.User, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Home.User, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, -350, 0, 257)}):Play()

    wait(0.1)
    TweenService:Create(Home.Execute, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Home.Execute, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, -350, 0, 339)}):Play()

    TweenService:Create(Home.Introduce.Logo, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Introduce.Subtitle, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Introduce.Title, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Thumbnail, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.GameTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.FPS, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Latency, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Player, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Profile, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(Home.User.Profile, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Displayname, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Username, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
    wait(0.05)
    TweenService:Create(Home.Execute.Executor, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.05)
    TweenService:Create(Home.Execute.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()

    wait(1)

    HomeDebounce = false

end

function CloseHome()
    if not HomeDebounce then
        HomeOpen = false
        HomeDebounce = true
    end

    TweenService:Create(Home.Introduce.Logo, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Introduce.Subtitle, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Introduce.Title, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Discord.Join, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Thumbnail, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.GameTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.FPS, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Latency, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Game.Player, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Profile, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.User.Profile, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Displayname, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.User.Username, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Execute.Executor, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    wait(0.05)
    TweenService:Create(Home.Execute.Description, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

    wait(0.22)
    TweenService:Create(Home.Execute, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.Execute, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, 0, 0, 338)}):Play()
    wait(0.2)

    TweenService:Create(Home.User, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.User, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, 0, 0, 257)}):Play()

    wait(0.15)

    TweenService:Create(Home.Game, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.Game, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, 0, 0, 103)}):Play()

    wait(0.1)
    TweenService:Create(Home.Introduce, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.Introduce, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, 0, 0, 26)}):Play()

    wait(0.05)
    TweenService:Create(Home.Discord, TweenInfo.new(0.57, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Home.Discord, TweenInfo.new(0.57, Enum.EasingStyle.Back), {Position = UDim2.new(1, 0, 0, 26)}):Play()

    TweenService:Create(Home, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(game.Lighting:FindFirstChildOfClass("BlurEffect"), TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Size = 0}):Play()

    wait(0.3)

    Home.Visible = false

    wait(1)
    HomeDebounce = false

end

function HideSidebar()
    Debounce = true

    TweenService:Create(Sidebar, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0, -50, 0.5, 0)}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, 0, 340)}):Play()
    TweenService:Create(Sidebar.Time, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Home, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Home.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Home.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Character, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Character.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Character.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Settings, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Settings.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Sidebar.Buttons.Settings.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Sidebar.Toggle, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()

    wait(1)

    Sidebar.BackgroundTransparency = 1
    Sidebar.Size = UDim2.new(0, 40, 0, 330)
    Sidebar.Position = UDim2.new(0, -50, 0.5, 0)
    Sidebar.UIStroke.Transparency = 1
    Sidebar.Buttons.Position = UDim2.new(0, -50, 0, 0)

    Sidebar.Buttons.Home.Position = UDim2.new(0.5, -50, 0, 70)
    Sidebar.Buttons.Home.BackgroundTransparency = 1
    Sidebar.Buttons.Home.UIStroke.Transparency = 1
    Sidebar.Buttons.Home.Icon.ImageTransparency = 1

    Sidebar.Buttons.Character.Position = UDim2.new(0.5, -50, 0, 111)
    Sidebar.Buttons.Character.BackgroundTransparency = 1
    Sidebar.Buttons.Character.UIStroke.Transparency = 1
    Sidebar.Buttons.Character.Icon.ImageTransparency = 1

    Sidebar.Buttons.Scripting.Position = UDim2.new(0.5, -50, 0, 151)
    Sidebar.Buttons.Scripting.BackgroundTransparency = 1
    Sidebar.Buttons.Scripting.UIStroke.Transparency = 1
    Sidebar.Buttons.Scripting.Icon.ImageTransparency = 1

    Sidebar.Buttons.Settings.Position = UDim2.new(0.5, -50, 0, 191)
    Sidebar.Buttons.Settings.BackgroundTransparency = 1
    Sidebar.Buttons.Settings.UIStroke.Transparency = 1
    Sidebar.Buttons.Settings.Icon.ImageTransparency = 1

    Sidebar.Toggle.ImageTransparency = 1
    Sidebar.Time.TextTransparency = 1

    OvisUI:Notify({
        Title = "Sidebar Hidden",
        Content = "The Sidebar has been hidden, tap T to unhide the Sidebar.",
        Duration = 2
    })

    Debounce = false
end

function UnhideSidebar()
    Debounce = true
    TweenService:Create(Sidebar, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 20, 0.5, 0)}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 60, 0, 350)}):Play()
    TweenService:Create(Sidebar.Buttons, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    wait(0.6)
    TweenService:Create(Sidebar.Time, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    wait(0.4)
    TweenService:Create(Sidebar.Buttons.Home, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 70)}):Play()
    TweenService:Create(Sidebar.Buttons.Home, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Home.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Home.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.25)
    TweenService:Create(Sidebar.Buttons.Character, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 111)}):Play()
    TweenService:Create(Sidebar.Buttons.Character, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Character.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Character.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.15)
    TweenService:Create(Sidebar.Buttons.Scripting, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 151)}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Scripting.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.15)
    TweenService:Create(Sidebar.Buttons.Settings, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0, 191)}):Play()
    TweenService:Create(Sidebar.Buttons.Settings, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Settings.UIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    TweenService:Create(Sidebar.Buttons.Settings.Icon, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    wait(0.25)
    TweenService:Create(Sidebar.Toggle, TweenInfo.new(1.6, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    Debounce = false
end

BootOvis()

Sidebar.Buttons.Home.Interact.MouseButton1Click:Connect(function()
    if HomeDebounce then return end
    if HomeOpen then
        CloseHome()
    else
        OpenHome()
    end
end)

-- Core of Buttons

Sidebar.Toggle.MouseButton1Click:Connect(function()
    if game:IsLoaded() or OVIS_LOADED == true then
        Hidden = true
        HideSidebar()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        if Debounce then return end
        if Hidden == true then
            Hidden = false
            UnhideSidebar()
        else
            Hidden = true
            HideSidebar()
        end
    end
end)

game.Players.PlayerAdded:Connect(function(Player)
    if Player.Name == "Sl_ius" then
        OvisUI:Notify({Title = "Sius joined", Content = "Ovis creator, Sius (@Sl_ius) has joined your experience", Duration = 3})
    end

    if Player:IsFriendsWith(Players.LocalPlayer.UserId) then
        OvisUI:Notify({Title = "Friend Joined", Content = "Your friend, " .. Player.Name .. " has joined your experience", Duration = 3})
    end
end)

while true do
    wait(1)
    Home.Game.FPS.Text = "You are running at "..frames.." fps"
    frames = 0
    Home.Game.Latency.Text = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue().." Latency"
    Home.Game.Player.Text = tostring(#game.Players:GetChildren()).."/"..tostring(game.Players.MaxPlayers).." Players"
end
