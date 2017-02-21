
function debugPrint(text)
	if global.DEBUG then
		game.print("[DEBUG] " .. text)
	end
end

function on_init()
	debugPrint("On Init!")
	if global == nil then
		global = {}
	end
	
	global.DEBUG = false
	
	if global.entities == nil then
		global.entities = {}
	end	
	
	script.on_event(defines.events.on_tick, on_first_game_tick)
	
end

function on_load()
	script.on_event(defines.events.on_tick, on_first_load_tick)
end

function on_configuration_changed()
	global.DEBUG = false
	debugPrint("On Configuration Changed!")
	
	--Fix for Version 0.14.1--
	if global.belts ~= nil then
		game.print("Overriding global.belts to global.entities")
		
		local numEnts = 0
		global.entities = {}
		for id, data in pairs(global.belts) do
			global.entities[id] = data
			global.entities[id].type = "transport-belt"
			numEnts = numEnts + 1
		end
		
		global.belts = nil
	end
	
	local entities = {}
	numEnts = 0
	for id, data in pairs(global.entities) do
		if data ~= nil then
			local surface = game.surfaces[data.surface]
				
			local ent = surface.find_entity(data.name, data.position)
			
			if ent ~= nil and ent.valid then
				local eng = get_entity_exact(data.name, surface, data.eng_pos.x, data.eng_pos.y)
				
				if eng ~= nil and eng.valid then
					entities[id] = data
					numEnts = numEnts + 1
				else
					debugPrint("Missing " .. data.type .. "-energy on " .. id)
				end
			end
		end		
	end
	debugPrint(numEnts .. " found")
	global.entities = entities
end

function on_first_game_tick(event)
	for i, surface in pairs(game.surfaces) do
		local belts = surface.find_entities_filtered({
			type = "transport-belt"
		})
		
		if #belts > 0 then
			for j, belt in pairs(belts) do
				on_built(belt)
			end
		end
		
		local loaders = surface.find_entities_filtered({
			type = "loader"
		})
		
		if #loaders > 0 then
			for j, loader in pairs(loaders) do
				on_built(loader)
			end
		end
		
	end
	
	debugPrint("Ran on_first_game_tick")
	script.on_event(defines.events.on_tick, on_tick)
end

function on_first_load_tick(event)
	
	local entities = {}
	
	for id, data in pairs(global.entities) do
		if data ~= nil then
			local surface = game.surfaces[data.surface]
				
			local ent = surface.find_entity(data.name, data.position)
			
			if ent ~= nil and ent.valid then
				local eng = get_entity_exact(data.name, surface, data.eng_pos.x, data.eng_pos.y)
				
				if eng ~= nil and eng.valid then
					entities[id] = data
				end
			end
		end
	end
	
	local removed = #global.entities - #entities
	global.entities = entities
	debugPrint("Ran on_first_load_tick. Removed: " .. removed)
	script.on_event(defines.events.on_tick, on_tick)
end

function on_tick(event)
		
	local checked = 0	
	
	for id, data in pairs(global.entities) do
		
		if checked >= 50 then
			break
		end
	
		if data ~= nil then
			if data.tick <= 0 then
				debugPrint("Checking " .. id)
				global.entities[id].tick = 20
				checked = checked + 1
				
				local surface = game.surfaces[data.surface]
				
				local ent = surface.find_entity(data.name, data.position)
				local eng = get_entity_exact(data.type .. "-energy", surface, data.eng_pos.x, data.eng_pos.y)
				
				if ent ~= nil and ent.valid then				
					if eng ~= nil and eng.valid then
						if eng.energy <= 1 then
							if ent.active then
								debugPrint("Turning off Entity")
							end
							
							ent.active = false
						else
							if not ent.active then
								debugPrint("Turning on Entity")
							end
							
							fix_entities_stuck(ent.surface, ent.type, ent.position.x, ent.position.y)
							
							ent.active = true
						end
						
					else
						global.entities[id] = nil
						debugPrint("[on_tick 1] Unable to find " .. id)
					end
				else
					
					debugPrint("[on_tick 2] Unable to find " .. id)
					if eng ~= nil and eng.valid then
						debugPrint("Removed eng")
						eng.destroy()
					end
				
					global.entities[id] = nil
				end
			else
				global.entities[id].tick = global.entities[id].tick - 1
			end
		end	
	end
	
end

function fix_entities_stuck(surface, type, x, y)
	local ents = surface.find_entities_filtered({
		area = {{x - 2, y - 2}, {x + 2, y + 2}},
		type = type
	})
	
	for k, ent in pairs(ents) do
		if ent.active then
			ent.active = false
			ent.active = true
		end
	end
	
end

function on_built_entity(event)
	on_built(event.created_entity)
end

function on_preplayer_mined_item(event)
	on_died(event.entity)
end

function on_entity_died(event)
	on_died(event.entity)
end

function on_robot_built_entity(event)
	on_built(event.created_entity)
end

function on_robot_pre_mined(event)
	on_died(event.entity)
end


function on_built(entity)

	if entity.type == "transport-belt" or entity.type == "loader" then
	
		local id = get_entity_id(entity)
		
		local eng = entity.surface.create_entity({
			name = entity.type .. "-energy",
			position = entity.position,
			force = entity.force
		})
		
		debugPrint("Added " .. id .. " to global")
		global.entities[id] = {
			name = entity.name,
			type = entity.type,
			position = entity.position,
			surface = entity.surface.name,
			eng_pos = eng.position,
			tick = 0
		}
	
	end
end

function on_died(entity)
	if entity.type == "transport-belt" or entity.type == "loader" then
		local id = get_entity_id(entity)
		debugPrint("Destroyed " .. id)
		
		local data = global.entities[id]
		
		local pos = entity.position
		
		if data ~= nil then
			pos = data.eng_pos
		end
		
		local eng = get_entity_exact(entity.type .. "-energy", entity.surface, pos.x, pos.y)
		
		if eng ~= nil and eng.valid then
			eng.destroy()
		else
			debugPrint("[on_died] Unable to find " .. id .. ", " .. tostring(data))
		end
		
		if global.entities[id] ~= nil then
			global.entities[id] = nil
		end
	end
end

function get_entity_id(entity)
	return entity.name .. "_" .. entity.surface.index .. "_" .. entity.position.x .. "_" .. entity.position.y
end

function get_entity_exact(name, surface, x, y)
	local ents = surface.find_entities_filtered({
		area = {{x - 0.1, y - 0.1}, {x + 0.1, y + 0.1}},
		name = name
	})
	
	if #ents > 0 then
		return ents[1]
	else
		return nil
	end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_preplayer_mined_item, on_preplayer_mined_item)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)