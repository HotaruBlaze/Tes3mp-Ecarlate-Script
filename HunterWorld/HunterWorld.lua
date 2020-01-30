---------------------------
--[[
HunterWorld by Rickoff
tes3mp 0.7.0
---------------------------
DESCRIPTION :
add 100 random spawn point for creature or npc
price 1k gold for all players connected after a timers
when a boss creature appears the players receive a message
when a player kills the boss he receives a reward and the message displays that a rare creature was killed
add a creatures by native spawn with a random list
resfresh all creature and npc after a timers
---------------------------
INSTALLATION:
Save the file as HunterWorld.lua inside your server/scripts/custom folder.

Edits to customScripts.lua
HunterWorld = require("custom.HunterWorld")
]]
---------------------------
tableHelper = require("tableHelper")
inventoryHelper = require("inventoryHelper")
jsonInterface = require("jsonInterface")

-- ===========
--MAIN CONFIG
-- ===========
-------------------------
local config = {}
--blacklist cell for protect to spawnadd some native spawn
config.blackList = {"-3, -1", "-3, -2", "-3, -3", "-4, -3", "-4, -4", "-2, -1", "Mine d'oeufs de Shulk", "Mine d'oeufs de Shulk, antre de la reine", "Jarvik, Port", "Jarvik, Brasseurs, Quartier",
 "Jarvik, Vieux Quartier", "Ald'ruhn, temple", "Gnisis, temple", "Balmora, temple"}

--blacklist nativespawn creature for protect spawnadd 
config.blackListCrea = {"bm_werewolf_default", "bm_horker_swim_unique", "bm_horker_large", "bm_horker", "a_ss_skeletal_mannequin", "raz_reddragon", "raz_bluedragon", "raz_adult_blackdragon", "raz_adult_greendragon", "plx_vamphunter1", "plx_vamphunter2", "plx_vamphunter3", "plx_vamphunter4", "plx_vamphunter5", "plx_wolfhunter1", "plx_wolfhunter2", "plx_wolfhunter3",
 "plx_wolfhunter4", "plx_wolfhunter5", "cait_seagull01", "cait_seagull02", "cait_seagull03", "sparrow1", "sparrow2", "sparrow3", "squirrel1", "squirrel2", "squirrel3",
 "plx_butterfly", "plx_butterfly2", "chickadee", "goldfinch1", "goldfinch2", "robin", "slaughterfish", "slaughterfish_small", "plx_razorfish", "plx_aqua netch", "plx_seahorse",
 "dreugh", "plx_slaughtershark", "bm_wolf_grey", "bm_wolf_red", "ancestor_ghost_summon", "atronach_flame_summon", "atronach_frost_summon", "atronach_storm_summon",
 "bm_bear_black_summon", "bm_wolf_grey_summon", "bonelord_summon", "bonewalker_summon", "centurion_sphere_summon", "clannfear_summon", "daedroth_summon",
 "dremora_summon", "fabricant_summon", "golden saint_summon", "hunger_summon", "scamp_summon", "skeleton_summon", "winged twilight_summon", "bm_wolf_bone_summon", "cait_shark02"}
 
config.seacrea = {"plx_slaughtershark", "dreugh"}
--timer spawn creature with random spawn point
config.timerSpawn = 120
--timer price
config.timerPrice = 3600
--price when players kill a boss
config.timerClean = 3600*6
--timer for clean cell
config.count = 5000
--list id boss
config.bosses = {"ecarlate_bandit_04", "ecarlate_bandit_03", "ecarlate_bandit_02", "ecarlate_bandit_01"}
--timer for respawn all npc and creature in cell
config.timerRespawn = 1800

local cellTable = jsonInterface.load("EcarlateCreaturesSpawn.json")
local creatureTable = jsonInterface.load("EcarlateCreatures.json")
local TimerEvent = tes3mp.CreateTimer("EventSpawn", time.seconds(config.timerSpawn))
local TimerPrice = tes3mp.CreateTimer("EventPrice", time.seconds(config.timerPrice))
local TimerClean = tes3mp.CreateTimer("EventClean", time.seconds(config.timerClean))
	
