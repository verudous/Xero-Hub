local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variables
local W = false
local W2 = false
local W3 = false
local Tween = nil
local plr = game.Players.LocalPlayer
local CbFw = getupvalues(require(plr.PlayerScripts.CombatFramework))
local CbFw2 = CbFw[2]
local Stop_Tween = false
local request_places = {}
local Auto_Farm_Level_Toggle = nil
getgenv().Team = "Pirates" -- Pirates/Marines
getgenv().Weapon_Type = "Melee"
getgenv().Weapon = nil
getgenv().Bring_Mob = true
getgenv().Auto_Farm_Level = true

-- Priority Queue
local PriorityQueue = {}
function PriorityQueue:new()
    local obj = {queue = {}}
    setmetatable(obj, self)
    self.__index = self
    return obj
end
function PriorityQueue:push(element, priority)
    table.insert(self.queue, {element = element, priority = priority})
    table.sort(self.queue, function(a, b)
        return a.priority < b.priority
    end)
end
function PriorityQueue:pop(priority)
    for i, task in ipairs(self.queue) do
        if task.priority == priority then
            return table.remove(self.queue, i)
        end
    end
end
function PriorityQueue:top()
    return self.queue[1]
end
function PriorityQueue:empty()
    return #self.queue == 0
end

-- Functions
local function UpdateWeapon()
    if getgenv().Weapon_Type ~= nil then
        for i, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                if getgenv().Weapon_Type == "Fruit" then
                    if string.find(v.ToolTip, getgenv().Weapon_Type) then
                        if v.Name == 'Ice-Ice' or v.Name == 'Light-Light' then
                            getgenv().Weapon = v.Name
                            return
                        else
                            OrionLib:MakeNotification({
                                Name = "Error",
                                Content = "Fruit must be either Ice or Light!",
                                Image = "rbxassetid://4483345998",
                                Time = 5
                            })
                        end
                    end
                else
                    if string.find(v.ToolTip, getgenv().Weapon_Type) then
                        getgenv().Weapon = v.Name
                        return
                    end
                end
            end
        end
    end
end
local function EquipWeapon(weapon)
	if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(weapon) then
		local tool = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(weapon)
		game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(tool)
	end
end
local function AddVelocity()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Xero") then
        local body = Instance.new("BodyVelocity")
        body.Name = "Xero"
        body.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
        body.MaxForce=Vector3.new(1000000000,1000000000,1000000000)
        body.Velocity=Vector3.new(0,0,0)
    end
end
local function RemoveVelocity()
    for _,v in pairs(game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):GetChildren()) do
        if v.Name == "Xero" then
            v:Destroy()
        end
    end
