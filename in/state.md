# Input state
Use the State module to keep track of the current state of actions such as if a key or game pad button is pressed or not.

# Usage
How you can use the State module is to create a unique instance. This is useful in multi-player games and when combining the State module with the Mapper module:

	local state = require "in.state"
	local mapper = require "in.mapper"

	function init(self)
		msg.post(".", "acquire_input_focus")
		self.state = state.create(1, 0.2)		-- key repeated every 0.2s(wait 1s for first time).
	end

	function update(self, dt)
		if self.state.is_pressed(hash("move_left")) then
			go.set_position(go.get_position() - vmath.vector3(50, 0, 0) * dt)
		elseif self.state.is_pressed(hash("move_right")) then
			go.set_position(go.get_position() + vmath.vector3(50, 0, 0) * dt)
		end
		-- alternative use
		if state.is_pressed(hash("fire"), self.state) then
			print("Pew pew!")
		end
		-- update state
		self.state.update(dt)
	end

	function on_input(self, action_id, action)
		self.state.on_input(mapper.on_input(action_id, 1), action)
		-- alternative use
		state.on_input(mapper.on_input(action_id, 1), action, self.state)
	end

# API

### state.acquire([instance])
Acquire input focus

### state.release([instance])
Release input focus

### state.on_input(action_id, action, [instance])
Register the state of an action_id

### state.is_pressed(action_id, [instance])
Check if an action_id is currently registered as pressed

**RETURN**
* ```result``` (boolean) - True if an action is currently registered as pressed
* ```pressed_time``` (number) - time to hold down
* ```released_time``` (number) - time to keep away


### state.is_repeated(action_id, [instance])
Check if an action_id is currently registered as repeated.

**RETURN**
* ```result``` (boolean) - True if an action is currently registered as repeated

### state.is_just_pressed(action_id, [instance])
Check if an action is just pressed or not

**RETURN**
* ```result``` (boolean) - True if an action_id is currently registered as just pressed
* ```released_time``` (number) - time to keep away

### state.is_just_released(action_id, [instance])
Check if an action is just released or not

**RETURN**
* ```result``` (boolean) - True if an action is currently registered as just released
* ```pressed_time``` (number) - time to hold down

### state.clear([instance])
Clear the state of any registered actions

### state.create([repeat_interval], [repeat_delay])
Create a unique instance of the state tracker

**PARAMETERS**
* ```repeat_interval``` (number) - time to repeat key (default 0.1)
* ```repeat_delay``` (number) - delay time to repeat key (default 0.5)

