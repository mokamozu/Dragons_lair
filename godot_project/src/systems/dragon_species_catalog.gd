class_name DragonSpeciesCatalog
extends RefCounted

const SPECIES: Dictionary = {
	"INTJ": {
		"name": "Draco Arcano",
		"form": "Dragão Clássico",
		"group": "Analistas",
		"anatomy": "Quatro patas e duas asas grandes; porte majestoso.",
		"head": "H",
		"wing": "Fingered",
		"tail": "Sword",
		"specialty": "Dano elemental à distância e alta precisão mágica.",
	},
	"INTP": {
		"name": "Lung Celestial",
		"form": "Dragão Oriental",
		"group": "Analistas",
		"anatomy": "Corpo serpentino longo, sem asas; levita por magia.",
		"head": "G",
		"wing": "Sem asas",
		"tail": "Heaven",
		"specialty": "Regeneração rúnica de energia e controle de área.",
	},
	"ENTJ": {
		"name": "Hidra Soberana",
		"form": "Hidra",
		"group": "Analistas",
		"anatomy": "Corpo pesado com duas ou três cabeças e asas.",
		"head": "B",
		"wing": "Handed",
		"tail": "Morningstar",
		"specialty": "Ataques múltiplos simultâneos e intimidação.",
	},
	"ENTP": {
		"name": "Anfíptero Ilusório",
		"form": "Amphiptere",
		"group": "Analistas",
		"anatomy": "Corpo serpentino sem patas, sustentado por duas asas enormes.",
		"head": "E",
		"wing": "Accordion",
		"tail": "Dagger",
		"specialty": "Esquiva aérea, rajadas rápidas e truques elementais.",
	},
	"INFJ": {
		"name": "Coatyl Místico",
		"form": "Coatyl",
		"group": "Diplomatas",
		"anatomy": "Serpente emplumada com asas de ave.",
		"head": "J",
		"wing": "Penas",
		"tail": "Feather",
		"specialty": "Auras de purificação, cura passiva e resistência mágica.",
	},
	"INFP": {
		"name": "Dragão Feérico",
		"form": "Feydragon",
		"group": "Diplomatas",
		"anatomy": "Corpo esguio com asas translúcidas de mariposa ou inseto.",
		"head": "C",
		"wing": "Membrana translúcida",
		"tail": "River",
		"specialty": "Favorece plantas mágicas e restaura energia.",
	},
	"ENFJ": {
		"name": "Serpe Solar",
		"form": "Zilant",
		"group": "Diplomatas",
		"anatomy": "Duas patas dianteiras e asas largas; postura erguida.",
		"head": "K",
		"wing": "6-Fingered",
		"tail": "Heaven",
		"specialty": "Fortalece ataque e defesa de aliados próximos.",
	},
	"ENFP": {
		"name": "Dragonete Etéreo",
		"form": "Dragonette",
		"group": "Diplomatas",
		"anatomy": "Porte médio e ágil, quatro patas leves e asas largas.",
		"head": "A",
		"wing": "Padrão F",
		"tail": "Fire",
		"specialty": "Favorece coletas raras e reduz o custo de impulso aéreo.",
	},
	"ISTJ": {
		"name": "Basilisco Blindado",
		"form": "Basilisk",
		"group": "Sentinelas",
		"anatomy": "Corpo baixo e largo, seis patas e couraça dorsal espinhosa.",
		"head": "I",
		"wing": "Sem asas",
		"tail": "Club",
		"specialty": "Defesa física extrema e resistência a atordoamento.",
	},
	"ISFJ": {
		"name": "Dragão Ártico",
		"form": "Arctic Dragon",
		"group": "Sentinelas",
		"anatomy": "Corpo robusto, adaptado ao frio, com pelagem ou escamas densas.",
		"head": "D",
		"wing": "Padrão J",
		"tail": "Deep Sea",
		"specialty": "Proteção por barreiras de gelo e resistência a climas hostis.",
	},
	"ESTJ": {
		"name": "Salamandra de Guerra",
		"form": "Salamander",
		"group": "Sentinelas",
		"anatomy": "Seis patas musculosas e asas médias para máxima tração.",
		"head": "F",
		"wing": "Handed",
		"tail": "Battle",
		"specialty": "Alta capacidade de carga para mineração e colheita.",
	},
	"ESFJ": {
		"name": "Leviatã das Marés",
		"form": "Sea Dragon",
		"group": "Sentinelas",
		"anatomy": "Corpo aquático com barbatanas dorsais e membranas de planagem.",
		"head": "K",
		"wing": "Rayed",
		"tail": "River",
		"specialty": "Irrigação da fazenda e deslocamento rápido na água.",
	},
	"ISTP": {
		"name": "Draco Terrestre",
		"form": "Drake",
		"group": "Exploradores",
		"anatomy": "Quatro patas musculosas, sem asas; saltos e corrida.",
		"head": "B",
		"wing": "Sem asas",
		"tail": "Scorpion",
		"specialty": "Dano físico, quebra de armadura e velocidade no solo.",
	},
	"ISFP": {
		"name": "Wyvern Silvestre",
		"form": "Wyvern",
		"group": "Exploradores",
		"anatomy": "Duas patas traseiras; asas que também apoiam o corpo no chão.",
		"head": "A",
		"wing": "Padrão C",
		"tail": "Mountain",
		"specialty": "Manobrabilidade em florestas, montanhas e desfiladeiros.",
	},
	"ESTP": {
		"name": "Wyrm Predador",
		"form": "Wyrm",
		"group": "Exploradores",
		"anatomy": "Corpo serpentino grande e ágil, sem patas ou asas.",
		"head": "E",
		"wing": "Sem asas",
		"tail": "Sword",
		"specialty": "Emboscadas rápidas, dano crítico e perfuração de defesas.",
	},
	"ESFP": {
		"name": "Lindwurm Veloz",
		"form": "Lindwurm",
		"group": "Exploradores",
		"anatomy": "Corpo serpentino com duas patas dianteiras fortes e garras.",
		"head": "H",
		"wing": "Padrão I",
		"tail": "Dagger",
		"specialty": "Combos rápidos e críticos durante o movimento.",
	},
}


static func get_profile(mbti: String) -> DragonSpeciesData:
	var code: String = _base_mbti_code(mbti)
	if not SPECIES.has(code):
		push_error("Não existe espécie de dragão cadastrada para o MBTI '%s'." % mbti)
		return null

	var definition: Dictionary = SPECIES[code]
	var profile: DragonSpeciesData = DragonSpeciesData.new()
	profile.species_id = code.to_lower()
	profile.mbti_code = code
	profile.species_name = str(definition["name"])
	profile.common_form = str(definition["form"])
	profile.mbti_group = str(definition["group"])
	profile.anatomy = str(definition["anatomy"])
	profile.head_profile = str(definition["head"])
	profile.wing_profile = str(definition["wing"])
	profile.tail_profile = str(definition["tail"])
	profile.specialty = str(definition["specialty"])
	return profile


static func get_species_ids() -> Array[String]:
	var result: Array[String] = []
	for code: String in SPECIES:
		result.append(code.to_lower())
	result.sort()
	return result


static func _base_mbti_code(mbti: String) -> String:
	var normalized: String = mbti.strip_edges().to_upper().replace("-", "")
	if normalized.length() < 4:
		return ""
	return normalized.substr(0, 4)
