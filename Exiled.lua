if getgenv().cuppink then warn("CupPibk Hub : Already executed!") return end
getgenv().cuppink = true

local DevMode = false

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local DeviceType = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"
if DeviceType == "Mobile" then
    local ClickButton = Instance.new("ScreenGui")
    local ImageButton = Instance.new("ImageButton");
    local UICorner = Instance.new("UICorner");

    ClickButton.Name = "ClickButton"
    ClickButton.Parent = game.CoreGui
    ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ImageButton.Parent = ClickButton
    ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
    ImageButton.BackgroundTransparency = 0.8
    ImageButton.Position = UDim2.new(0.9,0,0.1,0)
    ImageButton.Size = UDim2.new(0,50,0,50)
    ImageButton.Image = "rbxassetid://119937569996752"
    ImageButton.Draggable = true;
    ImageButton.Transparency = 1;
    UICorner.CornerRadius = UDim.new(0,200);
    UICorner.Parent = ImageButton;

    ImageButton.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
    end)
end

local function playCupPinkSound()
    local CupPinkSound = Instance.new("Sound")
    CupPinkSound.SoundId = "rbxassetid://9042908073"
    CupPinkSound.Volume = 0.5
    CupPinkSound.Looped = false
    CupPinkSound.PlayOnRemove = false
    CupPinkSound.Parent = workspace
    CupPinkSound:Play()
    CupPinkSound.Ended:Connect(function()
        CupPinkSound:Destroy()
    end)
end

-- << Initialization >> --
local function initializeServices()
    return {
        Workspace = game:GetService("Workspace"),
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        GuiService = game:GetService("GuiService"),
        VirtualUser = game:GetService("VirtualUser"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        RunService = game:GetService("RunService"),
        CollectionService = game:GetService("CollectionService"),
        HttpService = game:GetService("HttpService"),
        CoreGui = game:GetService('StarterGui'),
        ContextActionService = game:GetService('ContextActionService'),
        UserInputService = game:GetService('UserInputService'),
        TeleportService = game:GetService("TeleportService"),
        Lighting = game:GetService("Lighting"),
    }
end

local function initializePlayerData(services)
    local LocalPlayer = services.Players.LocalPlayer
    return {
        LocalPlayer = LocalPlayer,
        PlayerGui = LocalPlayer.PlayerGui,
        LocalName = LocalPlayer.Name,
        LocalDisplayName = LocalPlayer.DisplayName,
        Backpack = LocalPlayer.Backpack,
        LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),
        Humanoid = LocalPlayer.Character.Humanoid,
        HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart,
        Mouse = LocalPlayer:GetMouse(),
    }
end

local Executor = identifyexecutor()
local Services = initializeServices()
local PlayerData = initializePlayerData(Services)

local RenderStepped = Services.RunService.RenderStepped
local WaitForSomeone = RenderStepped.Wait

-- // // // Variables // // // --

local Noclip = false
local SavePos = ""

game.Players.LocalPlayer.Idled:Connect(function()
    Services.VirtualUser:CaptureController()
    Services.VirtualUser:ClickButton2(Vector2.new())
end)


-- // // // Functions // // // --
function ShowNotification(String)
    Fluent:Notify({
        Title = "CupPink",
        Content = String,
        Duration = 5,
    })
end

-- // // // Loading FluentUI // // // --
local Fluent = loadstring(game:HttpGet("https://cuppinkhub.web.app/scripts/LibraryUI/FluentUI.lua"))()
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local Window = Fluent:CreateWindow({
    Title = GameName .." | CupPink - Freemium",
    SubTitle = " by Kate.",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "DarkerPink",
    MinimizeKey = Enum.KeyCode.P
})

-- // // // Tabs Gui // // // --
local Tabs = { -- https://lucide.dev/icons/
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
}

local Options = Fluent.Options

