Ball = Class{}

-- construct an initializer
function Ball:init(x, y, width, height)
    self.x = x 
    self.y = y 
    self.width = width
    self.height = height

    --Variables to keep track of the velocity on both the X and Y axis since the ball moves in the two dimensions
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

function Ball:collides(paddle)
    -- check to see if the left edge of either is farther to the right than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    -- check to see if the bottom edge of either is higher than the top edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end
    -- if the above aren't true, they're overlapping
    return true

end
-- Places the ball at the middle of the screen with initial random velocity on both axis
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

-- Applies velocity to position scaled by dt (deltaTime)
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end