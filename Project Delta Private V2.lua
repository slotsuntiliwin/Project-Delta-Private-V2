local Decimals = 4
local Clock = os.clock()

local library = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/main/1%20Tokyo%20Lib%20(FIXED)/Tokyo%20Lib%20Source.lua'
    )
)({
    cheatname = 'Project Delta Script',
    gamename = 'by breakneckv09',
})
library:init()

local Window1 = library.NewWindow({
    title = 'Project Delta Private Script - breakneckv09',
    size = UDim2.new(0, 645, 0.6, 6),
})

local DupeTab = Window1:AddTab('  Dupe Method  ')
local CombatTab = Window1:AddTab('  Combat  ')
local VisualsTab = Window1:AddTab('  Visuals  ')
local MiscTab = Window1:AddTab('  Misc  ')
local CreditsTab = Window1:AddTab('  Credits  ')
local SettingsTab = library:CreateSettingsTab(Window1)

local DupeFuncSection = DupeTab:AddSection('Dupe Stuff:', 1)
local DupeStepsSection = DupeTab:AddSection('Dupe Guide', 2)
local AimbotSection = CombatTab:AddSection('Combat Stuff:', 1)
local AimbotSettings = CombatTab:AddSection('Combat Settings:', 2)
local VisualsSection = VisualsTab:AddSection('ESP Stuff:', 1)
local VisualsSettings = VisualsTab:AddSection('ESP Settings:', 2)
local MiscSection = MiscTab:AddSection('Visual/Player Stuff:', 1)
local SkinSection = MiscTab:AddSection('Skin Spoofer (Local):', 2)
local CreditsSection = CreditsTab:AddSection('Credits:', 1)
local Credits2Section = CreditsTab:AddSection('Suggestion Credits:', 2)

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService('TeleportService')
local Lighting = game:GetService('Lighting')
local StarterGui = game:GetService('StarterGui')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')

local fullbrightEnabled = false
local chosenFOV = 90

local lockedTarget = nil
local aimEnabled = false
local aimHoldActive = false
local useFOV = true
local teamCheck = true
local visibleCheck = true
local playerSaverEnabled = true
local savedPlayer = nil
local prediction = false
local fovRadius = 50
local strength = 0.05

local ASSUMED_BULLET_SPEED = 800
local PREDICTION_MULT = 1.0

local maxDistances = {
    enemyBox = 3000,
    enemyName = 3000,
    enemyHealth = 3000,
    enemyDistance = 3000,
    friendlyBox = 3000,
    friendlyName = 3000,
    friendlyHealth = 3000,
    friendlyDistance = 3000,
}

local function lockFirstPerson()
    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end

local function applyFOV(fov)
    if Camera then
        Camera.FieldOfView = fov
    end
end

MiscSection:AddSlider({
    enabled = true,
    text = 'FOV Changer',
    tooltip = 'Change camera FOV then click apply to set',
    flag = 'misc_fov_slider',
    suffix = '',
    dragging = false,
    focused = false,
    min = 90,
    max = 120,
    increment = 1,
    risky = false,
    callback = function(val)
        chosenFOV = val
    end,
})

MiscSection:AddButton({
    enabled = true,
    text = 'Apply FOV',
    tooltip = 'Apply the selected FOV',
    confirm = false,
    risky = false,
    callback = function()
        applyFOV(chosenFOV)
    end,
})

applyFOV(chosenFOV)

MiscSection:AddToggle({
    text = 'Fullbright',
    state = false,
    risky = false,
    tooltip = 'Forces bright lighting',
    flag = 'misc_fullbright',
    callback = function(value)
        fullbrightEnabled = value
        if fullbrightEnabled then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.new(0.4, 0.4, 0.4)
        end
    end,
})

local fovCircle
pcall(function()
    fovCircle = Drawing.new('Circle')
    fovCircle.Transparency = 0.6
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Color = Color3.new(1, 1, 1)
    fovCircle.Filled = false
    fovCircle.Visible = true
end)

RunService.RenderStepped:Connect(function()
    if fovCircle then
        local vp = Camera.ViewportSize
        fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        fovCircle.Radius = fovRadius
        fovCircle.Visible = aimEnabled and useFOV
    end
end)

