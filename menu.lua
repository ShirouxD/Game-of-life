--Author: Gimal Chamuditha Diyagama
--Student ID: 10637935
-- menu.lua
local composer = require("composer")
local widget = require("widget") --necessary to create buttons/sliders etc..

local scene = composer.newScene()


local gameOfLifeScene = composer.getScene("gameOfLife") --get the scene from gameeoflife lua file
local gameTimer = gameOfLifeScene.gameTimer --get the timer from the gameoflife lua file

--function to handle button events
local function handleButtonEvent(event) --this event handle button will be taking care of most of the logic in the buttons
    if event.phase == "ended" then
        local buttonId = event.target.id  --based on the button user clicks the logic will function
        if buttonId == "stopButton" then --stop button
            --this will stop the game and make into a paused state
            if gameOfLifeScene.gameTimer then
                timer.cancel(gameOfLifeScene.gameTimer)
            end
             --close the application
             native.requestExit()
        elseif buttonId == "resetButton" then --this button is used to go back
            --reset the grid/go back to its initial state
            scene.grid = gameOfLifeScene.initializeGrid()
            gameOfLifeScene.drawGrid(scene.grid)
        elseif buttonId == "pauseButton" then
            --pause button logic
            if gameOfLifeScene.gameTimer then  --if condition to check if timer is running
                timer.pause(gameOfLifeScene.gameTimer) --pause the game timer
                gameOfLifeScene.gameTimer = nil  --turn the gametimer value to nil
            else
                gameOfLifeScene.gameTimer = timer.performWithDelay(1000 / gameOfLifeScene.frameRate, gameLoop, 0)
            end
        elseif buttonId == "restartButton" then
            --restart button
            if gameOfLifeScene.gameTimer then   --check if timer is running
                timer.cancel(gameOfLifeScene.gameTimer) --cancel timer if it is running
            end
            gameOfLifeScene.grid = gameOfLifeScene.initializeGrid() --then get the intial grid state
            gameOfLifeScene.drawGrid(gameOfLifeScene.grid) --start the creation of it again
            gameOfLifeScene.gameTimer = timer.performWithDelay(1000 / gameOfLifeScene.frameRate, gameOfLifeScene.gameLoop, 0) --must use the gameOfLifeScene to make sure everything is referenced well
        end
    end
end

