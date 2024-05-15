
--[[
    Setup simple GUI to test out google analytics.
]]

local mainScreenGui
local contentFrame

local leftLabelWidth = 200


local mockPlayerDescs = {
    {
        id = 12345, 
        name = "James (1)",
    },
    {
        id = 23456, 
        name = "Peter (2)",
    },
    {
        id = 34567, 
        name = "John (3)",
    },
    {
        id = 45678, 
        name = "Matthew (4)",
    },
    {
        id = 56789, 
        name = "Thomas (5)",
    },
}

local gameConfigNames = {
    "v 1.0.01",
    "v 1.0.02",
    "v 1.0.03",
    "v 1.0.04",
}

local maxNumPlayers = #mockPlayerDescs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local analytics = require(ReplicatedStorage:WaitForChild("analytics"))

local gameState = {
    playing = false,
    gameConfig = 1,
    mockPlayerDescs = {},
    gameId = 0,
}

local gameId = 0

local inGameButtonsByPlayerIndex = {}
local inGameButtons = {}
local outGameButtons = {}
local gameConfigButtons = {}

local function setButtonSelected(button, selected) 
    button.BackgroundColor3 = selected and Color3.new(0.5, 0.5, 0.5) or Color3.new(1, 1, 1)
end

local function setButtonEnabled(button, enabled)
    button.Active = enabled
    if not enabled then 
        setButtonSelected(button, false)
    end
    button.TextColor3 = enabled and Color3.new(0, 0, 0) or Color3.new(0.5, 0.5, 0.5)
end

local function updateUI()
    for playerIndex, buttons in ipairs(inGameButtonsByPlayerIndex) do
        for _, button in buttons do 
            if playerIndex <= #gameState.mockPlayerDescs then
                setButtonEnabled(button, gameState.playing)
            else
                setButtonEnabled(button, false)
            end
        end
    end
    for _, button in ipairs(inGameButtons) do
        setButtonEnabled(button, gameState.playing)
    end
    for _, button in ipairs(outGameButtons) do
        setButtonEnabled(button, not gameState.playing)
    end
    for buttonIndex, button in ipairs(gameConfigButtons) do 
        setButtonSelected(button, gameState.gameConfig == buttonIndex)
    end
end

