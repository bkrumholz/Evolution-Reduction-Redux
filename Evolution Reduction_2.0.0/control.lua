require("config")

script.on_event(defines.events.on_entity_died, function(event)
	local dead_entity = event.entity
	local reduction_factor = 0.0
	local altered_evolution = 0.0
	local current_surface = dead_entity.surface
	local current_evolution = game.forces.enemy.get_evolution_factor(current_surface)
	local entity_type = dead_entity.type
	
	if DEBUG then  --print out what is being destroyed (type - name - planet surface)
		local ignore_type_list = {"asteroid","tree","unit"}
		local ignore_type = false
		
		for _, value in ipairs(ignore_type_list) do
			if value == entity_type then
				ignore_type = true
				break
			end
		end

		if ignore_type==false then 
			print(dead_entity.type.." - "..dead_entity.name.." - "..current_surface.name)
		end
	end
	
	if current_evolution > MINIMUM_EVOLUTION_FACTOR then
		if dead_entity.type == "unit" then
			--minimise check loop time
			--print("Unit")
		else
			if dead_entity.type == "turret" and (settings.global["Evolution-Reduction-Worm"].value) then
				reduction_factor = BASE_REDUCTION_FACTOR * (settings.global["Evolution-Reduction-Factor"].value / 100)
			else 
				if dead_entity.type == "unit-spawner" and (settings.global["Evolution-Reduction-Spawner"].value) then
					reduction_factor = BASE_REDUCTION_FACTOR * (settings.global["Evolution-Reduction-Factor"].value / 100)
				end
			end
		end
		
		if reduction_factor > 0.0 then
			if DEBUG or (settings.global["Evolution-Reduction-Debug-Mode"].value) then 
				print("Reduction = "..reduction_factor.." BASE = "..BASE_REDUCTION_FACTOR.." Pollution = "..game.forces.enemy.get_evolution_factor_by_pollution(current_surface)) 
			end
			if current_evolution < 1.0 then
				altered_evolution = (current_evolution - (reduction_factor * (1 - current_evolution)))
				if altered_evolution > MINIMUM_EVOLUTION_FACTOR then
					--game.forces.enemy.evolution_factor = altered_evolution
					game.forces.enemy.set_evolution_factor(altered_evolution,current_surface)
				else
					--game.forces.enemy.evolution_factor = MINIMUM_EVOLUTION_FACTOR
					game.forces.enemy.set_evolution_factor(MINIMUM_EVOLUTION_FACTOR,current_surface)
				end
			else
				--game.forces.enemy.evolution_factor = 0.99
				game.forces.enemy.set_evolution_factor(0.99,current_surface)
			end
			
			if settings.global["Evolution-Reduction-Alien-Gear-For-War"].value then
				--game.map_settings.enemy_evolution.time_factor = game.map_settings.enemy_evolution.time_factor + ((EVOLUTION_INCREMENT_FACTOR * reduction_factor) / 10)
				--game.map_settings.enemy_evolution.pollution_factor = game.map_settings.enemy_evolution.pollution_factor + (EVOLUTION_INCREMENT_FACTOR * reduction_factor)
				--Gear for war increases evolution rate for both time and pollution
				game.forces.enemy.set_evolution_factor_by_pollution(game.forces.enemy.get_evolution_factor_by_pollution(current_surface) + (EVOLUTION_INCREMENT_FACTOR * reduction_factor),current_surface)
				game.forces.enemy.set_evolution_factor_by_time(game.forces.enemy.get_evolution_factor_by_time(current_surface) + ((EVOLUTION_INCREMENT_FACTOR * reduction_factor) / 10),current_surface)
				if DEBUG then print("Time = "..game.forces.enemy.get_evolution_factor_by_time(current_surface).."\nPolution = "..game.forces.enemy.get_evolution_factor_by_pollution(current_surface)) end
			end
		end
	end
end
)

if DEBUG or (settings.global["Evolution-Reduction-Debug-Mode"].value) then
	script.on_event(defines.events.on_tick, function(event)
	local current_surface = game.players[1].surface
		if DISPLAY_FACTORS then
			print("Evolution Factors Reset")
			print("Destroy = "..game.forces.enemy.get_evolution_factor_by_killing_spawners(current_surface))
			print("Pollution = "..game.forces.enemy.get_evolution_factor_by_pollution(current_surface))
			print("Time = "..game.forces.enemy.get_evolution_factor_by_time(current_surface))
			print("Evolution = "..game.forces.enemy.get_evolution_factor(current_surface))
			DISPLAY_FACTORS = false
		end
	end)
end

script.on_init(function() --this function doesn't do anything now
	game.map_settings.enemy_evolution.destroy_factor = 0.0
	game.map_settings.enemy_evolution.pollution_factor = POLLUTION_FACTOR
end)

function print(msg)
	game.players[1].print(msg)
end
	
	
--[[
	if current_evolution > MINIMUM_EVOLUTION_FACTOR then	
		if dead_entity.type == "turret" then
			if string.find(dead_entity.name, "small") then
				reduction_factor = BASE_REDUCTION_FACTOR * SMALL_WORM
			elseif string.find(dead_entity.name, "medium") then
				reduction_factor = BASE_REDUCTION_FACTOR * MEDIUM_WORM
			elseif string.find(dead_entity.name, "big") then
				reduction_factor = BASE_REDUCTION_FACTOR * BIG_WORM
			elseif string.find(dead_entity.name, "giant") then
				reduction_factor = BASE_REDUCTION_FACTOR * GIANT_WORM
			elseif string.find(dead_entity.name, "behemoth") then
				reduction_factor = BASE_REDUCTION_FACTOR * BEHEMOTH_WORM
			end		
		else 
			if dead_entity.type == "unit-spawner" then
				if string.find(dead_entity.name, "bob") then
					reduction_factor = BASE_REDUCTION_FACTOR * SPAWNER_BOBS
				else
					reduction_factor = BASE_REDUCTION_FACTOR * SPAWNER_BASE
				end
			end
		end
--]]