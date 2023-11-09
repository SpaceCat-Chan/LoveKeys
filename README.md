# LoveKeys
a library to track the current state of key presses in Love2D

this library has moved away from github and can be found here instead: https://git.ptrc.gay/SpaceCat-Chan/lovekeys

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
	LoveKeys.RegisterKey("Jump") --you don't need to use actual keys, to see more check out the aliasing section
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

the above code will make it so that once the space key has been held for 2 seconds, it will act as if it was pressed again, then again one second later it will do it again and it will keep doing it every second until the space key is released

the first argument is the delay and the second is the repeat, they can be found in `<KeyInfo>.Repeat.Delay` and `<KeyInfo>.Repeat.Repeat` respectivly

when a key is repeating it is possible to tell that it is by checking `<KeyInfo>.Repeating`


## Aliasing

Aliasing allows you to combine multiple keys into one name  
it is especially useful if you want your users to be able to change keybinds 

a basic example of how to create a keybind goes like this: 

```lua
function love.load()
	LoveKeys.Alias({"w", "up"}, "MoveUp")
end
```

with the above Alias, MoveUp will be pressed if w __or__ up is pressed

both the first and second argument can be tables or strings interchangably

&nbsp;

there is an optional third argument which specifies how the keys interact.  
the allowed arguments are: `or, and, nor, nand`, the default is `or` 

`or` means that if any of the input keys are pressed, the output keys are pressed  
`and` means that all the input keys must be pressed before the output gets pressed.  
`nor` and `nand` are inverses of `or` and `and` respectively.

an example can be found in tests/alias/

## Alias namespacing

f you change gamestate and need alot of new keybinds, it can get annoying to have to un-alias and re-alias everything  
but with Alias namespacing it is possible to have multiple Alias setups at the same time, with only one of the active at any time

to activate a different namespace from the currently active one you can call `LoveKeys.SetAliasNamespace`

when defining Aliases they will by default be set for the currently active namespace, but this can be overridden using the fourth argument

```lua
function love.load()
	LoveKeys.SetAliasNamespace("The_B_Namespace")
	LoveKeys.Alias("a", "AAA", nil, "The_A_Namespace")
	LoveKeys.Alias("b", "BBB",) -- will be defined for currently active namespace, which is: The_B_Namespace
end
```

the default active namespace is `"default"`

## Accesing information about keys, advanced mode

i will just dump the format of the table you get from `LoveKeys.Get()` here

```lua
KeyInfo = {
	Pressed = true/false,
	Released = true/false,
	Held = true/false,
	PressLength = number,
	Repeating = true/false,
	Repeat = {
		Repeat = number, --how long between each repeat
		Delay = number --how long before it starts repeating, once this time is reached another keypress event happens
	},
	Alias = {
		[namespace_name1] = {
			To = Array_Of_Key_Names,
			From = Array_Of_Key_Names,
			Type = string --valid things are: or, and, nor, nand
		}
		[namespace_name2] = ...
		[...] = ...
	}
}
```

beware of accessing information in namespaces, they could be nil
