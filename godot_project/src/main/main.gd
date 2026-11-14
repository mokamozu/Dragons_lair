extends Node3D

const WORLD_SCENE: PackedScene = preload("res://scenes/environment/demo_world.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const DRAGON_SCENE: PackedScene = preload("res://scenes/dragon/dragon.tscn")
const HUD_SCENE: PackedScene = preload("res://scenes/ui/hud.tscn")


func _ready() -> void:
	var world: Node3D = WORLD_SCENE.instantiate()
	add_child(world)

	var dragon: CharacterBody3D = DRAGON_SCENE.instantiate()
	dragon.position = Vector3(3.0, 0.05, 2.0)
	add_child(dragon)

	var player: CharacterBody3D = PLAYER_SCENE.instantiate()
	player.position = Vector3(0.0, 0.05, 5.0)
	add_child(player)
	player.call("set_companion", dragon)
	dragon.call("set_follow_target", player)

	var hud: CanvasLayer = HUD_SCENE.instantiate()
	add_child(hud)
	hud.call("bind_player", player)
