local utils = {}

utils.get_snapshot = function(state)
	
	return {
		
		enabled  = state.enabled,
		cooldown = state.cooldown,
		toggled  = state.toggled,
		holding  = state.holding,
		last_hold = state.last_hold,
		last_release = state.last_release,
		last_activation = state.last_activation
		
	}
	
end

return utils