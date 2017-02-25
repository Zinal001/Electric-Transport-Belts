
function GetNextBelt(belt)
	local pos = belt.position
	local dir = belt.direction
	
	pos = OffsetPosition(pos, dir)
	
	return FindEntity(belt.surface, "transport-belt", pos)
end

function GetPrevBelt(belt)
	local pos = belt.position
	local dir = belt.direction
	
	dir = InvertDirection(dir)
	pos = OffsetPosition(pos, dir)
	
	return FindEntity(belt.surface, "transport-belt", pos)
end

function FindEntity(surface, type, pos)
	
	local ents = surface.find_entities_filtered({
		area = {{pos.x - 0.3, pos.y - 0.3}, {pos.x + 0.3, pos.y + 0.3}},
		type = type
	})
	
	if #ents > 0 then
		return ents[1]
	else
		return nil
	end
end

function FindBeltLineEnergySupply(belt)
	local posScanned = {}
	
	local beltId = GetEntityId(belt)
	posScanned[beltId] = true
	
	if global.entities[beltId] ~= nil and global.entities[beltId].supply ~= nil and global.entities[beltId].supply.valid then
		return global.entities[beltId].supply
	end
	
	local nextBelt = belt
	
	local interation = 0
	
	while nextBelt ~= nil do
	
		if interation >= 50 then
			break
		end
		interation = interation + 1
	
		nextBelt = GetPrevBelt(nextBelt)
		
		if nextBelt ~= nil then
			local id = GetEntityId(nextBelt)
			DebugPrint("Scanning " .. id)
			
			if posScanned[id] ~= nil then
				break
			end
			
			if global.entities[id] ~= nil and global.entities[id].supply ~= nil and global.entities[id].supply.valid then
				return global.entities[id].supply
			end
			
			posScanned[id] = true
		end
	end
	
	if interation >= 50 then
		DebugPrint("STOPPED EXECUTION OF GetBeltLine - PrevBelt: Stack Overflow")
	end
	
	nextBelt = belt
	interation = 0
	
	while nextBelt ~= nil do
	
		if interation >= 50 then
			break
		end
		interation = interation + 1
	
		nextBelt = GetNextBelt(nextBelt)
		
		if nextBelt ~= nil then
			local id = GetEntityId(nextBelt)
			DebugPrint("Scanning " .. id)
			
			if posScanned[id] ~= nil then
				break
			end
			
			if global.entities[id] ~= nil and global.entities[id].supply ~= nil and global.entities[id].supply.valid then
				return global.entities[id].supply
			end
			
			posScanned[id] = true
		end
	end
	
	if interation >= 50 then
		DebugPrint("STOPPED EXECUTION OF GetBeltLine - NextBelt: Stack Overflow")
	end
	
	return nil
end

function GetBeltLine(belt)
	
	local posScanned = {}
	local belts = {}
	table.insert(belts, belt)
	posScanned[GetEntityId(belt)] = true
	
	local nextBelt = belt
	
	local interation = 0
	
	while nextBelt ~= nil do
	
		if interation >= 50 then
			break
		end
		
		interation = interation + 1
	
		nextBelt = GetPrevBelt(nextBelt)
		
		if nextBelt ~= nil then
			if posScanned[GetEntityId(nextBelt)] ~= nil then
				break
			end
			
			posScanned[GetEntityId(nextBelt)] = true
			
			table.insert(belts, nextBelt)
		end
	end
	
	if interation >= 50 then
		DebugPrint("STOPPED EXECUTION OF GetBeltLine - PrevBelt: Stack Overflow")
	end
	
	nextBelt = belt
	interation = 0
	
	while nextBelt ~= nil do
	
		if interation >= 50 then
			break
		end
		interation = interation + 1
	
		nextBelt = GetNextBelt(nextBelt)
		
		if nextBelt ~= nil then
			if posScanned[GetEntityId(nextBelt)] ~= nil then
				break
			end
			posScanned[GetEntityId(nextBelt)] = true
			
			table.insert(belts, nextBelt)
		end
	end
	
	if interation >= 50 then
		DebugPrint("STOPPED EXECUTION OF GetBeltLine - NextBelt: Stack Overflow")
	end
	
	return belts