local AimToggle = AimbotSection:AddToggle({
    text = 'Aimbot Enabled',
    state = false,
    flag = 'aim_enabled',
    callback = function(v)
        aimEnabled = v
    end,
}):AddBind({
    enabled = true,
    text = 'Aim Key (hold)',
    mode = 'hold',
    bind = 'Set Bind',
    flag = 'aim_hold_key',
    state = false,
    nomouse = false,
    noindicator = false,
    callback = function(isHeld)
        aimHoldActive = isHeld
    end,
})

AimbotSection:AddToggle({
    text = 'Use FOV',
    state = true,
    flag = 'aim_use_fov',
    callback = function(v)
        useFOV = v
        if fovCircle then
            fovCircle.Visible = aimEnabled and v
        end
    end,
})

AimbotSection:AddToggle({
    text = 'Team Check',
    state = true,
    flag = 'aim_team_check',
    callback = function(v)
        teamCheck = v
    end,
})

AimbotSection:AddToggle({
    text = 'Visible Check',
    state = true,
    flag = 'aim_visible_check',
    callback = function(v)
        visibleCheck = v
    end,
})

AimbotSection:AddToggle({
    text = 'Sticky Aim',
    state = true,
    flag = 'aim_player_saver',
    callback = function(v)
        playerSaverEnabled = v
        if not playerSaverEnabled then
            savedPlayer = nil
        end
    end,
})

AimbotSection:AddToggle({
    text = 'Prediction (Beta)',
    state = false,
    flag = 'aim_prediction',
    callback = function(v)
        prediction = v
    end,
})

AimbotSettings:AddSlider({
    enabled = true,
    text = 'FOV Radius',
    tooltip = 'Use this to change the fov radius',
    flag = 'aim_fov_radius',
    min = 50,
    max = 400,
    increment = 1,
    callback = function(v)
        fovRadius = v
    end,
})

AimbotSettings:AddSlider({
    enabled = true,
    text = 'Strength',
    tooltip = 'Use this to adjust the strength of the aimbot',
    flag = 'aim_strength',
    min = 0.05,
    max = 1.0,
    increment = 0.01,
    callback = function(v)
        strength = math.clamp(v, 0.05, 1.0)
    end,
})

local savedSlots = {}
local MAX_SLOTS = 3

AimbotSection:AddButton({
    enabled = true,
    text = 'Anti Recoil',
    tooltip = 'Removes recoil completely for all guns',
    confirm = false,
    risky = false,
    callback = function()
        if #savedSlots > 0 then
            return
        end

        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local PlayersFolder = ReplicatedStorage:FindFirstChild('Players')
        if not PlayersFolder then
            return
        end

        local localPlayerNode = PlayersFolder:FindFirstChild(LocalPlayer.Name)
        if not localPlayerNode then
            return
        end

        local Inventory = localPlayerNode:FindFirstChild('Inventory')
        if not Inventory then
            return
        end

        local foundCount = 0

        for _, item in pairs(Inventory:GetChildren()) do
            if foundCount >= MAX_SLOTS then
                break
            end

            if
                item:IsA('StringValue') and item:FindFirstChild('Attachments')
            then
                local attachmentsFolder = item.Attachments
                local doneForThisItem = false

                for _, subFolder in pairs(attachmentsFolder:GetChildren()) do
                    if doneForThisItem or foundCount >= MAX_SLOTS then
                        break
                    end

                    if subFolder:IsA('Folder') then
                        for _, strVal in pairs(subFolder:GetChildren()) do
                            if doneForThisItem or foundCount >= MAX_SLOTS then
                                break
                            end

                            if
                                strVal:IsA('StringValue')
                                and strVal:FindFirstChild('ItemProperties')
                            then
                                local itemProps =
                                    strVal.ItemProperties:FindFirstChild(
                                        'Attachment'
                                    )
                                if itemProps then
                                    local ok, current = pcall(function()
                                        return itemProps:GetAttribute('Recoil')
                                    end)
                                    if ok then
                                        local s, err = pcall(function()
                                            itemProps:SetAttribute(
                                                'Recoil',
                                                -999
                                            )
                                        end)
                                        if s then
                                            table.insert(savedSlots, {
                                                inst = itemProps,
                                                original = current,
                                            })
                                            foundCount = foundCount + 1
                                            doneForThisItem = true
                                        else
                                        end
                                    else
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end,
})

