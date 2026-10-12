class_name AiProfile
extends RefCounted

var label: String = "baseline"
var error_rate: float = 0.12
var knock_scale: float = 1.0
var mee_pass_chaos: float = 0.12
var aggressive_card_rate: float = 0.45
var public_memory_weight: float = 0.25
var was_bluff_rate: float = 0.04
var challenge_rate: float = 0.18
var is_boss: bool = false
var display_name: String = "AI"


func decision_strength() -> float:
	return (1.0 - error_rate) * (0.35 + 0.65 * public_memory_weight) - mee_pass_chaos * 0.08


static func baseline() -> AiProfile:
	return AiProfile.new()


static func _named(label: String, display: String) -> AiProfile:
	var p := AiProfile.new()
	p.label = label
	p.display_name = display
	return p


static func studentenhuis_potje1() -> AiProfile:
	var p := _named("studentenhuis_p1", "Huisgenoot")
	p.error_rate = 0.26
	p.knock_scale = 0.4
	p.mee_pass_chaos = 0.2
	p.aggressive_card_rate = 0.32
	p.public_memory_weight = 0.12
	p.was_bluff_rate = 0.05
	p.challenge_rate = 0.22
	return p


static func studentenhuis_potje2() -> AiProfile:
	var p := _named("studentenhuis_p2", "Bestuurslid")
	p.error_rate = 0.14
	p.knock_scale = 0.85
	p.mee_pass_chaos = 0.12
	p.aggressive_card_rate = 0.48
	p.public_memory_weight = 0.28
	p.was_bluff_rate = 0.04
	p.challenge_rate = 0.18
	return p


static func studentenhuis_potje3_table() -> AiProfile:
	var p := _named("studentenhuis_p3", "Huisgenoot")
	p.error_rate = 0.1
	p.knock_scale = 1.15
	p.mee_pass_chaos = 0.08
	p.aggressive_card_rate = 0.55
	p.public_memory_weight = 0.35
	p.challenge_rate = 0.16
	return p


static func huisoudste() -> AiProfile:
	var p := _named("huisoudste", "De Huisoudste")
	p.is_boss = true
	p.error_rate = 0.06
	p.knock_scale = 1.7
	p.mee_pass_chaos = 0.05
	p.aggressive_card_rate = 0.7
	p.public_memory_weight = 0.45
	p.challenge_rate = 0.14
	return p


static func kroeg_potje1() -> AiProfile:
	var p := _named("kroeg_p1", "Stamgast")
	p.error_rate = 0.16
	p.knock_scale = 0.7
	p.mee_pass_chaos = 0.12
	p.aggressive_card_rate = 0.42
	p.public_memory_weight = 0.32
	p.challenge_rate = 0.16
	return p


static func kroeg_potje2() -> AiProfile:
	var p := _named("kroeg_p2", "Barkeeper")
	p.error_rate = 0.1
	p.knock_scale = 0.95
	p.mee_pass_chaos = 0.08
	p.aggressive_card_rate = 0.5
	p.public_memory_weight = 0.48
	p.challenge_rate = 0.14
	return p


static func kroeg_potje3_table() -> AiProfile:
	var p := _named("kroeg_p3", "Stamgast")
	p.error_rate = 0.08
	p.knock_scale = 1.05
	p.mee_pass_chaos = 0.07
	p.aggressive_card_rate = 0.52
	p.public_memory_weight = 0.5
	return p


static func barman() -> AiProfile:
	var p := _named("barman", "De Barman")
	p.is_boss = true
	p.error_rate = 0.045
	p.knock_scale = 1.15
	p.mee_pass_chaos = 0.04
	p.aggressive_card_rate = 0.58
	p.public_memory_weight = 0.62
	p.was_bluff_rate = 0.02
	p.challenge_rate = 0.12
	return p


static func huisfeest_potje1() -> AiProfile:
	var p := _named("huisfeest_p1", "Feestganger")
	p.error_rate = 0.14
	p.knock_scale = 1.25
	p.mee_pass_chaos = 0.18
	p.aggressive_card_rate = 0.62
	p.public_memory_weight = 0.4
	p.was_bluff_rate = 0.1
	p.challenge_rate = 0.2
	return p


static func huisfeest_potje2() -> AiProfile:
	var p := _named("huisfeest_p2", "Regelaar-hulp")
	p.error_rate = 0.1
	p.knock_scale = 1.15
	p.mee_pass_chaos = 0.22
	p.aggressive_card_rate = 0.55
	p.public_memory_weight = 0.55
	p.was_bluff_rate = 0.08
	p.challenge_rate = 0.18
	return p


static func huisfeest_potje3_table() -> AiProfile:
	var p := _named("huisfeest_p3", "Feestganger")
	p.error_rate = 0.09
	p.knock_scale = 1.2
	p.mee_pass_chaos = 0.16
	p.aggressive_card_rate = 0.58
	p.public_memory_weight = 0.5
	p.was_bluff_rate = 0.09
	return p


