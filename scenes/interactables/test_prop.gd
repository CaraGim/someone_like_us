extends Interactable

@export var highlight_color: Color = Color(0.9, 0.8, 0.2)
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func interact(_player: Node) -> void:
	print("Interacted with ", name)
	var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	material.albedo_color = highlight_color

func get_prompt() -> String:
	return "F key to collect"
