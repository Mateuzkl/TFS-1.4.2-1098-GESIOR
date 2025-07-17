local event = Event()
event.onJoin = function(self, skill, tries)
	-- Empty
	return true
end

event:register()