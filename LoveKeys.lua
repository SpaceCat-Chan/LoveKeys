--- @class KeyInfo
--- @field public Pressed boolean @if the button was clicked this update cycle
--- @field public Released boolean @if the button was let go of this update cycle
--- @field public Held boolean @if button is being held down
--- @field public PressLength number @how long the button has been pressed for
--- @field private RepeatLength number @internal thing, don't touch
--- @field public Alias table<string, AliasInfo> @info about current alias settings
--- @field public Repeating boolean @if the button has begun repeating Clicks
--- @field public Repeat RepeatInfo @info about how the button repeats
local NothingSpecialHereJustADummy

--- @class RepeatInfo
--- @field public Delay number how long before the key starts repeating * NOTICE the first repeat comes when time reaches Delay, not Delay + Repeat
--- @field public Repeat number how long between each repeat
local OnceAgainAnotherDummyType____AAAAAAAAAA

--- @class AliasInfo
--- @field public From string[]
--- @field public To string[]
--- @field public Type string @allowed to be: or, and, nor, nand
local Finally_AnotherDummyType_ItHasBeenSoLongSinceILastAddedOne

local KeysTable = {
	--- @type table<string, KeyInfo>
	KeyInfo = {},
	--- @type table<string, fun(KeyName:string,Key:KeyInfo):nil>
	Event =  {},
	--- @type string
	CurrentAliasNamespace = "default"
}

local function SimpleCopy(table)
	if type(table) == "table" then
		local NewTable = {}
		for k,v in pairs(table) do
			NewTable[k] = SimpleCopy(v)
		end
		return NewTable
	end
	return table
end

--- @param Key string @the key that you want info about
--- @return KeyInfo @the requsted info about the key
KeysTable.Get = function(Key)
	if KeysTable.KeyInfo[Key] == nil then
		LoveKeys.RegisterKey(Key)
	end
	return {
		Pressed = KeysTable.KeyInfo[Key].Pressed,
		Released = KeysTable.KeyInfo[Key].Released,
		Held = KeysTable.KeyInfo[Key].Held,
		PressLength = KeysTable.KeyInfo[Key].PressLength,
		Repeating = KeysTable.KeyInfo[Key].Repeating,
		Alias = SimpleCopy(KeysTable.KeyInfo[Key].Alias),
		Repeat = {
			Delay = KeysTable.KeyInfo[Key].Repeat.Delay,
			Repeat = KeysTable.KeyInfo[Key].Repeat.Repeat
		}
	}
end

KeysTable.GetSingleKeyAliasUpdateInfo = function(KeyInfo)
	local ToAliasPress
	local ToAliasUnpress
	local KeyAlias = KeyInfo.Alias[KeysTable.CurrentAliasNamespace]
	if KeyAlias and #KeyAlias.From ~= 0 then
		local RunningResult
		for _,Key in pairs(KeyAlias.From) do
			if KeyAlias.Type == "and" or KeyAlias.Type == "nand" then
				if (RunningResult or true) and KeysTable.KeyInfo[Key].Held then
					RunningResult = true
				else
					RunningResult = false
					break
				end
			end
			if KeyAlias.Type == "or" or KeyAlias.Type == "nor" then
				if(RunningResult or false) or KeysTable.KeyInfo[Key].Held then
					RunningResult = true
				else
					RunningResult = false
				end
			end
		end
		if KeyAlias.Type == "nor" or KeyAlias.Type == "nand" then
			RunningResult = not RunningResult
		end
		if RunningResult then
			if KeyInfo.Held == false then
				ToAliasPress = true
			end
		else
			if KeyInfo.Held == true then
				ToAliasUnpress = true
			end
		end
	end
	return ToAliasPress, ToAliasUnpress
end

KeysTable.ExecuteAliasKeyUpdate = function(k, ToAliasPress, ToAliasUnpress)
	if ToAliasPress then
		KeysTable.keypressed(k)
	end
	if ToAliasUnpress then
		KeysTable.keyreleased(k)
	end
end

KeysTable.SingleKeyTimingUpdate = function(dt, k, KeyInfo, Suppress)
	if KeyInfo.Held and not Suppress then
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

KeysTable.TimingUpdate = function(dt)
	for k,KeyInfo in pairs(KeysTable.KeyInfo) do
		KeysTable.SingleKeyTimingUpdate(dt, k, KeyInfo, false)
	end
end

KeysTable.AliasUpdate = function()
	for k,KeyInfo in pairs(KeysTable.KeyInfo) do
		local ToAliasPress, ToAliasUnpress = KeysTable.GetSingleKeyAliasUpdateInfo(KeyInfo)
		KeysTable.ExecuteAliasKeyUpdate(k, ToAliasPress, ToAliasUnpress)
	end
end

