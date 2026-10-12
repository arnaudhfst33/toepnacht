class_name PowerUpCatalog
extends RefCounted

## Prices and availability. Unimplemented v1.0 ids stay listed but are not sold.


static func display_name(id: String) -> String:
	match id:
		PowerUpId.KAARTJE_RUILEN:
			return "Kaartje Ruilen"
		PowerUpId.EVEN_SPIEKEN:
			return "Even Spieken"
		PowerUpId.OP_HET_RANDJE:
			return "Op het Randje"
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			return "Rondje van de Zaak"
		PowerUpId.HUISVOORDEEL:
			return "Huisvoordeel"
		PowerUpId.WASDAG:
			return "Wasdag"
		PowerUpId.DUBBEL_KLOPPEN:
			return "Dubbel Kloppen"
		PowerUpId.STALEN_ZENUWEN:
			return "Stalen Zenuwen"
		_:
			return id


static func cost(id: String) -> int:
	match id:
		PowerUpId.KAARTJE_RUILEN:
			return 5
		PowerUpId.EVEN_SPIEKEN:
			return 4
		PowerUpId.OP_HET_RANDJE:
			return 8
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			return 7
		PowerUpId.HUISVOORDEEL:
			return 7
		PowerUpId.WASDAG:
			return 6
		PowerUpId.DUBBEL_KLOPPEN:
			return 5
		PowerUpId.STALEN_ZENUWEN:
			return 6
		_:
			return 0


static func is_implemented(id: String) -> bool:
	return PowerUpId.all_ids().find(id) >= 0


static func is_passive(id: String) -> bool:
	return id == PowerUpId.OP_HET_RANDJE


static func purchasable_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in PowerUpId.all_ids():
		if is_implemented(id):
			ids.append(id)
	return ids


static func unimplemented_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in PowerUpId.all_ids():
		if not is_implemented(id):
			ids.append(id)
	return ids