AimbotSection:AddButton({
    enabled = true,
    text = 'Restore Recoil',
    tooltip = 'Restores the previously saved recoil for your guns',
    confirm = true,
    risky = false,
    callback = function()
        if #savedSlots == 0 then
            return
        end

        for _, slot in ipairs(savedSlots) do
            local inst = slot.inst
            local original = slot.original

            if inst and inst.Parent then
                pcall(function()
                    if original == nil then
                        inst:SetAttribute('Recoil', nil)
                    else
                        inst:SetAttribute('Recoil', original)
                    end
                end)
            end
        end

        savedSlots = {}
    end,
})

local function isTeammate(plr)
    if not teamCheck then
        return false
    end
    if not LocalPlayer.Team or not plr.Team then
        return false
    end
    return plr.Team == LocalPlayer.Team
end

local function isCharacterVisible(char)
    if not visibleCheck then
        return true
    end
    local head = char and char:FindFirstChild('Head')
    if not head then
        return false
    end

    local origin = Camera.CFrame.Position
    local dir = (head.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    params.FilterDescendantsInstances =
        { LocalPlayer.Character or workspace.Ignore }

    local result = workspace:Raycast(origin, dir, params)
    if not result then
        return true
    end
    return result.Instance and result.Instance:IsDescendantOf(char)
end

local function screenDistanceToCenter(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    if not onScreen then
        return math.huge
    end
    local center =
        Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local pos2d = Vector2.new(screenPos.X, screenPos.Y)
    return (pos2d - center).Magnitude
end

local function getClosestTargetHead()
    -- 1) If Player Saver enabled, try to return saved player (if still valid)
    if playerSaverEnabled and savedPlayer then
        local sp = savedPlayer
        if
            sp ~= LocalPlayer
            and sp.Character
            and sp.Character:FindFirstChild('Head')
            and sp.Character:FindFirstChild('Humanoid')
            and sp.Character.Humanoid.Health > 0
        then
            if not isTeammate(sp) then
                local head = sp.Character.Head
                local dist2center = screenDistanceToCenter(head.Position)

                if
                    (not useFOV or dist2center <= fovRadius)
                    and (not visibleCheck or isCharacterVisible(sp.Character))
                then
                    return head
                end
            end
        end
        -- saved player not valid / cannot be locked to -> forget them
        savedPlayer = nil
    end

    -- 2) Otherwise perform the normal nearest-in-FOV selection
    local bestHead = nil
    local bestDist = math.huge
    local bestPlayer = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if
            plr ~= LocalPlayer
            and plr.Character
            and plr.Character:FindFirstChild('Head')
            and plr.Character:FindFirstChild('Humanoid')
            and plr.Character.Humanoid.Health > 0
        then
            if not isTeammate(plr) then
                local head = plr.Character.Head
                local dist2center = screenDistanceToCenter(head.Position)

                if not useFOV or dist2center <= fovRadius then
                    if
                        not visibleCheck or isCharacterVisible(plr.Character)
                    then
                        if dist2center < bestDist then
                            bestDist = dist2center
                            bestHead = head
                            bestPlayer = plr
                        end
                    end
                end
            end
        end
    end

    local function findBestCandidatePlayer()
        local bestPlayer = nil
        local bestDist = math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if
                plr ~= LocalPlayer
                and plr.Character
                and plr.Character:FindFirstChild('Head')
                and plr.Character:FindFirstChild('Humanoid')
                and plr.Character.Humanoid.Health > 0
            then
                if not isTeammate(plr) then
                    local head = plr.Character.Head
                    local dist2center = screenDistanceToCenter(head.Position)

                    if not useFOV or dist2center <= fovRadius then
                        if
                            not visibleCheck
                            or isCharacterVisible(plr.Character)
                        then
                            if dist2center < bestDist then
                                bestDist = dist2center
                                bestPlayer = plr
                            end
                        end
                    end
                end
            end
        end

        return bestPlayer
    end

    -- RenderStepped aim loop: pick the target once when key is pressed and hold it until key release
    RunService.RenderStepped:Connect(function()
        if not aimEnabled then
            return
        end

        -- if not holding the aim key, clear locked target and do nothing
        if not aimHoldActive then
            lockedTarget = nil
            return
        end

        -- At this point: aimEnabled == true and aimHoldActive == true (holding)
        -- If we don't have a locked target yet, pick one now using the normal selection rules
        if not lockedTarget then
            lockedTarget = findBestCandidatePlayer()
            -- if no candidate found, just return and try again next frame
            if not lockedTarget then
                return
            end
        end

        -- If lockedTarget exists, ensure it's still valid (alive + has head). If not, clear it (so we can pick a new one while still holding)
        if
            not lockedTarget
            or not lockedTarget.Character
            or not lockedTarget.Character:FindFirstChild('Head')
            or not lockedTarget.Character:FindFirstChild('Humanoid')
            or lockedTarget.Character.Humanoid.Health <= 0
        then
            lockedTarget = nil
            return
        end

        -- Aim at the locked target's head regardless of FOV / visibility / team changes
        local head = lockedTarget.Character.Head
        local targetPos = getPredictedPosition(head) -- uses prediction toggle & simple lead if enabled

        if not Camera then
            return
        end

        local currentCF = Camera.CFrame
        local desiredCF = CFrame.new(currentCF.Position, targetPos)

        Camera.CFrame =
            currentCF:Lerp(desiredCF, math.clamp(strength, 0.05, 1.0))
    end)

    -- 3) If we found a new target and Player Saver is enabled, save that player for future priority
    if playerSaverEnabled and bestHead and bestPlayer then
        savedPlayer = bestPlayer
    end

    return bestHead
