--[[
    this example is just a version of the basic example that makes use of alias functionality
]]
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
	LoveKeys.Alias({"r"}, "test")
	LoveKeys.Alias({"r"}, "test2")
	assert(LoveKeys.r.Alias.default.To[1] == "test", "re-alias consistancy is not preserved")
	LoveKeys.Alias({}, "test")
	assert(LoveKeys.r.Alias.default.To[1] == nil, "re-alias consistancy is not preserved")
	assert(LoveKeys.r.Alias.default.To[2] == "test2", "re-alias consistancy is not preserved")
	
	LoveKeys.Alias({"r"}, "MoveUp")
    LoveKeys.Alias({"w", "up"}, "MoveUp")
	assert(LoveKeys.r.Alias.default.To[1] == nil, "re-alias consistancy is not preserved")
    LoveKeys.Alias({"s", "down"}, "MoveDown")
    LoveKeys.Alias({"a", "left"}, "MoveLeft")
    LoveKeys.Alias({"d", "right"}, "MoveRight")
	
    LoveKeys.Alias({"z", "x"}, {"Log1", "Log2"}, "and")
	LoveKeys.SetRepeatInfo("Log1", 2, 1)
end

function love.update(dt)

    if LoveKeys.MoveUp.Pressed then
		Speed.x = 0
		Speed.y = -1
	end
	if LoveKeys.MoveDown.Pressed then
		Speed.x = 0
		Speed.y = 1
	end
	if LoveKeys.MoveLeft.Pressed then
		Speed.x = -1
		Speed.y = 0
	end
	if LoveKeys.MoveRight.Pressed then
		Speed.x = 1
		Speed.y = 0
	end

	if LoveKeys.MoveUp.Released and Speed.x == 0 and Speed.y == -1 then
		Speed.y = 0
	end
	if LoveKeys.MoveDown.Released and Speed.x == 0 and Speed.y == 1 then
		Speed.y = 0
	end
	if LoveKeys.MoveLeft.Released and Speed.x == -1 and Speed.y == 0 then
		Speed.x = 0
	end
	if LoveKeys.MoveRight.Released and Speed.x == 1 and Speed.y == 0 then
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
