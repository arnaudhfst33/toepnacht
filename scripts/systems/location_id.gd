class_name LocationId
extends RefCounted

const STUDENTENHUIS := 0
const KROEG := 1
const HUISFEEST := 2
const SOCIETEIT := 3
const COUNT := 4


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
