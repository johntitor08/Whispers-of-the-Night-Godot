class_name FusionRecipeFields
extends SO

var ingredientA:
	get:
		return d.get("ingredientA", null)
	set(v):
		d["ingredientA"] = v

var ingredientB:
	get:
		return d.get("ingredientB", null)
	set(v):
		d["ingredientB"] = v

var result:
	get:
		return d.get("result", null)
	set(v):
		d["result"] = v

var successChance:
	get:
		return d.get("successChance", 1.0)
	set(v):
		d["successChance"] = v