end

local function getPredictedPosition(head)
    if not prediction then
        return head.Position
    end

    local hrp = head.Parent and head.Parent:FindFirstChild('HumanoidRootPart')
    if not hrp then
        return head.Position
    end

    local origin = Camera.CFrame.Position
    local toTarget = (head.Position - origin)
    local distance = toTarget.Magnitude
    local tLead = (distance / ASSUMED_BULLET_SPEED) * PREDICTION_MULT

    return head.Position + (hrp.Velocity * tLead)
end

RunService.RenderStepped:Connect(function()
    if not aimEnabled or not aimHoldActive then
        return
    end
    if not Camera then
        return
    end

    local head = getClosestTargetHead()
    if not head then
        return
    end

    local targetPos = getPredictedPosition(head)

    local currentCF = Camera.CFrame
    local desiredCF = CFrame.new(currentCF.Position, targetPos)

    Camera.CFrame = currentCF:Lerp(desiredCF, math.clamp(strength, 0.05, 1.0))
end)

local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
Sense.Load()

local enemyToggles = {
    box3d = false,
    name = false,
    healthBar = false,
    tracer = false,
    tracerOrigin = 'Bottom',
    distance = false,
}

local friendlyToggles = {
    box3d = false,
    name = false,
    healthBar = false,
    tracer = false,
    tracerOrigin = 'Bottom',
    distance = false,
}

local function updateEnemySettings()
    local anyEnabled = false
    for _, v in pairs(enemyToggles) do
        if v then
            anyEnabled = true
            break
        end
    end
    Sense.teamSettings.enemy.enabled = anyEnabled
    Sense.teamSettings.enemy.box3d = enemyToggles.box3d
    Sense.teamSettings.enemy.name = enemyToggles.name
    Sense.teamSettings.enemy.tracer = enemyToggles.tracer
    Sense.teamSettings.enemy.healthBar = enemyToggles.healthBar
    Sense.teamSettings.enemy.distance = enemyToggles.distance
end

local function updateFriendlySettings()
    local anyEnabled = false
    for _, v in pairs(friendlyToggles) do
        if v then
            anyEnabled = true
            break
        end
    end
    Sense.teamSettings.friendly.enabled = anyEnabled
    Sense.teamSettings.friendly.box3d = friendlyToggles.box3d
    Sense.teamSettings.friendly.name = friendlyToggles.name
    Sense.teamSettings.friendly.tracer = friendlyToggles.tracer
    Sense.teamSettings.friendly.healthBar = friendlyToggles.healthBar
    Sense.teamSettings.friendly.distance = friendlyToggles.distance
end

