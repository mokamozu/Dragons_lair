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
@export_range(0.0, 1000.0, 0.5) var luck: float = 5.0
