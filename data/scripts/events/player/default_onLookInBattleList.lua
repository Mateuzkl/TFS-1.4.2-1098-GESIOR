local event = Event()
event.onLookInBattleList = function(self, creature, distance)
	local description = "You see " .. creature:getDescription(distance)
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
	
	-- Look KILL AND DEATH -- 
	if creature:isPlayer() and not creature:getGroup():getAccess() then
		-- Using storage values for kills and deaths (you can set these up in your server)
		local kills = creature:getStorageValue(30001) or 0  -- Storage for player kills
		local deaths = creature:getStorageValue(30002) or 0  -- Storage for player deaths
		local kdr

		if deaths == 0 then
			kdr = kills
		else
			kdr = kills / deaths
		end
		description = string.format("%s\nKilleds: [%d], Dieds: [%d] and KDR is [%.1f].", description, kills, deaths, kdr)
	end
	
	-- Look Show Health Monster in Percentage --
	if creature:isCreature() and creature:isMonster() then
		description = "".. description .."\nHealth: ["..math.floor((creature:getHealth() / creature:getMaxHealth()) * 100).."%]"
		self:sendTextMessage(MESSAGE_INFO_DESCR, description)
    end
	
	-- Look Experience Monsters --
	if creature:isCreature() and creature:isMonster() then
        local exp = creature:getType():getExperience() -- get monster experience
        exp = exp * Game.getExperienceStage(self:getLevel()) -- apply experience stage multiplier
        if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then -- check if stamina system is active on the server
            local staminaMinutes = self:getStamina()
            if staminaMinutes > 2340 and self:getStorageValue(30003) == 1 then -- 'happy hour' check (Storage for isCasting)
                exp = exp * 1.65
			elseif staminaMinutes > 2340 and self:getStorageValue(30003) == -1 then
				exp = exp * 1.5
            elseif staminaMinutes <= 840 and self:getStorageValue(30003) == 1 then -- low stamina check
                exp = exp * 0.8
			elseif staminaMinutes <= 840 and self:getStorageValue(30003) == -1 then
				exp = exp * 0.5
			-- Doble Exp	
			elseif staminaMinutes > 2340 and self:getStorageValue(30004) > 1 then -- Storage for potion XP
				exp = exp * 1.5
            end
        end
        description = string.format("%s\nEstimated of Exp: [%d]", description, exp)
	end
	
	-- Look Shop NPC -- 
	if (creature:isCreature() and creature:isNpc() and distance <= 3) then
		local description = "Are you talking to " .. creature:getDescription(distance)
		self:say("hi", TALKTYPE_PRIVATE_PN, false, creature)
		self:say("trade", TALKTYPE_PRIVATE_PN, false, creature)
		self:sendTextMessage(MESSAGE_INFO_DESCR, description)
		return false
	end
	
	-- Look Inspecting -- 
	if creature:isPlayer() and not self:getGroup():getAccess() then
        creature:sendTextMessage(MESSAGE_STATUS_DEFAULT,"The player [".. self:getName() .. '] looking at you.')
    end
	
	if self:getGroup():getAccess() then
		local str = "%s\nHealth: %d / %d"
		if creature:isPlayer() and creature:getMaxMana() > 0 then
			str = string.format("%s, Mana: %d / %d", str, creature:getMana(), creature:getMaxMana())
		end
		description = string.format(str, description, creature:getHealth(), creature:getMaxHealth()) .. "."

		local position = creature:getPosition()
		description = string.format(
			"%s\nPosition: %d, %d, %d",
			description, position.x, position.y, position.z
		)

		if creature:isPlayer() then
			description = string.format("%s\nIP: %s.", description, creature:getIp())
		end
	end
	-- Look Position -- 
		local position = creature:getPosition()
		description = string.format(
			"%s\nPosition: [X: %d], [Y: %d], [Z: %d].",
			description, position.x, position.y, position.z
		)
	return description
end

event:register()
