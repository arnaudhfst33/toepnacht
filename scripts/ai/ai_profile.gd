class_name AiProfile
extends RefCounted

var label: String = "baseline"
var error_rate: float = 0.12
var knock_scale: float = 1.0
var mee_pass_chaos: float = 0.12
var aggressive_card_rate: float = 0.45
var is_boss: bool = false
var display_name: String = "AI"


static func baseline() -> AiProfile:
	return AiProfile.new()


static func studentenhuis_potje1() -> AiProfile:
	var p := AiProfile.new()
	p.label = "studentenhuis_p1"
	p.display_name = "Huisgenoot"
	p.error_rate = 0.26
	p.knock_scale = 0.4
	p.mee_pass_chaos = 0.2
	p.aggressive_card_rate = 0.32
	return p


static func studentenhuis_potje2() -> AiProfile:
	var p := AiProfile.new()
	p.label = "studentenhuis_p2"
	p.display_name = "Bestuurslid"
	p.error_rate = 0.14
	p.knock_scale = 0.85
	p.mee_pass_chaos = 0.12
	p.aggressive_card_rate = 0.48
	return p


static func studentenhuis_potje3_table() -> AiProfile:
	var p := AiProfile.new()
	p.label = "studentenhuis_p3"
	p.display_name = "Huisgenoot"
	p.error_rate = 0.1
	p.knock_scale = 1.15
	p.mee_pass_chaos = 0.08
	p.aggressive_card_rate = 0.55
	return p


static func huisoudste() -> AiProfile:
	var p := AiProfile.new()
	p.label = "huisoudste"
	p.display_name = "De Huisoudste"
	p.is_boss = true
	p.error_rate = 0.06
	p.knock_scale = 1.7
	p.mee_pass_chaos = 0.05
	p.aggressive_card_rate = 0.7
	return p


static func for_studentenhuis(potje: int, seat: int) -> AiProfile:
	if potje <= 1:
		var p1 := studentenhuis_potje1()
		var n1 := PackedStringArray(["Eerstejaars", "Huisgenoot", "Oud-lid"])
		p1.display_name = n1[seat - 1]
		return p1
	if potje == 2:
		var p2 := studentenhuis_potje2()
		var n2 := PackedStringArray(["Bestuurslid", "Feestcie", "Kotbaas"])
		p2.display_name = n2[seat - 1]
		return p2
	if seat == 1:
		return huisoudste()
	var p3 := studentenhuis_potje3_table()
	p3.display_name = "Huisgenoot" if seat == 2 else "Barploeg"
	return p3
