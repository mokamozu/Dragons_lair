class_name DragonStats
extends Resource

@export var dragon_name: String = "Brasa"
@export_enum("Fogo", "Terra", "Vento", "Água/Gelo") var element: String = "Fogo"
@export_range(1.0, 10000.0, 1.0) var max_hp: float = 120.0
@export_range(1.0, 10000.0, 1.0) var max_stamina: float = 100.0
@export_range(0.0, 1000.0, 0.5) var elemental_power: float = 12.0
@export_range(0.0, 1000.0, 0.5) var physical_strength: float = 10.0
@export_range(0.0, 10000.0, 0.5) var carry_capacity: float = 40.0
@export_range(0.0, 100.0, 0.5) var movement_speed: float = 8.0
@export_range(0.0, 100.0, 0.5) var agility: float = 8.0
@export_range(0.0, 1000.0, 0.5) var attack: float = 10.0
@export_range(0.0, 1.0, 0.01) var critical_chance: float = 0.08
@export_range(1.0, 10.0, 0.05) var critical_damage_multiplier: float = 1.5
@export_range(0.0, 1000.0, 0.5) var luck: float = 5.0
@export_range(0.1, 5.0, 0.05) var stamina_regen_multiplier: float = 1.0
@export_range(0.1, 5.0, 0.05) var flight_stamina_cost_multiplier: float = 1.0
@export_range(0.1, 5.0, 0.05) var flight_speed_multiplier: float = 1.0
@export_range(0.1, 5.0, 0.05) var situational_attack_multiplier: float = 1.0
@export_range(0.0, 1.0, 0.01) var attack_hp_threshold: float = 0.0
@export_range(0.0, 1.0, 0.01) var trait_defense_bonus: float = 0.0
@export_range(0.0, 100.0, 0.5) var trait_defense_range: float = 0.0
@export var resists_fear: bool = false
@export_range(0.1, 5.0, 0.05) var bond_affection_multiplier: float = 1.0
@export var heat_resistance: bool = false
@export_range(0.1, 5.0, 0.05) var swim_speed_multiplier: float = 1.0