end
local function CheckQuest()
    local Level = game:GetService("Players").LocalPlayer.Data.Level.Value
    local NameMob = nil
    local QuestNumber = nil
    local NameQuest = nil
    local CFrameMon = nil
    local CFrameQuest = nil
    local LevelReq = -999
    local RNameMob = nil
    local Quests = require(game:GetService("ReplicatedStorage").Quests)
    local GuideModule = require(game:GetService("ReplicatedStorage").GuideModule)
    local MaxLevelReqCurrentSea = -999
    for i,v in pairs(Quests) do
        for i1,v1 in pairs(v) do
            if i ~= "CitizenQuest" and i ~= "BartiloQuest" and v1["LevelReq"] <= Level then
                for i2,v2 in pairs(v1["Task"]) do
                    if v2 ~= 1 then
                        LevelReq = math.max(LevelReq, v1["LevelReq"])
                    end
                end
            end
        end
    end
    for i,v in pairs(Quests) do
        for i1,v1 in pairs(v) do
            if i ~= "CitizenQuest" and i ~= "BartiloQuest" and v1["LevelReq"] == LevelReq then
                for i2,v2 in pairs(v1["Task"]) do
                    RNameMob = i2 .. " [Lv. ".. v1["LevelReq"] .. "]"
                    NameMob = i2
                    QuestNumber = i1
                    NameQuest = i
                end
            end
        end
    end
    for a,b in pairs(GuideModule["Data"]["NPCList"]) do
        for c,d in pairs(b["Levels"]) do
            if LevelReq == d then
                CFrameQuest = a["CFrame"]
            end
            MaxLevelReqCurrentSea = math.max(d, MaxLevelReqCurrentSea)
        end
    end
    if not CFrameMon then
        pcall(function()
            CFrameMon = CFrame.new(game:GetService("ReplicatedStorage"):FindFirstChild(NameMob).WorldPivot.Position) * CFrame.new(0, 30, 0)
        end)
    end
    if not CFrameMon then
        pcall(function()
            CFrameMon = game.Workspace.Enemies:FindFirstChild(NameMob):FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 30, 0)
        end)
    end
    if not CFrameMon then
        pcall(function()
            CFrameMon = game.Workspace._WorldOrigin:FindFirstChild("EnemySpawns"):FindFirstChild(RNameMob).CFrame * CFrame.new(0, 30, 0)
        end)
    end
    if CFrameQuest == nil then
        LevelReq = -999
        CFrameMon = nil
        for i,v in pairs(Quests) do
            for i1,v1 in pairs(v) do
                if i ~= "CitizenQuest" and i ~= "BartiloQuest" and v1["LevelReq"] <= MaxLevelReqCurrentSea then
                    for i2,v2 in pairs(v1["Task"]) do
                        if v2 ~= 1 then
                            LevelReq = math.max(LevelReq, v1["LevelReq"])
                        end
                    end
                end
            end
        end
        for i,v in pairs(Quests) do
            for i1,v1 in pairs(v) do
                if i ~= "CitizenQuest" and i ~= "BartiloQuest" and v1["LevelReq"] == LevelReq then
                    for i2,v2 in pairs(v1["Task"]) do
                        RNameMob = i2 .. " [Lv. ".. v1["LevelReq"] .. "]"
                        NameMob = i2
                        QuestNumber = i1
                        NameQuest = i
                    end
                end
            end
        end
        for a,b in pairs(GuideModule["Data"]["NPCList"]) do
            for c,d in pairs(b["Levels"]) do
                if LevelReq == d then
                    CFrameQuest = a["CFrame"]
                end
            end
        end
        if not CFrameMon then
            pcall(function()
                CFrameMon = CFrame.new(game:GetService("ReplicatedStorage"):FindFirstChild(NameMob).WorldPivot.Position) * CFrame.new(0, 30, 0)
            end)
        end
        if not CFrameMon then
            pcall(function()
                CFrameMon = game.Workspace.Enemies:FindFirstChild(NameMob):FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 30, 0)
            end)
        end
        if not CFrameMon then
            pcall(function()
                CFrameMon = game.Workspace._WorldOrigin:FindFirstChild("EnemySpawns"):FindFirstChild(RNameMob).CFrame * CFrame.new(0, 30, 0)
            end)
        end
    end
    return NameQuest, QuestNumber, CFrameQuest, NameMob, CFrameMon
end
local function CheckNearestRequestIsland(place)
    local min_distance = math.huge
    local player = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for request_place, cframe in pairs(request_places) do
        min_distance = math.min(min_distance, math.abs((place.Position - cframe.Position).Magnitude))
    end
    min_distance = math.min(min_distance, math.abs((place.Position - player.Position).Magnitude))
    for request_place, cframe in pairs(request_places) do
        if math.abs((place.Position - cframe.Position).Magnitude) == min_distance then
            return request_place
        end
    end
    return nil
end
local function NoClip()
    local character = game:GetService("Players").LocalPlayer.Character
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end
local function tween(place)
    repeat wait()
        local request_place = CheckNearestRequestIsland(place)
        if request_place ~= nil then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", request_places[request_place].Position)
        end
        local player = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Sit == true then
            game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Sit = false
        end
        AddVelocity()
        NoClip()
        local Distance = (place.Position - player.Position).Magnitude
        local speed = 300
        if Distance < 250 then
            speed = 5000
        elseif Distance < 500 then
            speed = 650
        elseif Distance < 1000 then
            speed = 350
        elseif Distance >= 1000 then
            speed = 300
        end
        local TweenService = game:GetService("TweenService")
        local start = player.Position
        local _end = place.Position
        local distance = (start - _end).Magnitude
        local _time = distance/(speed)
        local info = TweenInfo.new(
            _time,
            Enum.EasingStyle.Linear
        )
        Tween = TweenService:Create(player, info, {CFrame = place})
        Tween:Play()
        if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 then
            repeat wait(1) until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
            AddVelocity()
        end
        if Stop_Tween and Tween.PlaybackState == Enum.PlaybackState.Playing then
            Tween:Cancel()
            break
        end
    until Distance <= 10
    RemoveVelocity()
