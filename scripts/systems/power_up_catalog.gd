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


static func description(id: String) -> String:
	match id:
		PowerUpId.KAARTJE_RUILEN:
			return "Ruil één kaart uit je hand voor een nieuwe kaart uit de stapel."
		PowerUpId.EVEN_SPIEKEN:
			return "Bekijk één willekeurige kaart van een tegenstander."
		PowerUpId.OP_HET_RANDJE:
			return "Eenmalige redding: als je af zou zijn, blijf je automatisch staan op 14 strafpunten."
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			return "Haal één strafpunt van je eigen totaal af."
		PowerUpId.HUISVOORDEEL:
			return "Ruil één kaart en kies daarna de beste van twee nieuwe kaarten."
		PowerUpId.WASDAG:
			return "Voorkom het strafpunt als jouw geblufte Was wordt betrapt."
		PowerUpId.DUBBEL_KLOPPEN:
			return "Maak je volgende KLOP extra waardevol: winst levert twee extra bierdopjes op."
		PowerUpId.STALEN_ZENUWEN:
			return "Ga automatisch MEE en krijg bij verlies één strafpunt minder."
		_:
			return "Onbekend effect."


static func timing(id: String) -> String:
	match id:
		PowerUpId.KAARTJE_RUILEN, PowerUpId.HUISVOORDEEL:
			return "Gebruik vóórdat je eerste kaart is gespeeld."
		PowerUpId.EVEN_SPIEKEN:
			return "Gebruik wanneer jij een keuze mag maken."
		PowerUpId.OP_HET_RANDJE:
			return "Automatisch zodra je 15 punten zou bereiken."
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			return "Gebruik tussen twee slagen of rondes."
		PowerUpId.WASDAG:
			return "Gebruik zodra een tegenstander jouw Was betwist."
		PowerUpId.DUBBEL_KLOPPEN:
			return "Activeer vlak vóór je op KLOP drukt."
		PowerUpId.STALEN_ZENUWEN:
			return "Gebruik wanneer je na een KLOP moet kiezen."
		_:
			return ""


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
