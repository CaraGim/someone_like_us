extends Interactable
class_name StageTransition

## Generic "jump into another stage" interactable -- reused for both
## entering an investigation stage from the basement and returning to the
## basement from one. Sets GameMode BEFORE swapping scenes so everything in
## the new scene (CameraRig, HudController, ...) reads the correct mode the
## moment it enters the tree, via each system's own GameMode.mode_changed
## subscription -- this node does not touch camera/HUD/etc. directly.
##
## target_scene_path is a res:// string, not a PackedScene export. Two
## stages that both lead to each other (e.g. basement <-> cemetery) would
## otherwise need mutual PackedScene ext_resource references between their
## .tscn files, which Godot's loader can resolve to null depending on load
## order since neither scene finishes parsing before the other needs it
## back. A path loaded on demand at interact-time has no such cycle.

@export_file("*.tscn") var target_scene_path: String = ""
@export var target_mode: int = GameMode.Mode.SANDBOX
@export var prompt_text: String = "F key to travel"

func interact(_player: Node) -> void:
	if target_scene_path == "":
		push_warning("StageTransition %s has no target_scene_path set" % name)
		return
	GameMode.set_mode(target_mode)
	get_tree().change_scene_to_file(target_scene_path)

func get_prompt() -> String:
	return prompt_text
