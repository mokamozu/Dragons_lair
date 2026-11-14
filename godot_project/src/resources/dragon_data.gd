class_name DragonData
extends Resource

const SAVE_PATH: String = "user://dragon_data.tres"
const DRAGON_STATS_SCRIPT: Script = preload("res://src/systems/dragon_stats.gd")

@export var player_name: String = "Cavaleiro"
@export var dragon_name: String = "Brasa"
@export var player_mbti: String = "ENFP-A"
@export var dragon_mbti: String = "ISFJ-T"
@export var species: String = "Dragão Ártico"
@export var species_id: String = ""
@export var species_profile: DragonSpeciesData
@export var element: String = "Fogo"
@export var behavioral_trait: String = "Protetor / Leal"
@export var weapon: String = "Espada e Escudo"
@export var exhausted_first_day: bool = false
@export var hp_bonus: float = 0.0
@export var stamina_bonus: float = 0.0
@export var elemental_power_bonus: float = 0.0
@export var carry_bonus: float = 0.0
@export var air_speed_multiplier: float = 1.0
@export var critical_bonus: float = 0.0
@export var stamina_regen_multiplier: float = 1.0
@export var turn_agility_multiplier: float = 1.0
@export var flight_stamina_cost_multiplier: float = 1.0
@export var heat_resistance: bool = false
@export var swim_speed_multiplier: float = 1.0
@export var trait_attack_multiplier: float = 1.0
@export var trait_attack_hp_threshold: float = 0.0
@export var trait_defense_bonus: float = 0.0
@export var trait_defense_range: float = 0.0
@export var trait_flight_speed_multiplier: float = 1.0
@export var bond_affection_multiplier: float = 1.0
@export var resists_fear: bool = false
@export var personality_scores: Dictionary = {}
@export var battle_result: String = "pending"
@export var trait_redemption_progress: int = 0


func create_dragon_stats() -> DragonStats:
	var stats: DragonStats = DRAGON_STATS_SCRIPT.new()
	stats.dragon_name = dragon_name
	stats.element = "Água/Gelo" if element == "Água / Gelo" else element
	stats.max_hp = 120.0 + hp_bonus
	stats.max_stamina = 100.0 + stamina_bonus
	stats.elemental_power = 12.0 + elemental_power_bonus
	stats.physical_strength = 10.0
	stats.carry_capacity = 40.0 + carry_bonus
	stats.movement_speed = 8.0
	stats.agility = 8.0 * turn_agility_multiplier
	stats.attack = 10.0
	stats.critical_chance = 0.08
	stats.critical_damage_multiplier = 1.5 * (1.0 + critical_bonus)
	stats.stamina_regen_multiplier = stamina_regen_multiplier
	stats.flight_stamina_cost_multiplier = flight_stamina_cost_multiplier
	stats.flight_speed_multiplier = air_speed_multiplier * trait_flight_speed_multiplier
	stats.situational_attack_multiplier = trait_attack_multiplier
	stats.attack_hp_threshold = trait_attack_hp_threshold
	stats.trait_defense_bonus = trait_defense_bonus
	stats.trait_defense_range = trait_defense_range
	stats.bond_affection_multiplier = bond_affection_multiplier
	stats.resists_fear = resists_fear
	stats.heat_resistance = heat_resistance
	stats.swim_speed_multiplier = swim_speed_multiplier
	return stats


func save_to_disk() -> Error:
	return ResourceSaver.save(self, SAVE_PATH)


func resolve_species_profile() -> DragonSpeciesData:
	var profile: DragonSpeciesData = DragonSpeciesCatalog.get_profile(dragon_mbti)
	if profile == null:
		return null
	species_profile = profile
	species_id = profile.species_id
	species = profile.species_name
	return profile


static func load_saved() -> DragonData:
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var loaded: Resource = ResourceLoader.load(SAVE_PATH, "DragonData")
	if loaded is DragonData:
		if loaded.resolve_species_profile() == null:
			return null
		return loaded
	push_error("O arquivo salvo do vínculo existe, mas não contém DragonData válido.")
	return null