function scene:create(event)
    local sceneGroup = self.view

    --make the title text
    local titleText = display.newText({
        text = "The Game of Life",  --put title text
        x = display.contentCenterX,  --this is the x axis and this current makes the position start from the center of the x axis
        y = display.contentHeight - 20,  --this is the y axis and it starts from the bottom of the screen
        font = native.systemFontBold,   --choose default font
        fontSize = 25
    })
    sceneGroup:insert(titleText)

    -- Create another text
    local anotherText = display.newText({
        text = "User can click to activate cells",
        x = display.contentCenterX,  --this is x axis and starts from the center again
        y = display.contentHeight - 0,  --this is y axis again and will determine the verticality of the text
        font = native.systemFontBold,
        fontSize = 10
    })
    sceneGroup:insert(anotherText) --add the texts to the display

    --create the stop button
    local stopButton = widget.newButton({
        id = "stopButton",  --id of the button
        label = "Stop",   --label the button as stop
        x = display.contentCenterX - 80,  --this starts from the center of x but substracts the given amount and goes to the left side of the screen from the center
        y = 30,
        width = 60, --can customize the width as well
        height = 30,    --we can customize the height of this
        shape = "roundedRect",   --use rounded corner rectangle to make it look better
        cornerRadius = 5,
        fillColor = { default = { 1, 0, 0 }, over = { 0.8, 0, 0 } }, --customize the color based on the corresponding RGB values
        onEvent = handleButtonEvent
    })
    sceneGroup:insert(stopButton) --add the buttons to the display

    --create the reset button
    local resetButton = widget.newButton({
        id = "resetButton",   --give the id of the button
        label = "Go Back", --the label of the button
        x = display.contentCenterX,   --start the x axis from the center
        y = 30, --y axis is in the same as the stop button
        width = 70, --higher width to account for more word count and the space
        height = 30,
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = { default = { 0, 1, 0 }, over = { 0, 0.8, 0 } },  --green color
        onEvent = handleButtonEvent
    })
    sceneGroup:insert(resetButton)

    --create the pause button
    local pauseButton = widget.newButton({
        id = "pauseButton",
        label = "Pause",
        x = display.contentCenterX + 80,    --pause button on the right side of the screen
        y = 30, --same y axis as go back button
        width = 60,
        height = 30,
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = { default = { 1, 0.5, 0.5 }, over = { 0.8, 0.4, 0.4 } }, --pink color
        onEvent = handleButtonEvent
    })
    sceneGroup:insert(pauseButton) --add pause button to display


    --create the restart button
    local restartButton = widget.newButton({
        id = "restartButton",
        label = "Restart",
        x = display.contentCenterX,  --we can change the x values as necessary
        y = 70, --y axis can also be changed based on our needs
        width = 70,  --width to match the button on top which is go back button
        height = 30,
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = { default = { 0, 1, 0 }, over = { 0, 0.8, 0 } }, --green color
        onEvent = handleButtonEvent
    })
    sceneGroup:insert(restartButton)


        --function to handle slider events
    local function handleSliderEvent(event) --some logic can also be included inside of this scene create function
        local sliderValue = event.value  --this will be a number between 1 and 100
        local newFrameRate = sliderValue / 10  --adjust this calculation as needed
        gameOfLifeScene.frameRate = newFrameRate
        if gameOfLifeScene.gameTimer then
            timer.cancel(gameOfLifeScene.gameTimer)
            gameOfLifeScene.gameTimer = timer.performWithDelay(1000 / gameOfLifeScene.frameRate, gameOfLifeScene.gameLoop, 0)
        end
    end
    --create the slider
    local slider = widget.newSlider({
        id = "speedSlider",
        left = display.contentCenterX - 100,  --position the slider in the center horizontally
        top = display.contentHeight - 70,  --position the slider 50 pixels from the bottom of the screen
        width = 200,
        value = gameOfLifeScene.frameRate * 10,  --the starting slider offset
        listener = handleSliderEvent
    })
    sceneGroup:insert(slider) --add slider to display

            --create the clear button
    local clearButton = widget.newButton({
        id = "clearButton",
        label = "Clear",
        x = display.contentCenterX - 80,  --position to the left of the screen from the restart button
        y = 70, --this is positioned same as the y axis of restart
        width = 60,     --same width and height as majority
        height = 30,
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = { default = { 1, 0, 0 }, over = { 0.8, 0, 0 } }, --red color
        onEvent = function(event)
            if event.phase == "ended" then
                gameOfLifeScene.clearGrid(gameOfLifeScene.grid, gameOfLifeScene.drawGrid)  --pass the grid and drawGrid to the clearGrid function
            end
        end
    })
    sceneGroup:insert(clearButton) --add clear button to display
    --function to handle the logic of start button
    local function handleButtonEvent(event)
        if event.phase == "ended" then  --check if event has ended
            local buttonId = event.target.id
            if buttonId == "startButton" then
                --start the simulation
                if gameOfLifeScene.gameTimer then
                    timer.cancel(gameOfLifeScene.gameTimer)
                end
                gameOfLifeScene.gameTimer = timer.performWithDelay(1000 / gameOfLifeScene.frameRate, gameOfLifeScene.gameLoop, 0)
            elseif buttonId == "stopButton" then
                --stop the simulation
                if gameOfLifeScene.gameTimer then
                    timer.cancel(gameOfLifeScene.gameTimer)
                end
            end
        end
    end


        --create the start button
    local startButton = widget.newButton({
        id = "startButton",
        label = "Start",
        x = display.contentCenterX + 80,  --this button is on the right side of the restart button
        y = 70, --y axis same as restart
        width = 60,
        height = 30,
        shape = "roundedRect", --standard rounded rectangle
        cornerRadius = 5,
        fillColor = { default = { 1, 0.5, 0.5 }, over = { 0.8, 0.4, 0.4 } },  --pink color
        onEvent = handleButtonEvent
    })
    sceneGroup:insert(startButton) --add start button to display

        --create the save button
    local saveButton = widget.newButton({
        id = "saveButton",
        label = "Save",
        x = display.contentCenterX,
        y = 410, --position the y axis so that its right below the 200x200 grid
        width = 60,
        height = 30,
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = { default = { 0, 1, 0 }, over = { 0, 0.8, 0 } },   --save is green color
        onEvent = function(event)--logic to save the grid inside of the button creation
            if event.phase == "ended" then
                gameOfLifeScene.saveGrid()
            end
        end
    })
    sceneGroup:insert(saveButton) --add save button to display

    
end

scene:addEventListener("create", scene) --made to manage the scenes accordingly

return scene