HunterWorld = {}

HunterWorld.TimerEventWorld = function(eventStatus)	
	tes3mp.StartTimer(TimerEvent)
	tes3mp.StartTimer(TimerPrice)
	tes3mp.StartTimer(TimerClean)
	tes3mp.LogAppend(enumerations.log.INFO, "....START TIMER HUNTER WORLD....")		
end 

function EventSpawn()	
	local creatureRefId
	local creaturename
	local cellId
	local posx
	local posy
	local posz
	local packetType = "spawn"	
	local rando1 = math.random(1, 193)
	local rando2 = math.random(1, 100)
	
	for slot1, creature in pairs(creatureTable.creatures) do
		if slot1 == rando1 then
			creatureRefId = creature.Refid
			creaturename = creature.name
		end
	end

	for slot2, cell in pairs(cellTable.cells) do
		if slot2 == rando2 then
			cellId = cell.Refid
			posx = cell.Posx
			posy = cell.Posy
			posz = cell.Posz
		end
	end

	if creatureRefId ~= nil and cellId ~= nil and posx ~= nil and posy ~= nil and posz ~= nil then
		local message = color.Red.. "Attention " ..color.Yellow..creaturename..color.Default.. " a fait une apparition dans la zone " ..color.Yellow..cellId.. "\n"
		if tableHelper.getCount(Players) > 0 then
			if tableHelper.containsValue(config.bosses, creatureRefId) then
				tes3mp.SendMessage(tableHelper.getAnyValue(Players).pid, message, true)
			end
		end
		local position = { posX = tonumber(posx), posY = tonumber(posy), posZ = tonumber(posz), rotX = 0, rotY = 0, rotZ = 0 }
		tes3mp.LogMessage(2, "Spawn")
		tes3mp.LogMessage(2, creatureRefId)
		tes3mp.LogMessage(2, cellId)
		logicHandler.CreateObjectAtLocation(cellId, position, creatureRefId, packetType)
	else
		tes3mp.LogMessage(2, "Restart")		
	end

	tes3mp.RestartTimer(TimerEvent, time.seconds(config.timerSpawn))
end	

function EventPrice()	
	for pid, player in pairs(Players) do
		if Players[pid] ~= nil and player:IsLoggedIn() then	
			local message = color.Gold.. "Votre récompense vient d'être versé dans votre inventaire pour votre temps passé en jeu, merci.\n"
			tes3mp.SendMessage(pid, message, false)	
			local player = Players[pid]
			local goldL = inventoryHelper.getItemIndex(player.data.inventory, "gold_001", -1)			
			if goldL ~= nil then
				local item = player.data.inventory[goldL]
				local refId = item.refId
				local count = item.count
				local rest = (item.count + 1000)
				player.data.inventory[goldL] = {refId = "gold_001", count = rest, charge = -1, soul = ""}			
			else
				table.insert(Players[pid].data.inventory, {refId = "gold_001", count = 1000, charge = -1, soul = ""})
			end	
			local itemref = {refId = "gold_001", count = 1000, charge = -1, soul = ""}			
			Players[pid]:SaveToDrive()
			Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)					
		end
	end
	tes3mp.RestartTimer(TimerPrice, time.seconds(config.timerPrice))
end