local function addRowWithLabel(text)
    local row = Instance.new("Frame")
    row.Parent = contentFrame
    row.Size = UDim2.new(1, 0, 0, 0)
    row.Position = UDim2.new(0, 0, 0, 0)
    local layoutOrder = contentFrame.NextLayoutOrder.Value
    row.LayoutOrder = layoutOrder
    row.Name = "Row" .. tostring(contentFrame.NextLayoutOrder.Value)
    row.AutomaticSize = Enum.AutomaticSize.Y
    local bgColor
    if layoutOrder%2 == 0 then 
        bgColor = Color3.fromHex("f0f0f0") 
    else
        bgColor = Color3.fromHex("e0e0e0")
    end
    row.BackgroundColor3 = bgColor

    local uiPadding = Instance.new("UIPadding")
    uiPadding.Parent = row
    uiPadding.PaddingBottom = UDim.new(0, 5)
    uiPadding.PaddingTop = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Parent = row
    label.Size = UDim2.new(0, leftLabelWidth, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    contentFrame.NextLayoutOrder.Value = contentFrame.NextLayoutOrder.Value + 1
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0

    uiPadding = Instance.new("UIPadding")
    uiPadding.Parent = label
    uiPadding.PaddingLeft = UDim.new(0, 5)
    uiPadding.PaddingRight = UDim.new(0, 5)

    local rowContent = Instance.new("Frame")
    rowContent.Parent = row 
    rowContent.Size = UDim2.new(1, -leftLabelWidth, 0, 0)
    rowContent.Position = UDim2.new(0, leftLabelWidth, 0, 0)
    rowContent.BackgroundTransparency = 1
    rowContent.BorderSizePixel = 0

    local uiGridLayout = Instance.new("UIGridLayout")
    uiGridLayout.Parent = rowContent
    uiGridLayout.FillDirection = Enum.FillDirection.Horizontal
    uiGridLayout.Name = "uiGridLayout"
    uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiGridLayout.CellSize = UDim2.new(0, 200, 0, 30)

    local intValue = Instance.new("IntValue")
    intValue.Parent = rowContent
    intValue.Value = 0
    intValue.Name = "NextLayoutOrder"
    return rowContent
end

local function addButton(row, text, callback)
    local button = Instance.new("TextButton")
    button.Parent = row
    button.Size = UDim2.new(0, 0, 1, 0)
    button.AutomaticSize = Enum.AutomaticSize.X
    button.Position = UDim2.new(0, 0, 0, 0)
    button.Text = text
    button.TextSize = 14
    button.LayoutOrder = row.NextLayoutOrder.Value
    row.NextLayoutOrder.Value = row.NextLayoutOrder.Value + 1
    button.MouseButton1Click:Connect(callback)
    button.BorderSizePixel = 3
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = button
    uiCorner.CornerRadius = UDim.new(0, 4)

    return button
end

local function addStartStopControls()
    local rowContent = addRowWithLabel("Start Game")
    for i = 2, maxNumPlayers do 
        local button = addButton(rowContent, string.format("Start %d Player Game", i), function()
            gameState.playing = true
            gameState.mockPlayerDescs = {}
            for _ = 1, i do
                table.insert(gameState.mockPlayerDescs, mockPlayerDescs[i])
            end
            gameState.endTime = nil
            gameState.gameId = "gameId_" .. tostring(os.time())
            gameId = gameId + 1
            gameState.actionCount = 0
            
            analytics.recordGameStart(gameState.gameId, gameState.gameConfig, gameState.mockPlayerDescs)

            updateUI()
        end)
        table.insert(outGameButtons, button)
        button.Name = string.format("Start%dPlayerGameButton", i)
    end

    rowContent = addRowWithLabel("End Game")
    local winButton = addButton(rowContent, "End Game (Win)", function()
        gameState.playing = false
        gameState.endTime = os.time()
        analytics.recordGameEnd(true)
        updateUI()
    end)
    table.insert(inGameButtons, winButton)

    local lossButton = addButton(rowContent, "End Game (Loss)", function()
        gameState.playing = false
        gameState.endTime = os.time()
        analytics.recordGameEnd(false)
        updateUI()
    end)
    table.insert(inGameButtons, lossButton)
end

local function addGameConfigControls()
    local rowContent = addRowWithLabel("Game Config")
    for i, gameConfigName in ipairs(gameConfigNames) do
        local button = addButton(rowContent, gameConfigName, function()
            gameState.gameConfig = i
            updateUI()
            end)
        table.insert(outGameButtons, button)
        table.insert(gameConfigButtons, button)
    end
end

local function addPlayerControls(playerIndex)
    local rowContent = addRowWithLabel(string.format("Player %d Actions", playerIndex))
    local numActions = 3
    for i = 1, numActions do
        local button = addButton(rowContent, string.format("Action %d", i), function()
            gameState.actionCount = gameState.actionCount + 1
            analytics.recordAction(i, gameState.mockPlayerDescs[playerIndex].id)
        end)
        if not inGameButtonsByPlayerIndex[playerIndex] then
            inGameButtonsByPlayerIndex[playerIndex] = {}
        end
        table.insert(inGameButtonsByPlayerIndex[playerIndex], button)
    end
end

local function turnOffPlayerControls()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
end

local function addMainGui()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Parent = script.Parent
    mainScreenGui.Name = "MainScreenGui"
    mainScreenGui.IgnoreGuiInset = true

    contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainScreenGui
    contentFrame.AnchorPoint = Vector2.new(0, 1)
    contentFrame.Position = UDim2.new(0, 0, 1, 0)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.BackgroundColor3 = Color3.fromHex("000")
    contentFrame.BackgroundTransparency = 1
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Name = "ContentFrame"

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = contentFrame
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Name = "uiListLayout"

    local intValue = Instance.new("IntValue")
    intValue.Parent = contentFrame
    intValue.Name = "NextLayoutOrder"

    addStartStopControls()
    addGameConfigControls()
    for i = 1, maxNumPlayers do
        addPlayerControls(i)
    end
    updateUI()
end

turnOffPlayerControls()
addMainGui()
