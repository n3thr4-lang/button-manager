--[[  

    button manager 
  made by: nethra
  check "n3thr4-lang" on github for use tutorial.
  
]]

--callbacks
local button_callbacks = require(script.callbacks)

-- ================================================================================
-- Button Manager Class
-- ================================================================================
local ButtonManager = {}
ButtonManager.__index = ButtonManager

function ButtonManager.new_button_list()
	return setmetatable({
		
		cache   = {},  -- [key] = {connections & threads}
		buttons = {},  -- [key] = GuiButton
		button_to_key = {}, -- basically reserved the buttons
		state = {}  --[[
		
		state[key] = {
		
	
		toggled = false,
		holding = false,
		enabled = button.interactable
		last_activation = "os.clock_thing",
		last_hold = "os.clock",
		last_release = "os.clock"
		
		}
		
		]]
		
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
	self.button_to_key[button] = final_key
	self.cache[final_key] = self.cache[final_key] or {}
	
	self.state[final_key] = {
		
		enabled  = button.Interactable,
		toggled  = false,
		holding  = false,
		
		last_activation = nil,
		last_hold = nil,
		last_release = nil
		
		
	}

	local destroy_conn = button.Destroying:Connect(function()
		self:remove_button(final_key)
	end)
	table.insert(self.cache[final_key], destroy_conn)

end


function ButtonManager:toggle_visibility(visible: boolean, key: string?)
	if not self.buttons then return end
	
	if typeof(key) == "Instance" and key:IsA("GuiButton") then
		key = self:get_key_from_button(key)
	end

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
	
	if typeof(key) == "Instance" and key:IsA("GuiButton") then
		key = self:get_key_from_button(key)
	end


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
	
	if typeof(key) == "Instance" and key:IsA("GuiButton") then
		key = self:get_key_from_button(key)
	end

	if not self.buttons[key] then
		warn("[ButtonManager] Button key not found:", key)
		return
	end

	local button_type = config.button_type
	
	if not button_type or not button_callbacks.button_function[button_type] then
		warn("[ButtonManager] Invalid or missing button_type")
		return
	end

	self:disable_button(key) 

	local target_visible = config.visible
	
	if target_visible == nil then
		
		target_visible = self.buttons[key].Visible
		
	end
	
	if config.reset_state then
		
		self:reset_state(key)
		
	end
	
	local button_state = self:get_button_state(key)

	button_callbacks.button_function[button_type](self.buttons[key], operator, key, self.cache, button_state, config)

	for i, v in pairs(operator) do

		if button_callbacks.interaction_hooks[i] then

			button_callbacks.interaction_hooks[i](self.buttons[key], operator, key, self.cache, button_state)

		end

	end


	self:toggle_visibility(target_visible, key)

end

function ButtonManager:get_button_state(key:any?)
	
	if not self.state then return end
	
	if typeof(key) == "Instance" and key:IsA("GuiButton") then
		key = self:get_key_from_button(key)
	end

	
	return self.state[key] or nil
	
end

function ButtonManager:reset_state(key)

	local function reset(button_state)
		
		button_state.toggled = false
		button_state.last_activation = nil
		button_state.last_hold = nil
		button_state.last_release = nil
		
	end

	if key then
		local button_state = self:get_button_state(key)
		if not button_state then return end
		reset(button_state)
	else
		for _, button_state in pairs(self.state) do
			reset(button_state)
		end
	end
	
	
end


function ButtonManager:get_key_from_button(button:GuiButton)
	
	if not button or not button:IsA("GuiButton") then return end
	if not self.button_to_key then return end
	
	return self.button_to_key[button] or nil
	
end

function ButtonManager:remove_button(key: string?)
	if not self.buttons then return end
	
	if typeof(key) == "Instance" and key:IsA("GuiButton") then
		key = self:get_key_from_button(key)
	end


	if key then
		if self.buttons[key] then
			self.button_to_key[self.buttons[key]] = nil
			self.buttons[key].Visible = false
			self:disable_button(key)
			self.buttons[key] = nil
			self.state[key] = nil
		end
	else

		for k, button in pairs(self.buttons) do
			self:disable_button(k)
		end
		table.clear(self.buttons)
		table.clear(self.state)
		table.clear(self.button_to_key)
	end
end


function ButtonManager:TERMINATE_EVERYTHING()
	self:remove_button()       
	self.cache = {}
	self.buttons = {}
	setmetatable(self, nil)
end

return ButtonManager




