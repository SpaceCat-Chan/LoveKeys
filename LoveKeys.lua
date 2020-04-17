--- @class KeyInfo
--- @field public Pressed boolean @if the button was clicked this update cycle
--- @field public Released boolean @if the button was let go of this update cycle
--- @field public Held boolean @if button is being held down
--- @field public PressLength number @how long the button has been pressed for
--- @field private RepeatLength number @internal thing, don't touch
--- @field public Repeating boolean @if the button has begun repeating Clicks
--- @field public Repeat RepeatInfo @info about how the button repeats
local NothingSpecialHereJustADummy

--- @class RepeatInfo
--- @field public Delay number how long before the key starts repeating * NOTICE the first repeat comes when time reaches Delay, not Delay + Repeat
--- @field public Repeat number how long between each repeat
local OnceAgainAnotherDummyType____AAAAAAAAAA

local KeysTable = {
	--- @type table<string, KeyInfo>
	KeyInfo = {},
	--- @type table<string, fun(KeyName:string,Key:KeyInfo):nil>
	Event =  {}
}

--- @param Key string @the key that you want info about
--- @return KeyInfo|nil !string @the requsted info or nil with an extra that contains error info
KeysTable.Get = function(Key)
	if KeysTable.KeyInfo[Key] == nil then
		return nil, "Unkown Key"
	end
	return {
		Pressed = KeysTable.KeyInfo[Key].Pressed,
		Released = KeysTable.KeyInfo[Key].Released,
		Held = KeysTable.KeyInfo[Key].Held,
		PressLength = KeysTable.KeyInfo[Key].PressLength,
		RepeatLength = 0, -- nice try getting info out from here
		Repeating = KeysTable.KeyInfo[Key].Repeating,
		Repeat = {
			Delay = KeysTable.KeyInfo[Key].Repeat.Delay,
			Repeat = KeysTable.KeyInfo[Key].Repeat.Repeat
		}
	}
end

-- this function should be called at the end of the love.update function
--- @param dt number @the amount of time since the last call to this function
KeysTable.update = function(dt)
	for k,KeyInfo in pairs(KeysTable.KeyInfo) do
		if KeyInfo.Held then
			KeyInfo.PressLength = KeyInfo.PressLength + dt
			KeyInfo.RepeatLength = KeyInfo.RepeatLength + dt
			if KeyInfo.RepeatLength > KeyInfo.Repeat.Delay and KeyInfo.Repeat.Delay ~= 0 and KeyInfo.Repeat.Repeat ~= 0 then
				KeyInfo.Pressed = true
				KeyInfo.Repeating = true
				KeyInfo.RepeatLength = KeyInfo.RepeatLength - KeyInfo.Repeat.Repeat
				if KeysTable.Event.keypressed then
					KeysTable.Event.keypressed(k, KeysTable.Get(k))
				end
			else
				KeyInfo.Pressed = false
			end
		end
		KeyInfo.Released = false
	end
end

-- this function should be called in love.keypressed
--- @param Key string @the name of key that was pressed
KeysTable.keypressed = function(Key)
	if KeysTable.KeyInfo[Key] == nil then
		KeysTable.KeyInfo[Key] = {
			Pressed = true,
			Released = false,
			Held = true,
			PressLength = 0,
			RepeatLength = 0,
			Repeating = false,
			Repeat = {
				Delay = 0,
				Repeat = 0
			}
		}
	else
		KeysTable.KeyInfo[Key].Pressed = true
		KeysTable.KeyInfo[Key].Released = false
		KeysTable.KeyInfo[Key].Held = true
		KeysTable.KeyInfo[Key].PressLength = 0
		KeysTable.KeyInfo[Key].RepeatLength = 0
		KeysTable.KeyInfo[Key].Repeating = false
	end
	if KeysTable.Event.keypressed then
		KeysTable.Event.keypressed(Key, KeysTable.Get(Key))
	end
end

-- this function should be called in love.keyreleased
--- @param Key string @the name of the key that was released
KeysTable.keyreleased = function(Key)
	if KeysTable.Event.keyreleased then
		KeysTable.Event.keyreleased(Key, KeysTable.Get(Key))
	end
	if KeysTable.KeyInfo[Key] == nil then
		KeysTable.KeyInfo[Key] = {
			Pressed = false,
			Released = true,
			Held = false,
			PressLength = 0,
			RepeatLength = 0,
			Repeating = false,
			Repeat = {
				Delay = 0,
				Repeat = 0
			}
		}
	else
		KeysTable.KeyInfo[Key].Pressed = false
		KeysTable.KeyInfo[Key].Released = true
		KeysTable.KeyInfo[Key].Held = false
		KeysTable.KeyInfo[Key].PressLength = 0
		KeysTable.KeyInfo[Key].RepeatLength = 0
		KeysTable.KeyInfo[Key].Repeating = false
	end
end

--- @param Key string @the name of the key to register
KeysTable.RegisterKey = function(Key)
	if KeysTable.KeyInfo[Key] == nil then
		KeysTable.KeyInfo[Key] = {
			Pressed = false,
			Released = false,
			Held = false,
			PressLength = 0,
			RepeatLength = 0,
			Repeating = false,
			Repeat = {
				Delay = 0,
				Repeat = 0
			}
		}
	end
end

--- @param Key string @the name of the key to change
--- @param Delay number @the number to set the keys delay to
--- @param Repeat number @the number to set the keys repeat to
--- @return boolean !string @boolean true for success, string for optianal error message
KeysTable.SetRepeatInfo = function(Key, Delay, Repeat)
	if KeysTable.KeyInfo[Key] == nil then
		return false, "Unknown Key"
	end
	KeysTable.KeyInfo[Key].Repeat = {Delay = Delay, Repeat = Repeat}
	return true
end

setmetatable(KeysTable, {__index = function(_, Key)
	return KeysTable.Get(Key)
end})

GLOBAL_SET_LOVE_KEYS = GLOBAL_SET_LOVE_KEYS or false
love = love or nil
if GLOBAL_SET_LOVE_KEYS then
	love.keypressed = function(Key)
		KeysTable.keypressed(Key)
	end
	love.keyreleased = function(Key)
		KeysTable.keyreleased(Key)
	end
end
GLOBAL_SET_LOVE_KEYS = nil
return KeysTable