end

function OffsetPosition(pos, dir)
	if dir == defines.direction.north then
		pos.y = pos.y - 1
	elseif dir == defines.direction.east then
		pos.x = pos.x + 1
	elseif dir == defines.direction.south then
		pos.y = pos.y + 1
	elseif dir == defines.direction.west then
		pos.x = pos.x - 1
	elseif dir == defines.direction.northeast then
		pos.x = pos.x + 1
		pos.y = pos.y - 1
	elseif dir == defines.direction.southeast then
		pos.x = pos.x + 1
		pos.y = pos.y + 1
	elseif dir == defines.direction.southwest then
		pos.x = pos.x - 1
		pos.y = pos.y - 1
	elseif dir == defines.direction.northwest then
		pos.x = pos.x - 1
		pos.y = pos.y - 1
	end
	
	return pos
end

function InvertDirection(dir)
	if dir == defines.direction.north then
		return defines.direction.south
	elseif dir == defines.direction.east then
		return defines.direction.west
	elseif dir == defines.direction.south then
		return defines.direction.north
	elseif dir == defines.direction.west then
		return defines.direction.east
	elseif dir == defines.direction.northeast then
		return defines.direction.southwest
	elseif dir == defines.direction.southeast then
		return defines.direction.northwest
	elseif dir == defines.direction.southwest then
		return defines.direction.northeast
	elseif dir == defines.direction.northwest then
		return defines.direction.southeast
	end
end

function GetEntityId(entity)
	return entity.name .. "_" .. entity.surface.name .. "_" .. entity.position.x .. "_" .. entity.position.y
end

function GetEntityIdEx(entity, name)
	return name .. "_" .. entity.surface.name .. "_" .. entity.position.x .. "_" .. entity.position.y
end

function CheckController(ctrl)
	local ctrl_id = GetEntityId(ctrl)
	DebugPrint("Checking controller " .. ctrl_id)
							
	if global.controllers[ctrl_id] ~= nil and global.controllers[ctrl_id].entity ~= nil and global.controllers[ctrl_id].entity.valid then
		
		DebugPrint("Found Controller")

		for _, belt in pairs(global.controllers[ctrl_id].belts) do
			if belt ~= nil and belt.valid then
				local beltId = GetEntityId(belt)
				belt.active = false
				
				if global.entities[beltId] ~= nil then
					global.entities[beltId] = nil
				end
			end
		end
		
		local belts = GetBeltLine(global.controllers[ctrl_id].entity)
		
		global.controllers[ctrl_id].belts = belts
		
		if global.controllers[ctrl_id].supply ~= nil and global.controllers[ctrl_id].supply.valid then
			global.controllers[ctrl_id].supply.electric_drain = #belts
			global.controllers[ctrl_id].supply.electric_buffer_size = #belts
		end
		
		for _, belt in pairs(belts) do
			if belt ~= nil and belt.valid then
				local beltId = GetEntityId(belt)
				belt.active = global.controllers[ctrl_id].powered
				
				global.entities[beltId] = {
					id = beltId,
					supply = global.controllers[ctrl_id].supply
				}
			end
		end
		
	end	
end

function DebugPrint(text)
	if global.DEBUG then
		game.print("[DEBUG] " .. text)
	end
end

function SetupGlobal(event)
	if global == nil then
		global = {}
	end
	
	global.DEBUG = true
	
	if global.entities == nil then
		global.entities = {}
	end
	
	if global.controllers == nil then
		global.controllers = {}
	end
	
	if global.suppliers == nil then
		global.suppliers = {}
	end
	
	if global.force_check == nil then
		global.force_check = {}
	end
end

