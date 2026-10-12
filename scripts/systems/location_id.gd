class_name LocationId
extends RefCounted

const STUDENTENHUIS := 0
const KROEG := 1
const HUISFEEST := 2
const SOCIETEIT := 3
const COUNT := 4


static func placeholder_color(location: int) -> Color:
	match location:
		STUDENTENHUIS:
			return Color(0.12, 0.22, 0.16)
		KROEG:
			return Color(0.18, 0.12, 0.10)
		HUISFEEST:
			return Color(0.16, 0.10, 0.20)
		SOCIETEIT:
			return Color(0.10, 0.12, 0.20)
		_:
			return Color(0.12, 0.14, 0.12)


static func next_location(location: int) -> int:
	if location < SOCIETEIT:
		return location + 1
	return -1


static func display_name(location: int) -> String:
	match location:
		STUDENTENHUIS:
			return "Studentenhuis"
		KROEG:
			return "Kroeg"
		HUISFEEST:
			return "Huisfeest"
		SOCIETEIT:
			return "Sociëteit"
		_:
			return "?"


static func boss_name(location: int) -> String:
	match location:
		STUDENTENHUIS:
			return "De Huisoudste"
		KROEG:
			return "De Barman"
		HUISFEEST:
			return "De Regelaar"
		SOCIETEIT:
			return "De Praeses"
		_:
			return "?"
