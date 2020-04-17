# LoveKeys
a library to track the current state of key presses in Love2D


## how to use:
there is a simple example in tests/basic

to use the library all that is needed is to require it:

```lua
LoveKeys = require("Path_To_LoveKeys")
```

any keys that you expect to use should be registered in love.load

```lua
function love.load()
	LoveKeys.RegisterKey("up")
	LoveKeys.RegisterKey("space")
	LoveKeys.RegisterKey("s")
end
```

then once you have done that, you can get information on the current state of the key in 3 ways:

```lua
LoveKeys.up.Pressed
-- or
LoveKeys["space"].Released
-- or
LoveKeys.Get("s").Held
```

in your love.update you should add LoveKeys.update to the end of it

```lua
function love.update(dt)
	--[[
		a bunch of code
	]]

	LoveKeys.update(dt)
end
```

when it comes to love.keypressed and love.keyreleased then this is how you should be doing it:

```lua
function love.keypressed(Key)
	LoveKeys.keypressed(Key)
end

function love.keyreleased(Key)
	LoveKeys.keyreleased(Key)
end
```

specifically you shouldn't have anything else in them, purely because key repeat can't be handled if you do that

if you still want to handle events you can instead define the functions LoveKeys.Event.keypressed and LoveKeys.Event.keyreleased

like this:

```lua
function LoveKeys.Event.keypressed(KeyName, Key)
	print(KeyName.." was pressed, it's delay setting is at: "..Key.Repeat.Delay)
end

function LoveKeys.Event.keyreleased(KeyName, Key)
	print(KeyName.." was released, it was pressed for "..Key.PressLength.." seconds")
end
```

&nbsp;

defining love.keypressed and love.keyreleased can be annoying so there is a shortcut for that

if the global variable `GLOBAL_SET_LOVE_KEYS` is set to true when LoveKeys is required, it will automatically define both love.keypressed and love.keyreleased to the same as seen above

## about delays and repeats

using LoveKeys.SetRepeatInfo() it is possible to tell the library how you want a key to repeat

```lua
LoveKeys.SetRepeatInfo("space", 2, 1)
```

the above code will make it so that once the space key has been held for 2 seconds, it will act as if it was pressed again, then again one second later it will do it again

the first argument is the delay and the second is the repeat, they can be found in `<KeyInfo>.Repeat.Delay` and `<KeyInfo>.Repeat.Repeat` respectivly

when a key is repeating it is possible to tell that it is by checking `<KeyInfo>.Repeating`