data:extend({

	{
		type = "electric-energy-interface",
		name = "controller-energy-supply",
		icon = "__electric_transport_belts__/graphics/entity/controller-energy-supply.png",
		flags = {"placeable-off-grid", "not-deconstructable", "not-on-map"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "electric-energy-interface"},
		max_health = 0,
		corpse = "medium-remnants",
		collision_box = {{0, 0}, {0, 0}},
		selection_box = {{0, 0}, {0, 0}},
		energy_source =
		{
		  type = "electric",
		  buffer_capacity = "2KW",
		  usage_priority = "secondary-input",
		  input_flow_limit = "2kW",
		  output_flow_limit = "2kW"
		},
		energy_production = "0KW",
		energy_usage = "1KW",
		-- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
		picture =
		{
		  filename = "__electric_transport_belts__/graphics/entity/transparent.png",
		  priority = "extra-high",
		  width = 62,
		  height = 62,
		  shift = {-0.015625, 0.15625}
		},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
	}
	  
})