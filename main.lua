
Class = require 'class'
-- The Paddle class stores position and dimensions for Paddle 1 and 2 and the logic for rendering them
require 'Paddle'
-- The Paddle class stores position and dimensions for the Ball and the logic for rendering it
require 'Ball'

-- https://github.com/Ulydev/push
-- push is a library that will allow us to draw our game at a virtual resolution
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
-- the speed at which our paddle will move, multiplied by Delta Time(dt)in update
--Moves the same distance over time 
PADDLE_SPEED = 200

--Runs when the game first starts up, only once; used to initialize the game.
function love.load()

     -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())
    --Small font for rendering the message in the game
    smallFont = love.graphics.newFont('font.ttf', 8)
    --Larger font for drawing scores on the screen
    scoreFont = love.graphics.newFont('font.ttf', 32)
    largeFont = love.graphics.newFont('font.ttf', 16)

    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    --Initializing our player paddles; Make them global so that they can be detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    --Place the ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT / 2, 4, 4)
    --GameState variables are used to transition between different parts of the game
    -- we will use this to detwemine the behaviour during render and update
    -- Separates states into their modules
    gameState = 'start'

end
function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = - math.random(140, 200)
        end      
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()            
        end
        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
         -- -4 to account for the ball's size
         if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
         end
         if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            --gameState = 'start'
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            --ball:reset()
            --gameState = 'start'
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end
    -- if we reach the left or right edge of the screen, 
    -- go back to start and update the score
    
    --Player 1 movement
    if gameState == "play" then
        player1.y = ball.y 
        
    end
    --[[if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED 
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end]]

    --PLayer 2 movement
    if gameState == "play" then
        player2.y = ball.y 
        player2.dy = ball.dy
    end

    --[[if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED 
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED 
    else
        player2.dy = 0
    end ]]

    --Update the ball based on its DX and DY only if we are on the play state;
    --Scale the velocity by dt so movement is framerate independent
    if gameState == 'play' then
        ball:update(dt)
    end
    -- Checks if the players have moved past the top and bottom edges of the screen
    player1:update(dt)
    player2:update(dt)

end

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
   -- elseif key = 'space' then

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            -- Resets ball to go back to the start state
            ball:reset()

            --Reset score to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
     -- begin rendering at virtual resolution
    push:apply('start')
    
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to begin', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player' .. tostring(servingPlayer) .. " 's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve !!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then

    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')

    end
    

    --render first paddle to the left side
    player1:render()

    --render second paddle to the right hand side
    player2:render()
    --render ball at the center
    ball:render()

    displayFPS()
    
    -- end rendering at virtual resolution
    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0/255, 255/255, 0/255, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
end