function OnBuilt(entity)
	if entity.type == "transport-belt" then
		DebugPrint("Created " .. entity.name)
		if string.find(entity.name, "belt-controller", 1, true) ~= nil then
			
			local entId = GetEntityId(entity)
			
			local supply = entity.surface.create_entity({
				name = "controller-energy-supply",
				position = entity.position,
				force = entity.force
			})
			
			if supply ~= nil then
				local supplyId = GetEntityId(supply)
				
				local belts = GetBeltLine(entity)
				supply.electric_drain = #belts
				supply.electric_buffer_size = #belts
				
				global.controllers[entId] = {
					id = entId,
					entity = entity,
					supply = supply,
					belts = belts,
					powered = false,
					force_powered = false,
					tick = 0,
					check_tick = 100
				}
				
				global.suppliers[supplyId] = {
					id = supplyId,
					supply = supply,
					ctrl = entity
				}
				
				for _, belt in pairs(belts) do
					
					local beltId = GetEntityId(belt)
					global.entities[beltId] = {
						id = beltId,
						supply = supply
					}
				end
				
				entity.active = false
				
				DebugPrint("Created Controller Energy Supply for " .. entId .. " (" .. supplyId .. ")")
			else
				DebugPrint("Could not create Controller Energy Supply for " .. entId)
			end
		else
			
			local entId = GetEntityId(entity)
			
			local supply = FindBeltLineEnergySupply(entity)
			
			if supply == nil or not supply.valid then
				entity.active = false
				DebugPrint("Could not find energy supply for " .. entId)
			else
				local supplyId = GetEntityId(supply)
				
				global.entities[entId] = {
					id = entId,
					supply = supply
				}
				
				if global.suppliers[supplyId] ~= nil and global.suppliers[supplyId].ctrl ~= nil and global.suppliers[supplyId].ctrl.valid then
				
					local ctrl_id = GetEntityId(global.suppliers[supplyId].ctrl)
					
					if global.controllers[ctrl_id] ~= nil and global.controllers[ctrl_id].entity ~= nil and global.controllers[ctrl_id].entity.valid then
					
						CheckController(global.suppliers[supplyId].ctrl)
						
						global.controllers[ctrl_id].force_powered = true
						
						if not global.controllers[ctrl_id].powered then
							entity.active = false
						end
						
						DebugPrint("Added " .. entId .. " to " .. supplyId)
					end					
				end
			end
		
		end
	end
end

function onDestroyed(entity)

	if entity.type == "transport-belt" then
	
		if string.find(entity.name, "belt-controller", 1, true) ~= nil then
			local entId = GetEntityId(entity)
			
			if global.controllers[entId] ~= nil then
			
				if global.controllers[entId].supply ~= nil and global.controllers[entId].supply.valid then
					local supplyId = GetEntityId(global.controllers[entId].supply)
			
					for _, belt in pairs(global.controllers[entId].belts) do
						if belt ~= nil and belt.valid then
							local beltId = GetEntityId(belt)
							
							if global.entities[beltId] ~= nil and global.entities[beltId].supply ~= nil and GetEntityId(global.entities[beltId].supply) == supplyId then
								belt.active = false
								global.entities[beltId] = nil
							end
						end
					end
					
					global.controllers[entId].supply.destroy()
					
					if global.suppliers[supplyId] ~= nil then
						global.suppliers[supplyId] = nil
					end
					
					global.controllers[entId] = nil
					
					DebugPrint("Removed supply from " .. entId)
				end
			end
		else
			local entId = GetEntityId(entity)
			
			if global.entities[entId] ~= nil then
			
				local supply = global.entities[entId].supply
				
				if supply ~= nil and supply.valid then
					DebugPrint("Found Supply")
					local supplyId = GetEntityId(supply)
					
					if global.suppliers[supplyId] ~= nil then
						local ctrl = global.suppliers[supplyId].ctrl
						
						if ctrl ~= nil and ctrl.valid then
							table.insert(global.force_check, ctrl)
						end
						
					end
					
				
				end
				
				DebugPrint("Removed " .. entId)
				global.entities[entId] = nil
			end
		
		end
	end	
end