end
local function GetCurrentBlade()
    local p13 = CbFw2.activeController
    local ret = p13.blades[1]
    if not ret then return end
    while ret.Parent~=game:GetService("Players").LocalPlayer.Character do ret=ret.Parent end
    return ret
end
local function AttackNoCD()
    local AC = CbFw2.activeController
    for i = 1, 1 do
        local bladehit = require(game:GetService("ReplicatedStorage").CombatFramework.RigLib).getBladeHits(
            plr.Character,
            {plr.Character.HumanoidRootPart},
            60
        )
        local cac = {}
        local hash = {}
        for k, v in pairs(bladehit) do
            if v.Parent:FindFirstChild("HumanoidRootPart") and not hash[v.Parent] then
                table.insert(cac, v.Parent.HumanoidRootPart)
                hash[v.Parent] = true
            end
        end
        bladehit = cac
        if #bladehit > 0 then
            local u8 = debug.getupvalue(AC.attack, 5)
            local u9 = debug.getupvalue(AC.attack, 6)
            local u7 = debug.getupvalue(AC.attack, 4)
            local u10 = debug.getupvalue(AC.attack, 7)
            local u12 = (u8 * 798405 + u7 * 727595) % u9
            local u13 = u7 * 798405
            (function()
                u12 = (u12 * u9 + u13) % 1099511627776
                u8 = math.floor(u12 / u9)
                u7 = u12 - u8 * u9
            end)()
            u10 = u10 + 1
            debug.setupvalue(AC.attack, 5, u8)
            debug.setupvalue(AC.attack, 6, u9)
            debug.setupvalue(AC.attack, 4, u7)
            debug.setupvalue(AC.attack, 7, u10)
            pcall(function()
                if plr.Character:FindFirstChildOfClass("Tool") and AC.blades and AC.blades[1] then
                    AC.animator.anims.basic[1]:Play(0.01,0.01,0.01)
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(GetCurrentBlade()))
                    game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.floor(u12 / 1099511627776 * 16777215), u10)
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, i, "")
                end
            end)
        end
    end
end
local function AutoBuso()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end
local function BringMob(PosMon, NameMon)
    for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
        if v.Name == NameMon and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and (v:FindFirstChild("HumanoidRootPart").Position - PosMon.Position).Magnitude <= 1000 then
            sethiddenproperty(game:GetService("Players").LocalPlayer, "MaximumSimulationRadius",  math.huge)
            sethiddenproperty(game:GetService("Players").LocalPlayer, "SimulationRadius",  9e20)
            if v:FindFirstChild("Humanoid"):FindFirstChild("Animator") then
                v:FindFirstChild("Humanoid").Animator:Destroy()
            end
            v:FindFirstChild("Humanoid"):ChangeState(11)
            v:FindFirstChild("Humanoid").JumpPower = 0
            v:FindFirstChild("Humanoid").WalkSpeed = 0
            v:FindFirstChild("HumanoidRootPart").CanCollide = false
            v:FindFirstChild("HumanoidRootPart").CFrame = PosMon
        end
    end