function EventClean()
	for slot2, cell in pairs(cellTable.cells) do
		cellDescription = cell.Refid
		if cellDescription ~= nil then
			local cell = LoadedCells[cellDescription]
			local useTemporaryLoad = false	
			if cell == nil then
				logicHandler.LoadCell(cellDescription)
				useTemporaryLoad = true
				cell = LoadedCells[cellDescription]	
				for _, uniqueIndex in pairs(cell.data.packets.spawn) do
					if cell.data.objectData[uniqueIndex] ~= nil then
						cell.data.objectData[uniqueIndex] = nil
						tableHelper.removeValue(cell.data.packets.spawn, uniqueIndex)	
						if tableHelper.getCount(Players) > 0 then		
							logicHandler.DeleteObjectForEveryone(cellDescription, uniqueIndex)
						end
					end
				end
				cell:SaveToDrive()			
			elseif cell ~= nil then	
				for _, uniqueIndex in pairs(cell.data.packets.spawn) do
					if cell.data.objectData[uniqueIndex] ~= nil then
						cell.data.objectData[uniqueIndex] = nil
						tableHelper.removeValue(cell.data.packets.spawn, uniqueIndex)
						logicHandler.DeleteObjectForEveryone(cellDescription, uniqueIndex)				
					end
				end
				cell:SaveToDrive()
			end	
			if useTemporaryLoad == true then
				logicHandler.UnloadCell(cellDescription)
			end
		end
	end
	tes3mp.RestartTimer(TimerClean, time.seconds(config.timerClean))
end	

HunterWorld.HunterPrime = function(eventStatus, pid, cellDescription)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		if LoadedCells[cellDescription] ~= nil then		
			LoadedCells[cellDescription]:SaveActorDeath(pid)			
			local actorIndex = tes3mp.GetActorListSize() - 1			
			if actorIndex ~= nil then			
				local uniqueIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)				
				local killerPid = tes3mp.GetActorKillerPid(actorIndex)				
				if uniqueIndex ~= nil and killerPid ~= nil then					
					if LoadedCells[cellDescription].data.objectData[uniqueIndex] then					
						local refId = LoadedCells[cellDescription].data.objectData[uniqueIndex].refId		
						if Players[killerPid] ~= nil then
							local goldLoc = inventoryHelper.getItemIndex(Players[killerPid].data.inventory, "gold_001", -1)	
							local addgold = 0
							local message = color.Red.. "Une créature rare vient d'être tuée !\n"	
							if tableHelper.containsValue(config.bosses, refId) then
								if goldLoc == nil then
									table.insert(Players[killerPid].data.inventory, {refId = "gold_001", count = config.count, charge = -1, soul = ""})			
								else
									Players[killerPid].data.inventory[goldLoc].count = Players[killerPid].data.inventory[goldLoc].count + config.count
									local countprice = Players[killerPid].data.inventory[goldLoc].count + config.count
								end
								tes3mp.MessageBox(killerPid, -1, "Tu a récupéré une prime de chasse !")
								tes3mp.SendMessage(killerPid, message, true)
								local itemref = {refId = "gold_001", count = config.count, charge = -1, soul = ""}			
								Players[killerPid]:SaveToDrive()
								Players[killerPid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)						
							end
						end
					end
				end
			end
		end
	end
end

