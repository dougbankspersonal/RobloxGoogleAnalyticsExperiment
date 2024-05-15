local analytics = {}

local cachedGameId
local cachedActionCount
local cachedStartTime 

analytics.recordGameStart = function(gameId, gameConfig, mockPlayerDescs)
    cachedGameId = gameId
    cachedActionCount = 0
    cachedStartTime = os.time()
    print("Send to analytics: game start")
    print("  cachedGameId = ", cachedGameId)
    print("  cachedActionCount = ", cachedActionCount)
    print("  cachedStartTime = ", cachedStartTime)
    print("  gameConfig = ", gameConfig)
    print("  numPlayers = ", #mockPlayerDescs)
end

analytics.recordGameEnd = function(outcome)
    local endTime = os.time()

    local totalTimeInSeconds = endTime - cachedStartTime

    print("Send to analytics: game start")
    print("  cachedGameId = ", cachedGameId)
    print("  cachedActionCount = ", cachedActionCount)
    print("  totalTimeInSeconds = ", totalTimeInSeconds)
    print("  outcome = ", outcome)
end

analytics.recordAction = function(actionType, playerId)
    cachedActionCount = cachedActionCount + 1
    print("Send to analytics: game action")
    print("  cachedGameId = ", cachedGameId)
    print("  cachedActionCount = ", cachedActionCount)
    print("  playerId = ", playerId)
    print("  actionType = ", actionType)
end

return analytics