local OutFile = io.open("out.txt", "w")

function print(...) --default print doesnt want to work on my pc
	OutFile:write(...)
	OutFile:write("\n")
end

package.path = "../../?.lua;"..package.path -- only needed because the library is outside this folder
GLOBAL_SET_LOVE_KEYS = true
LoveKeys = require("LoveKeys")

Position = {x = 400, y = 300}
Speed = {x = 0, y = 0}

function love.load()
	LoveKeys.RegisterKey("up")
	LoveKeys.RegisterKey("down")
	LoveKeys.RegisterKey("left")
	LoveKeys.RegisterKey("right")
	
	LoveKeys.RegisterKey("s")
	LoveKeys.SetRepeatInfo("s", 2, 1)
end

function love.update(dt)

	if LoveKeys.up.Pressed then
		Speed.x = 0
		Speed.y = -1
	end
	if LoveKeys.down.Pressed then
		Speed.x = 0
		Speed.y = 1
	end
	if LoveKeys.left.Pressed then
		Speed.x = -1
		Speed.y = 0
	end
	if LoveKeys.right.Pressed then
		Speed.x = 1
		Speed.y = 0
	end

	if LoveKeys.up.Released and Speed.x == 0 and Speed.y == -1 then
		Speed.y = 0
	end
	if LoveKeys.down.Released and Speed.x == 0 and Speed.y == 1 then
		Speed.y = 0
	end
	if LoveKeys.left.Released and Speed.x == -1 and Speed.y == 0 then
		Speed.x = 0
	end
	if LoveKeys.right.Released and Speed.x == 1 and Speed.y == 0 then
		Speed.x = 0
	end

	Position.x = Position.x + Speed.x * 100 * dt
	Position.y = Position.y + Speed.y * 100 * dt

	LoveKeys.update(dt)
end

function love.draw()
	love.graphics.circle("fill", Position.x, Position.y, 20)
end

function LoveKeys.Event.keypressed(KeyName, Key)
	print(KeyName.." was pressed, it's delay setting is at: "..Key.Repeat.Delay)
end

function LoveKeys.Event.keyreleased(KeyName, Key)
	print(KeyName.." was released, it was pressed for "..Key.PressLength.." seconds")
end