end
local function AutoFarmLevel()
    if getgenv().Auto_Farm_Level and getgenv().Weapon ~= nil then
        repeat wait()
            -- pcall(function()
                if not getgenv().Auto_Farm_Level then
                    return
                end
                local NameQuest, QuestNumber, CFrameQuest, NameMob, CFrameMon = CheckQuest()
                if CFrameMon ~= nil then
                    if (CFrameMon.Position - game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position) > 1000 then
                        tween(CFrameMon)
                        if not getgenv().Auto_Farm_Level then
                            repeat wait()
                                Stop_Tween = true
                            until Tween.PlaybackState ~= Enum.PlaybackState.Playing
                            Stop_Tween = false
                            return
                        end
                        AddVelocity()
                    end
                    if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false or not game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:find(NameMob, 1, true) then
                        tween(CFrameQuest)
                        if not getgenv().Auto_Farm_Level then
                            repeat wait()
                                Stop_Tween = true
                            until Tween.PlaybackState ~= Enum.PlaybackState.Playing
                            Stop_Tween = false
                            return
                        end
                        AddVelocity()
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestNumber)
                    end
                    for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 then
                            repeat wait(1) until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
                            AddVelocity()
                        end
                        if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false or not game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:find(NameMob, 1, true) then
                            tween(CFrameQuest)
                            if not getgenv().Auto_Farm_Level then
                                repeat wait()
                                    Stop_Tween = true
                                until Tween.PlaybackState ~= Enum.PlaybackState.Playing
                                Stop_Tween = false
                                return
                            end
                            AddVelocity()
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestNumber)
                            tween(CFrameMon)
                            if not getgenv().Auto_Farm_Level then
                                repeat wait()
                                    Stop_Tween = true
                                until Tween.PlaybackState ~= Enum.PlaybackState.Playing
                                Stop_Tween = false
                                return
                            end
                            AddVelocity()
                        end
                        if v.Name == NameMob and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
                            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 then
                                repeat wait(1) until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
                                AddVelocity()
                            end
                            if getgenv().Bring_Mob then
                                local PosMon = v:FindFirstChild("HumanoidRootPart").CFrame
                                BringMob(PosMon, NameMob)
                            end
                            if not getgenv().Auto_Farm_Level then
                                RemoveVelocity()
                                return
                            end
                            repeat wait(0.1)
                                UpdateWeapon()
                                AutoBuso()
                                tween(v:FindFirstChild("HumanoidRootPart").CFrame*CFrame.new(0, 30, 0))
                                if not getgenv().Auto_Farm_Level then
                                    repeat wait()
                                        Stop_Tween = true
                                    until Tween.PlaybackState ~= Enum.PlaybackState.Playing
                                    Stop_Tween = false
                                    return
                                end
                                AddVelocity()
                                if not getgenv().Auto_Farm_Level then
                                    RemoveVelocity()
                                    return
                                end
                                if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 then
                                    repeat wait(1) until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
                                    AddVelocity()
                                end
                                EquipWeapon(getgenv().Weapon)
                                AttackNoCD()
                            until v:FindFirstChild("Humanoid").Health <= 0
                        end
                    end
                end
            -- end)
        until not getgenv().Auto_Farm_Level
    elseif getgenv().Auto_Farm_Level and getgenv().Weapon == nil then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Weapon not selected!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        Auto_Farm_Level_Toggle:Set(false)
        getgenv().Auto_Farm_Level = false
    end
end

-- Script
if not game:IsLoaded() then
    repeat game.Loaded:Wait() until game:IsLoaded()
end
-- Join Team
if getgenv().Team ~= "Pirates" and getgenv().Team ~= "Marines" then
    getgenv().Team = "Pirates"
end
if game:GetService("Players").LocalPlayer.Team == nil then
    local Button = game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container[getgenv().Team].Frame.TextButton
    for i,v in pairs(getconnections(Button.Activated)) do
        v.Function()
    end
end
-- Check Sea
if game.PlaceId == 2753915549 then
    W = true
    request_places = {
        ["Whirl Pool"] = CFrame.new(3864.6884765625, 6.736950397491455, -1926.214111328125),
        ["Sky Area 1"] = CFrame.new(-4607.82275, 872.54248, -1667.55688),
        ["Sky Area 2"] = CFrame.new(-7894.61767578125, 5547.1416015625, -380.29119873046875),
        ["Fish Man"] = CFrame.new(61163.8515625, 11.6796875, 1819.7841796875)
    }
elseif game.PlaceId == 4442272183 then
    W2 = true
    request_places = {
        ["Ghost Ship"] = CFrame.new(923.21252441406, 126.9760055542, 32852.83203125)
    }
elseif game.PlaceId == 7449423635 then
    W3 = true
    request_places = {
        ["Castle on the sea"] = CFrame.new(-5075.50927734375, 314.5155029296875, -3150.0224609375),
        ["Mansion"] = CFrame.new(-12548.998046875, 332.40396118164, -7603.1865234375),
        ["Hydra Island"] = CFrame.new(5753.5478515625, 610.7880859375, -282.33172607421875),
        ["Temple Of Time"] = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875)
    }
end

UpdateWeapon()
wait(3)
AutoFarmLevel()
