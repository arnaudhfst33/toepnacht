class_name PowerUpId
extends RefCounted

const KAARTJE_RUILEN := "kaartje_ruilen"
const EVEN_SPIEKEN := "even_spieken"
const OP_HET_RANDJE := "op_het_randje"
const RONDJE_VAN_DE_ZAAK := "rondje_van_de_zaak"
const HUISVOORDEEL := "huisvoordeel"
const WASDAG := "wasdag"
const DUBBEL_KLOPPEN := "dubbel_kloppen"
const STALEN_ZENUWEN := "stalen_zenuwen"

const MAX_SLOTS := 2


static func all_ids() -> PackedStringArray:
	return PackedStringArray([
		KAARTJE_RUILEN,
		EVEN_SPIEKEN,
		OP_HET_RANDJE,
		RONDJE_VAN_DE_ZAAK,
		HUISVOORDEEL,
		WASDAG,
		DUBBEL_KLOPPEN,
		STALEN_ZENUWEN,
	])