HunterWorld.OnCreatureSpawn = function(eventStatus, pid, cellDescription, objects) 
	local ObjectIndex
	local ObjectRefid
	for _, object in pairs(objects) do
		ObjectIndex = object.uniqueIndex
		ObjectRefid = object.refId		
	end	
	if ObjectIndex ~= nil then
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
			if LoadedCells[cellDescription] ~= nil then											
				local location = {
					posX = LoadedCells[cellDescription].data.objectData[ObjectIndex].location.posX,
					posY = LoadedCells[cellDescription].data.objectData[ObjectIndex].location.posY,
					posZ = LoadedCells[cellDescription].data.objectData[ObjectIndex].location.posZ
				}			
				local rando	
				local randox
				local randoy
				local packetType = "spawn"				
				rando = math.random(1, 47)
				randox = math.random(-25, 25)
				randoy = math.random(-25, 25)		
				if not tableHelper.containsValue(config.blackList, cellDescription) then
					if not tableHelper.containsValue(config.blackListCrea, string.lower(ObjectRefid)) then		

						local creatureTable = jsonInterface.load("EcarlateCreaturesLigth.json")
						local creatureRefId
						local creaturename
				
						for slot1, creature in pairs(creatureTable.creatures) do
							if slot1 == rando then
								creatureRefId = creature.Refid
								creaturename = creature.name
							end
						end
						
						if creatureRefId ~= nil and cellDescription ~= nil and location.posX ~= nil and location.posY ~= nil and location.posZ ~= nil then
							if not tableHelper.containsValue(config.bosses, creatureRefId) then
								local position = { posX = tonumber(location.posX) + randox, posY = tonumber(location.posY) + randoy, posZ = tonumber(location.posZ), rotX = 0, rotY = 0, rotZ = 0 }
								tes3mp.LogMessage(2, "Spawn")
								tes3mp.LogMessage(2, creatureRefId)
								tes3mp.LogMessage(2, cellDescription)
								logicHandler.CreateObjectAtLocation(cellDescription, position, creatureRefId, packetType)	
							end
						end
					end	
				end
				if not tableHelper.containsValue(config.blackList, cellDescription) then
					if tableHelper.containsValue(config.seacrea, string.lower(ObjectRefid)) then		
						local creatureRefId = "cait_shark02"				
						if creatureRefId ~= nil and cellDescription ~= nil and posx ~= nil and posy ~= nil and posz ~= nil then
							if not tableHelper.containsValue(config.bosses, creatureRefId) then
								local position = { posX = tonumber(posx) + randox, posY = tonumber(posy) + randoy, posZ = tonumber(posz), rotX = 0, rotY = 0, rotZ = 0 }
								tes3mp.LogMessage(2, "Spawn")
								tes3mp.LogMessage(2, creatureRefId)
								tes3mp.LogMessage(2, cellDescription)
								logicHandler.CreateObjectAtLocation(cellDescription, position, creatureRefId, packetType)	
							end
						end
					end
				end	
			end
		end
	end
end

HunterWorld.OnPlayerChangeCell = function(eventStatus, pid) 
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local cellId = tes3mp.GetCell(pid)
		local cell = LoadedCells[cellId]
        local Time = os.time()	
		if cell ~= nil then
			if EcarlateHousing then
				local cellData = EcarlateHousing.GetCellData(cellId)
				if cellData and (cellData.house ~= nil) then
					--The cell belongs to a EcarlateHousing home
					tes3mp.LogMessage(2, "Cell belongs to a EcarlateHousing home")
					return
				end
			end			
			local tempCell = cell.data.entry.creationTime		
			if tempCell ~= nil then
				local calculTime = Time - tempCell		
				if calculTime > config.timerRespawn then				
					for x, index in pairs(cell.data.packets.actorList) do
						local refIndex = cell.data.packets.actorList[x]
						if refIndex ~= nil then
							if cell.data.objectData[refIndex] then
								local refId = cell.data.objectData[refIndex].refId						
								if cell.data.objectData[refIndex].location then
									local location = {
										posX = cell.data.objectData[refIndex].location.posX,
										posY = cell.data.objectData[refIndex].location.posY,
										posZ = cell.data.objectData[refIndex].location.posZ
									}
									local position = { posX = location.posX, posY = location.posY, posZ = location.posZ, rotX = 0, rotY = 0, rotZ = 0 }
									if tableHelper.containsValue(cell.data.packets.death, refIndex, true) then								
										tableHelper.removeValue(cell.data.objectData, refIndex)
										tableHelper.removeValue(cell.data.packets, refIndex)
										logicHandler.DeleteObjectForEveryone(cellId, refIndex)											
										logicHandler.CreateObjectAtLocation(cellId, position, refId, "spawn") 
									end
								end
							end
						end
					end									
					cell.data.entry.creationTime = os.time()
					cell:SaveToDrive()
				end
			end	
		end
	end
end


customEventHooks.registerHandler("OnServerInit", HunterWorld.TimerEventWorld)
customEventHooks.registerHandler("OnPlayerCellChange", HunterWorld.OnPlayerChangeCell)
customEventHooks.registerHandler("OnObjectSpawn", HunterWorld.OnCreatureSpawn)
customEventHooks.registerHandler("OnActorDeath", HunterWorld.HunterPrime)

return HunterWorld
