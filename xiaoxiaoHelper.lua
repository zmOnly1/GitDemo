
math.randomseed(os.time())

-- 定义网格尺寸和物品种类
local gridSize = 6
local itemTypes = 4

-- 创建一个空网格
--local grid = {}
--
---- 填充网格并确保没有超过2个连续的相同物品
--for i = 1, gridSize do
--    grid[i] = {}
--    for j = 1, gridSize do
--        local options = {1, 2, 3, 4}
--
--        -- 检查左边两个物品
--        if j > 2 and grid[i][j-1] == grid[i][j-2] then
--            for k = #options, 1, -1 do
--                if options[k] == grid[i][j-1] then
--                    table.remove(options, k)
--                end
--            end
--        end
--
--        -- 检查上边两个物品
--        if i > 2 and grid[i-1][j] == grid[i-2][j] then
--            for k = #options, 1, -1 do
--                if options[k] == grid[i-1][j] then
--                    table.remove(options, k)
--                end
--            end
--        end
--
--        -- 从剩余的选项中随机选择一个
--        grid[i][j] = options[math.random(#options)]
--    end
--end

function inMatches(x, y , matches)
    for i, v in ipairs(matches) do
        if v[1] == x and v[2] == y then
            return true
        end
    end
    return false
end
function inChanges(x, y , changes)
    for i, v in ipairs(changes) do
        if v.x == x and v.y == y then
            return true
        end
    end
    return false
end

--function myLog(str)
--    io.write(str)
--end

-- 打印网格状态 (用于调试)
local function printGrid(grid, matches, chg_points)
    local out = "\n"
    for i = 1, gridSize do
        for j = 1, gridSize do
            local print_val = grid[i][j] .. ""
            if chg_points and inChanges(i,j, chg_points) then
                print_val = string.format("^%s", print_val)
            end
            if matches and inMatches(i,j, matches) then
                print_val = string.format("*%s", print_val)
            end
            out = out .. string.format("%5s", print_val) .. "\t"
        end
        out = out .. "\n"
    end
    myLog(out)
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

function matchPoints(val, points)
    local new = {}
    new['val'] = val
    new['points'] = points
    new['intersect'] = false
    return new
end

function intersect(points1, points2)
    for _, m in ipairs(points1) do
        for _, n in ipairs(points2) do
            if m.x == n.x and m.y == n.y then
                return true
            end
        end
    end
    return false
end

function guid()
    local seed={'e','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    local tb={}
    for i=1,32 do
        table.insert(tb,seed[math.random(1,16)])
    end
    local sid=table.concat(tb)
    return string.format('%s-%s-%s-%s-%s',
            string.sub(sid,1,8),
            string.sub(sid,9,12),
            string.sub(sid,13,16),
            string.sub(sid,17,20),
            string.sub(sid,21,32)
    )
end

-- 查找所有匹配
local function findMatches(grid)
    local matches = {}

    -- 行检查
    for i = 1, gridSize do
        local j = 1
        while j <= gridSize - 2 do
            if grid[i][j] ~= 0 and math.floor(grid[i][j]) == math.floor(grid[i][j+1]) and math.floor(grid[i][j]) == math.floor(grid[i][j+2]) then
                local k = j
                local gid = guid()
                while k <= gridSize and math.floor(grid[i][k]) == math.floor(grid[i][j]) do
                    table.insert(matches, {i, k, grid[i][j], id=gid})
                    k = k + 1
                end
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
                local gid = guid()
                while k <= gridSize and math.floor(grid[k][j]) == math.floor(grid[i][j]) do
                    table.insert(matches, {  k, j, grid[i][j], id = gid})
                    k = k + 1
                end
                i = k
            else
                i = i + 1
            end
        end
    end

    return matches
end

-- 得分规则
--local 职业 = {步,弓,炮,策}
--local 颜色 = {绿色,蓝色,紫色,橙色,红色}
local scores = {1, 5, 10, 20}
for i, v in ipairs(scores) do
    for j = 1, 4 do
        scores[j * 10 + i] = scores[i] * 20
    end
end

-- 升级物品
local function upgradeItem(item)
    return item + 10
end

-- 移除匹配的物品并下落
local function removeMatchesAndDrop(grid, operation, chg_points)
    local totalScore = 0
    local combines = 0
    myLog("start--------------------------------")
    myLog(operation)
    while true do
        local matches = findMatches(grid)
        if #matches == 0 then
            if combines > 0 then
                myLog(operation)
                myLog("total combines: " .. combines)
                myLog("end--------------------------------")
            end
            break
        end

        myLog("Grid matches:")
        printGrid(grid, matches, chg_points)

        -- 移除匹配的物品
        for _, match in ipairs(matches) do
            grid[match[1]][match[2]] = 0
        end

        -- 升级最后变动的物品
        local mark = {}
        for _, match in ipairs(matches) do
            local key = match[1] .. "," .. match[2]
            for _, v in ipairs(chg_points) do
                if not mark[key] and not mark[match.id] and match[1] == v.x and match[2] == v.y then
                    grid[match[1]][match[2]] = upgradeItem(match[3])
                    mark[key] = true
                    mark[match.id] = true
                    -- 计算得分
                    totalScore = totalScore + scores[match[3]]
                    combines = combines + 1
                end
            end
        end
        myLog("Grid upgrade:")
        printGrid(grid, matches, chg_points)

        -- 重置变动物品
        chg_points = {}
        -- 下落物品
        for j = 1, gridSize do
            local emptySlots = 0
            for i = gridSize, 1, -1 do
                if grid[i][j] == 0 then
                    emptySlots = emptySlots + 1

                    table.insert(chg_points, Point(i, j))
                elseif emptySlots > 0 then
                    grid[i + emptySlots][j] = grid[i][j]
                    grid[i][j] = 0

                    table.insert(chg_points, Point(i, j))
                end
            end
        end

        myLog("Grid drop:")
        printGrid(grid, nil, chg_points)
    end
    return totalScore, combines
end

function exchange(grid, x1, y1, x2, y2)
    local temp = grid[x1][y1]
    local temp2 = grid[x2][y2]

    grid[x1][y1] = temp2
    grid[x2][y2] = temp
end

function Point(x,y)
    local new ={};
    new["x"] = x;
    new["y"] = y;
    return new;
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
    exchange(grid, x1, y1, x2, y2)

    local score,combines = removeMatchesAndDrop(grid, string.format("swapping (%d, %d) with (%d, %d)", x1, y1, x2, y2), {Point(x1, y1), Point(x2, y2)})
    return score,combines
end

-- 尝试移除一个物品并计算最佳交换后的得分
local function tryRemove(originalGrid, x, y)
    -- 复制网格
    local grid = copyGrid(originalGrid)

    local original = grid[x][y]
    grid[x][y] = 0

    -- 物品下落填补空缺
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

    local score, combines = removeMatchesAndDrop(grid, string.format("removing (%d, %d)", x, y), { Point(x, y) })
    return score, combines
end

-- 找到最佳的交换操作或移除操作
local function findBestMove(grid)
    local bestSwaps = {}
    local bestRemoves = {}

    for i = 1, gridSize do
        for j = 1, gridSize do
            -- 尝试交换操作
            for x = 1, gridSize do
                for y = 1, gridSize do
                    if not (i == x and j == y) then
                        local score,combines = trySwap(grid, i, j, x, y)
                        if score > 0 then
                            table.insert(bestSwaps, {score, combines, i, j, x, y})
                        end

                    end
                end
            end

            -- 尝试移除操作
            local score,combines = tryRemove(grid, i, j)
            if score > 0 then
                table.insert(bestRemoves, {score, combines, i, j})
            end
        end
    end

    -- 按得分排序
    table.sort(bestSwaps, function(a, b) return a[1] > b[1] end)
    -- 打印前三个最高得分的交换操作
    myLog("Top 3 Swap Moves:")
    for i = 1, math.min(3, #bestSwaps) do
        myLog(string.format("swapping (%d, %d) with (%d, %d) - Score: %d, Combines: %d", bestSwaps[i][3], bestSwaps[i][4], bestSwaps[i][5], bestSwaps[i][6], bestSwaps[i][1], bestSwaps[i][2]))
    end

    -- 按合成次数排序
    table.sort(bestSwaps, function(a, b) return a[2] > b[2] end)
    -- 打印前三个最高得分的交换操作
    myLog("Top 3 combines Swap Moves:")
    for i = 1, math.min(3, #bestSwaps) do
        myLog(string.format("swapping (%d, %d) with (%d, %d) - Score: %d, Combines: %d", bestSwaps[i][3], bestSwaps[i][4], bestSwaps[i][5], bestSwaps[i][6], bestSwaps[i][1], bestSwaps[i][2]))
    end

    -- 按得分排序
    table.sort(bestRemoves, function(a, b) return a[1] > b[1] end)
    -- 打印前三个最高得分的移除操作
    myLog("Top 3 Remove Moves:")
    for i = 1, math.min(3, #bestRemoves) do
        myLog(string.format("removing item at (%d, %d) - Score: %d, Combines: %d", bestRemoves[i][3], bestRemoves[i][4], bestRemoves[i][1], bestRemoves[i][2]))
    end
end

-- 打印初始网格状态
myLog("Initial Grid:")
printGrid(grid)

findBestMove(grid)