do
    --- << Home Tab >> ---
    local section = Tabs.Home:AddSection("JOIN OUR DISCORD")
    local Discord = Tabs.Home:AddButton({
        Title = "Copy Discord link",
        Description = "Join our discord!",
        Callback = function()
            setclipboard("https://discord.gg/KyfvX2HB3v")
            Fluent:Notify({
                Title = "CUPPINK",
                Content = "Successfully copied Discord linkใ",
                Duration = 5
            })
        end
    })

    --- << Main Tab >> ---
    local FulbrightVisual = Tabs.Main:AddToggle("FulbrightVisual", {Title = "Full Bright", Default = false })
    FulbrightVisual:OnChanged(function(Value)
        Options.FulbrightVisual.Value = Value
        spawn(function()
            while Options.FulbrightVisual.Value == true do task.wait()
                if Options.FulbrightVisual.Value then
                    game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                    game:GetService("Lighting").Brightness = 10
                    game:GetService("Lighting").FoggyAtmosphere.Density = 0
                else
                    game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70)
                    game:GetService("Lighting").Brightness = 0.5
                    game:GetService("Lighting").FoggyAtmosphere.Density = 0.8
                end
            end
        end)
    end)

    local CollectItem = Tabs.Main:AddButton({
        Title = "Collect Item",
        Callback = function()
            local worldFolder = game.Workspace:FindFirstChild("Debris")
            if not worldFolder then
                warn("world folder not found in Workspace")
                return
            end
            local oldpos = PlayerData.HumanoidRootPart.CFrame
            local offset = Vector3.new(0, 1, 0)
            for _, item in pairs(worldFolder:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    local ProximityPrompt = item.Handle.ProximityPrompt
                    PlayerData.HumanoidRootPart:PivotTo(item:GetPivot() + offset)
                    ProximityPrompt.RequiresLineOfSight = false
                    ProximityPrompt.HoldDuration = 0
                    task.wait(0.3)
                    ProximityPrompt:InputHoldBegin()
                    Services.RunService.Heartbeat:Wait(0.1)
                    ProximityPrompt:InputHoldEnd()
                    task.wait(0.5)
                    --PlayerData.HumanoidRootPart.CFrame = oldpos
                    PlayerData.HumanoidRootPart:PivotTo(workspace.Wagon:GetPivot() + Vector3.new(1, 10, 1))
                end
            end
        end
    })

    local CollectCandy = Tabs.Main:AddButton({
        Title = "Collect Candy Cane",
        Callback = function()
            local worldFolder = game.Workspace:FindFirstChild("Debris")
            if not worldFolder then
                warn("world folder not found in Workspace")
                return
            end
            local oldpos = PlayerData.HumanoidRootPart.CFrame
            for _, candy in pairs(worldFolder:GetChildren()) do
                if candy:IsA("Model") and candy.Name == "Candy Cane" and candy:FindFirstChild("Handle") then
                    local ProximityPrompt = candy.Handle.ProximityPrompt
                    PlayerData.HumanoidRootPart:PivotTo(candy:GetPivot())
                    ProximityPrompt.RequiresLineOfSight = false
                    task.wait(0.3)
                    ProximityPrompt:InputHoldBegin()
                    Services.RunService.Heartbeat:Wait(0.1)
                    ProximityPrompt:InputHoldEnd()
                    task.wait(0.5)
                    PlayerData.HumanoidRootPart.CFrame = oldpos
                end
            end
        end
    })

    local CollectCandy = Tabs.Main:AddButton({
        Title = "Collect Bag of Coins",
        Callback = function()
            local worldFolder = game.Workspace:FindFirstChild("Debris")
            if not worldFolder then
                warn("world folder not found in Workspace")
                return
            end
            local oldpos = PlayerData.HumanoidRootPart.CFrame
            for _, coins in pairs(worldFolder:GetChildren()) do
                if coins:IsA("Model") and coins.Name == "Bag of Coins" and coins:FindFirstChild("Handle") then
                    local ProximityPrompt = coins.Handle.ProximityPrompt
                    PlayerData.HumanoidRootPart:PivotTo(coins:GetPivot())
                    ProximityPrompt.RequiresLineOfSight = false
                    task.wait(0.3)
                    ProximityPrompt:InputHoldBegin()
                    Services.RunService.Heartbeat:Wait(0.1)
                    ProximityPrompt:InputHoldEnd()
                    task.wait(0.5)
                    PlayerData.HumanoidRootPart.CFrame = oldpos
                end
            end
        end
    })

    local CollectCandy = Tabs.Main:AddButton({
        Title = "Buy Jar",
        Callback = function()
            for i,v in pairs(workspace.MainPath:GetDescendants()) do
                if v:IsA("Model") and v.Name == "Wanderer" then
                    Dialog = v.HumanoidRootPart.ProximityPrompt
                    Dialog.RequiresLineOfSight = false
                    Dialog.HoldDuration = 0
                    Dialog:InputHoldBegin()
                    Services.RunService.Heartbeat:Wait(0.1)
                    Dialog:InputHoldEnd()
                    game:GetService("ReplicatedStorage").Remotes.Dialog:FireServer(1)
                end
            end
        end
    })

    local CollectCandy = Tabs.Main:AddButton({
        Title = "Collect FireFly",
        Callback = function()
            for i,v in pairs(workspace.Debris:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild('Common') or v:FindFirstChild('Rare') or v:FindFirstChild('Epic') then
                    local cframeValue = v:GetPivot()
                    local x = cframeValue.Position.X
                    local y = cframeValue.Position.Y
                    local z = cframeValue.Position.Z
                    PlayerData.HumanoidRootPart:PivotTo(v:GetPivot())
                    local arguments = {
                        [1] = workspace[PlayerData.LocalPlayer.Name].Jar,
                        [2] = "Activated",
                        [3] = Vector3.new(x, y, z)
                    }
                    game:GetService("ReplicatedStorage").Remotes.Tools:FireServer(unpack(arguments))
                end
            end
        end
    })

    -- // Visuals Tab // --
    local ItemVisual = Tabs.Visuals:AddToggle("ItemVisual", {Title = "ESP Item", Default = false })    
    ItemVisual:OnChanged(function(Value)
        Options.ItemVisual.Value = Value
        spawn(function()
            while Options.ItemVisual.Value == true do task.wait()
                local CurrentCamera = Services.CurrentCamera
                for i,v in pairs(workspace.Debris:GetChildren()) do
                    if v:IsA("Tool") then
                        if Options.ItemVisual.Value then
                            if not v:FindFirstChild('ItemESP') then
                                local bill = Instance.new('BillboardGui',v)
                                bill.Name = 'ItemESP'
                                bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                bill.Size = UDim2.new(1, 200, 1, 30)
                                bill.Adornee = v
                                bill.AlwaysOnTop = true
                                local name = Instance.new('TextLabel', bill)
                                name.Font = Enum.Font.GothamBold
                                name.TextSize = 14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1, 0, 1, 0)
                                name.TextYAlignment = Enum.TextYAlignment.Top
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(255, 100, 245)
                            else
                                v['ItemESP'].TextLabel.Text = v.Name
                            end
                        else
                            if v:FindFirstChild('ItemESP') then
                                v:FindFirstChild('ItemESP'):Destroy()
                            end
                        end
                    end
                end
                for i,v in pairs(workspace.ItemsDropped:GetChildren()) do
                    if v:IsA("Tool") then
                        if Options.ItemVisual.Value then
                            if not v:FindFirstChild('ItemESP') then
                                local bill = Instance.new('BillboardGui',v)
                                bill.Name = 'ItemESP'
                                bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                bill.Size = UDim2.new(1, 200, 1, 30)
                                bill.Adornee = v
                                bill.AlwaysOnTop = true
                                local name = Instance.new('TextLabel', bill)
                                name.Font = Enum.Font.GothamBold
                                name.TextSize = 14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1, 0, 1, 0)
                                name.TextYAlignment = Enum.TextYAlignment.Top
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(255, 100, 245)
                            else
                                v['ItemESP'].TextLabel.Text = v.Name
                            end
                        else
                            if v:FindFirstChild('ItemESP') then
                                v:FindFirstChild('ItemESP'):Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end)

    local MonterVisual = Tabs.Visuals:AddToggle("MonterVisual", {Title = "ESP Monter", Default = false })    
    MonterVisual:OnChanged(function(Value)
        Options.MonterVisual.Value = Value
        spawn(function()
            pcall(function()
                while Options.MonterVisual.Value == true do task.wait()
                    local CurrentCamera = Services.CurrentCamera
                    for i,v in pairs(workspace.Debris:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            if Options.MonterVisual.Value then 
                                if not v:FindFirstChild('MonterESP') then
                                    local bill = Instance.new('BillboardGui',v)
                                    bill.Name = 'MonterESP'
                                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                    bill.Size = UDim2.new(1, 200, 1, 30)
                                    bill.Adornee = v
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new('TextLabel', bill)
                                    name.Font = Enum.Font.GothamBold
                                    name.TextSize = 14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1, 0, 1, 0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    name.TextColor3 = Color3.fromRGB(255, 0, 0)
                                else
                                    v['MonterESP'].TextLabel.Text = v.Name.. "\nHealth : " .. v.Humanoid.Health
                                end
                            else
                                if v:FindFirstChild('MonterESP') then
                                    v:FindFirstChild('MonterESP'):Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end)

    local MerchantVisual = Tabs.Visuals:AddToggle("MerchantVisual", {Title = "ESP Merchant", Default = false })    
    MerchantVisual:OnChanged(function(Value)
        Options.MerchantVisual.Value = Value
        spawn(function()
            pcall(function()
                while Options.MerchantVisual.Value == true do task.wait()
                    local CurrentCamera = Services.CurrentCamera
                    for i,v in pairs(workspace.MainPath:GetDescendants()) do
                        if v:IsA("Model") and v.Name == "Merchant" and v:FindFirstChild('HumanoidRootPart') then
                            if Options.MerchantVisual.Value then 
                                if not v:FindFirstChild('MerchantESP') then
                                    local bill = Instance.new('BillboardGui',v)
                                    bill.Name = 'MerchantESP'
                                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                    bill.Size = UDim2.new(1, 200, 1, 30)
                                    bill.Adornee = v
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new('TextLabel', bill)
                                    name.Font = Enum.Font.GothamBold
                                    name.TextSize = 14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1, 0, 1, 0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    name.TextColor3 = Color3.fromRGB(0, 255, 0)
                                else
                                    v['MerchantESP'].TextLabel.Text = v.Name
                                end
                            else
                                if v:FindFirstChild('MerchantESP') then
                                    v:FindFirstChild('MerchantESP'):Destroy()
                                end
                            end
                        end
                        if v:IsA("Model") and v.Name == "Hunter" and v:FindFirstChild('HumanoidRootPart') then
                            if Options.MerchantVisual.Value then 
                                if not v:FindFirstChild('MerchantESP') then
                                    local bill = Instance.new('BillboardGui',v)
                                    bill.Name = 'MerchantESP'
                                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                    bill.Size = UDim2.new(1, 200, 1, 30)
                                    bill.Adornee = v
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new('TextLabel', bill)
                                    name.Font = Enum.Font.GothamBold
                                    name.TextSize = 14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1, 0, 1, 0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    name.TextColor3 = Color3.fromRGB(0, 255, 0)
                                else
                                    v['MerchantESP'].TextLabel.Text = v.Name
                                end
                            else
                                if v:FindFirstChild('MerchantESP') then
                                    v:FindFirstChild('MerchantESP'):Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end)

    local WandererVisual = Tabs.Visuals:AddToggle("WandererVisual", {Title = "ESP Wanderer", Default = false })    
    WandererVisual:OnChanged(function(Value)
        Options.WandererVisual.Value = Value
        spawn(function()
            pcall(function()
                while Options.WandererVisual.Value == true do task.wait()
                    local CurrentCamera = Services.CurrentCamera
                    for i,v in pairs(workspace.MainPath:GetDescendants()) do
                        if v:IsA("Model") and v.Name == "Wanderer" then
                            if Options.WandererVisual.Value then 
                                if not v:FindFirstChild('WandererESP') then
                                    local bill = Instance.new('BillboardGui',v)
                                    bill.Name = 'WandererESP'
                                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                    bill.Size = UDim2.new(1, 200, 1, 30)
                                    bill.Adornee = v
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new('TextLabel', bill)
                                    name.Font = Enum.Font.GothamBold
                                    name.TextSize = 14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1, 0, 1, 0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    name.TextColor3 = Color3.fromRGB(0, 0, 255)
                                else
                                    v['WandererESP'].TextLabel.Text = v.Name
                                end
                            else
                                if v:FindFirstChild('WandererESP') then
                                    v:FindFirstChild('WandererESP'):Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end)

    local FireFlyVisual = Tabs.Visuals:AddToggle("FireFlyVisual", {Title = "ESP FireFly", Default = false })    
    FireFlyVisual:OnChanged(function(Value)
        Options.FireFlyVisual.Value = Value
        spawn(function()
            pcall(function()
                while Options.FireFlyVisual.Value == true do task.wait()
                    local CurrentCamera = Services.CurrentCamera
                    for i,v in pairs(workspace.Debris:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild('Common') or v:FindFirstChild('Rare') or v:FindFirstChild('Epic') then
                            if Options.FireFlyVisual.Value then 
                                if not v:FindFirstChild('FireFlyESP') then
                                    local bill = Instance.new('BillboardGui',v)
                                    bill.Name = 'FireFlyESP'
                                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                    bill.Size = UDim2.new(1, 200, 1, 30)
                                    bill.Adornee = v
                                    bill.AlwaysOnTop = true
                                    local name = Instance.new('TextLabel', bill)
                                    name.Font = Enum.Font.GothamBold
                                    name.TextSize = 14
                                    name.TextWrapped = true
                                    name.Size = UDim2.new(1, 0, 1, 0)
                                    name.TextYAlignment = Enum.TextYAlignment.Top
                                    name.BackgroundTransparency = 1
                                    name.TextStrokeTransparency = 0.5
                                    name.TextColor3 = Color3.fromRGB(0, 0, 255)
                                else
                                    v['FireFlyESP'].TextLabel.Text = "FireFly"
                                end
                            else
                                if v:FindFirstChild('FireFlyESP') then
                                    v:FindFirstChild('FireFlyESP'):Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end)

    -- // Teleports Tab // --
    local section = Tabs.Teleports:AddSection("Position Teleport")
    local TPWagon = Tabs.Teleports:AddButton({
        Title = "Wagon Teleport",
        Callback = function()
            PlayerData.HumanoidRootPart:PivotTo(workspace.Wagon:GetPivot() + Vector3.new(1, 10, 1))
        end
    })

    local SelectPosition = Tabs.Teleports:AddParagraph({
        Title = "Position : N/A"
    })
    local TeleportSavePos = Tabs.Teleports:AddButton({
        Title = "Teleport To Saved Position",
        Description = "",
        Callback = function()
            if SavePos == nil then
                Fluent:Notify({
                    Title = "CupPink",
                    Content = "No saved position found!",
                    Duration = 3
                })
                return
            else
                PlayerData.LocalCharacter:FindFirstChild("HumanoidRootPart").CFrame = SavePos
            end
        end
    })
    local CanSavePos = Tabs.Teleports:AddButton({
        Title = "Save Position",
        Description = "",
        Callback = function()
            SavePos = PlayerData.LocalCharacter:FindFirstChild("HumanoidRootPart").CFrame
            SelectPosition:SetTitle("Position : "..tostring(math.floor(PlayerData.LocalCharacter:FindFirstChild("HumanoidRootPart").Position.X)).." X "..tostring(math.floor(PlayerData.LocalCharacter:FindFirstChild("HumanoidRootPart").Position.Y)).." Y "..tostring(math.floor(PlayerData.LocalCharacter:FindFirstChild("HumanoidRootPart").Position.Z)).." Z")
        end
    })
    local ResetSavePos = Tabs.Teleports:AddButton({
        Title = "Reset Saved Position",
        Description = "",
        Callback = function()
            SavePos = nil
            SelectPosition:SetTitle("Position : N/A")
        end
    })

    -- // // // Playey Teleport // // // --
    local playerName = {}
    function getPlayers()
        playerName = {}
        for _, v in pairs(game:GetService('Players'):GetPlayers()) do
            if v.Name ~= PlayerData.LocalPlayer.Name then
                table.insert(playerName, v.Name)
            end
        end
        return playerName
    end
    getPlayers()
    table.sort(playerName)
    local TeleportToPlayer = Tabs.Teleports:AddDropdown("TeleportToPlayer", {
        Title = "Player Around Teleport",
        Values = playerName,
        Multi = false,
        Default = nil,
    })
    TeleportToPlayer:OnChanged(function(Value)
        TargetPlayer = Value
        if TargetPlayer ~= nil then
            pcall(function()
                PlayerData.HumanoidRootPart:PivotTo(game:GetService('Players')[TargetPlayer].Character:GetPivot())
            end)
            TeleportToPlayer:SetValue(nil)
        end
    end)

    local RefreshPlayer = Tabs.Teleports:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            getPlayers()
            TeleportToPlayer:SetValues(playerName)
        end
    })

    -- // Character Tab // --
    local section = Tabs.Misc:AddSection("Character")
    local WalkSpeedSliderUI = Tabs.Misc:AddSlider("WalkSpeedSliderUI", {
        Title = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Rounding = 1,
    })
    WalkSpeedSliderUI:OnChanged(function(value)
        PlayerData.Humanoid.WalkSpeed = value
    end)
    local JumpHeightSliderUI = Tabs.Misc:AddSlider("JumpHeightSliderUI", {
        Title = "Jump Height",
        Min = 50,
        Max = 200,
        Default = 50,
        Rounding = 1,
    })
    JumpHeightSliderUI:OnChanged(function(value)
        PlayerData.Humanoid.JumpPower = value
    end)

    local InfJump = Tabs.Misc:AddToggle("InfJump", {Title = "Inf. Jump", Default = false })
    InfJump:OnChanged(function()
        if Options.InfJump.Value == true then
            PlayerData.Mouse.KeyDown:connect(function(key)
                if Options.InfJump.Value then
                    if key:byte() == 32 then
                        PlayerData.Humanoid:ChangeState('Jumping')
                        wait()
                        PlayerData.Humanoid:ChangeState('Seated')
                    end
                end
            end)
        else
            
        end
    end)

    local flying = false
    local bodyVelocity, bodyGyro
    local function initialRise(character)
        local riseSpeed = 10
        local startTime = tick()
        local riseTime = 1
        while tick() - startTime < riseTime do
            bodyVelocity.Velocity = Vector3.new(0, riseSpeed, 0)
            Services.RunService.RenderStepped:Wait()
        end
    end
    local FlySpeedSlider = Tabs.Misc:AddSlider("FlySpeedSlider", {
        Title = "Fly Speed",
        Min = 15,
        Max = 100,
        Default = 50,
        Rounding = 0.1,
    })
    FlySpeedSlider:OnChanged(function(Value)
        flySpeed = Value
    end)
    local EnableFly = Tabs.Misc:AddToggle("EnableFly", {Title = "Fly", Default = false })
    EnableFly:OnChanged(function()
        if Options.EnableFly.Value == true then
            if flying then return end
            flying = true
            PlayerData.Humanoid.PlatformStand = true
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = PlayerData.HumanoidRootPart
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
            bodyGyro.CFrame = PlayerData.HumanoidRootPart.CFrame
            bodyGyro.Parent = PlayerData.HumanoidRootPart
            initialRise(PlayerData.LocalCharacter)
            Services.RunService.RenderStepped:Connect(function()
                if flying then
                    local moveDirection = PlayerData.Humanoid.MoveDirection * flySpeed
                    local camLookVector = workspace.CurrentCamera.CFrame.LookVector
                    if moveDirection.Magnitude > 0 then
                        if camLookVector.Y > 0.2 then
                            moveDirection = moveDirection + Vector3.new(0, camLookVector.Y * flySpeed, 0)
                        elseif camLookVector.Y < -0.2 then
                            moveDirection = moveDirection + Vector3.new(0, camLookVector.Y * flySpeed, 0)
                        end
                    else
                        moveDirection = Vector3.new(0, 0, 0)
                    end
                    bodyVelocity.Velocity = moveDirection
                    local tiltAngle = 30
                    local tiltFactor = moveDirection.Magnitude / flySpeed
                    local tiltDirection = 1
                    if workspace.CurrentCamera.CFrame:VectorToObjectSpace(moveDirection).Z < 0 then
                        tiltDirection = -1
                    end
                    local tiltCFrame = CFrame.Angles(math.rad(tiltAngle) * tiltFactor * tiltDirection, 0, 0)
                    local targetCFrame = CFrame.new(PlayerData.HumanoidRootPart.Position, PlayerData.HumanoidRootPart.Position + camLookVector) * tiltCFrame
                    bodyGyro.CFrame = bodyGyro.CFrame:Lerp(targetCFrame, 0.2)
                end
            end)
        else
            if not flying then return end
            flying = false
            PlayerData.Humanoid.PlatformStand = false
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end)

    Tabs.Misc:AddButton({
        Title = "Copy XYZ",
        Description = "Copy Clipboard",
        Callback = function()
            local XYZ = tostring(PlayerData.HumanoidRootPart.Position)
            setclipboard("game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(" .. XYZ .. ")")
        end
    })

    -- // Load Tab // --
    if DevMode then
        local section = Tabs.Misc:AddSection("Load Scripts For Dev")
        Tabs.Misc:AddButton({
            Title = "Load Infinite-Yield FE",
            Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end
        })
        Tabs.Misc:AddButton({
            Title = "Load Dex",
            Callback = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/BizcuitMild/scripts/main/Dex.lua'))()
            end
        })
        Tabs.Misc:AddButton({
            Title = "Load RemoteSpy",
            Callback = function()
                loadstring(game:HttpGetAsync("https://github.com/richie0866/remote-spy/releases/latest/download/RemoteSpy.lua"))()
            end
        })
    end
end

Window:SelectTab(1)
playCupPinkSound()
warn("CupPibk : Executed!")
