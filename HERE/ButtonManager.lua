--[[  

    button manager 
  made by: nethra
  check "n3thr4-lang" on github for use tutorial.
  
]]

local button_function = {
	single_press = function(button: GuiButton, operator, key: string, cache)

		cache[key] = cache[key] or {}
		table.insert(cache[key], button.MouseButton1Click:Connect(function()
			if operator.fire then
				operator.fire(button)
			end
		end))
	end,

	hold = function(button: GuiButton, operator, key: string, cache)

		cache[key] = cache[key] or {}
		table.insert(cache[key], button.MouseButton1Down:Connect(function()
			if operator.hold then
				operator.hold(true, button)
			end
		end))

		table.insert(cache[key], button.MouseButton1Up:Connect(function()
			if operator.release then
				operator.release(false, button)
			end
		end))
	end,

	toggle = function(button: GuiButton, operator, key: string, cache, config: any)

		local current_state = config.state or false

		cache[key] = cache[key] or {}

		table.insert(cache[key], button.MouseButton1Click:Connect(function()

			current_state = not current_state

			if current_state then

				if operator.toggle then
					operator.toggle(true, button)
				end
			else
				if operator.untoggle then
					operator.untoggle(false, button)
				end
			end

		end))
	end,

	long_press = function(button: GuiButton, operator, key: string, cache, config: any)

		cache[key] = cache[key] or {}
		local time_take = config.time_take or 0.5
		local current_task: thread?

		table.insert(cache[key], button.MouseButton1Down:Connect(function()

			if current_task then -- for guarding
				task.cancel(current_task)
				current_task = nil
			end

			if operator.start_pressing then
				operator.start_pressing(button)
			end

			current_task = task.delay(time_take, function()
				if button and button.Parent then 
					if operator.finished then
						operator.finished(button)
					end
					current_task = nil
				end
			end)

		end))

		table.insert(cache[key], button.MouseButton1Up:Connect(function()
			if operator.stopped_pressing then
				operator.stopped_pressing(button)
			end

			if current_task then
				if operator.cancelling then
					operator.cancelling(button)
				end
				task.cancel(current_task)
				current_task = nil
			end

		end))
	end,
}

local interaction_hooks = {

	enter = function(button: GuiButton, operator, key, cache)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseEnter:Connect(function()
				if operator.enter then
					operator.enter(button)
				end
			end)
		)
	end,

	leave = function(button: GuiButton, operator, key, cache)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseLeave:Connect(function()
				if operator.leave then
					operator.leave(button)
				end
			end)
		)
	end,

	down = function(button: GuiButton, operator, key, cache)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseButton1Down:Connect(function()
				if operator.down then
					operator.down(button)
				end
			end)
		)
	end,

	up = function(button: GuiButton, operator, key, cache)
		cache[key] = cache[key] or {}

		table.insert(cache[key],
			button.MouseButton1Up:Connect(function()
				if operator.up then
					operator.up(button)
				end
			end)
		)
	end,

	on_toggle = function(button: GuiButton, operator, key, cache)
		if operator.on_toggle then
			operator.on_toggle(button)
		end
	end,
}


-- ================================================================================
-- Button Manager Class
-- ================================================================================
local ButtonManager = {}
ButtonManager.__index = ButtonManager

function ButtonManager.new_button_list()
	return setmetatable({
		cache   = {},  -- [key] = {connections & threads}
		buttons = {},  -- [key] = GuiButton
	}, ButtonManager)
end


function ButtonManager:add_button(button: GuiButton, key: string?)
	if not button or not button:IsA("GuiButton") then
		warn("[ButtonManager] Invalid GuiButton provided")
		return
	end

	local final_key = key or button.Name
	if self.buttons[final_key] then
		return 
	end

	self.buttons[final_key] = button
	self.cache[final_key] = self.cache[final_key] or {}


	local destroy_conn = button.Destroying:Connect(function()
		self:remove_button(final_key)
	end)
	table.insert(self.cache[final_key], destroy_conn)

end


function ButtonManager:toggle_visibility(visible: boolean, key: string?)
	if not self.buttons then return end

	if key then
		if self.buttons[key] then
			self.buttons[key].Visible = visible
		end
	else
		for _, button in pairs(self.buttons) do
			button.Visible = visible
		end
	end
end


function ButtonManager:disable_button(key: string?)
	if not self.cache or not self.buttons then return end

	if key then

		if not self.cache[key] then return end

		for _, obj in pairs(self.cache[key]) do
			if typeof(obj) == "RBXScriptConnection" then
				obj:Disconnect()
			elseif typeof(obj) == "thread" then
				task.cancel(obj)
			end
		end
		table.clear(self.cache[key])

	else

		for k, connections in pairs(self.cache) do
			for _, obj in pairs(connections) do
				if typeof(obj) == "RBXScriptConnection" then
					obj:Disconnect()
				elseif typeof(obj) == "thread" then
					task.cancel(obj)
				end
			end
			table.clear(connections)
		end
	end
end


function ButtonManager:Activate_button(key: string, operator: table, config: table)
	if not self.buttons[key] then
		warn("[ButtonManager] Button key not found:", key)
		return
	end

	local button_type = config.button_type
	if not button_type or not button_function[button_type] then
		warn("[ButtonManager] Invalid or missing button_type")
		return
	end

	self:disable_button(key) 

	local target_visible = config.visible
	if target_visible == nil then
		target_visible = self.buttons[key].Visible
	end

	button_function[button_type](self.buttons[key], operator, key, self.cache, config)

	for i, v in pairs(operator) do

		if interaction_hooks[i] then

			interaction_hooks[i](self.buttons[key], operator, key, self.cache)

		end

	end


	self:toggle_visibility(target_visible, key)

end


function ButtonManager:remove_button(key: string?)
	if not self.buttons then return end

	if key then
		if self.buttons[key] then
			self.buttons[key].Visible = false
			self:disable_button(key)
			self.buttons[key] = nil
		end
	else

		for k, button in pairs(self.buttons) do
			self:disable_button(k)
			self.buttons[k] = nil
		end
		table.clear(self.buttons)
	end
end


function ButtonManager:TERMINATE_EVERYTHING()
	self:remove_button()       
	self.cache = {}
	self.buttons = {}
	setmetatable(self, nil)
end

return ButtonManager