VisualsSection:AddToggle({
    text = 'Enemy 3D Box ESP',
    state = false,
    flag = 'esp_enemy_box3d',
    callback = function(enabled)
        enemyToggles.box3d = enabled
        updateEnemySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Enemy Name ESP',
    state = false,
    flag = 'esp_enemy_name',
    callback = function(enabled)
        enemyToggles.name = enabled
        updateEnemySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Enemy Health ESP',
    state = false,
    flag = 'esp_enemy_health',
    callback = function(enabled)
        enemyToggles.healthBar = enabled
        updateEnemySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Enemy Distance ESP',
    state = false,
    flag = 'esp_enemy_distance',
    callback = function(enabled)
        enemyToggles.distance = enabled
        updateEnemySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Enemy Tracer (Bottom)',
    state = false,
    flag = 'esp_enemy_tracer',
    callback = function(enabled)
        enemyToggles.tracer = enabled
        updateEnemySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Enemy Offscreen Arrow ESP',
    state = false,
    flag = 'esp_enemy_offscreen',
    callback = function(enabled)
        Sense.teamSettings.enemy.offScreenArrow = enabled
        updateEnemySettings()
    end,
})

VisualsSection:AddSeparator({ enabled = true, text = '—— Friendly ——' })
VisualsSection:AddToggle({
    text = 'Friendly 3D Box ESP',
    state = false,
    flag = 'esp_friendly_box3d',
    callback = function(enabled)
        friendlyToggles.box3d = enabled
        updateFriendlySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Friendly Name ESP',
    state = false,
    flag = 'esp_friendly_name',
    callback = function(enabled)
        friendlyToggles.name = enabled
        updateFriendlySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Friendly Health ESP',
    state = false,
    flag = 'esp_friendly_health',
    callback = function(enabled)
        friendlyToggles.healthBar = enabled
        updateFriendlySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Friendly Distance ESP',
    state = false,
    flag = 'esp_friendly_distance',
    callback = function(enabled)
        friendlyToggles.distance = enabled
        updateFriendlySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Friendly Tracer (Bottom)',
    state = false,
    flag = 'esp_friendly_tracer',
    callback = function(enabled)
        friendlyToggles.tracer = enabled
        updateFriendlySettings()
    end,
})
VisualsSection:AddToggle({
    text = 'Friendly Offscreen Arrow ESP',
    state = false,
    flag = 'esp_friendly_offscreen',
    callback = function(enabled)
        Sense.teamSettings.friendly.offScreenArrow = enabled
        updateFriendlySettings()
    end,
})

VisualsSettings:AddSlider({
    enabled = true,
    text = 'Offscreen Arrow Size',
    tooltip = 'Adjust offscreen arrow size',
    flag = 'esp_arrow_size',
    min = 5,
    max = 30,
    increment = 1,
    callback = function(value)
        Sense.teamSettings.enemy.offScreenArrowSize = value
        Sense.teamSettings.friendly.offScreenArrowSize = value
    end,
})
VisualsSettings:AddSlider({
    enabled = true,
    text = 'Offscreen Arrow Radius',
    tooltip = 'Adjust offscreen arrow circle radius',
    flag = 'esp_arrow_radius',
    min = 50,
    max = 300,
    increment = 5,
    callback = function(value)
        Sense.teamSettings.enemy.offScreenArrowRadius = value
        Sense.teamSettings.friendly.offScreenArrowRadius = value
    end,
})

RunService.RenderStepped:Connect(function()
    local localChar = LocalPlayer.Character
    if not localChar or not localChar.PrimaryPart then
        return
    end
    local camPos = Camera.CFrame.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char.PrimaryPart then
                local dist = (char.PrimaryPart.Position - camPos).Magnitude
                local isEnemy = plr.Team ~= LocalPlayer.Team

                if isEnemy then
                    Sense.teamSettings.enemy.box3d = enemyToggles.box3d
                        and dist <= maxDistances.enemyBox
                    Sense.teamSettings.enemy.name = enemyToggles.name
                        and dist <= maxDistances.enemyName
                    Sense.teamSettings.enemy.healthBar = enemyToggles.healthBar
                        and dist <= maxDistances.enemyHealth
                    Sense.teamSettings.enemy.distance = enemyToggles.distance
                        and dist <= maxDistances.enemyDistance
                    Sense.teamSettings.enemy.tracer = enemyToggles.tracer
                        and dist <= maxDistances.enemyDistance
                else
                    Sense.teamSettings.friendly.box3d = friendlyToggles.box3d
                        and dist <= maxDistances.friendlyBox
                    Sense.teamSettings.friendly.name = friendlyToggles.name
                        and dist <= maxDistances.friendlyName
                    Sense.teamSettings.friendly.healthBar = friendlyToggles.healthBar
                        and dist <= maxDistances.friendlyHealth
                    Sense.teamSettings.friendly.distance = friendlyToggles.distance
                        and dist <= maxDistances.friendlyDistance
                    Sense.teamSettings.friendly.tracer = friendlyToggles.tracer
                        and dist <= maxDistances.friendlyDistance
                end
            end
        end
    end
end)

