math.randomseed(os.time())

-- 定义网格尺寸和物品种类
local gridSize = 6
local itemTypes = 4

-- 创建一个空网格
local grid = {}

-- 填充网格并确保没有超过2个连续的相同物品
for i = 1, gridSize do
    grid[i] = {}
    for j = 1, gridSize do
        local options = {1, 2, 3, 4}

        -- 检查左边两个物品
        if j > 2 and grid[i][j-1] == grid[i][j-2] then
            for k = #options, 1, -1 do
                if options[k] == grid[i][j-1] then
                    table.remove(options, k)
                end
            end
        end

        -- 检查上边两个物品
        if i > 2 and grid[i-1][j] == grid[i-2][j] then
            for k = #options, 1, -1 do
                if options[k] == grid[i-1][j] then
                    table.remove(options, k)
                end
            end
        end

        -- 从剩余的选项中随机选择一个
        grid[i][j] = options[math.random(#options)]
    end
end

-- 打印网格状态 (用于调试)
local function printGrid(grid)
    for i = 1, gridSize do
        for j = 1, gridSize do
            io.write(grid[i][j] .. "\t")
        end
        io.write("\n")
    end
    io.write("\n")
end

-- 深度复制网格
local function copyGrid(grid)
    local newGrid = {}
    for i = 1, gridSize do
        newGrid[i] = {}
        for j = 1, gridSize do
            newGrid[i][j] = grid[i][j]
        end
    end
    return newGrid
end

-- 查找所有匹配
local function findMatches(grid)
    local matches = {}
    local matchItems = {  }
    -- 行检查
    for i = 1, gridSize do
        local j = 1
        while j <= gridSize - 2 do
            if grid[i][j] ~= 0 and math.floor(grid[i][j]) == math.floor(grid[i][j+1]) and math.floor(grid[i][j]) == math.floor(grid[i][j+2]) then
                local k = j
                while k <= gridSize and math.floor(grid[i][k]) == math.floor(grid[i][j]) do
                    table.insert(matches, {i, k, grid[i][j]})
                    k = k + 1
                end
                table.insert(matchItems, grid[i][j])
                j = k
            else
                j = j + 1
            end
        end
    end
    -- 列检查
    for j = 1, gridSize do
        local i = 1
        while i <= gridSize - 2 do
            if grid[i][j] ~= 0 and math.floor(grid[i][j]) == math.floor(grid[i+1][j]) and math.floor(grid[i][j]) == math.floor(grid[i+2][j]) then
                local k = i
                while k <= gridSize and math.floor(grid[k][j]) == math.floor(grid[i][j]) do
                    table.insert(matches, {k, j, grid[i][j]})
                    k = k + 1
                end
                table.insert(matchItems, grid[i][j])
                i = k
            else
                i = i + 1
            end
        end
    end
    return matches, matchItems
end

-- 打印所有匹配
local function printMatches(matches, operation)
    for _, match in ipairs(matches) do
        print(string.format("Match found at (%d, %d) with item %d due to %s", match[1], match[2], match[3], operation))
    end
end

-- 得分规则
local scores = {1, 5, 10, 20}

-- 升级物品
local function upgradeItem(item)
    return item + 10
end

-- 计算新的得分
local function calculateNewScore(matches, isUpgraded)
    local totalScore = 0
    for _, match in ipairs(matches) do
        local baseScore = scores[math.floor(match[3])]
        if baseScore then
            if isUpgraded then
                baseScore = baseScore * 20
            end
            totalScore = totalScore + baseScore
        else
            print(string.format("Error: No base score for item %d", match[3]))
        end
    end
    return totalScore
end

-- 移除匹配的物品并下落
local function removeMatchesAndDrop(grid, operation, x1, y1, x2, y2)
    local totalScore = 0
    while true do
        local matches,matchItems = findMatches(grid)
        if #matches == 0 then break end

        print("Matches found:" .. #matchItems)
        printMatches(matches, operation)

        print("Grid before removing matches:")
        printGrid(grid)

        local ori_p1 = grid[x1][y1]
        local ori_p2 = grid[x2][y2]

        -- 计算得分并移除匹配的物品
        totalScore = totalScore + calculateNewScore(matches, false)
        for _, match in ipairs(matches) do
            grid[match[1]][match[2]] = 0
        end

        -- 升级最后变动的物品
        for _, match in ipairs(matches) do
            if match[1] == x1 and match[2] == y1 then
                grid[x1][y1] = upgradeItem(ori_p1)
            elseif match[1] == x2 and match[2] == y2 then
                grid[x2][y2] = upgradeItem(ori_p2)
            end
        end

        -- 再次检查并移除升级后的匹配物品
        local upgradeMatches = findMatches(grid)
        if #upgradeMatches > 0 then
            print("Upgraded matches found:")
            printMatches(upgradeMatches, operation)
            totalScore = totalScore + calculateNewScore(upgradeMatches, true)
            for _, match in ipairs(upgradeMatches) do
                grid[match[1]][match[2]] = 0
            end
        end

        -- 下落物品
        for j = 1, gridSize do
            local emptySlots = 0
            for i = gridSize, 1, -1 do
                if grid[i][j] == 0 then
                    emptySlots = emptySlots + 1
                elseif emptySlots > 0 then
                    grid[i + emptySlots][j] = grid[i][j]
                    grid[i][j] = 0
                end
            end
        end

        print("Grid after removing matches:")
        printGrid(grid)
    end
    return totalScore
end

-- 尝试交换两个物品并计算得分
local function trySwap(originalGrid, x1, y1, x2, y2)
    -- 检查交换是否合法
    if x2 < 1 or x2 > gridSize or y2 < 1 or y2 > gridSize then
        return 0
    end
    -- 交换物品必须不同
    if grid[x1][y1] == grid[x2][y2] then
        return 0
    end
    -- 复制网格
    local grid = copyGrid(originalGrid)

    -- 交换物品
    local temp = grid[x1][y1]
    local temp2 = grid[x2][y2]

    grid[x1][y1] = temp2
    grid[x2][y2] = temp

    local score = removeMatchesAndDrop(grid, string.format("swapping (%d, %d) with (%d, %d)", x1, y1, x2, y2), x1, y1, x2, y2)

    --if score > 0 then
    --    grid[x1][y1] = "*" .. temp
    --    grid[x2][y2] = "*" .. temp2
    --    print("交换前")
    --    printGrid(grid)
    --
    --    grid[x1][y1] = "*" .. temp2
    --    grid[x2][y2] = "*" .. temp
    --    print("交换后")
    --    printGrid(grid)
    --end

    return score
end

-- 尝试移除一个物品并计算最佳交换后的得分
local function tryRemove(originalGrid, x, y)
    if true then
        return 0
    end
    -- 复制网格
    local grid = copyGrid(originalGrid)

    local original = grid[x][y]
    grid[x][y] = 0

    local initialScore = removeMatchesAndDrop(grid, string.format("removing (%d, %d)", x, y), x, y)
    local bestSwapScore = 0

    -- 检查所有可能的交换操作
    for i = 1, gridSize do
        for j = 1, gridSize do
            for di = -1, 1 do
                for dj = -1, 1 do
                    if math.abs(di) + math.abs(dj) == 1 then
                        local ni, nj = i + di, j + dj
                        if ni > 0 and ni <= gridSize and nj > 0 and nj <= gridSize then
                            local score = trySwap(grid, i, j, ni, nj)
                            if score > bestSwapScore then
                                bestSwapScore = score
                            end
                        end
                    end
                end
            end
        end
    end

    return initialScore + bestSwapScore
end

-- 找到最佳的交换操作或移除操作
local function findBestMove(grid)
    local bestMove = nil
    local bestScore = 0
    local bestSwapMove = nil
    local bestRemoveMove = nil

    for i = 1, gridSize do
        for j = 1, gridSize do
            -- 尝试交换操作
            for x = 1, gridSize do
                for y = 1, gridSize do
                    if not (i == x and j == y) then
                        local score = trySwap(grid, i, j, x, y)
                        if score > bestScore then
                            bestScore = score
                            bestMove = {type = "swap", x1 = i, y1 = j, x2 = x, y2 = y}
                            bestSwapMove = bestMove
                        end
                    end
                end
            end

            -- 尝试移除操作
            local score = tryRemove(grid, i, j)
            if score > bestScore then
                bestScore = score
                bestMove = {type = "remove", x = i, y = j}
                bestRemoveMove = bestMove
            end
        end
    end

    return bestMove, bestSwapMove, bestRemoveMove
end

-- 打印初始网格状态
print("Initial Grid:")
printGrid(grid)

local bestMove, bestSwapMove, bestRemoveMove = findBestMove(grid)

if bestMove then
    if bestMove.type == "swap" then
        print(string.format("Best move: Swap (%d, %d) with (%d, %d)", bestMove.x1, bestMove.y1, bestMove.x2, bestMove.y2))
    elseif bestMove.type == "remove" then
        print(string.format("Best move: Remove (%d, %d)", bestMove.x, bestMove.y))
    end
else
    print("No valid moves available")
end

if bestSwapMove then
    print(string.format("Best swap move: Swap (%d, %d) with (%d, %d)", bestSwapMove.x1, bestSwapMove.y1, bestSwapMove.x2, bestSwapMove.y2))
else
    print("No valid swap moves available")
end

if bestRemoveMove then
    print(string.format("Best remove move: Remove (%d, %d)", bestRemoveMove.x, bestRemoveMove.y))
else
    print("No valid remove moves available")
end

print("Grid after best move:")
if bestMove and bestMove.type == "swap" then
    trySwap(grid, bestMove.x1, bestMove.y1, bestMove.x2, bestMove.y2)
elseif bestMove and bestMove.type == "remove" then
    tryRemove(grid, bestMove.x, bestMove.y)
end
printGrid(grid)
