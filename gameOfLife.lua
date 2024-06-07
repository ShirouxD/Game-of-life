--Author: Gimal Chamuditha Diyagama
--Student ID: 10637935
-- gameOfLife.lua
local json = require("json") --json is required to save the file when user clicks save
local composer = require("composer")
local scene = composer.newScene()

--define the size of the grid
local rows, cols = 200, 200 --change to 200x200

--define 5000 as the number of random initial cells
local initialCells = 5000

--create a function to initialize the grid with random cells
local function initializeGrid()  --no argument
    local grid = {}  --initialize an empty grid
    for i = 1, rows do   --create a for loop to iterate through each row
        grid[i] = {}
        for j = 1, cols do --create a for loop to iterate through each column
            grid[i][j] = math.random(0, 1) --this will randomly set the cell to either dead or alive (0 or 1)
        end
    end
    return grid
end
scene.initializeGrid = initializeGrid
--create a variable to display group for cells
local cellGroup = display.newGroup() --mainly used in order to efficiency so that the program will continuously run without crashing at any point

--function to clear the grid
local function clearGrid(grid, drawGrid)
    for i = 1, rows do
        for j = 1, cols do
            grid[i][j] = 0
        end
    end
    drawGrid(grid)
end

--make the clearGrid function accessible from other files
scene.clearGrid = clearGrid

--function to draw the smaller grid on the screen
local function drawGrid(grid)
    cellGroup:removeSelf()
    cellGroup = display.newGroup()

    -- Reduce the size of the cells
    local cellSize = 1.4  -- Adjust the cell size as desired

    --calculate the total width and height of the grid
    local gridWidth = cols * cellSize
    local gridHeight = rows * cellSize

    --calculate the center position for the grid and outline
    local centerX = display.contentCenterX
    local centerY = display.contentCenterY

    --make a red outline rectangle for the entire grid
    local outlineRect = display.newRect(centerX, centerY, gridWidth + 8, gridHeight + 8)
    outlineRect:setFillColor(0, 0, 0, 0)
    outlineRect:setStrokeColor(1, 0, 0)
    outlineRect.strokeWidth = 4
    cellGroup:insert(outlineRect)

    for i = 1, rows do
        for j = 1, cols do
            local cell = grid[i][j]
            local rect = display.newRect(centerX + (j - cols/2) * cellSize, centerY + (i - rows/2) * cellSize, cellSize, cellSize)
            
            -- Add a touch event listener to the cell
            rect:addEventListener("touch", function(event)
                if event.phase == "began" then
                    -- Toggle the cell state when it's clicked
                    grid[i][j] = 1 - grid[i][j]
                    -- Redraw the grid to reflect the new state
                    drawGrid(grid)
                end
                return true  -- Prevents touch propagation to underlying objects
            end)

            if cell == 1 then
                rect:setFillColor(1, 1, 1)
            else
                rect:setFillColor(0, 0, 1)
            end

            cellGroup:insert(rect)
        end
    end
end
scene.drawGrid = drawGrid


--function to apply the Game of Life rules and update the grid
local function updateGrid(grid) --give grid as argument to show the current grid
    local newGrid = {}  --initialize new empty grid
    for i = 1, rows do  --iterate over rows of the grid
        newGrid[i] = {}  --initialize empty array to represent a row
        for j = 1, cols do  --iterate over columns of the grid
            local neighbors = 0 --initialize neighbor variable

            --count the number of active neighbors
            for x = -1, 1 do  --for loop to check for neighboring cells
                for y = -1, 1 do
                    if x ~= 0 or y ~= 0 then  --if loop to check if x and y are 0
                        local ni, nj = i + x, j + y  --calculate neighbor cell position
                        if ni >= 1 and ni <= rows and nj >= 1 and nj <= cols and grid[ni][nj] == 1 then  --check if cell is within the bounds and if it is active
                            neighbors = neighbors + 1  --if neighbors active then counter increase to keep track
                        end
                    end
                end
            end

            -- apply Game of Life rules
            if grid[i][j] == 1 then  --check if current cell is alive
                if neighbors < 2 or neighbors > 3 then  --if theres less than 2 or 3 neighbors cell dies
                    newGrid[i][j] = 0 -- 0 means cell dies
                else
                    newGrid[i][j] = 1 --1 means cell lives
                end
            else
                if neighbors == 3 then
                    newGrid[i][j] = 1 --cell becomes alive
                else
                    newGrid[i][j] = 0 --cell will be dead
                end
            end
        end
    end

    return newGrid
end

--new function to save the grid
local function saveGrid()
    local gridJson = json.encode(grid)
    local path = system.pathForFile("savedGrid.json", system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        file:write(gridJson)
        io.close(file)
    end
end

--make the saveGrid function accessible from other files
scene.saveGrid = saveGrid

--main loop to continuously update the grid
local grid = initializeGrid() --initialize the grid with random cells
scene.grid = grid  -- make grid accessible from other scenes
drawGrid(grid) --show initial state of grid

local frameRate = 10  --the rate at which the grid will be updated
scene.frameRate = frameRate

local function gameLoop() --new function to update and draw the grid every main loop
    scene.grid = updateGrid(scene.grid) --update the state of the grid and assign it to grid variable
    drawGrid(scene.grid) --show new state of the grid after the update
end
scene.gameLoop = gameLoop  -- make gameLoop accessible from other scenes

--define the timer variable outside the gameLoop function
local gameTimer = timer.performWithDelay(1000 / frameRate, gameLoop, 0)

--add the gameTimer to the scene so it can be accessed from other scenes
scene.gameTimer = gameTimer




return scene
