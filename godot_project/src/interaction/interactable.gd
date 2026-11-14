extends StaticBody3D

@export_enum("resource", "door", "farm_plot") var interaction_type: String = "resource"
@export var display_name: String = "Recurso"
@export var resource_amount: int = 1

var _opened: bool = false
var _harvested: bool = false


func interact(_actor: Node) -> String:
	match interaction_type:
		"resource":
			queue_free()
			return "%s coletado (+%d)" % [display_name, resource_amount]
		"door":
			_opened = not _opened
			rotation.y += deg_to_rad(85.0 if _opened else -85.0)
			return "A porta foi %s." % ("aberta" if _opened else "fechada")
		"farm_plot":
			_harvested = not _harvested
			return "Canteiro %s." % ("colhido" if _harvested else "preparado para plantio")
	return "Nada aconteceu."
