--add this in commandHandler.lua



  elseif cmd[1] == "trottiner" then	
		local PlayerSpeedBase = Players[pid].data.customVariables.PlayerSpeedBase
		local PlayerSpeedCurrently = Players[pid].data.attributes.Speed
		if PlayerSpeedBase == nil then
			PlayerSpeedBase = PlayerSpeedCurrently
		end
		Players[pid].data.attributes.Speed = Players[pid].data.customVariables.PlayerSpeedBase / 8		
		Players[pid].data.customVariables.PlayerSpeedBase = PlayerSpeedBase	
		Players[pid]:LoadAttributes()
		
	elseif cmd[1] == "courir" then	
		local PlayerSpeedBase = Players[pid].data.customVariables.PlayerSpeedBase
		local PlayerSpeedCurrently = Players[pid].data.attributes.Speed
		if PlayerSpeedBase == nil then
			PlayerSpeedBase = PlayerSpeedCurrently
		end
		Players[pid].data.attributes.Speed = Players[pid].data.customVariables.PlayerSpeedBase / 4			
		Players[pid].data.customVariables.PlayerSpeedBase = PlayerSpeedBase	
		Players[pid]:LoadAttributes()
		
	elseif cmd[1] == "sprinter" then	
		local PlayerSpeedBase = Players[pid].data.customVariables.PlayerSpeedBase
		local PlayerSpeedCurrently = Players[pid].data.attributes.Speed
		if PlayerSpeedBase == nil then
			PlayerSpeedBase = PlayerSpeedCurrently
		end
		Players[pid].data.attributes.Speed = PlayerSpeedBase		
		Players[pid].data.customVariables.PlayerSpeedBase = PlayerSpeedBase	
		Players[pid]:LoadAttributes()