-- this function should be called at the end of the love.update function
--- @param dt number @the amount of time since the last call to this function
KeysTable.update = function(dt)
	for k,KeyInfo in pairs(KeysTable.KeyInfo) do
		-- alias handeling
		local ToAliasPress, ToAliasUnpress = KeysTable.GetSingleKeyAliasUpdateInfo(KeyInfo)

		-- general other things handeling
		KeysTable.SingleKeyTimingUpdate(dt, k, KeyInfo, ToAliasPress or ToAliasUnpress)

		KeysTable.ExecuteAliasKeyUpdate(k, ToAliasPress, ToAliasUnpress)
	end
end

-- this function should be called in love.keypressed
--- @param Key string @the name of key that was pressed
KeysTable.keypressed = function(Key)
	if KeysTable.KeyInfo[Key] == nil then
		LoveKeys.RegisterKey(Key)
		KeysTable.KeyInfo[Key].Pressed = true
		KeysTable.KeyInfo[Key].Held = true
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
		LoveKeys.RegisterKey(Key)
		KeysTable.KeyInfo[Key].Released = true
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
			Alias = {},
			Repeat = {
				Delay = 0,
				Repeat = 0
			}
		}
	end
end

local function SetupAlias(KeyName, Namespace)
	Namespace = Namespace or KeysTable.CurrentAliasNamespace
	if KeysTable.KeyInfo[KeyName].Alias[Namespace] == nil then
		local KeyAlias = KeysTable.KeyInfo[KeyName].Alias
		KeyAlias[Namespace] = {
			From = {},
			To = {},
			Type = "or"
		}
	end
end

--- @param From string[]|string @a list of keys to alias from
--- @param To string[]|string @a list of keys to alias to
--- @param Type string|nil @the type of aliasing that should be created, supported things are: or, nor, and, nand
--- @return nil
KeysTable.Alias = function(From, To, Type, Namespace)
	Type = Type or "or"
	Namespace = Namespace or KeysTable.CurrentAliasNamespace
	if type(From) ~= "table" then
		From = {From}
	end
	if type(To) ~= "table" then
		To = {To}
	end
	for _,Key in pairs(From) do
		if LoveKeys.KeyInfo[Key] == nil then
			LoveKeys.RegisterKey(Key)
		end
		SetupAlias(Key, Namespace)
		local ToAdd = {}
		for _,FindKey in pairs(To) do
			local Found=false
			for _,CheckKey in pairs(KeysTable.KeyInfo[Key].Alias[Namespace].To) do
				if CheckKey == FindKey then
					Found = true
					break
				end
			end
			if not Found then
				table.insert(ToAdd, FindKey)
			end
		end
		for _,v in pairs(ToAdd) do --don't have table.move, this is good enough
			table.insert(KeysTable.KeyInfo[Key].Alias[Namespace].To, v)
		end
	end
	for _,Key in pairs(To) do
		if LoveKeys.KeyInfo[Key] == nil then
			LoveKeys.RegisterKey(Key)
		end
		SetupAlias(Key, Namespace)
		local ToRemoveFrom = {}
		for _,FindKey in pairs(KeysTable.KeyInfo[Key].Alias[Namespace].From) do
			local Found = false
			for _,CheckKey in pairs(From) do
				if FindKey == CheckKey then
					Found = true
					break
				end
			end
			if not Found then
				table.insert(ToRemoveFrom, FindKey)
			end
		end
		for _,KeyRemoveFrom in pairs(ToRemoveFrom) do
			for Index,RemoveCandidate in pairs(KeysTable.KeyInfo[KeyRemoveFrom].Alias[Namespace].To) do
				if RemoveCandidate == Key then
					KeysTable.KeyInfo[KeyRemoveFrom].Alias[Namespace].To[Index] = nil
					break
				end
			end
		end
		KeysTable.KeyInfo[Key].Alias[Namespace].From = From
		KeysTable.KeyInfo[Key].Alias[Namespace].Type = Type
		local ToAliasPress, ToAliasUnpress = KeysTable.GetSingleKeyAliasUpdateInfo(KeysTable.KeyInfo[Key])
		KeysTable.ExecuteAliasKeyUpdate(Key, ToAliasPress, ToAliasUnpress)
	end
end

KeysTable.SetAliasNamespace = function(Namespace)
	KeysTable.CurrentAliasNamespace = Namespace
	KeysTable.AliasUpdate()
end

--- @param Key string @the name of the key to change
--- @param Delay number @the number to set the keys delay to
--- @param Repeat number @the number to set the keys repeat to
--- @return nil
KeysTable.SetRepeatInfo = function(Key, Delay, Repeat)
	if KeysTable.KeyInfo[Key] == nil then
		KeysTable.RegisterKey(Key)
	end
	KeysTable.KeyInfo[Key].Repeat = {Delay = Delay, Repeat = Repeat}
end

setmetatable(KeysTable, {__index = function(_, Key)
	return KeysTable.Get(Key)
end})

GLOBAL_SET_LOVE_KEYS = GLOBAL_SET_LOVE_KEYS or false
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