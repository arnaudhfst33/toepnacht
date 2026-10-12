class_name ShopVisit
extends RefCounted

var active: bool = false
var offerings: PackedStringArray = PackedStringArray()


func to_dict() -> Dictionary:
	var list: Array = []
	for id in offerings:
		list.append(id)
	return {"active": active, "offerings": list}


static func from_dict(data: Dictionary) -> ShopVisit:
	var visit := ShopVisit.new()
	visit.active = bool(data.get("active", false))
	var list: Array = data.get("offerings", [])
	for item in list:
		visit.offerings.append(str(item))
	return visit


static func generate(rng: RandomNumberGenerator) -> ShopVisit:
	var visit := ShopVisit.new()
	visit.active = true
	var pool: Array[String] = []
	for id in PowerUpCatalog.purchasable_ids():
		pool.append(id)
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var take := mini(3, pool.size())
	for i in take:
		visit.offerings.append(pool[i])
	return visit
