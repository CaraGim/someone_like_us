extends Area3D
class_name Interactable

@export var label_offset: Vector3 = Vector3(0, 0.5, 0)

func interact(_player: Node) -> void:
	pass

func get_prompt() -> String:
	return ""

## World-space point the HUD prompt label should hover above.
func get_label_position() -> Vector3:
	return global_position + label_offset
