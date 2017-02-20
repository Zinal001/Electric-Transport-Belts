
function on_init()
	--game.print("On Init!")
	if global == nil then
		global = {}
	end
	
	if global.belts == nil then
		global.belts = {}
	end	
	
	script.on_event(defines.events.on_tick, on_first_game_tick)
	
end

function on_load()
	script.on_event(defines.events.on_tick, on_first_load_tick)
end

function on_configuration_changed()
	--game.print("On Configuration Changed!")
	local belts = {}
	
	for id, data in pairs(global.belts) do
		if data ~= nil then
			local surface = game.surfaces[data.surface]
				
			local ent = surface.find_entity(data.name, data.position)
			
			if ent ~= nil and ent.valid then
				local eng = surface.find_entity("transport-belt-energy", data.eng_pos)
				
				if eng ~= nil and eng.valid then
					belts[id] = data
				end
			end
		end		
	end
	
	global.belts = belts
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
	end
	
	--game.print("Ran on_first_game_tick")
	script.on_event(defines.events.on_tick, on_tick)
end

function on_first_load_tick(event)
	
	local belts = {}
	
	for id, data in pairs(global.belts) do
		if data ~= nil then
			local surface = game.surfaces[data.surface]
				
			local ent = surface.find_entity(data.name, data.position)
			
			if ent ~= nil and ent.valid then
				local eng = surface.find_entity("transport-belt-energy", data.position)
				
				if eng ~= nil and eng.valid then
					belts[id] = data
				end
			end
		end
	end
	
	local removed = #global.belts - #belts
	global.belts = belts
	--game.print("Ran on_first_load_tick. Removed: " .. removed)
	script.on_event(defines.events.on_tick, on_tick)
end

function on_tick(event)
		
	local checked = 0	
	
	for id, data in pairs(global.belts) do
		
		if checked >= 50 then
			break
		end
	
		if data ~= nil then
			if data.tick <= 0 then
				--game.print("Checking " .. id)
				global.belts[id].tick = 20
				checked = checked + 1
				
				local surface = game.surfaces[data.surface]
				
				local ent = surface.find_entity(data.name, data.position)
				local eng = get_entity_exact("transport-belt-energy", surface, data.eng_pos.x, data.eng_pos.y)
				
				if ent ~= nil and ent.valid then
					local engs = surface.find_entities_filtered({
						area = {{data.eng_pos.x - 1,data.eng_pos.y - 1}, {data.eng_pos.x + 1,data.eng_pos.y + 1}},
						name = "transport-belt-energy"
					})
				
					if eng ~= nil and eng.valid then
						if eng.energy <= 1 then
							if ent.active then
								--game.print("Turning off Entity")
							end
							
							ent.active = false
						else
							if not ent.active then
								--game.print("Turning on Entity")
							end
							
							fix_entities_stuck(ent.surface, ent.position.x, ent.position.y)
							
							ent.active = true
						end
						
					else
						global.belts[id] = nil
						--game.print("[on_tick 1] Unable to find " .. id)
					end
				else
					
					--game.print("[on_tick 2] Unable to find " .. id)
					if eng ~= nil and eng.valid then
						--game.print("Removed eng")
						eng.destroy()
					end
				
					global.belts[id] = nil
				end
			else
				global.belts[id].tick = global.belts[id].tick - 1
			end
		end	
	end
	
end

function fix_entities_stuck(surface, x, y)
	local ents = surface.find_entities_filtered({
		area = {{x - 2, y - 2}, {x + 2, y + 2}},
		type = "transport-belt"
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
	if entity.type == "transport-belt" then
	
		local id = get_entity_id(entity)
		
		local eng = entity.surface.create_entity({
			name = "transport-belt-energy",
			position = entity.position,
			force = entity.force
		})
		
		--game.print("Eng created " .. id)
		
		--game.print("Added " .. id .. " to global")
		global.belts[id] = {
			name = entity.name,
			position = entity.position,
			surface = entity.surface.name,
			eng_pos = eng.position,
			tick = 0
		}
	
	end
end

function on_died(entity)
	if entity.type == "transport-belt" then
		local id = get_entity_id(entity)
		--game.print("Destroyed " .. id)
		
		local data = global.belts[id]
		
		local pos = entity.position
		
		if data ~= nil then
			pos = data.eng_pos
		end
		
		local eng = get_entity_exact("transport-belt-energy", entity.surface, pos.x, pos.y)
		
		if eng ~= nil and eng.valid then
			eng.destroy()
		else
			--game.print("[on_died] Unable to find " .. id .. ", " .. tostring(data))
		end
		
		if global.belts[id] ~= nil then
			global.belts[id] = nil
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