function on_tick(event)
	local interation = 0
	
	if #global.force_check > 0 then
	
		for _, entity in pairs(global.force_check) do
			if entity ~= nil and entity.valid then
				CheckController(entity)
			end
		end
		
		global.force_check = {}
	end
	
	for id, data in pairs(global.controllers) do
		if interation >= 50 then
			break
		end
		
		if data ~= nil then
			if data.tick <= 0 then
				global.controllers[id].tick = 20				
				interation = interation + 1
				
				if global.controllers[id].check_tick <= 0 then
					global.controllers[id].check_tick = 100
					table.insert(global.force_check, global.controllers[id].entity)
				else
					global.controllers[id].check_tick = global.controllers[id].check_tick - 1
				end
				
				if data.supply ~= nil and data.supply.valid then
				
					if (data.powered or data.force_powered) and data.supply.energy < data.supply.electric_drain then
						
						global.controllers[id].powered = false
						
						for _, belt in pairs(data.belts) do
							if belt ~= nil and belt.valid then
								belt.active = false
							end
						end
						
						global.controllers[id].entity.active = false
						
						DebugPrint("Turned off " .. id)
					elseif (not data.powered or data.force_powered) and data.supply.energy >= data.supply.electric_drain then
						
						global.controllers[id].powered = true
						
						for _, belt in pairs(data.belts) do
							
							if belt ~= nil and belt.valid then
								belt.active = true
							end
							
						end
						
						global.controllers[id].entity.active = true
						
						DebugPrint("Turned on " .. id)
					end
				
					if data.force_powered then
						global.controllers[id].force_powered = false
					end
				
				end
				
			else
				global.controllers[id].tick = global.controllers[id].tick - 1
			end
		end
	
	end
	
end


function on_init()
	SetupGlobal(nil)
end

function on_load()
	
end

function on_configuration_changed(event)
	SetupGlobal(event)
	
	if event.mod_changes ~= nil and event.mod_changes["electric_transport_belts"] ~= nil then
		local change = event.mod_changes["electric_transport_belts"]
		
		if change.new_version ~= nil and change.new_version == "0.14.3" then
			global = {}
				
			for _, surface in pairs(game.surfaces) do
			
				local ents = surface.find_entities_filtered({
					name = "transport-belt-energy"
				})
				
				if #ents > 0 then
					for _, ent in pairs(ents) do
						ent.destroy()
					end
				end
				
				ents = surface.find_entities_filtered({
					name = "loader-energy"
				})
				
				if #ents > 0 then
					for _, ent in pairs(ents) do
						ent.destroy()
					end
				end
			
				ents = surface.find_entities_filtered({
					type = "transport-belt"
				})
				
				if #ents > 0 then
					for _, ent in pairs(ents) do
						ent.active = false
					end
				end
			
			end
			
			SetupGlobal(nil)
		end
	end
	
	
end

function on_built_entity(event)
	if event.created_entity.type == "transport-belt" then
		OnBuilt(event.created_entity)
	end
end

function on_robot_built_entity(event)
	if event.created_entity.type == "transport-belt" then
		OnBuilt(event.created_entity)
	end
end

function on_preplayer_mined_item(event)
	if event.entity.type == "transport-belt" then
		onDestroyed(event.entity)
	end
end

function on_robot_pre_mined(event)
	if event.entity.type == "transport-belt" then
		onDestroyed(event.entity)
	end
end

function on_entity_died(event)
	if event.entity.type == "transport-belt" then
		onDestroyed(event.entity)
	end
end

function on_player_rotated_entity(event)
	if event.entity.type == "transport-belt" then
	
		local entId = GetEntityId(event.entity)
		if global.entities[entId] ~= nil and global.entities[entId].supply ~= nil and global.entities[entId].supply.valid then
			local supplyId = GetEntityId(global.entities[entId].supply)
			
			if global.suppliers[supplyId] ~= nil and global.suppliers[supplyId].ctrl ~= nil and global.suppliers[supplyId].ctrl.valid then
				table.insert(global.force_check, global.suppliers[supplyId].ctrl)
			end
			
		end
	end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)
script.on_event(defines.events.on_preplayer_mined_item, on_preplayer_mined_item)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_entity)

