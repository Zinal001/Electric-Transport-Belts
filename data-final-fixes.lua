require("data-extend")

local extend = {}

function item_extend(type, name, nData)
	nData.icon = "__electric_transport_belts__/graphics/icons/" .. nData.name .. "-controller.png"
	nData.name = nData.name .. "-controller"
	nData.place_result = nData.name

	return nData
end

function entity_extend(type, name, nData)
	nData.icon = "__electric_transport_belts__/graphics/icons/" .. nData.name .. "-controller.png"
	nData.name = nData.name .. "-controller"

	if nData.minable ~= nil then
		nData.minable.result = nData.name
	end

	return nData
end

function recipe_extend_ingredients(nData, amountToAdd)
	local circuitFound = false

	for i, ingredient in pairs(nData) do
		if ingredient.name == "electronic-circuit" then
			ingredient.amount = ingredient.amount + amountToAdd
			circuitFound = true
			break
		end
	end

	if not circuitFound then
		table.insert(nData, {name = "electronic-circuit", amount = amountToAdd})
	end

	return nData
end

function recipe_extend(type, name, nData)
	nData.name = nData.name .. "-controller"

	if nData.ingredients == nil then
		nData.normal.ingredients = recipe_extend_ingredients(nData.normal.ingredients, 2)
		nData.expensive.ingredients = recipe_extend_ingredients(nData.expensive.ingredients, 1)
	else
		nData.ingredients = recipe_extend_ingredients(nData.ingredients, 1)
	end

	nData.result = nData.name
	nData.result_count = 1

	return nData
end

function technology_extend(type, name, data)
	local insert_effects = {}

	if data.effects ~= nil then
		for i, effect in pairs(data.effects) do

			if effect.type == "unlock-recipe" and extend.recipe[effect.recipe] ~= nil then

				table.insert(insert_effects, {
					type = "unlock-recipe",
					recipe = effect.recipe .. "-controller"
				})

			end

		end

		if #insert_effects > 0 then
			for _, effect in pairs(insert_effects) do
				table.insert(data.effects, effect)
			end
		end
	end

	return data
end


--EXTEND ITEMS--
extend["item"] = {}
extend.item["transport-belt"] = {func = item_extend}
extend.item["fast-transport-belt"] = {func = item_extend}
extend.item["express-transport-belt"] = {func = item_extend}

--EXTEND ENTITIES--
extend["transport-belt"] = {}
extend["transport-belt"]["transport-belt"] = {func = entity_extend}
extend["transport-belt"]["fast-transport-belt"] = {func = entity_extend}
extend["transport-belt"]["express-transport-belt"] = {func = entity_extend}

--EXTEND RECIPES--
extend["recipe"] = {}
extend.recipe["transport-belt"] = {enabled = true, func = recipe_extend}
extend.recipe["fast-transport-belt"] = {func = recipe_extend}
extend.recipe["express-transport-belt"] = {func = recipe_extend}

--EXTEND TECHNOLOGY--
extend["technology"] = {}
extend.technology["logistics"] = {func = technology_extend}
extend.technology["logistics-2"] = {func = technology_extend}
extend.technology["logistics-3"] = {func = technology_extend}

local extended = extend_data(extend)
if #extended > 0 then
	data:extend(extended)
end


