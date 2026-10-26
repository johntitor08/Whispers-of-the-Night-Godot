class_name ShopItemDataFields
extends SO

var item:
	get:
		return d.get("item", null)
	set(v):
		d["item"] = v

var price:
	get:
		return d.get("price", 0)
	set(v):
		d["price"] = v

var unlimitedStock:
	get:
		return d.get("unlimitedStock", true)
	set(v):
		d["unlimitedStock"] = v

var stockAmount:
	get:
		return d.get("stockAmount", 1)
	set(v):
		d["stockAmount"] = v

var sellRatio:
	get:
		return d.get("sellRatio", 0.5)
	set(v):
		d["sellRatio"] = v

var requiredLevel:
	get:
		return d.get("requiredLevel", 1)
	set(v):
		d["requiredLevel"] = v

var requiresFlag:
	get:
		return d.get("requiresFlag", false)
	set(v):
		d["requiresFlag"] = v

var requiredFlag:
	get:
		return d.get("requiredFlag", "")
	set(v):
		d["requiredFlag"] = v