static func regelaar() -> AiProfile:
	var p := _named("regelaar", "De Regelaar")
	p.is_boss = true
	p.error_rate = 0.11
	p.knock_scale = 1.85
	p.mee_pass_chaos = 0.28
	p.aggressive_card_rate = 0.72
	p.public_memory_weight = 0.42
	p.was_bluff_rate = 0.16
	p.challenge_rate = 0.28
	return p


static func societeit_potje1() -> AiProfile:
	var p := _named("societeit_p1", "Sociëteitslid")
	p.error_rate = 0.07
	p.knock_scale = 1.1
	p.mee_pass_chaos = 0.06
	p.aggressive_card_rate = 0.52
	p.public_memory_weight = 0.72
	p.was_bluff_rate = 0.03
	p.challenge_rate = 0.13
	return p


static func societeit_potje2() -> AiProfile:
	var p := _named("societeit_p2", "Senior")
	p.error_rate = 0.045
	p.knock_scale = 1.25
	p.mee_pass_chaos = 0.045
	p.aggressive_card_rate = 0.54
	p.public_memory_weight = 0.82
	p.challenge_rate = 0.11
	return p


static func societeit_potje3_table() -> AiProfile:
	var p := _named("societeit_p3", "Sociëteitslid")
	p.error_rate = 0.04
	p.knock_scale = 1.2
	p.mee_pass_chaos = 0.04
	p.aggressive_card_rate = 0.55
	p.public_memory_weight = 0.8
	return p


static func praeses() -> AiProfile:
	var p := _named("praeses", "De Praeses")
	p.is_boss = true
	p.error_rate = 0.025
	p.knock_scale = 1.35
	p.mee_pass_chaos = 0.03
	p.aggressive_card_rate = 0.6
	p.public_memory_weight = 0.95
	p.was_bluff_rate = 0.035
	p.challenge_rate = 0.1
	return p


static func for_studentenhuis(potje: int, seat: int) -> AiProfile:
	return for_location(LocationId.STUDENTENHUIS, potje, seat)


static func for_location(location: int, potje: int, seat: int) -> AiProfile:
	if potje <= 1:
		return _seat_names(_location_p1(location), location, 1, seat)
	if potje == 2:
		return _seat_names(_location_p2(location), location, 2, seat)
	if seat == 1:
		return _boss(location)
	return _seat_names(_location_p3(location), location, 3, seat)


static func _location_p1(location: int) -> AiProfile:
	match location:
		LocationId.KROEG:
			return kroeg_potje1()
		LocationId.HUISFEEST:
			return huisfeest_potje1()
		LocationId.SOCIETEIT:
			return societeit_potje1()
		_:
			return studentenhuis_potje1()


static func _location_p2(location: int) -> AiProfile:
	match location:
		LocationId.KROEG:
			return kroeg_potje2()
		LocationId.HUISFEEST:
			return huisfeest_potje2()
		LocationId.SOCIETEIT:
			return societeit_potje2()
		_:
			return studentenhuis_potje2()


static func _location_p3(location: int) -> AiProfile:
	match location:
		LocationId.KROEG:
			return kroeg_potje3_table()
		LocationId.HUISFEEST:
			return huisfeest_potje3_table()
		LocationId.SOCIETEIT:
			return societeit_potje3_table()
		_:
			return studentenhuis_potje3_table()


static func _boss(location: int) -> AiProfile:
	match location:
		LocationId.KROEG:
			return barman()
		LocationId.HUISFEEST:
			return regelaar()
		LocationId.SOCIETEIT:
			return praeses()
		_:
			return huisoudste()


static func _seat_names(p: AiProfile, location: int, potje: int, seat: int) -> AiProfile:
	var names := _names(location, potje)
	if seat >= 1 and seat <= names.size():
		p.display_name = names[seat - 1]
	return p


static func _names(location: int, potje: int) -> PackedStringArray:
	if location == LocationId.KROEG:
		if potje == 1:
			return PackedStringArray(["Stamgast", "Proost", "Tapper"])
		if potje == 2:
			return PackedStringArray(["Barkeeper", "Stamgast", "Student"])
		return PackedStringArray(["Stamgast", "Stamgast", "Student"])
	if location == LocationId.HUISFEEST:
		if potje == 1:
			return PackedStringArray(["Feestganger", "DJ", "Kotgenoot"])
		if potje == 2:
			return PackedStringArray(["Regelaar-hulp", "Feestganger", "Buur"])
		return PackedStringArray(["Feestganger", "DJ", "Buur"])
	if location == LocationId.SOCIETEIT:
		if potje == 1:
			return PackedStringArray(["Sociëteitslid", "Abactis", "Fiscus"])
		if potje == 2:
			return PackedStringArray(["Senior", "Abactis", "Fiscus"])
		return PackedStringArray(["Sociëteitslid", "Abactis", "Fiscus"])
	if potje <= 1:
		return PackedStringArray(["Feut", "Sjaars", "Huisoudste"])
	if potje == 2:
		return PackedStringArray(["Bestuurslid", "Feestcie", "Kotbaas"])
	return PackedStringArray(["Huisgenoot", "Huisgenoot", "Barploeg"])
