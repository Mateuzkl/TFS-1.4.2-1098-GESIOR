local event = Event()
event.onTurn = function(self, direction)
	if self:getGroup():getAccess() and self:getDirection() == direction then
        local nextPosition = self:getPosition()
        nextPosition:getNextPosition(direction)
        self:teleportTo(nextPosition, true)
		self:getPosition(): sendMagicEffect(CONST_ME_TELEPORT)
    end
	return true
end

event:register()
