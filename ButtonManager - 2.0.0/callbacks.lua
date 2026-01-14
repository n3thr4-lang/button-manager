--utils
local utils = require(script.utils)

local button_callbacks = {}

button_callbacks.button_function = {
	
	single_press = function(button: GuiButton, operator, key: string, cache, state, config: any)

		cache[key] = cache[key] or {}
		
		table.insert(cache[key], button.MouseButton1Click:Connect(function()
			
			state.last_activation = os.clock()
			
			if operator.fire then
				operator.fire(button, utils.get_snapshot(state))
			end
		
		end))
		
	end,

	hold = function(button: GuiButton, operator, key: string, cache, state, config: any)

		cache[key] = cache[key] or {}
		table.insert(cache[key], button.MouseButton1Down:Connect(function(x,y)
			
			if operator.hold then
				
				state.last_hold = os.clock()
				state.holding = true
				operator.hold(true, button,x,y,utils.get_snapshot(state))
				
			end
			
		end))

		table.insert(cache[key], button.MouseButton1Up:Connect(function(x,y)
			
			if operator.release then
				
				state.holding = false
				state.last_release = os.clock()
				operator.release(false, button,x,y,utils.get_snapshot(state))
				
			end
			
		end))
	end,

	toggle = function(button: GuiButton, operator, key: string, cache, state, config: any)

		state.toggled = config.state or state.toggled or false

		cache[key] = cache[key] or {}

		table.insert(cache[key], button.MouseButton1Click:Connect(function()

			state.toggled = not state.toggled
			state.last_activation = os.clock()

			if state.toggled then

				if operator.toggle then
					operator.toggle(true, button, utils.get_snapshot(state))
				end
				
			else
				if operator.untoggle then
					operator.untoggle(false, button, utils.get_snapshot(state))
				end
			end

		end))
	end,

	long_press = function(button: GuiButton, operator, key: string, cache, state, config: any)

		cache[key] = cache[key] or {}
		local time_take = config.time_take or 0.5
		local current_task: thread?

		table.insert(cache[key], button.MouseButton1Down:Connect(function(x,y)
			
			state.last_hold = os.clock()

			if current_task then -- for guarding
				task.cancel(current_task)
				current_task = nil
			end

			if operator.start_pressing then
				operator.start_pressing(button,x,y, utils.get_snapshot(state))
			end

			current_task = task.delay(time_take, function(x,y)
				if button and button.Parent then 
					state.last_activation = os.clock()
					if operator.finished then
						operator.finished(button,x,y,utils.get_snapshot(state))
					end
					current_task = nil
				end
			end)

		end))

		table.insert(cache[key], button.MouseButton1Up:Connect(function(x,y)
			
			state.last_release = os.clock()
			
			if operator.stopped_pressing then
				operator.stopped_pressing(button,x,y,utils.get_snapshot(state))
			end

			if current_task then
				if operator.cancelling then
					operator.cancelling(button,x,y,utils.get_snapshot(state))
				end
				task.cancel(current_task)
				current_task = nil
			end

		end))
	end,
}

button_callbacks.interaction_hooks = {

	enter = function(button: GuiButton, operator, key, cache, state)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseEnter:Connect(function(x,y)
				if operator.enter then
					operator.enter(button, x , y, utils.get_snapshot(state))
				end
			end)
		)
	end,

	leave = function(button: GuiButton, operator, key, cache, state)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseLeave:Connect(function(x,y)
				if operator.leave then
					operator.leave(button, x, y, utils.get_snapshot(state))
				end
			end)
		)
	end,

	down = function(button: GuiButton, operator, key, cache, state)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseButton1Down:Connect(function()
				if operator.down then
					operator.down(button, utils.get_snapshot(state))
				end
			end)
		)
	end,

	up = function(button: GuiButton, operator, key, cache, state)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseButton1Up:Connect(function()
				if operator.up then
					operator.up(button, utils.get_snapshot(state))
				end
			end)
		)
	end,

	on_toggle = function(button: GuiButton, operator, key, cache, state)
		if operator.on_toggle then
			operator.on_toggle(button, utils.get_snapshot(state))
		end
	end,
}


return button_callbacks
