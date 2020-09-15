--- Refer to state.md for documentation

local M = {}

--- Create an instance of the input state tracker
-- @return State instance
function M.create(repeat_interval, repeat_delay)
	local instance = {}

	local action_map = {}

	local repeat_interval = repeat_interval or 0.1
	local repeat_delay = repeat_delay or 0.5

	--- Acquire input focus for the current script
	-- @param url
	function instance.acquire(url)
		msg.post(url or ".", "acquire_input_focus")
		action_map = {}
	end

	--- Release input focus for the current script
	-- @param url
	function instance.release(url)
		msg.post(url or ".", "release_input_focus")
		action_map = {}
	end

	--- Check if an action is currently pressed or not
	-- @param action_id
	-- @return true if action_id is pressed
	-- @return pressed time
	-- @return relesed time
	function instance.is_pressed(action_id)
		assert(action_id, "You must provide an action_id")
		action_id = type(action_id) == "string" and hash(action_id) or action_id
		if not action_map[action_id] then return false,0 end
		return action_map[action_id].pressed
		,action_map[action_id].pressed_time
		,action_map[action_id].released_time
	end

	--- Check if an action is currently repeated or not
	-- @param action_id
	-- @return true if action_id is repeated
	function instance.is_repeated(action_id)
		assert(action_id, "You must provide an action_id")
		action_id = type(action_id) == "string" and hash(action_id) or action_id
		if not action_map[action_id] then return false,0 end
		return action_map[action_id].pressed and action_map[action_id].repeat_time == 0
	end

	--- Check if an action is just pressed or not
	-- @param action_id
	-- @return true if action_id is just pressed
	-- @return relesed time
	function instance.is_just_pressed(action_id)
		assert(action_id, "You must provide an action_id")
		action_id = type(action_id) == "string" and hash(action_id) or action_id
		if not action_map[action_id] then return false,0 end
		return action_map[action_id].pressed and action_map[action_id].pressed_time == 0
		,action_map[action_id].released_time
	end

	--- Check if an action is just released or not
	-- @param action_id
	-- @return true if action_id is just released
	-- @return pressed time
	function instance.is_just_released(action_id)
		assert(action_id, "You must provide an action_id")
		action_id = type(action_id) == "string" and hash(action_id) or action_id
		if not action_map[action_id] then return false,0 end
		return not action_map[action_id].pressed and action_map[action_id].released_time == 0
		,action_map[action_id].pressed_time
	end

	--- Forward any calls to on_input from scripts using this module
	-- @param action_id
	-- @param action
	function instance.on_input(action_id, action)
		assert(action, "You must provide an action")
		if action_id then
			action_id = type(action_id) == "string" and hash(action_id) or action_id
			if action.pressed then
				if not action_map[action_id] then
					action_map[action_id] = {pressed = true, pressed_time = 0, released_time = 0, repeat_time = 0, repeat_count = 0}
				elseif not action_map[action_id].pressed then
					action_map[action_id].pressed = true
					action_map[action_id].pressed_time = 0
					action_map[action_id].repeat_time = 0
					action_map[action_id].repeat_count = 0
				end
			elseif action.released then
				if not action_map[action_id] then
					action_map[action_id] = {pressed = false, pressed_time = 0, released_time = 0, repeat_time = 0, repeat_count = 0}
				elseif action_map[action_id].pressed then
					action_map[action_id].pressed = false
					action_map[action_id].released_time = 0
					action_map[action_id].repeat_time = 0
					action_map[action_id].repeat_count = 0
				end
			end
		end
	end

	function instance.update(dt)
		for action_id, value in pairs(action_map) do
			if action_map[action_id] then
				if action_map[action_id].pressed then
					action_map[action_id].pressed_time = action_map[action_id].pressed_time + dt
					action_map[action_id].repeat_time = action_map[action_id].repeat_time + dt
					if (action_map[action_id].repeat_count == 0 and action_map[action_id].repeat_time >= repeat_delay)
					or (action_map[action_id].repeat_count >= 1 and action_map[action_id].repeat_time >= repeat_interval) then
						action_map[action_id].repeat_time = 0
						action_map[action_id].repeat_count = action_map[action_id].repeat_count + 1
					end
				else
					action_map[action_id].released_time = action_map[action_id].released_time + dt
				end
			end
		end
	end

	--- Clear the state of any currently tracked input states
	function instance.clear()
		action_map = {}
	end

	return instance
end

local singleton = M.create()

--- Acquire input focus for the current script and clear state
-- @param url
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.acquire(url, instance)
	instance = instance or singleton
	return instance.acquire(url)
end

--- Release input focus for the current script and clear state
-- @param url
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.release(url, instance)
	instance = instance or singleton
	return instance.release(url)
end

--- Check if an action is pressed/active
-- @param action_id
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
-- @return true if pressed/active
function M.is_pressed(action_id, instance)
	instance = instance or singleton
	return instance.is_pressed(action_id)
end

--- Check if an action is currently repeated or not
-- @param action_id
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
-- @return true if action_id is repeated
function M.is_repeated(action_id, instance)
	instance = instance or singleton
	return instance.is_repeated(action_id)
end

--- Check if an action is just pressed or not
-- @param action_id
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
-- @return true if action_id is just pressed
-- @return relesed time
function M.is_just_pressed(action_id, instance)
	instance = instance or singleton
	return instance.is_just_pressed(action_id)
end

--- Check if an action is just released or not
-- @param action_id
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
-- @return true if action_id is just released
-- @return pressed time
function M.is_just_released(action_id, instance)
	instance = instance or singleton
	return instance.is_just_released(action_id)
end


--- Forward any calls to on_input from scripts using this module
-- @param action_id
-- @param action
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.update(dt, instance)
	instance = instance or singleton
	return instance.update(dt)
end

--- Forward any calls to on_input from scripts using this module
-- @param action_id
-- @param action
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.on_input(action_id, action, instance)
	instance = instance or singleton
	return instance.on_input(action_id, action)
end

--- Clear the state of any currently tracked input states
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.clear(instance)
	instance = instance or singleton
	instance.clear()
end

return M