DupeFuncSection:AddButton({
    enabled = true,
    text = 'Setup Dupe',
    tooltip = 'Setup the dupe method',
    confirm = false,
    risky = false,
    callback = function()
        local playerName = LocalPlayer.Name
        local repPlayers = ReplicatedStorage:FindFirstChild('Players')
        if
            not repPlayers
            or not repPlayers:FindFirstChild(playerName)
            or not repPlayers[playerName]:FindFirstChild('Equipment')
        then
            return
        end

        local equip = repPlayers[playerName].Equipment
        local function safeFire(toolName)
            if equip:FindFirstChild(toolName) then
                pcall(function()
                    ReplicatedStorage.Remotes.ChangeFireMode:FireServer(
                        equip[toolName],
                        '\255'
                    )
                end)
            end
        end

        safeFire('DV2')
        safeFire('AnarchyTomahawk')
        safeFire('PlasmaNinjato')
        safeFire('IceAxe')
        safeFire('IceDagger')
        safeFire('Karambit')
        safeFire('Cutlass')
        safeFire('Longsword')
        safeFire('Scythe')
        safeFire('Machete')
    end,
})

DupeFuncSection:AddSeparator({ enabled = true, text = ' ' })

DupeFuncSection:AddButton({
    enabled = true,
    text = 'Server Hop',
    tooltip = 'Find a different server',
    confirm = false,
    risky = false,
    callback = function()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = ''
        local foundServer = nil

        local function getServers()
            local url = string.format(
                'https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s',
                placeId,
                cursor ~= '' and '&cursor=' .. cursor or ''
            )
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if
                        server.playing < server.maxPlayers
                        and server.id ~= game.JobId
                    then
                        table.insert(servers, server)
                    end
                end
                cursor = result.nextPageCursor or ''
            else
                cursor = ''
            end
        end

        repeat
            getServers()
        until cursor == '' or #servers > 0

        if #servers > 0 then
            foundServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(
                placeId,
                foundServer.id,
                LocalPlayer
            )
        else
        end
    end,
})

DupeFuncSection:AddButton({
    enabled = true,
    text = 'Rejoin Server',
    tooltip = 'Rejoin current server',
    confirm = false,
    risky = false,
    callback = function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end,
})

DupeFuncSection:AddBind({
    enabled = true,
    text = 'Setup Dupe Bind',
    mode = 'hold',
    bind = 'Set Bind',
    callback = function()
        local playerName = LocalPlayer.Name
        local repPlayers = ReplicatedStorage:FindFirstChild('Players')
        if
            not repPlayers
            or not repPlayers:FindFirstChild(playerName)
            or not repPlayers[playerName]:FindFirstChild('Equipment')
        then
            return
        end

        local equip = repPlayers[playerName].Equipment
        local function safeFire(toolName)
            if equip:FindFirstChild(toolName) then
                pcall(function()
                    ReplicatedStorage.Remotes.ChangeFireMode:FireServer(
                        equip[toolName],
                        '\255'
                    )
                end)
            end
        end

        safeFire('DV2')
        safeFire('AnarchyTomahawk')
        safeFire('PlasmaNinjato')
        safeFire('IceAxe')
        safeFire('IceDagger')
        safeFire('Karambit')
        safeFire('Cutlass')
        safeFire('Longsword')
        safeFire('Scythe')
        safeFire('Machete')
    end,
})

DupeFuncSection:AddBind({
    enabled = true,
    text = 'Server Hop Bind',
    mode = 'hold',
    bind = 'Set Bind',
    callback = function()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = ''
        local foundServer = nil

        local function getServers()
            local url = string.format(
                'https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s',
                placeId,
                cursor ~= '' and '&cursor=' .. cursor or ''
            )
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if
                        server.playing < server.maxPlayers
                        and server.id ~= game.JobId
                    then
                        table.insert(servers, server)
                    end
                end
                cursor = result.nextPageCursor or ''
            else
                cursor = ''
            end
        end

        repeat
            getServers()
        until cursor == '' or #servers > 0

        if #servers > 0 then
            foundServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(
                placeId,
                foundServer.id,
                LocalPlayer
            )
        else
        end
    end,
})

