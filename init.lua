local your_mod_name = core.get_current_modname()

local api = dg_sprint_core

local settings = {
    	aux1 = false,
    	double_tap = true,
    	tap_interval = tonumber(core.settings:get(your_mod_name .. ".tap_interval")) or 0.5,
}

mcl_sprint.SPEED = tonumber(core.settings:get(your_mod_name .. ".set_speed")) or 1.8

api.register_server_step(your_mod_name, "DETECT", tonumber(core.settings:get(your_mod_name .. ".detection_step")) or 0.1, function(player, state, dtime)
    local control = player:get_player_control()
		local detected = api.sprint_key_detected(player, (settings.aux1 and control.aux1), (settings.double_tap and control.up), settings.tap_interval) and not (mcl_hunger.get_hunger(player) <= 6)
	if detected ~= state.detected then
		state.detected = detected
	end

end)

api.register_server_step(your_mod_name, "SPRINT", tonumber(core.settings:get(your_mod_name .. ".sprint_step")) or 0.2, function(player, state, dtime)
	if not settings.fov then
		settings.fov_value = 0
	end

	if state.detected then
		local pos = player:get_pos()
		local sprint_settings = {speed = settings.speed, jump = settings.jump}
		api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
		local playerNode = core.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local def = core.registered_nodes[playerNode.name]
		if def and def.walkable then
			core.add_particlespawner({
				amount = math.random(1, 2),
				time = 1,
				minpos = {x=-0.5, y=0.1, z=-0.5},
				maxpos = {x=0.5, y=0.1, z=0.5},
				minvel = {x=0, y=5, z=0},
				maxvel = {x=0, y=5, z=0},
				minacc = {x=0, y=-13, z=0},
				maxacc = {x=0, y=-13, z=0},
				minexptime = 0.1,
				maxexptime = 1,
				minsize = 0.5,
				maxsize = 1.5,
				collisiondetection = true,
				attached = player,
				vertical = false,
				node = playerNode,
				node_tile = mcl_sprint.get_top_node_tile(playerNode.param2, def.paramtype2), -- luacheck: ignore
			})
		end
    else
        local sprint_settings = {speed = settings.speed, jump = settings.jump}
        api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
    end
end)

api.register_server_step(your_mod_name, "DRAIN", tonumber(core.settings:get(your_mod_name .. ".drain_step")) or 0.2, function(player, state, dtime)
	if state.detected and api.is_player_draining(player) then
		mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_SPRINT)
	end
end)
