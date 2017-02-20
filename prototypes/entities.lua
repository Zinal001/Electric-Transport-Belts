data:extend({

	{
		type = "lamp",
		name = "transport-belt-energy",
		icon = "__base__/graphics/icons/small-lamp.png",
		collision_mask = {"not-colliding-with-itself", "water-tile"},
		flags = {"placeable-off-grid", "not-deconstructable"},
		order = "z",
		max_health = 0,
		corpse = "small-remnants",
		collision_box = {{0, 0}, {0, 0}},
		selection_box = {{0, 0}, {0, 0}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
		  type = "electric",
		  buffer_capacity = "2KW",
		  usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "1KW",
		light = {intensity = 0.0, size = 0},
		light_when_colored = {intensity = 0, size = 0},
		glow_size = 0,
		glow_color_intensity = 0,
		picture_off =
		{
		  filename = "__electric_transport_belts__/graphics/entity/transparent.png",
		  priority = "high",
		  width = 62,
		  height = 62,
		  frame_count = 1,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.015625, 0.15625},
		},
		picture_on =
		{
		  filename = "__electric_transport_belts__/graphics/entity/transparent.png",
		  priority = "high",
		  width = 62,
		  height = 62,
		  frame_count = 1,
		  axially_symmetrical = false,
		  direction_count = 1,
		  shift = {-0.015625, 0.15625},
		},
		signal_to_color_mapping = {},
		circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.28125}, {0.1875, 0.28125}, 18),
		circuit_wire_max_distance = 0

	  }

})