DupeFuncSection:AddBind({
    enabled = true,
    text = 'Rejoin Server Bind',
    mode = 'hold',
    bind = 'Set Bind',
    callback = function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end,
})

DupeStepsSection:AddSeparator({
    enabled = true,
    text = '1. Grab What U Wanna Dupe From The Vault.',
})
DupeStepsSection:AddSeparator({
    enabled = true,
    text = '2. Hit One Of The Hop Buttons Then Go Back.',
})
DupeStepsSection:AddSeparator({
    enabled = true,
    text = '3. Hit Setup Dupe Then Put Ur Items Back In.',
})
DupeStepsSection:AddSeparator({
    enabled = true,
    text = '4. Hit One Of The Hop Buttons Again.',
})
DupeStepsSection:AddSeparator({
    enabled = true,
    text = 'Grab Ur Items From The Vault And Ur Done (:',
})
DupeStepsSection:AddSeparator({
    enabled = true,
    text = "You've Officially Duped Your Items!!",
})

SkinSection:AddSeparator({
    enabled = true,
    text = '1. Hold Something Other Than The Knife.',
})
SkinSection:AddSeparator({
    enabled = true,
    text = '2. Select A Skin And Click Spoof Knife.',
})
SkinSection:AddSeparator({
    enabled = true,
    text = 'You Have A Locally Skinned Knife!!',
})

local skinChoices = {
    'Karambit',
    'Longsword',
    'Cutlass',
    'GoldenDV2',
    'IceDagger',
    'Kukri',
    'PlasmaNinjato',
}
local selectedSkin = skinChoices[1]

SkinSection:AddList({
    enabled = true,
    text = 'Select Knife Skin',
    tooltip = 'Choose your knife skin to spoof',
    selected = selectedSkin,
    multi = false,
    open = false,
    max = 6,
    values = skinChoices,
    risky = false,
    callback = function(choice)
        selectedSkin = choice
    end,
})

SkinSection:AddButton({
    enabled = true,
    text = 'Spoof Knife',
    tooltip = 'Spoofs your knife skin to the one you choose',
    confirm = false,
    risky = false,
    callback = function()
        local playerNode = ReplicatedStorage:FindFirstChild('Players')
            and ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
        if not playerNode then
            return
        end

        local equipment = playerNode:FindFirstChild('Equipment')
        if not equipment then
            return
        end

        local allowedNames = {
            'AnarchyTomahawk',
            'IceAxe',
            'Karambit',
            'Longsword',
            'Cutlass',
            'DV2',
            'GoldenDV2',
            'IceDagger',
            'Kukri',
            'PlasmaNinjato',
            'Scythe',
        }

        local knifeStringValue = nil
        for _, child in ipairs(equipment:GetChildren()) do
            if
                child:IsA('StringValue')
                and table.find(allowedNames, child.Name)
            then
                knifeStringValue = child
                break
            end
        end

        if not knifeStringValue then
            return
        end

        if
            equipment:FindFirstChild(selectedSkin)
            and equipment:FindFirstChild(selectedSkin) ~= knifeStringValue
        then
        end

        local ok, err = pcall(function()
            knifeStringValue.Name = selectedSkin
        end)
        if not ok then
        else
        end
    end,
})

CreditsSection:AddSeparator({
    enabled = true,
    text = 'UI: Tokyo Lib (FIXED) by weakhoes',
})
CreditsSection:AddSeparator({ enabled = true, text = 'ESP: Sirius Sense' })
CreditsSection:AddSeparator({ enabled = true, text = 'Script: breakneckv09' })

Credits2Section:AddSeparator({
    enabled = true,
    text = 'Prediction: @DocTorSpiele And @Lobotomite',
})
Credits2Section:AddSeparator({
    enabled = true,
    text = 'Dupe Method: @Lxwis And @Alfie',
})
Credits2Section:AddSeparator({
    enabled = true,
    text = 'Anti Recoil: @TheMentol',
})

local Time = (
    string.format('%.' .. tostring(Decimals) .. 'f', os.clock() - Clock)
)

library:SendNotification(
    ('Key Accepted Script Loaded In: ' .. tostring(Time)),
    6
)
