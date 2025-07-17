local loginMessage = CreatureEvent("loginMessage")
function loginMessage.onLogin(player)
    -- Log no console
    print(string.format("[LOGIN] Player %s has logged in.", player:getName()))

    local serverName = configManager.getString(configKeys.SERVER_NAME)
    local loginStr = "Welcome to " .. serverName .. "!"

    if player:getLastLoginSaved() <= 0 then
        loginStr = loginStr .. " Please choose your outfit."
        player:sendOutfitWindow()
    else
        loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
        player:sendTextMessage(MESSAGE_EVENT_ORANGE, "Welcome to " .. serverName .. "!")
    end

    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
	
	
	-- Notify player about the rewards in their reward chest
	local rewardChest = player:getRewardChest()
	local rewardContainerCount = 0
	for _, item in ipairs(rewardChest:getItems()) do
		if item:getId() == ITEM_REWARD_CONTAINER then
			rewardContainerCount = rewardContainerCount + 1
		end
	end
	if rewardContainerCount > 0 then
		player:sendTextMessage(MESSAGE_STATUS_DEFAULT, string.format("You have %d reward%s in your reward chest.", rewardContainerCount, rewardContainerCount > 1 and "s" or ""))
	end

    -- Promotion handling
    local vocation = player:getVocation()
    local promotion = vocation:getPromotion()
    if player:isPremium() then
        local value = player:getStorageValue(PlayerStorageKeys.promotion)
        if value == 1 then
            player:setVocation(promotion)
        end
    elseif not promotion then
        player:setVocation(vocation:getDemotion())
    end

    -- Display Bank Balance
    local balance = player:getBankBalance()
    if balance > 0 then
        local formattedBalance = formatNumber(balance)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your Bank Balance is: $" .. formattedBalance .. " gold coins.")
    end

    -- Inbox Notification
    local inboxItems = player:getInbox():getItemHoldingCount()
    if inboxItems > 0 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
            "Check the inbox, you have %d item%s.", inboxItems, inboxItems > 1 and "s" or ""
        ))
    end

    -- Open chat channels
    local channels = {2, 6, 12, 7, 8, 9} -- Global, Trade Market, Quest, Advertising, Changelog, Help
    for _, channelId in ipairs(channels) do
        player:openChannel(channelId)
    end

    return true
end
loginMessage:register()

local logoutMessage = CreatureEvent("logoutMessage")
function logoutMessage.onLogout(player)
    -- Log no console
    print(string.format("[LOGOUT] Player %s has logged out.", player:getName()))

    -- Clear stamina cooldown entry if it exists
    if nextUseStaminaTime and nextUseStaminaTime[player:getId()] then
        nextUseStaminaTime[player:getId()] = nil
    end

    return true
end
logoutMessage:register()
